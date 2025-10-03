#!/usr/bin/env bash

# This script defines and runs a non-interactive Nix job for log analysis.
# It leverages the Nixified Gemini for processing.

set -euo pipefail

# Define the experiment name and directory
EXPERIMENT_NAME="log_analysis_experiment"
EXPERIMENT_DIR="10/03/${EXPERIMENT_NAME}"

# Create the experiment directory
mkdir -p "$EXPERIMENT_DIR"

# Define the Nix flake for this task
# shellcheck disable=SC2016,SC1078,SC1079
FLAKE_CONTENT='''
{
  description = "Non-interactive log analysis task using Nixified Gemini";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, ... }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Define a non-interactive job
        jobs.logAnalysis = pkgs.runCommand "log-analysis-job" { }
          ''
            echo "--- Running non-interactive log analysis job ---"
            # Placeholder for actual log analysis logic using Nixified Gemini
            # Example: gemini-cli.packages.${system}.default --non-interactive --log-file ~/today/llm/logs/telemetry.log
            echo "Log analysis job completed (placeholder)."
            mkdir -p $out
            echo "Log analysis results" > $out/results.txt
          '';
      }
    );
}
'''

# Create the flake.nix file within the experiment directory
echo "$FLAKE_CONTENT" > "$EXPERIMENT_DIR/flake.nix"

# Run the Nix job
echo "--- Running Nix log analysis job ---"
nix build "$EXPERIMENT_DIR"#jobs.logAnalysis

echo "--- Non-interactive log analysis task complete ---"
