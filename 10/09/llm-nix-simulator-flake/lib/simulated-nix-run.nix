{ pkgs, analyzedNixExpression, promptFileDerivation, llmApiWrapper }:

pkgs.runCommand "simulated-nix-run"
{
  buildInputs = [ pkgs.bash pkgs.jq ];
  src = ./.; # Include the simulate.sh script
  inherit analyzedNixExpression promptFileDerivation;
  LLM_API_WRAPPER_BIN = "${llmApiWrapper.packages.aarch64-linux.default}/bin/call-llm-api";
  __impure = true;
} ''
  mkdir -p $out
  chmod +x $src/simulate.sh
  "$src/simulate.sh" "${promptFileDerivation}" "$out"
''
