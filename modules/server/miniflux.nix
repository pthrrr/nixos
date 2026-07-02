# modules/server/miniflux.nix
{ config, pkgs, ... }:
{
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.password1.file = ../../secrets/password1.age;
  age.secrets.domain.file = ../../secrets/domain.age;

  systemd.services.miniflux-credentials = {
    description = "Generate Miniflux admin credentials";
    before = [ "miniflux.service" ];
    after = [ "agenix.service" ];
    wants = [ "agenix.service" ];
    wantedBy = [ "multi-user.target" ];

    # Kein RemainAfterExit: Service läuft vor JEDEM miniflux-Start neu und
    # regeneriert die Credentials-Datei. Ablage in eigenem Verzeichnis
    # /run/miniflux-credentials (NICHT /run/miniflux, da systemd das als
    # RuntimeDirectory von miniflux.service beim Stop/Start leert).
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      USERNAME=$(cat ${config.age.secrets.username1.path} | tr -d '\n')
      PASSWORD=$(cat ${config.age.secrets.password1.path} | tr -d '\n')
      DOMAIN=$(cat ${config.age.secrets.domain.path} | tr -d '\n')

      mkdir -p /run/miniflux-credentials
      cat > /run/miniflux-credentials/admin-credentials <<CREDENTIALS
ADMIN_USERNAME=$USERNAME
ADMIN_PASSWORD=$PASSWORD
BASE_URL=https://miniflux.$DOMAIN
CREDENTIALS

      chmod 600 /run/miniflux-credentials/admin-credentials
    '';
  };

  systemd.services.miniflux = {
    after = [ "miniflux-credentials.service" ];
    requires = [ "miniflux-credentials.service" ];
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/run/miniflux-credentials/admin-credentials";

    config = {
      LISTEN_ADDR = "localhost:8080";
      POLLING_FREQUENCY = 60;
      CLEANUP_ARCHIVE_READ_DAYS = 14;
      CLEANUP_ARCHIVE_UNREAD_DAYS = 30;
      POLLING_PARSING_ERROR_LIMIT = 0;  # Never auto-disable feeds on errors
      CREATE_ADMIN = 1;
      RUN_MIGRATIONS = 1;
    };
  };
}
