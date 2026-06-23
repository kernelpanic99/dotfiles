{pkgs, ...}: rec {
  imports = [./config/restic.nix];
  home = {
    username = "kp";
    homeDirectory = "/home/kp";
    stateVersion = "26.11"; # TLDR: Don't touch

    sessionVariables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      GDK_BACKEND = "wayland,x11,*";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      OBSIDIAN_USE_WAYLAND = "1";
    };

    packages = with pkgs; [
      # Core CLI
      ripgrep
      fd
      jq
      lsof

      # Dev tooling
      tree-sitter
      gnumake
      python3
      bruno
      claude-code
      lazygit

      # Terminal UX
      fzf
      grc
      btop
      fastfetch
      ouch

      # Desktop / Wayland
      niri
      swayidle
      wl-clipboard
      cliphist
      brightnessctl
      pavucontrol

      # Apps
      brave
      libreoffice-fresh
      seahorse

      # Media
      mpv
      mpc
      yt-dlp

      # Infra / backup
      docker-compose

      # Personal workflow
      timewarrior

      # Security
      gnupg
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    configFile = {
      "niri/config.kdl".source = ./config/niri/config.kdl;
      "xdg-desktop-portal-termfilechooser/config".source = ./config/termfilechooser.conf;
    };
  };

  programs = {
    eilmeldung = import ./config/eilmeldung.nix;
    foot = import ./config/foot.nix;
    noctalia = import ./config/noctalia.nix;
    fish = import ./config/fish.nix {inherit pkgs;};
    neovim = import ./config/nvim/nvim.nix {inherit pkgs;};
    tmux = import ./config/tmux.nix {inherit pkgs;};
    yazi = import ./config/yazi.nix {inherit pkgs;};
    rmpc = import ./config/rmpc.nix;
    satty = import ./config/satty.nix;

    keepassxc = {
      enable = true;

      settings = {
        GUI = {
          Language = "en_US";
          MinimizeOnClose = true;
          MinimizeToTray = true;
          ShowTrayIcon = true;
          TrayIconAppearance = "monochrome-light";
          ApplicationTheme = "dark";
        };

        Security = {
          LockDatabaseIdle = false;
        };
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-mode = true;
      gtk-cursor-theme-size = 24;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-mode = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  services = {
    udiskie.enable = true;

    flatpak = {
      enable = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "nvidia-geforcenow";
          location = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
        }
      ];

      packages = [
        {
          appId = "com.nvidia.geforcenow";
          origin = "nvidia-geforcenow";
        }
        "app.grayjay.Grayjay"
        "io.wavebox.Wavebox"
      ];
    };

    mpd = {
      enable = true;
      musicDirectory = "${home.homeDirectory}/Music";
      network.startWhenNeeded = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "Pipewire Sound Server"
        }
      '';
    };
  };
}
