# verify-foaf-owl.nix
{ pkgs, lib, foafData, owlSchema, ... }:

let
  # Extract classes and properties from the OWL schema
  owlClasses = lib.filter (e: e."@type" == "http://www.w3.org/2002/07/owl#Class") owlSchema."@graph";
  owlProperties = lib.filter (e: lib.hasAttrByPath ["@type"] e && (e."@type" == "http://www.w3.org/2002/07/owl#ObjectProperty" || e."@type" == "http://www.w3.org/2002/07/owl#DatatypeProperty")) owlSchema."@graph";

  # Helper to get all IDs of defined classes
  classIds = lib.map (c: c."@id") owlClasses;

  # Helper to get all IDs of defined properties
  propertyIds = lib.map (p: p."@id") owlProperties;

  # Convert owlProperties to an attribute set keyed by @id for efficient lookup
  owlPropertiesById = lib.listToAttrs (lib.map (p: { name = p."@id"; value = p; }) owlProperties);

  # Function to check if a type is a defined OWL class
  isDefinedClass = typeId: lib.elem typeId classIds;

  # Function to check if a property is a defined OWL property
  isDefinedProperty = propertyId: lib.elem propertyId propertyIds;

  # --- Validation Logic ---

  # Validate each entity in the FOAF graph
  validateEntities = lib.map (entity:
    let
      entityId = entity."@id" or "unknown";
      entityType = entity."@type" or null;
      isValidType = if entityType == null then false else isDefinedClass entityType;
      typeCheckResult = if isValidType
        then { status = "PASS"; message = "Type '${entityType}' is a defined OWL class."; }
        else { status = "FAIL"; message = "Type '${entityType}' for entity '${entityId}' is not a defined OWL class."; };

      # Check properties of the entity against OWL schema
      propertyCheckResults = lib.filter (p: p.status == "FAIL") (lib.mapAttrsToList (attrName: attrValue:
        let
          # Skip special attributes like @id, @type, dcterms:title, etc.
          # We are focusing on properties that might have domain/range constraints
          isSpecialAttr = lib.elem attrName ["@id" "@type" "dcterms:title" "dcterms:description" "schema:solution" "schema:impact" "dcterms:identifier" "dcterms:created" "dcterms:creator"];
          propertyDef = owlPropertiesById."${attrName}" or null;
          isPropertyDefined = propertyDef != null;
        in
          if isSpecialAttr then { status = "SKIP"; message = "Skipping special attribute '${attrName}'."; }
          else if !isPropertyDefined then { status = "FAIL"; message = "Property '${attrName}' for entity '${entityId}' is not a defined OWL property."; }
          else { status = "PASS"; message = "Property '${attrName}' is a defined OWL property."; }
      ) entity);
    in
    {
      entity = entityId;
      typeCheck = typeCheckResult;
      propertyChecks = propertyCheckResults;
      overallStatus = if isValidType && (lib.length propertyCheckResults == 0) then "PASS" else "FAIL";
    }
  ) foafData.raw."@graph";

  # Overall validation result
  overallValidationStatus = if lib.all (r: r.overallStatus == "PASS") validateEntities
    then "PASS"
    else "FAIL";

in {
  validationResults = validateEntities;
  overallStatus = overallValidationStatus;
}
