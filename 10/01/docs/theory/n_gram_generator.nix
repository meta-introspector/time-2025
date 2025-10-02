{
  lib,
  pkgs,
  builtins,
  ...
}:

let
  # Function to tokenize a file path string into segments and parts.
  # Example: "/foo/bar/baz.nix" -> [ "foo" "bar" "baz" "nix" ]
  tokenizePath = path: 
    let
      # Remove leading/trailing slashes and split by slash
      pathSegments = lib.strings.splitString "/" (lib.strings.removePrefix "/" (lib.strings.removeSuffix "/" path));
      # Split by dot for file extensions and other parts
      splitByDot = lib.flatten (lib.map (segment: lib.strings.splitString "." segment) pathSegments);
      # Filter out empty strings that might result from multiple delimiters
      tokens = lib.filter (s: s != "") splitByDot;
    in
    tokens;

  # Conceptual function to tokenize a Nix expression's internal forms.
  # This is highly conceptual as full, robust Nix parsing in pure Nix is not feasible.
  # It would assume a structured representation of the Nix expression (e.g., an AST).
  # For now, it returns a predefined set of common Nix-related tokens.
  tokenizeNixExpression = nixExpression: # `nixExpression` would be a structured input, not raw string
    let
      # Placeholder for actual Nix parsing and token extraction.
      # In a real scenario, this would involve a Nix parser (e.g., written in Rust or Haskell)
      # that outputs a structured AST or a list of tokens.
      # For demonstration, we return a fixed set of common Nix-related tokens.
      conceptualTokens = [
        "flake" "inputs" "outputs" "nixpkgs" "url" "lib" "pkgs" "stdenv" "mkDerivation"
        "pname" "version" "src" "buildInputs" "buildCommand" "let" "in" "attrSet" "list"
        "callPackage" "overrideAttrs" "override" "final" "prev" "system" "eachDefaultSystem"
      ];
    in
    conceptualTokens;

  # Function to generate n-grams from a list of tokens.
  # nGramLengths: a list of integers (e.g., [2 3 5 7 11]) specifying the lengths of n-grams to generate.
  generateNGrams = { tokens, nGramLengths }:
    lib.flatten (
      lib.map (n: # For each n-gram length
        # Generate n-grams of length `n`
        lib.genList (i: lib.strings.concatStringsSep "_" (lib.lists.sublist i n tokens)) (builtins.length tokens - n + 1)
      ) nGramLengths
    );

  # Conceptual usage example
  exampleUsage = 
    let
      path = "/home/user/project/src/my-flake.nix";
      pathTokens = tokenizePath path;
      nixExpressionPlaceholder = {}; # Placeholder for a structured Nix expression
      nixTokens = tokenizeNixExpression nixExpressionPlaceholder;
      allTokens = pathTokens ++ nixTokens;
      nGramLengths = [ 2 3 5 7 11 ];

      pathNGrams = generateNGrams { tokens = pathTokens; inherit nGramLengths; };
      nixNGrams = generateNGrams { tokens = nixTokens; inherit nGramLengths; };
      combinedNGrams = generateNGrams { tokens = allTokens; inherit nGramLengths; };
    in
    {
      inherit pathTokens nixTokens allTokens;
      inherit pathNGrams nixNGrams combinedNGrams;
    };

in
{
  tokenizePath = tokenizePath;
  tokenizeNixExpression = tokenizeNixExpression;
  generateNGrams = generateNGrams;
  exampleUsage = exampleUsage;
}
