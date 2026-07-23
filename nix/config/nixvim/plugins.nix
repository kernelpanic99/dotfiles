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
    ruff
    mdformat
    gofumpt
    alejandra
    typstyle

    # Rust editor tooling only; suffixed on PATH, so a project's
    # devenv toolchain (earlier on PATH) takes precedence when present.
    rustc
    cargo
    rustfmt
  ];

  # Give rust-analyzer a std source for untooled projects, but don't
  # clobber a value already provided by a project shell.
  extraConfigLua = ''
    vim.env.RUST_SRC_PATH = vim.env.RUST_SRC_PATH or "${pkgs.rustPlatform.rustLibSrc}"
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

    lualine = {
      enable = true;
      settings.options.globalstatus = true;
    };
    barbar.enable = true;
    tmux-navigator.enable = true;

    neo-tree = {
      enable = true;
      settings = {
        filesystem = {
          window = {
            mappings = {
              O = "system_open";
            };
          };
          follow_current_file = {
            enabled = true;
            leave_dirs_open = false;
          };
        };

        commands = {
          system_open.__raw = ''
            function(state)
                local node = state.tree:get_node()
                local path = node:get_id()

                vim.fn.jobstart({ "xdg-open", path }, { detach = true })
            end
          '';
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
          "__unkeyed-1" = "<leader>a";
          group = "[A]I";
        }
      ];
    };

    mini-pairs.enable = true;
    mini-ai.enable = true;

    render-markdown.enable = true;

    typst-preview = {
      enable = true;
      settings = {
        open_cmd = "brave --app=%s --user-data-dir=/tmp/typst-preview --class=typst-preview";
      };
    };

    # AI CLI integration. NES (Next Edit Suggestions) is disabled since it
    # requires the Copilot language server; only the terminal CLI is used.
    sidekick = {
      enable = true;
      settings = {
        nes.enabled = false;
        cli = {
          watch = true;
          tools.crush = {};
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
        typescript
        javascript
        tsx
        rust
        go
        dockerfile
        python
        astro
        terraform
        latex
        typst
      ];
    };

    conform-nvim = {
      enable = true;
      settings = {
        lsp_format = "fallback";
        formatters_by_ft = {
          lua = ["stylua"];
          python = ["ruff_organize_imports" "ruff_format"];
          markdown = ["mdformat"];
          nix = ["alejandra"];
          javascript = ["biome"];
          javascriptreact = ["biome"];
          typescript = ["biome"];
          typescriptreact = ["biome"];
          json = ["biome"];
          jsonc = ["biome"];
          css = ["prettier"];
          scss = ["prettier"];
          html = ["prettier"];
          svelte = ["prettier"];
          astro = ["prettier"];
          jsx = ["prettier"];
          tsx = ["prettier"];
          yaml = ["prettier"];
          rust = ["rustfmt"];
          go = ["gofumpt"];
          typst = ["typstyle"];
        };
      };
    };
  };
}
