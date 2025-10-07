{
  # Import the OWL schema and the label interpreter
  unmathOwl = import ./unmath.owl.nix;
  labelInterpreter = import ./label_interpreter.nix;

  # Define a mapping from OWL concepts to emojis
  emojiMap = {
    # Classes
    Homotopy = "〰️";
    Equivalence = "⚖️";
    ComputationalProperty = "⚙️";
    TuringComplete = "🧠";
    DecidableInFiniteTime = "✅";
    UndecidableInFiniteTime = "❌";

    # Data Properties
    hasDegree = "➡️🔢"; # has -> number

    # Object Properties
    hasEquivalence = "➡️⚖️"; # has -> equivalence
    hasComputationalProperty = "➡️⚙️"; # has -> computational property

    # Specific values/concepts
    DegreeValue = "🔢";
    GreaterThan4 = "⬆️4️⃣";
  };

  # Define a recursive grammar using emojis
  # This is a simplified representation of how concepts can combine.
  recursiveGrammar = {
    # Rule: A Homotopy can have a Degree
    "${emojiMap.Homotopy} ${emojiMap.hasDegree} ${emojiMap.DegreeValue}" = true;

    # Rule: A Homotopy can have a ComputationalProperty
    "${emojiMap.Homotopy} ${emojiMap.hasComputationalProperty} ${emojiMap.ComputationalProperty}" = true;

    # Rule: If a Homotopy has a DegreeValue > 4, it is TuringComplete
    "${emojiMap.Homotopy} ${emojiMap.hasDegree} ${emojiMap.GreaterThan4} => ${emojiMap.TuringComplete}" = true;

    # Rule: If something is TuringComplete, it is UndecidableInFiniteTime
    "${emojiMap.TuringComplete} => ${emojiMap.UndecidableInFiniteTime}" = true;

    # Rule: A Homotopy can be related by Equivalence
    "${emojiMap.Homotopy} ${emojiMap.hasEquivalence} ${emojiMap.Equivalence}" = true;
  };

  # Represent the grammar as a graph (nodes and edges)
  grammarGraph = {
    nodes = [
      emojiMap.Homotopy
      emojiMap.Equivalence
      emojiMap.ComputationalProperty
      emojiMap.TuringComplete
      emojiMap.DecidableInFiniteTime
      emojiMap.UndecidableInFiniteTime
      emojiMap.DegreeValue
      emojiMap.GreaterThan4
      emojiMap.hasDegree
      emojiMap.hasEquivalence
      emojiMap.hasComputationalProperty
    ];

    edges = [
      # Homotopy hasDegree DegreeValue
      { source = emojiMap.Homotopy; relation = emojiMap.hasDegree; target = emojiMap.DegreeValue; }
      # Homotopy hasComputationalProperty ComputationalProperty
      { source = emojiMap.Homotopy; relation = emojiMap.hasComputationalProperty; target = emojiMap.ComputationalProperty; }
      # Homotopy hasDegree GreaterThan4 implies TuringComplete
      { source = emojiMap.Homotopy; relation = emojiMap.hasDegree; target = emojiMap.GreaterThan4; implies = emojiMap.TuringComplete; }
      # TuringComplete implies UndecidableInFiniteTime
      { source = emojiMap.TuringComplete; relation = "implies"; target = emojiMap.UndecidableInFiniteTime; }
      # Homotopy hasEquivalence Equivalence
      { source = emojiMap.Homotopy; relation = emojiMap.hasEquivalence; target = emojiMap.Equivalence; }
    ];
  };
}
