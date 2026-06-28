let
  esc = builtins.fromJSON "\"\\u001b\"";
  makeDashes = n: builtins.concatStringsSep "" (builtins.genList (_: "─") n);
  innerWidth = 60; # fixed: all sections produce the same total line width
  logoWidth = 40; # inferred imperically

  section = text: color: let
    textLen = builtins.stringLength text;
    leftDashes = (innerWidth - textLen - 2) / 2;
    rightDashes = innerWidth - textLen - 2 - leftDashes;
  in {
    type = "custom";
    format = "${esc}[${color}m╭${makeDashes leftDashes} ${text} ${makeDashes rightDashes}╮${esc}[0m";
  };

  endsection = color: {
    type = "custom";
    format = "${esc}[${color}m╰${makeDashes innerWidth}╯${esc}[0m";
  };
in {
  enable = true;
  settings = {
    logo = {
      type = "builtin";
      source = "windows";
    };

    display = {
      separator = "  ";
    };

    modules = [
      {
        type = "title";
        key = "Host";
        keyColor = "blue";
      }

      "break"

      (section "System" "35")
      {
        type = "os";
        key = "├─󱄅";
        keyColor = "magenta";
      }
      {
        type = "kernel";
        key = "├─";
        format = "{1} {2}";
        keyColor = "magenta";
      }
      {
        type = "packages";
        key = "├─󰮯";
        keyColor = "magenta";
      }
      {
        type = "wm";
        key = "├─󰧨";
        keyColor = "magenta";
      }
      {
        type = "theme";
        key = "├─󰉼";
        keyColor = "magenta";
      }
      {
        type = "uptime";
        key = "├─󰅐";
        keyColor = "magenta";
      }
      (endsection "35")

      "break"

      (section "Shell" "32")
      {
        type = "terminal";
        key = "├─";
        keyColor = "green";
      }
      {
        type = "terminalfont";
        key = "├─";
        keyColor = "green";
      }
      {
        type = "shell";
        key = "├─";
        keyColor = "green";
      }
      (endsection "32")

      "break"

      (section "Hardware" "33")
      {
        type = "host";
        key = "├─";
        keyColor = "yellow";
      }
      {
        type = "cpu";
        key = "├─󰍛";
        keyColor = "yellow";
      }
      {
        type = "gpu";
        key = "├─󰘚";
        keyColor = "yellow";
        hideType = "integrated";
      }
      {
        type = "display";
        key = "├─󰍹";
        keyColor = "yellow";
        compactType = "original-with-refresh-rate";
      }
      {
        type = "memory";
        key = "├─󰑭";
        keyColor = "yellow";
      }
      {
        type = "disk";
        key = "├─";
        keyColor = "yellow";
      }
      (endsection "33")

      "break"
      {
        type = "custom";
        format = "${esc}[1m${esc}[31m  ${esc}[1m${esc}[32m  ${esc}[1m${esc}[33m  ${esc}[1m${esc}[34m  ${esc}[1m${esc}[35m  ${esc}[1m${esc}[36m  ${esc}[1m${esc}[37m  ${esc}[1m${esc}[30m       ${esc}[1m${esc}[91m  ${esc}[1m${esc}[92m  ${esc}[1m${esc}[93m  ${esc}[1m${esc}[94m  ${esc}[1m${esc}[95m  ${esc}[1m${esc}[96m  ${esc}[1m${esc}[97m  ${esc}[1m${esc}[90m${esc}[0m";
      }
    ];
  };
}
