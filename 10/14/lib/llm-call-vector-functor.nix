{ lib
, calls
, # A list of individual LLM call descriptions
}:

{
  type = "llmCallVector";
  inherit calls;
  description = "A vector of LLM calls, representing a batch or sequence of interactions.";
}
