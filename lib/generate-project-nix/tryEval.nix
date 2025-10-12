# lib/generate-project-nix/tryEval.nix
#
# Helper function to safely evaluate a Nix expression (file or function result).
# Returns the evaluated content if successful, or an empty set if not.

{ builtins, ... }:

expr:
builtins.tryEval (
  if builtins.isAttrs expr then expr
  else if builtins.isFunction expr then { } # Still a function, return empty set
  else { } # Not a set or function, return empty set
)
