#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Ensure the cache directory exists
execute_cmd /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/setup_wikipedia_cache.sh

# Clear or create the articles list file
execute_cmd bash -c "> wikipedia_articles.md"

# List of Wikipedia URLs to cache (manually cleaned)
WIKI_URLS=(
    "https://en.wikipedia.org/wiki/17_(number)"
    "https://en.wikipedia.org/wiki/19_(number)"
    "https://en.wikipedia.org/wiki/B%C3%A9zout%27s_identity"
    "https://en.wikipedia.org/wiki/Bott_periodicity"
    "https://en.wikipedia.org/wiki/Centered_hexagonal_number"
    "https://en.wikipedia.org/wiki/Centered_triangular_number"
    "https://en.wikipedia.org/wiki/Coprime_integers"
    "https://en.wikipedia.org/wiki/Eigenvalues_and_eigenvectors"
    "https://en.wikipedia.org/wiki/Euclidean_algorithm"
    "https://en.wikipedia.org/wiki/Fermat_prime"
    "https://en.wikipedia.org/wiki/Gematria"
    "https://en.wikipedia.org/wiki/Griess_algebra"
    "https://en.wikipedia.org/wiki/Group_(mathematics)"
    "https://en.wikipedia.org/wiki/Heptadecagon"
    "https://en.wikipedia.org/wiki/Homotopy"
    "https://en.wikipedia.org/wiki/Keith_number"
    "https://en.wikipedia.org/wiki/Lattice_(order)"
    "https://en.wikipedia.org/wiki/Mathieu_group_M11"
    "https://en.wikipedia.org/wiki/Mathieu_group_M12"
    "https://en.wikipedia.org/wiki/Metonic_cycle"
    "https://en.wikipedia.org/wiki/Monster_group"
    "https://en.wikipedia.org/wiki/Monstrous_moonshine"
    "https://en.wikipedia.org/wiki/Online_Encyclopedia_of_Integer_Sequences"
    "https://en.wikipedia.org/wiki/Parameter_(mathematics)"
    "https://en.wikipedia.org/wiki/Riemann_zeta_function"
    "https://en.wikipedia.org/wiki/Sporadic_group"
    "https://en.wikipedia.org/wiki/Steiner_system"
    "https://en.wikipedia.org/wiki/Transitive_group_action"
    "https://en.wikipedia.org/wiki/Vertex_operator_algebra"
)

for url in "${WIKI_URLS[@]}"; do
    # Sanitize URL to create a filename
    filename=$(echo "$url" | sed -e 's/https:\/\/en.wikipedia.org\/wiki\///g' -e 's/[^a-zA-Z0-9_.-]/_/g')
    filepath="wikipedia_cache/${filename}.html"

    execute_cmd echo "Caching: $url to $filepath"
    # Use curl to get content and save it
    execute_cmd echo "Fetching content for $url using curl..."
    execute_cmd curl -sL -A "solfunmeme.com" "$url" -o "$filepath"

    # Check if the file is empty
    if [ ! -s "$filepath" ]; then
        execute_cmd echo "Warning: Fetched file is empty: $filepath. This might indicate a block or an empty page."
    fi

    # Add to articles list
    execute_cmd bash -c "echo \"- [$url]($url) -> $filepath\" >> wikipedia_articles.md"
done

execute_cmd echo "Wikipedia caching process simulated. Review wikipedia_articles.md and wikipedia_cache/ directory."
