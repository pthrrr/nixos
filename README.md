# nixos
i have no idea what i am doing

### try a package temporarily
`nix-shell -p <package>`

### persist changes
- `sudo nixos-rebuild switch --flake .#desktop`
- `sudo nixos-rebuild switch --flake .#laptop`

### check config
- `nix flake check`
- `nix flake show`

## issues to solve
- unlock keyring (auto-login)
- wake from sleep/hibernate (nvidia optimus prime)