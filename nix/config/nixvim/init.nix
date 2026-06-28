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
    showmode = false;
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

  autoCmd = [
    {
      event = ["TextYankPost"];
      callback.__raw = ''
        function()
          vim.highlight.on_yank({ timeout = 200 })
        end
      '';
    }
  ];

  keymaps = [
    # Files / UI
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options.silent = true;
      mode = "n";
    }
    {
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options.silent = true;
      mode = "n";
    }

    # Buffer
    {
      key = "<S-h>";
      action = "<cmd>BufferPrevious<CR>";
    }
    {
      key = "<S-l>";
      action = "<cmd>BufferNext<CR>";
    }
    {
      key = "<leader>bd";
      action = "<cmd>BufferClose<CR>";
    }
    {
      key = "<leader>bo";
      action = "<cmd>BufferCloseAllButCurrentOrPinned<CR>";
    }

    # Search (snacks.picker)
    {
      key = "<leader><leader>";
      action = "<cmd>lua require('snacks').picker.files()<CR>";
    }
    {
      key = "<leader>sg";
      action = "<cmd>lua require('snacks').picker.grep()<CR>";
    }
    {
      key = "<leader>sw";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
    }
    {
      key = "<leader>sv";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
      mode = "v";
    }
    {
      key = "<leader>sr";
      action = "<cmd>lua require('snacks').picker.recent()<CR>";
    }

    # Git
    {
      key = "<leader>gg";
      action = "<cmd>lua require('snacks').lazygit()<CR>";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk()<CR>";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      mode = "v";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      mode = "v";
    }
    {
      key = "<leader>gv";
      action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
    }
    {
      key = "<leader>gb";
      action = "<cmd>lua require('gitsigns').blame_line({ full = true })<CR>";
    }

    # Utility
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = "n";
    }
    {
      key = ">";
      action = ">gv";
      mode = "v";
    }
    {
      key = "<";
      action = "<gv";
      mode = "v";
    }

    # Clipboard
    {
      key = "<leader>y";
      action = ''"+y'';
      mode = ["n" "v"];
    }
    {
      key = "<leader>Y";
      action = ''"+Y'';
      mode = "n";
    }
    {
      key = "<leader>p";
      action = ''"+p'';
      mode = ["n" "v"];
    }
    {
      key = "<leader>P";
      action = ''"+P'';
      mode = ["n" "v"];
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    nvim-web-devicons
  ];

  lsp = {
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gr";
        lspBufAction = "references";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
      }
      {
        key = "K";
        lspBufAction = "hover";
      }
      {
        key = "<leader>lr";
        lspBufAction = "rename";
      }
      {
        key = "<leader>ls";
        action = "<cmd>lua require('snacks').picker.lsp_symbols()<CR>";
      }
      {
        key = "<leader>lx";
        action = "<cmd>lua require('snacks').picker.diagnostics()<CR>";
      }
      {
        key = "<leader>k";
        action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
      }
      {
        key = "<leader>j";
        action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
      }
    ];
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

  extraConfigLua = ''
    vim.diagnostic.config({
      virtual_text = { prefix = "● ", spacing = 4 },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = "always" },
    })
  '';

  plugins = {
    snacks = {
      enable = true;
      settings = {
        notifier = {enabled = true;};
        lazygit = {enabled = true;};
        indent = {enabled = true;};
        bigfile = {enabled = true;};
        picker = {enabled = true;};
        statuscolumn = {enabled = true;};
        input = {enabled = true;};
        terminal = {enabled = true;};
      };
    };
    lualine = {enable = true;};
    barbar = {enable = true;};
    tmux-navigator.enable = true;
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

    gitsigns.enable = true;

    blink-cmp = {
      enable = true;
      settings = {
        sources.default = ["lsp" "path" "snippets" "buffer"];
        completion.documentation = {
          auto_show = false;
          auto_show_delay_ms = 500;
        };
      };
    };

    which-key = {
      enable = true;
      settings.spec = [
        {
          "__unkeyed-1" = "<leader>b";
          group = "[B]uffer";
        }
        {
          "__unkeyed-1" = "<leader>c";
          group = "[C]ode";
        }
        {
          "__unkeyed-1" = "<leader>g";
          group = "[G]it";
        }
        {
          "__unkeyed-1" = "<leader>l";
          group = "[L]SP";
        }
        {
          "__unkeyed-1" = "<leader>s";
          group = "[S]earch";
        }
        {
          "__unkeyed-1" = "<leader>t";
          group = "[T]oggle/Tools";
        }
      ];
    };

    mini-pairs.enable = true;
    mini-ai.enable = true;

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
      settings = {
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };
        formatters_by_ft = {
          lua = ["stylua"];
          python = ["black"];
          markdown = ["mdformat"];
          nix = ["alejandra"];
          javascript = ["biome"];
          javascriptreact = ["biome"];
          typescript = ["biome"];
          typescriptreact = ["biome"];
          json = ["biome"];
          jsonc = ["biome"];
          css = ["prettier"];
          html = ["prettier"];
        };
      };
    };
  };
}
