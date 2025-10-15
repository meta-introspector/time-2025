{ lib
, checksum
, keyObject
, modelRouter
, prompt
, expectedOutputFormat ? "markdown"
, # Default to markdown
}:

{
  type = "llmCall";
  inherit checksum keyObject modelRouter prompt expectedOutputFormat;
}
