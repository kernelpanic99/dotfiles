if status is-interactive
    abbr --add xi yay -Syu
    abbr --add xr yay -Rsn
    abbr --add xs yay -Ss

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

    alias nvoff="sudo /usr/share/acpi_call/examples/turn_off_gpu.sh"
end

mise activate fish | source
direnv hook fish | source

function full-upgrade
    # Toolchain managers first
    echo "Upgrading system..."
    yay -Syu --noconfirm

    echo "Upgrading toolchains..."
    mise upgrade & rustup update & wait

    # Everything else concurrently
    cargo install-update -a & fisher update & uv tool upgrade --all & pnpm update -g & nvim --headless '+Lazy! sync' +qa & ya pkg upgrade & ~/.config/tmux/plugins/tpm/bin/update_plugins all & wait
end

# pnpm
set -gx PNPM_HOME "/home/kp/.local/share/pnpm"

if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Change CWD on exit from yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"

    if set cwd (cat -- "$tmp") && test -n "$cwd" && test "$cwd" != "$PWD"
        cd -- "$cwd"
    end

    rm -f -- "$tmp"
end
