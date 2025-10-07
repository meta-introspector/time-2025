# lib/generate-project-nix/fold-accumulator.nix
# This module isolates the accumulator function for lib.foldlAttrs in generate.nix

{ lib, types, ... }:

acc: name: entry:
  let
    # Ensure entry.value is an attribute set before merging
    # If not, it's ignored for the result, but its errors are still collected.
    validValue = if types.attrs.isType entry.value then entry.value else {};

    # Ensure entry.errors is a list before concatenating
    # If not, treat it as an empty list.
    validErrors = if lib.isList entry.errors then entry.errors else [];
  in
  {
    result = acc.result // { ${name} = validValue; };
    errors = acc.errors ++ validErrors;
  }
