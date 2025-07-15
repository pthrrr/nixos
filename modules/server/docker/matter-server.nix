{
  virtualisation.oci-containers.containers = {
    matter-server = {
      image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
      ports = [ "5580:5580" ];
      volumes = [
        "matter_server_data:/data"
      ];
      # For Thread support, you may need to add a bind mount for /run/dbus
      # volumes = [
      #   "matter_server_data:/data"
      #   "/run/dbus:/run/dbus:ro"
      # ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 5580 ];
}
