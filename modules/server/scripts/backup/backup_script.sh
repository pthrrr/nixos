#!/bin/bash

LOG_FILE=/home/pthr/cron/backup.log
EXCLUDE_FILE=/home/pthr/git/nixos/modules/server/scripts/backup/exclude.txt
INCLUDE_FILE=/home/pthr/git/nixos/modules/server/scripts/backup/include.txt

# Mount RAID5 if not already mounted
if ! mountpoint -q /mnt/raid5; then
  mount /mnt/raid5
  echo "Mounted /mnt/raid5" >> $LOG_FILE
fi

echo -e "\n------------------------------" >> $LOG_FILE
echo "running backup_script.sh" >> $LOG_FILE
echo "$(date)" >> $LOG_FILE
echo "PATH: $PATH" >> $LOG_FILE
echo "Running as user: $(whoami)" >> $LOG_FILE

# Rsync backup
rsync -ahHAX --stats \
    --exclude-from=$EXCLUDE_FILE \
    --include-from=$INCLUDE_FILE \
    /mnt/nvme/ /mnt/raid5/ >> $LOG_FILE 2>&1

# Calculate sizes
SIZE_NVME=$(df -h /mnt/nvme 2>/dev/null)
SIZE_RAID5=$(df -h /mnt/raid5 2>/dev/null)

echo -e "\nNVME: $SIZE_NVME" >> $LOG_FILE
echo "RAID5: $SIZE_RAID5" >> $LOG_FILE
echo -e "" >> $LOG_FILE

# Unmount and spin down RAID5 disks
if umount /mnt/raid5; then
  for disk in /dev/sdb /dev/sdc /dev/sdd; do
    #hdparm -y $disk
    hdparm -S 12 $disk # spin down after 1 minute of inactivity
  done
  echo "RAID5 unmounted and drives spun down" >> $LOG_FILE
else
  echo "WARNING: Could not unmount /mnt/raid5. Drives not spun down." >> $LOG_FILE
fi

echo "Date: $(date)" >> $LOG_FILE
echo -e "--- Backup done ---\n" >> $LOG_FILE
