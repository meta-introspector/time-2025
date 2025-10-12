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
        inherit (nixpkgs) lib;

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
          people = import ./data/people.nix;
          systems = import ./data/systems.nix;
          relationships = import ./data/relationships.nix;
        };

      in
      {
        packages.default = pkgs.writeText "c4-system-context.puml" systemContextDiagram;
      }
    );
}
