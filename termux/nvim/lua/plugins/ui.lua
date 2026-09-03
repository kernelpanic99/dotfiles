return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = { options = { globalstatus = true } },
  },

  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<S-h>", "<cmd>BufferPrevious<CR>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferNext<CR>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>BufferClose<CR>", desc = "Close buffer" },
      { "<leader>bo", "<cmd>BufferCloseAllButCurrentOrPinned<CR>", desc = "Close other buffers" },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer (Neo-tree)", silent = true },
    },
    opts = {
      window = {
        width = 24,
      },
      filesystem = {
        follow_current_file = { enabled = true, leave_dirs_open = false },
        window = {
          mappings = { O = "system_open" },
        },
        commands = {
          system_open = function(state)
            local node = state.tree:get_node()
            vim.ui.open(node:get_id())
          end,
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Search" },
        { "<leader>a", group = "AI" },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
  { "echasnovski/mini.ai", event = "VeryLazy", opts = {} },

  { "christoomey/vim-tmux-navigator", lazy = false },
}
