# modules/optional/ollama.nix
# Ollama LLM server with AMD ROCm GPU acceleration
{ config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "0.0.0.0";  # Listen on all interfaces (accessible from server)
    port = 11434;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";  # RX 7800 XT (Navi 32 / gfx1101)
    };
  };

  # Allow Ollama API access only from server
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 11434 -s 192.168.10.100 -j nixos-fw-accept
  '';
}
