{ config, pkgs, lib, ... }:
let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;
  domain = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.domain.path);
in
{
  age.secrets.domain = {
    file = ../../../secrets/domain.age;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    
    containers = {
      freshrss = {
        image = "freshrss/freshrss:latest";
        
        ports = [
          "127.0.0.1:8082:80"
        ];
        
        environment = {
          CRON_MIN = "*/15";  # Update feeds every 15 minutes
          TZ = "Europe/Berlin";
        };
        
        volumes = [
          "freshrss-data:/var/www/FreshRSS/data"
          "freshrss-extensions:/var/www/FreshRSS/extensions"
        ];
        
        extraOptions = [
          "--pull=always"
        ];
      };
    };
  };
}
