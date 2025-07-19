{ config, pkgs, ... }:

let
  domain = builtins.readFile "/run/agenix/domain";
in
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "shopping_list"
    ];
    config = {
      default_config = {};
      external_url = "https://ha.${builtins.replaceStrings ["\n"] [""] domain}";
      internal_url = "http://localhost:8123";
      http = {
        trusted_proxies = [
          "192.168.10.100"
          "127.0.0.1"
          "::1"
        ];
        use_x_forwarded_for = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
