#!/bin/sh
# Usage: ./partition.sh <host>   e.g. ./partition.sh laptop
#
# WIPES the disk defined in nix/hosts/<host>/disko.nix, then formats and mounts
# it. Double-check the target device in that file before running.
set -eu

host="${1:?usage: $0 <host>   (e.g. laptop, desktop)}"
disko="./nix/hosts/${host}/disko.nix"

[ -f "$disko" ] || {
  echo "no disko config at $disko" >&2
  exit 1
}

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount "$disko"
