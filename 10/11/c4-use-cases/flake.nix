{
  description = "Nix flake to generate C4 PlantUML diagrams for the system's use cases.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Function to generate PlantUML code for a C4 System Context diagram
        generateC4SystemContext = { systemName, description, people, systems, relationships }:
          let
            # Helper to format people
            formatPeople = lib.concatStringsSep "\n" (
              lib.map (p: "Person(${p.id}, \"${p.name}\", \"${p.description}\")") people
            );
            # Helper to format systems
            formatSystems = lib.concatStringsSep "\n" (
              lib.map (s: "System(${s.id}, \"${s.name}\", \"${s.description}\")") systems
            );
            # Helper to format relationships
            formatRelationships = lib.concatStringsSep "\n" (
              lib.map (r: "Rel(${r.from}, ${r.to}, \"${r.description}\")") relationships
            );
          in
          ''
            @startuml C4_SystemContext
            !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

            title System Context Diagram for ${systemName}
            ${description}

            ${formatPeople}

            ${formatSystems}

            ${formatRelationships}

            @enduml
          '';

        # Define the system's use cases as C4 elements
        systemContextDiagram = generateC4SystemContext {
          systemName = "Nix-based Monster Knot System";
          description = "The core system for Gödelian Arithmetization and meta-introspection.";
          people = [
            { id = "geminiCli", name = "Gemini CLI (AI Agent)", description = "Operates, Queries, and Learns from the system." }
          ];
          systems = [
            { id = "monsterKnotSystem", name = "Nix-based Monster Knot System", description = "Processes Nix files into Monster Knot representations." }
            { id = "git", name = "Git Repository", description = "Stores all project source code and history." }
            { id = "nixStore", name = "Nix Store", description = "Content-addressable storage for all derivations and artifacts." }
            { id = "ipfs", name = "IPFS Network", description = "Decentralized immutable storage for data artifacts." }
            { id = "solana", name = "Solana Blockchain", description = "Records transactions and ZKP proofs." }
            { id = "lmfdb", name = "LMFDB (PostgreSQL)", description = "Source of mathematically rigorous data." }
            { id = "lean4", name = "Lean 4 Theorem Prover", description = "Formal verification of mathematical objects (CRQ-012)." }
            { id = "minizinc", name = "MiniZinc Constraint Solver", description = "Constraint modeling and optimization (e.g., for Gödel numbering collision avoidance)." }
            { id = "rust", name = "Rust Ecosystem", description = "Language for ZKP provers, performance-critical components, and system-level tools." }
            { id = "llvm", name = "LLVM Compiler Infrastructure", description = "Backend for Rust compilation, low-level code generation, and analysis." }
          ];
          relationships = [
            { from = "geminiCli", to = "monsterKnotSystem", description = "Operates, Queries, Updates Mappings" }
            { from = "monsterKnotSystem", to = "git", description = "Reads/Writes Nix files, Tracks Changes" }
            { from = "monsterKnotSystem", to = "nixStore", description = "Stores/Retrieves NARs and Derivations" }
            { from = "monsterKnotSystem", to = "ipfs", description = "Stores/Retrieves Immutable Data Artifacts" }
            { from = "monsterKnotSystem", to = "solana", description = "Submits ZKP Proofs, Records Transactions" }
            { from = "monsterKnotSystem", to = "lmfdb", description = "Mirrors Data (Conceptual)" }
            { from = "geminiCli", to = "git", description = "Interacts with (commits, pushes)" }
            { from = "monsterKnotSystem", to = "lean4", description = "Invokes for Formal Verification (CRQ-012)" }
            { from = "monsterKnotSystem", to = "minizinc", description = "Utilizes for Constraint Modeling/Optimization" }
            { from = "monsterKnotSystem", to = "rust", description = "Integrates ZKP Provers and Tools" }
            { from = "rust", to = "llvm", description = "Compiles via" }
            { from = "monsterKnotSystem", to = "llvm", description = "Leverages for Code Analysis/Generation" }
          ];
        };

      in
      {
        packages.default = pkgs.writeText "c4-system-context.puml" systemContextDiagram;
      }
    );
}