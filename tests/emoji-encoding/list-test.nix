{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, listEncoder, emojiEncode }:

let
  testAst = [ "a" 1 ];
  # For testing, we need a mock emojiEncode that doesn't cause infinite recursion
  mockEmojiEncode = val:
    if builtins.isString val then "S" # Simplified string emoji
    else if builtins.isInt val then "I" # Simplified int emoji
    else "X"; # Unknown type

  # Re-import listEncoder with the mockEmojiEncode
  listEncoderMocked = import ../../lib/emoji-encoding/list.nix {
    inherit lib builtins emojiForTag repeatEmoji multiplicityFromVal;
    emojiEncode = mockEmojiEncode;
  };

  expectedEmoji = (repeatEmoji emojiForTag.list (multiplicityFromVal testAst)) + (lib.concatMap mockEmojiEncode testAst);
  actualEmoji = listEncoderMocked.encode testAst;
in
{
  "listEncoder encodes correctly" = actualEmoji == expectedEmoji;
}
