{ config, pkgs, ... }:
{
  age.secrets.radicale-users = {
    file = ../../secrets/radicale-users.age;
    owner = "radicale";
    group = "radicale";
  };
  
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "127.0.0.1:5232" "[::1]:5232" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-users.path;
        htpasswd_encryption = "bcrypt";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /var/lib/radicale 0755 radicale radicale -"
    "d /var/lib/radicale/collections 0755 radicale radicale -"
  ];

  networking.firewall.allowedTCPPorts = [ 5232 ];
}
