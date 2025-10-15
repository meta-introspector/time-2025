{
  description = "OODA Loop 2: Executing ZOS task chain";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    loop1 = {
      url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos";
      flake = true;
    };

    observeFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos/tasks/observe"; flake = true; };
    orientFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos/tasks/orient"; flake = true; };
    decideFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos/tasks/decide"; flake = true; };
    actFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos/tasks/act"; flake = true; };
    dwimFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/dwim"; flake = true; };
    sourceConfigFlake = { url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/zos/source-config"; flake = true; };
  };

  outputs = { self, nixpkgs, flake-utils, loop1, observeFlake, orientFlake, decideFlake, actFlake, dwimFlake, sourceConfigFlake }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          loop1-output = loop1.packages.${system}.default;

          # Define the OODA loop configurations and influences table
          oodaLoops = {
            loop1 = {
              vibe = "initial-observation";
              guidance = "Focus on broad data collection and initial state assessment.";
              influences = [ "data-integrity" "context-awareness" ];
            };
            loop2 = {
              vibe = "pattern-recognition";
              guidance = "Identify emerging patterns and anomalies from observed data.";
              influences = [ "historical-data" "predictive-models" ];
            };
            loop3 = {
              vibe = "strategic-alignment";
              guidance = "Align observations with strategic goals and potential actions.";
              influences = [ "goal-relevance" "resource-availability" ];
            };
            loop4 = {
              vibe = "action-synthesis";
              guidance = "Synthesize potential actions and evaluate their feasibility.";
              influences = [ "risk-assessment" "impact-analysis" ];
            };
            loop5 = {
              vibe = "execution-orchestration";
              guidance = "Orchestrate the execution of chosen actions.";
              influences = [ "execution-efficiency" "dependency-management" ];
            };
            loop6 = {
              vibe = "feedback-integration";
              guidance = "Integrate feedback from executed actions into the observation phase.";
              influences = [ "feedback-loop-speed" "error-detection" ];
            };
            loop7 = {
              vibe = "system-adaptation";
              guidance = "Adapt the system based on integrated feedback and new insights.";
              influences = [ "system-resilience" "scalability-considerations" ];
            };
            loop8 = {
              vibe = "adaptive-refinement";
              guidance = "Continuously refine strategies and processes for optimal performance.";
              influences = [ "performance-metrics" "user-feedback" ];
            };
          };

          influencesTable = {
            "data-integrity" = {
              description = "Ensuring the accuracy and consistency of data across all sources.";
              priority = 1;
              category = "observation";
            };
            "context-awareness" = {
              description = "Understanding the operational environment, external factors, and their dynamics.";
              priority = 2;
              category = "observation";
            };
            "historical-data" = {
              description = "Leveraging past data to inform current pattern recognition and predictions.";
              priority = 1;
              category = "orientation";
            };
            "predictive-models" = {
              description = "Utilizing models to forecast future states and potential outcomes.";
              priority = 2;
              category = "orientation";
            };
            "goal-relevance" = {
              description = "Assessing how well potential actions align with overall strategic objectives.";
              priority = 1;
              category = "decision";
            };
            "resource-availability" = {
              description = "Evaluating the availability of necessary resources (compute, data, personnel) for actions.";
              priority = 2;
              category = "decision";
            };
            "risk-assessment" = {
              description = "Identifying and evaluating potential risks associated with proposed actions.";
              priority = 1;
              category = "decision";
            };
            "impact-analysis" = {
              description = "Analyzing the potential positive and negative impacts of actions.";
              priority = 2;
              category = "decision";
            };
            "execution-efficiency" = {
              description = "Optimizing the speed and resource usage of action execution.";
              priority = 1;
              category = "action";
            };
            "dependency-management" = {
              description = "Managing interdependencies between different actions and components.";
              priority = 2;
              category = "action";
            };
            "feedback-loop-speed" = {
              description = "The rapidity with which feedback from actions is collected and processed.";
              priority = 1;
              category = "observation";
            };
            "error-detection" = {
              description = "Mechanisms for identifying and reporting failures or deviations from expected outcomes.";
              priority = 2;
              category = "observation";
            };
            "system-resilience" = {
              description = "The ability of the system to withstand and recover from failures or unexpected events.";
              priority = 1;
              category = "adaptation";
            };
            "scalability-considerations" = {
              description = "Planning for the system's ability to handle increased load or complexity.";
              priority = 2;
              category = "adaptation";
            };
            "performance-metrics" = {
              description = "Key indicators used to measure the effectiveness and efficiency of the system.";
              priority = 1;
              category = "refinement";
            };
            "user-feedback" = {
              description = "Incorporating input from users or external stakeholders for system improvement.";
              priority = 2;
              category = "refinement";
            };
          };

          # Get the commit source function from the sourceConfigFlake
          # We pass the 'self' commit hash to the sourceConfigFlake so it can use it as a base.
          # The 'self' here refers to the current flake (loop2).
          sourceConfig = sourceConfigFlake.lib.getLoopSourceConfig self.rev;

          # Recursive function to run the OODA loop
          runOODALoop = loopNum: previousActResult:
            let
              loopConfig = builtins.getAttr ("loop" + (toString loopNum)) oodaLoops;
              loopVibe = loopConfig.vibe;
              loopGuidance = loopConfig.guidance;
              loopInfluences = loopConfig.influences;
              loopCommit = sourceConfig.getCommitForLoop loopNum; # Use the function from sourceConfigFlake

              # Override inputs for observe, orient, decide, act with loop-specific commit
              # This is a conceptual change, actual implementation will be more involved
              # and might require modifying the task flakes themselves to accept these.
              # For now, we'll just pass them as arguments to the task functions.

              observe-result = (observeFlake.packages.${system}.default) {
                zos = previousActResult; # Pass previous act result as zos
                loopInfo = {
                  inherit loopNum loopVibe loopGuidance loopInfluences loopCommit;
                };
              };

              orient-result = (orientFlake.packages.${system}.default) {
                observe = observe-result;
                loopInfo = {
                  inherit loopNum loopVibe loopGuidance loopInfluences loopCommit;
                };
              };

              decide-result = (decideFlake.packages.${system}.default) {
                orientationDecision = orient-result;
                loopInfo = {
                  inherit loopNum loopVibe loopGuidance loopInfluences loopCommit;
                };
              };

              act-result = (actFlake.packages.${system}.default) {
                actionPlan = decide-result;
                dwimFlake = dwimFlake; # dwimFlake is a global input
                loopInfo = {
                  inherit loopNum loopVibe loopGuidance loopInfluences loopCommit;
                };
              };

            in
            if loopNum == 8 then act-result # Base case: last loop returns its result
            else runOODALoop (loopNum + 1) act-result;

          # Initial call to the OODA loop
          finalActResult = runOODALoop 1 loop1-output; # Start with loop1 and initial zos from loop1-output
        in
        {
          packages = {
            # The final result of the loop2 is the output of the 'act' task
            default = finalActResult;
          };
        });
}
