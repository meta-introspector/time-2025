{ pkgs, lib, globalState, bootstrapPlanExpression, ... }:

let
  # Function to parse the bootstrap plan into a list of steps
  # For now, assume bootstrapPlanExpression is a list of Nix expressions (strings)
  # FIXME: Implement a more robust parser for structured bootstrap plans
  parseBootstrapPlan = planString:
    lib.strings.splitString "\n---\n" planString; # Assuming steps are separated by "---"

  # Get the current step index from the global state, or start from 0
  currentStepIndex = globalState.currentBootstrapStep or 0;

  # Get the parsed steps
  bootstrapSteps = parseBootstrapPlan bootstrapPlanExpression;

  # Determine the next step to execute
  nextStep =
    if currentStepIndex < lib.length bootstrapSteps then
      lib.elemAt bootstrapSteps currentStepIndex
    else
      null; # No more steps

  # Execute a single bootstrap step
  executeStep = stepExpression: pkgs.stdenv.mkDerivation {
    name = "bootstrap-step-${toString currentStepIndex}";
    buildCommand = ''
      echo "Executing bootstrap step ${toString currentStepIndex}:"
      echo "${stepExpression}" > step.nix
      # FIXME: This is a placeholder. Actual execution would involve
      # evaluating the Nix expression and applying its effects.
      # For example, if step.nix defines a package, install it.
      # If it defines a service, enable it.
      # For now, we just echo the expression.
      cat step.nix
      echo "Step ${toString currentStepIndex} executed successfully."
    '';
  };

  # The new global state after executing the current step
  newGlobalState =
    if nextStep != null then
      let
        # Execute the step
        stepResult = executeStep nextStep;
      in
      globalState // {
        currentBootstrapStep = currentStepIndex + 1;
        lastExecutedStepResult = stepResult;
        # Add other state updates as needed
      }
    else
      globalState // { bootstrapComplete = true; };

in
newGlobalState
