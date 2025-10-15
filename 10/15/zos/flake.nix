{
  description = "ZOS Orchestrator: Coordinates the Act, Decide, and Observe tasks.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    self = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; }; # Hardcode the commit hash and explicitly set flake = true

    actFlake = { url = "path:./tasks/act"; };
    decideFlake = { url = "path:./tasks/decide"; };
    observeFlake = { url = "path:./tasks/observe"; };

    projectToObserve = {
      url = "path:../.."; # Points to the time-2025 repository root
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, actFlake, decideFlake, observeFlake, projectToObserve }:
    let
      lib = nixpkgs.lib; # Move lib definition here

      # Custom attributes for the flake's state
      generation = 3; # Hardcode generation to 1
      commitHash = "a62a65a364546734bda438098dc44cefba63380e"; # Hardcode the commit hash
      gitRepoName = "time-2025"; # Hardcode for now, can be parsed from self.url
      branchName = "feature/aimyc-003-cultivation"; # Hardcode for now, can be parsed from self.url
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = {
            default = pkgs.runCommand "zos-status-report"
              {
                nativeBuildInputs = [ pkgs.jq ];
                inherit generation commitHash gitRepoName branchName; # Use derivedGeneration
              } ''
              set -x
              mkdir -p $out
              echo "{ \"generation\": $generation, \"commitHash\": \"$commitHash\", \"gitRepoName\": \"$gitRepoName\", \"branchName\": \"$branchName\", \"status\": \"ready\" }" | jq . > $out/status-report.json
            '';
          };

          checks = {
            healthcheck = pkgs.runCommand "orchestrator-healthcheck"
              {
                nativeBuildInputs = [ pkgs.jq ];
                description = self.description; # Use self.description
                flakeInputs = builtins.toJSON (lib.attrNames self.inputs);
                system = system;
              } ''
              set -x
              mkdir -p $out
              echo "{ \"healthy\": true, \"description\": \"$description\", \"flakeInputs\": $flakeInputs, \"system\": \"$system\" }" | jq . > $out/healthcheck.json
            '';
          };
        }) // {
      # Expose generation as a top-level output
      generation = generation;
    };
}
