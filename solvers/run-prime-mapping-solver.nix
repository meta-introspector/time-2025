{ pkgs, lib, config, ... }:

let
  primeMappingConfig = import ../lib/prime-mapping-config.nix { inherit lib; };
  matrixUtils = import ../lib/matrix-utils.nix { inherit lib; };
  vibeConstants = import ../lib/vibe-constants.nix { inherit lib; };
  vibeMatrixGenerator = import ../lib/vibe-matrix-generator.nix { inherit lib vibeConstants primeMappingConfig; };

  # Generate the MiniZinc model (.mzn) content
  mznModelContent = import ./generate-mzn-model.nix {
    inherit lib config;
    inherit primeMappingConfig;
  };

  # Placeholder vibe data (will be replaced by LLM-generated data)
  # These should align with the dimensions and concepts defined in prime-mapping-config.nix
  primeVibes = vibeMatrixGenerator.generatePrimeVibes;

  conceptVibes = vibeMatrixGenerator.generateConceptVibes;

  vibeWeights = matrixUtils.floatsToStrings (matrixUtils.generateUniformVector (lib.length primeMappingConfig.vibeDimensions) vibeConstants.VS_ONE); # Equal weight for all vibes

  # Generate the MiniZinc data (.dzn) content
  dznDataContent = import ./generate-dzn-data.nix {
    inherit lib config primeVibes conceptVibes vibeWeights;
    inherit primeMappingConfig;
  };

  # Run MiniZinc solver
  solverResult = pkgs.runCommand "prime-mapping-result"
    {
      buildInputs = [ pkgs.minizinc ];
    } ''
    echo "${mznModelContent}" > model.mzn
    echo "${dznDataContent}" > data.dzn
    ${pkgs.minizinc}/bin/minizinc \
      --solver Gecode \
      --output-time \
      --output-objective \
      --output-mode json \
      model.mzn data.dzn > $out
  '';

in
{
  inherit solverResult;
}
