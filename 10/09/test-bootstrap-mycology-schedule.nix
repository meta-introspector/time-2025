let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # Import all the necessary flakes
  zosSporeVialFlake = (builtins.getFlake (toString ./zos-spore-vial-flake)).outputs;
  sporeCultivationLabFlake = (builtins.getFlake (toString ./spore-cultivation-lab-flake)).outputs;
  hackathonConsumerFlake = (builtins.getFlake (toString ../hackathon/consumer)).outputs; # This is the consumer flake
  llmDataExtractorFlake = (builtins.getFlake (toString ./llm-data-extractor-flake)).outputs;
  projectSchedulerFlake = (builtins.getFlake (toString ./project-scheduler-flake)).outputs;
  llmApiWrapper = (builtins.getFlake (toString ./llm-api-wrapper)).outputs;
  minizinc = (builtins.getFlake (toString ./minizinc-nix)).outputs;
  narBridgeFlake = (builtins.getFlake (toString ../hackathon/nar-bridge-flake)).outputs;
  bridgeInstanceFlake = (builtins.getFlake (toString ../hackathon/bridge)).outputs; # The actual bridge instance

  # Import the top-level orchestration flake
  bootstrapMycologyScheduleFlake = (builtins.getFlake (toString ./bootstrap-mycology-schedule-flake)).outputs;

  # Build the final schedule
  finalSchedule = bootstrapMycologyScheduleFlake.packages.aarch64-linux.default {
    inherit pkgs zosSporeVialFlake sporeCultivationLabFlake
            llmDataExtractorFlake projectSchedulerFlake
            llmApiWrapper minizinc narBridgeFlake bridgeInstanceFlake;
    # hackathonConsumerFlake is implicitly used by bridgeInstanceFlake
  };

in
  finalSchedule