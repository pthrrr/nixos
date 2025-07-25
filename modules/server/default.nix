{
  imports = [
    ./samba.nix
    ./caddy.nix
    ./pihole.nix
    #./backup.nix
    ./radicale.nix
    ./mount_raid.nix
    ./matter-server.nix
    ./home-assistant.nix
    ../common/house-keeping.nix 
 ];
}
