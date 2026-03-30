{ config, pkgs, lib, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    pkgs.gnome-tweaks
  ];

  # GNOME Keyring provides org.freedesktop.secrets for Electron apps (Signal etc.)
  services.gnome.gnome-keyring.enable = true;

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
