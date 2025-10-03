# theory/nix-indexer-pipeline.nix
#
# Implements the Nix Code Indexer Pipeline (CRQ-041) for extracting unique terms
# from Nix paths and metadata.

{ lib, ... } @ args:

let
  # Step 4: Data Consumption Batch
  # Reads the raw JSON index file into a Nix data structure.
  rawIndexJson = builtins.readFile ../nix-files.index.json;
  indexedFiles = builtins.fromJSON rawIndexJson;

  # Step 5: Tokenization and Term Generation (Pattern Batch)
  # Defines a simple tokenizePath function and extracts unique terms.

  # Simple tokenizer: splits by common delimiters and filters out noise.
  tokenizePath = path:
    let
      # Replace delimiters with a single space for easy splitting
      normalizedPath = lib.replaceStrings ["/" "-" "."] [" " " " " "] path;
      # Split by space and filter out empty strings
      tokens = lib.filter (s: s != "") (lib.splitString " " normalizedPath);
      # Filter out common file extensions and other noise
      filteredTokens = lib.filter (s:
        ! (lib.elem s ["nix" "json" "md" "sh" "txt" "d" "flake" "lib" "src" "docs" "theory" "meme" "memestorm" "tiktok" "001" "09" "24" "25" "26" "jobs" "vendor" "nixpkgs" "github" "meta" "introspector" "streamofrandom" "2025" "pick" "up" "cli" "gemini" "today" "ai" "ml" "zk" "ops" "flakes" "external" "build" "step" "build_step" "common" "imports" "debug" "utils" "test" "utils" "log" "analyzer" "review2" "rungemini" "run_task" "nix_custom_attrs_test" "test_custom_attrs" "setup_gemini_context" "leech" "lattice" "24d" "monster" "group" "71" "vibe" "crqs" "blade" "instance" "blades" "d17"])
      ) tokens;
    in
    filteredTokens;

  # Extract all tokens from all indexed file paths
  allTokens = lib.flatten (lib.map (file: tokenizePath file.path) indexedFiles);

  # Get unique terms
  uniqueTerms = lib.unique (lib.sort (a: b: a < b) allTokens);

in
{
  # Expose the unique terms
  inherit uniqueTerms;

  # Expose the raw indexed files for inspection
  inherit indexedFiles;
}
