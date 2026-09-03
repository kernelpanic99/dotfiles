return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
      {
        "<leader>gs",
        function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
        mode = "v",
        desc = "Stage hunk",
      },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
      {
        "<leader>gr",
        function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
        mode = "v",
        desc = "Reset hunk",
      },
      { "<leader>gv", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
      { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line" },
    },
  },

  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      fuzzy = { implementation = "lua" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
    },
  },
}
