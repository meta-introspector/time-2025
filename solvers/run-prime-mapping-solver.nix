{ pkgs, lib, config, ... }:

let
  primeMappingConfig = import ../lib/prime-mapping-config.nix { inherit lib; };
  matrixUtils = import ../lib/matrix-utils.nix { inherit lib; };

  # Generate the MiniZinc model (.mzn) content
  mznModelContent = import ./generate-mzn-model.nix {
    inherit lib config;
    inherit primeMappingConfig;
  };

  # Placeholder vibe data (will be replaced by LLM-generated data)
  # These should align with the dimensions and concepts defined in prime-mapping-config.nix
  primeVibes = matrixUtils.generateIdentityMatrix (lib.length primeMappingConfig.vibeDimensions);

  conceptVibes = matrixUtils.generateIdentityMatrix (lib.length primeMappingConfig.concepts);

  vibeWeights = matrixUtils.floatsToStrings (matrixUtils.generateUniformVector (lib.length primeMappingConfig.vibeDimensions) 1.0); # Equal weight for all vibes

  # Generate the MiniZinc data (.dzn) content
  dznDataContent = import ./generate-dzn-data.nix {
    inherit lib config primeVibes conceptVibes vibeWeights;
    inherit primeMappingConfig;
  };

  # Run MiniZinc solver
  solverResult = pkgs.runCommand "prime-mapping-result" {
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