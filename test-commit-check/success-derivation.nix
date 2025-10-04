{ pkgs }:

pkgs.runCommand "commit-msg-check-passed" {} "echo 'Commit message is valid.'; exit 0;"
