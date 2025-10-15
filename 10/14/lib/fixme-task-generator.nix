{ pkgs
, lib
, llmOrchestratorOutput
, bagOfWordsReportContent
, projectSource
, llmFunctor
, myKeyObject
, myModelRouter
,
}:

let
  stopWords = import ./stop-words.nix;

  # Parse the orchestrator output and bag-of-words report
  orchestratorOutput = builtins.fromJSON (builtins.readFile llmOrchestratorOutput);
  bagOfWordsReport = builtins.fromJSON bagOfWordsReportContent;

  # Extract words from LLM responses (simplified for now)
  # In a real scenario, this would involve more sophisticated text processing.
  allWords = lib.unique (
    lib.flatten (
      lib.map
        (
          result: lib.splitString " " (lib.replaceStrings [ "." "," ";" ":" "!" "?" "(" ")" "[" "]" "{" "}" "\"" "'" ] (lib.repeat 1 "") (lib.toLower result.response))
        )
        orchestratorOutput.results
    )
  );

  # Filter out stop words
  meaningfulWords = lib.filter (word: !(lib.elem word stopWords)) allWords;

  # Sort words by frequency from bag-of-words report and select top N
  # This assumes bagOfWordsReport is an attribute set of word -> count
  sortedWords = lib.sort
    (
      a: b: (bagOfWordsReport.${a} or 0) > (bagOfWordsReport.${b} or 0)
    )
    meaningfulWords;

  topNWords = lib.take 10 sortedWords; # Limit to top 10 words

  # Generate fixme tasks for each selected word
  fixmeTasks = lib.map
    (
      word:
      let
        # Perform grep for the word in the project source
        grepResult = pkgs.runCommand "grep-result-${word}"
          {
            buildInputs = [ pkgs.gnugrep ];
            src = projectSource; # The project source to grep in
          } ''
          grep -r -i -F "${word}" $src > $out
        '';
      in
      llmFunctor {
        inherit lib myKeyObject myModelRouter;
        checksum = "fixme-checksum-${word}"; # Placeholder checksum
        prompt = "Analyze the term '${word}' within the project context. Consider the following grep output: ${builtins.readFile grepResult}. Provide insights on its usage, potential issues, or areas for improvement. Original LLM response context: ${builtins.toJSON orchestratorOutput.results}.";
        expectedOutputFormat = "markdown";
      }
    )
    topNWords;

in
{
  inherit fixmeTasks;
}
