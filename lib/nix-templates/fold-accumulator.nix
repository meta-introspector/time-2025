# lib/nix-templates/fold-accumulator.nix
# Abstraction for accumulating results and errors in lib.foldlAttrs.
{ lib, types, nix-stdlib, ... }:

acc: name: entry:
let
  validValue = if nix-stdlib.lib.types.attrs.isType entry.value then entry.value else { };
  validErrors = if nix-stdlib.lib.types.lists.isType entry.errors then entry.errors else [ ];
in
{
  result = acc.result // { ${name} = validValue; };
  errors = acc.errors ++ validErrors;
}
