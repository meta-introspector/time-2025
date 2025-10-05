{ lib, pkgs, readSimpleExprJson }:

let
  # Import the parsed SimpleExpr.rec JSON
  simpleExprRec = readSimpleExprJson;

  # Import individual SimpleExpr constructor modules
  bvarModule = import ./simple_expr_modules/bvar.nix { inherit lib; };
  sortModule = import ./simple_expr_modules/sort.nix { inherit lib; };
  constModule = import ./simple_expr_modules/const.nix { inherit lib; };
  appModule = import ./simple_expr_modules/app.nix { inherit lib; };
  lamModule = import ./simple_expr_modules/lam.nix { inherit lib; };
  forallEModule = import ./simple_expr_modules/forallE.nix { inherit lib; };

  # Expose constructors and checkers from modules
  inherit (bvarModule) mkBVar isBVar;
  inherit (sortModule) mkSort isSort;
  inherit (constModule) mkConst isConst;
  inherit (appModule) mkApp isApp;
  inherit (lamModule) mkLam isLam;
  inherit (forallEModule) mkForallE isForallE;

  # A function to "reconstruct" a SimpleExpr from its JSON representation
  # This will be a recursive function that traverses the JSON and builds Nix Expr objects
  jsonToSimpleExpr = json:
    if builtins.isAttrs json then
      # Check if it's a SimpleExpr first
      if isBVar json then
        mkBVar {
          deBruijnIndex = json.deBruijnIndex;
          type = jsonToSimpleExpr json.type;
        }
      else if isSort json then
        mkSort {
          level = jsonToSimpleExpr json.level; # level itself can be a nested structure
        }
      else if isConst json then
        mkConst {
          declName = json.declName;
          levels = lib.map (level: jsonToSimpleExpr level) json.levels; # Recursively process levels
          type = jsonToSimpleExpr json.type;
        }
      else if isApp json then
        mkApp {
          fn = jsonToSimpleExpr json.fn;
          arg = jsonToSimpleExpr json.arg;
        }
      else if isLam json then
        mkLam {
          binderName = json.binderName;
          binderInfo = json.binderInfo;
          binderType = jsonToSimpleExpr json.binderType;
          body = jsonToSimpleExpr json.body;
        }
      else if isForallE json then
        mkForallE {
          binderName = json.binderName;
          binderInfo = json.binderInfo;
          binderType = jsonToSimpleExpr json.binderType;
          body = jsonToSimpleExpr json.body;
        }
      else
        # If it's an attribute set but NOT a recognized SimpleExpr, just recursively process its values
        lib.mapAttrs (name: value: jsonToSimpleExpr value) json
    else if builtins.isList json then
      # If it's a list, recursively process its elements
      lib.map (value: jsonToSimpleExpr value) json
    else
      json; # Return as is if not an attribute set or list

  # The actual SimpleExpr object derived from the JSON
  simpleExprObject = jsonToSimpleExpr simpleExprRec.cnstInfB.cnstInf.type;

in {
  inherit mkBVar isBVar;
  inherit mkSort isSort;
  inherit mkConst isConst;
  inherit mkApp isApp;
  inherit mkLam isLam;
  inherit mkForallE isForallE;
  inherit simpleExprRec; # Expose the raw parsed JSON for further processing
  inherit simpleExprObject; # Expose the constructed SimpleExpr object
}