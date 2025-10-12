{ lib, ... }:

# Handler for 'sort' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
algebra.sort {
  level = recCall expr.level;
  inherit depth;
}
)
