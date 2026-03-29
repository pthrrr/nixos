# NixOS

Multi-host NixOS configuration managed with Flakes.

## Hosts

| Host | Typ | Beschreibung |
|------|-----|-------------|
| desktop | Workstation | Gnome, Home Manager |
| laptop | Laptop | Gnome, Home Manager, Audio (audio.nix) |
| server | Headless | Home Server (ZFS, Podman, diverse Dienste) |

## Repo-Struktur

```
├── flake.nix                  # Entry Point (3 Hosts)
├── hosts/
│   ├── desktop/               # configuration.nix + hardware.nix
│   ├── laptop/
│   └── server/
├── modules/
│   ├── common/                # Geteilte Module (alle Hosts)
│   ├── desktop-environments/  # Gnome
│   ├── optional/              # Gaming, HDR, VM, etc.
│   └── server/                # Server-Dienste
├── home/                      # Home Manager Configs
├── overlays/                  # Caddy-Overlay (Server)
└── secrets/                   # agenix-verschlüsselte Secrets
```

## Flake-Inputs

- **nixpkgs** (unstable)
- **agenix** — Secret Management
- **home-manager** — User-Config
- **copyparty** — File Access
- **audio-nix** — Audio/Music Production (Laptop)

## Server-Dienste

| Dienst | Laufzeit | Modul |
|--------|----------|-------|
| Syncthing | Nativ | syncthing.nix |
| Radicale | Nativ | radicale.nix |
| Copyparty | Nativ | copyparty.nix |
| Caddy | Nativ | caddy.nix |
| Blocky (DNS) | Nativ | blocky.nix |
| Grafana + Prometheus | Nativ | monitoring.nix |
| Home Assistant | Podman | home-assistant.nix |
| Matter Server | Podman | matter-server.nix |
| FreshRSS | Podman | podman/freshrss.nix |
| Matchering | Podman | podman/matchering.nix |

**Storage:** ZFS (sanoid/syncoid Backups) — siehe `backup.nix`, `zfs.nix`

## Anwendung

```bash
# System bauen + aktivieren
sudo nixos-rebuild switch --flake .#<host> --impure

# Flake aktualisieren
nix flake update

# Debug
sudo nixos-rebuild switch --flake .#<host> --show-trace --print-build-logs --verbose
```
