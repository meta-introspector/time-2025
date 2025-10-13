packages = rec {
inherit (virtualPackages) ;
default = pkgs.runCommand "all-virtual-packages" {
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
