{ lib
, pkgs
, mkTask
, flakeSources ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir" ]
, inputFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-inputs" ]
, processFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-processes" ]
, outputFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-outputs" ]
}:

let
  generateTask = flakeSource:
    let
      taskPhases = import ./task-phases.nix {
        inherit lib pkgs flakeSource inputFlakes processFlakes outputFlakes;
      };
    in
    {
      stableId = "phased-task-${lib.strings.sanitizeDerivationName flakeSource}";
      plan = taskPhases.planDerivation;
      commit = taskPhases.commitDerivation;
      run = taskPhases.runDerivation;
      eval = taskPhases.evalDerivation;
    };
in
lib.map generateTask flakeSources
