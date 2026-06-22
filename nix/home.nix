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
  };

  programs = {
    eilmeldung = import ./config/eilmeldung.nix;
    foot = import ./config/foot.nix;
    noctalia = {
      enable = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;

      extraPackages = with pkgs; [
        # LSP servers
        vtsls
        biome
        vscode-langservers-extracted # cssls, htmlls, jsonls, eslintls
        tailwindcss-language-server
        astro-language-server
        nodePackages.svelte-language-server
        rust-analyzer
        gopls
        lexical
        marksman
        yaml-language-server
        terraform-ls
        lua-language-server
        dockerfile-language-server-nodejs
        nodePackages.bash-language-server
        fish-lsp
        pyright
        zls
        docker-compose-language-service
        # Formatters
        stylua
        nodePackages.prettier
        black
        mdformat
        taplo
      ];

      extraLuaConfig =
        ''
          vim.g.lazy_path = "${pkgs.vimPlugins.lazy-nvim}"
          vim.g.treesitter_path = "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}"
          vim.g.blink_cmp_path = "${pkgs.vimPlugins.blink-cmp}"
        ''
        + builtins.readFile ./config/nvim/init.lua;
    };
  };
}
