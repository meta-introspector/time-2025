{
  description = "A flake to audit all flake.lock files in a project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # The project to audit, typically the root of the repository
    project = {
      url = "path:../.."; # Points to the streamofrandom 2025 root
      flake = false; # Treat as a path, not a flake
    };
  };

  outputs = { self, nixpkgs, flake-utils, project }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Function to recursively find all flake.lock files
        findAllFlakeLocks = path:
          let
            # Read directory contents
            dirContents = builtins.readDir path;
            # Filter for flake.lock files directly in this directory
            currentLockFiles = builtins.filter (name: name == "flake.lock" && dirContents.${name} == "regular") (builtins.attrNames dirContents);
            currentLockFilePaths = builtins.map (name: path + "/${name}") currentLockFiles;

            # Recursively search subdirectories
            subDirs = builtins.filter (name: dirContents.${name} == "directory") (builtins.attrNames dirContents);
            recursiveLockFiles = builtins.concatLists (builtins.map (name: findAllFlakeLocks (path + "/${name}")) subDirs);
          in
          currentLockFilePaths ++ recursiveLockFiles;

        allLockFiles = findAllFlakeLocks project; # Start from the project input

        # Function to extract data from a single flake.lock file
        extractDataFromLockFile = lockFile:
          let
            json = builtins.fromJSON (builtins.readFile lockFile);
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
        allExtractedData = builtins.concatLists (builtins.map extractDataFromLockFile allLockFiles);

        # Function to count unique occurrences of a field
        countUnique = fieldName:
          let
            values = builtins.map (item: item.${fieldName}) allExtractedData;
            # Group by value and count
            grouped = lib.groupBy (x: x) values;
          in
          lib.mapAttrs
            (value: list: {
              count = builtins.length list;
              value = value;
            })
            grouped;

        # Expose the audit results
        auditReport = {
          urls = countUnique "url";
          narHashes = countUnique "narHash";
          owners = countUnique "owner";
          repos = countUnique "repo";
          revs = countUnique "rev";
          types = countUnique "type";
        };
      in
      {
        packages.default = pkgs.writeText "flake-audit-report.json" (builtins.toJSON auditReport);
        checks.auditReport = pkgs.runCommand "flake-audit-check"
          {
            report = pkgs.writeText "report.json" (builtins.toJSON auditReport);
          } "cp $report $out";
      }
    );
}
