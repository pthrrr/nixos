{ config, pkgs, lib, ... }:
let
  # Read the decrypted usernames from agenix secrets (same as server)
  username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
  username2 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username2.path);
in
{
  environment.systemPackages = [ pkgs.cifs-utils pkgs.samba ];

  fileSystems."/mnt/nvme" = {
    device = "//192.168.10.100";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100,file_mode=0664,dir_mode=0775"];
  };

}
