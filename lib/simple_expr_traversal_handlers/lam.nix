{ lib, ... }:

# Handler for 'lam' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
algebra.lam {
  inherit (expr) binderName;
  inherit (expr) binderInfo;
  binderType = recCall expr.binderType;
  body = recCall expr.body;
  inherit depth;
}
)
