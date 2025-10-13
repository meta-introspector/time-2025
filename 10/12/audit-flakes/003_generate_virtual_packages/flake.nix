{
  description = "A flake to generate virtual packages and emoji strings from extracted flake data.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing a JSON file with extracted data
    extractedData = {
      url = "path:../002_extract_data";
    };
  };

  outputs = { self, nixpkgs, flake-utils, extractedData }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Get the extracted data from the previous step's output
        allExtractedData = builtins.fromJSON (builtins.readFile "${extractedData.packages.${system}.default}/extracted-data.json");

        # Function to generate a unique emoji string (placeholder for now)
        # In a real scenario, this could be based on a hash of the data, or a more sophisticated mapping
        generateEmojiString = index: lib.substring 0 1 (lib.hashString "sha256" (builtins.toJSON index)); # Placeholder

        # Generate virtual packages for each extracted data item
        virtualPackages = lib.listToAttrs (lib.mapWithIndex
          (index: data: {
            name = generateEmojiString index;
            value = pkgs.writeText "virtual-package-${generateEmojiString index}.json" (builtins.toJSON data);
          })
          allExtractedData);
      in
      {
        packages = virtualPackages; # Expose all virtual packages
        checks.virtualPackages = pkgs.runCommand "virtual-packages-check"
          {
            inherit virtualPackages;
          } "echo \"${builtins.toJSON (lib.mapAttrs (name: value: value) virtualPackages)}\" > $out";
      }
    );
}
