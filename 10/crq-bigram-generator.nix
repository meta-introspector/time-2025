{ pkgs ? import <nixpkgs> {} }:

let
  crqTexts = import ./crq-text-extractor.nix { inherit pkgs; };
  nGramGenerator = import ../10/01/docs/theory/n_gram_generator.nix { inherit (pkgs) lib; inherit pkgs; inherit builtins; };

  # Simple tokenizer
  tokenize = text:
    let
      lower = builtins.toLower text;
      # Replace punctuation with spaces
      noPunct = pkgs.lib.replaceStrings ["." "," ":" ";" "(" ")" "\n"] [" " " " " " " " " " " " " "] lower;
      words = pkgs.lib.splitString " " noPunct;
      # Filter out empty strings
      tokens = pkgs.lib.filter (s: s != "") words;
    in
    tokens;

  generateBigrams = text:
    let
      tokens = tokenize text;
    in
    nGramGenerator.generateNGrams { inherit tokens; nGramLengths = [ 2 ]; };

  crqBigrams = pkgs.lib.mapAttrs (name: generateBigrams) crqTexts;

in
crqBigrams
