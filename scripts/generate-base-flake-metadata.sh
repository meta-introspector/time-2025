#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Default values
FLAKE_NAME=""
DESCRIPTION=""
SYSTEM=""
NIXPKGS_REF=""
FLAKE_UTILS_REF=""
OUT_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --flake-name)
      FLAKE_NAME="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --system)
      SYSTEM="$2"
      shift 2
      ;;
    --nixpkgs-ref)
      NIXPKGS_REF="$2"
      shift 2
      ;;
    --flake-utils-ref)
      FLAKE_UTILS_REF="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option $1" >&2
      exit 1
      ;;
    *)
      echo "Unknown argument $1" >&2
      exit 1
      ;;
  esac
done

# Ensure all required arguments are set
: "${FLAKE_NAME:?Error: --flake-name not set}"
: "${DESCRIPTION:?Error: --description not set}"
: "${SYSTEM:?Error: --system not set}"
: "${NIXPKGS_REF:?Error: --nixpkgs-ref not set}"
: "${FLAKE_UTILS_REF:?Error: --flake-utils-ref not set}"
: "${OUT_DIR:?Error: --out-dir not set}"

mkdir -p "$OUT_DIR"

cat > "$OUT_DIR/metadata.txt" <<EOF
Flake Name: ${FLAKE_NAME}
Description: ${DESCRIPTION}
System: ${SYSTEM}
Nixpkgs Ref: ${NIXPKGS_REF}
Flake-Utils Ref: ${FLAKE_UTILS_REF}
EOF

echo "Metadata generated successfully in $OUT_DIR/metadata.txt"
