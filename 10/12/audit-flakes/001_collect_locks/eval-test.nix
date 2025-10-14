{ system, bagOfWordsGeneratorPath, flakePath }:

let
  bagOfWordsGeneratorFlake = builtins.getFlake bagOfWordsGeneratorPath;
  bagOfWordsGenerator = bagOfWordsGeneratorFlake.lib.${system};
in

bagOfWordsGenerator.generateBagOfWords flakePath
