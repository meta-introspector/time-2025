#!/usr/bin/env bash

set -euo pipefail

NAR_FILE="$1"
# CRQ_BINSTORE_PATH is now expected to be set by the wrapper script
OUTPUT_DIR="./unpacked-nar-data"

if [[ -z "$NAR_FILE" ]]; then
  echo "Usage: $0 <nar-file-name>"
  exit 1
fi

if [[ -z "$CRQ_BINSTORE_PATH" ]]; then
  echo "Error: CRQ_BINSTORE_PATH environment variable is not set."
  exit 1
fi

NAR_PATH="${CRQ_BINSTORE_PATH}/${NAR_FILE}"

if [[ ! -f "$NAR_PATH" ]]; then
  echo "Error: NAR file not found at ${NAR_PATH}"
  exit 1
fi

echo "Unpacking NAR file: ${NAR_PATH}"
mkdir -p "${OUTPUT_DIR}"
nix-nar-unpack --file "${NAR_PATH}" --to "${OUTPUT_DIR}"

echo "NAR file unpacked to: ${OUTPUT_DIR}"