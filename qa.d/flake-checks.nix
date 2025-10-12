{ pkgs, projectInfo }:

let
  nix-flake-check = pkgs.runCommand "nix-flake-check"
    {
      inherit (projectInfo) projectSrc;
      nativeBuildInputs = [ pkgs.nix ];
    } ''
    tmpConfDir=$(mktemp -d)
    tmpStateDir=$(mktemp -d)
    tmpCacheDir=$(mktemp -d)
    tmpHomeDir=$(mktemp -d)
    echo "state-dir = $tmpStateDir" > $tmpConfDir/nix.conf
    echo "local-cache-dir = $tmpCacheDir" >> $tmpConfDir/nix.conf
    export NIX_CONF_DIR=$tmpConfDir
    export HOME=$tmpHomeDir

    cp -r $projectSrc/. .
    nix flake check --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --no-update-lock-file --override-input dataSources path:./flakes/data-sources
    rm -rf $tmpConfDir $tmpStateDir $tmpCacheDir $tmpHomeDir
    touch $out
  '';
in
{
  inherit nix-flake-check;
}
