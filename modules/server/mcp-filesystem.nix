# modules/server/mcp-filesystem.nix
# MCP Filesystem Server for Open WebUI integration
# Provides file read/write/search capabilities to LLMs
{ config, pkgs, ... }:
let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
  # Directories the LLM is allowed to access (read+write)
  allowedDir1 = "/data/users/${username1}/mcp";
  allowedDir2 = "/data/users/${username2}/mcp";
  mcpPort = 8383;
in
{
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  # Ensure MCP directories exist
  systemd.tmpfiles.rules = [
    "d ${allowedDir1} 0775 media media -"
    "d ${allowedDir2} 0775 media media -"
  ];

  # Add open-webui user to media group for /data access
  users.users.open-webui = {
    isSystemUser = true;
    group = "open-webui";
    extraGroups = [ "media" ];
  };
  users.groups.open-webui = {};

  # MCP Filesystem Server via supergateway (stdio→SSE bridge)
  # Runs @modelcontextprotocol/server-filesystem behind supergateway
  # so Open WebUI can connect via SSE
  systemd.services.mcp-filesystem = {
    description = "MCP Filesystem Server (SSE)";
    after = [ "network-online.target" "agenix.service" ];
    wants = [ "network-online.target" "agenix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "open-webui";
      Group = "media";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.nodejs}/bin/npx --yes supergateway --port ${toString mcpPort} --stdio \"npx --yes @modelcontextprotocol/server-filesystem ${allowedDir1} ${allowedDir2}\"";
      Environment = [
        "HOME=/tmp/mcp-filesystem"
        "npm_config_cache=/tmp/mcp-filesystem/.npm"
      ];
    };
  };

  environment.systemPackages = [ pkgs.nodejs ];
}
