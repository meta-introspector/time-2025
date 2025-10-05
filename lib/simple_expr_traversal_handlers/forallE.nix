{ lib, ... }:

# Handler for 'forallE' SimpleExpr
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
  algebra.forallE {
    binderName = expr.binderName;
    binderInfo = expr.binderInfo;
    binderType = recCall expr.binderType;
    body = recCall expr.body;
    inherit depth;
  }
)