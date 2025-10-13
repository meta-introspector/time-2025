# Generate virtual packages for each extracted data item
virtualPackages = lib.listToAttrs (lib.lists.imap0
(index: data: {
name = generateEmojiString index;
value = pkgs.writeText "virtual-package-${generateEmojiString index}.json" (builtins.toJSON data);
})
allExtractedData);
in
{
