{
  # Define the OWL ontology using Nix attribute sets
  ontology = {
    id = "http://example.org/unmath-ontology";
    versionIRI = "http://example.org/unmath-ontology/1.0";
    comment = "An OWL schema exploring the computational properties of homotopies, particularly asserting the undecidability of higher-degree homotopies.";

    # Classes
    classes = {
      Homotopy = {
        comment = "Represents a homotopy, a continuous deformation between two functions.";
      };
      Equivalence = {
        comment = "Represents a mathematical equivalence relation.";
      };
      ComputationalProperty = {
        comment = "A general class for computational characteristics.";
      };
      TuringComplete = {
        comment = "Represents the property of being Turing complete.";
        subClassOf = [ "ComputationalProperty" ];
      };
      DecidableInFiniteTime = {
        comment = "Represents the property of being decidable in finite time.";
        subClassOf = [ "ComputationalProperty" ];
      };
      UndecidableInFiniteTime = {
        comment = "Represents the property of being undecidable in finite time.";
        subClassOf = [ "ComputationalProperty" ];
        disjointWith = [ "DecidableInFiniteTime" ];
      };
    };

    # Object Properties
    objectProperties = {
      hasEquivalence = {
        comment = "Relates a homotopy to an equivalence relation it participates in.";
        domain = "Homotopy";
        range = "Equivalence";
      };
      hasComputationalProperty = {
        comment = "Relates a homotopy to its computational properties.";
        domain = "Homotopy";
        range = "ComputationalProperty";
      };
    };

    # Data Properties
    dataProperties = {
      hasDegree = {
        comment = "The degree of a homotopy.";
        domain = "Homotopy";
        range = "xsd:integer";
      };
    };

    # Axioms / Assertions
    axioms = [

      # Assertion: If a Homotopy has a degree >= 5, then it hasComputationalProperty TuringComplete
      # This is a more direct representation of the implication.
      {
        type = "SubClassOf";
        subClass = {
          type = "Restriction";
          onProperty = 'hasDegree';
          someValuesFrom = {
            type = "Datatype";
            onDatatype = "xsd:integer";
            withRestrictions = [
              { "xsd:minInclusive" = 5; }
            ];
          };
        };
        superClass = {
          type = "Restriction";
          onProperty = 'hasComputationalProperty';
          someValuesFrom = "TuringComplete";
        };
      };

      # Assertion: If a Homotopy is Turing complete, then it is undecidable in finite time.
      {
        type = "SubClassOf";
        subClass = {
          type = "Restriction";
          onProperty = "hasComputationalProperty";
          someValuesFrom = "TuringComplete";
        };
        superClass = {
          type = "Restriction";
          onProperty = "hasComputationalProperty";
          someValuesFrom = "UndecidableInFiniteTime";
        };
      };
    ];
  };
}
