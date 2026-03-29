# modules/server/backup.nix
#
# Backup-Strategie:
#   sanoid  → stündliche ZFS-Snapshots auf tank/* (Retention: 24h/30d/6m)
#   syncoid → tägliches zfs send/receive tank/* → backup/snapshots/*
#   ntfy    → Push-Benachrichtigung nach jedem Backup-Lauf
#
# Nach jedem Reboot muss der backup Pool manuell entsperrt werden:
#   sudo zpool import backup && sudo zfs load-key backup && sudo zfs mount -a
#
{ config, pkgs, ... }:

{
  # ── sanoid: ZFS-Snapshots erstellen + aufräumen ──────────────────────
  #
  # Erstellt automatisch Snapshots auf tank/* nach Zeitplan.
  # Retention: 24 stündliche, 30 tägliche, 6 monatliche Snapshots.
  # Läuft immer (unabhängig davon, ob backup Pool importiert ist).

  services.sanoid = {
    enable = true;
    interval = "hourly";

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

  # ── backup-sync: syncoid + ntfy-Benachrichtigung ────────────────────
  #
  # Eigener Wrapper statt services.syncoid, damit wir:
  #   - Alle Datasets sequentiell synchronisieren
  #   - Ergebnisse sammeln (Erfolg/Fehlschlag pro Dataset)
  #   - EINE konsolidierte ntfy-Nachricht senden
  #
  # Wenn backup Pool nicht importiert → alle Datasets schlagen fehl →
  # ntfy-Warnung erinnert daran, den Pool zu entsperren.

  systemd.timers.backup-sync = {
    description = "ZFS Backup Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;  # nachholen wenn Server um 03:00 aus war
    };
  };

  systemd.services.backup-sync = {
    description = "ZFS Backup (syncoid) mit ntfy-Benachrichtigung";
    after = [ "ntfy-sh.service" ];
    path = with pkgs; [ sanoid curl zfs ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      DATASETS="fotos users services containers"
      FAILED=""
      SUCCESS=""
      ERRORS=""

      for ds in $DATASETS; do
        echo "=== Syncing tank/$ds → backup/snapshots/$ds ==="
        OUTPUT=$(syncoid --no-sync-snap "tank/$ds" "backup/snapshots/$ds" 2>&1) && {
          SUCCESS="$SUCCESS $ds"
          echo "$OUTPUT"
        } || {
          FAILED="$FAILED $ds"
          ERRORS="$ERRORS
$ds: $OUTPUT"
          echo "FEHLER bei $ds: $OUTPUT"
        }
      done

      TIMESTAMP=$(date '+%d.%m.%Y %H:%M')

      if [ -z "$FAILED" ]; then
        curl -s \
          -H "Title: Backup erfolgreich" \
          -H "Priority: low" \
          -H "Tags: white_check_mark" \
          -d "Alle Datasets synchronisiert ($TIMESTAMP):$SUCCESS" \
          http://127.0.0.1:2586/backup
      else
        curl -s \
          -H "Title: Backup FEHLER" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d "Backup-Probleme ($TIMESTAMP)
Fehlgeschlagen:$FAILED
Erfolgreich:$SUCCESS" \
          http://127.0.0.1:2586/backup
      fi
    '';
  };
}
