{ config, pkgs, ... }:
{
  programs.vscodium = {
    enable = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };
}