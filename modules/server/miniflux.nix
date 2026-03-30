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

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      USERNAME=$(cat ${config.age.secrets.username1.path} | tr -d '\n')
      PASSWORD=$(cat ${config.age.secrets.password1.path} | tr -d '\n')
      DOMAIN=$(cat ${config.age.secrets.domain.path} | tr -d '\n')

      mkdir -p /run/miniflux
      cat > /run/miniflux/admin-credentials << EOF
      ADMIN_USERNAME=$USERNAME
      ADMIN_PASSWORD=$PASSWORD
      BASE_URL=https://miniflux.$DOMAIN
      EOF

      chmod 600 /run/miniflux/admin-credentials
    '';
  };

  systemd.services.miniflux = {
    after = [ "miniflux-credentials.service" ];
    requires = [ "miniflux-credentials.service" ];
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/run/miniflux/admin-credentials";

    config = {
      LISTEN_ADDR = "localhost:8080";
      POLLING_FREQUENCY = "60";
      CLEANUP_ARCHIVE_READ_DAYS = "30";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "90";
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
    };
  };
}
