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
      ];
      center = ["timew" "group:g1" "control-center" "audio_visualizer"];
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
      margin_ends = 5;
      start = ["launcher" "workspaces"];
      thickness = 35;
    };

    plugins = {
      enabled = ["kernelpanic99/timew"];
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

    lockscreen_widgets = {
      enabled = false;
      schema_version = 2;
      widget_order = ["lockscreen-login-box@eDP-1" "lockscreen-login-box@HDMI-A-1"];

      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };

      widget = {
        "lockscreen-login-box@HDMI-A-1" = {
          box_height = 70.0;
          box_width = 400.0;
          cx = 960.0;
          cy = 961.0;
          output = "HDMI-A-1";
          rotation = 0.0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            input_opacity = 1.0;
            input_radius = 6.0;
            show_login_button = true;
          };
        };

        "lockscreen-login-box@eDP-1" = {
          box_height = 70.0;
          box_width = 400.0;
          cx = 768.0;
          cy = 745.0;
          output = "eDP-1";
          rotation = 0.0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            input_opacity = 1.0;
            input_radius = 6.0;
            show_login_button = true;
          };
        };
      };
    };

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
      default.path = "/home/kp/Pictures/Wallpapers/flowers-19.jpg";
      last.path = "/home/kp/Pictures/Wallpapers/flowers-19.jpg";
      monitors = {
        "HDMI-A-1".path = "/home/kp/Pictures/Wallpapers/flowers-19.jpg";
        "eDP-1".path = "/home/kp/Pictures/Wallpapers/flowers-19.jpg";
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
    };
  };
}
