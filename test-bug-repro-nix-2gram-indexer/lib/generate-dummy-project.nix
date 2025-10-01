{ pkgs, lib, builtins }:

let
  generateDummyProjectScript = pkgs.writeScript "generate-dummy-project.sh" (builtins.readFile ../generate_dummy_project.sh);
in

pkgs.runCommand "dummy-project-root" {
  buildInputs = [ pkgs.bash ];
} "echo \"Executing script: $generateDummyProjectScript\" && $generateDummyProjectScript $out"
