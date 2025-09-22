#!/usr/bin/env bash

# Ensure the cache directory exists
./setup_wikipedia_cache.sh

# Clear or create the articles list file
> wikipedia_articles.md

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

    echo "Caching: $url to $filepath"
    # Use curl to get content and save it
    echo "Fetching content for $url using curl..."
    curl -sL "$url" > "$filepath"

    # Add to articles list
    echo "- [$url]($url) -> $filepath" >> wikipedia_articles.md
done

echo "Wikipedia caching process simulated. Review wikipedia_articles.md and wikipedia_cache/ directory."
