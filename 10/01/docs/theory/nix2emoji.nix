{
  lib,
  builtins,
  # Import the emoji OWL schema
  emojiOwlModule,
  ...
}:

let
  # Extract emojiMap from the OWL schema
  emojiMap = builtins.listToAttrs (
    builtins.map (
      individualName: 
        let
          individual = emojiOwlModule.ontology.individuals.${individualName};
          conceptName = builtins.replaceStrings [ "Concept" "Value" "Keyword" ] [ "" "" "" ] individualName;
        in
        { name = conceptName; value = individual.hasEmojiRepresentation; }
    ) (builtins.attrNames emojiOwlModule.ontology.individuals)
  );

  # Function to convert a Nix value to an emoji string
  toEmoji = value: 
    if builtins.isAttrs value then
      let
        attrEmojis = builtins.concatStringsSep "" (
          builtins.mapAttrsToList (name: val: 
            "${name}${emojiMap.Assign}${toEmoji val}${emojiMap.StatementEnd}"
          ) value
        );
      in
      "${emojiMap.AttrSetOpen}${attrEmojis}${emojiMap.AttrSetClose}"
    else if builtins.isList value then
      let
        listEmojis = builtins.concatStringsSep "" (
          builtins.map (val: 
            "${toEmoji val}${emojiMap.StatementEnd}"
          ) value
        );
      in
      "${emojiMap.ListOpen}${listEmojis}${emojiMap.ListClose}"
    else if builtins.isString value then
      "${emojiMap.StringQuote}${value}${emojiMap.StringQuote}"
    else if builtins.isBool value then
      if value then emojiMap.TrueValue else emojiMap.FalseValue
    else if builtins.isInt value then
      "${emojiMap.NumberBlock}${builtins.toString value}"
    else if value == null then # Check for null
      emojiMap.NullValue
    else if builtins.isFunction value then
      # Represent functions conceptually for now, as direct conversion is hard
      "${emojiMap.FunctionConceptEmoji} (function)"
    else
      "❓(unknown_type)"; # Fallback for unhandled types

in
{
  nix2emoji = toEmoji;
  emojiMap = emojiMap; # Export map for reference
}
