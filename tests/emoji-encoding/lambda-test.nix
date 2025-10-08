{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, lambdaEncoder, emojiEncode }:

let
  testAst = { body = "x"; arg = "y"; }; # Simplified lambda AST
  mockEmojiEncode = val: "M"; # Mock for sub-expressions

  lambdaEncoderMocked = import ../../lib/emoji-encoding/lambda.nix {
    inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal;
    emojiEncode = mockEmojiEncode;
  };

  expectedEmoji = (repeatEmoji emojiForTag.lambda (multiplicityFromVal testAst)) + (mockEmojiEncode testAst.body);
  actualEmoji = lambdaEncoderMocked.encode testAst;
in
{
  "lambdaEncoder encodes correctly" = actualEmoji == expectedEmoji;
}
