let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # The Nix expression to simulate (e.g., our nar-bridge-flake)
  nixExpressionToSimulate = pkgs.runCommand "nix-expression-to-simulate" {} ''
    mkdir -p $out
    cp ${../hackathon/nar-bridge-flake/flake.nix} $out/flake.nix
  '';

  # Define llmApiWrapper as a flake input here
  llmApiWrapper = (builtins.getFlake (toString ./llm-api-wrapper)).outputs;

  # Import the LLM Nix Simulator Flake
  llmNixSimulatorFlake = (builtins.getFlake (toString ./llm-nix-simulator-flake)).outputs;

  # Build the simulated Nix run
  simulatedRun = llmNixSimulatorFlake.packages.aarch64-linux.default {
    inherit pkgs nixExpressionToSimulate llmApiWrapper;
  };

in
  simulatedRun