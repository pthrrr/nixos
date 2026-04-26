# modules/optional/ollama-nvidia.nix
# Ollama LLM server with NVIDIA CUDA GPU acceleration
{ config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "127.0.0.1";
    port = 11434;
  };
}
