return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    notifier = { enabled = true },
    lazygit = { enabled = true },
    indent = { enabled = true },
    bigfile = { enabled = true },
    picker = {
      enabled = true,
      win = { list = { wo = { wrap = true } } },
    },
    statuscolumn = { enabled = true },
    input = { enabled = true },
    terminal = {},
  },
  keys = {
    { "<leader><leader>", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep word under cursor", mode = { "n", "x" } },
    { "<leader>sr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
}
