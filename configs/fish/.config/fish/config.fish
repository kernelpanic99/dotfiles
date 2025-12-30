if status is-interactive
    abbr --add xi paru -Syu
    abbr --add xr paru -Rsn
    abbr --add xs paru -Ss

    alias t="smug start"

    alias tw="timew"
    alias tws="timew start"
    alias twp="timew stop"
    alias twi="timew summary :ids"
    alias twc="timew continue"
    alias twd="timew delete"

    alias yw="pipe-viewer"
    alias ys="pipe-viewer -ls"
    alias yc="pipe-viewer -sc"

    alias wb="killall waybar; waybar > /dev/null 2>&1 & disown"
    alias hp="killall hyprpaper; hyprpaper > /dev/null 2>&1 & disown"

    alias ytaud="yt-dlp --extract-audio --audio-format m4a --audio-quality best --embed-metadata"
end

mise activate fish | source
direnv hook fish | source

if test -z "$DISPLAY"; and test "$XDG_VTNR" -eq 1
    exec Hyprland
end

function full-upgrade
    echo "Upgrading system packages..."
    paru -Syu --noconfirm

    echo "Upgrading mise..."
    mise upgrade

    echo "Upgrading cargo..."
    cargo install --list | grep -E '^\w' | awk '{print $1}' | xargs -n1 cargo install

    echo "Upgrading fish..."
    fisher update

    echo "Upgrading python packages..."
    uv tool upgrade --all

    echo "Upgrading npm packages..."
    pnpm update -g
end

# pnpm
set -gx PNPM_HOME "/home/kp/.local/share/pnpm"

if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
