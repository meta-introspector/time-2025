{ pkgs, lib, concepts ? { }, zos ? { }, nixLib ? { } } @ args:

let
  # Construct the list of ln -s commands for zosPrimes
  zosPrimesLinks = pkgs.lib.concatStringsSep "\n" (pkgs.lib.map
    (prime:
      ''ln -s ${zos.zosPrimes."prime-${builtins.toString prime}"}/primes.txt $out/concepts/zos_primes_${builtins.toString prime}.txt''
    )
    (import ./primes.nix));
in
pkgs.runCommand "ai-context-23"
{
  script = ./scripts/ai-context-builder.sh;
} ''
  $script $out \
    ${concepts.mkNumber 23}/number \
    ${concepts.is-prime-23}/result \
    ${concepts.fact-23-oracle}/fact \
    "${zosPrimesLinks}"
''
# DO NOT ADD ANY ) here
