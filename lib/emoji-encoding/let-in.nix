{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, emojiEncode, ... }:

{
  encode = ast:
    let
      bindEmojis = lib.concatStringsSep "" (lib.mapAttrsToList (name: val: (emojiEncode name) + (emojiEncode val)) ast.binds);
      bodyEmoji = emojiEncode ast.body;
    in
    (repeatEmoji emojiForTag.letIn (multiplicityFromVal ast)) + bindEmojis + bodyEmoji;
}
