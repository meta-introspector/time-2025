#!/usr/bin/env bash 
NIX_STORE_PATH=$(nix-store --query ./result)
NIX_HASH=$(basename "${NIX_STORE_PATH}")
NAR_FILE="${NIX_HASH}.nar" 
BINSTORE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/current-month/22/crq-binstore"
export NIX_STORE_PATH
export NIX_HASH
export NAR_FILE
export BINSTORE_PATH

echo store "${NIX_STORE_PATH}"
echo hash "${NIX_HASH}"
echo file "${NAR_FILE}"
echo binstore "${BINSTORE_PATH}"


set -e
set -x
echo going to exprot "${BINSTORE_PATH}/${NAR_FILE}"
nix-store --export "${NIX_STORE_PATH}" > "${BINSTORE_PATH}/${NAR_FILE}"
pushd "${BINSTORE_PATH}"
git add  "${NAR_FILE}"
git commit -m "feat: Add ${NAR_FILE} to binstore"
git push
popd
