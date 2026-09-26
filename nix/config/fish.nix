{pkgs}: {
  enable = true;

  plugins = with pkgs.fishPlugins; [
    {
      name = "done";
      src = done.src;
    }
    {
      name = "hydro";
      src = hydro.src;
    }
  ];

  # Opens the editor in a pane started by `t` once the project environment is
  # loaded. A devenv hook spawns its own shell here, which inherits _T_EDITOR
  # and opens the editor; the parent shell drops the marker once that returns.
  interactiveShellInit = ''
    function _t_editor --on-event fish_prompt
        if not set -q _T_EDITOR
            return
        end

        if functions -q __direnv_export_eval
            __direnv_export_eval
        end

        if test -z "$DEVENV_ROOT"; and devenv hook-should-activate &>/dev/null
            if test "$_DEVENV_HOOK_ACTIVATED" = "$PWD"
                set -e _T_EDITOR
            end

            return
        end

        set -e _T_EDITOR
        nvim
    end
  '';

  functions = {
    t = ''
      if set -q argv[1]
          set dir (realpath $argv[1])
      else
          set dir $PWD
      end
      set session (string replace -ra '[^a-zA-Z0-9_-]' '_' (basename $dir))

      if not tmux has-session -t $session 2>/dev/null
          tmux new-session -d -s $session -c $dir -e _T_EDITOR=1
          tmux set-environment -t $session -u _T_EDITOR
          tmux split-window -t "$session:0" -v -c $dir
          tmux select-pane -t "$session:0.0"
      end

      if set -q TMUX
          tmux switch-client -t $session
      else
          tmux attach-session -t $session
      end
    '';
  };

  shellAliases = {
    tw = "timew";
    tws = "timew start";
    twp = "timew stop";
    twi = "timew summary :ids";
    twc = "timew continue";
    twd = "timew delete";

    nt = "t ~/Documents/Notes";

    nxr = "sudo nixos-rebuild switch --flake ~/dotfiles#(hostname)";

    ytaud = "yt-dlp --extract-audio --audio-format m4a --audio-quality best --embed-metadata";
    ytdl = "yt-dlp -f 'bestvideo[height>=720]+bestaudio/best[height>=720]' -S '+size,+br,vcodec:av1:vp9:h265:h264'";
  };
}
