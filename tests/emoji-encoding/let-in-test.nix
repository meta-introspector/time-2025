{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, letInEncoder, emojiEncode }:

let
  testAst = { binds = { x = 1; }; body = "y"; }; # Simplified letIn AST
  mockEmojiEncode = val: "M"; # Mock for sub-expressions

  letInEncoderMocked = import ../../lib/emoji-encoding/let-in.nix {
    inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal;
    emojiEncode = mockEmojiEncode;
  };

  bindEmojis = lib.concatStringsSep "" (lib.mapAttrsToList (name: val: (mockEmojiEncode name) + (mockEmojiEncode val)) testAst.binds);
  bodyEmoji = mockEmojiEncode testAst.body;
  expectedEmoji = (repeatEmoji emojiForTag.letIn (multiplicityFromVal testAst)) + bindEmojis + bodyEmoji;
  actualEmoji = letInEncoderMocked.encode testAst;
in
{
  "letInEncoder encodes correctly" = actualEmoji == expectedEmoji;
}
