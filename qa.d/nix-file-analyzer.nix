{ pkgs, lib, projectInfo, rnix-parser, deadnix }:

let
  check = pkgs.runCommand "nix-file-analyzer"
    {
      inherit (projectInfo) allProjectNixFiles;
      inherit (pkgs) jq;
      rnixParserBin = rnix-parser.packages.${pkgs.system}.default;
      deadnixBin = deadnix;
      name = "nix-file-analyzer-report";
    } ''
        echo "--- Analyzing Nix files for URLs and Unused Variables ---"
        mkdir -p $out/knowledge_dumps
        mkdir -p $out/deadnix_reports
        reportFile="$out/analysis-report.md"
        echo "# Nix File Analysis Report" > "$reportFile"
        echo "" >> "$reportFile"

        for nixFile in $allProjectNixFiles; do
          # Generate unique filenames for JSON AST and deadnix report
          fileBaseName=$(basename "$nixFile")
          jsonAstFile="$out/knowledge_dumps/$fileBaseName.ast.json"
          deadnixReportFile="$out/deadnix_reports/$fileBaseName.deadnix.json"
          combinedKnowledgeFile="$out/knowledge_dumps/$fileBaseName.knowledge.json"

          echo "## File: $nixFile" >> "$reportFile"
          echo "### Combined Knowledge: [$(basename "$combinedKnowledgeFile")](./knowledge_dumps/$(basename "$combinedKnowledgeFile"))" >> "$reportFile"
          echo "" >> "$reportFile"

          # Generate and cache the JSON AST
          "$rnixParserBin"/bin/rnix-parser --json < "$nixFile" > "$jsonAstFile"

          # Generate and cache the deadnix report
          "$deadnixBin" --output-format json "$nixFile" > "$deadnixReportFile" || true

          # Combine JSON AST and deadnix report into a single knowledge dump
          "$jq"/bin/jq -s '{
      "ast": .[0],
      "deadnix": .[1],
      "extractedUrls": (.[0] | .. | select(type == "string") | select(test("https?://|git@|github:|path:")) | unique)
    }' "$jsonAstFile" "$deadnixReportFile" > "$combinedKnowledgeFile"

          echo "```json"
     >> "$reportFile"
          # Display a summary of extracted URLs and deadnix findings in the markdown report
          "$jq"/bin/jq '{"extractedUrls": .extractedUrls, "deadnixFindings": .deadnix}' "$combinedKnowledgeFile" >> "$reportFile"
          echo "```"
     >> "$reportFile"
          echo "" >> "$reportFile"
        done

        echo "--- Nix File Analysis Report Generated to $reportFile ---"
        touch $out
  '';
in
check
