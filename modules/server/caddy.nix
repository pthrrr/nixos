{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/namecheap@v0.0.0-20250228023406-ef9fadb67785" ];
      hash = "sha256-lETdtRL/IieIEufJGOaFguowgHNOEk6oR7418C1FlF4=";
    };
    
    configFile = "/var/lib/caddy/Caddyfile";
  };
  
  age.secrets.domain.file = ../../secrets/domain.age;
  age.secrets.namecheap-credentials.file = ../../secrets/namecheap-credentials.age;
  
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy 0755 caddy caddy -"
  ];
  
systemd.services.caddy-config = {
  description = "Generate Caddy configuration";
  before = [ "caddy.service" ];
  after = [ "agenix.service" ];
  wants = [ "agenix.service" ];
  wantedBy = [ "multi-user.target" ];
  
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    # Run as root to ensure we can read the secrets
    User = "root";
    Group = "root";
  };
  
  path = with pkgs; [ curl coreutils ];
  
  script = ''
    # Add debugging to see what's happening
    echo "Checking if domain secret exists..."
    if [ ! -f "${config.age.secrets.domain.path}" ]; then
      echo "ERROR: Domain secret file does not exist at ${config.age.secrets.domain.path}"
      exit 1
    fi
    
    echo "Reading domain from ${config.age.secrets.domain.path}"
    DOMAIN=$(cat ${config.age.secrets.domain.path})
    echo "Domain is: $DOMAIN"
    
    # Validate domain
    if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "eof" ]; then
      echo "ERROR: Invalid domain value: '$DOMAIN'"
      exit 1
    fi
    
    SERVER_IP=$(curl -s -4 icanhazip.com)
    echo "Server IP: $SERVER_IP"
    
    # Create Caddyfile with proper ownership
    cat > /var/lib/caddy/Caddyfile << EOF
    {
      email pthr+acme@$DOMAIN
    }
    
    ha.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      reverse_proxy localhost:8123
    }

    pihole.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      @root {
        path /
      }
      rewrite @root /admin/
      reverse_proxy localhost:8080
    }

    radicale.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      reverse_proxy localhost:5232
    }

    copyparty.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      reverse_proxy localhost:3210
    }

    shelly1.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      reverse_proxy 192.168.10.201
    }

    shellyplug.$DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      reverse_proxy 192.168.10.200
    }
    
    $DOMAIN {
      tls {
        dns namecheap {
          user {env.NAMECHEAP_API_USER}
          api_key {env.NAMECHEAP_API_KEY}
          client_ip $SERVER_IP
        }
      }
      redir https://ha.$DOMAIN{uri}
    }
    EOF
    
    # Set proper ownership for Caddy
    chown caddy:caddy /var/lib/caddy/Caddyfile
    chmod 644 /var/lib/caddy/Caddyfile
    
    echo "Caddyfile generated successfully"
  '';
  };
  
  systemd.services.caddy = {
    after = [ "caddy-config.service" ];
    requires = [ "caddy-config.service" ];
    serviceConfig = {
      EnvironmentFile = config.age.secrets.namecheap-credentials.path;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
