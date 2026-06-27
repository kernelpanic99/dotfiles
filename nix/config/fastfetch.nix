let
  esc = builtins.fromJSON "\"\\u001b\"";
  makeDashes = n: builtins.concatStringsSep "" (builtins.genList (_: "─") n);
  innerWidth = 60; # fixed: all sections produce the same total line width
  logoWidth = 40; # inferred imperically
  rightCol = logoWidth + 2 + innerWidth; # Column where │ lands

  # Draws │ at rightCol on the line above by using cursor-up (\e[1A),
  # then returns — takes no extra visible line in the output.
  borderLine = color: {
    type = "custom";
    format = "${esc}[1A${esc}[${toString rightCol}G${esc}[${color}m│${esc}[0m";
  };

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
        key = "System";
        keyColor = "blue";
      }

      "break"

      (section "System" "35")
      {
        type = "os";
        key = "├─󱄅";
        keyColor = "magenta";
      }
      (borderLine "35")
      {
        type = "kernel";
        key = "├─";
        format = "{1} {2}";
        keyColor = "magenta";
      }
      (borderLine "35")
      {
        type = "packages";
        key = "├─󰮯";
        keyColor = "magenta";
      }
      (borderLine "35")
      {
        type = "wm";
        key = "├─󰧨";
        keyColor = "magenta";
      }
      (borderLine "35")
      {
        type = "theme";
        key = "├─󰉼";
        keyColor = "magenta";
      }
      (borderLine "35")
      (endsection "35")

      "break"

      (section "Shell" "32")
      {
        type = "terminal";
        key = "├─";
        keyColor = "green";
      }
      (borderLine "32")
      {
        type = "terminalfont";
        key = "├─";
        keyColor = "green";
      }
      (borderLine "32")
      {
        type = "shell";
        key = "├─";
        keyColor = "green";
      }
      (borderLine "32")
      (endsection "32")

      "break"

      (section "Hardware" "33")
      {
        type = "host";
        key = "├─";
        keyColor = "yellow";
      }
      (borderLine "33")
      {
        type = "cpu";
        key = "├─󰍛";
        keyColor = "yellow";
      }
      (borderLine "33")
      {
        type = "gpu";
        key = "├─󰘚";
        keyColor = "yellow";
        hideType = "integrated";
      }
      (borderLine "33")
      {
        type = "display";
        key = "├─󰍹";
        keyColor = "yellow";
        compactType = "original-with-refresh-rate";
      }
      (borderLine "33")
      {
        type = "memory";
        key = "├─󰑭";
        keyColor = "yellow";
      }
      (borderLine "33")
      {
        type = "uptime";
        key = "├─󰅐";
        keyColor = "yellow";
      }
      (borderLine "33")
      (endsection "33")

      "break"
      {
        type = "custom";
        format = "${esc}[1m${esc}[31m  ${esc}[1m${esc}[32m  ${esc}[1m${esc}[33m  ${esc}[1m${esc}[34m  ${esc}[1m${esc}[35m  ${esc}[1m${esc}[36m  ${esc}[1m${esc}[37m  ${esc}[1m${esc}[30m       ${esc}[1m${esc}[91m  ${esc}[1m${esc}[92m  ${esc}[1m${esc}[93m  ${esc}[1m${esc}[94m  ${esc}[1m${esc}[95m  ${esc}[1m${esc}[96m  ${esc}[1m${esc}[97m  ${esc}[1m${esc}[90m${esc}[0m";
      }
    ];
  };
}
