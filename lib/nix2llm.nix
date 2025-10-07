{ lib, ... }:

{
  # TODO: Make the description more detailed and structured.
  # Function to describe a Nix expression to an LLM
  nix2llm = nixExpression: filters: 
    let
      # For now, a generic description. This will be expanded later.
      description = "This Nix expression is: ${builtins.toJSON nixExpression}. Filters: ${builtins.toJSON filters}.";
    in
    ''
      # Nix Expression Description for LLM

      ## Purpose
      The following Nix expression is provided for analysis and potential modification.

      ## Details
      ${description}

      ## Instructions for LLM
      Please analyze the provided Nix expression based on the given filters and parameters.
      Your response should focus on the structure, purpose, and potential areas for improvement or modification.
    '';
}
