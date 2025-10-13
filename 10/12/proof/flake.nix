{
  description = "Proof of value for October 12, 2025: Demonstrates the utility of QA refactoring, URL extraction, Deadnix integration, and the local flake registry.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the main project flake
    streamofrandom = {
      url = "path:../../..";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    rnix-dumper.url = "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=10/12/proof/000_rnix_dump";
    nar-exporter = {
      url = "path:./001_nar_exporter";
    };
    binstore-locator = {
      url = "path:./002_binstore_locator";
      #      inputs.nar-exporter = nar-exporter;
    };
    nix-to-solana-translator = {
      url = "path:./004_nix_to_solana_translator";
      #      inputs.nar-exporter-flake = nar-exporter;
    };
    # nix-dumper.url = "path:./001_dump_nix";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , streamofrandom
    , rnix-dumper
    , nar-exporter
    , binstore-locator
    , nix-to-solana-translator
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      # Function to safely evaluate an expression and capture errors
      tryEval = expr:
        let
          result = builtins.tryEval expr;
        in
        if result.success
        then { success = true; value = result.value; error = null; }
        else { success = false; value = null; error = result.error; };

      # Check from 000_rnix_dump, wrapped in tryEval
      rnixDumpCheckResult = tryEval rnix-dumper.packages.${system}.default;

      # # Safely evaluate nix-dumper package
      # nixDumperPackageResult = tryEval nix-dumper.packages.${system}.default;

      # Check from 001_dump_nix, depending on the first check
      nixDumpCheck =
        if !rnixDumpCheckResult.success then
          pkgs.runCommand "nix-dump-check-failed-rnix"
            {
              passthru.error = "rnixDumpCheck failed: ${rnixDumpCheckResult.error}";
            } "echo \"rnixDumpCheck failed: ${rnixDumpCheckResult.error}\" > $out"
        else
          pkgs.runCommand "nix-dump-check"
            {
              buildInputs = [ rnixDumpCheckResult.value ];
            } "touch $out";

      # Run the default QA check from the main project flake
      todayValueCheck = streamofrandom.checks.${system}.default;

      # Import specific QA checks from the main project flake
      nixEmojiReport = streamofrandom.checks.${system}.nix-emoji-report;
      urlExtractorReport = streamofrandom.checks.${system}.url-extractor;

      # A combined report demonstrating uniqueness and value
      combinedProofReport = pkgs.runCommand "combined-proof-report"
        {
          inherit nixEmojiReport urlExtractorReport;
          rnixDumperOutput = rnix-dumper.packages.${system}.default;
          narExporterOutput = nar-exporter.packages.${system}.default;
          binstoreLocatorOutput = binstore-locator.packages.${system}.default;
          solanaTranslatorOutput = nix-to-solana-translator.packages.${system}.default;
          nativeBuildInputs = [ pkgs.coreutils ]; # For sha256sum
        } ''
                    echo "--- Combined Proof Report for October 12, 2025 ---"
                    mkdir -p $out
                    reportFile="$out/proof-report.md"
                    echo "# Proof Report for October 12, 2025" > "$reportFile"
                    echo "" >> "$reportFile"
                    echo "## Summary of Today's Contributions:" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "This report combines key outputs from the QA system to highlight the uniqueness and value of the work performed today." >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### Nix Emoji Report" >> "$reportFile"
                    echo "" >> "$reportFile"
                    cat "$nixEmojiReport/nix-emoji-report.md" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### URL Extraction Report" >> "$reportFile"
                    echo "" >> "$reportFile"
                    cat "$urlExtractorReport/url-report.md" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### RNix Dumper Output" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "Path: $rnixDumperOutput" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### NAR Exporter Output" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "Path: $narExporterOutput" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### Binstore Locator Output" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "Path: $binstoreLocatorOutput" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "### Solana Translator Output" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "Path: $solanaTranslatorOutput" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "## Conceptual Uniqueness and Value Assessment:" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "The combined data from the Nix Emoji Report (representing structural and semantic fingerprints) and the URL Extraction Report (identifying external dependencies and sources) provides a rich feature set for assessing the uniqueness and value of today's contributions." >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "By comparing these feature sets against a 'map' of existing project contributions, we can identify:" >> "$reportFile"
                    echo "*   **Distinctness:** New patterns in Nix expressions, novel URL sources, or unique combinations of dependencies." >> "$reportFile"
                    echo "*   **Value:** Contributions that introduce new functionalities, integrate new external resources, or improve existing code in a structurally different way." >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "--- Combined Proof Report Generated to $reportFile ---"
            
                    # Calculate and append the Proof of Novelty Fingerprint
                    NOVELTY_FINGERPRINT=$(sha256sum "$reportFile" | awk 
        '{print $1}')
                    echo "" >> "$reportFile"
                    echo "## Proof of Novelty Fingerprint (SHA256):" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "```
        $NOVELTY_FINGERPRINT
        ```" >> "$reportFile"
                    echo "" >> "$reportFile"
                    echo "--- End of Proof Report ---"
                    touch $out
      '';

    in
    rec {
      # An app to demonstrate using the local registry
      registryDemoApp = pkgs.writeShellScriptBin "registry-demo" ''
        echo "--- Demonstrating Local Flake Registry ---"
        echo "Attempting to show nixpkgs flake info using registry:"
        nix flake show nixpkgs
        echo "Attempting to show streamofrandom flake info using registry:"
        nix flake show streamofrandom
        echo "--- Registry Demo Complete ---"
      '';

      checks = {
        rnixDumpCheck = tryEval rnix-dumper.packages.${system}.default;
        # nixDumpCheck = nixDumpCheck; # Commented out
        #default = combinedProofReport;
        #default = rnixDumpCheck;
        narBinstoreLocator = binstore-locator.packages.${system}.default;
        solanaTranslator = nix-to-solana-translator.packages.${system}.default; # New check
      };
      packages.default = combinedProofReport;
      apps.registry-demo = {
        type = "app";
        program = "${registryDemoApp}/bin/registry-demo";
      };
    }
    );
}
