{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bitwig-studio
    #bitwig-studio-unwrapped

    # VSTs
    yabridge
    yabridgectl
  ];
}
