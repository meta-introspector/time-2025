{
  description = "Nix flake for generating bag-of-words from a flake.nix file.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; # Use project's nixpkgs as default
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    bagOfWordsScript = {
      url = "path:../../scripts/generate_flake_bag_of_words.sh";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, bagOfWordsScript }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        lib = {
          generateBagOfWords = flakePath:
            pkgs.runCommandLocal "bag-of-words-report"
              {
                nativeBuildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk pkgs.jq ];
                flakeFile = flakePath;
                script = bagOfWordsScript;
              } ''
              mkdir -p $out
              "$script" "$flakeFile" > $out/report.json
            '';
        };

        docs.md = pkgs.writeText "bag-of-words-generator-docs.md" ''
          # Bag-of-Words Generator Flake

          ## Description

          This Nix flake provides a function to generate a "bag-of-words" report from a given `flake.nix` file. It extracts keywords and their counts from the `flake.nix` content.

          ## Inputs

          -   `nixpkgs`: Standard Nixpkgs input.
          -   `flake-utils`: Utility functions for Nix flakes.
          -   `bagOfWordsScript`: A path to the shell script (`generate_flake_bag_of_words.sh`) that performs the actual bag-of-words generation.

          ## Outputs

          ### `lib.${system}.generateBagOfWords` Function

          This function is the primary interface of the flake. It takes a path to a `flake.nix` file and returns a Nix derivation (package) that, when built, produces a JSON report.

          -   **Input Argument:**
              -   `flakePath`: A string representing the absolute path to a `flake.nix` file.

          -   **Output:**
              -   A Nix derivation (package). When this derivation is built, its output directory will contain a `report.json` file.

          ### `report.json` Structure

          The `report.json` file is a JSON object where keys are words extracted from the `flake.nix` content, and values are their respective counts.
        '';
      });
}
