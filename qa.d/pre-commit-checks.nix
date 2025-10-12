{ pkgs, qaHelpers, projectInfo }:

let
  pre-commit-all-files = pkgs.runCommand "pre-commit-all-files"
    {
      inherit (qaHelpers) pre-commit git;
      inherit (projectInfo) projectSrc;
    } ''
    echo "Running pre-commit hooks on all files..."
    # Copy project source to a temporary directory
    cp -r $projectSrc/. .
    # Initialize a dummy git repository for pre-commit to work
    ${qaHelpers.git}/bin/git init
    ${qaHelpers.git}/bin/git add .
    # Run pre-commit on all files
    ${qaHelpers.pre-commit}/bin/pre-commit run --all-files
    touch $out
  '';
in
{
  inherit pre-commit-all-files;
}
