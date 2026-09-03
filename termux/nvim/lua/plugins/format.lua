return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>cf", function() require("conform").format() end, desc = "Format buffer" },
  },
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      markdown = { "mdformat" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
  },
}
