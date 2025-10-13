{
  description = "A flake to fold extracted flake data into a JSON matrix.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing a JSON file with all aggregated virtual packages
    virtualPackages = {
      url = "path:../003_generate_virtual_packages";
    };
  };

  outputs = { self, nixpkgs, flake-utils, virtualPackages }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Get the aggregated virtual packages data from the previous step's output
        allVirtualPackagesData = builtins.fromJSON (builtins.readFile "${virtualPackages.packages.${system}.default}/all-virtual-packages.json");

        # Function to count unique occurrences of a field
        countUnique = fieldName:
          let
            values = builtins.map (item: item.${fieldName}) allVirtualPackagesData;
            # Group by value and count
            grouped = lib.groupBy (x: x) values;
          in
          lib.mapAttrs
            (value: list: {
              count = builtins.length list;
              value = value;
            })
            grouped;

        # Expose the audit results as a matrix
        auditMatrix = {
          urls = countUnique "url";
          narHashes = countUnique "narHash";
          owners = countUnique "owner";
          repos = countUnique "repo";
          revs = countUnique "rev";
          types = countUnique "type";
        };
      in
      {
        packages.default = pkgs.writeText "flake-audit-matrix.json" (builtins.toJSON auditMatrix);
        checks.auditMatrix = pkgs.runCommand "flake-audit-matrix-check"
          {
            inherit auditMatrix;
          } "echo \"${builtins.toJSON auditMatrix}\" > $out";
      }
    );
}
