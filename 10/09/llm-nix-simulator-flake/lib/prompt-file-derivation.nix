{ pkgs, analyzedNixExpression }:

pkgs.writeText "llm-prompt.txt" ''
  You are a highly intelligent Nix expert. Your task is to simulate the execution
  of a given Nix expression and predict its concrete outcomes.

  Here is an abstract representation of a Nix expression:
  ${builtins.readFile analyzedNixExpression}/abstract-nix.txt

  Based on this, predict the following:
  1.  The expected Nix store path(s) of the primary output(s).
  2.  Any external dependencies that would be fetched (e.g., GitHub repositories, URLs).
  3.  A high-level summary of the build steps involved.
  4.  Potential runtime behavior or side effects.
  5.  Any warnings or errors that might occur during evaluation or build.

  Format your response as a JSON object with keys like "predicted_outputs",
  "external_dependencies", "build_summary", "runtime_behavior", "potential_issues".
''
