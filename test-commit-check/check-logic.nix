{ pkgs, commitMsg, regex }:

let
  isValid = builtins.match regex commitMsg != null;
in
isValid
