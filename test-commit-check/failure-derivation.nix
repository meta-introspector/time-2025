{ pkgs, commitMsg, regex }:

pkgs.runCommand "commit-msg-check-failed" {} ''
  ${pkgs.writeText "run-error-script" ''
    #!${pkgs.bash}/bin/bash
    ${./scripts/commit-msg-error.sh} "${commitMsg}" "${regex}"
  ''}
'';
