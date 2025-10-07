{
  description = "Test working Gemini CLI from GitHub with bundle in Nix store";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # Use our working branch with bundle properly packaged
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { nixpkgs, gemini-cli, ... }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.writeShellScriptBin "test-github-gemini" ''
        echo "=== Testing GitHub Gemini CLI with Nix Store Bundle ==="
        echo "Branch: feature/test (with working bundle packaging)"
        echo "Gemini CLI Path: ${gemini-cli.packages.${system}.default}/bin/gemini"
        echo ""
        
        echo "Testing version:"
        ${gemini-cli.packages.${system}.default}/bin/gemini --version
        
        echo ""
        echo "Testing help:"
        ${gemini-cli.packages.${system}.default}/bin/gemini --help | head -10
        
        echo ""
        echo "Bundle verification:"
        ls -la ${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js
        
        echo ""
        echo "✓ GitHub Gemini CLI test complete!"
      '';

      apps.${system} = {
        default = {
          type = "app";
          program = "${gemini-cli.packages.${system}.default}/bin/gemini";
        };

        test = {
          type = "app";
          program = "${pkgs.writeShellScript "test-runner" ''
            ${gemini-cli.packages.${system}.default}/bin/gemini "Hello from GitHub Nix store bundle!"
          ''}";
        };
      };
    };
}
