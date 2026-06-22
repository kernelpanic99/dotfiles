{pkgs}: {
  enable = true;

  plugins = with pkgs.fishPlugins; [
    done
    hydro
  ];

  shellAbbrs = {
    xi = "sudo pacman -Syu";
    xr = "sudo pacman -Rsn";
    xs = "sudo pacman -Ss";
  };

  shellAliases = {
    t = "dmux";
    tb = "dmux -P backend";
    ts = "dmux -P stencil";

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
