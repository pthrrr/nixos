{ config, pkgs, audio-nix, ... }:

{

  imports = [
    audio-nix.nixosModules.yabridgemgr
  ];

  # Add the audio.nix overlay to access their packages
  nixpkgs.overlays = [ audio-nix.overlays.default ];
  
  users.groups.realtime = {};
  users.users.pthr.extraGroups = [ "realtime" "audio" ];

  security.pam.loginLimits = [
    { domain = "@realtime"; item = "rtprio";  type = "soft"; value = "95"; }
    { domain = "@realtime"; item = "rtprio";  type = "hard"; value = "95"; }
    { domain = "@realtime"; item = "memlock"; type = "soft"; value = "unlimited"; }
    { domain = "@realtime"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "@realtime"; item = "nice";    type = "soft"; value = "-11"; }
  ];

  security.rtkit.enable = true;

environment.systemPackages = with pkgs; [
  #bitwig-studio
  yabridge
  yabridgectl

  x42-plugins           # Professional mixing/mastering tools
  distrho-ports                 # Collection of creative effects
  dragonfly-reverb      # Beautiful convolution reverbs
  calf                  # Comprehensive effect collection
  
  ] ++ (with audio-nix.packages.${pkgs.system}; [
    #bitwig-studio6-latest

    # Core audio tools
    # neuralnote          # AI note recognition
    paulxstretch        # Audio stretching
    vital        # Synthesizer
    atlas2              # Sample organizer
    papu                # Gameboy Emulator

    # CHOW plugin collection (choose what you need)
    #chow-tape-mode      # Tape saturation
    #chow-centaur       # Overdrive
    #chow-kick          # Kick synthesizer
    # chow-multitool    # Multi-purpose tool
    # chow-phaser       # Phaser effect
    
    # Additional tools ("other stuff")
    # plugdata          # Pure Data
    # aida-x            # AI amp modeling
    # grainbow          # Granular synthesis
  ]);

}
