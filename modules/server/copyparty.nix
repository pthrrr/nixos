{ config, pkgs, lib, ... }:

# ─────────────────────────────────────────────────────────────
#  modules/server/copyparty.nix   (fixed)
# ─────────────────────────────────────────────────────────────
let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;

  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
in
{
  # ─── secrets ───────────────────────────────────────────────
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  age.secrets.password1 = {
    file  = ../../secrets/password1.age;
    owner = "copyparty";
    mode  = "0400";
  };
  age.secrets.password2 = {
    file  = ../../secrets/password2.age;
    owner = "copyparty";
    mode  = "0400";
  };

  # ─── service account ──────────────────────────────────────
  users.groups.copyparty = {};

  users.users.copyparty = {
    isSystemUser = true;
    group        = "copyparty";
    extraGroups  = [ "users" ];
    home         = "/var/lib/copyparty";
    createHome   = true;
  };

  # ─── make sure cache dir exists before service starts ─────
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

      # central store for history + thumbnails
      hist = "/var/lib/copyparty/hist";

      e2t  = true;  # multimedia index
      e2ts = true;  # generate thumbnails
      e2d  = true;  # dedup DB
      hash-mt = 4;
      no-reload = true;
    };

    accounts.${username1}.passwordFile = config.age.secrets.password1.path;
    accounts.${username2}.passwordFile = config.age.secrets.password2.path;

    volumes = {
      "/${username1}" = {
        path   = "/mnt/nvme/users/${username1}";
        access = { rwd = username1; };
        flags  = { fk = 4; scan = 300; e2d = true; e2t = true; };
      };
      "/${username2}" = {
        path   = "/mnt/nvme/users/${username2}";
        access = { rwd = username2; r = username1; };
        flags  = { fk = 4; scan = 300; e2d = true; e2t = true; };
      };
      "/shared" = {
        path   = "/mnt/nvme/shared";
        access = { rwd = [ username1 username2 ]; };
        flags  = { fk = 4; scan = 300; e2d = true; e2t = true; };
      };
      "/public" = {
        path   = "/mnt/nvme/public";
        access = { r = "*"; rwd = username1; };
        flags  = { fk = 4; scan = 300; e2d = true; };
      };
    };

    openFilesLimit = 8192;
  };
}
