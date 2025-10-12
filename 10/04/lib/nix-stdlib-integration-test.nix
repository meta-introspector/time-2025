# temp_test_generate.nix
let
  # Use the specified nixpkgs flake
  nixpkgs = builtins.getFlake "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  inherit (nixpkgs) lib;
  pkgs = nixpkgs.legacyPackages.${builtins.currentSystem}; # Define pkgs here

  inherit (lib) types;
  inherit (builtins) tryEval;# Define tryEval here

  # errors and evaluateNixFile are not circularly dependent on generate or processEntry.
  errors = import ./lib/generate-project-nix/error-constructor.nix { inherit lib builtins; };
  evaluateNixFile = import ./lib/generate-project-nix/evaluateNixFile.nix { inherit lib builtins types errors tryEval pkgs; }; # Inherit pkgs here

  # Define mutually recursive functions within a 'rec' attribute set
  mutuallyRecursive = rec {
    processEntry = import ./lib/generate-project-nix/processEntry.nix {
      inherit lib builtins types errors evaluateNixFile generate;
    };

    generate = import ./lib/generate-project-nix/generate.nix {
      inherit lib builtins types errors evaluateNixFile processEntry;
    };
  };

  # Extract the functions from the 'mutuallyRecursive' attribute set
  inherit (mutuallyRecursive) processEntry;
  inherit (mutuallyRecursive) generate;

in
generate (builtins.path { path = ./.; })
