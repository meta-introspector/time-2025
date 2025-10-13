{
  description = "A flake to find references to dependencies in flake.nix files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    extractedData = {
      url = "path:../002_extract_data";
    };
    project = {
      url = "path:../.."; # Points to the streamofrandom 2025 root
      flake = false; # Treat as a path, not a flake
    };
  };

  outputs = { self, nixpkgs, flake-utils, extractedData, project }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        extractedDataPath = extractedData.packages.${system}.default;

        greppedData = pkgs.runCommand "grepped-flake-data"
          {
            nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ];
            extractedData = extractedDataPath;
            projectRoot = project; # Pass the project path
          } ''
          mkdir -p $out
          echo "[]" > $out/grepped-data.json

          jq -c '.[]' "$extractedData/extracted-data.json" | while IFS= read -r item; do
            nixFile=$(echo "$item" | jq -r '.nixFile')
            repo=$(echo "$item" | jq -r '.repo')

            # Read the content of the nixFile
            nix_file_content=$(cat "$nixFile")

            grep_results=$(echo "$nix_file_content" | grep -n "$repo" || true)
            item=$(echo "$item" | jq --arg grep_results "$grep_results" '. + {grepResults: $grep_results}')

            echo "$item" >> $out/temp-grepped-data.jsonl
          done

          jq -s '.' $out/temp-grepped-data.jsonl > $out/grepped-data.json
        '';
      in
      {
        packages.default = greppedData;
      }
    );
}
