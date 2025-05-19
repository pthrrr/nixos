{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        pinage404.pinage404-vscode-extension-packs
    ];
  };
}