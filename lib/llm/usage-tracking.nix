{ lib, ... }:

let
  # Defines the structure for LLM quota information
  llmQuotaSchema = {
    type = lib.types.attrs;
    attrs = {
      totalRequests = lib.types.int;
      remainingRequests = lib.types.int;
      resetTime = lib.types.str; # ISO 8601 timestamp
      totalTokens = lib.types.int;
      remainingTokens = lib.types.int;
      # Add other relevant quota metrics as needed (e.g., rate limits per minute/hour)
      requestsPerMinute = lib.types.int;
      requestsPerHour = lib.types.int;
      requestsPerDay = lib.types.int;
      requestsPerWeek = lib.types.int;
      tokensPerMinute = lib.types.int;
      tokensPerHour = lib.types.int;
      tokensPerDay = lib.types.int;
      tokensPerWeek = lib.types.int;
    };
  };

  # Defines the structure for estimated LLM usage per task
  llmEstimatedUsageSchema = {
    type = lib.types.attrs;
    attrs = {
      estimatedTokens = lib.types.int;
      estimatedRequests = lib.types.int;
      # Add other relevant estimation metrics (e.g., estimated cost)
    };
  };

  # Defines the structure for measured LLM usage after task execution
  llmMeasuredUsageSchema = {
    type = lib.types.attrs;
    attrs = {
      actualTokens = lib.types.int;
      actualRequests = lib.types.int;
      durationMs = lib.types.int; # Duration of the API call in milliseconds
      # Add other relevant measured metrics (e.g., actual cost)
    };
  };

in {
  llmQuotaSchema = llmQuotaSchema;
  llmEstimatedUsageSchema = llmEstimatedUsageSchema;
  llmMeasuredUsageSchema = llmMeasuredUsageSchema;
}
