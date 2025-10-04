# lib/generate-project-nix/evaluateNixFile.nix
#
# Helper function to safely evaluate a Nix expression (file or function result).
# Returns { value = <evaluated_result>, errors = [] } on success,
# or { value = null, errors = [{ type = "evaluation_error", message = <error_message> }] } on failure.

{ pkgs, lib, builtins, tryEval, ... }: # Accept dependencies as arguments

file:
  let
    # Use builtins.tryEval to catch evaluation errors during import or function calls.
    evalResult = builtins.tryEval (
      let
        imported = import file;
      in
      if builtins.isFunction imported then
        # Try to call the function with common arguments
        tryEval (imported { inherit pkgs lib; })
      else if builtins.isAttrs imported then
        imported
      else
        # If it's neither a function nor an attribute set, return an empty set
        {};
    );
  in
  if evalResult.success then
    # If evaluation was successful, check if the result is an attribute set.
    if builtins.isAttrs evalResult.value then
      { value = evalResult.value, errors = [] }
    else
      { value = {}, errors = [{ type = "type_error", message = "File ${file} evaluated to a ${builtins.typeOf evalResult.value}, but a set was expected." }] }
  else
    # If evaluation failed, capture the error message.
    { value = {}, errors = [{ type = "evaluation_error", message = "File ${file} failed to evaluate: ${evalResult.error}" }] };
