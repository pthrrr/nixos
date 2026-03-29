# NixOS

## Base scaffolding
```
├── flake.lock
├── flake.nix                       # Main entry point
├── home                            # Home-manager configurations
│   └── <user>                      # User-specific config
│       ├── home.nix                # Shared user apps
│       ├── applications            # Shared user app configurations
│       │   ├── dconf.nix           # Gnome configuration 
│       │   └── <app1>.nix
│       │   └── <app2>.nix
│       ├── <device1> 
│       │   └── <deivce1_app1>.nix  # Specific apps for <device1>
│       └── <device2>
│           └── <deivce2_app1>.nix  # Specific apps for <device2> 
├── hosts                           # Machine-specific configurations
│   ├── <device1>
│   │   ├── configuration.nix
│   │   └── hardware.nix
│   └── <device2>
│       ├── configuration.nix
│       └── hardware.nix
├── modules
│   ├── common                      # Shared configurations/apps
│   │   ├── <shared_app1>.nix       # Shared application
│   │   ├── <shared_app2>.nix
│   │   └── users.nix               # User definitions
│   └── desktop-environments        # DE configurations
│   │   └── gnome.nix
│   └── optional                    # Optional applications
│       └── <optional_app1>.nix
└── README.md
```

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

### Check config
- `nix flake check`
- `nix flake show`

##  Dconf

check options for dconf settings
- `dconf watch \`

## PaperWm Winprop

- The wm_class or title of a window can be found by using looking glass: `Alt` + `F2` `lg` `Return` Go to the "Windows" section at the top right and find the window.

## To Do's
- setup wireguard
   - sync cal with CalDAV

## Issues
- ~~unlock keyring (auto-login)~~ — fixed: gnome-keyring disabled, pass-secret-service handles secrets via pass/GPG
- ~~wake from sleep/hibernate (nvidia optimus prime)~~ — fixed: NVIDIA power management + PRIME Sync