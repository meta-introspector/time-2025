{ pkgs ? import <nixpkgs> {}, commitMsgFile ? null }:

let
  commitMsg = builtins.readFile commitMsgFile;

  # Extract scope from commit message
  scope = let
    match = builtins.match "^[a-z]+\(([^)]*)\):" commitMsg;
  in if match != null then builtins.elemAt match 0 else null;

  # Check if scope is a CRQ, Incident, or Task ID
  isCrqIncTsk = scope != null && (builtins.match "^(crq|inc|tsk)-[0-9]+$" scope != null);

  # Placeholder for actual document existence check using index.nix
  documentExists = true; # Temporarily assume true

in
if isCrqIncTsk && !documentExists then
  false # Document not found
else
  true # Valid or no CRQ/Incident/Task scope
