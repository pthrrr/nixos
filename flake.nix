{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/desktop-environments/gnome.nix
          ./modules/common/applications.nix
          ./modules/common/house-keeping.nix
          ./modules/common/users.nix

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
          ./modules/common/applications.nix
          ./modules/common/house-keeping.nix
          ./modules/common/users.nix

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.pthr = import ./home/pthr/laptop;
          }
        ];
      };
    };
  };
}
 