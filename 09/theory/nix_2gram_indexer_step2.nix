let
  pkgs = import <nixpkgs> {};
in
{ lib, pkgs, builtins, nixCodeIndexerModule, nGramGeneratorModule }:
{
  generate2GramIndexStep2 = { projectRoot, name ? "step2-indexed-files-json" }:
    let
      step1Output = nixCodeIndexerModule.indexNixFiles {
        path = projectRoot;
        inherit projectRoot;
      };
      nixFileIndex = step1Output; # nixFileIndex is defined here
      indexedFilesJsonDerivation = pkgs.runCommand "nix-files-json" {
        buildInputs = [ pkgs.nix ];
        __impure = true; # Mark as impure because its input comes from an impure derivation
      } "cat ${nixFileIndex}/nix-files.index.json > $out";
    in
    indexedFilesJsonDerivation;
}
