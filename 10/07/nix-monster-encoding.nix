{ lib ? import <nixpkgs> {} }:

let
  # Emoji mappings for tags (visual "primes")
  emojiForTag = {
    list = "📋";   # 2 (Duality/Foundation)
    ifThenElse = "❓";  # 3 (Structure/Form)
    int = "🔢";    # 5 (Pattern/Collection)
    attrset = "📦"; # 7 (Insight/Guidance)
    lambda = "λ";  # 11 (Transformation/Flow)
    letIn = "↩️";   # 13 (Challenge/Verification)
    string = "📝"; # 17 (Refinement/Communication)
    unsupported = "🚫"; # 19 (Manifestation/Core Being - representing the boundary)
  };

  # Exponent/multiplicity from value (same as prime version)
  multiplicityFromVal = val:
    if lib.isInt val then 1 + (if val < 0 then 1 else 0) + (builtins.mod (builtins.abs val) 10)
    else if lib.isString val then 1 + lib.stringLength val
    else if lib.isList val then lib.length val
    else if val ? type && val.type or "" == "attrs" then 1 + (builtins.length (lib.attrNames val))
    else 1; # Default for unsupported types

  # Repeat emoji n times (pure concat)
  repeatEmoji = emoji: n: lib.concatStrings (lib.genList (_: emoji) n);

  # Import specialized emoji encoders
  intEncoder = import ./lib/emoji-encoding/int.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal; };
  stringEncoder = import ./lib/emoji-encoding/string.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal; };
  listEncoder = import ./lib/emoji-encoding/list.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal emojiEncode; };
  attrsetEncoder = import ./lib/emoji-encoding/attrset.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal emojiEncode; };
  lambdaEncoder = import ./lib/emoji-encoding/lambda.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal emojiEncode; };
  letInEncoder = import ./lib/emoji-encoding/let-in.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal emojiEncode; };
  ifThenElseEncoder = import ./lib/emoji-encoding/if-then-else.nix { inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal emojiEncode; };

  # Recursive emoji encoder: dispatches to specialized encoders
  emojiEncode = ast:
    if lib.isInt ast then intEncoder.encode ast
    else if lib.isString ast then stringEncoder.encode ast
    else if lib.isList ast then listEncoder.encode ast
    else if ast ? type && ast.type or "" == "attrs" then attrsetEncoder.encode ast
    else if ast ? body && ast ? arg then lambdaEncoder.encode ast  # Simple lambda
    else if ast ? binds && ast ? body then letInEncoder.encode ast  # letIn
    else if ast ? cond && ast ? thenBranch && ast ? elseBranch then ifThenElseEncoder.encode ast  # ifThenElse
    else repeatEmoji emojiForTag.unsupported (multiplicityFromVal ast);

  # Example AST: { a = 42; b = [ "hello" "world" ]; }
  exampleAST = {
    type = "attrs";
    a = 42;
    b = [ "hello" "world" ];
  };

  encodedEmoji = emojiEncode exampleAST;

in
{
  inherit emojiEncode;
  example = {
    ast = exampleAST;
    inherit encodedEmoji;  # E.g., "📦📦📦📝📝🔢🔢🔢📝📝📝📝📝📝📝📝📝📝📝📝"
  };
  # Test: nix repl, load this, then example.encodedEmoji
}