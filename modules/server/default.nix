{
  imports = [
    ./samba.nix
    ./caddy.nix
    ./mount_raid.nix
    ./homeassistant.nix
    #./docker
    ../common/house-keeping.nix 
 ];
}
