{
  description = "Consolidated development environment for streamofrandom/2025, incorporating pick-up-nix2 and gemini-cli devShells.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    # Input for the main pick-up-nix2 project
    pick-up-nix.url = "github:meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify"; # Relative path to the project root

    # Input for the vendored gemini-cli
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, pick-up-nix, gemini-cli, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import the devShells from the input flakes
        pickUpNixDevShell = pick-up-nix.devShells.${system}.default;
        geminiCliDevShell = gemini-cli.devShells.${system}.default;

        lib = pkgs.lib;
        buildStepsLib = import ./lib/build_step.nix { inherit lib pkgs; };
        captureTelemetryScript = pkgs.writeShellScript "capture-telemetry" (builtins.readFile ./capture_telemetry.sh);

        orchestrateBuildStep = buildStep:
          let
            # Helper to create a derivation for a phase
            mkPhaseDerivation = phaseName: phaseScript:
              if phaseScript == null then null
              else pkgs.runCommand "${buildStep.name}-${phaseName}" {} ''
                ${captureTelemetryScript} "${phaseScript}"
              '';

            preDerivation = mkPhaseDerivation "pre" buildStep.prePhase;
            nixBuildDerivation = buildStep.nixBuildPhase; # Assumed to be a derivation already
            invarDerivation = mkPhaseDerivation "invar" buildStep.invarPhase;
            postDerivation = mkPhaseDerivation "post" buildStep.postPhase;

            # Combine phases into a single executable derivation
            # This is a simplified orchestration. In a real scenario, dependencies
            # between phases and error handling would be more robust.
            combinedDerivation = pkgs.runCommand "${buildStep.name}-orchestrated" {
              inherit (buildStep) description;
              # Ensure all phase derivations are built before this one
              _pre = preDerivation;
              _nix = nixBuildDerivation;
              _invar = invarDerivation;
              _post = postDerivation;
            } ''
              echo "--- Orchestrating build step: ${buildStep.name} ---"
              ${lib.optionalString (preDerivation != null) "$_pre"}
              ${lib.optionalString (nixBuildDerivation != null) "echo \"Running Nix build for ${buildStep.name}\"; nix build $_nix"}
              ${lib.optionalString (invarDerivation != null) "$_invar"}
              ${lib.optionalString (postDerivation != null) "$_post"}
              echo "--- Build step ${buildStep.name} complete ---"
              mkdir -p $out
              echo "Orchestrated build step ${buildStep.name} completed successfully." > $out/result
            '';
          in
          combinedDerivation;
      in
      {
        devShells.default = pkgs.mkShell {
          # Combine buildInputs from both devShells
          buildInputs =
            pickUpNixDevShell.buildInputs
            ++ geminiCliDevShell.buildInputs
            ++ [
              # Add any additional tools specific to streamofrandom/2025 here
              pkgs.pre-commit # Ensure pre-commit is available
              pkgs.vale # Ensure vale is available for pre-commit hooks
            ];

          # Combine shellHooks from both devShells
          shellHook = ''
            echo "Entering consolidated streamofrandom/2025 development shell."
            ${pickUpNixDevShell.shellHook or ""}
            ${geminiCliDevShell.shellHook or ""}
            # Add any additional shell commands specific to streamofrandom/2025 here
            echo "Consolidated devShell ready."
          '';

          # Inherit environment variables if necessary, or define new ones
          # inherit (pickUpNix2DevShell) env;
          # inherit (geminiCliDevShell) env;
        };

        apps.run-task-interactive = {
          type = "app";
          program = let
            script = pkgs.writeScript "run-gemini-interactive" ''
              #!${pkgs.bash}/bin/bash
              mkdir -p logs
              # strace_file=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
              # strace -f -o logs/strace_$strace_file.txt -s 9999
              ${gemini-cli}/bundle/gemini.js --output-format json \
                                          --approval-mode yolo \
                                          --model gemini-2.5-flash \
                                          --checkpointing \
                                          --prompt-interactive "$@"
            '';
          in "${script}";
        }; # Closes apps.run-task-interactive
        packages = {
          exampleBuildStep = orchestrateBuildStep (
            buildStepsLib.mkBuildStep {
              name = "root-pre-nix-check";
              description = "Ensures no unstaged or uncommitted Nix files before running Nix commands.";
              prePhase = pkgs.writeShellScript "pre-nix-check-script" ''
                if git status --porcelain -- '*.nix' | grep -q .; then
                  echo "ERROR: Unstaged or uncommitted Nix files found. Please commit or stash them before proceeding."
                  git status --porcelain -- '*.nix'
                  exit 1
                fi
                echo "--- Pre-Nix check passed. No unstaged or uncommitted Nix files found. ---"
              '';
              nixBuildPhase = null; # No direct Nix build for this check
              invarPhase = null;
              postPhase = null;
            }
          );
        };
      }
    );
}