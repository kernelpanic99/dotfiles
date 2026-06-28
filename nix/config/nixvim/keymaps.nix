{...}: {
  keymaps = [
    # Files / UI
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options = {
        silent = true;
        desc = "Explorer (Neo-tree)";
      };
      mode = "n";
    }
    {
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options = {
        silent = true;
        desc = "Format buffer";
      };
      mode = "n";
    }

    # Buffer
    {
      key = "<S-h>";
      action = "<cmd>BufferPrevious<CR>";
      options.desc = "Previous buffer";
    }
    {
      key = "<S-l>";
      action = "<cmd>BufferNext<CR>";
      options.desc = "Next buffer";
    }
    {
      key = "<leader>bd";
      action = "<cmd>BufferClose<CR>";
      options.desc = "Close buffer";
    }
    {
      key = "<leader>bo";
      action = "<cmd>BufferCloseAllButCurrentOrPinned<CR>";
      options.desc = "Close other buffers";
    }

    # Search
    {
      key = "<leader><leader>";
      action = "<cmd>lua require('snacks').picker.files()<CR>";
      options.desc = "Find files";
    }
    {
      key = "<leader>sg";
      action = "<cmd>lua require('snacks').picker.grep()<CR>";
      options.desc = "Grep";
    }
    {
      key = "<leader>sw";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
      options.desc = "Grep word under cursor";
    }
    {
      key = "<leader>sv";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
      options.desc = "Grep selection";
      mode = "v";
    }
    {
      key = "<leader>sr";
      action = "<cmd>lua require('snacks').picker.recent()<CR>";
      options.desc = "Recent files";
    }

    # Git
    {
      key = "<leader>gg";
      action = "<cmd>lua require('snacks').lazygit()<CR>";
      options.desc = "Lazygit";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk()<CR>";
      options.desc = "Stage hunk";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      options.desc = "Stage hunk";
      mode = "v";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
      options.desc = "Reset hunk";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      options.desc = "Reset hunk";
      mode = "v";
    }
    {
      key = "<leader>gv";
      action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
      options.desc = "Preview hunk";
    }
    {
      key = "<leader>gb";
      action = "<cmd>lua require('gitsigns').blame_line({ full = true })<CR>";
      options.desc = "Blame line";
    }

    # Utility
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlight";
      mode = "n";
    }
    {
      key = ">";
      action = ">gv";
      options.desc = "Indent";
      mode = "v";
    }
    {
      key = "<";
      action = "<gv";
      options.desc = "Outdent";
      mode = "v";
    }

    # Clipboard
    {
      key = "<leader>y";
      action = ''"+y'';
      options.desc = "Yank to clipboard";
      mode = ["n" "v"];
    }
    {
      key = "<leader>Y";
      action = ''"+Y'';
      options.desc = "Yank line to clipboard";
      mode = "n";
    }
    {
      key = "<leader>p";
      action = ''"+p'';
      options.desc = "Paste from clipboard";
      mode = ["n" "v"];
    }
    {
      key = "<leader>P";
      action = ''"+P'';
      options.desc = "Paste before from clipboard";
      mode = ["n" "v"];
    }
  ];
}
