{ pkgs ? import <nixpkgs> {} }:

let
  nixFiles = import ./nix-indexer.nix { inherit pkgs; };

  # Filter for CRQ .foaf.nix files
  foafCrqFiles = pkgs.lib.filter (p: pkgs.lib.hasSuffix ".foaf.nix" p && pkgs.lib.hasPrefix "09/crq-" p) nixFiles;

  # Filter for CRQ .md files
  mdCrqFiles = pkgs.lib.filter (p: pkgs.lib.hasSuffix ".md" p && pkgs.lib.hasPrefix "docs/crqs/CRQ_" p) nixFiles;

  # Function to get CRQ ID from .foaf.nix files (e.g., "crq-001.foaf.nix" -> "CRQ-001")
  getFoafCrqId = path: let
    baseName = builtins.baseNameOf path; # e.g., "crq-001.foaf.nix"
    crqPart = pkgs.lib.substring 0 (pkgs.lib.stringLength baseName - 9) baseName; # "crq-001"
  in
    pkgs.lib.toUpper (pkgs.lib.replaceStrings ["crq-"] ["CRQ-"] crqPart);

  # Function to get CRQ ID from .md files (e.g., "CRQ_041_Title.md" -> "CRQ-041")
  getMdCrqId = path: let
    baseName = builtins.baseNameOf path; # e.g., "CRQ_041_Colosseum_Mirror_Flake.md"
    # Match "CRQ_XXX" part
    matched = builtins.match "CRQ_([0-9]+)_.*\\.md" baseName;
    crqNum = pkgs.lib.head matched; # "041"
  in
    "CRQ-${crqNum}";

  # Extract IDs from both types of files
  foafCrqIds = map getFoafCrqId foafCrqFiles;
  mdCrqIds = map getMdCrqId mdCrqFiles;

  # Combine and deduplicate all CRQ IDs
  allCrqIds = pkgs.lib.unique (foafCrqIds ++ mdCrqIds);

in
allCrqIds
