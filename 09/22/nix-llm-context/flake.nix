{
  description = "Nix flake for generating LLM context for symbols. (Updated for OEIS)";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Add the main project repository as an input
    # This refers to the repository where this flake.nix resides
    mainProject.url = "github:meta-introspector/time-2025/feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, mainProject }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        primeSieve = import ./lib/prime-sieve.nix { inherit lib; };

        # Function to generate LLM context for a given symbol
        generateLlmContext = { symbol, htmlFileName, keywordsScriptFileName, linksFileName, tutorialsPattern, generatorScript }:
          (pkgs.runCommand "llm-context-${symbol}"
            {
              buildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils pkgs.file pkgs.which ];
              buildCommand = ''"${self}/debug_wrapper.sh" --generator-script="${self}/${generatorScript}" --symbol="${symbol}" --html-file-name="${htmlFileName}" --keywords-script="${keywordsScriptFileName}" --links-file-name="${linksFileName}" --tutorials-pattern="${tutorialsPattern}" --output-dir="$out" --main-project="${mainProject}"'';
            } "");
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

        packages.oeisLlmContext = generateLlmContext {
          symbol = "OEIS";
          htmlFileName = "Online_Encyclopedia_of_Integer_Sequences.html";
          keywordsScriptFileName = "extract_meaningful_keywords.sh";
          linksFileName = "all_extracted_links.md";
          tutorialsPattern = ""; # No specific tutorial pattern for now
          generatorScript = "generate_oeis_llm_txt.sh";
        };

        # New output for zos sequence for a given prime
        packages.zosSequence = prime: pkgs.runCommand "zos-sequence-${toString prime}"
          {
            buildInputs = [ pkgs.bash ];
            buildCommand = ''
              echo "${lib.concatStringsSep "\n" (primeSieve prime)}" > $out/primes.txt
            '';
          }
          { };
      }
    );
}
