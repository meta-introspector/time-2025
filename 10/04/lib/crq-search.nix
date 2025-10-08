{ pkgs, keyword ? null, crqDir }:

let
  # crqDir is now passed as an argument for pure evaluation context

  # Function to extract CRQ ID and Title from filename
  parseCrqFilename = filename:
    let
      # Example: CRQ_001_Log_Analysis_Pure_Derivation.md
      # Match CRQ_XXX_ and then the rest as title
      match = builtins.match "CRQ_([0-9]+)_(.*)\.md" filename;
    in
    if match != null then
      {
        id = builtins.elemAt match 0;
        title = builtins.replaceStrings [ "_" ] [ " " ] (builtins.elemAt match 1);
        inherit filename;
      }
    else
      null;

  # Read all files in the CRQ directory
  allCrqFiles = builtins.filter (name: builtins.hasSuffix ".md" name) (builtins.attrNames (builtins.readDir crqDir));

  # Parse all CRQ files
  parsedCrqs = builtins.filter (crq: crq != null) (builtins.map parseCrqFilename allCrqFiles);

  # Filter by keyword if provided
  filteredCrqs =
    if keyword != null then
      builtins.filter (crq: builtins.match ".*${builtins.toLower keyword}.*" (builtins.toLower crq.title) != null) parsedCrqs
    else
      parsedCrqs;

  # Sort by CRQ ID (descending for latest)
  sortedCrqs = pkgs.lib.sort (a: b: builtins.compareVersion a.id b.id > 0) filteredCrqs;

  # Get the latest 3 suggestions
  suggestions = pkgs.lib.take 3 sortedCrqs;

in
suggestions
