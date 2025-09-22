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
        generateLlmContext = { symbol, htmlFileName, keywordsScriptFileName, linksFileName, tutorialsPattern, generatorScript }:
          (pkgs.runCommand "llm-context-${symbol}" {
            src = self;
            LLM_SYMBOL_NAME = symbol;
            LLM_HTML_FILE_NAME = "${self}/wikipedia_cache/${htmlFileName}";
            LLM_KEYWORDS_SCRIPT_FILE_NAME = "${self}/${keywordsScriptFileName}";
            LLM_LINKS_FILE_NAME = "${self}/${linksFileName}";
            LLM_TUTORIALS_PATTERN = tutorialsPattern;
            LLM_OUTPUT_FILE = "$out/llm-context-${symbol}.txt";
            buildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils ];
          } ''
            # Copy the generator script to a temporary location and make it executable
            cp "$src/${generatorScript}" ./generator_script.sh
            chmod +x ./generator_script.sh

            # Execute the generator script, which will read arguments from environment variables
            ./generator_script.sh
          '');
      in
      rec {
        packages.monsterGroupLlmContext = generateLlmContext {
          symbol = "Monster Group";
          htmlFileName = "Monster_group.html";
          keywordsScriptFileName = "extract_meaningful_keywords.sh";
          linksFileName = "all_extracted_links.md";
          tutorialsPattern = "*monster_group*_tiktok_tutorial.md";
          generatorScript = "generate_monster_group_llm_txt.sh";
        };
      }
    );
}