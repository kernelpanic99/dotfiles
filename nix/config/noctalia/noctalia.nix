{
  enable = true;

  settings = {
    bar.default = {
      capsule_group = [
        {
          fill = "surface_variant";
          id = "g1";
          members = ["clock" "notifications"];
          opacity = 1.0;
          padding = 6.0;
        }

        {
          fill = "surface_variant";
          id = "g2";
          members = ["media" "audio_visualizer"];
          opacity = 1.0;
          padding = 6.0;
        }
      ];
      start = ["launcher" "workspaces" "niri_windows"];
      center = ["timew" "group:g1" "group:g2"];
      end = [
        "tray"
        "keyboard_layout"
        "clipboard"
        "network"
        "bluetooth"
        "volume"
        "battery"
        "session"
      ];
      font_family = "ComicShannsMono Nerd Font";

      margin_ends = 0;
      radius_top_left = 0;
      radius_top_right = 0;

      thickness = 35;
    };

    plugins = {
      enabled = ["kernelpanic99/timew" "kernelpanic99/niri_windows"];
      source = [
        {
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          name = "official";
        }
        {
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          name = "community";
        }
        {
          kind = "path";
          location = "~/dotfiles/nix/config/noctalia/plugins/";
          name = "dev";
        }
      ];
    };

    location.address = "Odessa, Ukraine";

    shell = {
      font_family = "ComicShannsMono Nerd Font Mono";
      screenshot = {
        pipe_command = "satty -f -";
        pipe_to_command = true;
        save_to_file = false;
      };
    };

    theme = {
      builtin = "Catppuccin";
      templates = {
        builtin_ids = ["foot" "gtk3" "gtk4" "niri"];
        community_ids = ["yazi"];
      };
    };

    wallpaper = {
      directory = "~/Pictures/Wallpapers";
      automation = {
        enabled = true;
        interval_seconds = 600;
      };
    };

    widget = {
      battery = {
        hide_when_full = true;
        hide_when_plugged = true;
      };
      clock.format = "{:%H:%M %a %d-%m-%y}";
      network.show_label = false;
      timew = {
        capsule = true;
        type = "kernelpanic99/timew:timew";
      };
      workspaces = {
        empty_color = "on_surface";
        hide_when_empty = true;
      };
      media = {
        album_art_only = true;
      };
      niri_windows = {
        type = "kernelpanic99/niri_windows:niri_windows";
      };
    };

    idle = {
      behavior = {
        stop-tracker = {
          action = "command";
          enabled = true;
          timeout = 300;
          command = "timew stop";
        };
        stop-player = {
          action = "command";
          enabled = true;
          timeout = 590;
          command = "mpc pause";
        };
        lock = {
          action = "lock";
          enabled = true;
          timeout = 600;
        };
        screen-off = {
          action = "screen_off";
          enabled = true;
          timeout = 660;
        };
        lock-and-suspend = {
          action = "lock-and-suspend";
          enabled = true;
          timeout = 900;
        };
      };
    };
  };
}
