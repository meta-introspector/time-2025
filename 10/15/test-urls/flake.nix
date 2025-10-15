{
  description = "A test flake demonstrating dynamic URL calculation and fetching/importing a Nix file";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    githubWrapperLib = {
      url = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/lib/github-wrapper.nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, githubWrapperLib }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      # Import the githubWrapper function from githubWrapperLib
      githubWrapper = (import githubWrapperLib { inherit lib; }).githubWrapper;

      # Define the parameters for githubWrapper
      targetOwner = "meta-introspector";
      targetRepo = "time-2025";
      targetRef = "feature/aimyc-003-cultivation"; # Updated branch
      targetDir = "."; # Point to the root of the repository

      # Calculate the URL string using githubWrapper (for informational purposes)
      calculatedUrl = githubWrapper {
        owner = targetOwner;
        repo = targetRepo;
        ref = targetRef;
        dir = targetDir;
      };

      # Fetch the entire content from the target repository
      fetchedRepo = pkgs.fetchFromGitHub {
        owner = targetOwner;
        repo = targetRepo;
        rev = targetRef;
        sha256 = "11vc3sq67gm7i3m7fdvf7kkbxkyr9p6dsi0ir2g28fgm5dggj605"; # Obtained from nix-prefetch-url
      };

      # Attempt to import the default.nix from the fetched repository
      importedModule = import "${fetchedRepo}/default.nix";

    in
    {
      packages.${system}.default = pkgs.writeText "calculated-url-output" calculatedUrl;

      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScript "print-calculated-url" ''
          echo "Calculated URL: ${calculatedUrl}"
          echo "Fetched repository path: ${fetchedRepo}"
          echo "Imported module type: $(nix eval --raw --impure --expr 'builtins.typeOf (import ${fetchedRepo}/${targetDir}/flake.nix)')"
        ''}";
      };
    };
}
