# 10/03/lib/plantuml_generator.nix
# This file contains logic for generating PlantUML diagrams from part definitions.

{ lib, umlData }:

let
  inherit (lib)
    concatStringsSep
    escapeNixString
    mapAttrsToList
    map
    replaceStrings
    ;

  # Function to generate PlantUML for a single part
  generatePartUML = { id, title, description, vibe, relatedCRQs, dependencies, outputs }:
    let
      # Escape PlantUML reserved characters in description
      escapedDescription = replaceStrings [ "<" ">" "{" "}" "[" "]" "|" "\\" ] [ "\\<" "\\>" "\\{" "\\}" "\[" "\]" "\\|" "\\\\" ] description;

      # Format related CRQs
      formattedCRQs = if relatedCRQs == [ ] then "" else "  -- Related CRQs: ${concatStringsSep ", " relatedCRQs}";

      # Format dependencies
      formattedDependencies = if dependencies == [ ] then "" else "  -- Dependencies: ${concatStringsSep ", " dependencies}";

      # Format outputs
      formattedOutputs = if outputs == [ ] then "" else "  -- Outputs: ${concatStringsSep ", " outputs}";

    in
    ''
      component "Part ${id}: ${title}" as part${id} <<${vibe}>> {
        note as N${id}
          ${escapedDescription}
          ${formattedCRQs}
          ${formattedDependencies}
          ${formattedOutputs}
        end note
      }
    '';

  # Generate UML for all parts
  allPartsUML = concatStringsSep "\n" (mapAttrsToList (name: generatePartUML) umlData.parts);

  # Generate relationships between parts
  allRelationshipsUML = concatStringsSep "\n" (mapAttrsToList
    (name: part:
      let
        sourceId = part.id;
        dependenciesUML = concatStringsSep "\n" (map (depId: "part${depId} --> part${sourceId}") part.dependencies);
      in
      dependenciesUML
    )
    umlData.parts);

in
{
  inherit allPartsUML allRelationshipsUML;
}
