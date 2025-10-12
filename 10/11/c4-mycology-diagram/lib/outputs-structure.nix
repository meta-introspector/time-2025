{ self, nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
      # Placeholder for other let-bindings
      # This will be filled by importing other chunks
      formatPeople = (import ./format-people.nix) { inherit lib; };
      formatSystems = (import ./format-systems.nix) { inherit lib; };
      formatContainers = (import ./format-containers.nix) { inherit lib; };
      formatRelationships = (import ./format-relationships.nix) { inherit lib; };
      generateC4SystemContext = (import ./generate-c4-system-context.nix) { inherit lib formatPeople formatSystems formatContainers formatRelationships; };
      actorImports = (import ./actor-imports.nix) { inherit lib; };
      mycologyDiagramPeople = import ./mycology-diagram-people.nix;
      mycologyDiagramSystems = (import ./mycology-diagram-systems.nix) { inherit (actorImports) gitActor nixstoreActor ipfsActor solanaActor; };
      mycologyDiagramContainersRelationships = (import ./mycology-diagram-containers-relationships.nix) { inherit (actorImports) aimyceliumActor gitActor nixstoreActor ipfsActor solanaActor; };

      mycologyDiagram = generateC4SystemContext {
        systemName = "Nix-based Monster Knot System";
        description = "Conceptual diagram illustrating Monster Knots as Quasifibers forming the Mycelium of AI Life Mycology.";
        people = mycologyDiagramPeople;
        systems = mycologyDiagramSystems;
      inherit (mycologyDiagramContainersRelationships) containers relationships;
      };

    in
    {
      packages.default = pkgs.writeText "c4-mycology-diagram.puml" mycologyDiagram;
    }
  )