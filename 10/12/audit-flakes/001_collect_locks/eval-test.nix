{ pkgs, lib, system, bagOfWordsGeneratorPath, flakePath }:

let
  bagOfWordsGenerator = import bagOfWordsGeneratorPath { inherit pkgs lib system; };
in

toString (bagOfWordsGenerator.lib.${system}.generateBagOfWords flakePath)
