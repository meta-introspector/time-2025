{
  description = "Nix flake for NAR similarity search based on Gödel numbering and Monster Group concepts.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    rnix-parser = {
      url = "github:meta-introspector/rnix-parser?ref=feature/CRQ-016-nixify-workflow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025/10/11/nar-similarity-search";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rnix-parser }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Import the library functions
        similarityLib = import ./lib.nix {
          inherit lib pkgs system nixpkgs rnix-parser self;
        };

      in
      {
        lib = similarityLib;
        # Default package to demonstrate self-introspection and Gödel numbering
        packages.default = pkgs.runCommand "self-gödel-number" {
          nativeBuildInputs = [ pkgs.bash pkgs.jq ];
          flakeSource = self;
          extractedKeywordsDerivation = similarityLib.extractKeywords self;
        }
          ''
            set -euo pipefail

            echo "Calculating Gödel number (prime exponents) for self flake..."
            local keywords_json=$(cat $extractedKeywordsDerivation)

            # Evaluate the Nix calculateGödelNumber function
            local prime_exponents_json=$(nix eval --json --expr \
              'let 
                 flake = builtins.getFlake "${self}";
                 calculateGödelNumber = flake.outputs.lib.${system}.calculateGödelNumber; 
                 keywordsList = builtins.fromJSON "${keywords_json}";
               in 
                 calculateGödelNumber { inherit keywordsList; }')

            echo "$prime_exponents_json" > $out/prime-exponents.json
          '';
      }
    );
}
