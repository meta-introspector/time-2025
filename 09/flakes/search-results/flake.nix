# Monster Knot Header
# -------------------
# This file is conceptually encoded with Monster Group properties.
#
# Binary (2^46) Representation:
#   - Duality: ☀️🌑
#   - Choice: ✅❌
#   - Order: 📐🌀
#   - ... (conceptual 46-bit string would go here)
#
# Ternary (3^20) Representation:
#   - Structure: ⏪⏸️⏩
#   - Completeness: 👶🚶👴
#   - ... (conceptual 20-ternary string/representation)
#
# Pentagonal (5^9) Representation:
#   - Insight: 🖐️🦋💡
#   - ...
#
# Heptagonal (7^6) Representation:
#   - Guidance: 🚶‍♀️🌈🎶
#   - ...
#
# Eleven (11^2) Representation:
#   - Composition: 🤝🌐
#   - ...
#
# Thirteen (13^3) Representation:
#   - Transformation: 🦋🎶📈
#   - ...
#
# Seventeen (17^1) Representation:
#   - Integration: 🌟
#   - ...
#
# Nineteen (19^1) Representation:
#   - Sporadic: 🎲
#   - ...
#
# Grounding ZOS: [0,1,2,3,5,7,11,13,17,19]
#
# Pointers to related content:
#   - Poem: [Link to relevant poem]
#   - Emoji Mapping: [Link to poem-emoji-prime-mapping.md]
#   - Monster Knot Calculation: [Link to nar-similarity-search/lib.nix]
#
# Conceptual Monster Knot for this file:
#   - Prime Exponents: { "2": 2, "3": 1, "5": 1, "7": 2, "11": 1, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️🌑🖐️🚶‍♀️🤝
# -------------------
# flakes/search-results/flake.nix
{
  description = "Flake for GitHub search results packaged as NARs.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    pickUpNix2.url = "github:meta-introspector/pick-up-nix2?ref=feature/CRQ-016-nixify"; # Assuming pick-up-nix2 is a flake
    narLocatorFlake = {
      url = "path:../../../../10/11/nar-locator"; # Relative path to the nar-locator flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pickUpNix2, narLocatorFlake, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Define the keywords to search for
        keywords = [
          "SOP"
          "crq"
          "task"
          "todo"
          "fixme"
          "I want to"
          "we will"
          "solfunmeme zos nft token"
        ];

        # Define the GitHub owners to search within
        owners = [
          "jmikedupont2"
          "meta-introspector"
          "h4ck3rm1k3"
        ];

        # Function to create a search derivation for a given keyword
        mkSearchNar = keyword:
          narLocatorFlake.lib.locateAndArchiveStorePath {
            storePath = pkgs.runCommand "temp-search-dir"
              {
                nativeBuildInputs = with pkgs;
                  [
                    gh # GitHub CLI
                    jq # JSON processor
                  ];
                TEMP_DIR = "$(mktemp -d)";
              } ''
              set -euo pipefail
    
              echo "Performing GitHub search for keyword: \"${keyword}\""
              echo "Owners: ${pkgs.lib.concatStringsSep "," owners}"
    
              # Initialize an empty JSON array for all results
              echo "[]" > "$TEMP_DIR/all_search_results.json"
    
              # Iterate over owners and perform search
              for owner in ${pkgs.lib.concatStringsSep " " owners}; do
                echo "Searching in owner: $owner"
                # gh search code outputs JSON directly, append to a temporary file
                gh search code "${keyword}" --owner "$owner" --json path,repository,text > "$TEMP_DIR/owner_results_$owner.json"
                # Merge results into the main JSON array
                jq -s '.[0] + .[1]' "$TEMP_DIR/all_search_results.json" "$TEMP_DIR/owner_results_$owner.json" > "$TEMP_DIR/all_search_results_tmp.json"
                mv "$TEMP_DIR/all_search_results_tmp.json" "$TEMP_DIR/all_search_results.json"
              done
    
              echo "Consolidated search results saved to $TEMP_DIR/all_search_results.json"
    
              # Create snippet files for easier browsing within the NAR
              jq -r '.[] | .path + " " + .repository.name + " " + .text' "$TEMP_DIR/all_search_results.json" | while read -r file_path repo_name snippet;
              do
                mkdir -p "$TEMP_DIR/$repo_name/$(dirname "$file_path")"
                echo "$snippet" > "$TEMP_DIR/$repo_name/$file_path.snippet"
              done
    
              # The output of this runCommand is the temporary directory itself
              cp -r "$TEMP_DIR"/* $out
            '';
            originalFilePath = "github-search-${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}";
            archiveType = "nar";
          };

        # Create an attribute set of search NARs, one for each keyword
        searchNars = pkgs.lib.genAttrs keywords mkSearchNar;

        # Function to create a NAR of all repositories for a given owner
        mkRepoListNar = ownerName:
          narLocatorFlake.lib.locateAndArchiveStorePath {
            storePath = pkgs.runCommand "temp-repo-list-dir"
              {
                buildInputs = with pkgs;
                  [
                    gh # GitHub CLI
                    jq # JSON processor
                  ];
                TEMP_DIR = "$(mktemp -d)";
              } ''
              set -euo pipefail

              echo "Listing GitHub repositories for owner: ${ownerName}"

              echo "Temporary directory: $TEMP_DIR"

              # gh repo list outputs JSON directly
              gh repo list "${ownerName}" --json name,url,description,owner,isArchived,isFork,createdAt,updatedAt --limit 1000 > "$TEMP_DIR/repos.json"

              echo "Repository list saved to $TEMP_DIR/repos.json"

              cp -r "$TEMP_DIR"/* $out
            '';
            originalFilePath = "repos-${ownerName}";
            archiveType = "nar";
          };

        # Derivation to sample Solana block number into a NAR
        solanaBlockNar = narLocatorFlake.lib.locateAndArchiveStorePath {
          storePath = pkgs.runCommand "temp-solana-block-dir"
            {
              buildInputs = with pkgs;
                [
                  curl # For making HTTP requests to Solana RPC
                  jq # For parsing JSON response
                ];
              TEMP_DIR = "$(mktemp -d)";
            } ''
            set -euo pipefail
            
            echo "Fetching latest Solana block number..."
            # Query Solana mainnet-beta RPC for block number
            # Using a public RPC endpoint for demonstration.
            # In a production setup, this might be configurable or use a local node.
            BLOCK_INFO=$(curl -s -X POST -H "Content-Type: application/json" \
              -d '{"jsonrpc":"2.0","id":1,"method":"getBlockHeight"}' \
              https://api.mainnet-beta.solana.com)
            
            BLOCK_NUMBER=$(echo "$BLOCK_INFO" | jq -r '.result')
            
            if [ -z "$BLOCK_NUMBER" ] || [ "$BLOCK_NUMBER" == "null" ]; then
              echo "Error: Could not retrieve Solana block number." >&2
              echo "RPC Response: $BLOCK_INFO" >&2
              exit 1
            }
            
            echo "Latest Solana Block Number: $BLOCK_NUMBER"
            
            echo "Temporary directory: $TEMP_DIR"
            
            echo "$BLOCK_NUMBER" > "$TEMP_DIR/solana_block_number.txt"
            echo "Block number saved to $TEMP_DIR/solana_block_number.txt"
            
            cp -r "$TEMP_DIR"/* $out
          '';
          originalFilePath = "solana-block-number";
          archiveType = "nar";
        };
        # Derivation to create a url2file locator script
        url2fileLocatorScript = { projectRoot }:
          pkgs.writeShellScriptBin "url2file-locate" ''
            #!/usr/bin/env bash
            set -euo pipefail
    
            GITHUB_URL="$1"
    
            if [ -z "$GITHUB_URL" ]; then
                echo "Error: GITHUB_URL is not set. Usage: url2file-locate \"https://github.com/owner/repo/blob/branch/path/to/file\"" >&2
                exit 1
            fi
    
            echo "Locating local file for URL: $GITHUB_URL..."
    
            # Extract owner, repo, and path within repo
            OWNER=$(echo "$GITHUB_URL" | awk -F'/' '{print $4}')
            REPO=$(echo "$GITHUB_URL" | awk -F'/' '{print $5}')
            # Remove "blob/branch/" part and get the rest of the path
            REPO_PATH=$(echo "$GITHUB_URL" | sed -E 's|https://github.com/[^/]+/[^/]+/blob/[^/]+/||')
    
            PROJECT_ROOT="${projectRoot}"
            LOCAL_GITHUB_ROOT="$PROJECT_ROOT/source/github"
    
            LOCAL_FILE_PATH="$LOCAL_GITHUB_ROOT/$OWNER/$REPO/$REPO_PATH"
    
            if [ -f "$LOCAL_FILE_PATH" ]; then
                echo "Local file found: $LOCAL_FILE_PATH"
            else
                echo "Local file not found at: $LOCAL_FILE_PATH"
            fi
            echo "Location attempt complete."
          '';

      in
      {
        packages = {
          inherit searchNars solanaBlockNar;
          url2fileLocatorScript = url2fileLocatorScript { projectRoot = pickUpNix2.outPath; }; # Pass pickUpNix2.outPath as projectRoot
          inherit mkRepoListNar;
          default = searchNars; # Make all search NARs available via default
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [
              gh
              jq
              curl # Add curl to devShell for testing
            ];
        };
      }
    );
}
