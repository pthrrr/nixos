{
  # Enable software RAID support
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      DEVICE /dev/disk/by-id/ata-ST2000VN004-2E4164_W524S2VN
      DEVICE /dev/disk/by-id/ata-ST2000VN004-2E4164_Z528SKQL
      DEVICE /dev/disk/by-id/ata-ST2000VN004-2E4164_Z52BDS00
      
      ARRAY /dev/md0 metadata=1.2 UUID=ace21660:6c81534f:91ec72fb:14f6b156
    '';
  };

  # Configure filesystem mounting
  fileSystems."/mnt/raid5" = {
    device = "/dev/md0";
    fsType = "ext4";
    options = [ "noauto" ]; # noauto disables auto-mounting | defaults would auto mount
  };
}
