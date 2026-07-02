{pkgs}: {
  enable = true;
  enableFishIntegration = true;

  plugins = with pkgs.yaziPlugins; {
    inherit smart-enter smart-paste gvfs ouch;
  };

  settings = {
    opener = {
      mpv = [{run = ''mpv --force-window "$@"''; orphan = true; for = "unix";}];
      mdfried = [{run = "mdfried %s"; block = true; for = "unix"; desc = "View markdown with mdfried";}];
      nvim = [{run = "nvim %s"; block = true; for = "unix"; desc = "Edit with neovim";}];
      xournalpp = [{run = "xournalpp %s"; block = false; orphan = true; for = "unix"; desc = "Open with Xournal++";}];
      zathura = [{run = "zathura %s"; block = false; orphan = true; for = "unix"; desc = "Open with Zathura";}];
    };
    open.prepend_rules = [
      {url = "*.md"; use = ["nvim" "mdfried"];}
      {mime = "video/*"; use = ["mpv" "reveal"];}
      {mime = "application/{,g}zip"; use = ["extract"];}
      {mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}"; use = ["extract"];}
      {url = "*.pdf"; use = ["xournalpp" "zathura"];}
    ];
    plugin.prepend_previewers = [
      {mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}"; run = "ouch";}
    ];
  };

  keymap = {
    input.prepend_keymap = [
      {on = "<Esc>"; run = "close"; desc = "Cancel input";}
    ];
    mgr.prepend_keymap = [
      {on = "p"; run = "plugin smart-paste"; desc = "Paste into the hovered directory or CWD";}
      {on = ["t" "h"]; run = "tab_create ~/"; desc = "Create new tab at home";}
      {on = "y"; run = [''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list'' "yank"];}
      {on = ["M" "m"]; run = "plugin gvfs -- select-then-mount --jump"; desc = "Select device to mount and jump to its mount point";}
      {on = ["M" "u"]; run = "plugin gvfs -- select-then-unmount"; desc = "Select device then unmount";}
      {on = ["M" "a"]; run = "plugin gvfs -- add-mount"; desc = "Add a GVFS mount URI";}
      {on = ["M" "e"]; run = "plugin gvfs -- edit-mount"; desc = "Edit a GVFS mount URI";}
      {on = ["M" "r"]; run = "plugin gvfs -- remove-mount"; desc = "Remove a GVFS mount URI";}
      {on = ["g" "m"]; run = "plugin gvfs -- jump-to-device"; desc = "Jump to mounted device";}
      {on = "<C-n>"; run = "shell -- ripdrag -xa %s";}
    ];
  };

  initLua = ''
    require('gvfs'):setup({})
  '';
}
