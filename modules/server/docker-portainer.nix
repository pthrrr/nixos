{
  virtualisation.docker.enable = true;

  users.users.pthr.extraGroups = [ "docker" ];

  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:latest";
      ports = [
        "9000:9000"   # HTTP web UI
        "9443:9443"   # HTTPS web UI (optional)
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "portainer_data:/data"
      ];
      restartPolicy = "unless-stopped";
    };
  };

  networking.firewall.allowedTCPPorts = [ 9000 9443 ];
}
