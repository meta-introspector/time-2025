{ pkgs, lib, config, ... }:

let
  oeisConfig = import ../lib/oeis-config.nix { inherit lib; };

  # Generate the MiniZinc model (.mzn) content
  mznModelContent = builtins.readFile ./oeis-generator.mzn;

  # Generate the MiniZinc data (.dzn) content
  dznDataContent = import ./generate-oeis-dzn.nix {
    inherit lib config oeisConfig;
  };

  # Run MiniZinc solver
  solverResult = pkgs.runCommand "oeis-solver-result" {
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
