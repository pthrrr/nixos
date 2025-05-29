{ config, pkgs, ... }:

{
  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    mangohud
    mangojuice
  ];

  # Enable Steam services
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  
  programs.gamemode.enable = true;

  # Optional: Configure MangoHud globally
  #environment.variables = {
  #  MANGOHUD = "1";  # Enable MangoHud globally for all games
  #};
}
