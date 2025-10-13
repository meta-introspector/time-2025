{
  description = "A flake to extract data from a list of flake.lock files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing a JSON file with a list of flake.lock paths
    collectedLocks = {
      url = "path:../001_collect_locks";
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectedLocks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Get the path to the derivation output containing the list of flake.lock file paths
        collectedLocksDerivationPath = collectedLocks.packages.${system}.default;
        allCollectedLocks = builtins.fromJSON (builtins.readFile "${collectedLocksDerivationPath}/all-flake-locks.json");

        # Process each collected lock file
        processedLockFiles = lib.map
          (item:
            if item.hasLockFile then
              let
                lockFileContent = builtins.readFile item.lockFilePath;
                nixFileContent = item.nixFileContent; # Already read in 001_collect_locks
              in
              # Create a derivation for each lock file to extract its data
              pkgs.runCommand "extracted-data-${lib.strings.sanitizeDerivationName item.lockFilePath}"
                {
                  nativeBuildInputs = [ pkgs.jq ];
                  inherit lockFileContent nixFileContent;
                  lockFilePath = item.lockFilePath;
                  nixFilePath = item.nixFilePath;
                  hasLockFile = item.hasLockFile;
                }
                ''
                  mkdir -p $out
                  echo "$lockFileContent" | jq -c --arg lock_file_path "$lockFilePath" --arg nix_file_path "$nixFilePath" --arg nix_file_content "$nixFileContent" --arg has_lock_file "${hasLockFile}" '.nodes[] | select(.locked != null) | {sourceFile: $lock_file_path, nixFile: $nix_file_path, nixFileContent: $nix_file_content, hasLockFile: ($has_lock_file | fromjson), url: .locked.url // "N/A", narHash: .locked.narHash // "N/A", owner: .locked.owner // "N/A", repo: .locked.repo // "N/A", rev: .locked.rev // "N/A", type: .locked.type // "N/A"}' > $out/extracted-data.json
                ''
            else
              null # Or handle missing lock files differently, e.g., log them
          )
          allCollectedLocks;

        # Filter out nulls (for missing lock files) and combine all extracted data
        allExtractedData = pkgs.runCommand "combined-extracted-data"
          {
            nativeBuildInputs = [ pkgs.jq ];
            extractedDataJsons = builtins.toJSON (lib.filter (x: x != null) processedLockFiles);
          }
          ''
            mkdir -p $out
            echo "$extractedDataJsons" | jq -s 'flatten' > $out/extracted-data.json
          '';
      in
      {
        packages.default = allExtractedData;
        checks.extractedData = pkgs.runCommand "extracted-flake-data-check"
          {
            inherit allExtractedData;
          } "cp ${allExtractedData}/extracted-data.json $out";

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 002_extract_data

          ## Purpose

          This flake is the second step in the flake audit process. It takes a list of `flake.lock` file paths (output from `001_collect_locks`) and extracts relevant data from each `flake.lock` file.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `collectedLocks`: The output from the `001_collect_locks` flake, which is a derivation containing a JSON file with a list of `flake.lock` paths.

          ## Outputs

          *   `packages.default`: A derivation containing a JSON file (`extracted-data.json`) which is a single JSON array containing all extracted data from all `flake.lock` files.
          *   `checks.extractedData`: A check that outputs the same JSON data, useful for debugging and verification.

          ## Usage

          To build the default package (the JSON file containing all extracted data):

          ```bash
          nix build .#default
          ```

          To inspect the extracted data (for debugging):

          ```bash
          nix build .#checks.extractedData
          cat ./result
          ```

          This flake is designed to be chained with subsequent flakes in the audit process.
        '';
      }
    );
}
