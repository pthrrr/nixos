# modules/server/zfs.nix (Entwurf)
{
  # mdraid nicht mehr benötigt
  boot.swraid.enable = false;

  # ZFS auto-import für Pool "backup"
  boot.zfs.extraPools = [ "backup" ];
}
