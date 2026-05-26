# modules/server/hermes-agent.nix
# Hermes Agent — AI assistant with Ollama (local LLM) via Telegram
# Native mode with strict sandboxing: only MCP workspace dirs are writable
{ config, pkgs, ... }:

let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;
  domain = stripNL (builtins.readFile config.age.secrets.domain.path);
in
{
  age.secrets.hermes-telegram-token = {
    file = ../../secrets/hermes-telegram-token.age;
    owner = "hermes";
    group = "hermes";
  };

  services.hermes-agent = {
    enable = true;

    # Telegram-Dependency muss explizit aktiviert werden (nicht in [all] enthalten)
    extraDependencyGroups = [ "messaging" ];

    # Ollama als LLM-Provider via Custom Endpoint (Laptop)
    settings = {
      model = {
        default = "gemma4:e2b";
        provider = "custom";
        base_url = "http://laptop:11434/v1";
      };
      terminal.backend = "local";
      toolsets = [ "all" ];
    };

    environment = {
      # Nur autorisierte Telegram-User erlauben
      TELEGRAM_ALLOWED_USERS = "119400565";
    };

    # Telegram Bot Token aus agenix
    environmentFiles = [
      config.age.secrets.hermes-telegram-token.path
    ];

    # MCP-Ordner als Workspace
    workingDirectory = "/var/lib/hermes/workspace";

    # Agent darf nur auf diese Verzeichnisse zugreifen
    documents = {
      "SOUL.md" = ''
        Du bist ein hilfreicher persönlicher AI-Assistent.
        Du kommunizierst auf Deutsch.
        Du hast Zugriff auf die MCP-Ordner der Benutzer Pierre und Katti.
        Die Ordner sind unter /data/users/pierre/mcp und /data/users/katti/mcp gemountet.
      '';
    };

    # Zusätzliche Pakete für den Agent
    extraPackages = with pkgs; [
      ripgrep
      fd
      jq
      curl
    ];
  };

  # MCP-Ordner müssen existieren
  systemd.tmpfiles.rules = [
    "d /data/users/pierre/mcp 0770 hermes hermes -"
    "d /data/users/katti/mcp 0770 hermes hermes -"
  ];

  # Sandboxing: Agent darf nur auf MCP-Ordner + eigenen State zugreifen
  systemd.services.hermes-agent.serviceConfig = {
    ReadWritePaths = [
      "/data/users/pierre/mcp"
      "/data/users/katti/mcp"
    ];
  };
}
