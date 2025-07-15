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
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      DOMAIN=$(cat ${config.age.secrets.domain.path})
      
      cat > /var/lib/caddy/Caddyfile << EOF
      {
        email pthr+acme@$DOMAIN
      }
      
      ha.$DOMAIN {
        tls {
          dns namecheap {
            user {env.NAMECHEAP_API_USER}
            api_key {env.NAMECHEAP_API_KEY}
          }
        }
        reverse_proxy localhost:8123
      }
      
      $DOMAIN {
        tls {
          dns namecheap {
            user {env.NAMECHEAP_API_USER}
            api_key {env.NAMECHEAP_API_KEY}
          }
        }
        redir https://ha.$DOMAIN{uri}
      }
      EOF
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
