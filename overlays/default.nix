# overlays/default.nix
{ inputs, ... }: {
  # Custom packages from pkgs directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Version overrides and modifications
  modifications = final: prev: {
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
