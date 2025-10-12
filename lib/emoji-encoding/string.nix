{ lib, builtins, emojiForTag, repeatEmoji, multiplicityFromVal, ... }:

{
  encode = ast: repeatEmoji emojiForTag.string (multiplicityFromVal ast);
}
