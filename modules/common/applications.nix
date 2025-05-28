{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    tree
    neofetch
  ];

  # Disable XTerm
  services.xserver.excludePackages = with pkgs; [ 
    xterm 
  ];
}
