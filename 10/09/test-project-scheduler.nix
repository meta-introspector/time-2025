let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # Import the dummy project state
  dummyProjectState = import ./dummy-project-state.nix { inherit pkgs; };

  # Import the project-scheduler-flake
  projectSchedulerFlake = (builtins.getFlake (toString ./project-scheduler-flake)).outputs;

  # Build the optimized schedule
  optimizedSchedule = projectSchedulerFlake.packages.aarch64-linux.default {
    inherit pkgs;
    projectState = dummyProjectState;
    llmApiWrapper = (builtins.getFlake (toString ./llm-api-wrapper)).outputs;
    minizinc = (builtins.getFlake (toString ./minizinc-nix)).outputs;
  };

in
optimizedSchedule
