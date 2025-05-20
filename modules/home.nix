{
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    ./apps/vscodium.nix
  ];

  # Home Manager settings
  home.username = "pthr";
  home.homeDirectory = "/home/pthr";
  home.stateVersion = "25.05";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Packages specific to your user
  home.packages = with pkgs; [ ];

  # Program-specific configurations
  #programs.git = {
  #  enable = true;
  #  #userName = "Your Name";
  #  #userEmail = "your.email@example.com";
  #};

  # Additional configurations...
}
