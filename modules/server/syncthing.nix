{ config, pkgs, lib, ... }:
let
  stripNL   = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
in
{
  # Declare the secrets this module needs
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;
 
  age.secrets.syncthing = {
    file = ../../secrets/syncthing.age;
    owner = "media";
    mode = "0400";
  };

  # Create media user for copyparty and syncthing
  users.groups.media = {};
  users.users.media = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/media";
    createHome = true;
  };

  services.syncthing = {
    enable = true;
    user = "media";
    group = "media";

    dataDir = "/var/lib/media/syncthing";
    configDir = "/var/lib/media/syncthing/.config/syncthing";
    
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    
    overrideDevices = false;
    overrideFolders = true;
    
    settings = {
      gui = {
        enabled = true;
        theme = "default";
        user = "${username1}";
        password = stripNL (builtins.readFile config.age.secrets.syncthing.path);
      };
      
      options = {
        urAccepted = -1;
        relaysEnabled = true;
        localAnnounceEnabled = true;
        globalAnnounceEnabled = true;
        limitBandwidthInLan = false;
        setLowPriority = false;
      };
      
      folders = {
        "${username1}-keepass" = {
          id = "${username1}-keepass";
          label = "${username1} KeePass";
          path = "/mnt/nvme/users/${username1}/keepass";
          type = "sendreceive";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.kdbx-*-*.kdbx"  # Ignore KeePass backup files
          ];
          versioning = {
            type = "simple";
            params = { keep = "20"; };
          };
        };
        
        "${username2}-keepass" = {
          id = "${username2}-keepass";
          label = "${username2} KeePass";
          path = "/mnt/nvme/users/${username2}/keepass";
          type = "sendreceive";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.kdbx-*-*.kdbx"  # Ignore KeePass backup files
          ];
          versioning = {
            type = "simple";
            params = { keep = "20"; };
          };
        };

        "${username1}-photos" = {
          id = "${username1}-photos";
          label = "${username1} Photos";
          path = "/mnt/nvme/photos/${username1}/pixel_7a";
          type = "receiveonly";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.tmp"
            "*.partial"
            ".thumbnails/"
            "Thumbs.db"
            ".DS_Store"
          ];
          versioning = {
            type = "simple";
            params = { keep = "5"; };
          };
        };

        "${username2}-photos" = {
          id = "${username2}-photos";
          label = "${username2} Photos";
          path = "/mnt/nvme/photos/${username2}/pixel_8";
          type = "receiveonly";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.tmp"
            "*.partial"
            ".thumbnails/"
            "Thumbs.db"
            ".DS_Store"
          ];
          versioning = {
            type = "simple";
            params = { keep = "5"; };
          };
        };

        "${username1}-data" = {
          id = "${username1}-data";
          label = "${username1} Data";
          path = "/mnt/nvme/users/${username1}/data/pixel_7a";
          type = "sendreceive";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.tmp"
            "*.partial"
            ".sync-conflict-*"
            "Thumbs.db"
            ".DS_Store"
          ];
          versioning = {
            type = "simple";
            params = { keep = "10"; };
          };
        };

        "${username2}-data" = {
          id = "${username2}-data";
          label = "${username2} Data";
          path = "/mnt/nvme/users/${username2}/data/pixel_8";
          type = "sendreceive";
          rescanIntervalS = 60;
          fsWatcherEnabled = true;
          ignorePerms = true;
          ignorePatterns = [ 
            "*.tmp"
            "*.partial"
            ".sync-conflict-*"
            "Thumbs.db"
            ".DS_Store"
          ];
          versioning = {
            type = "simple";
            params = { keep = "10"; };
          };
        };
      };
    };    
  };
}
