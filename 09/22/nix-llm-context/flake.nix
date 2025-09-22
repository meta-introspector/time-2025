{
  description = "Nix flake for generating LLM context for symbols.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Function to generate LLM context for a given symbol
        generateLlmContext = { symbol, htmlFileName, keywordsScriptFileName, linksFileName, tutorialsPattern }:
          pkgs.runCommand "llm-context-${symbol}" {
            src = self;
            buildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils ];
          } ''
            # Navigate to the source directory within the build environment
            cd "$src"

            OUTPUT_FILE="$out/llm-context-${symbol}.txt"
            echo "# ${symbol} - LLM Context" > "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            echo "## Wikipedia Content" >> "$OUTPUT_FILE"
            cat "wikipedia_cache/${htmlFileName}" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            echo "## Extracted Keywords" >> "$OUTPUT_FILE"
            "./${keywordsScriptFileName}" "wikipedia_cache/${htmlFileName}" 10 | sed 's/^[ ]*[0-9]* //g' >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            echo "## Related Links" >> "$OUTPUT_FILE"
            grep -i "${symbol// /_}" "${linksFileName}" >> "$OUTPUT_FILE" # Replace spaces for grep pattern
            echo "" >> "$OUTPUT_FILE"

            echo "## Related TikTok Tutorials" >> "$OUTPUT_FILE"
            find . -maxdepth 1 -type f -name "${tutorialsPattern}" | sed 's#./##' | while read -r tutorial;
              echo "- $tutorial" >> "$OUTPUT_FILE"
            done
            echo "" >> "$OUTPUT_FILE"
          ''
      in
      rec {
        packages.monsterGroupLlmContext = generateLlmContext {
          symbol = "Monster Group";
          htmlFileName = "Monster_group.html";
          keywordsScriptFileName = "extract_meaningful_keywords.sh";
          linksFileName = "all_extracted_links.md";
          tutorialsPattern = "*monster_group*_tiktok_tutorial.md";
        };
      }
    );
}
