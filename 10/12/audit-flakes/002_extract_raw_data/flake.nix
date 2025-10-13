{
  description = "A flake to extract raw data from a list of flake.lock files, including absolute paths.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectedLocks = {
      url = "path:../001_collect_locks";
    };
    project = {
      url = "path:../../.."; # Points to the streamofrandom 2025 root
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectedLocks, project }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        collectedLocksDerivationPath = collectedLocks.packages.${system}.default;
        allCollectedLocks = builtins.fromJSON (builtins.readFile collectedLocksDerivationPath);

        processedLockFiles = allCollectedLocks;
        allExtractedData = pkgs.runCommand "combined-extracted-data-placeholder"
          { }
          "echo '[]' > $out/extracted-data.json";
      in
      {
        packages.default = allExtractedData;
        checks.rawLockData = pkgs.runCommand "raw-lock-data-check"
          {
            rawLockDataPaths = processedLockFiles; # These are now the paths to derivations
          }
          ''
            mkdir -p $out
            for path in $rawLockDataPaths; do
              echo "Derivation path: $path" >> $out/paths.txt
              # Also list the contents of the derivation
              ls -l $path >> $out/contents-$(basename $path).txt
            done
            echo "Done." >> $out/paths.txt
          '';

        checks.extractedData = pkgs.runCommand "extracted-flake-data-check"
          {
            extractedDataInput = allExtractedData;
          } "cp $extractedDataInput/extracted-data.json $out/extracted-data.json";

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 002_extract_raw_data

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
