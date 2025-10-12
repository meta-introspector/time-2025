# qa.d/nix-dump-evaluator.nix
{ pkgs, lib, allNixFiles, projectRoot, ... }:

pkgs.runCommand "nix-dump-evaluator"
{
  inherit allNixFiles projectRoot;
  buildInputs = [ pkgs.nix ]; # Ensure nix is available for nix eval
} ''
  echo "--- Running nix eval --dump on all Nix files ---"
  for nixFile in $allNixFiles; do
    echo "Processing $nixFile..."
    nix eval --dump --file "$projectRoot/$nixFile" > "$out/$(basename $nixFile).dump"
  done
  echo "--- Finished nix eval --dump on all Nix files ---"
''
