{
  description = "Proof of value for October 12, 2025: Demonstrates the utility of QA refactoring, URL extraction, Deadnix integration, and the local flake registry.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the main project flake
    streamofrandom.url = "path:../../..";
  };

  outputs = { self, nixpkgs, flake-utils, streamofrandom }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Run the default QA check from the main project flake
        todayValueCheck = streamofrandom.checks.${system}.default;

        # Import specific QA checks from the main project flake
        nixEmojiReport = streamofrandom.checks.${system}.nix-emoji-report;
        urlExtractorReport = streamofrandom.checks.${system}.url-extractor;

        # A combined report demonstrating uniqueness and value
        combinedProofReport = pkgs.runCommand "combined-proof-report"
          {
            inherit nixEmojiReport urlExtractorReport;
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
                      echo "## Conceptual Uniqueness and Value Assessment:" >> "$reportFile"
                      echo "" >> "$reportFile"
                      echo "The combined data from the Nix Emoji Report (representing structural and semantic fingerprints) and the URL Extraction Report (identifying external dependencies and sources) provides a rich feature set for assessing the uniqueness and value of today's contributions." >> "$reportFile"
                      echo "" >> "$reportFile"
                      echo "By comparing these feature sets against a 'map' of existing project contributions, we can identify:" >> "$reportFile"
                      echo "*   **Distinctness:** New patterns in Nix expressions, novel URL sources, or unique combinations of dependencies." >> "$reportFile"
                      echo "*   **Value:** Contributions that introduce new functionalities, integrate new external resources, or improve existing code in a structurally different way." >> "$reportFile"
                      echo "" >> "$reportFile"
                      echo "Further analysis would involve embedding these feature sets into a multi-dimensional space and calculating distance metrics to identify 'closest neighbors' and quantify the novelty of today's work." >> "$reportFile"
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

        checks.default = combinedProofReport;
        apps.registry-demo = {
          type = "app";
          program = "${registryDemoApp}/bin/registry-demo";
        };
      }
    );
}
