{ lib, ... }:

let
  # Constructor for a 'lam' (lambda abstraction) SimpleExpr
  # Example: { kind = "lam"; binderName = "x"; binderInfo = "default"; binderType = { ... }; body = { ... }; }
  mkLam = { binderName, binderInfo, binderType, body }: {
    kind = "lam";
    inherit binderName binderInfo binderType body;
  };

  # Check if a given JSON fragment represents a 'lam'
  isLam = json:
    builtins.isAttrs json && json ? kind && json.kind == "lam" && json ? binderName && json ? binderInfo && json ? binderType && json ? body;

in {
  inherit mkLam isLam;
}