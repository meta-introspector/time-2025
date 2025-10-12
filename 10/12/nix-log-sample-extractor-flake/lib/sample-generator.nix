{ lib, pkgs, logAnalysisPipeline, system } @ args:

let
  nixLogParser = logAnalysisPipeline.lib.${system};

  # Function to process a single parsed log entry and return its sample data
  processLogEntry = logEntry:
    let
      # Extract event type
      eventType = logEntry.type or "Unknown";

      # Extract Nix store paths from relevant fields
      pathsFromLine = if logEntry ? line then nixLogParser.extractNixStorePathsFromLine logEntry.line else [ ];
      pathsFromText = if logEntry ? text then nixLogParser.extractNixStorePathsFromLine logEntry.text else [ ];
      pathsFromDerivation = if logEntry ? fields && logEntry.fields ? derivation then nixLogParser.extractNixStorePathsFromLine logEntry.fields.derivation else [ ];

      # Combine and deduplicate paths
      allPaths = lib.unique (pathsFromLine ++ pathsFromText ++ pathsFromDerivation);

      # Create a canonical representation of the sample data for hashing
      # We use builtins.toJSON to ensure a stable string representation for hashing
      sampleData = builtins.toJSON {
        type = eventType;
        content = builtins.toJSON logEntry; # Store the original parsed JSON content
        nixStorePaths = allPaths;
      };
      sampleHash = pkgs.lib.hashString "sha256" sampleData;
    in
    {
      inherit eventType sampleData sampleHash allPaths;
      originalContent = logEntry;
    };

  # Function to generate the content of a pure Nix test case file
  generateSampleNixFileContent = { eventType, originalContent, allPaths }:
    let
      # Convert originalContent and allPaths to JSON strings for embedding
      originalContentJson = builtins.toJSON originalContent;
      allPathsJson = builtins.toJSON allPaths;
    in
    ''
      { lib, ... }:
      {
        type = "${eventType}";
        content = builtins.fromJSON ${builtins.toJSON originalContentJson};
        nixStorePaths = builtins.fromJSON ${builtins.toJSON allPathsJson};
      }
    '';

  # Main function to extract samples from a log file
  extractSamplesFromLogFile = { logFilePath, maxSamples ? 20 }:
    let
      # Local functions for tokenization and novelty detection
      # Function to tokenize a log line
      tokenizeLine = logLine:
        let
          # Extract words (simple tokenization)
          words = lib.strings.splitString " " (lib.strings.toLower logLine);
          # Extract Nix store paths
          nixPaths = nixLogParser.extractNixStorePathsFromLine logLine;
        in
        lib.unique (words ++ nixPaths);

      # Function to check if a line contains novel tokens
      isNovel = { currentTokens, knownTokens }:
        let
          newTokens = lib.lists.filter (token: !(lib.lists.elem token knownTokens)) currentTokens;
        in
        newTokens != [ ];

      # Function to update the knowledge base (list of known tokens)
      updateKB = { currentTokens, knownTokens }:
        lib.unique (knownTokens ++ currentTokens);

      # Impure step: Read log file and convert to JSON array using jq
      logJsonArrayDerivation = pkgs.runCommand "log-to-json-array" {
        src = logFilePath;
        nativeBuildInputs = [ pkgs.jq ];
      } ''
        cat "$src" | jq -s '.' > "$out"
      '';

      logEntries = builtins.fromJSON (builtins.readFile logJsonArrayDerivation);

      # Recursive function to process log entries and collect samples
      collectSamples = { entries, currentKnownTokens, collectedSamples, sampleCount }:
        if sampleCount >= maxSamples || lib.lists.length entries == 0
        then collectedSamples
        else
          let
            currentEntry = lib.lists.head entries;
            remainingEntries = lib.lists.tail entries;

            lineTokens = tokenizeLine (builtins.toJSON currentEntry); # Tokenize the raw JSON line
            isEntryNovel = isNovel { currentTokens = lineTokens; knownTokens = currentKnownTokens; };

            newKnownTokens = if isEntryNovel
                             then updateKB { currentTokens = lineTokens; knownTokens = currentKnownTokens; }
                             else currentKnownTokens;

            processedSample = processLogEntry currentEntry;
            sampleFilename = "${processedSample.eventType}-${processedSample.sampleHash}.nix";
            sampleContent = generateSampleNixFileContent {
              inherit (processedSample) eventType originalContent allPaths;
            };

            newCollectedSamples = if isEntryNovel
                                  then collectedSamples ++ [ { inherit sampleFilename sampleContent; } ]
                                  else collectedSamples;

            newSampleCount = if isEntryNovel then sampleCount + 1 else sampleCount;
          in
          collectSamples {
            entries = remainingEntries;
            currentKnownTokens = newKnownTokens;
            collectedSamples = newCollectedSamples;
            sampleCount = newSampleCount;
          };

      finalSamples = collectSamples {
        entries = logEntries;
        currentKnownTokens = [ ]; # Start with an empty KB
        collectedSamples = [ ];
        sampleCount = 0;
      };
    in
    finalSamples; # Return the list of collected samples

in
{
  inherit processLogEntry generateSampleNixFileContent extractSamplesFromLogFile;
}
