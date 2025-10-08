# lib/generate-project-nix/error-constructor.nix
# This module isolates the construction of error attribute sets.

{ file, builtins, ... }:

let
  # Functions to construct error attribute sets
  typeError = expectedType: actualType: {
    value = {};
    errors = [{
      type = "type_error";
      message = "File ${file} evaluated to a ${builtins.toString actualType}, but a ${builtins.toString expectedType} was expected.";
    }];
  };

  evaluationError = errorMessage: {
    value = {};
    errors = [{
      type = "evaluation_error";
      message = "File ${file} failed to evaluate: ${builtins.toString errorMessage}";
    }];
  };
in
{
  inherit typeError evaluationError;
}
