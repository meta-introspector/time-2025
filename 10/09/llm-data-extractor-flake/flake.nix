{
  description = "An impure flake to extract specific data from hackathon results using an LLM.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    hackathonResults = {
      # This input will be the JSON output from the hackathon-consumer-flake
      # For testing, we can point it to a dummy JSON file or the actual build result.
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/consumer";
      flake = true;
    };
    # Assuming an LLM API wrapper is available as a Nix package
    llmApiWrapper = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/llm-api-wrapper";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, hackathonResults, llmApiWrapper }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      # Define the prompt template for data extraction
      # This could be an input or a separate file
      extractionPromptTemplate = ''
        Given the following hackathon project data in JSON format:

        ${builtins.readFile hackathonResults.packages.aarch64-linux.default}/output.json}

        Extract the following information for each project:
        - Project Name
        - Team Members
        - Technologies Used
        - Project Description (summary, max 2 sentences)
        - Link to Project Repository (if available)

        Format the output as a JSON array of objects, where each object represents a project.
      '';

      # The impure derivation that interacts with the LLM
      extractedData = pkgs.runCommand "extracted-hackathon-data" {
        buildInputs = [ pkgs.bash pkgs.jq llmApiWrapper.packages.aarch64-linux.default ];
        # Pass the hackathon results as a source
        src = hackathonResults.packages.aarch64-linux.default;
        # Pass the prompt template
        prompt = extractionPromptTemplate;
        # Mark as impure because it interacts with an external API
        __impure = true;
      } ''
        mkdir -p $out

        # Construct the full prompt
        FULL_PROMPT="${prompt}"

        # Call the LLM API wrapper
        # Assuming llmApiWrapper provides a binary like 'call-llm-api'
        # and it takes the prompt as an argument and outputs JSON
        ${llmApiWrapper.packages.aarch64-linux.default}/bin/call-llm-api "$FULL_PROMPT" > "$out/extracted-data.json"

        echo "Extracted data saved to $out/extracted-data.json"
      '';
    in
    {
      packages.aarch64-linux.default = extractedData;
    };
}