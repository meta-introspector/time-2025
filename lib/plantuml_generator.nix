{ lib, umlData }:

let
  # Helper function to properly quote and escape strings for PlantUML
  quoteString = str: "\\\"${lib.strings.escapeNixString str}\\\"";

  # Helper function to construct a PlantUML entity string
  createEntity = { type, id, name, technology ? null, description ? null }:
    let
      args = [ (quoteString name) ]
        ++ (lib.optional (technology != null) (quoteString technology))
        ++ (lib.optional (description != null) (quoteString description));
    in
    "${type}(${id}, ${lib.strings.concatStringsSep ", " args})";

  # Helper function to construct a PlantUML relationship string
  createRelationship = { source, destination, description, technology ? null }:
    let
      args = [ (quoteString description) ]
        ++ (lib.optional (technology != null) (quoteString technology));
    in
    "Rel_R(${source}, ${destination}, ${lib.strings.concatStringsSep ", " args})";

  # Function to generate PlantUML entity definition string
  renderElement = elem:
    let
      id = elem.id or (lib.strings.toLower (lib.strings.removeSuffix " " elem.name));
    in
    if elem.type == "Person" || elem.type == "External_System" then
      createEntity { inherit (elem) type; inherit id; inherit (elem) name; inherit (elem) description; }
    else if elem.type == "System_Boundary" then
      createEntity { inherit (elem) type; inherit id; inherit (elem) name; }
    else
      createEntity { inherit (elem) type; inherit id; inherit (elem) name; inherit (elem) technology; inherit (elem) description; };

  # Function to generate PlantUML relationship definition string
  renderRelationship = rel:
    createRelationship {
      inherit (rel) source;
      inherit (rel) destination;
      inherit (rel) description;
      inherit (rel) technology;
    };

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
  inherit renderElement renderRelationship;
  inherit quoteString createEntity createRelationship;
}
