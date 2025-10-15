# 10/15/zos/source-config/flake.nix
{
  description = "Provides source URLs (commit hashes) for OODA loop iterations.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

      in
      {
        # This output provides a function to get the source for a given loop.
        # It takes the initial commit hash as an argument.
        lib.getLoopSourceConfig = initialCommit: {
          # This function will be called by the OODA loop flake.
          # It takes the loop number and returns the commit hash for that loop.
          getCommitForLoop = loopNum:
            # For now, always return the initialCommit.
            # This can be extended later to provide different commits per loop.
            initialCommit;
        };

        # A simple check to ensure the flake is working
        checks.default = pkgs.runCommand "source-config-check" { } ''
          echo "Source config flake is functional." > $out
        '';
      });
}
