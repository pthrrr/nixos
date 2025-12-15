{ config, pkgs, lib, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    pkgs.gnome-tweaks
  ];

  # Disable GNOME Keyring
  # services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Exclude specific GNOME applications
  environment.gnome.excludePackages = with pkgs; [
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
