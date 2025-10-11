{ lib, pkgs, builtins, nixTermExtractor, nGramGenerator, ... }:

let
  # List of relative Nix file paths from index/chunks/nix.txt
  nixFilePaths = lib.strings.splitString "\n" (builtins.readFile (./. + "/index/chunks/nix.txt"));

  # Define the n-gram lengths to extract
  nGramLengths = [ 1 2 3 5 7 11 13 17 19 ];

  # Extract unique n-grams from all Nix files
  allUniqueNGrams = lib.lists.unique (lib.lists.flatten (
    lib.lists.map (filePath: 
      # Ensure filePath is relative to the current flake for builtins.readFile
      let absoluteFilePath = (./. + "/${filePath}");
      in nixTermExtractor.extractUniqueNGrams { inherit filePath nGramLengths; } # Pass absoluteFilePath
    ) nixFilePaths
  ));

  # Create a mapping from each unique n-gram to an emoji
  nGramEmojiMap = lib.lists.listToAttrs (
    lib.lists.map (nGram: { 
      name = nGram;
      value = nixTermExtractor.mapTermToEmoji nGram;
    }) allUniqueNGrams
  );

in
{
  inherit nGramEmojiMap;
  inherit allUniqueNGrams;
}

