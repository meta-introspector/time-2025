{ lib
, pkgs
, builtins
, nixCodeIndexerModule
, nGramGeneratorModule
, ...
}:

let
  generate2GramIndexStep5Module = import ./nix_2gram_indexer_step5.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndexStep6 =
    { projectRoot
    , # The root path of the project to index
      name ? "nix-2gram-index"
    ,
    }:
    let
      all2GramUsages = generate2GramIndexStep5Module.generate2GramIndexStep5 {
        inherit projectRoot;
        inherit name;
      };

      grouped2Grams = builtins.groupBy (usage: usage.value) all2GramUsages;
    in
    grouped2Grams;

in
{
  inherit generate2GramIndexStep6;
}
