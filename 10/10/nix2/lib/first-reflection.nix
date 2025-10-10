{ lib, pkgs }:

let
  # Function to evaluate a Nix expression to JSON
  # This will be used to get a canonical representation of each command/target
  evalToJson = expr:
    let
      # Use builtins.toJSON to convert the evaluated expression to JSON
      # This requires the expression to be evaluable to a simple type (string, list, attrset, etc.)
      jsonString = builtins.toJSON expr;
    in
    jsonString;

  # Function to check for uniqueness among a list of expressions
  # It takes an attribute set where keys are identifiers and values are the expressions
  checkUniqueness = expressions:
    let
      # Map each expression to its JSON representation
      jsonRepresentations = lib.mapAttrs (name: evalToJson) expressions;

      # Group expressions by their JSON representation to find duplicates
      groupedByJson = builtins.groupBy (name: jsonRepresentations.${name}) (lib.attrNames expressions);

      # Filter out groups that have more than one element (these are duplicates)
      duplicates = lib.filterAttrs (json: names: (lib.length names) > 1) groupedByJson;

      # Determine if there are any duplicates
      hasDuplicates = (lib.attrNames duplicates) != [];
    in
    {
      inherit jsonRepresentations duplicates hasDuplicates;
    };

in
{
  # Expose the checkUniqueness function
  check = checkUniqueness;
}