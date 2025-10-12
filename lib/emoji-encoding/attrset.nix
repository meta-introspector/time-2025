{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, emojiEncode, ... }:

{
  encode = ast:
    let
      names = lib.attrNames ast;
      keyValEmojis = lib.concatMap (name: (emojiEncode name) + (emojiEncode ast.${name})) names;
    in
    (repeatEmoji emojiForTag.attrset (multiplicityFromVal ast)) + keyValEmojis;
}
