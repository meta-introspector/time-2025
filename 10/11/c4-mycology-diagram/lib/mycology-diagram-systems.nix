{ gitActor, nixstoreActor, ipfsActor, solanaActor }:
[
  { id = "monsterKnotSystem"; name = "Nix-based Monster Knot System"; description = "The core system for Gödelian Arithmetization and meta-introspection."; }
] ++ gitActor.systems ++ nixstoreActor.systems ++ ipfsActor.systems ++ solanaActor.systems