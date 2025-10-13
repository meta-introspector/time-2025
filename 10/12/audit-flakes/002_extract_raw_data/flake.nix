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

        processedLockFiles = lib.map
          (item:
            let
              # Read files from the item derivation
              nixFilePath = builtins.readFile (item + "/nixFilePath");
              lockFilePath = builtins.readFile (item + "/lockFilePath");
              nixFileContent = builtins.readFile (item + "/nixFileContent");
              hasLockFile = builtins.fromJSON (builtins.readFile (item + "/hasLockFile"));
            in
            pkgs.runCommand "raw-lock-data-${lib.strings.sanitizeDerivationName lockFilePath}"
              {
                inherit nixFilePath lockFilePath nixFileContent hasLockFile;
              }
              ''
                mkdir -p $out
                echo "$nixFilePath" > $out/nixFilePath.txt
                echo "$lockFilePath" > $out/lockFilePath.txt
                echo "$nixFileContent" > $out/nixFileContent.txt
                echo "$hasLockFile" > $out/hasLockFile.txt
              ''
          )
          allCollectedLocks;
        allExtractedData = pkgs.runCommand "combined-extracted-data"
          {
            nativeBuildInputs = [ pkgs.jq ];
            rawLockDataDerivations = lib.filter (x: x != null) processedLockFiles;
            PROJECT_ROOT = project; # Pass project root as env var
          }
          ''
            mkdir -p $out
            TEMP_JSON_FILES=""
            for raw_data_drv in $rawLockDataDerivations; do
              NIX_FILE_PATH=$(cat $raw_data_drv/nixFilePath.txt)
              LOCK_FILE_PATH=$(cat $raw_data_drv/lockFilePath.txt)
              NIX_FILE_CONTENT=$(cat $raw_data_drv/nixFileContent.txt)
              HAS_LOCK_FILE=$(cat $raw_data_drv/hasLockFile.txt)

              RELATIVE_LOCK_FILE_PATH=$(realpath --relative-to=$PROJECT_ROOT $LOCK_FILE_PATH)
              RELATIVE_NIX_FILE_PATH=$(realpath --relative-to=$PROJECT_ROOT $NIX_FILE_PATH)

              echo "$NIX_FILE_CONTENT" | jq -c \
                --arg lock_file_path "$RELATIVE_LOCK_FILE_PATH" \
                --arg nix_file_path "$RELATIVE_NIX_FILE_PATH" \
                --arg nix_file_content "$NIX_FILE_CONTENT" \
                --arg has_lock_file "$HAS_LOCK_FILE" \
                '.nodes[] | select(.locked != null) | {sourceFile: $lock_file_path, nixFile: $RELATIVE_NIX_FILE_PATH, nixFileContent: $nix_file_content, hasLockFile: ($has_lock_file | fromjson), url: .locked.url // "N/A", narHash: .locked.narHash // "N/A", owner: .locked.owner // "N/A", repo: .locked.repo // "N/A", rev: .locked.rev // "N/A", type: .locked.type // "N/A"}' \
                > $out/extracted-data-$(basename $LOCK_FILE_PATH).json
              TEMP_JSON_FILES+=" $out/extracted-data-$(basename $LOCK_FILE_PATH).json"
            done
            jq -s 'flatten' $TEMP_JSON_FILES > $out/extracted-data.json
          '';
      in
      {
        packages.default = allExtractedData;
        checks.rawLockData = pkgs.runCommand "raw-lock-data-check"
          {
            rawLockDataDerivations = processedLockFiles;
          }
          ''
            mkdir -p $out
            idx=0
            for drv in $rawLockDataDerivations; do
              ln -s $drv $out/$idx
              idx=$((idx+1))
            done
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
