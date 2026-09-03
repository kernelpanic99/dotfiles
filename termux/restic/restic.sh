#!/data/data/com.termux/files/usr/bin/bash
# restic wrapper for the Termux workstation, restore-focused: the desktop backs
# up to this repo, the tablet pulls things back down.
#
# Bootstrap (once):
#   mkdir -p ~/.local/share/restic && chmod 700 ~/.local/share/restic
#   echo 'PASSWORD' > ~/.local/share/restic/password
#   echo 'REPO_URL' > ~/.local/share/restic/repository
#   printf 'AWS_ACCESS_KEY_ID=...\nAWS_SECRET_ACCESS_KEY=...\n' > ~/.local/share/restic/env
#   chmod 600 ~/.local/share/restic/{password,repository,env}
# Store the values in your password manager.
#
# Usage:
#   restic.sh snap                     list snapshots
#   restic.sh ls [SUBPATH] [SNAP]      browse a snapshot (default: whole tree, latest)
#   restic.sh find PATTERN             locate a file across all snapshots
#   restic.sh pull SUBPATH [DEST] [SNAP]
#                                      restore a path from the desktop home into DEST
#                                      (DEST default: the same path under $HOME)
#                                        restic.sh pull Documents
#                                        restic.sh pull .ssh
#                                        restic.sh pull Pictures/Wallpapers ~/wp
#   restic.sh cat SUBPATH [SNAP]       stream a single file to stdout
#   restic.sh backup                   local backup of this device, then forget/prune
#   restic.sh ARGS...                  raw restic passthrough

set -euo pipefail

SECRETS="$HOME/.local/share/restic"
export RESTIC_REPOSITORY="$(cat "$SECRETS/repository")"
export RESTIC_PASSWORD_FILE="$SECRETS/password"
set -a
. "$SECRETS/env"
set +a

# Home directory the desktop backs up under (snapshots store absolute paths).
DESKTOP_HOME="${RESTIC_DESKTOP_HOME:-/home/kp}"

abs() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *) printf '%s/%s' "$DESKTOP_HOME" "$1" ;;
  esac
}

cmd="${1:-snap}"
[ $# -gt 0 ] && shift || true

case "$cmd" in
  snap | snapshots)
    restic snapshots "$@"
    ;;

  ls)
    subpath="${1:-/}"
    snap="${2:-latest}"
    restic ls "$snap" "$(abs "$subpath")"
    ;;

  find)
    restic find "${1:?pattern}"
    ;;

  pull)
    subpath="${1:?subpath, e.g. Documents}"
    src="$(abs "$subpath")"
    dest="${2:-$HOME/${subpath#/}}"
    snap="${3:-latest}"
    mkdir -p "$dest"
    restic restore "$snap:$src" --target "$dest"
    printf '\nrestored %s -> %s\n' "$src" "$dest"
    ;;

  cat | dump)
    snap="${2:-latest}"
    restic dump "$snap" "$(abs "${1:?subpath}")"
    ;;

  backup)
    EXCLUDES="$(dirname "$0")/excludes.txt"
    PATHS=(
      "$HOME/dotfiles"
      "$HOME/Documents"
      "$HOME/.ssh"
      "$HOME/.local/share/timewarrior"
    )
    EXISTING=()
    for p in "${PATHS[@]}"; do
      [ -e "$p" ] && EXISTING+=("$p")
    done
    restic backup --exclude-file "$EXCLUDES" "${EXISTING[@]}"
    restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
    ;;

  *)
    exec restic "$cmd" "$@"
    ;;
esac
