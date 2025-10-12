# batch-modify-crqs.nix
{ pkgs, lib, ... }:

let
  # List of CRQ FOAF files to modify
  crqFiles = [
    ./crq-008.foaf.nix
    ./crq-009.foaf.nix
    ./crq-010.foaf.nix
    ./crq-011.foaf.nix
    ./crq-012.foaf.nix
    ./crq-013.foaf.nix
  ];

  # Function to modify a single CRQ FOAF file
  modifyCrqFile = file:
    let
      originalContent = builtins.readFile file;
      modifiedContent = lib.replaceStrings [ "\"@type\" = \"Document\";" ] [ "\"@type\" = \"dcterms:Document\";" ] originalContent;
    in
    { path = file; content = modifiedContent; };

  # Apply the modification to all files
  modifiedCrqFiles = lib.map modifyCrqFile crqFiles;

  # A shell script to write the modified content back to the files
  writeScript = pkgs.writeShellScript "batch-modify-crqs" (
    lib.concatStringsSep "\n" (lib.map (f: "echo -n ${lib.escapeShellArg f.content} > ${lib.escapeShellArg f.path}") modifiedCrqFiles)
  );

in
writeScript
