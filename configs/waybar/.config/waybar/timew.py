#!/usr/bin/env python

import argparse
import json
import subprocess
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import List, NotRequired, TypedDict

from dateutil import parser

config = {
    "show_seconds": True,
    "tag_character": "-",
    "fallback_tag_index": -1,
    "idle_threshold": 10,
}


class Status(Enum):
    ACTIVE = "active"
    PAUSED = "paused"
    STOPPED = "stopped"
    IDLE = "idle"

    def to_json(self):
        return self.value


NO_TRACKING = json.dumps(
    {"class": Status.STOPPED.to_json(), "text": ""}
)  # With empty text widget won't show up


class TimewTask(TypedDict):
    id: int
    start: str
    end: NotRequired[str]
    tags: NotRequired[List[str]]


def calculate_total(tasks: List[TimewTask], show_seconds: bool = True) -> str:
    total = timedelta(0)

    for task in tasks:
        start = parser.parse(task["start"])
        end = parser.parse(task["end"]) if "end" in task else datetime.now(timezone.utc)

        total += end - start

    # Convert to HH:MM:SS
    seconds = int(total.total_seconds())
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60

    seconds = f":{seconds % 60:02d}" if show_seconds else ""

    return f"{hours:02d}:{minutes:02d}{seconds}"


def get_current_task() -> tuple[TimewTask | None, List[TimewTask] | None]:
    all_tasks: List[TimewTask] = json.loads(
        subprocess.run(
            ["timew", "export", ":today"], capture_output=True, text=True, timeout=1
        ).stdout
    )

    if not all_tasks:
        return None, None

    return all_tasks[-1], all_tasks


def get_display_tag(tags: List[str] | None) -> str:
    if not tags:
        return "empty"

    for tag in tags:
        if config["tag_character"] in tag:
            return tag

    index = config.get("fallback_tag_index", -1)

    return tags[index]


def is_idle(task: TimewTask) -> bool:
    if "end" not in task:
        return False

    delta = datetime.now(timezone.utc) - parser.parse(task["end"])

    return delta > timedelta(minutes=config["idle_threshold"] or 10)


def to_waybar(_task: TimewTask | None, all_tasks: List[TimewTask] | None) -> str:
    if _task is None or all_tasks is None:
        return NO_TRACKING

    tags = _task.get("tags", [])
    task: List[TimewTask] = []

    for t in all_tasks:
        if t.get("tags", []) == tags:  # timew sorts tags, so this is sufficient
            task.append(t)

    if not task:
        return NO_TRACKING

    total = calculate_total(task, config["show_seconds"])
    day_total = calculate_total(all_tasks, False)
    status = (
        Status.ACTIVE
        if "end" not in _task
        else Status.IDLE
        if is_idle(_task)
        else Status.PAUSED
    )

    tag = get_display_tag(tags)

    return json.dumps(
        {
            "class": status.to_json(),
            "text": f"{tag} {total}/{day_total}",
        }
    )


def toggle(_task: TimewTask):
    if "end" in _task:
        subprocess.run(["timew", "continue"])
    else:
        subprocess.run(["timew", "stop"])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--toggle", action="store_true", help="Toggle task")
    args = parser.parse_args()

    task, all_tasks = get_current_task()

    if args.toggle and task is not None:
        toggle(task)
    else:
        print(to_waybar(task, all_tasks))


if __name__ == "__main__":
    main()
