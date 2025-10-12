{ pkgs, lib, prompt, gemini-cli, system }:

let
  builderScript = pkgs.writeShellScript "gemini-prompt-builder" ''
    ${pkgs.bash}/bin/bash ${./gemini-prompt-builder.sh} "$out" "${prompt}" "${gemini-cli}"
  '';
in

pkgs.runCommand "gemini-prompt-output"
{
  buildInputs = [ gemini-cli ]; # Add gemini-cli to buildInputs
} ''
  ${builderScript}
''
