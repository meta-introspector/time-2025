{ pkgs, lib, formalTriad }:

let
  # Architectural Vibe Constraints based on Monster Group factors
  RIGOR_LAYER_DESC = "Enforces GMP, ISO 9000, ITIL compliance (CRQ-010)";
  PURE_DERIVATION_DESC = "Generates content-addressable artifacts, subject to CRQ-012 verification";
  FORMAL_TRIAD_DESC = "Nix, Lean 4/Unimath, MiniZinc for Ultimate Verification";
  
  # UML Element Definitions as Nix Functions/Attribute Sets
  mkBoundary = { name, description }: { type = "System_Boundary"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name description; };
  mkContainer = { name, technology, description }: { type = "Container"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name technology description; };
  mkComponent = { name, technology, description }: { type = "Component"; id = lib.strings.toLower (lib.strings.replaceStrings [" "] ["_"] name); inherit name technology description; };
  mkRel = { source, destination, description, technology ? null }: { type = "Rel"; inherit source destination description technology; };

  # --- System Elements Defined by Nix Attribute Sets ---
  
  # 1. External/Boundary Nodes
  agent = { id = "team_agent"; name = "Mycology Lab Team Agent"; type = "Person"; description = "foaf:Agent operating within the Ultimate Lattice"; };
  monster = { id = "monster_group"; name = "Monster Group (F1)"; type = "External_System"; description = "Ultimate Architectural Template, defining prime influence"; };
  
  # 2. Containers (Workflow Layers)
  framework = mkBoundary {
    name = "quasi_mycology_framework";
    description = "Quasi Meta Mycology Framework (bott Lattice on 8D Manifold)";
  };

  rigorLayer = mkContainer {
    name = "rigor_layer";
    technology = "Nix Derivation (CRQ-010)";
    description = RIGOR_LAYER_DESC;
  };

  cwmVerification = mkContainer {
    name = "cwm_verification";
    technology = "Nix-Native CWM (cwm.nix)";
    description = "FOAF/OWL semantic validation for Agent Identity (foaf:Agent) and compliance with OWL schema before deployment (CRQ-002, CRQ-030)";
  };

  pureEngine = mkContainer {
    name = "pure_derivation_engine";
    technology = "Rust/Nix (CRQ-001/CRQ-007)";
    description = PURE_DERIVATION_DESC;
  };
  
  # 3. Components (Formal Triad)
  leanProof = mkComponent {
    name = "lean4_proof_engine";
    technology = "Lean 4 / Unimath (CRQ-011)";
    description = "Executes proof: Derivation is a Unimath Type (CRQ-012)";
  };
  
  minizincSolver = mkComponent {
    name = "minizinc_solver";
    technology = "MiniZinc";
    description = "Solves symmetry constraints based on Monster Primes";
  };

  # 4. Relationships (The Flow of Formal Verification)
  relationships = [
    (mkRel { source = agent.id; destination = cwmVerification.id; description = "Is Verified By (FOAF/OWL)"; })
    (mkRel { source = agent.id; destination = rigorLayer.id; description = "Submits Strain Portfolio under GMP/ITIL"; })
    (mkRel { source = rigorLayer.id; destination = pureEngine.id; description = "Mandates Purity for Artifact Generation"; })
    (mkRel { source = pureEngine.id; destination = minizincSolver.id; description = "Inputs Complexity/Gödel Numbers"; })
    (mkRel { source = minizincSolver.id; destination = leanProof.id; description = "Outputs Solved Constraints (Arithmetization)"; })
    (mkRel { source = leanProof.id; destination = rigorLayer.id; description = "Provides Formal Proof (CRQ-012)"; technology = "Mathematical Guarantees"; })
    (mkRel { source = pureEngine.id; destination = monster.id; description = "Encodes Artifact based on Monster Genome"; })
    (mkRel { source = monster.id; destination = leanProof.id; description = "Defines Topological Equivalence (HoTT Types as Spaces)"; })
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
