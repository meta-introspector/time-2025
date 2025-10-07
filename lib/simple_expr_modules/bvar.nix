{ lib, ... }:

let
  # Constructor for a 'bvar' (bound variable) SimpleExpr
  # Example: { kind = "bvar"; deBruijnIndex = 0; type = { ... }; }
  mkBVar = { deBruijnIndex, type }: {
    kind = "bvar";
    inherit deBruijnIndex type;
  };

  # Check if a given JSON fragment represents a 'bvar'
  isBVar = json:
    builtins.isAttrs json && json ? kind && json.kind == "bvar" && json ? deBruijnIndex && json ? type;

in {
  inherit mkBVar isBVar;
}