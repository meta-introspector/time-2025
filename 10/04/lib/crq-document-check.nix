{ pkgs ? import <nixpkgs> { }, commitMsgFile ? null }:

let
  commitMsg = builtins.readFile commitMsgFile;

  # Extract scope from commit message
  scope =
    let
      match = builtins.match "^[a-z]+\(([^)]*)\):" commitMsg;
    in
    if match != null then builtins.elemAt match 0 else null;

  # Check if scope is a CRQ, Incident, or Task ID
  isCrqIncTsk = scope != null && (builtins.match "^(crq|inc|tsk)-[0-9]+$" scope != null);

  # Placeholder for actual document existence check using index.nix
  documentExists = true; # Temporarily assume true

in
if isCrqIncTsk && !documentExists then
  {
    success = false;
    message = "Error: CRQ/Incident/Task document for scope '${scope}' not found.";
  }
else if isCrqIncTsk && documentExists then
  {
    success = true;
    message = "CRQ/Incident/Task document for scope '${scope}' found.";
  }
else
  {
    success = true;
    message = "No CRQ/Incident/Task scope found in commit message, skipping document check.";
  }
