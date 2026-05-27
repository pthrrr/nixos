{ pkgs, ... }:

{
  # OpenRazer daemon for Razer peripherals
  hardware.openrazer = {
    enable = true;
    users = [ "pthr" ];
  };

  # Polychromatic: GUI for managing Razer devices
  environment.systemPackages = with pkgs; [
    polychromatic
  ];
}
