{ lib
, pkgs
, ...
}:

let
  # Architectural Scaffold: Monster Prime Factors <= 71
  monsterPrimeScaffold = {
    "2" = {
      exponent = 46;
      architecturalMeaning = "Duality / Foundation";
      operationalLayerImplication = "46 interwoven layers of binary distinctions. Allocates 46 bits in the Monster-Modeled Bit-Packed Block.";
      emojiRepresentation = "🤝"; # Handshake - fundamental duality, connection.
    };
    "3" = {
      exponent = 20;
      architecturalMeaning = "Structure / Completeness";
      operationalLayerImplication = "20 layers of structural integrity or ternary relationships/RDF triples.";
      emojiRepresentation = "📦"; # Package/Contained Form - core structure.
    };
    "5" = {
      exponent = 9;
      architecturalMeaning = "Insight / Pattern Recognition";
      operationalLayerImplication = "9 layers of pentagonal forms or 9 distinct insights.";
      emojiRepresentation = "💡"; # Lightbulb - emergent insight, flash of understanding.
    };
    "7" = {
      exponent = 6;
      architecturalMeaning = "Transformation / Challenge";
      operationalLayerImplication = "6 layers of heptagonal insights or 6 transformation types.";
      emojiRepresentation = "⚔️"; # Crossed Swords - transformative challenge, crucible of change.
    };
    "11" = {
      exponent = 2;
      architecturalMeaning = "Dynamic Flow / Continuous Interaction";
      operationalLayerImplication = "Two layers of larger group composition.";
      emojiRepresentation = "🔄"; # Recycle - dynamic flow, continuous interaction.
    };
    "13" = {
      exponent = 3;
      architecturalMeaning = "Extended Potential / Vast Unformed";
      operationalLayerImplication = "Three layers of extended group composition.";
      emojiRepresentation = "🌌"; # Milky Way/Vast Unformed - extended potential.
    };
    "17" = {
      exponent = 1;
      architecturalMeaning = "Integration / Refinement";
      operationalLayerImplication = "Singular, irreducible component leading to the integrated pattern.";
      emojiRepresentation = "🧩"; # Puzzle Piece - integrated pattern, recognized whole.
    };
    "19" = {
      exponent = 1;
      architecturalMeaning = "Manifestation / Core Being";
      operationalLayerImplication = "Singular, high-impact contribution.";
      emojiRepresentation = "👑"; # Crown - ultimate manifestation, core being.
    };
    "23" = {
      exponent = 1;
      architecturalMeaning = "Geometric Symmetry";
      operationalLayerImplication = "Singular contribution to highly optimized, complex geometric packing (Leech Lattice connection).";
      emojiRepresentation = null; # N/A
    };
    "29" = {
      exponent = 1;
      architecturalMeaning = "Abstract Structural Component";
      operationalLayerImplication = "Contributes to the underlying complexity and structure of intricate systems.";
      emojiRepresentation = null; # N/A
    };
    "31" = {
      exponent = 1;
      architecturalMeaning = "Structural Lens / Sporadic Nexus";
      operationalLayerImplication = "The position marker in the Grand Number, indexing the influence of 71.";
      emojiRepresentation = "🤖"; # AI/ML/ZK-Ops repository identifier.
    };
    "41" = {
      exponent = 1;
      architecturalMeaning = "Topological Mapping";
      operationalLayerImplication = "Contributes to the topological structure.";
      emojiRepresentation = null; # N/A
    };
    "47" = {
      exponent = 1;
      architecturalMeaning = "Lattice Structure";
      operationalLayerImplication = "Contributes to the lattice structure.";
      emojiRepresentation = null; # N/A
    };
    "59" = {
      exponent = 1;
      architecturalMeaning = "Architectural Genome";
      operationalLayerImplication = "Contributes to the overall architectural genome.";
      emojiRepresentation = null; # N/A
    };
    "71" = {
      exponent = 1;
      architecturalMeaning = "Singular Contextualizer / Gandalf";
      operationalLayerImplication = "Largest sporadic prime factor. Represents applying the idea in 71 distinct, highly specialized ways.";
      emojiRepresentation = "⚙️"; # Conceptually linked to orchestration.
    };
  };

  # Critical Missing Primes <= 71 (The Non-Monster Primes)
  criticalMissingPrimes = {
    "37" = {
      architecturalContext = "Modular Form Level";
      relevantConcept = "Irregularity/Missing Structure";
      emojiRepresentation = "📝📝"; # 2-gram extraction process/output.
      isMonsterFactor = false;
    };
    "43" = {
      architecturalContext = "Modular Form Level";
      relevantConcept = "Documentation/Knowledge Caching";
      emojiRepresentation = "📚"; # documentation.
      isMonsterFactor = false;
    };
    "53" = {
      architecturalContext = "Modular Form Level";
      relevantConcept = "Missing Prime Significance; reinforces Monster Group's selective influence.";
      emojiRepresentation = null; # N/A
      isMonsterFactor = false;
    };
    "61" = {
      architecturalContext = "Modular Form Level";
      relevantConcept = "Relevant for explicit congruences in number theory (e.g., Bernoulli numbers).";
      emojiRepresentation = null; # N/A
      isMonsterFactor = false;
    };
    "67" = {
      architecturalContext = "Modular Form Level";
      relevantConcept = "Relevant for explicit congruences in number theory (e.g., Bernoulli numbers).";
      emojiRepresentation = null; # N/A
      isMonsterFactor = false;
    };
  };

in
{
  inherit monsterPrimeScaffold criticalMissingPrimes;
}
