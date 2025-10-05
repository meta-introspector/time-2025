{ lib, ... }:

# Handler for 'lam' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
  algebra.lam {
    binderName = expr.binderName;
    binderInfo = expr.binderInfo;
    binderType = recCall expr.binderType;
    body = recCall expr.body;
    inherit depth;
  }
)