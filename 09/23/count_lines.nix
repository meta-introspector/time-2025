let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  ngramFile = ./ngram_index.json;
  fileContent = builtins.readFile ngramFile;
  lines = lib.splitString "\n" fileContent;
  lineCount = lib.length lines;
in
lineCount
