{
  description = "Nix flake for generating OEIS index by wrapping generate_oeis_index.sh.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # The generate_oeis_index.sh script
        generateOeisIndexScript = "${self}/scripts/generate_oeis_index.sh";

        # Function to generate the OEIS index
        generateOeisIndex = pkgs.runCommand "oeis-index"
          {
            nativeBuildInputs = [ pkgs.bash ];
            script = generateOeisIndexScript;
          } ''
          bash $script $out
        '';

      in
      {
        lib = { inherit generateOeisIndex; };

        checks = {
          # Check to generate the OEIS index
          generateOeisIndexCheck = pkgs.runCommand "generate-oeis-index-check"
            {
              nativeBuildInputs = [ pkgs.bash pkgs.jq ];
              oeisIndex = generateOeisIndex;
            } ''
            echo "Checking OEIS index generation..."
            local oeis_index_path="$oeisIndex"
            echo "OEIS index generated at: $oeis_index_path"
            # Verify that the index file exists and is not empty
            if [ -s "$oeis_index_path/oeis_index.json" ]; then
              echo "OEIS index file exists and is not empty. Good!"
              cat "$oeis_index_path/oeis_index.json"
            else
              echo "Error: OEIS index file is missing or empty." >&2
              exit 1
            fi
          '';
        };
      }
    );
}
