{ pkgs ? import <nixpkgs> {} }:

let
  crqIds = import ./crq-parser.nix { pkgs = pkgs; };

  # Also allow conventional commit types
  conventionalTypes = ["feat" "fix" "docs" "style" "refactor" "test" "chore"];

  # Allow specific scopes for ITIL categories with numbers
  itilScopes = ["crq-[0-9]+" "inc-[0-9]+" "tsk-[0-9]+"];

  # Construct the regex for the scope part
  scopeRegex = "(\((" + pkgs.lib.concatStringsSep "|" itilScopes + ")\))?";

  crqRegex = "^(" + pkgs.lib.concatStringsSep "|" (crqIds ++ conventionalTypes) + ")" + scopeRegex + ": ";

in
crqRegex

