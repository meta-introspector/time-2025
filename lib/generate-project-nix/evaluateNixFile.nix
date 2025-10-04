# lib/generate-project-nix/evaluateNixFile.nix
#
# Helper function to safely evaluate a Nix expression (file or function result).
# Returns { value = <evaluated_result>, errors = [] } on success,
# or { value = null, errors = [{ type = "evaluation_error", message = <error_message> }] } on failure.

{ pkgs, lib, builtins, tryEval, types, errors, ... }: # Accept dependencies as arguments

file:
  let
    # Use builtins.tryEval to catch evaluation errors during import or function calls.
    evalResult = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/wrapEval.nix") { inherit file builtins; }; # Use wrapEval to get the evaluation result

    # Use a let-in block to clarify the return structure
    # finalResult = if evalResult.success then
    #   # If evaluation was successful, check if the result is an attribute set.
    #   if builtins.isAttrs evalResult.value then
    #     { value = evalResult.value; errors = []; }
    #   else
    #     { value = {}; errors = [{ type = "type_error"; message = "File ${file} evaluated to a ${builtins.typeOf evalResult.value}, but a set was expected." }]; }
    # else
    #   # If evaluation failed, capture the error message.
    #   { value = {}; errors = [{ type = "evaluation_error"; message = "File ${file} failed to evaluate: ${evalResult.error}" }]; };
    #
    # Isolated error logic in a separate module for debugging
    finalResult = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/error-isolation.nix") { inherit evalResult file builtins errors types; };
  in
  finalResult
