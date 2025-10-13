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
            sourceFile=$(echo "$item" | jq -r '.sourceFile')
            repo=$(echo "$item" | jq -r '.repo')

            flakeFile=$(echo "$sourceFile" | sed 's/flake.lock/flake.nix/')

            if [ -f "$flakeFile" ]; then
              grep_results=$(grep -n "$repo" "$flakeFile" || true)
              item=$(echo "$item" | jq --arg grep_results "$grep_results" '. + {grepResults: $grep_results}')
            fi

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
