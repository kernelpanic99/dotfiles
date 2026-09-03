return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    nes = { enabled = false },
    cli = {
      watch = true,
      tools = { claude = {} },
    },
  },
  keys = {
    { "<leader>ac", function() require("sidekick.cli").toggle({ name = "claude" }) end, desc = "Sidekick toggle claude" },
    {
      "<c-.>",
      function() require("sidekick.cli").focus() end,
      mode = { "n", "t", "i", "x" },
      desc = "Sidekick focus",
    },
    { "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = { "n", "x" }, desc = "Sidekick send this" },
    { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Sidekick send file" },
    { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = "x", desc = "Sidekick send selection" },
    { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Sidekick select prompt" },
    { "<leader>as", function() require("sidekick.cli").select() end, desc = "Sidekick select CLI" },
    { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Sidekick detach CLI" },
  },
}
