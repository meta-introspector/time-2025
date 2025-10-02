{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  ...
}:

let
  # A function to generate an index of 2-grams from Nix file paths, with usage pointers.
  generate2GramIndexStep1 = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    # First, index all Nix files in the project
    nixFileIndex = nixCodeIndexerModule.indexNixFiles {
      path = projectRoot;
      projectRoot = projectRoot; # Pass projectRoot to the indexer
      name = "${name}-nix-file-index";
    };
  in
  nixFileIndex;

in
{
  generate2GramIndexStep1 = generate2GramIndexStep1;
}
