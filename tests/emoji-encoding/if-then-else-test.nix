{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, ifThenElseEncoder, emojiEncode }:

let
  testAst = { cond = true; thenBranch = "a"; elseBranch = "b"; }; # Simplified ifThenElse AST
  mockEmojiEncode = val: "M"; # Mock for sub-expressions

  ifThenElseEncoderMocked = import ../../lib/emoji-encoding/if-then-else.nix {
    inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal;
    emojiEncode = mockEmojiEncode;
  };

  condEmoji = mockEmojiEncode testAst.cond;
  thenEmoji = mockEmojiEncode testAst.thenBranch;
  elseEmoji = mockEmojiEncode testAst.elseBranch;
  expectedEmoji = (repeatEmoji emojiForTag.ifThenElse 1) + condEmoji + thenEmoji + elseEmoji;
  actualEmoji = ifThenElseEncoderMocked.encode testAst;
in
{
  "ifThenElseEncoder encodes correctly" = actualEmoji == expectedEmoji;
}
