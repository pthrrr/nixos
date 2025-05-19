{
  description = "nixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add Home Manager as an input
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:

    let
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      nixosModules = {
        default        = ./modules/default.nix;
      };

      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          #system = "x86_64-linux";
          
          modules = [
            self.nixosModules.default
            ./hosts/laptop
            
            # Add Home Manager as a module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Point to your home configurations
              home-manager.users.pthr = import ./modules/home.nix;
            }
          ];
        };

        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            ./hosts/desktop

            # Add Home Manager as a module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Point to your home configurations
              home-manager.users.pthr = import ./modules/home.nix;
            }
          ];
        };
      };
    };
}
