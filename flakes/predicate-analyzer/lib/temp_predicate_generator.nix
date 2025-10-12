{ lib, pkgs, nixFilesListPath }:

let
  # Read Nix file paths from the provided nixFilesListPath
  nixFilePathsString = builtins.readFile nixFilesListPath;
  nixFiles = lib.strings.splitString "\n" nixFilePathsString;

  # Keywords for content-based predicates
  contentKeywords = [ "2gram" "ngram" "parse" "read" "lines" "qa" "crq" "test" "flake" "pkgs" "lib" "outputs" "imports" ];

  # Custom fileExt function using splitString
  fileExt = filename:
    let
      parts = lib.strings.splitString "." filename;
    in
    if lib.lists.length parts > 1 then lib.lists.last parts else "";

  generatePredicates = file:
    let
      filePath = toString file;
      dirName = lib.strings.removeSuffix ("/" + (baseNameOf filePath)) filePath;
      baseName = baseNameOf filePath;
      extension = fileExt baseName; # Use custom fileExt
      nameWithoutExt = if extension == "" then baseName else lib.strings.removeSuffix ".${extension}" baseName; # Refined nameWithoutExt

      # Split directory into components, filter out empty strings
      pathComponents = lib.lists.filter (s: s != "") (lib.strings.splitString "/" dirName);

      # Predicates for path components (prefixed to avoid clashes)
      pathComponentPredicates = lib.genAttrs pathComponents (comp: true);

      # Predicates for filename parts and extension
      filenamePartPredicates = {
        "filename_base_${nameWithoutExt}" = true;
        "extension_${extension}" = true;
      };

      # Content-based predicates
      fileContent = if builtins.pathExists file then builtins.readFile file else "";
      contentPredicates = lib.genAttrs contentKeywords (keyword: lib.strings.hasInfix keyword fileContent);

      # Combine all predicates. Use // to merge attribute sets, later ones override earlier ones if keys clash.
      allPredicates = pathComponentPredicates // filenamePartPredicates // contentPredicates;
    in
    {
      inherit file;
      filename = baseName;
      predicates = allPredicates;
    };

  # Filter out empty strings from nixFiles list that might result from splitString
  validNixFiles = lib.lists.filter (s: s != "") nixFiles;

  predicateMatrix = lib.map generatePredicates validNixFiles;

  # Collect all unique predicate names across all files
  allPredicateNames = lib.unique (lib.lists.flatten (lib.lists.map (fileData: lib.attrNames fileData.predicates) predicateMatrix));

  # Calculate frequency of each predicate
  predicateFrequencies = lib.foldl'
    (acc: fileData:
      lib.foldl'
        (innerAcc: predicateName:
          if fileData.predicates ? ${predicateName} && fileData.predicates.${predicateName} then
            innerAcc // { ${predicateName} = (innerAcc.${predicateName} or 0) + 1; }
          else
            innerAcc
        )
        acc
        allPredicateNames
    )
    {}
    predicateMatrix;

  # Sort predicates by frequency (most frequent first)
  sortedPredicates = lib.sort
    (a: b: (predicateFrequencies.${a} or 0) > (predicateFrequencies.${b} or 0))
    allPredicateNames;

in { 
  inherit predicateMatrix predicateFrequencies sortedPredicates;
}
