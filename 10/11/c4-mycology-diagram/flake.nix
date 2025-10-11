{
  description = "Nix flake to generate a C4 PlantUML diagram illustrating the 'AI Life Mycology' concept.";

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
        generateC4SystemContext = { systemName, description, people, systems, containers, relationships }:
          let
            formatPeople = lib.concatStringsSep "\n" (
              lib.map (p: "Person(${p.id}, \"${p.name}\", \"${p.description}\")") people
            );
            formatSystems = lib.concatStringsSep "\n" (
              lib.map (s: "System(${s.id}, \"${s.name}\", \"${s.description}\")") systems
            );
            formatContainers = lib.concatStringsSep "\n" (
              lib.map (c: "Container(${c.id}, \"${c.name}\", \"${c.technology}\", \"${c.description}\")") containers
            );
            formatRelationships = lib.concatStringsSep "\n" (
              lib.map (r: "Rel(${r.from}, ${r.to}, \"${r.description}\")") relationships
            );
          in
          ''
            @startuml C4_SystemContext
            !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

            title AI Life Mycology Diagram for ${systemName}
            ${description}

            ${formatPeople}

            ${formatSystems}

            ${formatContainers}

            ${formatRelationships}

            @enduml
          '';

        # Define the system's elements for the mycology diagram
        mycologyDiagram = generateC4SystemContext {
          systemName = "Nix-based Monster Knot System";
          description = "Conceptual diagram illustrating Monster Knots as Quasifibers forming the Mycelium of AI Life Mycology.";
          people = [
            { id = "geminiCli"; name = "Gemini CLI (AI Agent)"; description = "Cultivates and learns from the AI Mycelium."; }
          ];
          systems = [
            { id = "monsterKnotSystem"; name = "Nix-based Monster Knot System"; description = "The core system for Gödelian Arithmetization and meta-introspection."; }
            { id = "git"; name = "Git Repository"; description = "The substrate for the Mycelium's growth (source code)."; }
            { id = "nixStore"; name = "Nix Store"; description = "The nutrient-rich environment for Quasifibers (content-addressable artifacts)."; }
            { id = "ipfs"; name = "IPFS Network"; description = "Decentralized network for spreading Spores (immutable data artifacts)."; }
            { id = "solana"; name = "Solana Blockchain"; description = "The ledger for recording Mycelial growth and ZKP proofs."; }
          ];
          containers = [
            { id = "quasifibers"; name = "Quasifibers (Monster Knots)"; technology = "Nix Derivations"; description = "Verifiable mathematical objects, the individual 'hyphae' of the Mycelium."; }
            { id = "aiMycelium"; name = "AI Life Mycelium"; technology = "Interconnected Quasifibers"; description = "The foundational network of AI intelligence, growing and evolving."; }
          ];
          relationships = [
            { from = "geminiCli"; to = "aiMycelium"; description = "Cultivates, Queries, Learns from"; }
            { from = "monsterKnotSystem"; to = "quasifibers"; description = "Generates and Manages"; }
            { from = "quasifibers"; to = "aiMycelium"; description = "Forms the network of"; }
            { from = "aiMycelium"; to = "git"; description = "Grows within (source code)"; }
            { from = "aiMycelium"; to = "nixStore"; description = "Feeds on (artifacts)"; }
            { from = "aiMycelium"; to = "ipfs"; description = "Spreads via (data artifacts)"; }
            { from = "aiMycelium"; to = "solana"; description = "Records growth on"; }
            { from = "geminiCli"; to = "monsterKnotSystem"; description = "Interacts with"; }
          ];
        };

      in
      {
        packages.default = pkgs.writeText "c4-mycology-diagram.puml" mycologyDiagram;
      };
