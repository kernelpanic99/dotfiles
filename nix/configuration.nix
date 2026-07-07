# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  pkgs,
  ...
}: {
  nix.settings = {
    experimental-features = ["flakes" "nix-command"];

    extra-substituters = ["https://noctalia.cachix.org"];
    extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];

    trusted-users = ["root" "@wheel" "kp"];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Boot configuration.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      verbose = false;
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
      kernelModules = ["kvm-amd" "amdgpu"];
      systemd.enable = true;
    };

    plymouth.enable = true;

    kernelParams = ["quiet" "splash"];
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kp = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"]; # Enable ‘sudo’ for the user.
    createHome = true;
    shell = pkgs.fish;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    tmux
    wget
    gcc
    man-pages
    man-pages-posix
    glib
    lshw
    crush
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.comic-shanns-mono
    ];
  };

  documentation = {
    dev.enable = true;

    man.man-db.enable = false;
    man.mandoc.enable = true;
  };

  # Programs
  programs = {
    dconf.enable = true;
    fish.enable = true;
    xwayland.enable = true;

    niri.enable = true;

    regreet = {
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

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };

      settings = {
        skip_selection = true;
      };
    };

    nix-ld = {
      enable = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  xdg.portal = {
    enable = true;
    config = {
      # Must live under `niri`, not `common`: xdg-desktop-portal uses
      # niri-portals.conf and ignores portals.conf under XDG_CURRENT_DESKTOP=niri.
      niri."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser" "gtk"];
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
    ];
  };

  # List services that you want to enable:
  services = {
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    power-profiles-daemon.enable = true;
    gvfs.enable = true;
  };

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [pkgs.linux-firmware];

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          AlwaysPairable = true;
        };
      };
    };

    cpu.amd.updateMicrocode = true;
  };

  # Maintenance
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  system.stateVersion = "26.11"; # TLDR: Don't touch
}
