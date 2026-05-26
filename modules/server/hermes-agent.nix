# modules/server/hermes-agent.nix
# Hermes Agent — AI assistant with Ollama (local LLM) via Telegram
# Native mode with strict sandboxing: only MCP workspace dirs are writable
{ config, pkgs, lib, ... }:

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

  age.secrets.hermes-telegram-users = {
    file = ../../secrets/hermes-telegram-users.age;
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

    environment = {};

    # Telegram Bot Token + User-Allowlist aus agenix
    environmentFiles = [
      config.age.secrets.hermes-telegram-token.path
      config.age.secrets.hermes-telegram-users.path
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
    # Dateisystem-Isolation
    ProtectSystem = lib.mkForce "strict";           # / und /usr read-only
    ProtectHome = lib.mkForce true;                 # /home nicht sichtbar
    PrivateTmp = true;                  # eigenes /tmp
    ReadWritePaths = [
      "/data/users/pierre/mcp"
      "/data/users/katti/mcp"
      "/var/lib/hermes"                 # eigener State
    ];

    # Netzwerk: nur Ollama + Telegram API
    # (kein RestrictAddressFamilies, da Hermes TCP braucht)

    # Kernel-Hardening
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;

    # Keine Rechteeskalation
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;

    # Kein Zugriff auf Hardware
    PrivateDevices = true;

    # Syscall-Filter
    SystemCallArchitectures = "native";
  };
}
