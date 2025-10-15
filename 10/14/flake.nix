{
  description = "Flake for AI Life Mycology - Monster Group Prime Lattice";

  inputs = {
    self.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    bagOfWordsGenerator.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=flakes/bag-of-words-generator";
  };

  outputs = { self, nixpkgs, bagOfWordsGenerator, ... }@inputs:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      flakeUtils = (import ./lib/flake-utils.nix) { inherit pkgs lib; };

      llmPipelineResults = (import ./lib/llm-pipeline.nix) {
        inherit pkgs lib self bagOfWordsGenerator;
        flakeFile = ./flake.nix;
      };

      finalOutputs = (import ./lib/outputs.nix) {
        inherit pkgs lib flakeUtils llmPipelineResults;
      };
    in
    {
      packages.${system} = {
        default = flakeUtils.monsterGroupPrimeLattice.monsterGroupJson;
        llmResults = llmPipelineResults.llmOrchestrator;
      };

      lib.monsterGroupData = flakeUtils.monsterGroupPrimeLattice.monsterGroupData;

      lib.previousVersionChecksum = llmPipelineResults.llmCallVectorDescription.calls .0.checksum; # Assuming first call's checksum

      lib.llmCallVectorDescription = llmPipelineResults.llmCallVectorDescription;

      lib.debugDump = {
        llmCallVector = llmPipelineResults.llmCallVectorDescription;
        keyObject = llmPipelineResults.myKeyObject;
        modelRouter = llmPipelineResults.myModelRouter;
        llmOrchestratorDerivation = llmPipelineResults.llmOrchestrator;
        bagOfWordsReport = llmPipelineResults.bagOfWordsReportContent;
      };

      docs.md = pkgs.writeText "mycology-flake-docs.md" "see file";
    };
}	
    
