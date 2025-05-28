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

    # TODO throws exception in journalctl
    # JS ERROR: Error: Requiring Gtk, version 3.0: Typelib file for namespace 'Gtk', version '3.0' not found
    # https://github.com/NixOS/nixpkgs/issues/256889
    gnomeExtensions.pop-shell
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
