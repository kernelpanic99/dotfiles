# Bootstrap (once per machine):
#   mkdir -p ~/.local/share/syncthing
#   chmod 700 ~/.local/share/syncthing
#   copy this host's cert.pem and key.pem into ~/.local/share/syncthing
#   chmod 600 ~/.local/share/syncthing/{cert,key}.pem
# Store the key pairs in KeePassXC. The device IDs below are derived from them.
#
# Switching machines: boot both, run `sync-wait`, and shut down the machine
# being left once it reports everything is up to date.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;

  home = config.home-manager.users.kp.home.homeDirectory;
  secretsDir = "${home}/.local/share/syncthing";

  devices = {
    desktop = "AXQI5SK-X244U77-5WPHEOM-PFDXVE6-EUXBLJC-S7BFCDJ-TML7GMH-ISO5EQT";
    laptop = "M7D5VFY-SYZEBFF-YSGHLIE-R7LTOHC-L3R2QSW-CN2GTGU-WICTXAM-WCTDSQA";
  };

  peers = lib.filterAttrs (name: _: name != hostName) devices;

  # Folder ID -> path relative to home.
  folders = {
    adev = "adev";
    bdev = "bdev";
    documents = "Documents";
    ssh = ".ssh";
    aws = ".aws";
    timewarrior = ".local/share/timewarrior";

    # Claude Code sessions are keyed by absolute cwd, which matches across
    # machines since home and project paths are identical.
    claude-projects = ".claude/projects";
    claude-file-history = ".claude/file-history";
  };

  # Syncthing applies the first matching pattern. (?d) lets it delete ignored
  # files when their parent directory is removed on the other machine.
  ignorePatterns = map (pattern:
    if lib.hasPrefix "!" pattern
    then pattern
    else "(?d)${pattern}") [
    # devenv: service state (databases) syncs, the rest of .devenv is local
    ".devenv/state/tasks.db*"
    ".devenv/state/files.json"
    "!.devenv/state"
    ".devenv/*"

    # Dependencies / build artifacts
    "node_modules"
    "target"
    "dist"
    "build"
    "out"
    ".next"
    ".nuxt"
    ".terraform"
    ".sst"

    # Package manager caches
    ".npm"
    ".yarn/cache"
    ".pnpm-store"

    # Temp / logs
    "*.log"
    "*.tmp"
    ".cache"
    ".tmp"
  ];

  syncWait = pkgs.writeShellApplication {
    name = "sync-wait";
    runtimeInputs = with pkgs; [curl jq libxml2 procps];
    text = ''
      # Database files copied while the server runs are inconsistent. This
      # also catches databases running inside docker containers.
      if running=$(pgrep -l -x 'postgres|redis-server'); then
        echo "Stop dev databases before syncing:"
        echo "$running"
        exit 1
      fi

      config="''${XDG_STATE_HOME:-$HOME/.local/state}/syncthing/config.xml"
      apikey=$(xmllint --xpath 'string(configuration/gui/apikey)' "$config")
      peers=(${lib.escapeShellArgs (lib.attrValues peers)})

      api() {
        curl -fsS -H "X-API-Key: $apikey" "http://127.0.0.1:8384/rest/$1"
      }

      for peer in "''${peers[@]}"; do
        echo "Waiting for $peer to connect..."

        until api system/connections | jq -e --arg id "$peer" '.connections[$id].connected' >/dev/null; do
          sleep 2
        done
      done

      echo "Connected, syncing..."

      # Require a few consecutive clean polls so a pause between index
      # exchanges is not mistaken for completion.
      stable=0

      while [ "$stable" -lt 3 ]; do
        synced=true

        for folder in ${lib.escapeShellArgs (lib.attrNames folders)}; do
          if ! api "db/status?folder=$folder" | jq -e '.state == "idle" and .needTotalItems == 0' >/dev/null; then
            synced=false
          fi
        done

        for peer in "''${peers[@]}"; do
          completion=$(api "db/completion?device=$peer" | jq '.completion | floor')
          printf '\r%s: %s%%   ' "$peer" "$completion"

          if [ "$completion" -lt 100 ]; then
            synced=false
          fi
        done

        if $synced; then
          stable=$((stable + 1))
        else
          stable=0
        fi

        sleep 2
      done

      printf '\nUp to date. Safe to shut down.\n'
    '';
  };
in {
  networking.firewall = {
    allowedTCPPorts = [22000];
    allowedUDPPorts = [22000 21027];
  };

  home-manager.users.kp = {
    home.packages = [syncWait];

    services.syncthing = {
      enable = true;
      cert = "${secretsDir}/cert.pem";
      key = "${secretsDir}/key.pem";

      settings = {
        options.urAccepted = -1;

        devices = lib.mapAttrs (_: id: {inherit id;}) peers;

        folders =
          lib.mapAttrs (_: path: {
            path = "${home}/${path}";
            devices = lib.attrNames peers;
            inherit ignorePatterns;

            versioning = {
              type = "trashcan";
              params.cleanoutDays = "30";
            };
          })
          folders;
      };
    };
  };
}
