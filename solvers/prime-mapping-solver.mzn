int: num_primes;
int: num_concepts;

set of int: PRIMES = 1..num_primes;
set of int: CONCEPTS = 1..num_concepts;

% Decision variable: mapping[c] = p means concept c is mapped to prime p
array[CONCEPTS] of var PRIMES: mapping;

% Each concept must be mapped to exactly one prime (implicit by array definition)

% Each prime must be mapped to at most one concept
constraint all_different(mapping);

% --- Input Data (to be provided in a .dzn file) ---
% array[PRIMES, VIBE_DIMENSIONS] of float: prime_vibes;
% array[CONCEPTS, VIBE_DIMENSIONS] of float: concept_vibes;
% array[VIBE_DIMENSIONS] of float: vibe_weights; % How important each vibe dimension is

% --- Objective Function (to be refined later) ---
% solve maximize sum(c in CONCEPTS) (
%   sum(d in VIBE_DIMENSIONS) (
%     vibe_weights[d] * (prime_vibes[mapping[c], d] * concept_vibes[c, d])
%   )
% );

solve satisfy;
