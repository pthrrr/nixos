# modules/optional/llama.nix
# Llamas_server or other llama-based web services
{ config, pkgs, lib, ... }:
{
  networking.firewall.extraCommands = lib.mkAfter ''
    iptables -A nixos-fw -p tcp --dport 8080 -j nixos-fw-accept
  '';
}
