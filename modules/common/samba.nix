{ config, pkgs, ... }:
let
  # Read the decrypted usernames from agenix secrets (client needs the same secrets)
  username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
  username2 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username2.path);
in
{
  # Required packages for CIFS mounting
  environment.systemPackages = [ pkgs.cifs-utils pkgs.samba ];

  # Mount admin share using encrypted username
  fileSystems."/mnt/admin_share" = {
    device = "//192.168.10.100/${username1}";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/admin-secrets,uid=1000,gid=100,file_mode=0664,dir_mode=0775"];
  };

  # Mount user files using encrypted username
  fileSystems."/mnt/user_files" = {
    device = "//192.168.10.100/${username2}";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/user-secrets,uid=1000,gid=100,file_mode=0664,dir_mode=0775"];
  };

}
