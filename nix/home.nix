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
      NIXOS_OZONE_WL = "1";
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
      lazygit
      nodejs
      vtsls
      rust-analyzer
      nixd
      flyctl

      # Terminal UX
      fzf
      grc
      ouch

      # Desktop / Wayland
      xwayland-satellite
      wl-clipboard
      cliphist
      brightnessctl
      pavucontrol
      libappindicator
      gobject-introspection
      mesa-demos

      # Apps
      brave
      libreoffice-fresh
      seahorse
      stress-ng
      furmark
      guvcview
      telegram-desktop
      chromium
      zathura
      mdfried

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
      "crush/crush.json".text = builtins.toJSON (import ./config/crush.nix);
      "eilmeldung/save-article.sh" = {
        source = ./config/save-article.sh;
        executable = true;
      };
    };

    desktopEntries.nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      exec = "foot -e nvim %F";
      terminal = false;
      categories = ["TextEditor" "Development"];
      mimeType = [
        "text/plain"
        "text/markdown"
        "text/x-shellscript"
        "text/x-c"
        "text/x-c++"
        "text/x-python"
        "text/x-rust"
        "text/x-javascript"
        "text/x-nix"
        "text/css"
      ];
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "x-scheme-handler/telegram" = "telegram-desktop.desktop";
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";
        "text/x-shellscript" = "nvim.desktop";
        "text/x-c" = "nvim.desktop";
        "text/x-c++" = "nvim.desktop";
        "text/x-python" = "nvim.desktop";
        "text/x-rust" = "nvim.desktop";
        "text/x-javascript" = "nvim.desktop";
        "text/x-nix" = "nvim.desktop";
        "text/css" = "nvim.desktop";
      };
    };
  };

  programs = {
    eilmeldung = import ./config/eilmeldung.nix;
    foot = import ./config/foot.nix;
    noctalia = import ./config/noctalia/noctalia.nix;
    fish = import ./config/fish.nix {inherit pkgs;};
    tmux = import ./config/tmux.nix {inherit pkgs;};
    yazi = import ./config/yazi.nix {inherit pkgs;};
    rmpc = import ./config/rmpc.nix;
    satty = import ./config/satty.nix;
    btop = import ./config/btop.nix {inherit pkgs;};
    nixvim.imports = [./config/nixvim/init.nix];

    fastfetch = import ./config/fastfetch.nix;

    devenv = {
      enable = true;
      enableFishIntegration = true;
    };

    obs-studio = {
      enable = true;
    };

    claude-code = {
      enable = true;
      enableMcpIntegration = false;

      settings = {
        includeCoAuthoredBy = false;
        tui = "fullscreen";
        theme = "dark";
        model = "opus";
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name = "Arthur Nikolaienko";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    dircolors = {
      enable = true;
      enableFishIntegration = true;
    };

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
      name = "catppuccin-macchiato-peach-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = ["peach"];
        variant = "macchiato";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  services = {
    udiskie.enable = true;

    flatpak = {
      enable = true;
      update.onActivation = true;
      uninstallUnmanaged = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      packages = [
        "io.wavebox.Wavebox"
      ];

      overrides.global = {
        "Session Bus Policy"."org.kde.StatusNotifierWatcher" = "talk";
        Environment.TZ = "Europe/Athens";
      };
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

    mpd-mpris.enable = true;
  };

  systemd.user.services.eilmeldung-sync = {
    Service.ExecStart = "${pkgs.eilmeldung}/bin/eilmeldung --sync";
  };

  systemd.user.timers.eilmeldung-sync-timer = {
    Unit.Description = "Hourly eilmeldung sync";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "eilmeldung-sync.service";
    };
    Install.WantedBy = ["timers.target"];
  };
}
