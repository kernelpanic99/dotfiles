vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- General
opt.undofile = true
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 300
opt.confirm = true

-- Indentation
opt.fillchars = { eob = " " }
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.shiftwidth = 4
opt.expandtab = true

-- UI
opt.mouse = "a"
opt.number = true
opt.showmode = false
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.cursorline = true
opt.scrolloff = 10
opt.termguicolors = true

-- Search and replace
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Folds (treesitter-driven)
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Termux clipboard bridge
if vim.fn.executable("termux-clipboard-set") == 1 then
  vim.g.clipboard = {
    name = "termux",
    copy = { ["+"] = "termux-clipboard-set", ["*"] = "termux-clipboard-set" },
    paste = { ["+"] = "termux-clipboard-get", ["*"] = "termux-clipboard-get" },
    cache_enabled = 0,
  }
end

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})
