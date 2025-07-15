
{ config, pkgs, lib, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "shopping_list"
      "otbr" # open thread border router 
    ];
    config = {
      default_config = {};
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];

}

