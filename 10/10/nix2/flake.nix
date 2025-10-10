{
  description = "Dynamic Flake Checker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Or a more appropriate nixpkgs
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ]; # Define target systems
      inherit (nixpkgs) lib;

      # For now, a simplified list of flakes to check
      flakePaths = [
        (toString ../../.. + "/flake.nix") # Main flake
        (toString ./flake-checker.nix) # Our checker flake
        (toString ../../../09/26/jobs/vendor/nix-task/flake.nix)
        (toString ../grep-nar-flake/flake.nix)
        (toString ../../09/orchestration-flake/flake.nix)
      ];

      flake-checker = import ./flake-checker.nix;

    in
    {
      # Define a check that runs our flake checker
      checks = lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          # Call our flake checker with the list of all flake.nix files
          checkerResults = flake-checker {
            inherit lib pkgs;
            inherit flakePaths;
            firstReflection = {}; # Placeholder
            urlExtractor = {}; # Placeholder
            gitmodulesPaths = []; # Placeholder
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
