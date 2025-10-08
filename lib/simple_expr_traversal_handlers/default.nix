{ lib, ... }:

# Handler for default basic types (non-SimpleExpr)
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
  algebra.default expr depth
)