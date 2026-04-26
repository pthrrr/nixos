{ config, pkgs, ... }:
{
  services.esphome = {
    enable = true;
    port = 6052;
    address = "0.0.0.0";
  };

  # Port 6052: ESPHome Dashboard
  # Port 6053: ESPHome Native API (ESP-Geräte → Home Assistant)
  # Port 3232: ESPHome OTA updates
  # Port 8266: ArduinoOTA updates
  networking.firewall.allowedTCPPorts = [ 6052 6053 3232 8266 ];
  networking.firewall.allowedUDPPorts = [ 8266 ];
}
