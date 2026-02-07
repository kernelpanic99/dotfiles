#!/bin/bash

# A simple wrapper to automatically open neovim when started from godot or focus if already running
# Note: niri compositor and foot terminal only

PROJECT="$1"
FILE="$2"
LINE="$3"
COL="$4"

if [[ -z "$PROJECT" || -z "$FILE" || -z "$LINE" || -z "$COL" ]]; then
    echo "Usage: $0 <path> <file> <line> <col>, in godot arguments - {project} {file} {line} {col}"
    exit 1
fi

function get_win_id() {
    niri msg --json windows 2>/dev/null | jq -r ".[] | select(.title | test(\"^nvim.*$1.*\"; \"i\")).id" 2>/dev/null | head -n1
}

function focus_win() {
    niri msg action focus-window --id "$1" 2>/dev/null
}

DIR=$(basename "$PROJECT")
ID=$(get_win_id "$DIR")

if [[ -n "$ID" ]]; then
    focus_win "$ID"
else
    foot -T "nvim $PROJECT" -e fish -c "cd '$PROJECT' && nvim --listen '$PROJECT/server.pipe'" &
    for i in {1..50}; do
        [[ -e "$PROJECT/server.pipe" ]] && break
        sleep 0.01
    done
fi

nvim --server "$PROJECT/server.pipe" --remote-send "<C-\><C-N>:e $FILE<CR>:call cursor($LINE+1,$COL)<CR>"
