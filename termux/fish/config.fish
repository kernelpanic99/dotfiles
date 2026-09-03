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

    # ssh-agent: on the desktop gnome-keyring did this via PAM. Termux has no
    # keyring, so keychain keeps a single agent alive across shells and reboots.
    if type -q keychain
        keychain --quiet --eval | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
    end
end
