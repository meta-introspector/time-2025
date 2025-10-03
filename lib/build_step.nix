{ lib, pkgs, ... }:

/*
 * Defines the structure for a single build step in the Nix-orchestrated build process.
 * Each step includes pre-build, Nix build, invariance check, and post-build phases.
 *
 * A build step is an attribute set with the following optional fields:
 *   - name: (String) A human-readable name for the step.
 *   - description: (String) A brief description of what the step does.
 *   - prePhase: (Derivation or String) A derivation or shell script to execute before the main Nix build.
 *               This is typically for setup, checks, or data preparation.
 *   - nixBuildPhase: (Derivation) The core Nix derivation for this step. This should be pure and reproducible.
 *   - invarPhase: (Derivation or String) A derivation or shell script for invariance checks.
 *                 This runs after nixBuildPhase and before postPhase, for formal verification
 *                 (e.g., MiniZinc, Lean4) or strong assertions about the build's output.
 *   - postPhase: (Derivation or String) A derivation or shell script to execute after the Nix build
 *                and invariance checks. For cleanup, reporting, or triggering subsequent actions.
 *   - dependencies: (List of Strings) A list of names of other build steps this step depends on.
 */
{
  mkBuildStep = {
    name,
    description ? "",
    prePhase ? null,
    nixBuildPhase ? null,
    invarPhase ? null,
    postPhase ? null,
    dependencies ? [],
  }:
  {
    inherit name description prePhase nixBuildPhase invarPhase postPhase dependencies;
  };
}
