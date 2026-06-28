{
  pkgs,
  config,
  ...
}: {
  enable = true;
  nixpkgs.config.allowUnfree = true;
  colorschemes.catppuccin.enable = true;

  opts = {
    # General
    undofile = true;
    updatetime = 250;
    timeout = true;
    timeoutlen = 300;
    confirm = true;

    # Identation
    fillchars = {eob = " ";};
    autoindent = true;
    smartindent = true;
    breakindent = true;
    shiftwidth = 4;
    expandtab = true;

    # UI
    mouse = "a";
    number = true;
    showmode = true;
    signcolumn = "yes";
    splitright = true;
    splitbelow = true;
    list = true;
    listchars = {
      tab = "» ";
      trail = "·";
      nbsp = "␣";
    };
    cursorline = true;
    scrolloff = 10;
    termguicolors = true;

    # Search and replace
    ignorecase = true;
    smartcase = true;
    inccommand = "split";

    # Folds
    foldmethod = "syntax";
    foldlevelstart = 99;
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";

    have_nerd_font = true;
    loaded_netrw = false;
    loaded_netrwPlugin = false;
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options.silent = true;
      mode = "n";
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    nvim-web-devicons
  ];

  lsp = {
    servers = {
      # Web
      vtsls.enable = true;
      biome.enable = true;
      nixd.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      tailwindcss.enable = true;
      astro.enable = true;

      # Languages
      rust_analyzer.enable = true;
      gopls.enable = true;
      lua_ls.enable = true;
      pyright.enable = true;

      # Configs
      yamlls.enable = true;
      tombi.enable = true;
      docker_language_server.enable = true;
      docker_compose_language_service.enable = true;
      terraformls.enable = true;

      #Other
      fish_lsp.enable = true;
      bashls.enable = true;
      marksman.enable = true;
    };
  };

  extraPackages = with pkgs; [
    stylua
    prettier
    biome
    black
    mdformat
  ];

  plugins = {
    lualine = {enable = true;};
    barbar = {enable = true;};
    neo-tree = {
      enable = true;
      settings = {
        filesystem = {
          follow_current_file = {
            enabled = true;
            leave_dirs_open = false;
          };
        };
      };
    };

    lspconfig.enable = true;

    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;

      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        bash
        fish
        json
        lua
        markdown
        nix
        regex
        toml
        yaml
        ini
        vim
        vimdoc
        xml
        yaml
        typescript
        tsx
        rust
        go
        dockerfile
        python
        astro
        terraform
      ];
    };

    conform-nvim = {
      enable = true;
    };
  };
}
