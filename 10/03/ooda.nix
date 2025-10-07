{ lib, ... }:

let
  oodaLoop = {
    observe = {
      description = "Comprehensive indexing of the entire process via strace, perf, ebpf, telemetry, objdump, and addr2line. This phase focuses on collecting raw execution and system data.";
      # Conceptual link to modules responsible for observation
      # modules = [ "nix_2gram_indexer" "telemetry_capture_scripts" ];
    };

    orient = {
      description = "Mapping the collected content (trace data, CRQ content) to the project's meta-model (bott framework, Monster Group, CRQs, formal ontologies). This phase provides context and framework for understanding observations.";
      # Conceptual link to modules responsible for orientation
      # modules = [ "crq_bigram_index" "meta_model_definitions" ];
    };

    decide = {
      description = "Applying rules and performing validation using MiniZinc and Lean4. Based on the orientation, the system decides if its behavior is in harmony with its meta-model and if it is safe.";
      # Conceptual link to modules responsible for decision
      # modules = [ "audit_script" "minizinc_models" "lean4_proofs" ];
    };

    act = {
      description = "Subsequent actions taken based on the validation results from the 'Decide' phase. This could include approving CRQs, flagging issues, triggering re-builds, or initiating further analysis.";
      # Conceptual link to modules responsible for action
      # modules = [ "crq_management_tools" "notification_systems" ];
    };
  };

in
oodaLoop
