{ pkgs, ... }:
{
  imports = [];

  nix.settings.experimental-features = [ 
     "nix-command"
     "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
  ];
}