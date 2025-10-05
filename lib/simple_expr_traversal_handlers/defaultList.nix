{ lib, ... }:

# Handler for default lists (non-SimpleExpr)
# It takes algebra, expr, depth, and recCall (the recursive call function)
(algebra: expr: depth: recCall:
  algebra.defaultList (lib.map recCall expr) depth
)