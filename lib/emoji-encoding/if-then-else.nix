{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, emojiEncode, ... }:

{
  encode = ast:
    let
      condEmoji = emojiEncode ast.cond;
      thenEmoji = emojiEncode ast.thenBranch;
      elseEmoji = emojiEncode ast.elseBranch;
    in
    (repeatEmoji emojiForTag.ifThenElse 1) + condEmoji + thenEmoji + elseEmoji;
}
