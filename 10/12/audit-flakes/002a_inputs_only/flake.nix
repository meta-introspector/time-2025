{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectedLocks = {
      url = "path:../001_collect_locks";
    };
    project = {
      url = "path:../../.."; # Points to the streamofrandom 2025 root
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        inputNames = lib.attrNames self.inputs;
        inputCount = lib.length inputNames;
        inputSize = "N/A (complex to calculate without full evaluation)"; # Still a placeholder
      in
      {
        packages.default = pkgs.hello;
        checks.healthcheck = {
          healthy = true;
          inherit inputCount inputSize;
          inputs = inputNames; # Add the list of input names
        };
      }
    );
}
