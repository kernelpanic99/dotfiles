{...}: {
  keymaps = [
    # Files / UI
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options.silent = true;
      mode = "n";
    }
    {
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options.silent = true;
      mode = "n";
    }

    # Buffer
    {
      key = "<S-h>";
      action = "<cmd>BufferPrevious<CR>";
    }
    {
      key = "<S-l>";
      action = "<cmd>BufferNext<CR>";
    }
    {
      key = "<leader>bd";
      action = "<cmd>BufferClose<CR>";
    }
    {
      key = "<leader>bo";
      action = "<cmd>BufferCloseAllButCurrentOrPinned<CR>";
    }

    # Search
    {
      key = "<leader><leader>";
      action = "<cmd>lua require('snacks').picker.files()<CR>";
    }
    {
      key = "<leader>sg";
      action = "<cmd>lua require('snacks').picker.grep()<CR>";
    }
    {
      key = "<leader>sw";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
    }
    {
      key = "<leader>sv";
      action = "<cmd>lua require('snacks').picker.grep_word()<CR>";
      mode = "v";
    }
    {
      key = "<leader>sr";
      action = "<cmd>lua require('snacks').picker.recent()<CR>";
    }

    # Git
    {
      key = "<leader>gg";
      action = "<cmd>lua require('snacks').lazygit()<CR>";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk()<CR>";
    }
    {
      key = "<leader>gs";
      action = "<cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      mode = "v";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
    }
    {
      key = "<leader>gr";
      action = "<cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })<CR>";
      mode = "v";
    }
    {
      key = "<leader>gv";
      action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
    }
    {
      key = "<leader>gb";
      action = "<cmd>lua require('gitsigns').blame_line({ full = true })<CR>";
    }

    # Utility
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = "n";
    }
    {
      key = ">";
      action = ">gv";
      mode = "v";
    }
    {
      key = "<";
      action = "<gv";
      mode = "v";
    }

    # Clipboard
    {
      key = "<leader>y";
      action = ''"+y'';
      mode = ["n" "v"];
    }
    {
      key = "<leader>Y";
      action = ''"+Y'';
      mode = "n";
    }
    {
      key = "<leader>p";
      action = ''"+p'';
      mode = ["n" "v"];
    }
    {
      key = "<leader>P";
      action = ''"+P'';
      mode = ["n" "v"];
    }
  ];
}
