{
  description = "Nix flake for generating LLM context for symbols.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Add the main project repository as an input
    # This refers to the repository where this flake.nix resides
    mainProject.url = "path:../"; # Path to the parent directory (the main project root)
  };

  outputs = { self, nixpkgs, flake-utils, mainProject }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Function to generate LLM context for a given symbol
        generateLlmContext = { symbol, htmlFileName, keywordsScriptFileName, linksFileName, tutorialsPattern, generatorScript }:
          (pkgs.runCommand "llm-context-${symbol}" {
            # Use mainProject as the primary source for all data files
            src = mainProject;
            generatorScriptPath = "${self}/nix-llm-context/${generatorScript}";

            buildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils ];
          } ''
            # Execute the generator script with necessary arguments
            # The script will read arguments from environment variables
            # and use the paths provided by Nix.
            "$generatorScriptPath" 
              "${symbol}" 
              "${mainProject}/wikipedia_cache/${htmlFileName}" 
              "${mainProject}/${keywordsScriptFileName}" 
              "${mainProject}/${linksFileName}" 
              "${tutorialsPattern}" 
              "$out/llm-context-${symbol}.txt" 
              "${mainProject.url}" 
              "${mainProject.rev}"
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