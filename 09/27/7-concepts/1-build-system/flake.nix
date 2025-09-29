# flake.nix
{
  description = "A Nix flake providing pre-commit hooks for code quality and formatting, embodying bott principles of integration and pattern recognition.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        src = ./.;
        vendoredLintStaged = pkgs.callPackage ./nix/packages/lint-staged { inherit src; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
            pkgs.nixpkgs-fmt
            pkgs.statix
            pkgs.shellcheck # Keep shellcheck as it's a useful general-purpose linter
            pkgs.nodePackages."@commitlint/cli" # Keep commitlint
            pkgs.vale
            pkgs.nodejs # For lint-staged
            vendoredLintStaged
          ];
        };
        # Expose the rustVersions for easy access
        # inherit rustVersions;

        checks = {
          simple-test = pkgs.runCommand "simple-test" {} "echo \"Test passed!\" > $out";
        };
      }
    );
}
