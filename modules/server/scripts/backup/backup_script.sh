#!/bin/bash

LOG_FILE=/home/pthr/backup.log
EXCLUDE_FILE=/home/pthr/git/nixos/modules/server/scripts/backup/exclude.txt
INCLUDE_FILE=/home/pthr/git/nixos/modules/server/scripts/backup/include.txt
BACKUP_DIR="/mnt/raid5/.deleted-files/$(date +%Y%m%d)"

echo "running backup_script.sh" >> $LOG_FILE
echo "$(date)" >> $LOG_FILE
echo "Running as user: $(whoami)" >> $LOG_FILE

# Mount RAID5 if not already mounted
if ! mountpoint -q /mnt/raid5; then
  if mount /mnt/raid5; then
    echo "Mounted /mnt/raid5" >> $LOG_FILE
  else
    echo "ERROR: Failed to mount /mnt/raid5" >> $LOG_FILE
    exit 1
  fi
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Rsync backup
if rsync -ahHAX --backup --backup-dir="$BACKUP_DIR" --stats \
    --exclude-from=$EXCLUDE_FILE \
    --include-from=$INCLUDE_FILE \
    /mnt/nvme/ /mnt/raid5/current/ >> $LOG_FILE 2>&1; then
  echo "Backup completed successfully" >> $LOG_FILE
else
  echo "ERROR: Backup failed with exit code $?" >> $LOG_FILE
  exit 1
fi

# Clean up backup directories older than 30 days
find /mnt/raid5/.deleted-files/ -maxdepth 1 -type d -name "deleted-*" -mtime +30 -exec rm -rf {} \; 2>> $LOG_FILE

# Calculate sizes
SIZE_NVME=$(df -h /mnt/nvme 2>/dev/null)
SIZE_RAID5=$(df -h /mnt/raid5 2>/dev/null)

echo -e "\nNVME: $SIZE_NVME" >> $LOG_FILE
echo "RAID5: $SIZE_RAID5" >> $LOG_FILE

# Unmount and spin down RAID5 disks
if umount /mnt/raid5; then
  for disk in /dev/sdb /dev/sdc /dev/sdd; do
    hdparm -S 12 $disk
  done
  echo "RAID5 unmounted and drives spun down" >> $LOG_FILE
else
  echo "WARNING: Could not unmount /mnt/raid5. Drives not spun down." >> $LOG_FILE
fi

echo "Date: $(date)" >> $LOG_FILE
echo -e "--- Backup done ---\n" >> $LOG_FILE
