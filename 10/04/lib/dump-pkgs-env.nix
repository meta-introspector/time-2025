{ pkgs ? import <nixpkgs> {} }:

let
  # Function to process Nix values for JSON serialization
  # It attempts to convert thunks to strings and hashes them uniquely.
  processValue = value: 
    if builtins.isAttrs value then
      builtins.mapAttrs (name: subValue: processValue subValue) value
    else if builtins.isList value then
      builtins.map (subValue: processValue subValue) value
    else if builtins.isFunction value then
      # Represent functions as a special string
      "<function>"
    else if builtins.isPath value then
      # Represent paths as their string representation
      builtins.toString value
    else if builtins.isBool value || builtins.isInt value || builtins.isFloat value || builtins.isString value then
      # Primitive types can be directly serialized
      value
    else
      # For other types (e.g., thunks, derivations), try to convert to string and hash
      let
        valStr = builtins.toString value;
        valHash = builtins.hashString "sha256" valStr;
      in
      "<unserializable: ${valStr} (hash: ${valHash})>";

  # Process the entire pkgs object
  processedPkgs = processValue pkgs;

in
processedPkgs
