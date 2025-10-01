{
  lib,
  pkgs,
  builtins,
  nix2gramIndexerModule,
  ...
}:

let
  # The root of the project to index.
  # For this example, we'll use the current directory (the directory containing this file).
  projectRoot = pkgs.lib.cleanSource ../../../../../../../..; # Adjust path to project root

  # Generate the 2-gram index for the project
  twoGramIndex = nix2gramIndexerModule.generate2GramIndex {
    inherit projectRoot;
    name = "project-2gram-index";
  };
in
twoGramIndex
