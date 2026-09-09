return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.diagnostic.config({
        virtual_text = { prefix = "● ", spacing = 4 },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "References")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>la", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>ls", function() Snacks.picker.lsp_symbols() end, "Document symbols")
          map("<leader>lx", function() Snacks.picker.diagnostics() end, "Diagnostics")
          map("<leader>k", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("<leader>j", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
        end,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        vtsls = {},
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } } } },
        },
        basedpyright = {},
        bashls = {},
        yamlls = {},
        jsonls = {},
        marksman = {},
        taplo = {},
        rust_analyzer = {},
      }

      for name, cfg in pairs(servers) do
        cfg.capabilities = capabilities
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end
    end,
  },
}
