{ config, pkgs, lib, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    pkgs.gnome-tweaks
  ];

  # Disable GNOME Keyring secret service — pass-secret-service handles
  # org.freedesktop.secrets via pass/GPG instead (enabled in home-manager)
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Exclude specific GNOME applications
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    totem
    epiphany
    gnome-weather
    gnome-maps
    gnome-music
    # gnome-calendar
    # gnome-text-editor
    gnome-contacts
    gnome-logs
    gnome-tour
    # snapshot
    gedit
    # simple-scan
    yelp
    geary
  ];
}
