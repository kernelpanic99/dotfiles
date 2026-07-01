# Bootstrap (once per machine):
#   mkdir -p ~/.local/share/restic
#   chmod 700 ~/.local/share/restic
#   echo 'PASSWORD'    > ~/.local/share/restic/password
#   echo 'REPO_URL'    > ~/.local/share/restic/repository
#   printf 'AWS_ACCESS_KEY_ID=...\nAWS_SECRET_ACCESS_KEY=...\n' > ~/.local/share/restic/env
#   chmod 600 ~/.local/share/restic/{password,repository,env}
# Store values in KeePassXC.
#
# Restore
# set -x RESTIC_REPOSITORY (cat ~/.local/share/restic/repository)
# set -x RESTIC_PASSWORD_FILE ~/.local/share/restic/password
# export (cat ~/.local/share/restic/env | xargs)  # or source it in bash
{
  config,
  lib,
  ...
}: let
  secretsDir = "${config.home.homeDirectory}/.local/share/restic";
in {
  services.restic.enable = true;

  services.restic.backups.main = {
    repositoryFile = "${secretsDir}/repository";
    passwordFile = "${secretsDir}/password";
    environmentFile = "${secretsDir}/env";

    paths = [
      "${config.home.homeDirectory}/adev"
      "${config.home.homeDirectory}/bdev"
      "${config.home.homeDirectory}/Documents"
      "${config.home.homeDirectory}/Pictures/Wallpapers"
      "${config.home.homeDirectory}/Music/beatport"
      "${config.home.homeDirectory}/.ssh"
      "${config.home.homeDirectory}/.aws"
      "${config.home.homeDirectory}/.local/share/timewarrior"
      "${config.home.homeDirectory}/.config/BraveSoftware"
    ];

    exclude = [
      # Dependencies / build artifacts
      "node_modules"
      "target"
      "dist"
      "build"
      "out"
      ".next"
      ".nuxt"
      ".terraform"

      # Package manager caches
      ".npm"
      ".yarn/cache"
      ".pnpm-store"

      # Browser caches (large, not useful to restore)
      "CacheStorage"
      "Cache"
      "cache2"
      "Code Cache"
      "GPUCache"
      "Application Cache"
      "Crashpad"
      "crash_reports"
      "IndexedDB"
      "Local Storage"
      "Session Storage"

      # Temp / logs
      "*.log"
      "*.tmp"
      ".cache"
      ".tmp"
    ];

    # No automatic timer by default: restic stays configured for on-demand
    # backup and restore on every host. Hosts that back up on a schedule set
    # a concrete timer via config/backup-schedule.nix, which overrides this.
    timerConfig = lib.mkDefault null;

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--prune"
    ];
  };
}
