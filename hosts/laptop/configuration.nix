{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/optional/gaming.nix
    #../../modules/optional/music-production.nix
    ../../modules/optional/vm.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "mem_sleep_default=deep"                      # Use S3 deep sleep (most reliable for NVIDIA)
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve VRAM on suspend
    "i915.enable_fbc=1"                            # Intel framebuffer compression
    "i915.enable_psr=1"                            # Intel panel self-refresh
    "nmi_watchdog=0"                               # Disable NMI watchdog (saves power)
  ];

  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
    "vm.swappiness" = 10;                    # Prefer keeping game data in RAM
    "vm.max_map_count" = 2147483642;         # Required by many modern games/Proton
    "vm.compaction_proactiveness" = 0;       # Reduce background memory compaction stalls
  };

  networking.hostName = "nixOS-laptop"; # Define your hostname.
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

  users.users.pthr.extraGroups = [ "dialout" "uucp" "adbusers" "kvm" ]; # arduino IDE

  # Enable OpenSSH (provides SSH keys automatically)
  services.openssh.enable = true;

  age.identityPaths = [ "/home/pthr/.ssh/pthr" ]; 

  # Add the agenix secrets
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ 
    pkgs.brlaser          # Brother laser printers
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver          # Hardware video decode
      vulkan-loader
      vulkan-validation-layers
      libvdpau-va-gl               # VDPAU via VA-API
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader                # 32-bit Vulkan for Proton/Wine games
    ];
  };

  # NVIDIA environment variables -- only for user sessions, not display manager
  # Use environment.variables for non-session-critical settings only
  environment.variables = {
    NVD_BACKEND = "direct";
    VDPAU_DRIVER = "nvidia";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_GSYNC_ALLOWED = "1";
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Hybrid graphics with PRIME
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

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

    # Low-latency audio for gaming (~5ms instead of ~21ms default)
    extraConfig.pipewire = {
      "99-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 1024;
        };
      };
    };
  };

  # Enable GVFS for better desktop integration
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # enable flatpak
  services.flatpak.enable = true;

  # Laptop-specific services
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver = {
      xkb.layout = "de";
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    # Touchpad support
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };

services.udev.extraRules = ''
  # Allow browser (WebHID) access to Ducky One X Mini Wireless
  SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3233", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="3233", MODE="0666"
'';

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "pthr";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Sleep/Suspend configuration
  systemd.sleep.settings.Sleep = {
    SuspendState = "mem";
    SuspendMode = "suspend";
  };

  # Lid close / power button behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "30min";
  };

  # System-level power management
  powerManagement.enable = true;

  # GNOME power profile integration (Power Saver / Balanced / Performance)
  services.power-profiles-daemon.enable = true;

  # Compressed in-memory swap (prevents OOM kills, no disk I/O)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Intel thermal management daemon
  services.thermald.enable = true;

  # Firmware update daemon (UEFI/EC updates from LVFS)
  services.fwupd.enable = true;

  # Bluetooth (off at boot, enable manually when needed)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # NVIDIA-specific GameMode overrides (supplements shared gaming.nix)
  programs.gamemode.settings = {
    general = {
      softrealtime = "auto";
      ioprio = 0;
      inhibit_screensaver = 1;
    };
    gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
      nv_powermizer_mode = 1;    # Force max GPU clocks during gaming
    };
    custom = {
      start = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
      end = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
    };
  };

  # Only run nix garbage collection when on AC power
  systemd.services.nix-gc.serviceConfig.ConditionACPower = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    android-tools
    xbacklight
    powertop             # Power consumption analyzer
    nvtopPackages.nvidia # GPU monitoring
    vulkan-tools         # vulkaninfo, vkcube
    mesa-demos           # glxgears, glxinfo
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
