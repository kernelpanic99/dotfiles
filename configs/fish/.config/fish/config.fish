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
end

mise activate fish | source
direnv hook fish | source

if test -z "$DISPLAY"; and test "$XDG_VTNR" -eq 1
    exec Hyprland
end
