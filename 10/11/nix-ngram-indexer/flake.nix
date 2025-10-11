{
  description = "Nix flake for generating N-gram indexes for similarity and near-duplicate detection.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025"; # Project root
    };
    # Input for the nix_2gram_indexer.nix file itself
    nix2GramIndexerFile = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025/10/01/docs/theory/nix_2gram_indexer.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix2GramIndexerFile }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Import the functions from nix_2gram_indexer.nix
        ngramIndexerLib = import nix2GramIndexerFile { inherit lib pkgs builtins; };

        # Function to generate the N-gram index for specified paths and N-gram sizes
        generateNgramIndex = { paths, ngramSizes ? [ 1 2 3 5 7 11 13 19 23 ] }:
          ngramIndexerLib.generateNgramIndex { inherit paths ngramSizes; };

      in
      {
        lib = { inherit generateNgramIndex; };

        checks = {
          # Generate N-gram index for scripts/ and docs/
          generateProjectNgramIndex = pkgs.runCommand "generate-project-ngram-index" {
            nativeBuildInputs = [ pkgs.bash pkgs.jq ];
            # Define the paths to be indexed (relative to self.outPath)
            indexedPaths = lib.toJSON [ "${self}/scripts" "${self}/docs" ];
            ngramIndex = generateNgramIndex { paths = [ "${self}/scripts" "${self}/docs" ]; };
          } ''
            echo "Generating N-gram index for project..."
            local ngram_index_path="$ngramIndex"
            echo "N-gram index generated at: $ngram_index_path"
            # Verify that the index file exists and is not empty
            if [ -s "$ngram_index_path/ngram_index.json" ]; then
              echo "N-gram index file exists and is not empty. Good!"
            else
              echo "Error: N-gram index file is missing or empty." >&2
              exit 1
            fi
          '';
        };
      }
    );
}