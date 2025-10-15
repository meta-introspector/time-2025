{ pkgs, lib, self, bagOfWordsGenerator, flakeFile }:

let
  # Instantiate the key object
  myKeyObject = (import ./key-object.nix) { inherit lib; homedir = "/home/user"; files = [ ]; };

  # Instantiate the model router
  myModelRouter = (import ./model-router.nix) { inherit lib; config = { }; };

  llmFunctor = import ./llm-functor.nix { inherit lib; };

  # Generate bag-of-words report for the current flake.nix
  bagOfWordsReportDerivation = bagOfWordsGenerator.lib.${pkgs.system}.generateBagOfWords flakeFile;
  bagOfWordsReportContent = builtins.readFile "${bagOfWordsReportDerivation}/report.json";

  # Create a list of individual LLM call descriptions
  llmCalls = [
    ((import ./llm-functor.nix) { inherit lib; checksum = self.narHash; keyObject = myKeyObject; modelRouter = myModelRouter; prompt = "Generate a short, creative description for a Nix flake that processes a 'Monster Group Prime Lattice' and outputs its JSON representation. The flake's previous version checksum is: ${self.narHash}. Focus on the 'AI Life Mycology' theme. (Call 1)"; expectedOutputFormat = "markdown"; })
    ((import ./llm-functor.nix) { inherit lib; checksum = self.narHash; keyObject = myKeyObject; modelRouter = myModelRouter; prompt = "Summarize the core functionality of a Nix flake that manages a 'Monster Group Prime Lattice' and its JSON output, considering its previous version checksum: ${self.narHash}. Emphasize the 'AI Life Mycology' context. (Call 2)"; expectedOutputFormat = "markdown"; })
  ];

  # Instantiate the LLM call vector
  # The monadic interface: an impure derivation to execute initial LLM calls
  llmOrchestratorInitial = pkgs.runCommand "llm-orchestrator-initial-results"
    {
      # Mark as impure to allow external network access and homedir access
      __noChroot = true;
      __noSandbox = true;

      buildInputs = [ pkgs.bash ];

      # Pass the pure Nix objects as JSON strings to the script
      LLM_CALL_VECTOR_JSON = builtins.toJSON llmCallVectorDescription;
      KEY_OBJECT_JSON = builtins.toJSON myKeyObject;
      MODEL_ROUTER_JSON = builtins.toJSON myModelRouter;
      BAG_OF_WORDS_REPORT_JSON = bagOfWordsReportContent;

      # Make the script executable
      script = pkgs.writeScript "llm-orchestrator.sh" (builtins.readFile ../scripts/llm-orchestrator.sh);

    } ''
    $script "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$BAG_OF_WORDS_REPORT_JSON" > $out
  '';

  # Fixme task generation stage
  fixmeTaskGeneratorResults = (import ./fixme-task-generator.nix) {
    inherit pkgs lib llmFunctor myKeyObject myModelRouter;
    llmOrchestratorOutput = llmOrchestratorInitial; # Use output of initial orchestration
    bagOfWordsReportContent = bagOfWordsReportContent;
    projectSource = self; # Pass the entire flake as project source for grep
  };

  # Create a new LLM call vector for fixme tasks
  fixmeLlmCallVectorDescription = (import ./llm-call-vector-functor.nix) {
    inherit lib;
    calls = fixmeTaskGeneratorResults.fixmeTasks;
  };

  workpool = (import ./workpool-functor.nix) {
    inherit lib;
    tasks = fixmeTaskGeneratorResults.fixmeTasks;
  };

  # The monadic interface: an impure derivation to execute fixme LLM calls
  llmOrchestratorFixme = pkgs.runCommand "llm-orchestrator-fixme-results"
    {
      # Mark as impure to allow external network access and homedir access
      __noChroot = true;
      __noSandbox = true;

      buildInputs = [ pkgs.bash ];

      # Pass the pure Nix objects as JSON strings to the script
      LLM_CALL_VECTOR_JSON = builtins.toJSON fixmeLlmCallVectorDescription;
      KEY_OBJECT_JSON = builtins.toJSON myKeyObject;
      MODEL_ROUTER_JSON = builtins.toJSON myModelRouter;
      BAG_OF_WORDS_REPORT_JSON = bagOfWordsReportContent; # Still pass bag of words for context

      # Make the script executable
      script = pkgs.writeScript "llm-orchestrator.sh" (builtins.readFile ../scripts/llm-orchestrator.sh);

    } ''
    $script "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$BAG_OF_WORDS_REPORT_JSON" > $out
  '';

in
{
  inherit myKeyObject myModelRouter llmCallVectorDescription llmOrchestratorInitial fixmeTaskGeneratorResults fixmeLlmCallVectorDescription llmOrchestratorFixme;
  # Expose other intermediate results if needed for debugging or further processing
  inherit bagOfWordsReportDerivation bagOfWordsReportContent;
}
