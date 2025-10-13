{
  description = "A flake to provide the final audit report as a set of chunked virtual packages.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing the final audit matrix
    foldToMatrix = {
      url = "path:../004_fold_to_matrix";
    };
  };

  outputs = { self, nixpkgs, flake-utils, foldToMatrix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        finalAuditMatrix = builtins.fromJSON (builtins.readFile "${foldToMatrix.packages.${system}.default}");

        # Function to chunk the audit matrix (placeholder for now)
        # This could be more sophisticated, e.g., chunking by field or by size
        chunkData = data: [ data ]; # For now, just return the whole matrix as a single chunk

        # Generate virtual packages for each chunk
        chunkedVirtualPackages = lib.listToAttrs (lib.lists.imap0
          (index: chunk:
            let
              # Generate a unique name for the chunk, appending "005"
              chunkName = lib.strings.sanitizeDerivationName "chunk-${toString index}-005";
            in
            {
              name = chunkName;
              value = pkgs.writeText "audit-chunk-${chunkName}.json" (builtins.toJSON chunk);
            }
          )
          (chunkData finalAuditMatrix));
      in
      {
        packages = rec {
          inherit (chunkedVirtualPackages);
          default = pkgs.runCommand "all-audit-chunks"
            {
              nativeBuildInputs = [ pkgs.jq ];
            } ''
            export chunkedVirtualPackagePaths='${builtins.toJSON (map (v: toString v) (lib.attrValues chunkedVirtualPackages))}'
            mkdir -p $out
            echo "[]" > $out/all-audit-chunks.json # Initialize an empty JSON array

            # Parse the JSON array of chunked virtual package paths
            jq -r '.[]' <<< "$chunkedVirtualPackagePaths" | while IFS= read -r vp_path; do
              # Read the content of each chunked virtual package (which is a JSON file)
              cat "$vp_path" >> $out/temp-all-audit-chunks.jsonl
            done

            # Convert the JSONL to a single JSON array
            jq -s '.' $out/temp-all-audit-chunks.jsonl > $out/all-audit-chunks.json
          '';
        };
        checks.auditReport = pkgs.runCommand "audit-report-check"
          {
            nativeBuildInputs = [ pkgs.jq ];
          } ''
          export chunkedVirtualPackagePaths='${builtins.toJSON (map (v: toString v) (lib.attrValues chunkedVirtualPackages))}'
          mkdir -p $out
          echo "[]" > $out/audit-report.json # Initialize an empty JSON array

          # Parse the JSON array of chunked virtual package paths
          jq -r '.[]' <<< "$chunkedVirtualPackagePaths" | while IFS= read -r vp_path; do
            # Read the content of each chunked virtual package (which is a JSON file)
            cat "$vp_path" >> $out/temp-audit-report.jsonl
          done

          # Convert the JSONL to a single JSON array
          jq -s '.' $out/temp-audit-report.jsonl > $out/audit-report.json
        '';

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 005_final_report

          ## Purpose

          This flake provides the final audit report as a set of chunked virtual packages, suitable for distributed processing.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `foldToMatrix`: The output from the `004_fold_to_matrix` flake, which is a derivation containing the final audit matrix.

          ## Outputs

          *   `packages.default`: A derivation containing all the generated chunked virtual packages.
          *   `packages.<chunk-name>`: Individual virtual packages, each containing a JSON file with a chunk of the audit data.
          *   `checks.auditReport`: A check that outputs the JSON representation of all chunked virtual packages, useful for debugging and verification.

          ## Usage

          To build all chunked virtual packages:

          ```bash
          nix build .#default
          ```

          To build a specific chunked virtual package (e.g., for the first chunk):

          ```bash
          nix build .#packages.chunk-0-005
          cat ./result
          ```

          This flake is designed to enable distributed processing of the audit report.
        '';
      }
    );
}
