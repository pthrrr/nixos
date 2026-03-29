# modules/server/ntfy.nix
#
# Push-Notification-Server für Backup-Alerts, Monitoring, HA-Events etc.
# Web UI + API über Caddy: https://ntfy.$DOMAIN
# Intern: 127.0.0.1:2586
#
{ config, pkgs, ... }:
{
  # Config wird zur Laufzeit generiert (Domain ist agenix-Secret).
  # ExecStartPre läuft als root (liest Secret, schreibt Config),
  # ntfy selbst läuft als ntfy-sh.

  systemd.services.ntfy-sh = {
    description = "ntfy push notification server";
    after = [ "agenix.service" "network.target" ];
    wants = [ "agenix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = let
        configScript = pkgs.writeShellScript "ntfy-config" ''
          DOMAIN=$(cat ${config.age.secrets.domain.path})
          mkdir -p /var/lib/ntfy-sh
          cat > /var/lib/ntfy-sh/server.yml << EOF
          listen-http: "127.0.0.1:2586"
          base-url: "https://ntfy.$DOMAIN"
          cache-file: /var/lib/ntfy-sh/cache.db
          EOF
          chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/server.yml
          chmod 600 /var/lib/ntfy-sh/server.yml
        '';
      in "+${configScript}";  # + prefix = run as root
      ExecStart = "${pkgs.ntfy-sh}/bin/ntfy serve --config /var/lib/ntfy-sh/server.yml";
      User = "ntfy-sh";
      Group = "ntfy-sh";
      StateDirectory = "ntfy-sh";
      Restart = "on-failure";
    };
  };

  users.users.ntfy-sh = {
    isSystemUser = true;
    group = "ntfy-sh";
  };
  users.groups.ntfy-sh = {};
}
