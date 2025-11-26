{ config, pkgs, ... }:

let
  stripNL   = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
in
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  systemd.services.matchering = {
    description = "Matchering Audio Mastering Service";
    after = [ "network.target" "podman.service" ];
    requires = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm -f matchering";
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm --name matchering \
          -p 8360:8360 \
          -v /mnt/nvme/users/${username1}/data/Matchering/service:/app/data \
          sergree/matchering-web
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop matchering";
    };
  };
}
