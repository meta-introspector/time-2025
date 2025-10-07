{ lib, config, ... }:

let
  cfg = config.primeMappingConfig;
  num_primes = lib.length cfg.vibeDimensions;
  num_concepts = lib.length cfg.concepts;

  vibe_dimensions_set = lib.concatStringsSep ", " (lib.genList (i: "v" + toString i) num_primes);

in
''
int: num_primes;
int: num_concepts;

set of int: PRIMES = 1..num_primes;
set of int: CONCEPTS = 1..num_concepts;
set of int: VIBE_DIMENSIONS = 1..${toString num_primes};

% Decision variable: mapping[c] = p means concept c is mapped to prime p
array[CONCEPTS] of var PRIMES: mapping;

% Each concept must be mapped to exactly one prime (implicit by array definition)

% Each prime must be mapped to at most one concept
constraint all_different(mapping);

% Input Data
array[PRIMES, VIBE_DIMENSIONS] of float: prime_vibes;
array[CONCEPTS, VIBE_DIMENSIONS] of float: concept_vibes;
array[VIBE_DIMENSIONS] of float: vibe_weights;

% Objective Function: Maximize alignment between concept and prime vibes
solve maximize sum(c in CONCEPTS) (
  sum(d in VIBE_DIMENSIONS) (
    vibe_weights[d] * (prime_vibes[mapping[c], d] * concept_vibes[c, d])
  )
);

output ["mapping = ", show(mapping)];
''
