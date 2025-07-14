{
  imports = [
    ./samba.nix
    ./mount_raid.nix
    ./homeassistant.nix
    ./docker
    ../common/house-keeping.nix 
 ];
}
