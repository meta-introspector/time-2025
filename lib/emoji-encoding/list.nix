{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, emojiEncode, ... }:

{
  encode = ast:
    let subEmojis = lib.concatMap emojiEncode ast;
    in (repeatEmoji emojiForTag.list (multiplicityFromVal ast)) + subEmojis;
}