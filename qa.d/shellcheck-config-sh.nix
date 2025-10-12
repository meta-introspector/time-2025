{ pkgs, qaHelpers, projectInfo }:

let
  check = pkgs.runCommand "shellcheck-config-sh"
    {
      inherit (qaHelpers) shellcheck;
      inherit (projectInfo) projectSrc;
    } ''
    echo "Running shellcheck on scripts/test-commit-checker/config.sh..."
    cp -r $projectSrc/. .
    ${qaHelpers.shellcheck}/bin/shellcheck -x scripts/test-commit-checker/config.sh
    touch $out
  '';
in
check
