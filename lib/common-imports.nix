{ system ? "aarch64-linux", nixpkgs }:

let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  inherit nixpkgs pkgs;
  inherit (nixpkgs) lib;
  inherit builtins;
}

