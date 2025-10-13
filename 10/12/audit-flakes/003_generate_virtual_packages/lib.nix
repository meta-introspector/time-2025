{ lib
, pkgs
, extractedData
, nixpkgs
, flake-utils
, system
,
}:

let
  # Get the extracted data from the previous step's output
  allExtractedData = builtins.fromJSON (builtins.readFile "${extractedData.packages.${system}.default}/extracted-data.json");

  # Function to generate a unique emoji string (placeholder for now)
  # In a real scenario, this could be based on a hash of the data, or a more sophisticated mapping
  generateEmojiString = index: "fixme"; # Placeholder to bypass hashString issue

  # Generate virtual packages for each extracted data item
  virtualPackages = lib.listToAttrs (lib.lists.imap0
    (index: data: {
      name = generateEmojiString index;
      value = pkgs.writeText "virtual-package-${generateEmojiString index}.json" (builtins.toJSON data);
    })
    allExtractedData);

in
{
  inherit allExtractedData generateEmojiString virtualPackages;
}
