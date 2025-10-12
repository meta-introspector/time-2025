{ lib
, pkgs
, builtins
, nixCodeIndexerModule
, nGramGeneratorModule
, ...
}:

let
  generate2GramIndexStep3Module = import ./nix_2gram_indexer_step3.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndexStep4 =
    { projectRoot
    , # The root path of the project to index
      name ? "nix-2gram-index"
    ,
    }:
    let
      readIndexedFilesJson = generate2GramIndexStep3Module.generate2GramIndexStep3 {
        inherit projectRoot;
        inherit name;
      };

      indexedFiles = builtins.fromJSON (builtins.readFile readIndexedFilesJson);
    in
    indexedFiles;

in
{
  inherit generate2GramIndexStep4;
}
