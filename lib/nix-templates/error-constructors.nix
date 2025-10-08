# lib/nix-templates/error-constructors.nix
# Abstraction for creating structured error entries.
{ lib, builtins, ... }:

file: # The file context for the error message
let
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
