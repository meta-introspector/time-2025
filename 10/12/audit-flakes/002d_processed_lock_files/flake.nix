{
  description = "Flake to process collected flake.lock files and extract relevant data.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectedLocksData = {
      url = "path:../002c_collected_locks_derivation";
    };
    project = {
      url = "path:../../.."; # Points to the streamofrandom 2025 root
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectedLocksData, project, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Metadata for this flake
        flakeMetadata = {
          origin = "002d_processed_lock_files";
          purpose = "Processes collected flake.lock files to extract relevant data.";
          input_data_structure = "JSON array of objects, each representing a collected lock file (from 002c_collected_locks_derivation).";
          output_data_structure = "JSON array of objects, each representing extracted data from a single flake.lock file.";
          notes = "This flake applies the 'processedLockFiles' logic from the original 002_extract_raw_data flake.";
        };

        # Access the default package of collectedLocksData, which is a derivation
        # containing collected-locks.json and healthcheck-data.json
        collectedLocksDataDerivation = collectedLocksData.packages.${system}.default;

        # Create a derivation to read and process the JSON file
        processedLockFilesDerivation = pkgs.runCommand "processed-lock-files-data"
          {
            # Make the collectedLocksDataDerivation an input to this derivation
            collectedLocksDataInput = collectedLocksDataDerivation;
            projectRoot = project; # Pass project root as env var
            nativeBuildInputs = [ pkgs.jq ]; # Use jq to parse JSON
          } ''
          mkdir -p $out
          # Read the collected-locks.json file from the input derivation
          cat $collectedLocksDataInput/collected-locks.json > $out/collected-locks.json

          # Iterate over each lock file and apply the processing logic
          TEMP_JSON_FILES=""
          jq -c '.[]' $out/collected-locks.json | while read -r item; do
            NIX_FILE_PATH=$(echo "$item" | jq -r '.nixFilePath')
            LOCK_FILE_PATH=$(echo "$item" | jq -r '.lockFilePath')
            NIX_FILE_CONTENT=$(echo "$item" | jq -r '.nixFileContent')
            HAS_LOCK_FILE=$(echo "$item" | jq -r '.hasLockFile')

            RELATIVE_LOCK_FILE_PATH=$(realpath --relative-to=$projectRoot $LOCK_FILE_PATH)
            RELATIVE_NIX_FILE_PATH=$(realpath --relative-to=$projectRoot $NIX_FILE_PATH)

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

          # Write metadata.json
          echo '${builtins.toJSON flakeMetadata}' > $out/metadata.json
        '';

        # Read the processed data for healthcheck
        allExtractedData = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile "${processedLockFilesDerivation}/extracted-data.json"));
        processedCount = lib.length allExtractedData;
        processedSample = lib.take 3 allExtractedData;

      in
      {
        packages.default = processedLockFilesDerivation; # Output the processed data
        checks.healthcheck = {
          healthy = true;
          inherit processedCount processedSample;
          metadata = flakeMetadata;
        };
      }
    );
}
