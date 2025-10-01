# flakes/search-results/flake.nix
{
  description = "Flake for GitHub search results packaged as NARs.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
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
          pkgs.stdenv.mkDerivation {
            pname = "github-search-${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}";
            version = "0.1.0";

            # Build inputs for the search script
            buildInputs = with pkgs;
              [ gh # GitHub CLI
                jq # JSON processor
              ];

            # The builder script that performs the search and creates the NAR
            # This derivation is impure because it accesses the network (GitHub API)
            # and relies on external tools (gh CLI).
            # It also needs access to the GitHub token, which should be handled securely
            # (e.g., via environment variables or sops-nix, not hardcoded here).
            # For demonstration, we assume gh CLI is authenticated.
            builder = pkgs.writeShellScript "search-builder" ''
              set -euo pipefail

              echo "Performing GitHub search for keyword: \"${keyword}\""
              echo "Owners: ${pkgs.lib.concatStringsSep "," owners}"

              TEMP_DIR=$(mktemp -d)
              echo "Temporary directory: $TEMP_DIR"

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

              # Create the NAR from the temporary directory
              echo "Creating NAR from $TEMP_DIR..."
              nix-store --dump "$TEMP_DIR" > "$out"/${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}.nar

              echo "NAR created at $out/${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}.nar"
              rm -rf "$TEMP_DIR"
            '';

            # Mark as impure because it accesses the network
            # This is generally discouraged in pure Nix, but requested by the user
            # and necessary for dynamic network access.
            # In a production system, such network access would typically be
            # isolated and controlled (e.g., via a trusted builder).
            impureEnv = true;
          };

        # Create an attribute set of search NARs, one for each keyword
        searchNars = pkgs.lib.genAttrs keywords (keyword: mkSearchNar keyword);

        # Function to create a NAR of all repositories for a given owner
        mkRepoListNar = ownerName:
          pkgs.stdenv.mkDerivation {
            pname = "github-repos-${ownerName}";
            version = "0.1.0";

            buildInputs = with pkgs; [
              gh # GitHub CLI
              jq # JSON processor
            ];

            builder = pkgs.writeShellScript "repo-list-builder" ''
              set -euo pipefail

              echo "Listing GitHub repositories for owner: ${ownerName}"

              TEMP_DIR=$(mktemp -d)
              echo "Temporary directory: $TEMP_DIR"

              # gh repo list outputs JSON directly
              gh repo list "${ownerName}" --json name,url,description,owner,isArchived,isFork,createdAt,updatedAt --limit 1000 > "$TEMP_DIR/repos.json"

              echo "Repository list saved to $TEMP_DIR/repos.json"

              # Create the NAR from the temporary directory
              echo "Creating NAR from $TEMP_DIR..."
              nix-store --dump "$TEMP_DIR" > "$out"/repos-${ownerName}.nar

              echo "NAR created at $out/repos-${ownerName}.nar"
              rm -rf "$TEMP_DIR"
            '';

            impureEnv = true;
          };

        # Derivation to sample Solana block number into a NAR
        solanaBlockNar = pkgs.stdenv.mkDerivation {
          pname = "solana-block-sampler";
          version = "0.1.0";

          buildInputs = with pkgs; [
            curl # For making HTTP requests to Solana RPC
            jq   # For parsing JSON response
          ];

          builder = pkgs.writeShellScript "solana-block-builder" ''
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
            fi

            echo "Latest Solana Block Number: $BLOCK_NUMBER"

            TEMP_DIR=$(mktemp -d)
            echo "Temporary directory: $TEMP_DIR"

            echo "$BLOCK_NUMBER" > "$TEMP_DIR/solana_block_number.txt"
            echo "Block number saved to $TEMP_DIR/solana_block_number.txt"

            # Create the NAR from the temporary directory
            echo "Creating NAR from $TEMP_DIR..."
            nix-store --dump "$TEMP_DIR" > "$out"/solana-block-number.nar

            echo "NAR created at $out/solana-block-number.nar"
            rm -rf "$TEMP_DIR"
          '';

          # Mark as impure because it accesses the network
          impureEnv = true;
        };

        # Derivation to create a url2file locator script
        url2fileLocatorScript = pkgs.writeShellScriptBin "url2file-locate" ''
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

          PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"
          LOCAL_GITHUB_ROOT="$PROJECT_ROOT/source/github"

          LOCAL_FILE_PATH="$LOCAL_GITHUB_ROOT/$OWNER/$REPO/$REPO_PATH"

          if [ -f "$LOCAL_FILE_PATH" ]; then
              echo "Local file found: $LOCAL_FILE_PATH"
          else
              echo "Local file not found at: $LOCAL_FILE_PATH"
          fi
          echo "Location attempt complete."
        '';

      in {
        packages = {
          inherit searchNars solanaBlockNar url2fileLocatorScript mkRepoListNar;
          default = searchNars; # Make all search NARs available via default
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [ gh
              jq
              curl # Add curl to devShell for testing
            ];
        };
      }
    );
}
