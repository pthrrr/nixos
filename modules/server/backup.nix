# modules/server/backup.nix
#
# Backup-Strategie:
#   sanoid  → stündliche ZFS-Snapshots auf tank/* (Retention: 24h/30d/6m)
#   syncoid → tägliches zfs send/receive tank/* → backup/data/*
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
    path = with pkgs; [ sanoid curl zfs bc ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      DATASETS="fotos users services containers"
      FAILED=""
      SUCCESS=""
      TOTAL_BYTES=0
      TIMESTAMP=$(date '+%d.%m.%Y %H:%M')
      START=$SECONDS

      # Prüfe ob backup Pool importiert und entsperrt ist
      if ! zpool list backup &>/dev/null; then
        echo "ABBRUCH: backup Pool nicht importiert"
        curl -s \
          -H "Title: Backup ABBRUCH" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d "Backup Pool nicht importiert ($TIMESTAMP). Bitte entsperren: sudo zpool import backup && sudo zfs load-key backup && sudo zfs mount -a" \
          http://127.0.0.1:2586/backup
        exit 1
      fi

      set +e  # syncoid gibt Exit 1 bei "nothing to do" zurück → nicht abbrechen
      for ds in $DATASETS; do
        echo "=== Syncing tank/$ds → backup/data/$ds ==="
        OUTPUT=$(syncoid --no-sync-snap "tank/$ds" "backup/data/$ds" 2>&1)
        RC=$?
        echo "$OUTPUT"
        if [ $RC -eq 0 ]; then
          SUCCESS="$SUCCESS $ds"
          # Übertragene Bytes aus syncoid-Ausgabe extrahieren (Format: "~ 194.6 MB")
          SIZE_LINE=$(echo "$OUTPUT" | grep -oE '\(~ [0-9.]+ [KMGT]B\)' | head -1)
          BYTES=$(echo "$SIZE_LINE" | grep -oE '[0-9.]+')
          UNIT=$(echo "$SIZE_LINE" | grep -oE '[KMGT]' | head -1)
          if [ -n "$BYTES" ]; then
            case "$UNIT" in
              K) TOTAL_BYTES=$(echo "$TOTAL_BYTES + $BYTES * 1024" | bc) ;;
              M) TOTAL_BYTES=$(echo "$TOTAL_BYTES + $BYTES * 1048576" | bc) ;;
              G) TOTAL_BYTES=$(echo "$TOTAL_BYTES + $BYTES * 1073741824" | bc) ;;
              T) TOTAL_BYTES=$(echo "$TOTAL_BYTES + $BYTES * 1099511627776" | bc) ;;
            esac
          fi
        elif echo "$OUTPUT" | grep -q "Nothing to do"; then
          # syncoid gibt Exit 1 zurück wenn keine neuen Snapshots vorhanden → kein Fehler
          SUCCESS="$SUCCESS $ds"
        else
          FAILED="$FAILED $ds"
        fi
      done
      set -e

      # Dauer berechnen
      ELAPSED=$(( SECONDS - START ))
      if [ $ELAPSED -ge 3600 ]; then
        DURATION="$(( ELAPSED / 3600 ))h $(( (ELAPSED % 3600) / 60 ))min"
      elif [ $ELAPSED -ge 60 ]; then
        DURATION="$(( ELAPSED / 60 ))min $(( ELAPSED % 60 ))s"
      else
        DURATION="''${ELAPSED}s"
      fi

      # Transfergröße formatieren
      if [ "$(echo "$TOTAL_BYTES > 1073741824" | bc)" -eq 1 ]; then
        TRANSFER="$(echo "scale=1; $TOTAL_BYTES / 1073741824" | bc) GB"
      elif [ "$(echo "$TOTAL_BYTES > 1048576" | bc)" -eq 1 ]; then
        TRANSFER="$(echo "scale=1; $TOTAL_BYTES / 1048576" | bc) MB"
      elif [ "$(echo "$TOTAL_BYTES > 1024" | bc)" -eq 1 ]; then
        TRANSFER="$(echo "scale=1; $TOTAL_BYTES / 1024" | bc) KB"
      elif [ "$(echo "$TOTAL_BYTES > 0" | bc)" -eq 1 ]; then
        TRANSFER="$(echo "$TOTAL_BYTES" | bc | cut -d. -f1) B"
      else
        TRANSFER="keine Daten (up-to-date)"
      fi

      # Platzbelegung sammeln (mit Prozent)
      TANK_USED=$(zfs get -H -o value used tank)
      TANK_AVAIL=$(zfs get -H -o value available tank)
      TANK_USED_BYTES=$(zfs get -Hp -o value used tank)
      TANK_AVAIL_BYTES=$(zfs get -Hp -o value available tank)
      TANK_PCT=$(echo "scale=0; $TANK_USED_BYTES * 100 / ($TANK_USED_BYTES + $TANK_AVAIL_BYTES)" | bc)
      BACKUP_USED=$(zfs get -H -o value used backup)
      BACKUP_AVAIL=$(zfs get -H -o value available backup)
      BACKUP_USED_BYTES=$(zfs get -Hp -o value used backup)
      BACKUP_AVAIL_BYTES=$(zfs get -Hp -o value available backup)
      BACKUP_PCT=$(echo "scale=0; $BACKUP_USED_BYTES * 100 / ($BACKUP_USED_BYTES + $BACKUP_AVAIL_BYTES)" | bc)
      STORAGE="NVMe: ''${TANK_USED} belegt, ''${TANK_AVAIL} frei (''${TANK_PCT}%) | RAID: ''${BACKUP_USED} belegt, ''${BACKUP_AVAIL} frei (''${BACKUP_PCT}%)"

      if [ -z "$FAILED" ]; then
        curl -s \
          -H "Title: Backup erfolgreich" \
          -H "Priority: low" \
          -H "Tags: white_check_mark" \
          -d "Alle Datasets synchronisiert ($TIMESTAMP)
Datasets:$SUCCESS
Transfer: $TRANSFER in $DURATION
$STORAGE" \
          http://127.0.0.1:2586/backup
      else
        curl -s \
          -H "Title: Backup FEHLER" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d "Backup-Probleme ($TIMESTAMP)
Fehlgeschlagen:$FAILED
Erfolgreich:$SUCCESS
Transfer: $TRANSFER in $DURATION
$STORAGE" \
          http://127.0.0.1:2586/backup
      fi
    '';
  };
}
