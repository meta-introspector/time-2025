{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    meta-introspector-flake.url = "github:meta-introspector/time-2025?dir=09&ref=feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, meta-introspector-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        secretScannerModule = import "${meta-introspector-flake}/10/01/docs/theory/secret_scanner.nix" { inherit lib pkgs; };
      in
      {
        packages.test-secret-scanner = pkgs.runCommand "test-secret-scanner" {
          # Try to call a function from the module to see if it evaluates
          output = builtins.toJSON (secretScannerModule.scanForSecrets {
            filePath = "/dev/null";
            name = "test-scan";
          });
        } "echo \"$$output\" > $$out";
      }
    );
}
