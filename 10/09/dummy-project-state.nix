{ pkgs ? import <nixpkgs> { system = "aarch64-linux"; } }:

pkgs.runCommand "dummy-project-state" { } ''
  mkdir -p $out
  echo "# Project Summary" > $out/project-summary.md
  echo "" >> $out/project-summary.md
  echo "This is a dummy project summary for testing the project scheduler flake." >> $out/project-summary.md
  echo "" >> $out/project-summary.md
  echo "Current tasks include: developing NAR bridge, analyzing existing Nix files, and creating LLM-driven task generation." >> $out/project-summary.md
''
