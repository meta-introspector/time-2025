{ pkgs ? import <nixpkgs> { } }:

let
  generatedDerivations = import ./eval-tasks.nix { inherit pkgs; };
  generatedDerivationStrings = pkgs.lib.map toString generatedDerivations;
in
generatedDerivationStrings
