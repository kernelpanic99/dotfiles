{...}: {
  # Automatic backup schedule. Imported only by hosts that back up on a timer.
  # Hosts without this module still have restic fully configured (see
  # config/restic.nix) for on-demand backup and restore.
  home-manager.users.kp.services.restic.backups.main.timerConfig = {
    OnCalendar = "21:00";
    Persistent = true;
  };
}
