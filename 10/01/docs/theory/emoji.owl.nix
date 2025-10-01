{
  # Define the OWL ontology using Nix attribute sets
  ontology = {
    id = "http://example.org/emoji-ontology";
    versionIRI = "http://example.org/emoji-ontology/1.0";
    comment = "An OWL schema mapping concepts to their emoji representations.";

    # Classes
    classes = {
      Concept = {
        comment = "A general concept to be represented by an emoji.";
      };
      StructuralElement = {
        comment = "A structural element in Nix syntax.";
        subClassOf = [ "Concept" ];
      };
      Keyword = {
        comment = "A Nix keyword.";
        subClassOf = [ "Concept" ];
      };
      BooleanValue = {
        comment = "A boolean value.";
        subClassOf = [ "Concept" ];
      };
      NullValue = {
        comment = "The null value.";
        subClassOf = [ "Concept" ];
      };
      NumberValue = {
        comment = "A numerical value.";
        subClassOf = [ "Concept" ];
      };
      StringValue = {
        comment = "A string value.";
        subClassOf = [ "Concept" ];
      };
      FunctionConcept = {
        comment = "A function concept.";
        subClassOf = [ "Concept" ];
      };
    };

    # Data Properties
    dataProperties = {
      hasEmojiRepresentation = {
        comment = "The emoji string representing a concept.";
        domain = "Concept";
        range = "xsd:string";
      };
      hasNixKeyword = {
        comment = "The Nix keyword represented by a concept.";
        domain = "Keyword";
        range = "xsd:string";
      };
    };

    # Individuals (mapping concepts to emojis)
    individuals = {
      # From unmath.owl.nix concepts
      HomotopyConcept = {
        type = "Concept";
        hasEmojiRepresentation = "〰️";
      };
      EquivalenceConcept = {
        type = "Concept";
        hasEmojiRepresentation = "⚖️";
      };
      ComputationalPropertyConcept = {
        type = "Concept";
        hasEmojiRepresentation = "⚙️";
      };
      TuringCompleteConcept = {
        type = "Concept";
        hasEmojiRepresentation = "🧠";
      };
      DecidableInFiniteTimeConcept = {
        type = "Concept";
        hasEmojiRepresentation = "✅";
      };
      UndecidableInFiniteTimeConcept = {
        type = "Concept";
        hasEmojiRepresentation = "❌";
      };

      # Structural elements for Nix
      AttrSetOpen = {
        type = "StructuralElement";
        hasEmojiRepresentation = "🗄️";
      };
      AttrSetClose = {
        type = "StructuralElement";
        hasEmojiRepresentation = "🗄️🔚";
      };
      ListOpen = {
        type = "StructuralElement";
        hasEmojiRepresentation = "📜";
      };
      ListClose = {
        type = "StructuralElement";
        hasEmojiRepresentation = "📜🔚";
      };
      Assign = {
        type = "StructuralElement";
        hasEmojiRepresentation = "➡️";
      };
      StatementEnd = {
        type = "StructuralElement";
        hasEmojiRepresentation = "🛑";
      };
      FunctionArg = {
        type = "StructuralElement";
        hasEmojiRepresentation = "👉";
      };
      StringQuote = {
        type = "StructuralElement";
        hasEmojiRepresentation = "💬";
      };
      NumberBlock = {
        type = "StructuralElement";
        hasEmojiRepresentation = "🔢";
      };

      # Keywords/Booleans
      TrueValue = {
        type = "BooleanValue";
        hasEmojiRepresentation = "✅";
        hasNixKeyword = "true";
      };
      FalseValue = {
        type = "BooleanValue";
        hasEmojiRepresentation = "❌";
        hasNixKeyword = "false";
      };
      NullValue = {
        type = "NullValue";
        hasEmojiRepresentation = "👻";
        hasNixKeyword = "null";
      };
      InheritKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "🧬";
        hasNixKeyword = "inherit";
      };
      WithKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "🌳";
        hasNixKeyword = "with";
      };
      LetKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "💡";
        hasNixKeyword = "let";
      };
      InKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "↩️";
        hasNixKeyword = "in";
      };
      IfKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "❓";
        hasNixKeyword = "if";
      };
      ThenKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "✔️";
        hasNixKeyword = "then";
      };
      ElseKeyword = {
        type = "Keyword";
        hasEmojiRepresentation = "✖️";
        hasNixKeyword = "else";
      };
      FunctionConceptEmoji = {
        type = "FunctionConcept";
        hasEmojiRepresentation = "λ"; # Lambda for function
      };
    };
  };
}
