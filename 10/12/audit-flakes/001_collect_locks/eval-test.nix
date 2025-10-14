{ pkgs, lib, system, bagOfWordsGeneratorPath, flakePath }:

let
  bagOfWordsGenerator = import bagOfWordsGeneratorPath { inherit pkgs lib system; };
in

bagOfWordsGenerator.lib.${system}.generateBagOfWords flakePath
