{ lib, ... }:

# Handler for 'app' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
  algebra.app {
    fn = recCall expr.fn;
    arg = recCall expr.arg;
    inherit depth;
  }
)