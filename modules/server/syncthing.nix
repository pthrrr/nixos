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
    owner = "syncthing";
    mode = "0400";
  };

  # Create syncthing user and add it to the copyparty group
  users.groups.syncthing = {};
  users.users.syncthing = {
    isSystemUser = true;
    group = "syncthing";
    extraGroups = [ "copyparty" ];
    home = "/var/lib/syncthing";
    createHome = true;
  };

  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";

    dataDir = "/var/lib/syncthing";
    configDir = "/var/lib/syncthing/.config/syncthing";
    
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    
    overrideDevices = false;
    overrideFolders = false;
    
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
          versioning = {
            type = "simple";
            params = { keep = "20"; };
          };
        };
      };
    };    
  };
}
