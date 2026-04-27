# modules/server/open-webui.nix
# Open WebUI with SearXNG web search integration
{ config, pkgs, ... }:
{
  services.open-webui = {
    enable = true;
    port = 8282;
    environment = {
      OLLAMA_BASE_URLS = "http://desktop:11434;http://laptop:11434";
      ENABLE_RAG_WEB_SEARCH = "true";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://localhost:8888/search?q=<query>&format=json&language=de";
      WEBUI_AUTH = "false";  # Set to "true" if you want login
    };
  };
}
