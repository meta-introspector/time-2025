{
  description = "A flake to perform a dry-run build on a given input flake path.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = {
          # This is a function that takes the target flake path as an argument
          # and returns a derivation that performs the dry-run.
          dryRun = targetFlakePath: pkgs.runCommand "dry-run-${pkgs.lib.strings.sanitizeDerivationName targetFlakePath}"
            {
              # The target flake path is passed as an environment variable
              TARGET_FLAKE_PATH = targetFlakePath;
            }
            ''
              mkdir -p $out
              # Execute nix build with dry-run and verbose flags
              nix build -vvvvv --dry-run --extra-experimental-features 'nix-command flakes' --flake "$TARGET_FLAKE_PATH#default" > $out/dry-run-output.txt 2>&1
            '';
        };
      }
    );
}
