# modules/server/ntfy.nix
#
# Push-Notification-Server für Backup-Alerts, Monitoring, HA-Events etc.
# Web UI + API über Caddy: https://ntfy.$DOMAIN
# Intern: 127.0.0.1:2586
#
{ config, pkgs, ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:2586";
      # base-url wird nicht gesetzt (enthält Domain = Secret)
      # Funktioniert ohne base-url für Push-Notifications via curl/App
      # Falls nötig: Runtime-Injection analog zu caddy.nix
    };
  };
}
