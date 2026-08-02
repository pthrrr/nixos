{ config, lib, pkgs, ... }:
let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;
  cfg = config.services.caldav;
  credentials = pkgs.writeText "caldav-credentials" ''
    {
      "domain" = "${stripNL cfg.domain}";
      "username" = "${stripNL cfg.username}";
      "password" = "${stripNL cfg.password}";
    };
in
{
  options.services.caldav = {
    enable = lib.mkOption {
      default = false;
      description = "Enable CalDAV/CardDAV integration";
    };
    domain = lib.mkOption {
      default = "";
      description = "The domain for radicale (e.g. )";
    };
    username = lib.mkOption {
      default = "";
      description = "Radical user name";
    };
    password = lib.mkOption {
      default = "";
      description = "Radical user password";
    };
  };

  config = lib.mkIf config.services.caldav.enable {
    home-manager.users.pthr.file = {
      ".config/caldav/credentials.json".source = credentials;
    };
  };
}
