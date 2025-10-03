
{ system ? "aarch64-linux", nixpkgs }:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  inherit nixpkgs pkgs;
  lib = nixpkgs.lib;
  builtins = builtins;
}

