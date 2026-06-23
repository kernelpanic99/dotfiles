{pkgs}: {
  enable = true;

  plugins = with pkgs.fishPlugins; [
    { name = "done"; src = done.src; }
    { name = "hydro"; src = hydro.src; }
  ];

  shellAbbrs = {
    xi = "sudo pacman -Syu";
    xr = "sudo pacman -Rsn";
    xs = "sudo pacman -Ss";
  };

  functions = {
    t = ''
      if set -q argv[1]
          set dir (realpath $argv[1])
      else
          set dir $PWD
      end
      set session (string replace -ra '[^a-zA-Z0-9_-]' '_' (basename $dir))

      if not tmux has-session -t $session 2>/dev/null
          tmux new-session -d -s $session -c $dir
          tmux send-keys -t "$session:0.0" nvim Enter
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

    ytaud = "yt-dlp --extract-audio --audio-format m4a --audio-quality best --embed-metadata";
    ytdl = "yt-dlp -f 'bestvideo[height>=720]+bestaudio/best[height>=720]' -S '+size,+br,vcodec:av1:vp9:h265:h264'";
  };
}
