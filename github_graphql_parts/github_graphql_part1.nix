{ nixpkgs, ... }:

let
  common = import ../../../lib/common-imports.nix { inherit nixpkgs; };
  # Inherit common libraries and builtins
  inherit (common) lib pkgs builtins;

  githubApiUrl = "https://api.github.com/graphql";
