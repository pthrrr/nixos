# nixos
i have no idea what i am doing

### try a package temporarily
`nix-shell -p <package>`

### persist changes
- `sudo nixos-rebuild switch --flake "./#desktop"`
- `sudo nixos-rebuild switch --flake "./#vivobook"`

### check config
- `nix flake check`
- `nix flake show`

## Things to fix
- unlock keyring
- wake from sleep/hibernate