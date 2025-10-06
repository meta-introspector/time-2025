{
  nix2gramIndexerModule,
  ...
}:

let
  common = import ../../../lib/common-imports.nix {};
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

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
