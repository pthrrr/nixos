
{ config, pkgs, lib, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "shopping_list"
    ];
    config = {
      default_config = {};
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];

}

