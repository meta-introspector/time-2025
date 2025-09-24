#!/usr/bin/env bash

set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Path to the publish script
PUBLISH_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_nix_artifact_to_git.sh"

# Target repository URL
REPO_URL="https://github.com/meta-introspector/crq-binstore.git"

# List of flake attribute paths for Wikipedia articles
FLAKE_ATTR_PATHS=(
    "./22#17NumberWikidata"
    "./22#19NumberWikidata"
    "./22#BézoutIdentityWikidata"
    "./22#BottPeriodicityWikidata"
    "./22#CenteredHexagonalNumberWikidata"
    "./22#CenteredTriangularNumberWikidata"
    "./22#CoprimeIntegersWikidata"
    "./22#EigenvaluesAndEigenvectorsWikidata"
    "./22#EuclideanAlgorithmWikidata"
    "./22#FermatPrimeWikidata"
    "./22#KeithNumberWikidata"
    "./22#MathieuGroupM12Wikidata"
    "./22#MetonicCycleWikidata"
    "./22#MonstrousMoonshineWikidata"
    "./22#OnlineEncyclopediaOfIntegerSequencesWikidata"
    "./22#OntologyWikidata"
    "./22#SteinerSystemWikidata"
)

for attr_path in "${FLAKE_ATTR_PATHS[@]}"; do
  execute_cmd echo "Publishing $attr_path..."
  "$PUBLISH_SCRIPT" "$attr_path" "$REPO_URL"
done

echo "All Wikipedia NARs published."
