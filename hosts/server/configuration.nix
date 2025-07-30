# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, agenix, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" ];
  # Ensure ACL support for ext4
  boot.supportedFilesystems = [ "ext4" ];

  # Static IP configuration
  networking = {
    hostName = "nixOS-server";
    
    # Disable DHCP globally
    useDHCP = false;
    
    # Configure your primary interface (enp4s0)
    interfaces.enp4s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.10.100";
        prefixLength = 24;           # /24 = 255.255.255.0
      }];
    };
    
    # Leave the second interface (enp5s0) unconfigured for now
    interfaces.enp5s0 = {
      useDHCP = false;
    };
    
    # Set default gateway (likely your router)
    defaultGateway = "192.168.10.1";
    
    # DNS servers
    nameservers = [ 
      "192.168.10.1" 
    ];
    
    # Disable NetworkManager for servers
    networkmanager.enable = false;
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 139 445 ];
      allowedUDPPorts = [ 137 138 ];
    };
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      AllowUsers = [ "pthr" ];
    };
  };

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account.
  users.users.pthr = {
    isNormalUser = true;
    description = "pthr";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
  };

  users.users.dataowner1 = {
    isSystemUser = true;
    description = "Data owner 1 (Admin)";
    group = "users";
    extraGroups = [ "wheel" ];
    uid = 1001;
  }; 

  users.users.dataowner2 = {
    isSystemUser = true;
    description = "Data owner 2";
    group = "users";
    uid = 1002;
  };

  age.identityPaths = [ "/home/pthr/.ssh/pthr" ];

  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  # Enable automatic login for the user.
  services.getty.autologinUser = "pthr";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     git
     tree
     samba
     cifs-utils
     mdadm
     curl
     hdparm
     agenix.packages.x86_64-linux.default
     acl
  ];

  # Fix mdadm warning
  boot.swraid.mdadmConf = ''
    MAILADDR root@localhost
    PROGRAM /run/current-system/sw/bin/logger
  '';

  # Setup ACLs for copyparty
  systemd.services.setup-copyparty-acls = {
    description = "Setup ACLs for copyparty";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];  # Wait for filesystems to be mounted
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
        username2 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username2.path);
      in pkgs.writeShellScript "setup-acls" ''
        # Wait a moment to ensure filesystem is ready
        sleep 2
        
        # Check if directories exist before setting ACLs
        if [ -d "/mnt/nvme/users/${username1}" ]; then
          ${pkgs.acl}/bin/setfacl -R -m u:copyparty:rwx /mnt/nvme/users/${username1}
          ${pkgs.acl}/bin/setfacl -R -d -m u:copyparty:rwx /mnt/nvme/users/${username1}
        fi
        
        if [ -d "/mnt/nvme/users/${username2}" ]; then
          ${pkgs.acl}/bin/setfacl -R -m u:copyparty:rwx /mnt/nvme/users/${username2}
          ${pkgs.acl}/bin/setfacl -R -d -m u:copyparty:rwx /mnt/nvme/users/${username2}
        fi
        
        if [ -d "/mnt/nvme/shared" ]; then
          ${pkgs.acl}/bin/setfacl -R -m u:copyparty:rwx /mnt/nvme/shared
          ${pkgs.acl}/bin/setfacl -R -d -m u:copyparty:rwx /mnt/nvme/shared
        fi
        
        if [ -d "/mnt/nvme/public" ]; then
          ${pkgs.acl}/bin/setfacl -R -m u:copyparty:rwx /mnt/nvme/public
          ${pkgs.acl}/bin/setfacl -R -d -m u:copyparty:rwx /mnt/nvme/public
        fi
      '';
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
