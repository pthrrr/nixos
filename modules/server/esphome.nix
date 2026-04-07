{ config, pkgs, ... }:
{
  services.esphome = {
    enable = true;
    port = 6052;
    address = "0.0.0.0";
  };

  # Port 6052: ESPHome Dashboard (direkt, ohne Caddy)
  # Port 6053: ESPHome Native API (ESP-Geräte → Home Assistant)
  networking.firewall.allowedTCPPorts = [ 6052 6053 ];
}
