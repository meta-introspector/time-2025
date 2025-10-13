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
        lib = nixpkgs.lib; # Explicitly import lib from nixpkgs

        # Get the extracted data from the previous step's output
        allExtractedData = builtins.fromJSON (builtins.readFile "${extractedData.packages.${system}.default}/grepped-data.json");

        # Function to generate a unique emoji string (placeholder for now)
        # In a real scenario, this could be based on a hash of the data, or a more sophisticated mapping
        generateEmojiString = data:
          let
            # Convert the data to JSON string
            dataJson = builtins.toJSON data;
            # Hash the JSON string to get a unique identifier
            # Hash the JSON string to get a unique identifier
            dataHash = builtins.hashString "sha256" dataJson;
            # Take a substring of the hash to use as an "emoji string"
            # This is a placeholder for a more sophisticated emoji mapping
            emoji = lib.substring 0 8 dataHash;
          in
          emoji;

        # Generate virtual packages for each extracted data item
        virtualPackages = lib.listToAttrs (lib.lists.imap0
          (index: data:
            let
              packageName = lib.strings.sanitizeDerivationName (generateEmojiString data);
            in
            {
              name = packageName;
              value = pkgs.writeText "virtual-package-${packageName}.json" (builtins.toJSON data);
            }
          )
          allExtractedData);
      in
      {
        packages = rec {
          inherit (virtualPackages);
          default = pkgs.runCommand "all-virtual-packages"
            {
              # Pass the paths of the virtual packages as a list of strings
              virtualPackagePaths = builtins.toJSON (lib.attrValues virtualPackages);
              nativeBuildInputs = [ pkgs.jq ]; # For processing JSON
            } ''
            mkdir -p $out
            echo "[]" > $out/all-virtual-packages.json # Initialize an empty JSON array

            # Parse the JSON array of virtual package paths
            jq -r '.[]' <<< "$virtualPackagePaths" | while IFS= read -r vp_path; do
              # Read the content of each virtual package (which is a JSON file)
              cat "$vp_path" >> $out/temp-all-virtual-packages.jsonl
            done

            # Convert the JSONL to a single JSON array
            jq -s '.' $out/temp-all-virtual-packages.jsonl > $out/all-virtual-packages.json
          '';
        };
        checks.virtualPackages = pkgs.runCommand "virtual-packages-check"
          {
            inherit virtualPackages;
          } "echo \"${builtins.toJSON (lib.mapAttrs (name: value: value) virtualPackages)}\" > $out";
      }
    );
}
