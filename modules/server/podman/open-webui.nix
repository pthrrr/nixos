# modules/server/podman/open-webui.nix
#
# Open WebUI als Podman-Container (offizielles Image)
# Ersetzt das native NixOS-Modul wegen fehlendem SvelteKit-Frontend in nixpkgs 0.9.6
# Web UI über Caddy: https://ai.$DOMAIN
# Intern: 127.0.0.1:8282 (via --network=host + PORT=8282)
# SearXNG-Integration: localhost:8888 (nativ, modules/server/searxng.nix)
#
{ config, pkgs, ... }:

{
  # Datenverzeichnis auf tank (ZFS)
  systemd.tmpfiles.rules = [
    "d /data/containers/open-webui 0755 root root -"
    "d /data/containers/open-webui/data 0755 root root -"
  ];

  systemd.services.open-webui = {
    description = "Open WebUI (Podman)";
    after = [ "network.target" "podman.service" ];
    requires = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm -f open-webui";
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm --name open-webui \
          --network=host \
          -e OLLAMA_BASE_URLS="http://desktop:11434;http://laptop:11434" \
          -e ENABLE_RAG_WEB_SEARCH="true" \
          -e RAG_WEB_SEARCH_ENGINE="searxng" \
          -e SEARXNG_QUERY_URL="http://localhost:8888/search?q=<query>&format=json" \
          -e WEBUI_AUTH="false" \
          -e PORT="8282" \
          -v /data/containers/open-webui/data:/app/backend/data \
          --security-opt=no-new-privileges \
          ghcr.io/open-webui/open-webui:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop open-webui";
    };
  };
}
