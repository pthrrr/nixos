# modules/server/searxng.nix
# SearXNG metasearch engine for Open WebUI web search
{ config, pkgs, ... }:
{
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key = "nixos-searxng-local-secret";
      };
      search = {
        formats = [ "html" "json" ];
      };
      engines = [
        { name = "google"; engine = "google"; shortcut = "g"; }
        { name = "duckduckgo"; engine = "duckduckgo"; shortcut = "ddg"; }
        { name = "wikipedia"; engine = "wikipedia"; shortcut = "wp"; }
      ];
    };
  };
}
