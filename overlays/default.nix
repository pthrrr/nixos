# overlays/default.nix
{ inputs, ... }: {
  # Custom packages from pkgs directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Version overrides and modifications
  modifications = final: prev: {
    openldap = prev.openldap.overrideAttrs (old: {
      doCheck = false;
    });
    # TODO: remove once nixos-unstable includes openrazer 3.12.3
    linuxPackages_latest = prev.linuxPackages_latest.extend (lpFinal: lpPrev: {
      openrazer = lpPrev.openrazer.overrideAttrs (old: {
        version = "3.12.3-${prev.linuxPackages_latest.kernel.version}";
        src = prev.fetchFromGitHub {
          owner = "openrazer";
          repo = "openrazer";
          rev = "v3.12.3";
          hash = "sha256-X1NPqbugBdxD5Nt9wIwQADV4CuydGLpgKhlNazVdrIY=";
        };
      });
    });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
