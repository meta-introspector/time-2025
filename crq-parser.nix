{ pkgs ? import <nixpkgs> {} }:

let
  nixFiles = import ./nix-indexer.nix { pkgs = pkgs; };

  crqFiles = pkgs.lib.filter (p: pkgs.lib.hasSuffix ".foaf.nix" p && pkgs.lib.hasPrefix "./09/crq-" p) nixFiles;

  getCrqId = path: let
    baseName = builtins.baseNameOf path;
    # Assuming the format is crq-XXX.foaf.nix
    crqPart = pkgs.lib.substring 0 (pkgs.lib.stringLength baseName - 9) baseName;
  in
    pkgs.lib.toUpper (pkgs.lib.replaceStrings ["-"] [":"] crqPart);

  crqIds = map getCrqId crqFiles;

in
crqIds
