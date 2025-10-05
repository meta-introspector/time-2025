{ lib, pkgs, ... }:

let
  # Path to the SimpleExpr.rec JSON file
  simpleExprJsonPath = ../10/05/MicroLean4/SimpleExpr.rec_686e510a6699f2e1ff1b216c16d94cd379ebeca00c030a79a3134adff699e06c.json;

  # Function to read and parse the JSON file
  readSimpleExprJson =
    let
      # Read the file content as a string
      jsonString = builtins.readFile simpleExprJsonPath;
      # Parse the JSON string into a Nix attribute set
      parsedJson = builtins.fromJSON jsonString;
    in
    parsedJson;

in {
  inherit readSimpleExprJson;
}