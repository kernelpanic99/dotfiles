fish_add_path -g ~/.local/bin

if status is-interactive
    set -gx EDITOR nvim
    set -gx VISUAL nvim

    # timewarrior
    alias tw   timew
    alias tws  'timew start'
    alias twp  'timew stop'
    alias twi  'timew summary :ids'
    alias twc  'timew continue'
    alias twd  'timew delete'

    alias nt   't ~/Documents/Notes'

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
    end
end
