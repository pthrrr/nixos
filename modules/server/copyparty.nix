{ config, pkgs, lib, ... }:

let
  stripNL   = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
in
{
  # ─── secrets ───────────────────────────────────────────────
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  age.secrets.password1 = { file = ../../secrets/password1.age; owner = "copyparty"; mode = "0400"; };
  age.secrets.password2 = { file = ../../secrets/password2.age; owner = "copyparty"; mode = "0400"; };

  # ─── service account ──────────────────────────────────────
  users.groups.copyparty = {};
  users.users.copyparty  = {
    isSystemUser = true;
    group        = "copyparty";
    home         = "/var/lib/copyparty";
    createHome   = true;
  };

  # ─── cache directories (history + thumbnails) ─────────────
  systemd.tmpfiles.rules = [
    "d /var/lib/copyparty       0750 copyparty copyparty -"
    "d /var/lib/copyparty/hist  0750 copyparty copyparty -"
  ];

  # ─── Copyparty service ────────────────────────────────────
  services.copyparty = {
    enable = true;

    settings = {
      i = "0.0.0.0";
      p = 3210;
      hist = "/var/lib/copyparty/hist";
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
      "/${username1}-data" = {
        path   = "/mnt/nvme/users/${username1}";
        access = { A = username1; };
      };

      "/${username2}-data" = {
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
    };

    openFilesLimit = 8192;
  };
}
