let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  # Pass self to the scope to reference the submodule content
  self = builtins.getFlake (toString ./.) ;
  simpleExprJsonPath = self + "/10/05/MicroLean4/SimpleExpr.rec_686e510a6699f2e1ff1b216c16d94cd379ebeca00c030a79a3134adff699e06c.json";
  readSimpleExprJson = (import ./lib/read_simple_expr_json.nix { inherit lib simpleExprJsonPath; }).readSimpleExprJson;
  simpleExprNix = (import ./lib/simple_expr_nix.nix { inherit lib pkgs readSimpleExprJson; });
  simpleExprTraversal = (import ./lib/simple_expr_traversal.nix { inherit lib pkgs simpleExprNix; });
  simpleExprAnalysis = (import ./lib/simple_expr_analysis.nix { inherit lib pkgs simpleExprTraversal; });
in
  simpleExprAnalysis.calculateKnuthianScore simpleExprNix.simpleExprObject