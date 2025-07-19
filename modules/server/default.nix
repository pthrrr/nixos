{
  imports = [
    ./samba.nix
    ./caddy.nix
    ./pihole.nix
    ./radicale.nix
    ./mount_raid.nix
    ./homeassistant.nix
    #./docker
    ../common/house-keeping.nix 
 ];
}
