# NixOS
This is my personal NixOS configuration.
It relies on the [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)

## The New CLI and the Classic CLI
[Resource](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes#the-new-cli-and-the-classic-cli)

## Useful commands

### Common commands

**Try a package**
- `nix-shell -p <package>`

**Apply system changes**
- `sudo nixos-rebuild switch`

    **Customize location and name of configuration**
    - `sudo nixos-rebuild switch --flake <path>#hostname`
    - `sudo nixos-rebuild switch --flake .#laptop`
    - `sudo nixos-rebuild switch --flake .` 

*Occasionally, you may encounter a "sha256 mismatch" error when running nixos-rebuild switch. This error can be resolved by updating flake.lock using nix flake update.*

**Show detailed error messages**

*You can always try to add --show-trace --print-build-logs --verbose to the nixos-rebuild command*
- `sudo nixos-rebuild switch --flake .#myhost --show-trace --print-build-logs --verbose`

**Use GitHub repo as flake source**
- `sudo nixos-rebuild switch --flake github:owner/repo#your-hostname`

### Flake commands
**List official flake templates:**
- `nix flake show templates`

**Download template**
- `nix flake init -t templates#full`

**Compile a program from source and try without permanent installing it**
- `nix run github:owner/repo#your-hostname`

**Update flakee.lock**
- `nix flake update`

### check config
- `nix flake check`
- `nix flake show`

## issues to solve
- unlock keyring (auto-login)
- wake from sleep/hibernate (nvidia optimus prime)