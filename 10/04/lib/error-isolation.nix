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
        { value = null; errors = []; }
    else
      { value = null; errors = []; };
in
finalResult