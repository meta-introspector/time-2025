let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  inherit ((import ./lib/read_simple_expr_json.nix { inherit lib pkgs; })) readSimpleExprJson;
  simpleExprNix = import ./lib/simple_expr_nix.nix { inherit lib pkgs readSimpleExprJson; };
  simpleExprTraversal = import ./lib/simple_expr_traversal.nix { inherit lib simpleExprNix; };
  simpleExprPrettyPrinter = import ./lib/simple_expr_pretty_printer.nix { inherit lib simpleExprTraversal; };
in
simpleExprPrettyPrinter.prettyPrintSimpleExpr simpleExprNix.simpleExprObject
