
{ system ? "aarch64-linux" }:

let
  nixpkgs = import (builtins.fetchGit {
    url = "https://github.com/meta-introspector/nixpkgs";
    ref = "feature/CRQ-016-nixify";
  }) { inherit system; };
in
{
  inherit nixpkgs;
  lib = nixpkgs.lib;
  pkgs = nixpkgs;
  builtins = builtins;
}

