{ lib, ... }:

let
  # Constructor for an 'app' (application) SimpleExpr
  # Example: { kind = "app"; fn = { ... }; arg = { ... }; }
  mkApp = { fn, arg }: {
    kind = "app";
    inherit fn arg;
  };

  # Check if a given JSON fragment represents an 'app'
  isApp = json:
    builtins.isAttrs json && json ? kind && json.kind == "app" && json ? fn && json ? arg;

in
{
  inherit mkApp isApp;
}
