{ config, pkgs, lib, ... }:
let
  cfg = config.programs.caldav;
  secrets = config.age.secrets;
  domain = lib.strings.removeTrailing "\n" (builtins.readFile secrets.domain.path);
  username = lib.strings.removeTrailing "\n" (builtins.readFile secrets.username1.path);
  password = lib.strings.removeTrailing "\n" (builtins.readFile secrets.password1.path);
in
{
  options.programs.caldav = {
    enable = lib.mkOption {
      default = false;
      description = "Enable CalDAV/CardDAV integration for GNOME Calendar and Contacts";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-calendar
    ];

    dconf.settings = {
      "org/gnome/calendar" = {
        caldav-urls = [
          "https://radicale.${domain}/${username}/calendar"
        ];
        caldav-usernames = [ username ];
        caldav-passwords = [ password ];
        caldav-servers = [
          "https://radicale.${domain}"
        ];
      };

      "org/gnome/contacts" = {
        carddav-urls = [
          "https://radicale.${domain}/${username}/contacts"
        ];
        carddav-usernames = [ username ];
        carddav-passwords = [ password ];
        carddav-servers = [
          "https://radicale.${domain}"
        ];
      };
    };
  };
}
