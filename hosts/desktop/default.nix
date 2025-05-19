{ config, pkgs, lib, ... }:

{
  imports = [
    #./../../modules/apps/vscodium.nix
    ./hardware-configuration.nix
    ./configuration.nix
  ];

  networking.hostName = "nixos";
}
