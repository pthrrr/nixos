{ config, pkgs, lib, ... }:
let
  # Read the decrypted usernames from agenix secrets
  username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
  username2 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username2.path);
in
{
  users.users.${username1} = {
    isSystemUser = true;
    description = "Samba user 1";
    group = "users";
    uid = 1005;
    shell = pkgs.shadow;
  };

  users.users.${username2} = {
    isSystemUser = true;
    description = "Samba user 2";
    group = "users";
    uid = 1006;
    shell = pkgs.shadow;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "NixOS Server";
        "netbios name" = "nixos-server";
        security = "user";
        "map to guest" = "bad user";
        "dns proxy" = "no";
        "log file" = "/var/log/samba/smb.log";
        "log level" = 1;
      };
      
      "${username1}" = {
        path = "/mnt/nvme/users/${username1}";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = username1;
        "force user" = "dataowner1";
        "create mask" = "0664";
        "directory mask" = "0775";
        comment = "Admin access to all data";
      };
      
      "${username2}" = {
        path = "/mnt/nvme/users/${username2}";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = username2;
        "force user" = "dataowner2";
        "create mask" = "0664";
        "directory mask" = "0775";
        comment = "Personal files";
      };
      
    };
  };
}
