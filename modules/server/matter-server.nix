{ config, pkgs, ... }:
{
  services.matter-server = {
    enable = true;
    port = 5580;
  };

  # Open required ports for Matter communication
  networking.firewall = {
    allowedTCPPorts = [ 5580 ];  # Matter server
    allowedUDPPorts = [ 
      5540   # Matter operational port
      5353   # mDNS
    ];
    # Enable multicast for mDNS discovery
    extraCommands = ''
      iptables -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
      iptables -A INPUT -d 224.0.0.251/32 -j ACCEPT
      iptables -A INPUT -d ff02::fb/128 -j ACCEPT
    '';
  };
}
