{
  description = "A flake to sanitize extracted data by converting absolute paths to relative paths.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    extractedRawData = {
      url = "path:../002_extract_raw_data";
    };
    project = {
      url = "path:../../.."; # Points to the streamofrandom 2025 root
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, extractedRawData, project }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        extractedRawDataPath = extractedRawData.packages.${system}.default;

        sanitizedData = pkgs.runCommand "sanitized-extracted-data"
          {
            nativeBuildInputs = [ pkgs.jq ];
            extractedRawDataInput = extractedRawDataPath;
            PROJECT_ROOT = project;
          }
          ''
            mkdir -p $out
            jq --arg project_root "$PROJECT_ROOT" ' 
              .[] |
              .sourceFile = (.sourceFile | sub("^" + $project_root + "/"; "")) |
              .nixFile = (.nixFile | sub("^" + $project_root + "/"; ""))
            ' "$extractedRawDataInput/extracted-data.json" > $out/sanitized-data.json
          '';
      in
      {
        packages.default = sanitizedData;
        # checks.sanitizedData = pkgs.runCommand "sanitized-data-check"
        #   {
        #     sanitizedDataDerivation = sanitizedData;
        #   }
        #   "cp $sanitizedDataDerivation/sanitized-data.json $out/sanitized-data.json";

        checks.debugLsSource = pkgs.runCommand "debug-ls-source"
          {
            sourceToInspect = sanitizedData;
          }
          "ls -lR $sourceToInspect > $out";

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 003_sanitize_extracted_data

          ## Purpose

          This flake is the third step in the flake audit process. It takes the raw extracted data (output from `002_extract_raw_data`) and sanitizes it by converting absolute paths to relative paths.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `extractedRawData`: The output from the `002_extract_raw_data` flake, which is a derivation containing a JSON file with raw extracted data (including absolute paths).
          *   `project`: The root path of the project, used to calculate relative paths.

          ## Outputs

          *   `packages.default`: A derivation containing a JSON file (`sanitized-data.json`) which is a single JSON array containing all extracted data with sanitized (relative) paths.
          *   `checks.sanitizedData`: A check that outputs the same JSON data, useful for debugging and verification.

          ## Usage

          To build the default package (the JSON file containing all sanitized data):

          ```bash
          nix build .#default
          ```

          To inspect the sanitized data (for debugging):

          ```bash
          nix build .#checks.sanitizedData
          cat ./result
          ```

          This flake is designed to be chained with subsequent flakes in the audit process.
        '';
      }
    );
}
