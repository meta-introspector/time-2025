{ pkgs, commitMsg, regex }:

let
  runErrorScript = pkgs.writeText "run-error-script" ''
    #!${pkgs.bash}/bin/bash
    ${./scripts/commit-msg-error.sh} "${commitMsg}" "${regex}"
  '';
in

pkgs.runCommand "commit-msg-check-failed" {} ''
  ${runErrorScript}
'';
