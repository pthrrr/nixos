{ config, pkgs, ... }:

{
  # Ensure DB directory exists with correct ownership (UID 1000 for Alpine image)
  systemd.tmpfiles.rules = [
    "d /data/containers/fmd 0755 1000 1000 -"
    "d /data/containers/fmd/db 0755 1000 1000 -"
  ];

  systemd.services.fmd-server = {
    description = "Find My Device Server";
    after = [ "network.target" "podman.service" ];
    requires = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm -f fmd-server";
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm --name fmd-server \
          --network=host \
          -e FMD_PORTINSECURE=8081 \
          -v /data/containers/fmd/db:/var/lib/fmd-server/db \
          --read-only \
          --cap-drop=all \
          --security-opt=no-new-privileges \
          registry.gitlab.com/fmd-foss/fmd-server:0.14.2-alpine
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop fmd-server";
    };
  };
}
