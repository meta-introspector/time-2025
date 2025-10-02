{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  nGramGeneratorModule,
  ...
}:

let
  generate2GramIndexStep1Module = import ./nix_2gram_indexer_step1.nix { inherit lib pkgs builtins nixCodeIndexerModule; };

  generate2GramIndexStep2 = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    nixFileIndex = generate2GramIndexStep1Module.generate2GramIndexStep1 {
      projectRoot = projectRoot;
      name = name;
    };

    # Read the indexed files from the JSON output
    indexedFilesJsonDerivation = pkgs.runCommand "${name}-indexed-files-json" {
      buildInputs = [ nixFileIndex ];
      __impure = true; # Mark as impure because its input comes from an impure derivation
    } "cat ${nixFileIndex}/nix-files.index.json > $out";
  in
  indexedFilesJsonDerivation;

in
{
  generate2GramIndexStep2 = generate2GramIndexStep2;
}
