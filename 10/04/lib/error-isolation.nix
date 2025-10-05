# lib/generate-project-nix/error-isolation.nix
# This module isolates the problematic logic from evaluateNixFile.nix

{ evalResult, file, builtins, errorHelpers, types, ... }:

let
  # If evalResult indicates success, check if the value is an attribute set.
  # Otherwise, capture the evaluation error.
  finalResult =
    if evalResult.success then
      if types.attrs.isType evalResult.value then
        { value = evalResult.value; errors = []; }
      else
        let typeErrors = errorHelpers.typeError "attrs" (types.values.type evalResult.value); in
        { value = null; errors = typeErrors; }
    else
      let evalErrors = errorHelpers.evalError evalResult.error; in
      { value = null; errors = evalErrors; };
in
finalResult