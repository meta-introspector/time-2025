{ lib, simpleExprNix, ... }:

let
  # Import constructors and checkers from simpleExprNix
  inherit (simpleExprNix) mkBVar isBVar
                          mkSort isSort
                          mkConst isConst
                          mkApp isApp
                          mkLam isLam
                          mkForallE isForallE;

  # Generic traversal function (catamorphism/fold) for SimpleExpr
  # It takes an 'algebra' (an attribute set of functions for each constructor)
  # and a SimpleExpr, and applies the appropriate function from the algebra.
  traverseSimpleExpr = algebra: expr:
    if isBVar expr then
      algebra.bvar {
        inherit (expr) deBruijnIndex;
        type = traverseSimpleExpr algebra expr.type;
      }
    else if isSort expr then
      algebra.sort {
        level = traverseSimpleExpr algebra expr.level;
      }
    else if isConst expr then
      algebra.const {
        inherit (expr) declName;
        levels = lib.map (level: traverseSimpleExpr algebra level) expr.levels;
        type = traverseSimpleExpr algebra expr.type;
      }
    else if isApp expr then
      algebra.app {
        fn = traverseSimpleExpr algebra expr.fn;
        arg = traverseSimpleExpr algebra expr.arg;
      }
    else if isLam expr then
      algebra.lam {
        inherit (expr) binderName;
        inherit (expr) binderInfo;
        binderType = traverseSimpleExpr algebra expr.binderType;
        body = traverseSimpleExpr algebra expr.body;
      }
    else if isForallE expr then
      algebra.forallE {
        inherit (expr) binderName;
        inherit (expr) binderInfo;
        binderType = traverseSimpleExpr algebra expr.binderType;
        body = traverseSimpleExpr algebra expr.body;
      }
    else if builtins.isAttrs expr then
      # If it's an attribute set but not a SimpleExpr, convert it to a string representation
      # This is a fallback for non-SimpleExpr attribute sets
      lib.concatStringsSep " " (lib.mapAttrsToList (name: value: "${name}=${traverseSimpleExpr algebra value}") expr)
    else if builtins.isList expr then
      # If it's a list, recursively process its elements and join them
      lib.concatStringsSep " " (lib.map (value: traverseSimpleExpr algebra value) expr)
    else
      toString expr; # Return string representation for basic types
in {
  inherit traverseSimpleExpr;
}