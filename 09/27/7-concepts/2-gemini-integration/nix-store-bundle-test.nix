{
  description = "Test that other derivations can access gemini.js from Nix store";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # Reference our local working gemini-cli
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { nixpkgs, gemini-cli, ... }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "nix-store-bundle-test";
        version = "1.0";

        src = pkgs.writeText "dummy" "test";

        buildInputs = [
          pkgs.nodejs_22
          gemini-cli.packages.${system}.default
        ];

        buildPhase = ''
          echo "=== Testing Gemini Bundle Access from Nix Store ==="
          
          mkdir -p $out/logs
          
          # Test that we can access the gemini CLI package
          echo "Gemini CLI package path: ${gemini-cli.packages.${system}.default}"
          
          # Test wrapper script
          echo "Testing wrapper script:"
          ${gemini-cli.packages.${system}.default}/bin/gemini --version | tee $out/logs/wrapper-test.log
          
          # Test direct bundle access
          echo "Testing direct bundle access:"
          node ${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js --version | tee $out/logs/bundle-test.log
          
          # Verify bundle exists in expected location
          echo "Bundle verification:"
          ls -la ${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js | tee $out/logs/bundle-info.log
          
          echo "✅ SUCCESS: Other derivations can access gemini.js from Nix store!"
        '';

        installPhase = ''
          echo "Test results saved to $out/logs/"
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${gemini-cli.packages.${system}.default}/bin/gemini";
      };
    };
}
