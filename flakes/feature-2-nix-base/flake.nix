{
  description = "Feature 2: Foundational Nix Base - Provides basic pkgs and lib.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:nix
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;
      in
      {
        # Expose pkgs and lib for other flakes to consume
        lib = {
          inherit pkgs lib;
        };

        # A simple package to demonstrate the base
        packages.default = pkgs.writeText "nix-base-feature" "This flake provides a foundational Nix environment.";
      }
    );
}