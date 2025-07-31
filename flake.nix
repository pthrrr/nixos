{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    copyparty.url = "github:9001/copyparty";
    copyparty.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, agenix, copyparty, ... }@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit agenix; };  # Keep as agenix
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/desktop-environments/gnome.nix
          ./modules/common
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.pthr = import ./home/pthr/desktop;
          }
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit agenix; };  # Keep as agenix
        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/desktop-environments/gnome.nix
          ./modules/common
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.pthr = import ./home/pthr/laptop;
          }
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit agenix inputs; };  # Pass both agenix AND inputs
        modules = [
          # ONLY apply overlay to server (for Caddy v2.9.1)
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (import ./overlays { inherit inputs; }).modifications
              copyparty.overlays.default
            ];
          })

          agenix.nixosModules.default
          copyparty.nixosModules.default
          
          ./hosts/server/configuration.nix
          ./modules/server

          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
        ];
      };
    };
  };
}
