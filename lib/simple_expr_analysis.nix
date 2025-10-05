{ lib, pkgs, simpleExprTraversal, ... }:

let
  # Explicitly import lib functions to ensure 'foldl' and 'max' are available
  inherit (pkgs.lib) foldl' max attrValues pow flatten;
  sumUtil = import ./utils/sum.nix { inherit lib; }; # Import our custom sum

  # Helper to sum the 'size' attribute of a list of records
  sumSizes = records: sumUtil.sum (lib.map (r: if r ? size then r.size else 0) records);

  # Algebra to calculate the number of nodes in a SimpleExpr tree
  sizeAlgebra = {
    bvar = ({ deBruijnIndex, type, depth }: 1 + type);
    sort = ({ level, depth }: 1 + level);
    const = ({ declName, levels, type, depth }: 1 + (sumUtil.sum levels) + type);
    app = ({ fn, arg, depth }: 1 + fn + arg);
    lam = ({ binderName, binderInfo, binderType, body, depth }: 1 + binderType + body);
    forallE = ({ binderName, binderInfo, binderType, body, depth }: 1 + binderType + body);

    # Default handlers for non-SimpleExpr types
    defaultAttr = (attrs: depth: 1 + sumUtil.sum (lib.attrValues attrs));
    defaultList = (list: depth: sumUtil.sum list);
    default = (value: depth: 0);
  };

  # Function to calculate the size of a SimpleExpr
  calculateSize = expr:
    simpleExprTraversal.traverseSimpleExpr sizeAlgebra expr 0; # Pass initial depth 0

  # Algebra to calculate the maximum depth of a SimpleExpr tree
  depthAlgebra = {
    bvar = ({ deBruijnIndex, type, depth }: 1 + type);
    sort = ({ level, depth }: 1 + level);
    const = ({ declName, levels, type, depth }: 1 + (foldl' max 0 levels) + type);
    app = ({ fn, arg, depth }: 1 + max fn arg);
    lam = ({ binderName, binderInfo, binderType, body, depth }: 1 + max binderType body);
    forallE = ({ binderName, binderInfo, binderType, body, depth }: 1 + max binderType body);

    # Default handlers for non-SimpleExpr types
    defaultAttr = (attrs: depth: 1 + foldl' max 0 (attrValues attrs));
    defaultList = (list: depth: foldl' max 0 list);
    default = (value: depth: 0);
  };

  # Function to calculate the depth of a SimpleExpr
  calculateDepth = expr:
    simpleExprTraversal.traverseSimpleExpr depthAlgebra expr 0; # Pass initial depth 0

  # Algebra to calculate a Knuthian quantitative analysis score
  # using bott[8] prime numbers (2, 3, 5, 7, 11, 13, 17, 19)
  knuthianAlgebra = {
    # Prime 2: Node existence
    # Prime 3: Constructor type
    # Prime 5: Recursive depth (conceptual, handled by multiplication)
    # Prime 7: Binding/Abstraction
    # Prime 11: Identity/Constant
    # Prime 13: Indexing/Position
    # Prime 17: Levels/Universes
    # Prime 19: Application/Functionality

    bvar = { deBruijnIndex, type, depth }:
      2 * 3 * 13 * deBruijnIndex * type; # Node * Constructor * Indexing * deBruijnIndex * Type

    sort = { level, depth }:
      2 * (pow 3 2) * 17 * level; # Node * Constructor * Levels * Level

    const = { declName, levels, type, depth }:
      2 * (pow 3 3) * 11 * (if builtins.isString declName then 1 else declName) * (foldl' (a: b: a * b) 1 levels) * type; # Node * Constructor * Identity * declName * Levels * Type

    app = { fn, arg, depth }:
      2 * (pow 3 4) * 19 * fn * arg; # Node * Constructor * Application * Function * Argument

    lam = { binderName, binderInfo, binderType, body, depth }:
      2 * (pow 3 5) * 7 * (if builtins.isString binderName then 1 else binderName) * (if builtins.isString binderInfo then 1 else binderInfo) * binderType * body; # Node * Constructor * Binding * BinderName * BinderInfo * BinderType * Body

    forallE = { binderName, binderInfo, binderType, body, depth }:
      2 * (pow 3 6) * 7 * (if builtins.isString binderName then 1 else binderName) * (if builtins.isString binderInfo then 1 else binderInfo) * binderType * body; # Node * Constructor * Binding * BinderName * BinderInfo * BinderType * Body

    # Default handlers for non-SimpleExpr types
    defaultAttr = attrs: depth: foldl' (a: b: a * b) 1 (attrValues attrs); # Product of children's scores
    defaultList = list: depth: foldl' (a: b: a * b) 1 list; # Product of list elements' scores
    default = value: depth:
      if builtins.isString value then 1 # Strings contribute 1 (neutral for multiplication)
      else if builtins.isBool value then 1 # Booleans contribute 1
      else if builtins.isFloat value || builtins.isInt value then value # Numbers contribute their value
      else 1; # Fallback for other types
  };

  # Function to calculate the Knuthian score
  calculateKnuthianScore = expr:
    simpleExprTraversal.traverseSimpleExpr knuthianAlgebra expr 0; # Pass initial depth 0

  # Algebra for detailed analysis: counts, sizes, nesting
  detailedAnalysisAlgebra = {
    bvar = { deBruijnIndex, type, currentDepth }:
      [ { kind = "bvar"; inherit currentDepth; } ] ++ type;

    sort = { level, currentDepth }:
      [ { kind = "sort"; inherit currentDepth; } ] ++ level;

    const = { declName, levels, type, currentDepth }:
      [ { kind = "const"; inherit currentDepth; } ] ++ levels ++ type;

    app = { fn, arg, currentDepth }:
      [ { kind = "app"; inherit currentDepth; } ] ++ fn ++ arg;

    lam = { binderName, binderInfo, binderType, body, currentDepth }:
      [ { kind = "lam"; inherit currentDepth; } ] ++ binderType ++ body;

    forallE = { binderName, binderInfo, binderType, body, currentDepth }:
      [ { kind = "forallE"; inherit currentDepth; } ] ++ binderType ++ body;

    # Default handlers for non-SimpleExpr types
    defaultAttr = attrs: currentDepth:
      [ { kind = "attribute_set"; inherit currentDepth; } ] ++ (flatten (lib.attrValues attrs));

    defaultList = list: currentDepth:
      [ { kind = "list"; inherit currentDepth; } ] ++ (flatten list);

    default = value: currentDepth:
      [ { kind = "value"; inherit currentDepth; } ]; # Basic values don't have internal structure
  };

  # Function to perform detailed analysis
  performDetailedAnalysis = expr:
    simpleExprTraversal.traverseSimpleExpr detailedAnalysisAlgebra expr 0;

  # Algebra for literal and constant analysis
  literalAndConstantAnalysisAlgebra = {
    bvar = { deBruijnIndex, type, currentDepth }:
      [ { kind = "bvar_index"; value = deBruijnIndex; inherit currentDepth; } ] ++ type;

    sort = { level, currentDepth }:
      [ { kind = "sort_level"; value = level; inherit currentDepth; } ] ++ level;

    const = { declName, levels, type, currentDepth }:
      [ { kind = "const_declName"; value = declName; inherit currentDepth; } ] ++ levels ++ type;

    app = { fn, arg, currentDepth }: fn ++ arg; # No literals/constants directly in app

    lam = { binderName, binderInfo, binderType, body, currentDepth }:
      [ { kind = "lam_binderName"; value = binderName; inherit currentDepth; }
        { kind = "lam_binderInfo"; value = binderInfo; inherit currentDepth; }
      ] ++ binderType ++ body;

    forallE = { binderName, binderInfo, binderType, body, currentDepth }:
      [ { kind = "forallE_binderName"; value = binderName; inherit currentDepth; }
        { kind = "forallE_binderInfo"; value = binderInfo; inherit currentDepth; }
      ] ++ binderType ++ body;

    # Default handlers for non-SimpleExpr types
    defaultAttr = attrs: currentDepth:
      flatten (lib.attrValues (lib.mapAttrs (name: value: simpleExprTraversal.traverseSimpleExpr literalAndConstantAnalysisAlgebra value currentDepth) attrs));

    defaultList = list: currentDepth:
      flatten (lib.map (value: simpleExprTraversal.traverseSimpleExpr literalAndConstantAnalysisAlgebra value currentDepth) list);

    default = value: currentDepth:
      if builtins.isString value || builtins.isInt value || builtins.isFloat value || builtins.isBool value then
        [ { kind = "literal"; value = value; inherit currentDepth; } ]
      else
        []; # Other basic types (e.g., null) don't count as literals for this analysis
  };

  # Function to perform literal and constant analysis
  performLiteralAndConstantAnalysis = expr:
    simpleExprTraversal.traverseSimpleExpr literalAndConstantAnalysisAlgebra expr 0;

in {
  inherit calculateSize calculateDepth calculateKnuthianScore performDetailedAnalysis performLiteralAndConstantAnalysis;
}