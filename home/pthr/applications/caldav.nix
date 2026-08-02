{ config, pkgs, lib, ... }:
let
  cfg = config.programs.caldav;
  credentialsFile = config.home-manager.users.pthr.file.".config/caldav/credentials.json".source;
  cred = builtins.fromJSON (builtins.readFile credentialsFile);
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
          "https://radicale.${cred.domain}/${cred.username}/calendar"
        ];
        caldav-usernames = [ cred.username ];
        caldav-passwords = [ cred.password ];
        caldav-servers = [
          "https://radicale.${cred.domain}"
        ];
      };

      "org/gnome/contacts" = {
        carddav-urls = [
          "https://radicale.${cred.domain}/${cred.username}/contacts"
        ];
        carddav-usernames = [ cred.username ];
        carddav-passwords = [ cred.password ];
        carddav-servers = [
          "https://radicale.${cred.domain}"
        ];
      };
    };
  };
}
