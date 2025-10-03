{ pkgs, lib, umlData }:

let
  # Function to generate PlantUML entity definition string
  renderElement = elem:
    let
      type = elem.type;
      id = elem.id or (lib.strings.toLower (lib.strings.removeSuffix " " elem.name));
      name = "\"${elem.name}\"" ; # Corrected: escaped quotes for string literal
      tech = if elem ? technology then "\"${elem.technology}\"" else ""; # Corrected: escaped quotes for string literal
      desc = if elem ? description then "\"${elem.description}\"" else ""; # Corrected: escaped quotes for string literal
    in
    if type == "Person" || type == "External_System" then
      "${type}(${id}, ${name}, ${desc})"
    else if type == "System_Boundary" then
      "${type}(${id}, ${name})"
    else
      "${type}(${id}, ${name}, ${tech}, ${desc})";

  # Function to generate PlantUML relationship definition string
  renderRelationship = rel:
    let
      source = rel.source;
      dest = rel.destination;
      desc = "\"${rel.description}\"" ; # Corrected: escaped quotes for string literal
      tech = if rel ? technology then "\"${rel.technology}\"" else ""; # Corrected: escaped quotes for string literal
    in
    "Rel_R(${source}, ${dest}, ${desc}, ${tech})";

  # Assemble all PUML lines
  pumlLines = [
    "@startuml"
    "!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml"
    ""
    "title Hackathon: Gödelian Mycology Workflow (CRQ-012 Arithmetization)"
    ""
    (renderElement umlData.boundary)
    "{"
  ]
    ++ (lib.map renderElement umlData.elements)
    ++ [ "}" ]
    ++ (lib.map renderElement (lib.filter (e: e.type != "System_Boundary") umlData.externals))
    ++ [ "" ]
    ++ (lib.map renderRelationship umlData.relationships)
    ++ [ "@enduml" ];

in
# Final Nix derivation: produces a content-addressable PUML file
pkgs.writeText "hackathon-mycology-workflow.puml" (lib.strings.concatStringsSep "\n" pumlLines)
