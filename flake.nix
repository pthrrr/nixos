{
  description = "My machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:

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

      nixosConfigurations = {

        # Name of your config
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # # README.md
            # mkdir ~/nixos
            # cd ~/nixos
            # cp /etc/nixos/hardware-configuration.nix ./
            # cp /etc/nixos/configuration.nix ./
            # Add and commit all files
            # nixos-rebuild switch --flake "./#laptop"
            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };
      };
    };
}
