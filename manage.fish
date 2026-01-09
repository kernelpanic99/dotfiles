#!/usr/bin/env fish

set configs anyrun btop calcurse copyq fish foot gtk-3.0 gtk-4.0 hypr lazygit mako mise mpd ncmpcpp nvim nwg-drawer nwg-look pipe-viewer satty smug timewarrior swaylock waybar tmux yazi rmpc niri noctalia

function get_configs
    if test (count $argv) -gt 0
        set configs_to_check $argv

        for cfg in $configs_to_check
            if not contains $cfg $configs
                echo "Error: '$cfg' is not in the configs list" >&2
                return 1
            end
        end
    else
        set configs_to_check $configs
    end

    printf '%s\n' $configs_to_check
end

function restow
    set configs (get_configs $argv)
    or return

    cd ./configs

    for cfg in $configs
        stow -R "$cfg" -t ~/

        echo "$cfg restowed"
    end
end

function migrate_configs
    set configs (get_configs $argv)
    or return

    for cfg in $configs
        set dot_dir "./configs/$cfg/.config/"
        set config_dir "$HOME/.config/$cfg"

        if not test -d $config_dir
            echo "Existing config directory '$config_dir' not found, skipping $cfg" >&2
            continue
        end

        if test -d "$dot_dir/$cfg"
            echo "Dotfiles config directory '$dot_dir' already exists, skipping $cfg" >&2
            continue
        end

        echo $cfg $dot_dir $config_dir

        mkdir -p $dot_dir

        echo "Created dotfile directory $dot_dir"

        cp -rf $config_dir "$dot_dir/"

        echo "Copied config directory into dotfiles repo $config_dir -> $dot_dir"

        rm -rf $config_dir

        echo "Removed confid directory $config_dir"
    end

    restow $argv
end

function show_help
    echo "Usage: manage.fish <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  migrate [configs...]  - Migrate configs from ~/.config to dotfiles"
    echo "  restow [configs...]   - Restow configs (all or specified)"
    echo "  help                  - Show this help message"
end

# Main CLI dispatcher
if test (count $argv) -eq 0
    show_help
    exit 1
end

set cmd $argv[1]
set -e argv[1]

switch $cmd
    case migrate
        migrate_configs $argv
    case restow
        restow $argv
    case help
        show_help
    case '*'
        echo "Unknown command: $cmd" >&2
        show_help
        exit 1
end
