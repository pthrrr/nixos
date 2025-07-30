{ config, pkgs, lib, agenix, ... }:
let
  username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
  username2 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username2.path);
in
{
  age.secrets.password1 = {
    file = ../../secrets/password1.age;
    owner = "copyparty";
    mode = "0400";
  };
  
  age.secrets.password2 = {
    file = ../../secrets/password2.age;
    owner = "copyparty";
    mode = "0400";
  };

  services.copyparty = {
    enable = true;
    
    # Global settings
    settings = {
      # Listen on all interfaces
      i = "0.0.0.0";
      # Use default copyparty ports
      p = 3210;
      
      # Enable FTP access on default port
      #ftp = "0.0.0.0:2121";
      
      # Enable multimedia indexing and thumbnails
      e2t = true;
      e2ts = true;
      
      # Enable deduplication database
      e2d = true;
      
      # Enable file hashing with multiple threads
      hash-mt = 4;
      
      # Disable automatic config reload
      no-reload = true;
    };
    
    # Create user accounts
    accounts = {
      # Admin user (username1)
      ${username1} = {
        passwordFile = config.age.secrets.password1.path;
      };
      
      # Regular user (username2)
      ${username2} = {
        passwordFile = config.age.secrets.password2.path;
      };
    };
    
    # Configure volumes (equivalent to Samba shares)
    volumes = {
      # Admin's personal directory
      "/${username1}" = {
        path = "/mnt/nvme/users/${username1}";
        
        # Access permissions
        access = {
          # Only username1 has full access
          rwd = username1;
        };
        
        # Volume flags
        flags = {
          # Enable file keys for sharing
          fk = 4;
          # Scan for new files every 5 minutes
          scan = 300;
          # Enable uploads database
          e2d = true;
          # Enable multimedia indexing
          e2t = true;
        };
      };
      
      # User2's personal directory
      "/${username2}" = {
        path = "/mnt/nvme/users/${username2}";
        
        access = {
          # Only username2 has full access
          rwd = username2;
          # Admin can also access (since they're admin)
          r = username1;
        };
        
        flags = {
          fk = 4;
          scan = 300;
          e2d = true;
          e2t = true;
        };
      };
      
      # Shared area accessible by both users
      "/shared" = {
        path = "/mnt/nvme/shared";
        
        access = {
          # Both users have read-write access
          rwd = [ username1 username2 ];
        };
        
        flags = {
          fk = 4;
          scan = 300;
          e2d = true;
          e2t = true;
        };
      };
      
      # Public read-only area (optional)
      "/public" = {
        path = "/mnt/nvme/public";
        
        access = {
          # Everyone can read
          r = "*";
          # Only admin can write
          rwd = username1;
        };
        
        flags = {
          fk = 4;
          scan = 300;
          e2d = true;
        };
      };
    };
    
    # Increase open files limit for better performance
    openFilesLimit = 8192;
  };
}
