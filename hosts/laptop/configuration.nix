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
  boot.loader.timeout = 1;  # 1 second boot menu (press key to pause)
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Preserve VRAM on hibernate
    "nmi_watchdog=0"                                 # Disable NMI watchdog (saves power)
    "resume=/dev/disk/by-uuid/578f1365-c5a0-44a6-9216-2889c20320ed"  # Resume from hibernate (root partition with swapfile)
    "resume_offset=74092544"                         # Physical offset of /var/lib/swapfile
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/578f1365-c5a0-44a6-9216-2889c20320ed";

  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
    "vm.swappiness" = 10;
    "vm.max_map_count" = 2147483642;
    "vm.compaction_proactiveness" = 0;
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

  # Keep graphics simple — no extraPackages that might interfere with suspend
  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Preserve VRAM on suspend — required for reliable resume
    powerManagement.enable = true;

    # Fine-grained power management off (can interfere with PRIME Sync suspend)
    powerManagement.finegrained = false;

    # Proprietary modules (worked for suspend, open modules didn't help)
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME Sync — NVIDIA drives all displays (required for external monitor)
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

  # Sleep/Hibernate configuration
  # Suspend-to-RAM doesn't work with NVIDIA PRIME Sync on this hardware,
  # so we use hibernate (suspend-to-disk) instead.
  # "platform" uses ACPI S4 — firmware powers off directly after image write,
  # bypassing userspace shutdown where NVIDIA would hang.
  systemd.sleep.settings.Sleep = {
    HibernateMode = "platform";
  };

  # Lid close / power button → hibernate
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandlePowerKey = "hibernate";
    IdleAction = "hibernate";
    IdleActionSec = "30min";
  };

  # System-level power management
  powerManagement.enable = true;

  # Reduce hibernate image size: default is 2/5 of RAM (~6.4GB).
  # Smaller image = faster write + faster resume. The kernel drops
  # disk caches first, so active data is preserved.
  systemd.services."hibernate-image-size" = {
    description = "Set hibernate image size to minimum";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 0 > /sys/power/image_size'";
      RemainAfterExit = true;
    };
  };

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

  # Only run nix garbage collection when on AC power
  systemd.services.nix-gc.unitConfig.ConditionACPower = true;

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
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
