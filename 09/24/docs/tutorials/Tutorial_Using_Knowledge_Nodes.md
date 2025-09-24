# Tutorial: Using Nix-based Knowledge Nodes

This tutorial guides you through defining, building, querying, and inspecting "knowledge nodes" – structured data payloads managed by Nix flakes, designed for AI context composition.

## 1. Defining a Knowledge Node

A knowledge node is essentially a Nix derivation that packages a data payload (e.g., a Wikipedia article's content) and annotates it with custom attributes (metadata).

### Example: `mypackage.nix` (Knowledge Node Definition)

Create a file `nix_custom_attrs_test/mypackage.nix`:

```nix
{ stdenv }:

stdenv.mkDerivation {
  name = "knowledge-article-monster-group";
  src = ./some-local-file.txt; # Path to your data payload

  # This phase copies the data payload into the output path in the Nix store.
  installPhase = ''
    cp $src $out/article.txt
  '';

  # --- Custom Attributes for Knowledge Representation ---
  article_title = "Monster Group";
  tags = [ "mathematics" "group-theory" "sporadic-groups" ];
  summary = "The largest sporadic simple group.";
  related_topics = [ "Monstrous Moonshine" "Griess Algebra" ];

  # Helper attribute for easy shell parsing of tags
  tags_string = builtins.concatStringsSep " " tags;
}
```

### Example: `nix_custom_attrs_test/some-local-file.txt` (Data Payload)

```
This is the content of a sample article about the Monster Group.
It is the largest sporadic simple group.
```

### Example: `nix_custom_attrs_test/default.nix` (Entry Point)

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./mypackage.nix {}
```

## 2. Building and Querying a Knowledge Node

You can build the knowledge node and query its custom attributes using Nix commands.

```bash
# Navigate to your test directory
cd nix_custom_attrs_test

# Query a custom attribute (e.g., article_title)
ARTICLE_TITLE=$(nix-instantiate --eval -A article_title . | xargs)
echo "Article Title: $ARTICLE_TITLE"

# Query another custom attribute (e.g., tags_string)
TAGS=$(nix-instantiate --eval -A tags_string . | xargs)
echo "Tags: $TAGS"

# Build the knowledge node to get its store path (the NAR payload)
RESULT_PATH=$(nix-build .)
echo "Knowledge Node NAR Payload Path: $RESULT_PATH"

# Inspect the content of the payload
cat "$RESULT_PATH/article.txt"
```

## 3. Inspecting a Knowledge Node NAR File

Once a knowledge node is built, its data payload resides in the Nix store as a NAR file. You can inspect this NAR file using `nix-nar-unpack`.

Assuming you have the absolute path to a `.nar` file (e.g., one published to `crq-binstore` or exported from a build):

```bash
# Example: Let's assume you have a NAR file named 'my-knowledge-node.nar'
# For demonstration, we'll export the one we just built:
nix-store --export $(nix-build . --no-out-link) > /tmp/my-knowledge-node.nar

NAR_FILE_PATH="/tmp/my-knowledge-node.nar"
OUTPUT_DIR="/tmp/unpacked-knowledge-node"

echo "Unpacking NAR file: $NAR_FILE_PATH"
mkdir -p "$OUTPUT_DIR"
nix-nar-unpack --file "$NAR_FILE_PATH" --to "$OUTPUT_DIR"

echo "NAR content unpacked to: $OUTPUT_DIR"
ls -l "$OUTPUT_DIR"
cat "$OUTPUT_DIR/article.txt" # Assuming your article was named article.txt inside the NAR
```

## 4. Publishing a Knowledge Node NAR

To share your knowledge node, you can publish its NAR file to a Git repository like `crq-binstore`. This typically involves building the derivation, exporting it as a NAR, and pushing it to the repository.

The `scripts/publish_knowledge_node_nar.sh` script automates this process:

```bash
# Example: Publish the 'monster-group' knowledge node
# (Ensure you are in the project root or adjust paths accordingly)
scripts/publish_knowledge_node_nar.sh \
  .#packages.aarch64-linux.knowledge-article-monster-group \
  https://github.com/meta-introspector/crq-binstore.git
```

*Note: The exact flake attribute path (`.#packages.aarch64-linux.knowledge-article-monster-group`) depends on how your knowledge node is integrated into your main `flake.nix`.*

## 5. Using Existing NAR Inspection Scripts

The project includes scripts for further analysis of NAR files:

*   **`fetch-nar-data.sh`**: Used to unpack a NAR file from a given path.
    ```bash
    # Example usage (assuming CRQ_BINSTORE_PATH is set)
    # CRQ_BINSTORE_PATH="/path/to/cloned/crq-binstore"
    # scripts/fetch-nar-data.sh <nar-file-name-in-binstore>
    ```
*   **`extract_nar_wordlist.sh`**: Extracts text content from a NAR and generates a wordlist.
    ```bash
    # Example usage
    # scripts/extract_nar_wordlist.sh /tmp/my-knowledge-node.nar
    ```
*   **`inspect_nar_content.sh`**: Performs keyword frequency analysis on NAR content.
    ```bash
    # Example usage
    # scripts/inspect_nar_content.sh /tmp/my-knowledge-node.nar
    ```
    *Note: Ensure these scripts are updated to use `nix-nar-unpack` or `nix-store --restore` for extraction, not `tar -xf`.*

By following these steps, you can effectively manage and share structured knowledge using Nix flakes, making it composable for various applications, including AI context generation.
