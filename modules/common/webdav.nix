{ config, pkgs, lib, ... }:
{
  # Declare the secrets this module needs
  age.secrets.domain = {
    file = ../../secrets/domain.age;
  };
  
  age.secrets.username1 = {
    file = ../../secrets/username1.age;
  };
  
  age.secrets.password1 = {
    file = ../../secrets/password1.age;
    mode = "0400";
  };

  # Install rclone
  environment.systemPackages = [ pkgs.rclone ];
  
  # Mount for username1's personal directory
  systemd.services.webdav-mount-user1 = {
    description = "Mount WebDAV";
    after = [ "network-online.target" "agenix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    script = ''
      # Read secrets at runtime
      USERNAME=$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets.username1.path})
      DOMAIN=$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets.domain.path})
      PASSWORD=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.password1.path})
      
      # Create mount point
      ${pkgs.coreutils}/bin/mkdir -p /media/BigData/$USERNAME
      ${pkgs.coreutils}/bin/chown 1000:100 /media/BigData/$USERNAME || true
      
      # Create temporary rclone config
      export HOME=/tmp
      ${pkgs.coreutils}/bin/mkdir -p /tmp/.config/rclone
      
      ${pkgs.rclone}/bin/rclone config create copyparty-$USERNAME webdav \
        url=https://copyparty.$DOMAIN/$USERNAME \
        vendor=owncloud \
        user=$USERNAME \
        pass=$(${pkgs.rclone}/bin/rclone obscure "$PASSWORD")
      
      # Mount with rclone
      ${pkgs.rclone}/bin/rclone mount copyparty-$USERNAME: /media/BigData/$USERNAME \
        --config=/tmp/.config/rclone/rclone.conf \
        --vfs-cache-mode=writes \
        --dir-cache-time=5s \
        --daemon \
        --allow-other \
        --uid=1000 \
        --gid=100
    '';
    
    serviceConfig = {
      Type = "forking";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    
    preStop = ''
      USERNAME=$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets.username1.path})
      ${pkgs.fuse}/bin/fusermount -u /media/BigData/$USERNAME || true
    '';
  };
}
