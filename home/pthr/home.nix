{ config, pkgs, lib, ... }:
{

  imports = [
    ./applications/dconf.nix
    ./applications/vscodium.nix
  ];

  home.username = "pthr";
  home.homeDirectory = "/home/pthr";
  home.stateVersion = "22.05";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    brave
    keepassxc
    signal-desktop
    telegram-desktop
    freetube
    vlc
    spotify
  ];

  programs.git = {
    enable = true;
    userName = "pthrrr";
    #userEmail = "";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "discord"
      "unigine-valley"
      "bitwig-studio-unwrapped"
  ];
}
