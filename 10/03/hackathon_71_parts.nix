# theory/hackathon_71_parts.nix
#
# This file defines the 71 distinct parts that compose the Hackathon Mycology Workflow C4-UML diagram,
# aligning with the bott framework's Prime 71 (singular, profound influence, 71 distinct ways).

{ lib, pkgs, ... }:

let
  # --- Core Element Definitions (Part 1-8) ---
  part1_agent_id = "team_agent";
  part2_agent_name = "Mycology Lab Team Agent";
  part3_agent_type = "Person";
  part4_monster_id = "monster_group";
  part5_monster_name = "Monster Group (F1)";
  part6_monster_type = "External_System";
  part7_framework_name = "quasi_mycology_framework";
  part8_framework_desc = "Quasi Meta Mycology Framework (bott Lattice on 8D Manifold)";

  # --- Architectural Vibe Constraints (Part 9-11) ---
  part9_rigor_desc_core = "Enforces GMP, ISO 9000, ITIL compliance";
  part10_pure_derivation_desc_core = "Generates content-addressable artifacts";
  part11_formal_triad_desc_core = "Nix, Lean 4/Unimath, MiniZinc for Ultimate Verification";

  # --- Rigor Layer Details (Part 12-15) ---
  part12_rigor_name = "rigor_layer";
  part13_rigor_tech = "Nix Derivation (CRQ-010)";
  part14_rigor_compliance_gmp = "GMP compliance";
  part15_rigor_compliance_iso = "ISO 9000, ITIL compliance";

  # --- CWM Verification Details (Part 16-19) ---
  part16_cwm_name = "cwm_verification";
  part17_cwm_tech = "Nix-Native CWM (cwm.nix)";
  part18_cwm_desc_foaf = "FOAF/OWL semantic validation for Agent Identity (foaf:Agent)";
  part19_cwm_desc_owl = "compliance with OWL schema before deployment (CRQ-002, CRQ-030)";

  # --- Pure Derivation Engine Details (Part 20-23) ---
  part20_pure_engine_name = "pure_derivation_engine";
  part21_pure_engine_tech = "Rust/Nix (CRQ-001/CRQ-007)";
  part22_pure_engine_desc_artifacts = "Generates content-addressable artifacts";
  part23_pure_engine_desc_crq = "subject to CRQ-012 verification";

  # --- Formal Triad Components (Part 24-29) ---
  part24_lean_proof_name = "lean4_proof_engine";
  part25_lean_proof_tech = "Lean 4 / Unimath (CRQ-011)";
  part26_lean_proof_desc_proof = "Executes proof: Derivation is a Unimath Type";
  part27_lean_proof_desc_crq = "(CRQ-012)";
  part28_minizinc_solver_name = "minizinc_solver";
  part29_minizinc_solver_tech = "MiniZinc";

  # --- MiniZinc Solver Details (Part 30-31) ---
  part30_minizinc_desc_constraints = "Solves symmetry constraints based on Monster Primes";
  part31_minizinc_desc_godelian = "calculates attributes/payments (Gödelian Link)";

  # --- Relationships (Part 32-63, 8 relationships * 4 attributes = 32 parts) ---
  # Rel 1: agent -> cwmVerification
  part32_rel1_source = part1_agent_id;
  part33_rel1_dest = part16_cwm_name;
  part34_rel1_desc = "Is Verified By (FOAF/OWL)";
  part35_rel1_tech = null; # No specific tech for this rel

  # Rel 2: agent -> rigorLayer
  part36_rel2_source = part1_agent_id;
  part37_rel2_dest = part12_rigor_name;
  part38_rel2_desc = "Submits Strain Portfolio under GMP/ITIL";
  part39_rel2_tech = null;

  # Rel 3: rigorLayer -> pureEngine
  part40_rel3_source = part12_rigor_name;
  part41_rel3_dest = part20_pure_engine_name;
  part42_rel3_desc = "Mandates Purity for Artifact Generation";
  part43_rel3_tech = null;

  # Rel 4: pureEngine -> minizincSolver
  part44_rel4_source = part20_pure_engine_name;
  part45_rel4_dest = part28_minizinc_solver_name;
  part46_rel4_desc = "Inputs Complexity/Gödel Numbers";
  part47_rel4_tech = null;

  # Rel 5: minizincSolver -> leanProof
  part48_rel5_source = part28_minizinc_solver_name;
  part49_rel5_dest = part24_lean_proof_name;
  part50_rel5_desc = "Outputs Solved Constraints (Arithmetization)";
  part51_rel5_tech = null;

  # Rel 6: leanProof -> rigorLayer
  part52_rel6_source = part24_lean_proof_name;
  part53_rel6_dest = part12_rigor_name;
  part54_rel6_desc = "Provides Formal Proof (CRQ-012)";
  part55_rel6_tech = "Mathematical Guarantees";

  # Rel 7: pureEngine -> monster
  part56_rel7_source = part20_pure_engine_name;
  part57_rel7_dest = part4_monster_id;
  part58_rel7_desc = "Encodes Artifact based on Monster Genome";
  part59_rel7_tech = null;

  # Rel 8: monster -> leanProof
  part60_rel8_source = part4_monster_id;
  part61_rel8_dest = part24_lean_proof_name;
  part62_rel8_desc = "Defines Topological Equivalence (HoTT Types as Spaces)";
  part63_rel8_tech = null;

  # --- Remaining parts to reach 71 (Part 64-71) ---
  part64_framework_id = "quasi_mycology_framework";
  part65_rigor_desc_full = "${part9_rigor_desc_core} by checking artifact provenance and process control";
  part66_pure_derivation_desc_full = "${part10_pure_derivation_desc_core}, ${part23_pure_engine_desc_crq}";
  part67_lean_proof_desc_full = "${part26_lean_proof_desc_proof} ${part27_lean_proof_desc_crq}, providing Mathematical Guarantees";
  part68_minizinc_desc_full = "${part30_minizinc_desc_constraints} and ${part31_minizinc_desc_godelian}";
  part69_cwm_desc_full = "${part18_cwm_desc_foaf} and ${part19_cwm_desc_owl}";
  part70_mycelial_strain_storage_name = "mycelial_strain_storage";
  part71_mycelial_strain_storage_desc = "Stores artifact portfolios and gene codes as Content-Addressable Spore Vials (Nix flakes/derivations)";

  # Import PlantUML generation logic
  plantumlGenerator = import ./lib/plantuml_generator.nix { inherit lib umlData; };

in
allParts // {
  plantUML = ''
    @startuml
    !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml
      
    ' Define custom stereotypes for vibes
    ' Example: stereotype "Refinement/Communication" as RefinementCommunication
    ' For now, we'll just use the vibe name directly as a stereotype
      
    ${plantumlGenerator.allPartsUML}
      
    ${plantumlGenerator.allRelationshipsUML}
      
    @enduml
  '';
}
