# modules/server/monitoring.nix
{ config, pkgs, ... }:
{
  # --- Prometheus ---
  services.prometheus = {
    enable = true;
    port = 9090;
    
    # Metriken-Quellen
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

  # --- Node Exporter (System-Metriken) ---
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
      age.secrets.grafana-admin-password = {
        file = ../../secrets/password1.age;
        owner = "grafana";
      };
    };

    # Prometheus als Datenquelle automatisch einrichten
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
