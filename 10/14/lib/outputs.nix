{ pkgs
, lib
, flakeUtils
, llmPipelineResults
,
}:

let
  llmResponsePackageFunctor = import ./llm-response-package-functor.nix { inherit pkgs lib; };

  # Parse the JSON output from the llmOrchestrator
  orchestratorOutput = builtins.fromJSON (builtins.readFile llmPipelineResults.llmOrchestrator);

  # Create individual packages for each LLM response
  llmResponsePackages = lib.listToAttrs (
    lib.map
      (
        result: {
          name = result.callId;
          value = llmResponsePackageFunctor {
            inherit pkgs lib;
            callId = result.callId;
            prompt = result.prompt;
            response = result.response;
            modelUsed = result.modelUsed;
            checksum = result.checksum;
            metadata = orchestratorOutput.metadata; # Pass orchestrator metadata
          };
        }
      )
      orchestratorOutput.results
  );

  # Create a meta-package that aggregates all individual LLM response packages
  llmResponsesMetaPackage = pkgs.runCommand "llm-responses-meta"
    {
      buildInputs = [ pkgs.coreutils ];
    } ''
    mkdir -p $out
    for pkg in ${lib.concatStringsSep " " (lib.attrValues llmResponsePackages)}; do
      cp -r $pkg/* $out/
    done
  '';

in
{
  packages.${pkgs.system} = {
    default = flakeUtils.monsterGroupPrimeLattice.monsterGroupJson;
    llmResultsInitial = llmPipelineResults.llmOrchestratorInitial;
    llmResultsFixme = llmPipelineResults.llmOrchestratorFixme;
    llmResponses = llmResponsePackages; # Expose individual packages
    llmResponses.default = llmResponsesMetaPackage; # Expose meta-package
    llmWorkpool = llmPipelineResults.workpool;
  };

  lib.monsterGroupData = flakeUtils.monsterGroupPrimeLattice.monsterGroupData;

  lib.previousVersionChecksum = llmPipelineResults.llmCallVectorDescription.calls .0.checksum; # Assuming first call's checksum

  lib.llmCallVectorDescription = llmPipelineResults.fixmeLlmCallVectorDescription;

  lib.debugDump = {
    llmCallVectorInitial = llmPipelineResults.llmCallVectorDescription;
    llmCallVectorFixme = llmPipelineResults.fixmeLlmCallVectorDescription;
    keyObject = llmPipelineResults.myKeyObject;
    modelRouter = llmPipelineResults.myModelRouter;
    llmOrchestratorInitialDerivation = llmPipelineResults.llmOrchestratorInitial;
    llmOrchestratorFixmeDerivation = llmPipelineResults.llmOrchestratorFixme;
    bagOfWordsReport = llmPipelineResults.bagOfWordsReportContent;
    orchestratorOutput = orchestratorOutput;
    llmResponsePackages = llmResponsePackages;
    fixmeTaskGeneratorResults = llmPipelineResults.fixmeTaskGeneratorResults;
    workpool = llmPipelineResults.workpool;
  };

  docs.md = pkgs.writeText "mycology-flake-docs.md" "see file";
}
