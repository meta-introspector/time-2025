{
  description = "Dynamic Flake Checker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Or a more appropriate nixpkgs
    flake-checker.url = "./flake-checker.nix"; # Relative path to our checker
  };

  outputs = { self, nixpkgs, flake-checker, ... }:
    let
      systems = [ "x86_64-linux" ]; # Define target systems

      # For now, a simplified list of flakes to check
      flakePaths = [
        (toString ../../.. + "/flake.nix") # Main flake
        (toString ./flake-checker.nix) # Our checker flake
      ];

    in
    {
      # Define a check that runs our flake checker
      checks = lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          # Call our flake checker with the list of all flake.nix files
          checkerResults = flake-checker.results {
            inherit lib pkgs;
            inherit flakePaths;
          };
        in
        {
          # Expose the report as a check result
          flakeIdentityReport = pkgs.runCommand "flake-identity-report" {} ''
            echo "${checkerResults.report}" > "$out"
            # If there are duplicates, fail the build
            if ${if checkerResults.hasDuplicates then "true" else "false"}; then
              echo "ERROR: Duplicate commands found!" >&2
              exit 1
            fi
          '';
        }
      );
    };
}
