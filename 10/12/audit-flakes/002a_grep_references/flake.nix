{
  description = "A flake to find references to dependencies in flake.nix files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    extractedData = {
      url = "path:../002_extract_data";
    };
  };

  outputs = { self, nixpkgs, flake-utils, extractedData }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        extractedDataPath = extractedData.packages.${system}.default;

        greppedData = pkgs.runCommand "grepped-flake-data"
          {
            nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ];
            extractedData = extractedDataPath;
          } ''
          mkdir -p $out
          echo "[]" > $out/grepped-data.json

          jq -c '.[]' "$extractedData/extracted-data.json" | while IFS= read -r item; do
            nixFileContent=$(echo "$item" | jq -r '.nixFileContent')
            repo=$(echo "$item" | jq -r '.repo')
            sourceFile=$(echo "$item" | jq -r '.sourceFile') # Keep sourceFile for context
            nixFilePath=$(echo "$item" | jq -r '.nixFilePath') # Keep nixFilePath for context

            # Grep the content directly, not the file path
            grep_results=$(echo "$nixFileContent" | grep -n "$repo" || true)
            item=$(echo "$item" | jq --arg grep_results "$grep_results" --arg nix_file_path "$nixFilePath" '. + {grepResults: $grep_results, nixFilePath: $nix_file_path}')

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
