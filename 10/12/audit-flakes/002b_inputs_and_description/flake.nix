{
  description = "fixme for now";

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
  outputs = { self, nixpkgs, flake-utils, ... } @ args:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        inputNames = lib.attrNames self.inputs;
        inputCount = lib.length inputNames;
        inputSize = "N/A (complex to calculate without full evaluation)";
        healthcheckData = {
          healthy = true;
          inherit inputCount inputSize;
          inputs = inputNames;
          description = "fixme self.description"; # Access description from self
        };
      in
      {
        packages.default = pkgs.runCommand "inputs-and-description-info" { } ''
          mkdir -p $out
          echo '${builtins.toJSON healthcheckData}' > $out/inputs-and-description-info.json
        '';
        checks.healthcheck = healthcheckData;
      }
    );
}
