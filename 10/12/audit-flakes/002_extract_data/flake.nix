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

        # Create a derivation to extract data from all lock files
        extractedDataDerivation = pkgs.runCommand "extracted-flake-data"
          {
            collectedLocksPath = collectedLocksDerivationPath; # Pass the derivation path
            nativeBuildInputs = [ pkgs.jq ]; # For processing JSON
          } ''
          mkdir -p $out
          echo "[]" > $out/extracted-data.json # Initialize an empty JSON array

          # Read the JSON file containing the list of lock file paths
          allLockFilePathsJson=$(cat "$collectedLocksPath")
          # Parse the JSON array of paths
          jq -r '.[]' <<< "$allLockFilePathsJson" | while IFS= read -r lock_file_path; do
            # Read the content of the lock file and pipe it to jq
            cat "$lock_file_path" | jq -c --arg lock_file_path "$lock_file_path" --arg nix_file_path "$nix_file_path" '.nodes[] | select(.locked != null) | {sourceFile: $lock_file_path, nixFile: $nix_file_path, url: .locked.url // "N/A", narHash: .locked.narHash // "N/A", owner: .locked.owner // "N/A", repo: .locked.repo // "N/A", rev: .locked.rev // "N/A", type: .locked.type // "N/A"}' >> $out/temp-extracted-data.jsonl
          done

          # Convert the JSONL to a single JSON array
          jq -s '.' $out/temp-extracted-data.jsonl > $out/extracted-data.json
        '';

        # The extracted data is now available as a JSON file in the derivation output
        allExtractedData = builtins.fromJSON (builtins.readFile "${extractedDataDerivation}/extracted-data.json");
      in
      {
        packages.default = extractedDataDerivation;
        checks.extractedData = pkgs.runCommand "extracted-flake-data-check"
          {
            inherit extractedDataDerivation;
          } "cp ${extractedDataDerivation}/extracted-data.json $out";

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
