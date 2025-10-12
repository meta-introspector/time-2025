{ pkgs, lib, projectInfo, rnix-parser }:

let
  check = pkgs.runCommand "url-extractor"
    {
      inherit (projectInfo) allProjectNixFiles;
      inherit (pkgs) jq;
      rnixParserBin = rnix-parser.packages.${pkgs.system}.default; 
      name = "url-extractor-report";
    } ''
    echo "--- Extracting URLs from Nix files using rnix-parser ---"
    mkdir -p $out/json_asts
    reportFile="$out/url-report.md"
    echo "# URL Extraction Report" > "$reportFile"
    echo "" >> "$reportFile"

    for nixFile in $allProjectNixFiles; do
      # Generate a unique filename for the JSON AST
      jsonAstFile="$out/json_asts/$(basename "$nixFile").json"

      echo "## File: $nixFile" >> "$reportFile"
      echo "### JSON AST: [$(basename "$jsonAstFile")](./json_asts/$(basename "$jsonAstFile"))" >> "$reportFile"
      echo "" >> "$reportFile"

      # Generate and cache the JSON AST
      "$rnixParserBin"/bin/rnix-parser --json < "$nixFile" > "$jsonAstFile"

      echo "
 >> "$reportFile"
      # Extract URLs from the cached JSON AST for the report
      "$jq"/bin/jq -r '.. | select(type == "string") | select(test("https?://|git@|github:|path:"))' "$jsonAstFile" | sort -u >> "$reportFile"
      echo "
 >> "$reportFile"
      echo "" >> "$reportFile"
    done

    echo "--- URL Extraction Report Generated to $reportFile ---"
    touch $out
  '';
in
check