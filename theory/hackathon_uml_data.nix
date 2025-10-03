{ pkgs, lib, formalTriad }:

let
  parts = import ./hackathon_71_parts.nix { inherit lib pkgs; };

  # Architectural Vibe Constraints based on Monster Group factors
  RIGOR_LAYER_DESC = parts.rigor_desc_full;
  PURE_DERIVATION_DESC = parts.pure_derivation_desc_full;
  FORMAL_TRIAD_DESC = parts.formal_triad_desc_core;
  
  # UML Element Definitions as Nix Functions/Attribute Sets
  mkBoundary = { name, description }: { type = "System_Boundary"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name description; };
  mkContainer = { name, technology, description }: { type = "Container"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name technology description; };
  mkComponent = { name, technology, description }: { type = "Component"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name technology description; };
  mkRel = { source, destination, description, technology ? null }: { type = "Rel"; inherit source destination description technology; };

  # --- System Elements Defined by Nix Attribute Sets ---
  
  # 1. External/Boundary Nodes
  agent = { id = parts.agent_id; name = parts.agent_name; type = parts.agent_type; description = "${parts.agent_name} operating within the Ultimate Lattice"; };
  monster = { id = parts.monster_id; name = parts.monster_name; type = parts.monster_type; description = "${parts.monster_name} defining prime influence"; };
  
  # 2. Containers (Workflow Layers)
  framework = mkBoundary {
    name = parts.framework_name;
    description = parts.framework_desc;
  };

  rigorLayer = mkContainer {
    name = parts.rigor_name;
    technology = parts.rigor_tech;
    description = RIGOR_LAYER_DESC;
  };

  cwmVerification = mkContainer {
    name = parts.cwm_name;
    technology = parts.cwm_tech;
    description = parts.cwm_desc_full;
  };

  pureEngine = mkContainer {
    name = parts.pure_engine_name;
    technology = parts.pure_engine_tech;
    description = PURE_DERIVATION_DESC;
  };
  
  # 3. Components (Formal Triad)
  leanProof = mkComponent {
    name = parts.lean_proof_name;
    technology = parts.lean_proof_tech;
    description = parts.lean_proof_desc_full;
  };
  
  minizincSolver = mkComponent {
    name = parts.minizinc_solver_name;
    technology = parts.minizinc_solver_tech;
    description = parts.minizinc_desc_full;
  };

  # 4. Relationships (The Flow of Formal Verification)
  relationships = [
    (mkRel { source = parts.rel1_source; destination = parts.rel1_dest; description = parts.rel1_desc; technology = parts.rel1_tech; })
    (mkRel { source = parts.rel2_source; destination = parts.rel2_dest; description = parts.rel2_desc; technology = parts.rel2_tech; })
    (mkRel { source = parts.rel3_source; destination = parts.rel3_dest; description = parts.rel3_desc; technology = parts.rel3_tech; })
    (mkRel { source = parts.rel4_source; destination = parts.rel4_dest; description = parts.rel4_desc; technology = parts.rel4_tech; })
    (mkRel { source = parts.rel5_source; destination = parts.rel5_dest; description = parts.rel5_desc; technology = parts.rel5_tech; })
    (mkRel { source = parts.rel6_source; destination = parts.rel6_dest; description = parts.rel6_desc; technology = parts.rel6_tech; })
    (mkRel { source = parts.rel7_source; destination = parts.rel7_dest; description = parts.rel7_desc; technology = parts.rel7_tech; })
    (mkRel { source = parts.rel8_source; destination = parts.rel8_dest; description = parts.rel8_desc; technology = parts.rel8_tech; })
  ];

  # The main application object that holds all data
  umlData = {
    boundary = framework;
    elements = [ rigorLayer cwmVerification pureEngine leanProof minizincSolver ];
    externals = [ agent monster ];
    relationships = relationships;
  };

in
umlData
