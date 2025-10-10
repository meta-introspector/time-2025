
(
{
  pkgs ? (builtins.getFlake "nixpkgs").legacyPackages.aarch64-linux,
  lib ? pkgs.lib,
}:

let
  miniPrelude = import ./mini-prelude.nix { inherit pkgs lib; };
in
miniPrelude
) {}
