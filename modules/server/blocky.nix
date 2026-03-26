# modules/server/blocky.nix
{ config, pkgs, ... }:
{
  # Domain secret wird auch in caddy.nix referenziert,
  # doppelte Deklaration ist in NixOS idempotent
  age.secrets.domain = {
    file = ../../secrets/domain.age;
  };

  # Config wird zur Laufzeit generiert (agenix Secret)
  systemd.services.blocky-config = {
    description = "Generate Blocky configuration";
    before = [ "blocky.service" ];
    after = [ "agenix.service" "network-online.target" ];
    wants = [ "agenix.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      DOMAIN=$(cat ${config.age.secrets.domain.path} | tr -d '\n')

      mkdir -p /etc/blocky

      cat > /etc/blocky/config.yml << EOF
      # ===========================================
      # Blocky DNS Configuration
      # ===========================================

      # --- Ports ---
      # Testphase: 5353 (Pi-hole bleibt auf 53)
      # Produktion: auf 53 umstellen
      ports:
        dns: 5335
        http: 4000

      # --- Upstream DNS (DoT) ---
      upstreams:
        groups:
          default:
            - tcp-tls:1.1.1.1:853
            - tcp-tls:1.0.0.1:853
            - tcp-tls:9.9.9.9:853

      bootstrapDns:
        - tcp+udp:1.1.1.1
        - tcp+udp:9.9.9.9

      # --- Lokale DNS-Einträge ---
      # Alle Subdomains → Server IP (kein Hairpin NAT nötig)
      customDNS:
        mapping:
          $DOMAIN: 192.168.10.100
          ha.$DOMAIN: 192.168.10.100
          radicale.$DOMAIN: 192.168.10.100
          copyparty.$DOMAIN: 192.168.10.100
          syncthing.$DOMAIN: 192.168.10.100
          rss.$DOMAIN: 192.168.10.100
          matchering.$DOMAIN: 192.168.10.100
          shelly1.$DOMAIN: 192.168.10.201
          shellyplug.$DOMAIN: 192.168.10.200

      # --- Ad-Blocking ---
      blocking:
        denylists:
          ads:
            - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
        clientGroupsBlock:
          default:
            - ads

      # --- Caching ---
      caching:
        minTime: 5m
        maxTime: 30m
        prefetching: true

      # --- Conditional Forwarding ---
      # Lokale Gerätenamen via FritzBox auflösen
      conditional:
        mapping:
          fritz.box: 192.168.10.1
          10.168.192.in-addr.arpa: 192.168.10.1

      # --- Logging ---
      log:
        level: info
      EOF

      echo "Blocky config generated successfully"
    '';
  };

  # Blocky Service
  systemd.services.blocky = {
    description = "Blocky DNS proxy";
    after = [ "blocky-config.service" "network-online.target" ];
    requires = [ "blocky-config.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.blocky}/bin/blocky --config /etc/blocky/config.yml";
      Restart = "on-failure";
      RestartSec = "5s";

      # Hardening
      DynamicUser = true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
