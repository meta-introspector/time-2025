{ pkgs ? import <nixpkgs> {} }:

let
  crqIds = import ./crq-parser.nix { pkgs = pkgs; };

  # Also allow conventional commit types
  conventionalTypes = ["feat" "fix" "docs" "style" "refactor" "test" "chore"];

  crqRegex = "^(" + pkgs.lib.concatStringsSep "|" (crqIds ++ conventionalTypes) + ")(\([^)]+\))?: ";

in
crqRegex

