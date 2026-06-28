{pkgs}: {
  enable = true;
  prefix = "C-s";
  mouse = true;
  escapeTime = 10;
  historyLimit = 50000;
  terminal = "tmux-256color";
  keyMode = "vi";
  focusEvents = true;

  plugins = with pkgs.tmuxPlugins; [
    vim-tmux-navigator
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
