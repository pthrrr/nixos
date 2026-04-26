# modules/optional/ollama-nvidia.nix
# Ollama LLM server with NVIDIA CUDA GPU acceleration
{ config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    port = 11434;
  };

  # Allow Ollama API access only from server
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 11434 -s 192.168.10.100 -j nixos-fw-accept
  '';
}
