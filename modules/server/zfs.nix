# modules/server/zfs.nix
{
  # mdraid nicht mehr benötigt
  boot.swraid.enable = false;

  # ZFS auto-import für Pool "tank" (unverschlüsselt, startet automatisch)
  # Pool "backup" wird NICHT auto-importiert (verschlüsselt, braucht Passphrase)
  # → backup manuell importieren: sudo zpool import backup && sudo zfs load-key backup && sudo zfs mount -a
  boot.zfs.extraPools = [ "tank" ];
}
