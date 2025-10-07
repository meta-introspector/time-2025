{ lib, pkgs, builtins, nixCodeIndexerModule, nGramGeneratorModule }:
{
  generate2GramIndexStep1 = { projectRoot, name ? "step1-nix-file-index" }:
    let
      nixFilesIndex = nixCodeIndexerModule.indexNixFiles {
        path = projectRoot;
        inherit projectRoot;
      };
    in
    nixFilesIndex;
}
