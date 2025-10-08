{
  description = "ZOS Zero Ontology System Spore Vial with Prime Vibes.";

  outputs = { self, ... } @ args:
    let
      primes = [ 0 1 2 3 5 7 11 13 17 19 ];
      primeVibes = "The ZOS Zero Ontology System embodies the prime vibes: ${builtins.toString primes}.";
    in
    {
      lib.getPrompt = { pkgs }: primeVibes;
    };
}
