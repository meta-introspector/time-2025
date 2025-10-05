# lib/generate-project-nix/error-isolation.nix
# This module isolates the problematic logic from evaluateNixFile.nix

{ evalResult, file, builtins, errors, types, ... }:

let
  # If evalResult indicates success, check if the value is an attribute set.
  # Otherwise, capture the evaluation error.
  finalResult =
    if evalResult.success then
      if types.attrs.isType evalResult.value then
        { value = evalResult.value; errors = []; }
      else
        { value = null; errors = errors.typeError "attrs" (types.values.type evalResult.value); }
    else
      { value = null; errors = errors.evalError evalResult.error; };
in
finalResult