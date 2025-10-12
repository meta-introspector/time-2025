{ lib, simpleExprJsonPath }:

let
  # Function to read and parse the JSON file
  readSimpleExprJson =
    let
      # Read the file content as a string
      jsonString = builtins.readFile simpleExprJsonPath;
      # Parse the JSON string into a Nix attribute set
      parsedJson = builtins.fromJSON jsonString;
    in
    parsedJson;

in
{
  inherit readSimpleExprJson;
}
