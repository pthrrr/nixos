{ config, pkgs, ... }:

{
  # ── sanoid: ZFS-Snapshots erstellen + aufräumen ──────────────────────
  #
  # Erstellt automatisch Snapshots auf tank/* nach Zeitplan.
  # Retention: 24 stündliche, 30 tägliche, 6 monatliche Snapshots.
  # Läuft immer (unabhängig davon, ob backup Pool importiert ist).

  services.sanoid = {
    enable = true;
    interval = "hourly";  # systemd-Timer: jede Stunde

    datasets = {
      "tank/fotos" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
      "tank/users" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
      "tank/services" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
      "tank/containers" = {
        autosnap = true;
        autoprune = true;
        hourly = 24;
        daily = 30;
        monthly = 6;
      };
    };
  };

  # ── syncoid: zfs send/receive (tank → backup) ───────────────────────
  #
  # Inkrementelles Backup von tank Datasets auf backup Pool.
  # Läuft täglich um 03:00.
  # Wenn backup Pool nicht importiert ist, schlägt syncoid fehl →
  # wird beim nächsten Lauf nachgeholt sobald der Pool importiert ist.
  #
  # Nach jedem Reboot muss der backup Pool manuell entsperrt werden:
  #   sudo zpool import backup && sudo zfs load-key backup && sudo zfs mount -a

  services.syncoid = {
    enable = true;
    interval = "*-*-* 03:00:00";  # täglich um 03:00

    commands = {
      "tank/fotos" = {
        target = "backup/snapshots/fotos";
        extraArgs = [ "--no-sync-snap" ];  # nutzt sanoid-Snapshots
      };
      "tank/users" = {
        target = "backup/snapshots/users";
        extraArgs = [ "--no-sync-snap" ];
      };
      "tank/services" = {
        target = "backup/snapshots/services";
        extraArgs = [ "--no-sync-snap" ];
      };
      "tank/containers" = {
        target = "backup/snapshots/containers";
        extraArgs = [ "--no-sync-snap" ];
      };
    };
  };
}
