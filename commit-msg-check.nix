{ pkgs ? import <nixpkgs> { }, commitMsgFile ? null }:

let
  regex = import ./regex-generator.nix { inherit pkgs; };
  # Use the provided commitMsgFile argument, or fall back to pkgs.lib.elemAt (builtins.attrValues pkgs.stdenv.args) 0
  actualCommitMsgFile = if commitMsgFile != null then commitMsgFile else pkgs.lib.elemAt (builtins.attrValues pkgs.stdenv.args) 0;
  commitMsg = builtins.readFile actualCommitMsgFile;

  isValid = builtins.match regex commitMsg != null;

in
if isValid then
  pkgs.runCommand "commit-msg-check-passed" { } "echo 'Commit message is valid.'; exit 0;"
else
  pkgs.runCommand "commit-msg-check-failed" { } ''
    ${pkgs.writeText "run-error-script" ''
      #!${pkgs.bash}/bin/bash
      ${./scripts/commit-msg-error.sh} "${actualCommitMsgFile}" "${regex}"
    ''}
  ''
