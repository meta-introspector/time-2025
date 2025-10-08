{ lib, ... }:

let
  # Constructor for a 'const' (constant) SimpleExpr
  # Example: { kind = "const"; declName = "Nat"; levels = [...]; type = { ... }; }
  mkConst = { declName, levels, type }: {
    kind = "const";
    inherit declName levels type;
  };

  # Check if a given JSON fragment represents a 'const'
  isConst = json:
    builtins.isAttrs json && json ? kind && json.kind == "const" && json ? declName && json ? levels && json ? type;

in {
  inherit mkConst isConst;
}