# modules/server/ntfy.nix
#
# Push-Notification-Server für Backup-Alerts, Monitoring, HA-Events etc.
# Web UI + API über Caddy: https://ntfy.$DOMAIN
# Intern: 127.0.0.1:2586
#
{ config, pkgs, ... }:
{
  # ntfy-sh wird NICHT über services.ntfy-sh konfiguriert,
  # da base-url die Domain enthält (Secret via agenix).
  # Stattdessen: Config zur Laufzeit generieren, analog zu caddy.nix.

  systemd.services.ntfy-sh = {
    description = "ntfy push notification server";
    after = [ "agenix.service" "network.target" ];
    wants = [ "agenix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = let
        configScript = pkgs.writeShellScript "ntfy-config" ''
          DOMAIN=$(cat ${config.age.secrets.domain.path})
          mkdir -p /etc/ntfy
          cat > /etc/ntfy/server.yml << EOF
          listen-http: "127.0.0.1:2586"
          base-url: "https://ntfy.$DOMAIN"
          EOF
        '';
      in "${configScript}";
      ExecStart = "${pkgs.ntfy-sh}/bin/ntfy serve --config /etc/ntfy/server.yml";
      User = "ntfy-sh";
      Group = "ntfy-sh";
      StateDirectory = "ntfy-sh";
      CacheDirectory = "ntfy-sh";
      Restart = "on-failure";
    };
  };

  users.users.ntfy-sh = {
    isSystemUser = true;
    group = "ntfy-sh";
  };
  users.groups.ntfy-sh = {};
}
