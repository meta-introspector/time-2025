{ pkgs
, lib
, callId
, prompt
, response
, modelUsed
, checksum
, metadata ? { }
,
}:

let
  packageName = "llm-response-${callId}";
  outputContent = ''
    LLM Call ID: ${callId}
    Prompt: ${prompt}
    Response: ${response}
    Model Used: ${modelUsed}
    Checksum: ${checksum}
    Metadata: ${builtins.toJSON metadata}
  '';
in

pkgs.writeText packageName outputContent
