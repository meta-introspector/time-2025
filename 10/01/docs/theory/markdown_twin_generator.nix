{ lib, ... }:

let
  common = import ../../../lib/common-imports.nix {};
  inherit (common) lib pkgs builtins;
  # A conceptual function to find and index all .md files in a given path.
  # This would be an impure operation as it scans the filesystem.
  indexMarkdownFiles = { 
    path, # The path to scan for .md files
    name ? "markdown-file-index",
  }:
    pkgs.runCommand name {
      inherit path;
      __impure = true; # Scanning the filesystem is impure
      nativeBuildInputs = [ pkgs.findutils pkgs.nix ]; # For `find` and `nix hash` commands
    }
    ''
      echo "Indexing .md files in ${path}..." >&2
      mkdir -p $out
      # Create a JSON array of objects { path, hash }
      echo "[" > $out/markdown-files.index.json
      FIRST=true
      find "${path}" -name "*.md" -print0 | while IFS= read -r -d $'\0' file; do
        relative_path=$(realpath --relative-to="${path}" "$file")
        file_hash=$(nix hash file --base32 "$file") # Get content hash
        if [ "$FIRST" = "false" ]; then
          echo "," >> $out/markdown-files.index.json
        fi
        echo "  {\"path\": \"${relative_path}\", \"hash\": \"${file_hash}\"}" >> $out/markdown-files.index.json
        FIRST=false
      done
      echo "]" >> $out/markdown-files.index.json
      echo "Markdown files indexed in $out/markdown-files.index.json" >&2
    '';

  # A conceptual function to generate a Nix "twin" for a Markdown file.
  # This twin would be a Nix expression that represents the Markdown file
  # and potentially provides functions to process it.
  generateMarkdownTwin = {
    markdownFilePath, # Path to the Markdown file in the Nix store
    name ? (builtins.baseNameOf markdownFilePath),
  }:
    pkgs.runCommand "markdown-twin-${name}" {
      inherit markdownFilePath;
      nativeBuildInputs = [ pkgs.pandoc ];
    }
    ''
      echo "Generating HTML for ${markdownFilePath}..." >&2
      mkdir -p $out
      pandoc -f markdown -t html ${markdownFilePath} > $out/index.html
      echo "HTML generated for ${markdownFilePath} at $out/index.html" >&2
    '';

  # Conceptual usage example
  exampleMarkdownIndexingAndTwinning = 
    let
      # Assume a path to a directory containing Markdown files
      # For this example, we'll use the current directory conceptually.
      # In a real scenario, this would be a specific source directory.
      markdownSourcePath = pkgs.lib.cleanSource ./.; # Conceptual: index current directory
      indexedMDFiles = indexMarkdownFiles { path = markdownSourcePath; };

      # Get the first Markdown file from the index (conceptual)
      # This part needs to be careful about empty indexes or non-existent files.
      firstMDFile = 
        let 
          indexContent = builtins.fromJSON (builtins.readFile "${indexedMDFiles}/markdown-files.index.json");
        in
        if builtins.length indexContent > 0 then builtins.head indexContent else null;

      firstMDTwin = 
        if firstMDFile != null then
          generateMarkdownTwin {
            markdownFilePath = "${markdownSourcePath}/${firstMDFile.path}";
            name = builtins.baseNameOf firstMDFile.path;
          }
        else
          null;
    in
    {
      inherit indexedMDFiles firstMDTwin;
    };

in
{
  inherit indexMarkdownFiles;
  inherit generateMarkdownTwin;
  inherit exampleMarkdownIndexingAndTwinning;
}
