# qa.d/nix-dump-evaluator.nix
{ pkgs, lib, allNixFiles, projectRoot, ... }:

pkgs.runCommand "nix-dump-evaluator"
{
  inherit allNixFiles projectRoot;
  buildInputs = [ pkgs.nix ]; # Ensure nix is available for nix eval
} ''
  echo "--- Running nix eval --json on all Nix files ---"
  for nixFile in $allNixFiles; do
    echo "Processing $nixFile..."
    nix eval --json --file "$projectRoot/$nixFile" > "$out/share/nix-dumps/${packageName}.json"
  done
  echo "--- Finished nix eval --json on all Nix files ---"
''
