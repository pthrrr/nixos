# modules/server/mcp-filesystem.nix
# MCP Filesystem Server for Open WebUI integration
# Provides file read/write/search capabilities to LLMs
{ config, pkgs, ... }:
let
  # Directory the LLM is allowed to access (read+write)
  allowedDir = "/var/lib/mcp-files";
  mcpPort = 8383;
in
{
  # Ensure the shared directory exists
  systemd.tmpfiles.rules = [
    "d ${allowedDir} 0755 open-webui open-webui -"
  ];

  # MCP Filesystem Server via supergateway (stdio→SSE bridge)
  # Runs @modelcontextprotocol/server-filesystem behind supergateway
  # so Open WebUI can connect via SSE
  systemd.services.mcp-filesystem = {
    description = "MCP Filesystem Server (SSE)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "open-webui";
      Group = "open-webui";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.nodejs}/bin/npx --yes supergateway --port ${toString mcpPort} --stdio \"npx --yes @modelcontextprotocol/server-filesystem ${allowedDir}\"";
      Environment = [
        "HOME=/tmp/mcp-filesystem"
        "npm_config_cache=/tmp/mcp-filesystem/.npm"
      ];
    };
  };

  environment.systemPackages = [ pkgs.nodejs ];
}
