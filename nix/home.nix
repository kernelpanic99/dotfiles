{pkgs, ...}: rec {
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
      # Base tools
      ripgrep
      fd
      jq
      lsof
      tree-sitter

      fzf
      lazygit
      btop
      ouch
      restic
      docker-compose
      fastfetch
      niri
      brave
      timewarrior
      yt-dlp
      keepassxc
      pavucontrol
      wl-clipboard
      cliphist
      swayidle
      bruno
      claude-code
      pnpm
      nodejs
      grc
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
    noctalia = {
      enable = true;
    };

    fish = import ./config/fish.nix {inherit pkgs;};
    neovim = import ./config/nvim/nvim.nix {inherit pkgs;};
    tmux = import ./config/tmux.nix {inherit pkgs;};
    yazi = import ./config/yazi.nix {inherit pkgs;};
    zoxide = {
      enable = true;
      enableFishIntegration = true;
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

      packages = [
        "com.nvidia.geforcenow"
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
