{
  description = "Nix flake for integrating GitHub code search functionality.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Function to perform GitHub code search
        # This function is impure as it makes network requests
        githubCodeSearch = { query, org ? "meta-introspector", name ? "github-code-search-result" }:
          pkgs.runCommand name
            {
              nativeBuildInputs = [ pkgs.gh ]; # GitHub CLI
              inherit query org;
              __impure = true; # Network access is impure
            } ''
            echo "Performing GitHub code search for query: \"$query\" in organization: \"$org\"..."
            gh search code "$query" --org "$org" > $out
            echo "GitHub search completed. Results in $out"
          '';

      in
      {
        lib = { inherit githubCodeSearch; };

        checks = {
          # Conceptual check for GitHub code search
          testGithubCodeSearch = pkgs.runCommand "test-github-code-search"
            {
              nativeBuildInputs = [ pkgs.bash pkgs.gh ];
              # This check is conceptual and will only verify that the 'gh' command can be run.
              # A real test would require GitHub authentication and network access.
            } ''
            echo "Testing GitHub CLI availability and basic command execution..."
            if command -v gh &> /dev/null; then
              echo "GitHub CLI (gh) is available."
              # Attempt a dry run or a simple command that doesn't require auth
              gh --version
              echo "Basic gh command executed successfully."
            else
              echo "Error: GitHub CLI (gh) not found." >&2
              exit 1
            fi
          '';
        };
      }
    );
}
