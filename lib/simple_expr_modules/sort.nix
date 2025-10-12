{ lib, ... }:

let
  # Constructor for a 'sort' (type universe) SimpleExpr
  # Example: { kind = "sort"; level = { ... }; }
  mkSort = { level }: {
    kind = "sort";
    inherit level;
  };

  # Check if a given JSON fragment represents a 'sort'
  isSort = json:
    builtins.isAttrs json && json ? kind && json.kind == "sort" && json ? level;

in
{
  inherit mkSort isSort;
}
