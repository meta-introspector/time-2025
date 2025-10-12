{ lib, ... }:

# Handler for 'forallE' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
algebra.forallE {
  inherit (expr) binderName;
  inherit (expr) binderInfo;
  binderType = recCall expr.binderType;
  body = recCall expr.body;
  inherit depth;
}
)
