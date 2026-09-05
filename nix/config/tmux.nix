{pkgs}: let
  # Is an editor running anywhere under the tmux pane whose pid is $1?
  #
  # `devenv shell` and other wrappers run their child shell on a pty of their
  # own, leaving the pane's own tty carrying just the wrapper. Walking the
  # pane's process tree finds the editor wherever it ended up.
  isVim = pkgs.writeShellScript "tmux-is-vim" ''
    ${pkgs.procps}/bin/ps -eo pid=,ppid=,state=,comm= | ${pkgs.gawk}/bin/awk -v root="$1" '
      {
        pid[NR] = $1
        ppid[NR] = $2
        state[NR] = $3
        comm[NR] = $4
        n = NR
      }

      END {
        desc[root] = 1

        changed = 1
        while (changed) {
          changed = 0
          for (i = 1; i <= n; i++) {
            if (!desc[pid[i]] && desc[ppid[i]]) {
              desc[pid[i]] = 1
              changed = 1
            }
          }
        }

        for (i = 1; i <= n; i++) {
          if (desc[pid[i]] && state[i] !~ /[TXZ]/ && tolower(comm[i]) ~ /^g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?$/) {
            exit 0
          }
        }

        exit 1
      }
    '
  '';
in {
  enable = true;
  prefix = "C-s";
  mouse = true;
  escapeTime = 10;
  historyLimit = 50000;
  terminal = "tmux-256color";
  keyMode = "vi";
  focusEvents = true;

  plugins = with pkgs.tmuxPlugins; [
    {
      plugin = vim-tmux-navigator;
      extraConfig = ''
        set -g @vim_navigator_check "${isVim} '#{pane_pid}'"
      '';
    }
    yank
    {
      plugin = catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavor 'mocha'
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_status_modules_right "session uptime"
        set -g @catppuccin_status_left_separator "█"
        set -g @catppuccin_status_right_separator "█"
      '';
    }
  ];

  extraConfig = ''
    bind-key K kill-session

    set -g status on
    set -g status-position top
    set -g renumber-windows on

    bind -r h resize-pane -L 5
    bind -r j resize-pane -D 5
    bind -r k resize-pane -U 5
    bind -r l resize-pane -R 5

    bind -r n next-window
    bind -r p previous-window

    set -sg terminal-overrides ",*:RGB"
  '';
}
