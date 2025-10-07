{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, emojiEncode, ... }:

{
  encode = ast:
    (repeatEmoji emojiForTag.lambda (multiplicityFromVal ast)) + (emojiEncode ast.body);
}
