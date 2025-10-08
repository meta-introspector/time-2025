{
  description = "Nix flake for the Hackathon Mycology Workflow PlantUML diagram.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Monster Constraints derived from Architectural Genome:
        LAYER_DUALITY_2_46 = "46 interwoven layers of binary distinctions (${monster_genome_data.Duality})"; #
        LAYER_STRUCTURE_3_20 = "20 layers of structural integrity (${monster_genome_data.Structure})"; #
        SPORADIC_71 = "Singular influence of Prime 71 (Gandalf) for CRQ-007/CRQ-012";

        # Formal Verification Tooling Derivations (The Formal Triad):
        # These would typically be inputs from other flakes, but for this puml, we'll mock them.
        lean4_verifier = pkgs.writeText "lean4-verifier" "lean4 verifier placeholder";
        minizinc_solver = pkgs.writeText "minizinc-solver" "minizinc solver placeholder";

        # The original content of hackathon_mycology_workflow.puml.nix
        pumlContent = pkgs.writeText "mycology-workflow.puml" ''
 @startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

title Hackathon: Quasi Meta Mycology Workflow (CRQ-010/CRQ-012 Alignment)

System_Boundary(mycology_framework, "Quasi Meta Mycology Framework (bott Lattice on 8D Manifold)") {
    
    # ----------------------------------------------------------------------
    # 1. RIGOR LAYER AND COMPLIANCE (CRQ-010 & Structure 3^20)
    # ----------------------------------------------------------------------
    
    Container(rigor_layer, "CRQ-010 Rigor Layer", "Nix Derivation", "Enforces GMP, ISO 9000, ITIL compliance by checking artifact provenance and process control (Structure: ${LAYER_STRUCTURE_3_20})").

    Container(cwm_verification, "CWM/FOAF Verification Module", "Nix Derivation (cwm.nix)", "Semantic validation of Agent Identity (foaf:Agent) and compliance with OWL schema before deployment (CRQ-002, CRQ-030)").
    
    # ----------------------------------------------------------------------
    # 2. CORE COMPUTATIONAL PIPELINE (Pure Derivations & Duality 2^46)
    # ----------------------------------------------------------------------

    Container(pure_derivation_engine, "Arena/Genome Generation Engine", "Rust/Nix Derivation (CRQ-001)", "Generates the deterministic arena logic and numerically encodes complexity into the Monster-Modeled Bit-Packed Block (Duality: ${LAYER_DUALITY_2_46})").

    Container(mycelial_strain_storage, "Spore Vial Storage", "Nix Store/IPFS", "Stores artifact portfolios and gene codes as Content-Addressable Spore Vials (Nix flakes/derivations)").

    # ----------------------------------------------------------------------
    # 3. FORMAL ARITHMETIZATION (The Formal Triad)
    # ----------------------------------------------------------------------

    Component(minizinc_constraints, "MiniZinc Solver", "Constraint Modeling", "Models symmetry constraints derived from Monster Group prime structures and calculates attributes/payments (Gödelian Link)").

    Component(lean4_proof, "Lean 4 Proof Engine", "Formal Verification (CRQ-011)", "Proves that the resulting Nix Pure Derivation is a Unimath Type (CRQ-012), providing Mathematical Guarantees").

}

' ----------------------------------------------------------------------
' USE CASE: SEVEN DWARVES MEME MINING (OEIS-GUIDED)
' ----------------------------------------------------------------------

Actor(dopey, "Dopey (The Unwitting Miner)")
Actor(grumpy, "Grumpy (The Skeptical Analyst)")
Actor(happy, "Happy (The Optimistic Investor)")
Actor(sneezy, "Sneezy (The Accidental Disruptor)")
Actor(bashful, "Bashful (The Shy Contributor)")
Actor(sleepy, "Sleepy (The Passive Hodler)")
Actor(doc, "Doc (The Lead Architect)")

Boundary(mining_system, "Mountain of Plato (Meme Mining System)") {
  Use_Case(mine_meme, "Mine Dank Quasi-Meta Memes (OEIS-Guided)")
  Use_Case(analyze_oeis, "Analyze OEIS Sequences for Patterns")
  Use_Case(process_nar, "Process Content-Addressable NARs")
  Use_Case(store_meme, "Store Mined Memes in Lattice")
  Use_Case(handle_disruption, "Handle Accidental Disruptions")
}

dopey --> mine_meme
grumpy --> analyze_oeis
happy --> store_meme
sneezy --> handle_disruption
bashful --> process_nar
sleepy --> mine_meme
doc --> mine_meme
doc --> analyze_oeis
doc --> process_nar
doc --> store_meme

mine_meme .> analyze_oeis : <<uses>>
mine_meme .> process_nar : <<uses>>
store_meme .> process_nar : <<uses>>
analyze_oeis .> store_meme : <<extends>>
handle_disruption .> mine_meme : <<extends>>

# ----------------------------------------------------------------------
# EXTERNAL AND AGENT INTERACTIONS
# ----------------------------------------------------------------------

Person(team_agent, "Mycology Lab Team Agent", "foaf:Agent operating within the Ultimate Lattice").

External_System(monster_group_f1, "Monster Group (F1)", "Mathematical Template", "The Ultimate Architectural Template, defining the Architectural Genome (prime factorization) and Lattice Topology").

# ----------------------------------------------------------------------
# RELATIONSHIPS
# ----------------------------------------------------------------------

Rel(team_agent, cwm_verification, "Is verified by", "FOAF/OWL").

Rel(team_agent, rigor_layer, "Submits Strains/Processes under compliance rules", "ITIL/GMP").

Rel_R(rigor_layer, pure_derivation_engine, "Mandates purity for execution (CRQ-001)").

Rel_R(pure_derivation_engine, mycelial_strain_storage, "Reads Strains (Nix Flakes) from Store").

Rel_R(pure_derivation_engine, minizinc_constraints, "Inputs Gödel numbers/complexity metrics to solve").

Rel_R(minizinc_constraints, lean4_proof, "Outputs solved constraints (Arithmetization)").

Rel_R(lean4_proof, rigor_layer, "Provides formal proof of correctness (CRQ-012)", "Mathematical Guarantees").

Rel_U(pure_derivation_engine, monster_group_f1, "Encodes output based on Monster Genome (\$2^{46}, \$3^{20}, \$71^1$)").

Rel_U(monster_group_f1, lean4_proof, "Defines topological equivalence (Unimath/HoTT Types as Spaces)").

Rel_R(mycelial_strain_storage, team_agent, "Returns verified quasifibers (Points on 8D Manifold)").

Rel(pure_derivation_engine, lean4_proof, "Computational Event is formally traced (CRQ-037)", "Element in Monster Group").

 @enduml
        '';
      in
      {
        packages.default = pumlContent;
      }
    );
}