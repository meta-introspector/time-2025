{ nixpkgs, ... }:

let
  common = import ../../../lib/common-imports.nix { inherit nixpkgs; };
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  githubApiUrl = "https://api.github.com/graphql";
