{ lib, config, primeVibes, conceptVibes, vibeWeights, ... }:

let
  cfg = config.primeMappingConfig;
  num_primes = lib.length cfg.vibeDimensions;
  num_concepts = lib.length cfg.concepts;
  num_vibe_dimensions = lib.length cfg.vibeDimensions;

  formatMatrix = matrix: lib.concatStringsSep ", " (
    lib.map
      (
        row: "[ " + (lib.concatStringsSep ", " (lib.map toString row)) + " ]"
      )
      matrix
  );

in
''
  num_primes = ${toString num_primes};
  num_concepts = ${toString num_concepts};
  num_vibe_dimensions = ${toString num_vibe_dimensions};
''
