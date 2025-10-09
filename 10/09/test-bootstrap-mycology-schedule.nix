let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # Import all the necessary flakes
  zosSporeVialFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/zos-spore-vial-flake").outputs;
  sporeCultivationLabFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/spore-cultivation-lab-flake").outputs;
  hackathonConsumerFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/consumer").outputs; # This is the consumer flake
  llmDataExtractorFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/llm-data-extractor-flake").outputs;
  projectSchedulerFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/project-scheduler-flake").outputs;
  llmApiWrapper = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/llm-api-wrapper").outputs;
  minizinc = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/minizinc-nix").outputs;
  narBridgeFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/nar-bridge-flake").outputs;
  bridgeInstanceFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/bridge").outputs; # The actual bridge instance
  mctsSolanaFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/mcts-solana-flake").outputs; # Import the MCTS Solana Flake

  # Import the GitHub Data Fetcher Flake
  githubDataFetcherFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/github-data-fetcher-flake").outputs;

  # Import the top-level orchestration flake
  bootstrapMycologyScheduleFlake = (builtins.getFlake "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/bootstrap-mycology-schedule-flake").outputs;

  # Build the final schedule
  finalSchedule = bootstrapMycologyScheduleFlake.packages.aarch64-linux.default {
    inherit pkgs zosSporeVialFlake sporeCultivationLabFlake
            llmDataExtractorFlake projectSchedulerFlake
            llmApiWrapper minizinc narBridgeFlake bridgeInstanceFlake
            mctsSolanaFlake githubDataFetcherFlake; # Add githubDataFetcherFlake
    # hackathonConsumerFlake is implicitly used by bridgeInstanceFlake
  };

in
  finalSchedule