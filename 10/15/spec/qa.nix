{ lib, pkgs }:
{
  name = "quality-assurance-spec";
  description = "Specification for a task that performs quality assurance on raw LLM results, verifying correctness, completeness, and adherence to requirements.";
  taskType = "quality-assurance";
  inputs = {
    rawResults = "A derivation containing the raw LLM results from the /execute task.";
    originalPrompt = "The original prompt or task description for context.";
    expectedOutputFormat = "The expected format of the output.";
  };
  outputs = {
    qaReport = "A derivation containing a report on the quality of the LLM results.";
    verifiedResults = "A derivation containing the verified and potentially refined LLM results.";
  };
}
