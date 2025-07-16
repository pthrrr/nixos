{ config, pkgs, lib, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "shopping_list"
      "otbr"
    ];
    config = {
      default_config = {};
      
      # Top-level URL configuration (not under http)
      external_url = "https://ha.my.domain";  # Replace with your actual domain
      internal_url = "http://localhost:8123";
      
      # HTTP configuration for reverse proxy
      http = {
        trusted_proxies = [
          "192.168.10.100"  # Your server's internal IP
          "127.0.0.1"
          "::1"
        ];
        use_x_forwarded_for = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
