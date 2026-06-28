{...}: {
  opts = {
    # General
    undofile = true;
    updatetime = 250;
    timeout = true;
    timeoutlen = 300;
    confirm = true;

    # Identation
    fillchars = {eob = " ";};
    autoindent = true;
    smartindent = true;
    breakindent = true;
    shiftwidth = 4;
    expandtab = true;

    # UI
    mouse = "a";
    number = true;
    showmode = false;
    signcolumn = "yes";
    splitright = true;
    splitbelow = true;
    list = true;
    listchars = {
      tab = "» ";
      trail = "·";
      nbsp = "␣";
    };
    cursorline = true;
    scrolloff = 10;
    termguicolors = true;

    # Search and replace
    ignorecase = true;
    smartcase = true;
    inccommand = "split";

    # Folds
    foldmethod = "syntax";
    foldlevelstart = 99;
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";

    have_nerd_font = true;
    loaded_netrw = false;
    loaded_netrwPlugin = false;
  };

  autoCmd = [
    {
      event = ["TextYankPost"];
      callback.__raw = ''
        function()
          vim.highlight.on_yank({ timeout = 200 })
        end
      '';
    }
  ];
}
