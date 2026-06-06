{ config, pkgs, lib, ... }:
{

  imports = [
    ./applications/dconf.nix
    ./applications/vscodium.nix
  ];

  home.username = "pthr";
  home.homeDirectory = "/home/pthr";
  home.stateVersion = "22.05";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Brave with VA-API hardware video decode (enables HEVC playback)
    (symlinkJoin {
      name = "brave-vaapi";
      paths = [ brave ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/brave \
          --add-flags "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder"
      '';
    })
    zed-editor
    keepassxc
    signal-desktop
    telegram-desktop
    freetube
    vlc
    spotify
    kdePackages.kdenlive
    godot_4
  ];

  programs.git = {
    enable = true;
    settings.user.name = "pthrrr";
    # settings.user.email = "your@email.com";
    signing.format = "openpgp";
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };

  # Install kitty terminal.
  programs.kitty.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "discord"
      "teamspeak3"
      "bitwig-studio-unwrapped"
      "bitwig-studio"
  ];
}
