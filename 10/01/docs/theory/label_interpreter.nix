{
  # Import the unmath.owl.nix schema
  unmathOwl = import ./unmath.owl.nix;

  # A simple label interpreter function
  # This function takes the OWL schema and returns a structured representation
  # that can be used to map labels onto new classes or entities.
  interpretLabels =
    { owlSchema ? unmathOwl.ontology
    ,
    }:
    let
      # Extract classes, properties, and axioms for easier access
      inherit (owlSchema) classes;
      inherit (owlSchema) objectProperties;
      inherit (owlSchema) dataProperties;
      inherit (owlSchema) axioms;

      # Function to get a list of class names
      getClassNames = builtins.attrNames classes;

      # Function to get a list of object property names
      getObjectPropertyNames = builtins.attrNames objectProperties;

      # Function to get a list of data property names
      getDataPropertyNames = builtins.attrNames dataProperties;

      # A conceptual function to apply axioms (this would be a full OWL reasoner in a real scenario)
      # For now, it just returns the axioms themselves.
      applyAxioms = dataToLabel: {
        # In a real implementation, this would apply the logical rules from axioms
        # to infer new labels or properties for `dataToLabel`.
        # For example, if dataToLabel has hasDegree >= 5, it would infer TuringComplete.
        # This is a placeholder for complex reasoning logic.
        axiomsApplied = axioms;
        inputData = dataToLabel;
      };

    in
    {
      # Exported functions and data from the interpreter
      allClassNames = getClassNames;
      allObjectPropertyNames = getObjectPropertyNames;
      allDataPropertyNames = getDataPropertyNames;
      applyAxiomsToData = applyAxioms;
      rawOwlSchema = owlSchema;
    };
}
