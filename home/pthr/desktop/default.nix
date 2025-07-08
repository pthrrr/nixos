{ pkgs, config, lib, ... }:

let
  sharedConfig = import ./../home.nix { inherit pkgs config lib; };
in
{
  imports = [ sharedConfig ];

  # Desktop-specific packages
  home.packages = with pkgs; sharedConfig.home.packages ++ [
    discord
    teamspeak3
    unigine-valley
  ];
}
