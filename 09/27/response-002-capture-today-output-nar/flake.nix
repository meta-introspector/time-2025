{
  description = "Gemini's response: Flake to run 'streamofrandom_cli today' and capture its output in a NAR file.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Or appropriate version
    # Input for the streamofrandom_cli project, which is in the parent directory
    streamofrandomCli = {
      url = "path:../"; # Refers to the parent directory where the workspace is
      flake = false; # Treat as a non-flake input
    };
  };

  outputs = { self, nixpkgs, streamofrandomCli, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux; # Or appropriate system
      # Build the streamofrandom_cli
      cliPackage = pkgs.callPackage
        ({ rustPlatform, lib, openssl }:
          rustPlatform.buildRustPackage {
            pname = "streamofrandom_cli";
            version = "0.1.0"; # Match the version in Cargo.toml
            src = streamofrandomCli; # Use the parent directory as source
            cargoLock = "${streamofrandomCli}/Cargo.lock"; # Assuming Cargo.lock is at the workspace root
            # Add other build inputs if necessary, e.g., for chrono
            buildInputs = [ openssl ]; # Example for openssl if needed by chrono
            # Ensure the workspace is correctly handled by buildRustPackage
            # This might require setting a CARGO_MANIFEST_DIR or similar if the workspace is complex
            # For now, assuming buildRustPackage can find the correct Cargo.toml within streamofrandomCli
            # If it fails, we might need to specify cargoRoot or similar.
            cargoRoot = streamofrandomCli;
            sourceRoot = "streamofrandom_cli"; # The subdirectory containing the actual package
          }
        )
        { };

      # Derivation to run 'today' and capture output into a NAR
      capturedTodayOutputNar = pkgs.runCommand "captured-today-output-nar"
        {
          buildInputs = [ pkgs.coreutils pkgs.nix ]; # For 'date' and 'mkdir' in the shell script, and nix for nix-store
          cli = cliPackage;
        } ''
        # Create a temporary directory for the output
        mkdir -p $TMPDIR/output
        
        # Run the 'today' command and capture its stdout
        # We need to ensure HOME is set correctly for the Rust program
        export HOME=$(mktemp -d) # Create a temporary HOME for isolation
        
        # Execute the command and capture stdout
        # The 'today' command also changes directory and creates symlinks,
        # so we need to run it in a way that its side effects are contained
        # or we explicitly capture the output it prints to stdout.
        # The Rust program prints the final path to stdout.
        TODAY_OUTPUT=$($cli/bin/streamofrandom_cli today)
        echo "$TODAY_OUTPUT" > $TMPDIR/output/today_output.txt

        # Create a NAR from the temporary output directory
        nix-store --dump $TMPDIR/output > $out
      '';
    in
    {
      # The NAR file as an output
      narFile = capturedTodayOutputNar;

      # A default package that just prints instructions on how to use the NAR
      defaultPackage = pkgs.runCommand "print-nar-instructions" { } ''
        mkdir -p $out/bin
        echo "To access the captured NAR file, run: nix build .#narFile" > $out/bin/print-nar-instructions
        echo "The NAR file will be in result/." >> $out/bin/print-nar-instructions
        chmod +x $out/bin/print-nar-instructions
      '';

      devShell = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bash pkgs.nix ];
        shellHook = ''
          echo "Welcome to the devShell for response-002-capture-today-output-nar."
          echo "Run 'nix build .#narFile' to build the NAR file."
          echo "Run 'print-nar-instructions' for usage."
        '';
      };
    };
}
