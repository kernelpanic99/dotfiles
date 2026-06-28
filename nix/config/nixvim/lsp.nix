{...}: {
  extraConfigLua = ''
    vim.diagnostic.config({
      virtual_text = { prefix = "● ", spacing = 4 },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = "always" },
    })
  '';

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

      # Other
      fish_lsp.enable = true;
      bashls.enable = true;
      marksman.enable = true;
    };
  };
}
