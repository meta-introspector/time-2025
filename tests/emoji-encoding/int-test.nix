{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, intEncoder }:

let
  testAst = 42;
  expectedEmoji = repeatEmoji emojiForTag.int (multiplicityFromVal testAst);
  actualEmoji = intEncoder.encode testAst;
in
{
  "intEncoder encodes correctly" = actualEmoji == expectedEmoji;
}