{ pkgs ? import <nixpkgs> {} }:

let
  regex = import ./regex-generator.nix { pkgs = pkgs; };
  commitMsgFile = pkgs.lib.elemAt (builtins.attrValues pkgs.stdenv.args) 0;
  commitMsg = builtins.readFile commitMsgFile;

  isValid = builtins.match regex commitMsg != null;

in
if isValid then
  pkgs.runCommand "commit-msg-check-passed" {} "echo 'Commit message is valid.'; exit 0;"
else
  pkgs.runCommand "commit-msg-check-failed" {} "echo 'Error: Commit message does not follow the required format.'; echo 'Allowed formats: CRQ-XXX: <message> or <type>(<scope>): <message>'; exit 1;"
