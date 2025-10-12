{ lib, ... }:

# Handler for 'bvar' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
algebra.bvar {
  inherit (expr) deBruijnIndex;
  type = recCall expr.type;
  inherit depth;
}
)
