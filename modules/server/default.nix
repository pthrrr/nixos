{
  imports = [
    ./podman

    ./caddy.nix
    #./backup.nix
    ./radicale.nix
    ./syncthing.nix
    ./copyparty.nix
    ./mount_raid.nix
    ./matter-server.nix
    ./home-assistant.nix

    ../common/house-keeping.nix 
 ];
}
