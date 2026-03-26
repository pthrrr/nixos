# modules/server/monitoring.nix
{ config, pkgs, ... }:
{
  # --- agenix Secrets (oberste Ebene!) ---
  age.secrets.grafana-admin-password = {
    file = ../../secrets/password1.age;
    owner = "grafana";
  };

  age.secrets.grafana-secret-key = {
    file = ../../secrets/password1.age;
    owner = "grafana";
  };

  age.secrets.grafana-admin-user = {
    file = ../../secrets/username1.age;
    owner = "grafana";
  };

  # --- Prometheus ---
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "blocky";
        static_configs = [{
          targets = [ "127.0.0.1:4000" ];
        }];
      }
      {
        job_name = "node";
        static_configs = [{
          targets = [ "127.0.0.1:9100" ];
        }];
      }
    ];
  };

  # --- Node Exporter ---
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
      "processes"
      "filesystem"
      "diskstats"
      "meminfo"
      "netdev"
      "cpu"
      "loadavg"
    ];
  };

  # --- Grafana ---
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "localhost";
      };
      security = {
        admin_user = "$__file{/run/agenix/grafana-admin-user}";
        admin_password = "$__file{/run/agenix/grafana-admin-password}";
        secret_key = "$__file{/run/agenix/grafana-secret-key}";
      };
      panels = {
        disable_sanitize_html = true;
      };
    };

    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
    };
  };
}
