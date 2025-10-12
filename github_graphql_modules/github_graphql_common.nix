{ lib, pkgs, builtins, ... }:

let
  common = import ../../../lib/common-imports.nix { };
  # Inherit common libraries and builtins
  inherit (common) lib pkgs builtins;

  githubApiUrl = "https://api.github.com/graphql";

in
{
  inherit lib pkgs builtins githubApiUrl;
}
