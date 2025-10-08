# lib/prime_encoder.nix
# Encodes a SimpleExpr (Nix attribute set representation of Lean4 expression) into a nested list of prime numbers.

{ lib, primeLattice }:

let
  # Helper function to find a prime by its brainfOperation
  findPrimeByBrainfOperation = operation: 
    let
      found = lib.filter (p: p.brainfOperation == operation) (lib.attrValues primeLattice.primes);
    in
    if lib.length found > 0 then (lib.head found).value else null;

  # Recursive function to encode a SimpleExpr into a nested list of primes
  encodeSimpleExpr = simpleExpr: 
    let
      # Map SimpleExpr kinds to their corresponding brainfOperations
      kindToOperation = {
        app = "function_apply";
        bvar = "bvar_access";
        const = "define_constant";
        forallE = "forall_quantify";
        lam = "lambda_abstract";
        sort = "define_sort";
      };

      # Get the brainfOperation for the current SimpleExpr kind
      currentOperation = kindToOperation."${simpleExpr.type}" or null;
      currentPrime = findPrimeByBrainfOperation currentOperation;

      # Handle recursive encoding for nested expressions
      encodedChildren = 
        if simpleExpr.type == "app" then
          [ (encodeSimpleExpr simpleExpr.fn) (encodeSimpleExpr simpleExpr.arg) ]
        else if simpleExpr.type == "forallE" || simpleExpr.type == "lam" then
          [ (encodeSimpleExpr simpleExpr.forbndrTyp) (encodeSimpleExpr simpleExpr.forbdB) ]
        else
          []; # No children or not a recursive type

    in
    if currentPrime == null then
      throw "Unknown SimpleExpr type or unmapped operation: ${simpleExpr.type}"
    else
      # Return a nested list: [currentPrime, encodedChild1, encodedChild2, ...]
      [ currentPrime ] ++ encodedChildren;

in {
  inherit encodeSimpleExpr;
}