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

    # Manually managed snapshot inputs
    time-2025-snapshot-1 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-2 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-3 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-4 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-5 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-6 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-7 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
    time-2025-snapshot-8 = { url = "github:meta-introspector/time-2025?ref=a62a65a364546734bda438098dc44cefba63380e"; flake = true; };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , actFlake
    , decideFlake
    , observeFlake
    , projectToObserve
    , time-2025-snapshot-1
    , time-2025-snapshot-2
    , time-2025-snapshot-3
    , time-2025-snapshot-4
    , time-2025-snapshot-5
    , time-2025-snapshot-6
    , time-2025-snapshot-7
    , time-2025-snapshot-8
    }:
    let
      lib = nixpkgs.lib; # Move lib definition here

      # Custom attributes for the flake's state, with recursion fix
      # We assume snapshot-1 is the source for the previous generation number
      previousSnapshotInput = time-2025-snapshot-1;

      derivedGeneration =
        if lib.hasAttr "generation" previousSnapshotInput.outputs
        then (builtins.mod previousSnapshotInput.outputs.generation 8) + 1
        else 1; # Start at 1 if no previous snapshot generation

      generation = derivedGeneration; # Use the derived generation

      currentSnapshotInput =
        if generation == 1 then time-2025-snapshot-1
        else if generation == 2 then time-2025-snapshot-2
        else if generation == 3 then time-2025-snapshot-3
        else if generation == 4 then time-2025-snapshot-4
        else if generation == 5 then time-2025-snapshot-5
        else if generation == 6 then time-2025-snapshot-6
        else if generation == 7 then time-2025-snapshot-7
        else time-2025-snapshot-8;
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
