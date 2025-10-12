{ lib, ... }:

let
  formatPeopleLib = import ./formatters/format-people.nix { inherit lib; };
  formatSystemsLib = import ./formatters/format-systems.nix { inherit lib; };
  formatContainersLib = import ./formatters/format-containers.nix { inherit lib; };
  formatRelationshipsLib = import ./formatters/format-relationships.nix { inherit lib; };
in
{ systemName, description, people, systems, containers, relationships }:
  let
    formatPeople = formatPeopleLib.formatPeople people;
    formatSystems = formatSystemsLib.formatSystems systems;
    formatContainers = formatContainersLib.formatContainers containers;
    formatRelationships = formatRelationshipsLib.formatRelationships relationships;
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
  ''