#!/bin/bash
set -euo pipefail

# Allow switching focus in fullscreen mode with up and down directions
# If no window on current monitor, focus the other monitor

dir="$1"
props=$(hyprctl activewindow -j 2>/dev/null)

# Check if there's an active window
if [[ "$props" == "" ]] || ! echo "$props" | jq -e '.address' >/dev/null 2>&1; then
    # No active window, focus the other monitor for left/right
    if [[ "$dir" == "l" ]]; then
        hyprctl dispatch focusmonitor -1
    elif [[ "$dir" == "r" ]]; then
        hyprctl dispatch focusmonitor +1
    fi
    exit 0
fi

is_fullscreen=$(echo "$props" | jq -r '.fullscreen')

if [[ "$is_fullscreen" -eq 1 && ("$dir" == "u" || "$dir" == "d") ]]; then
    hyprctl dispatch cyclenext
else
    hyprctl dispatch movefocus "$dir"
fi
