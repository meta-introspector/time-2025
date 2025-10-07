{ pkgs ? import <nixpkgs> {} }:

let
  nixFiles = pkgs.lib.splitString "\n" (builtins.readFile ./index.nix.txt);
in
nixFiles
