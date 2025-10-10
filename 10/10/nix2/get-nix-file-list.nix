
{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
}:

let
  miniPrelude = import ./mini-prelude.nix { inherit pkgs lib; };
in
miniPrelude
