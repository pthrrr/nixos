{ config, pkgs, agenix, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/optional/gaming.nix  # Import the shared gaming module
    ../../modules/optional/hdr.nix
    ../../modules/optional/ollama.nix
    ../../modules/optional/openrazer.nix

  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";  

  networking.hostName = "nixOS-desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Configure console keymap
  console.keyMap = "de";

  # Enable OpenSSH (provides SSH keys automatically)
  services.openssh.enable = true;

  age.identityPaths = [ "/home/pthr/.ssh/pthr" ];

  # Add the agenix secrets 
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "ntsync" ];

  # Desktop-specific hardware settings
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        libva
        # Video acceleration
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
        # Vulkan support
        vulkan-loader
      ];
      # Enable 32-bit support for gaming
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
        vulkan-loader
      ];
    };
  };

  environment.sessionVariables = {
    # Force VA-API driver
    LIBVA_DRIVER_NAME = "radeonsi";
    # Enable VDPAU
    VDPAU_DRIVER = "radeonsi";
    # ROCm/HIP support
    HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    # AMD Vulkan
    AMD_VULKAN_ICD = "RADV";
    # Proton / HDR
    PROTON_ADD_CONFIG = "fsr4rdna3";
    PROTON_ENABLE_HDR = "1";
    DXVK_HDR = "1";
    # Shader cache
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
    # Performance: GL thread offloading and RADV optimisations
    mesa_glthread = "true";
    RADV_PERFTEST = "gpl,ngg_streamout,rt";
  };
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # PipeWire base configuration
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/99-custom.conf" ''
        context.properties = {
          default.clock.rate = 48000
          default.clock.quantum = 256
          default.clock.min-quantum = 64
          default.clock.max-quantum = 1024
        }
      '')
    ];

    # Scarlett 2i2 Gen3: auto-set as default device with higher priority
    wireplumber.extraConfig."50-scarlett" = {
      "monitor.alsa.rules" = [{
        matches = [{ "node.name" = "~alsa_.*Scarlett.*"; }];
        actions.update-props = {
          "node.description" = "Scarlett 2i2";
          "priority.session" = 2000;
          "priority.driver" = 2000;
        };
      }];
    };

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable GVFS for better desktop integration
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Desktop-specific services
  services = {
    xserver = {
      xkb.layout = "de";
      enable = true;
      videoDrivers = [ "amdgpu" ];  # AMD GPU driver
    };
  };

  services.udev.extraRules = ''
    KERNEL=="card[0-9]*", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="auto"
    
    # Allow browser (WebHID) access to Ducky One X Mini Wireless
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3233", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3233", MODE="0666"
  '';

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pthr";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # AMD GPU management (undervolting, fan curves, power profiles)
  programs.corectrl.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  # AMD-specific gaming overrides (supplements shared gaming.nix)
  programs.gamemode.settings.gpu = {
    apply_gpu_optimisations = "accept-responsibility";
    gpu_device = 0;
    amd_performance_level = "high";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    agenix.packages.x86_64-linux.default

    # GPU monitoring/testing tools
    radeontop
    gpu-viewer
    clinfo
    mesa-demos
    libva-utils
    vulkan-tools

    # Video tools with GPU acceleration
    ffmpeg-full  # Includes VA-API support
    mpv          # Hardware-accelerated video player

    pavucontrol    # GUI audio control
    crosspipe
    qpwgraph       # Advanced PipeWire graph manager
  ];

  # Optimize for low-latency audio
  security.rtkit.enable = true;
    systemd.user.settings.Manager.DefaultLimitNOFILE = "524288:1048576";
    security.pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "soft"; value = "524288"; }
      { domain = "*"; item = "nofile"; type = "hard"; value = "1048576"; }
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
  ];

    # Add your user to audio group
  users.users.pthr = {  # Replace with your username
    extraGroups = [ "audio" "realtime" "corectrl" ];
  };

  # Add to your configuration
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;           # Reduce swapping for better real-time performance
    "kernel.sched_rt_runtime_us" = -1;  # Allow unlimited RT scheduling
  };

  # Low-latency kernel parameters
  boot.kernelParams = [ 
    "threadirqs" 
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.dpm=1"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
