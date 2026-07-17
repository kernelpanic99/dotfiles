{...}: {
  extraConfigLua = ''
    vim.diagnostic.config({
      virtual_text = { prefix = "● ", spacing = 4 },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })
  '';

  lsp = {
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
        options.desc = "Go to definition";
      }
      {
        key = "gr";
        lspBufAction = "references";
        options.desc = "References";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
        options.desc = "Go to implementation";
      }
      {
        key = "K";
        lspBufAction = "hover";
        options.desc = "Hover";
      }
      {
        key = "<leader>lr";
        lspBufAction = "rename";
        options.desc = "Rename symbol";
      }
      {
        key = "<leader>la";
        lspBufAction = "code_action";
        mode = ["n" "v"];
        options.desc = "Code action";
      }
      {
        key = "<leader>ls";
        action = "<cmd>lua require('snacks').picker.lsp_symbols()<CR>";
        options.desc = "Document symbols";
      }
      {
        key = "<leader>lx";
        action = "<cmd>lua require('snacks').picker.diagnostics()<CR>";
        options.desc = "Diagnostics";
      }
      {
        key = "<leader>k";
        action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
        options.desc = "Previous diagnostic";
      }
      {
        key = "<leader>j";
        action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
        options.desc = "Next diagnostic";
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
      tinymist.enable = true;
    };
  };
}
