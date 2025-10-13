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

        auditMatrix = pkgs.runCommand "audit-matrix-generator"
          {
            nativeBuildInputs = [ pkgs.jq ];
            allVirtualPackagesDataJson = builtins.toJSON allVirtualPackagesData;
            foldScript = ./fold_script.jq;
          } ''
          mkdir -p $out
          echo "$allVirtualPackagesDataJson" | jq -s -f $foldScript > $out/flake-audit-matrix.json
        '';
      in
      {
        packages.default = auditMatrix;
        checks.auditMatrix = auditMatrix;
      }
    );
}
