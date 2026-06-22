# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./disko.nix];

  nix.settings = {
    experimental-features = ["flakes" "nix-command"];

    extra-substituters = ["https://noctalia.cachix.org"];
    extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
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
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
      kernelModules = ["kvm-amd" "amdgpu"];
    };
  };

  networking = {
    hostName = "nixos";
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
    wget
    git
    tmux
    man-pages
    man-pages-posix
    lshw
    cliphist
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
    fish.enable = true;
    xwayland.enable = true;
  };

  virtualisation = {
    docker.enable = true;
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [
          "termfilechooser"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [
          "gnome"
        ];
      };
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
    power-profiles-daemon.enable = true;
    xserver.videoDrivers = [
      "nvidia"
      "amdgpu"
    ];

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.sway}/bin/niri-session";
          user = "kp";
        };

        default_session = initial_session;
      };
    };
  };

  security.pam.services.login.enableGnomeKeyring = true;

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [pkgs.linux-firmware];

    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.finegrained = true;
      open = true;
      nvidiaSettings = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        amdgpuBusId = "PCI:5:00:0";
        nvidiaBusId = "PCI:1:00:0";
      };
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          FastConnectable = false;
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
