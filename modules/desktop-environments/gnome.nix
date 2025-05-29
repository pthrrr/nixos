{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pkgs.gnome-tweaks

    # gnome extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.paperwm
  ];

  # Exclude specific GNOME applications
  environment.gnome.excludePackages = with pkgs; [
    totem
    epiphany
    gnome-weather
    gnome-maps
    gnome-music
    gnome-calendar
    gnome-calculator
    gnome-text-editor
    gnome-contacts
    gnome-photos
    gnome-logs
    gnome-tour
    snapshot
    gedit
    simple-scan
    yelp
    geary
  ];
}
