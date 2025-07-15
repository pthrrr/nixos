# overlays/default.nix
{ inputs, ... }: {
  # Custom packages from pkgs directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Version overrides and modifications
  modifications = final: prev: {
    # Override Caddy to use v2.9.1 for Namecheap plugin compatibility
    caddy = prev.caddy.overrideAttrs (oldAttrs: rec {
      version = "2.9.1";
      vendorHash = "sha256-qrlpuqTnFn/9oMTMovswpS1eAI7P9gvesoMpsIWKcY8=";
      src = prev.fetchFromGitHub {
        owner = "caddyserver";
        repo = "caddy";
        tag = "v${version}";
        hash = "sha256-XW1cBW7mk/aO/3IPQK29s4a6ArSKjo7/64koJuzp07I=";
      };
    });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
