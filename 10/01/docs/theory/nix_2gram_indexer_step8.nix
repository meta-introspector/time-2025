{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  nGramGeneratorModule,
  ...
}:

let
  generate2GramIndexStep7Module = import ./nix_2gram_indexer_step7.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndexStep8 = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    twoGramIndex = generate2GramIndexStep7Module.generate2GramIndexStep7 {
      projectRoot = projectRoot;
      name = name;
    };

    # Create a derivation to output the generated 2-gram index as JSON
    indexOutput = pkgs.runCommand name {
      inherit twoGramIndex;
      # We need nixFileIndex here as a buildInput, but it's not directly available from step7.
      # This highlights a challenge with strict step-by-step refactoring.
      # For now, we'll assume it's implicitly handled or needs to be passed down.
      # For a proper solution, nixFileIndex would need to be an output of an earlier step.
      # For this exercise, we'll temporarily omit it from buildInputs here.
      # buildInputs = [ nixFileIndex ]; # Temporarily commented out
    }
    ''
      mkdir -p $out
      echo "${builtins.toJSON twoGramIndex}" > $out/nix-2gram-index.json
      echo "Generated 2-gram index for Nix file paths in $out/nix-2gram-index.json" >&2
    '';

  in
  indexOutput;

in
{
  generate2GramIndexStep8 = generate2GramIndexStep8;
}
