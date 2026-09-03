local map = vim.keymap.set

-- Utility
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("v", ">", ">gv", { desc = "Indent" })
map("v", "<", "<gv", { desc = "Outdent" })

-- Clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste before from clipboard" })
