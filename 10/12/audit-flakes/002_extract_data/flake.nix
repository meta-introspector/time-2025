{
  description = "A flake to extract data from a list of flake.lock files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing a JSON file with a list of flake.lock paths
    collectedLocks = {
      url = "path:../001_collect_locks";
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectedLocks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Get the list of flake.lock file paths from the previous step's output
        allLockFilePaths = builtins.fromJSON (builtins.readFile "${collectedLocks.packages.${system}.default}");

        # Function to extract data from a single flake.lock file
        extractDataFromLockFile = lockFilePath:
          let
            json = builtins.fromJSON (builtins.readFile lockFilePath);
            nodes = lib.attrValues json.nodes; # Get all nodes
            # Filter out the 'root' node if it's just a reference
            filteredNodes = builtins.filter (node: node ? locked) nodes;
          in
          builtins.map
            (node: {
              url = node.locked.url or "N/A";
              narHash = node.locked.narHash or "N/A";
              owner = node.locked.owner or "N/A";
              repo = node.locked.repo or "N/A";
              rev = node.locked.rev or "N/A";
              type = node.locked.type or "N/A";
            })
            filteredNodes;

        # Aggregate data from all lock files
        allExtractedData = builtins.concatLists (builtins.map extractDataFromLockFile allLockFilePaths);
      in
      {
        packages.default = pkgs.writeText "extracted-flake-data.json" (builtins.toJSON allExtractedData);
        checks.extractedData = pkgs.runCommand "extracted-flake-data-check"
          {
            inherit allExtractedData;
          } "echo \"${builtins.toJSON allExtractedData}\" > $out";
      }
    );
}
