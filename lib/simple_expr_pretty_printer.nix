{ lib, simpleExprTraversal, ... }:

let
  # Define a simple pretty-printer algebra
  prettyPrinterAlgebra = {
    bvar = { deBruijnIndex, type }: "(bvar ${toString deBruijnIndex} ${type})";
    sort = { level }: "(sort ${level})"; # level is already a string or simple attr set
    const = { declName, levels, type }: "(const ${declName} [${lib.concatStringsSep " " (lib.map toString levels)}] ${type})";
    app = { fn, arg }: "(app ${fn} ${arg})";
    lam = { binderName, binderInfo, binderType, body }: "(lam ${binderName} ${binderInfo} ${binderType} ${body})";
    forallE = { binderName, binderInfo, binderType, body }: "(forallE ${binderName} ${binderInfo} ${binderType} ${body})";
  };

  # Function to pretty-print a SimpleExpr
  prettyPrintSimpleExpr = expr:
    simpleExprTraversal.traverseSimpleExpr prettyPrinterAlgebra expr;

in
{
  inherit prettyPrintSimpleExpr;
}
