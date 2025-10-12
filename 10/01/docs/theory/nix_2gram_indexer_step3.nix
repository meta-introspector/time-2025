{ lib
, pkgs
, builtins
, nixCodeIndexerModule
, nGramGeneratorModule
, ...
}:

let
  generate2GramIndexStep2Module = import ./nix_2gram_indexer_step2.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndexStep3 =
    { projectRoot
    , # The root path of the project to index
      name ? "nix-2gram-index"
    ,
    }:
    let
      indexedFilesJsonDerivation = generate2GramIndexStep2Module.generate2GramIndexStep2 {
        inherit projectRoot;
        inherit name;
      };
    in
    indexedFilesJsonDerivation;

in
{
  inherit generate2GramIndexStep3;
}
