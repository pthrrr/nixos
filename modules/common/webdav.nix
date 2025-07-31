{ config, pkgs, lib, ... }:
let
  username1 = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.username1.path);
  domain = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.domain.path);
in
{
  # Install rclone
  environment.systemPackages = [ pkgs.rclone ];
  
  # Create mount points
  systemd.tmpfiles.rules = [
    "d /mnt/webdav/${username1} 0755 ${username1} users -"
    "d /mnt/webdav/shared 0755 ${username1} users -"
  ];
  
  # Mount for username1
  systemd.services."webdav-mount-${username1}" = {
    description = "Mount WebDAV for ${username1}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "notify";
      User = username1;
      Group = "users";
      
      ExecStartPre = pkgs.writeShellScript "setup-rclone-${username1}" ''
        export HOME=/tmp
        mkdir -p /tmp/.config/rclone
        ${pkgs.rclone}/bin/rclone config create copyparty-${username1} webdav \
          url=https://copyparty.${domain}/${username1} \
          vendor=owncloud \
          user=${username1} \
          pass=$(${pkgs.rclone}/bin/rclone obscure $(cat ${config.age.secrets.password1.path}))
      '';
      
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount copyparty-${username1}: /mnt/webdav/${username1} \
          --config=/tmp/.config/rclone/rclone.conf \
          --vfs-cache-mode=writes \
          --dir-cache-time=5s \
          --daemon-wait=60s \
          --allow-other
      '';
      
      ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/webdav/${username1}";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
  
  # Mount shared folder (accessible by username1)
  systemd.services.webdav-mount-shared = {
    description = "Mount WebDAV shared folder";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "notify";
      User = username1;
      Group = "users";
      
      ExecStartPre = pkgs.writeShellScript "setup-rclone-shared" ''
        export HOME=/tmp
        mkdir -p /tmp/.config/rclone
        ${pkgs.rclone}/bin/rclone config create copyparty-shared webdav \
          url=https://copyparty.${domain}/shared \
          vendor=owncloud \
          user=${username1} \
          pass=$(${pkgs.rclone}/bin/rclone obscure $(cat ${config.age.secrets.password1.path}))
      '';
      
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount copyparty-shared: /mnt/webdav/shared \
          --config=/tmp/.config/rclone/rclone.conf \
          --vfs-cache-mode=writes \
          --dir-cache-time=5s \
          --daemon-wait=60s \
          --allow-other
      '';
      
      ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/webdav/shared";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
