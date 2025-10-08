#!/bin/bash
# shellcheck disable=SC2154
      echo "Generating OWL ontology from Nix code index..." >&2
      mkdir -p "$out"
      ONTOLOGY_FILE="$out"/nix-ontology.ttl

      # Start OWL Turtle output
      {
        echo "@prefix : <${NIX_ONTOLOGY_PREFIX}> ."
        echo "@prefix owl: <${OWL_PREFIX_URL_STRING}> ."
        echo "@prefix rdf: <${RDF_PREFIX_URL_STRING}> ."
        echo "@prefix rdfs: <${RDFS_PREFIX_URL_STRING}> ."
        echo "@prefix xsd: <${XSD_PREFIX_URL_STRING}> ."
        echo ""
        echo "<${NIX_ONTOLOGY_PREFIX}> rdf:type owl:Ontology ;"
        echo "  rdfs:comment \"Automatically generated OWL ontology from Nix code.\" ."
        echo ""
      } > "$ONTOLOGY_FILE"

      # Define core classes for Nix concepts
      {
        echo ":NixFile rdf:type owl:Class ; rdfs:comment \"Represents a .nix file.\" ."
        echo ":NixExpression rdf:type owl:Class ; rdfs:comment \"Represents a Nix expression.\" ."
        echo ":NixFlake rdf:type owl:Class ; rdfs:comment \"Represents a Nix flake.\" ."
        echo ":NixInput rdf:type owl:Class ; rdfs:comment \"Represents a flake input.\" ."
        echo ":NixOutput rdf:type owl:Class ; rdfs:comment \"Represents a flake output.\" ."
        echo ":NixPackage rdf:type owl:Class ; rdfs:comment \"Represents a Nix package.\" ."
        echo ":NixFunction rdf:type owl:Class ; rdfs:comment \"Represents a Nix function.\" ."
        echo ":NixAttributeSet rdf:type owl:Class ; rdfs:comment \"Represents a Nix attribute set.\" ."
        echo ":NixList rdf:type owl:Class ; rdfs:comment \"Represents a Nix list.\" ."
        echo ":NixString rdf:type owl:Class ; rdfs:comment \"Represents a Nix string.\" ."
        echo ":NixInteger rdf:type owl:Class ; rdfs:comment \"Represents a Nix integer.\" ."
        echo ":NixBoolean rdf:type owl:Class ; rdfs:comment \"Represents a Nix boolean.\" ."
        echo ""
      } >> "$ONTOLOGY_FILE"

      # Define properties
      {
        echo ":hasPath rdf:type owl:DatatypeProperty ; rdfs:domain :NixFile ; rdfs:range xsd:string ."
        echo ":hasHash rdf:type owl:DatatypeProperty ; rdfs:domain :NixFile ; rdfs:range xsd:string ."
        echo ":hasInput rdf:type owl:ObjectProperty ; rdfs:domain :NixFlake ; rdfs:range :NixInput ."
        echo ":hasOutput rdf:type owl:ObjectProperty ; rdfs:domain :NixFlake ; rdfs:range :NixOutput ."
        echo ":definesPackage rdf:type owl:ObjectProperty ; rdfs:domain :NixOutput ; rdfs:range :NixPackage ."
        echo ":definesFunction rdf:type owl:ObjectProperty ; rdfs:domain :NixOutput ; rdfs:range :NixFunction ."
        echo ":hasType rdf:type owl:DatatypeProperty ; rdfs:domain :NixExpression ; rdfs:range xsd:string ."
        echo ""
      } >> "$ONTOLOGY_FILE"

      # Iterate over indexedNixCode and generate individuals
      # This part would require parsing the actual Nix code to extract more semantic information.
      # For now, we'll just create individuals for each Nix file.
      echo "Processing indexed Nix files..." >&2
      jq -c "${JQ_FILTER}" < "${NIX_FILE_INDEX}"/nix-files.index.json | while IFS= read -r i;
      do
        FILE_PATH=$(echo "$i" | jq -r "${JQ_PATH_FILTER}")
        # Create a valid OWL individual ID from the file path
        FILE_ID=${FILE_PATH//[^a-zA-Z0-9_]/_}
        echo ":${FILE_ID} rdf:type :NixFile ;" >> "$ONTOLOGY_FILE"
      done
