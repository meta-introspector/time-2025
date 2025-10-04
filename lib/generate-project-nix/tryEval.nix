# lib/generate-project-nix/tryEval.nix
#
# Helper function to ensure an expression is an attribute set.
# If the expression is a function, it's treated as an empty set.
# This is a fallback for functions that cannot be evaluated to a set with default arguments.

{ builtins, ... }: # Accept builtins as an argument

expr:
  if builtins.isAttrs expr then expr
  else if builtins.isFunction expr then {} # Still a function, return empty set
  else {}; # Not a set or function, return empty set
