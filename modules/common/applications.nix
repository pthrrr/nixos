{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    python314
    tree
    neofetch
  ];

  # Disable XTerm
  services.xserver.excludePackages = with pkgs; [ 
    xterm 
  ];
}
