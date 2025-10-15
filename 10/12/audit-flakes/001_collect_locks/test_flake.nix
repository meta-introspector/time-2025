{
  description = "A flake to test the 001_collect_locks flake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectLocks = {
      url = "path:."; # Reference to the current 001_collect_locks flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectLocks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        checks.testCollectedFiles = pkgs.runCommand "test-collected-files"
          {
            # Get the first collected lock file info
            lockFileInfo = collectLocks.packages.${system}.lock-file-0;
            nativeBuildInputs = [ pkgs.jq ];
          }
          ''
            # Ensure the output is a valid JSON file
            jq . "$lockFileInfo/lock-file-info.json"

            # Check for expected fields
            jq -e 'has("nixFilePath")' "$lockFileInfo/lock-file-info.json"
            jq -e 'has("lockFilePath")' "$lockFileInfo/lock-file-info.json"
            jq -e 'has("nixFileContent")' "$lockFileInfo/lock-file-info.json"

            echo "Collected file info test passed."
          '';
      });
}
