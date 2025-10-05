{ lib, umlData }:

let
  # Function to generate PlantUML entity definition string
  renderElement = elem:
    let
      type = elem.type;
      id = elem.id or (lib.strings.toLower (lib.strings.removeSuffix " " elem.name));
      nameStr = lib.strings.escapeNixString elem.name;
      techStr = lib.optionalString (elem ? technology && elem.technology != "") (lib.strings.escapeNixString elem.technology);
      descStr = lib.optionalString (elem ? description && elem.description != "") (lib.strings.escapeNixString elem.description);
    in
    if type == "Person" || type == "External_System" then
      "${type}(${id}, \"${nameStr}\"${lib.optionalString (descStr != "") ", \"${descStr}\"})"
    else if type == "System_Boundary" then
      "${type}(${id}, \"${nameStr}\")"
    else
      "${type}(${id}, \"${nameStr}\"${lib.optionalString (techStr != "") ", \"${techStr}\"${lib.optionalString (descStr != "") ", \"${descStr}\"})";

  # Function to generate PlantUML relationship definition string
  renderRelationship = rel:
    let
      source = rel.source;
      dest = rel.destination;
      descStr = lib.strings.escapeNixString rel.description;
      techStr = lib.optionalString (rel ? technology && rel.technology != "") (lib.strings.escapeNixString rel.technology);
    in
    "Rel_R(${source}, ${dest}, \"${descStr}\"${lib.optionalString (techStr != "") ", \"${techStr}\"})";

  # Assemble all PUML lines
  pumlLines = [
    "@startuml"
    "!include \"https://raw.githubusercontent.com/meta-introspector/C4-PlantUML/master/C4_Container.puml\""
    ""
    "title ${umlData.title}"
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

{
  inherit pumlLines;
  # Optionally, expose renderElement and renderRelationship if they might be reused
  inherit renderElement renderRelationship;
}
