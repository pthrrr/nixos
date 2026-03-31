# modules/server/podman/auto-update.nix
#
# Wöchentlicher Podman-Image-Update-Check:
#   - Zieht alle registrierten Container-Images neu
#   - Vergleicht Digests (alt vs. neu)
#   - Startet betroffene Services neu (nur wenn aktiv)
#   - Sendet ntfy-Zusammenfassung auf Topic "container"
#
# Neue Container hier registrieren: IMAGE_SERVICE Array im Script
#
{ config, pkgs, ... }:

{
  systemd.timers.podman-update = {
    description = "Podman Image Update Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 04:00:00";
      Persistent = true;
    };
  };

  systemd.services.podman-update = {
    description = "Podman Image Update Check mit ntfy-Benachrichtigung";
    after = [ "ntfy-sh.service" "podman.service" ];
    path = with pkgs; [ podman curl coreutils ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      TIMESTAMP=$(date '+%d.%m.%Y %H:%M')
      UPDATED=""
      CHECKED=0
      ERRORS=""

      # Registrierte Container: "image|systemd-service"
      CONTAINERS="
        registry.gitlab.com/fmd-foss/fmd-server:0.14.2-alpine|fmd-server
        docker.io/sergree/matchering-web:latest|matchering
      "

      for ENTRY in $CONTAINERS; do
        IMAGE=$(echo "$ENTRY" | cut -d'|' -f1)
        SERVICE=$(echo "$ENTRY" | cut -d'|' -f2)
        CHECKED=$((CHECKED + 1))

        # Aktuellen Digest speichern
        OLD_ID=$(podman image inspect "$IMAGE" --format '{{.Id}}' 2>/dev/null || echo "none")

        # Neues Image ziehen
        if ! podman pull "$IMAGE" 2>&1; then
          ERRORS="$ERRORS\n- $SERVICE: Pull fehlgeschlagen"
          continue
        fi

        # Neuen Digest vergleichen
        NEW_ID=$(podman image inspect "$IMAGE" --format '{{.Id}}' 2>/dev/null || echo "error")

        if [ "$OLD_ID" != "$NEW_ID" ]; then
          if systemctl is-active --quiet "$SERVICE"; then
            systemctl restart "$SERVICE"
            UPDATED="$UPDATED\n- $SERVICE: aktualisiert + neu gestartet"
          else
            UPDATED="$UPDATED\n- $SERVICE: neues Image (Service nicht aktiv)"
          fi
        fi
      done

      # Alte ungenutzte Images aufräumen
      podman image prune -f 2>/dev/null || true

      # ntfy-Benachrichtigung
      if [ -n "$ERRORS" ]; then
        MSG="Image-Check ($TIMESTAMP)\n$CHECKED Images geprüft\n\nFehler:$ERRORS"
        [ -n "$UPDATED" ] && MSG="$MSG\n\nAktualisiert:$UPDATED"
        curl -s \
          -H "Title: Container-Update FEHLER" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d "$(echo -e "$MSG")" \
          http://127.0.0.1:2586/container
      elif [ -n "$UPDATED" ]; then
        curl -s \
          -H "Title: Container aktualisiert" \
          -H "Priority: low" \
          -H "Tags: package" \
          -d "$(echo -e "Image-Check ($TIMESTAMP)\n$CHECKED Images geprüft\n\nAktualisiert:$UPDATED")" \
          http://127.0.0.1:2586/container
      else
        curl -s \
          -H "Title: Container up-to-date" \
          -H "Priority: min" \
          -H "Tags: white_check_mark" \
          -d "Image-Check ($TIMESTAMP): $CHECKED Images geprüft, alle aktuell." \
          http://127.0.0.1:2586/container
      fi
    '';
  };
}
