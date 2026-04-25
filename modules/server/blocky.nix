# modules/server/blocky.nix
{ config, pkgs, ... }:
{
  age.secrets.domain = {
    file = ../../secrets/domain.age;
  };

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
ports:
  dns: 53
  http: 4000

upstreams:
  groups:
    default:
      - tcp-tls:1.1.1.1:853
      - tcp-tls:1.0.0.1:853
      - tcp-tls:9.9.9.9:853

bootstrapDns:
  - tcp+udp:1.1.1.1
  - tcp+udp:9.9.9.9

clientLookup:
  upstream: 192.168.10.1
  singleNameOrder:
    - 1

customDNS:
  mapping:
    $DOMAIN: 192.168.10.100
    blocky.$DOMAIN: 192.168.10.100
    ha.$DOMAIN: 192.168.10.100
    radicale.$DOMAIN: 192.168.10.100
    copyparty.$DOMAIN: 192.168.10.100
    syncthing.$DOMAIN: 192.168.10.100
    matchering.$DOMAIN: 192.168.10.100
    grafana.$DOMAIN: 192.168.10.100
    shelly1.$DOMAIN: 192.168.10.100
    shellyplug.$DOMAIN: 192.168.10.100
    miniflux.$DOMAIN: 192.168.10.100
    fmd.$DOMAIN: 192.168.10.100
    ai.$DOMAIN: 192.168.10.100
    desktop.$DOMAIN: 192.168.10.254
    desktop: 192.168.10.254
    esphome.$DOMAIN: 192.168.10.100

blocking:
  denylists:
    ads:
      # StevenBlack unified + fakenews + gambling + porn + social
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts
    hagezi:
      # Hagezi Multi Pro - Maximum Protection
      - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt
  allowlists:
    default:
      - reddit.com
      - www.reddit.com
      - old.reddit.com
  clientGroupsBlock:
    default:
      - ads
      - hagezi
  blockType: zeroIp
  blockTTL: 1m
  loading:
    refreshPeriod: 24h
    downloads:
      timeout: 60s
      attempts: 3

caching:
  minTime: 5m
  maxTime: 30m
  prefetching: true

conditional:
  mapping:
    fritz.box: 192.168.10.1
    10.168.192.in-addr.arpa: 192.168.10.1

log:
  level: info

prometheus:
  enable: true
  path: /metrics
EOF

      echo "Blocky config generated successfully"
    '';
  };

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

      DynamicUser = true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
