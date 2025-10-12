{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, attrsetEncoder, emojiEncode }:

let
  testAst = { a = "hello"; b = 1; };
  # For testing, we need a mock emojiEncode that doesn't cause infinite recursion
  mockEmojiEncode = val:
    if builtins.isString val then "S" # Simplified string emoji
    else if builtins.isInt val then "I" # Simplified int emoji
    else "X"; # Unknown type

  # Re-import attrsetEncoder with the mockEmojiEncode
  attrsetEncoderMocked = import ../../lib/emoji-encoding/attrset.nix {
    inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal;
    emojiEncode = mockEmojiEncode;
  };

  expectedEmoji = (repeatEmoji emojiForTag.attrset (multiplicityFromVal testAst)) + (lib.concatMap (name: (mockEmojiEncode name) + (mockEmojiEncode testAst.${name})) (lib.attrNames testAst));
  actualEmoji = attrsetEncoderMocked.encode testAst;
in
{
  "attrsetEncoder encodes correctly" = actualEmoji == expectedEmoji;
}
