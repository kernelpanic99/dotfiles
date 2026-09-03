return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { flavour = "mocha" },
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },
  {
      "e-ink-colorscheme/e-ink.nvim",
      config = function ()
          require("e-ink").setup()
          vim.cmd.colorscheme("e-ink")

          vim.opt.background = "light"
      end,
  }
}
