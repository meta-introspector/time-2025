{ lib, ... }:

# Handler for 'const' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
algebra.const {
  inherit (expr) declName;
  levels = lib.map recCall expr.levels;
  type = recCall expr.type;
  inherit depth;
}
)
