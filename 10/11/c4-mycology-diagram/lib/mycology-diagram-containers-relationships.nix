{ aimyceliumActor, gitActor, nixstoreActor, ipfsActor, solanaActor }: {
  containers = [
    { id = "quasifibers"; name = "Quasifibers (Monster Knots)"; technology = "Nix Derivations"; description = "Verifiable mathematical objects, the individual 'hyphae' of the Mycelium."; }
  ] ++ aimyceliumActor.containers;
  relationships = [
    { from = "monsterKnotSystem"; to = "quasifibers"; description = "Generates and Manages"; }
    { from = "geminiCli"; to = "monsterKnotSystem"; description = "Interacts with"; }
  ] ++ aimyceliumActor.relationships ++ gitActor.relationships ++ nixstoreActor.relationships ++ ipfsActor.relationships ++ solanaActor.relationships;
}