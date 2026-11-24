"""
One-shot EcoFlow BLE client built on eflib from rabits/ha-ef-ble.

  ecoflow status            print device state as JSON
  ecoflow set KEY on|off    flip a toggle (ac_ports, usb_ports, ...) and print state

Reads user_id and serial from $XDG_CONFIG_HOME/ecoflow/config.toml.

Exit codes: 2 config, 3 device not found, 4 auth failed, 5 timeout,
6 command rejected, 7 another invocation holds the lock.
"""

import argparse
import asyncio
import enum
import fcntl
import json
import logging
import os
import sys
import time
import tomllib
from pathlib import Path

import eflib
from bleak import BleakScanner

CONFIG_FILE = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config") / "ecoflow" / "config.toml"
LOCK_FILE = Path(os.environ.get("XDG_RUNTIME_DIR") or "/tmp") / "ecoflow.lock"

SCAN_TIMEOUT = 10
AUTH_TIMEOUT = 20
DUMP_TIMEOUT = 10
DUMP_QUIET = 0.3
DUMP_KEY = "battery_level"
CONFIRM_TIMEOUT = 6
DISCONNECT_TIMEOUT = 5
LOCK_TIMEOUT = 40


class Failure(Exception):
    CONFIG = 2
    NOT_FOUND = 3
    AUTH = 4
    TIMEOUT = 5
    COMMAND = 6
    BUSY = 7

    def __init__(self, code: int, message: str):
        super().__init__(message)
        self.code = code


def load_config() -> tuple[str, str]:
    try:
        config = tomllib.loads(CONFIG_FILE.read_text())
    except FileNotFoundError:
        raise Failure(Failure.CONFIG, f"missing {CONFIG_FILE}")
    except tomllib.TOMLDecodeError as e:
        raise Failure(Failure.CONFIG, f"invalid {CONFIG_FILE}: {e}")

    user_id = str(config.get("user_id", "")).strip()
    serial = str(config.get("serial", "")).strip()

    if not user_id or not serial:
        raise Failure(Failure.CONFIG, f"user_id and serial are required in {CONFIG_FILE}")

    return user_id, serial


def acquire_lock():
    LOCK_FILE.touch(exist_ok=True)
    handle = LOCK_FILE.open("r")
    deadline = time.monotonic() + LOCK_TIMEOUT

    while True:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return handle
        except BlockingIOError:
            if time.monotonic() > deadline:
                raise Failure(Failure.BUSY, "another ecoflow call is still running")

            time.sleep(0.2)


async def scan(serial: str):
    found = asyncio.Event()
    match = {}

    def on_adv(dev, adv):
        sn = eflib.sn_from_advertisement(adv)

        if sn is not None and sn.decode("ascii", "replace") == serial:
            match["dev"], match["adv"] = dev, adv
            found.set()

    async with BleakScanner(detection_callback=on_adv):
        try:
            await asyncio.wait_for(found.wait(), SCAN_TIMEOUT)
        except TimeoutError:
            raise Failure(Failure.NOT_FOUND, f"{serial} not in range or held by another client")

    return match["dev"], match["adv"]


def jsonable(value):
    if isinstance(value, enum.Enum):
        return value.name.lower()

    return value


class Session:
    def __init__(self, device):
        self.device = device
        self.values: dict[str, object] = {}
        self.last_new = 0.0

        for field in device._fields + device._computed_fields:
            if not field.public_name.startswith("_"):
                self._watch(field.public_name)

    def _watch(self, name: str):
        def on_update(value):
            if name not in self.values:
                self.last_new = time.monotonic()

            self.values[name] = value

        self.device.register_state_update_callback(on_update, name)

    def toggles(self) -> dict:
        return {c.key: c for c in eflib.get_controls(self.device, eflib.controls.toggle)}

    async def open(self, user_id: str):
        self.device.with_disabled_reconnect(True)
        await self.device.connect(user_id=user_id, max_attempts=2)

        try:
            state, exc = await asyncio.wait_for(
                self.device.wait_until_authenticated_or_error(return_exc=True),
                AUTH_TIMEOUT,
            )
        except TimeoutError:
            raise Failure(Failure.TIMEOUT, "authentication timed out")

        if not state.authenticated:
            raise Failure(Failure.AUTH, f"{state.name.lower()}: {exc}" if exc else state.name.lower())

        await self._wait_dump()

    async def _wait_dump(self):
        started = time.monotonic()
        deadline = started + DUMP_TIMEOUT

        while True:
            now = time.monotonic()

            if self.values.get(DUMP_KEY) and now - self.last_new >= DUMP_QUIET:
                logging.info("dump complete after %.2fs", now - started)
                return

            if now > deadline:
                raise Failure(Failure.TIMEOUT, f"device sent no {DUMP_KEY} within {DUMP_TIMEOUT}s")

            await asyncio.sleep(0.05)

    async def set_toggle(self, key: str, enabled: bool):
        control = self.toggles()[key]
        await control.enable_func(self.device, enabled)
        deadline = time.monotonic() + CONFIRM_TIMEOUT

        while bool(self.values.get(key)) != enabled:
            if time.monotonic() > deadline:
                raise Failure(Failure.COMMAND, f"device did not confirm {key}={'on' if enabled else 'off'}")

            await asyncio.sleep(0.05)

    async def close(self):
        try:
            await asyncio.wait_for(self.device.disconnect(), DISCONNECT_TIMEOUT)
        except Exception as e:
            logging.debug("disconnect failed: %r", e)

    def snapshot(self) -> dict:
        return {
            "serial": self.device.serial_number,
            "model": self.device.__doc__,
            "updated": int(time.time()),
            "values": {k: jsonable(v) for k, v in sorted(self.values.items())},
            "toggles": sorted(self.toggles()),
        }


async def run(args) -> dict:
    user_id, serial = load_config()
    ble_dev, adv = await scan(serial)
    device = eflib.NewDevice(ble_dev, adv)

    if device is None or eflib.is_unsupported(device):
        raise Failure(Failure.NOT_FOUND, f"{serial} is not a supported model")

    session = Session(device)

    if args.cmd == "set" and args.key not in session.toggles():
        raise Failure(Failure.COMMAND, f"unknown toggle {args.key}, available: {', '.join(sorted(session.toggles()))}")

    try:
        await session.open(user_id)

        if args.cmd == "set":
            await session.set_toggle(args.key, args.state == "on")

        return session.snapshot()
    finally:
        await session.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-v", "--verbose", action="count", default=0)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    setter = sub.add_parser("set")
    setter.add_argument("key")
    setter.add_argument("state", choices=["on", "off"])
    args = parser.parse_args()

    level = {0: logging.CRITICAL, 1: logging.INFO}.get(args.verbose, logging.DEBUG)
    handler = logging.StreamHandler()
    handler.setLevel(level)
    handler.setFormatter(logging.Formatter("%(levelname)s %(name)s: %(message)s"))
    logging.basicConfig(level=level, handlers=[handler])

    try:
        lock = acquire_lock()

        with lock:
            snapshot = asyncio.run(run(args))
    except Failure as e:
        print(f"ecoflow: {e}", file=sys.stderr)
        sys.exit(e.code)
    except KeyboardInterrupt:
        sys.exit(130)

    print(json.dumps(snapshot, default=str))


if __name__ == "__main__":
    main()
