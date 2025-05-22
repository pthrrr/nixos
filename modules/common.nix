{ config, pkgs, ... }:
{
  imports = [ ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Disable XTerm
  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    tree
    neofetch
    git
    nixd
  ];

  # User-specific packages
  users.users.pthr.packages = with pkgs; [
    brave
    keepassxc
    vscodium
    freetube
    signal-desktop
    telegram-desktop
    vlc
  ];

  # Exclude specific GNOME applications
  environment.gnome.excludePackages = with pkgs; [
    totem
    epiphany
    gnome-weather
    gnome-maps
    gnome-music
    gnome-calendar
    gnome-calculator
    gnome-text-editor
    gnome-contacts
    gnome-photos
    gnome-logs
    gnome-tour
    snapshot
    gedit
    simple-scan
    yelp
    geary
  ];

  # Install firefox.
  programs.firefox.enable = false;

  # Disable bluetooth
  hardware.bluetooth.enable = false;
}
