{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager, ... }@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/desktop-environments/gnome.nix
          ./modules/common
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.pthr = import ./home/pthr/desktop;
          }
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/desktop-environments/gnome.nix
          ./modules/common
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.pthr = import ./home/pthr/laptop;
          }
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit agenix; };

        modules = [
          ./hosts/server/configuration.nix
	  ./modules/server
          agenix.nixosModules.default

          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];     
          }

        ];
      };

    };
  };
}
 
