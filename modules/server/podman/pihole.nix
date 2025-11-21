{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/udp"
      "53:53/tcp"
      "8080:80/tcp"
    ];
    environment = {
      TZ = "Europe/Berlin";
    };
    volumes = [
      "/var/lib/pihole/etc-pihole:/etc/pihole"
      "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 53 8080 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
