# Bag-of-Words Generator Flake

## Description

This Nix flake provides a function to generate a "bag-of-words" report from a given `flake.nix` file. The bag-of-words representation is a simplified, sparse representation of text, where the order of words is disregarded, but the frequency of each word is retained. In this context, it extracts keywords and their counts from the `flake.nix` content.

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

The `report.json` file is a JSON object where keys are words extracted from the `flake.nix` content, and values are their respective counts. Words are typically lowercased and punctuation is removed during the generation process.

```json
{
  "word1": count1,
  "word2": count2,
  ...
}
```

## Usage Example (within a Nix expression)

```nix
let
  bagOfWordsGenerator = inputs.bagOfWordsGenerator; # Assuming bagOfWordsGenerator is an input
  flakePath = /path/to/your/flake.nix;
  system = "aarch64-linux"; # Or builtins.currentSystem
  bagOfWordsReport = bagOfWordsGenerator.lib.${system}.generateBagOfWords flakePath;
in
  # You can then build bagOfWordsReport and access its output:
  # nix build .#bagOfWordsReport
  # cat ./result/report.json
```

## Internal Mechanism

The `generateBagOfWords` function uses `pkgs.runCommandLocal` to execute the `bagOfWordsScript` (a shell script) within a sandboxed environment. The `flakePath` is passed as an argument to this script, which then processes the `flake.nix` file and generates the `report.json`.
