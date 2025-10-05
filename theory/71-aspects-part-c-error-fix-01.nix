{ lib }:

let
  # buildDescription = { baseText, exampleFileName }:
  #   lib.strings.replaceStrings [ "<EXAMPLE_FILE_NAME>" ] [ exampleFileName ] baseText;

  aspectsOf71 = [
    {
      number = 29;
      title = "The '71' in JSON Event Traces";
      category = "Code Occurrences & Observability";
      description = "Occurrences in JSON lattice event traces (e.g., 'trace_event_trace_event_ff51f91b-0271-4b6a-bb19-ad77203baf9f.json') suggest its presence in system observability data, potentially marking specific events or identifiers within complex system interactions.";
    },
    {
      number = 30;
      title = "The '71' in GitHub Repository IDs";
      category = "Code Occurrences & External References";
      description = "The appearance of '71' in GitHub repository IDs (e.g., 'id":98588021') indicates its pervasive presence in external references and metadata, linking to the broader ecosystem of open-source projects.";
    }
  ];
in aspectsOf71