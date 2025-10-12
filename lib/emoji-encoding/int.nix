{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, ... }:

{
  encode = ast: repeatEmoji emojiForTag.int (multiplicityFromVal ast);
}
