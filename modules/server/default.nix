{
  imports = [
    ./samba.nix
    ./caddy.nix
    ./pihole.nix
    ./backup.nix
    ./radicale.nix
    ./mount_raid.nix
    ./homeassistant.nix
    ../common/house-keeping.nix 
 ];
}
