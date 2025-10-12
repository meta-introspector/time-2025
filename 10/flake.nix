{
  description = "Nix flake for modules related to the 10/ directory, including CRQ text extraction and n-gram generation.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Assuming month09Flake is needed by crq-text-extractor.nix
    month09Flake = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=09";
      flake = false; # Assuming 09 is not a flake itself, but a directory of modules
    };
  };

  outputs = { self, nixpkgs, flake-utils, month09Flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
      in
      {
        # Expose crq-text-extractor.nix as an output
        crqTextExtractor = import ./crq-text-extractor.nix { inherit pkgs month09Flake; };

        # Expose n_gram_generator.nix as an output
        nGramGenerator = import ./01/docs/theory/n_gram_generator.nix { inherit lib pkgs builtins; };
      }
    );
}
