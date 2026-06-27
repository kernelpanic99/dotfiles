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
  };
}
