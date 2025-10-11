{
  description = "Nix flake for exposing search utility functions from lib_search_utils.sh.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # The lib_search_utils.sh script
        libSearchUtilsScript = "${self}/09/22/lib/lib_search_utils.sh";

        # Expose the script as a package
        searchUtilsPackage = pkgs.writeShellScriptBin "lib_search_utils" ''
          source ${libSearchUtilsScript}
          "$@"
        '';

      in
      {
        packages.default = searchUtilsPackage;

        checks = {
          # Check to test a utility function (e.g., get_top_n_terms)
          testSearchUtility = pkgs.runCommand "test-search-utility" {
            nativeBuildInputs = [ pkgs.bash ];
            searchUtils = searchUtilsPackage;
          } ''
            echo "Testing search utility function..."
            # Simulate a file with terms
            echo "apple banana apple orange banana apple" > terms.txt
            
            # Call a function from the script (e.g., get_top_n_terms)
            local result=$(${searchUtils} get_top_n_terms terms.txt 2)
            
            if [[ "$result" == "apple 3\nbanana 2" ]]; then
              echo "Search utility test passed."
            else
              echo "Error: Search utility test failed. Expected 'apple 3\nbanana 2', got '$result'" >&2
              exit 1
            fi
          '';
        };
      }
    );
}
