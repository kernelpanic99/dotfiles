{
  pkgs,
  config,
  ...
}: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-web-devicons
  ];

  extraPackages = with pkgs; [
    stylua
    prettier
    biome
    black
    mdformat
  ];

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

    lualine.enable = true;
    barbar.enable = true;
    tmux-navigator.enable = true;

    neo-tree = {
      enable = true;
      settings.filesystem.follow_current_file = {
        enabled = true;
        leave_dirs_open = false;
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
