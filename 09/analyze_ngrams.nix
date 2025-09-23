let
  # Import nixpkgs for the "lib" functions.
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  # Path to the JSON file.
  ngramFile = ./ngram_index.json;

  # Read and parse the JSON file.
  # WARNING: This will load the entire ngram_index.json file into memory.
  ngramData = builtins.fromJSON (builtins.readFile ngramFile);

  # Convert the attribute set to a list of { name, value } pairs.
  ngramList = lib.mapAttrsToList (name: value: { inherit name value; }) ngramData;

  # Sort the list by value in descending order.
  sortedNgrams = lib.sort (a: b: lib.higher a.value b.value) ngramList;

  # Take the top 10.
  top10Ngrams = lib.take 10 sortedNgrams;
in
top10Ngrams
