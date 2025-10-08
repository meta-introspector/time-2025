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
    buildInputs = [ pkgs.minizinc pkgs.jq ];
  } ''
    echo "${mznModelContent}" > model.mzn
    echo "${dznDataContent}" > data.dzn
    result=$(${pkgs.minizinc}/bin/minizinc \
      --solver Gecode \
      --output-time \
      --output-objective \
      --output-mode json \
      model.mzn data.dzn)
    # TODO: Make the JSON parsing more robust.
    # The current implementation assumes a simple array and takes the last element.
    # This might not be sufficient for more complex outputs.
    # Extract the last OEIS number from the JSON output
    # For now, assume the output is a simple array and take the last element
    echo $(echo "$result" | ${pkgs.jq}/bin/jq '.F[-1]') > $out
  '';

in
{
  inherit solverResult;
}
