{ lib, ... }:

let
  buildDescription = { exampleFileName, otelContext }:
    "Occurrences in JSON lattice event traces (e.g., '${exampleFileName}') suggest its presence in system observability data, potentially marking specific events or identifiers within complex system interactions, specifically in the context of ${otelContext}.";

  aspect29 = {
    number = 29;
    title = "The '71' in JSON Event Traces (OTel Event Trace)";
    category = "Code Occurrences & Observability";
    description = buildDescription {
      exampleFileName = "trace_event_trace_event_ff51f91b-0271-4b6a-bb19-ad77203baf9f.json";
      otelContext = "OpenTelemetry (OTel) event traces";
    };
  };
in aspect29