{ lib, ... }:

let
  # Constructor for a 'forallE' (dependent function type) SimpleExpr
  # Example: { kind = "forallE"; binderName = "A"; binderInfo = "implicit"; binderType = { ... }; body = { ... }; }
  mkForallE = { binderName, binderInfo, binderType, body }: {
    kind = "forallE";
    inherit binderName binderInfo binderType body;
  };

  # Check if a given JSON fragment represents a 'forallE'
  isForallE = json:
    builtins.isAttrs json && json ? kind && json.kind == "forallE" && json ? binderName && json ? binderInfo && json ? binderType && json ? body;

in
{
  inherit mkForallE isForallE;
}
