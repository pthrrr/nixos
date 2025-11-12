{ config, pkgs, lib, ... }:

let
  stripNL   = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
in
{
  # secrets
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  age.secrets.password1 = { file = ../../secrets/password1.age; owner = "media"; mode = "0400"; };
  age.secrets.password2 = { file = ../../secrets/password2.age; owner = "media"; mode = "0400"; };

  # cache directories (history + thumbnails)
  systemd.tmpfiles.rules = [
    "d /var/lib/media/copyparty       0750 media media -"
    "d /var/lib/media/copyparty/hist  0750 media media -"
  ];

  # Copyparty service
  services.copyparty = {
    enable = true;

    # Run as media user
    user = "media";
    group = "media";

    settings = {
      i = "0.0.0.0";
      p = 3210;
      hist = "/var/lib/media/copyparty/hist";
      e2t = true;      # multimedia index
      e2ts = true;     # thumbnails
      e2d = true;      # dedup database
      hash-mt = 4;     # multi-threaded hashing
      no-reload = true;
    };

    accounts.${username1}.passwordFile = config.age.secrets.password1.path;
    accounts.${username2}.passwordFile = config.age.secrets.password2.path;

    volumes = {
      # Main user directories
      "/${username1}" = {
        path   = "/mnt/nvme/users/${username1}";
        access = { A = username1; };
      };

      "/${username2}" = {
        path   = "/mnt/nvme/users/${username2}";
        access = { 
          rwmd = username2;
          rA = username1;
        };
      };

      # Photo directories
      "/${username1}-photos" = {
        path   = "/mnt/nvme/photos/${username1}";
        access = { A = username1; };
      };

      "/${username2}-photos" = {
        path   = "/mnt/nvme/photos/${username2}";
        access = { 
          rwmd = username2;
          rA = username1;
        };
      };

      "/papa-photos" = {
        path   = "/mnt/nvme/photos/papa";
        access = { A = username1; };
      };

      # papa data
      "/papa" = {
        path   = "/mnt/nvme/users/papa";
        access = { A = username1; };
      };
    };

    openFilesLimit = 8192;
  };

  # Fix file permissions for group collaboration
  systemd.services.copyparty = {
    serviceConfig = {
      UMask = lib.mkForce "0002";  # Creates files as 644 instead of 600
    };
  };
}
