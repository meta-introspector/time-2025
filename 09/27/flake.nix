# flake.nix
{
  description = "A Nix flake providing pre-commit hooks for code quality and formatting, embodying bott principles of integration and pattern recognition.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
            pkgs.nixpkgs-fmt
            pkgs.statix
            pkgs.shellcheck # Keep shellcheck as it's a useful general-purpose linter
            pkgs.nodePackages."@commitlint/cli" # Keep commitlint
          ];
        };
      }
    );
}
