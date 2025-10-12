{
  description = "Nix flake for detecting duplicated Nix code via content hashing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
    # Input for the nix_code_indexer.nix file itself
    nixCodeIndexerFile = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=10/01/docs/theory/nix_code_indexer.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixCodeIndexerFile }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Import the functions from nix_code_indexer.nix
        indexerLib = import nixCodeIndexerFile { inherit lib pkgs builtins; };

        # Function to detect duplicates in the project
        detectDuplicates =
          let
            nixFileIndex = indexerLib.indexNixFiles {
              path = self;
              projectRoot = self;
            };
          in
          indexerLib.detectDuplication { inherit nixFileIndex; };

      in
      {
        lib = { inherit detectDuplicates; };

        checks = {
          # Check for exact duplicate Nix files in the project
          findExactNixDuplicates = pkgs.runCommand "find-exact-nix-duplicates"
            {
              nativeBuildInputs = [ pkgs.bash pkgs.jq ];
              duplicatesJson = lib.toJSON detectDuplicates.duplicates;
            } ''
            echo "Checking for exact Nix file duplicates..."
            local duplicates_array=$(cat $duplicatesJson)
            if echo "$duplicates_array" | jq -e '. == []' > /dev/null; then
              echo "No exact Nix file duplicates found. Good!"
            else
              echo "Found exact Nix file duplicates:" >&2
              echo "$duplicates_array" | jq '.' >&2
              exit 1
            fi
          '';
        };
      }
    );
}
