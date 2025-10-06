let
  # Import nixpkgs for the "lib" functions.
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  # Path to the JSON file.
  ngramFile = ./ontology_ngrams.json;

  # Read and parse the JSON file.
  # WARNING: This will load the entire ngram_index.json file into memory.
  ngramData = builtins.fromJSON (builtins.readFile ngramFile);

  # Access the "1-gram" array from the parsed JSON data.
  ngramList = ngramData."1-gram";

  # Sort the list by value in descending order.
  sortedNgrams = lib.sort (a: b: a.value > b.value) ngramList;

  # Take the top 10.
  top10Ngrams = lib.take 10 sortedNgrams;
in
builtins.toJSON ngramList
