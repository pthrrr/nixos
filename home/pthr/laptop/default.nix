{ pkgs, config, lib, ... }:

let
  sharedConfig = import ./../home.nix { inherit pkgs config lib; };
in
{
  imports = [ sharedConfig ];

  # Laptop-specific packages
  home.packages = with pkgs; sharedConfig.home.packages ++ [
    bitwig-studio
    arduino
    arduinoOTA
  ];
}
