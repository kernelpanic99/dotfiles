{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "kp";
    homeDirectory = "/home/kp";
    stateVersion = "26.11"; # TLDR: Don't touch

    packages = with pkgs; [
      # Base tools
      ripgrep
      fd
      jq
      yazi
      fzf
      lazygit
      btop
      ouch
      restic
      docker-compose
      fastfetch
      niri
      brave
    ];
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./config/niri/config.kdl;
    "xdg-desktop-portal-termfilechooser/config".source = ./config/termfilechooser.conf;
    "nvim/init.lua".source = ./config/nvim/init.lua;
  };

  programs = {
    eilmeldung = import ./config/eilmeldung.nix;
    foot = import ./config/foot.nix;
    noctalia = {
      enable = true;
    };
  };
}
