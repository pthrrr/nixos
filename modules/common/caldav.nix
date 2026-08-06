{ config, lib, pkgs, ... }:
let
  cfg = config.services.caldav;
in
{
  options.services.caldav = {
    enable = lib.mkOption {
      default = false;
      description = "Enable CalDAV/CardDAV integration";
    };
    domain = lib.mkOption {
      default = "";
      description = "The domain for radicale";
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
}
