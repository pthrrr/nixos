{ config, pkgs, ... }:
let
  domain = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.domain.path);
in
{
  age.secrets.domain = {
    file = ../../secrets/domain.age;
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "homeassistant_hardware"
      "shopping_list"
      "shelly"
      "thread"
      "matter"
    ];
    extraPackages = python3Packages: with python3Packages; [
      getmac
      pyfritzhome
      fritzconnection
      aiohomekit
      xmltodict
    ];
    config = {
      default_config = {};
      automation = "!include automations.yaml";

      homeassistant = {
        time_zone = "Europe/Berlin";
      };
      http = {
        server_host = [ "0.0.0.0" "::" ];
        server_port = 8123;
        trusted_proxies = [
          "192.168.10.100"
          "127.0.0.1"
          "::1"
        ];
        use_x_forwarded_for = true;
      };
      lovelace = {
        mode = "storage";
        resources = [];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  networking.firewall.allowedUDPPorts = [ 5683 ]; # CoIoT, unicast shelly
}
