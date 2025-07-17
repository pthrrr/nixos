{ config, pkgs, ... }:

let
  backupScript = ./scripts/backup/backup_script.sh;
in
{
  systemd.services.backup-script = {
    description = "Nightly NVMe to RAID5 Backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${backupScript}";
      User = "root";
    };
    path = [ pkgs.hdparm pkgs.rsync ];
  };

  systemd.timers.backup-script = {
    description = "Nightly NVMe to RAID5 Backup Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
    };
  };
}
