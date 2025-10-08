{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, stringEncoder }:

let
  testAst = "hello";
  expectedEmoji = repeatEmoji emojiForTag.string (multiplicityFromVal testAst);
  actualEmoji = stringEncoder.encode testAst;
in
{
  "stringEncoder encodes correctly" = actualEmoji == expectedEmoji;
}