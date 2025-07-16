{
  imports = [
    ./samba.nix
    ./caddy.nix
    ./pihole.nix
    ./mount_raid.nix
    ./homeassistant.nix
    #./docker
    ../common/house-keeping.nix 
 ];
}
