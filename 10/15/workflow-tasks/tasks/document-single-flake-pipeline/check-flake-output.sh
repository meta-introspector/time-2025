#!/usr/bin/env bash

# SC2154: These variables are referenced but not assigned within the script.
# They are expected to be passed as environment variables by Nix's pkgs.runCommand.
# shellcheck disable=SC2154

set +e # Don't exit on first error
if nix build "$flakePath".#"$output" --no-link &> "$out/build_log.txt"; then
  echo "status=success" > "$out/status"
  cp "$(nix build "$flakePath".#"$output" --no-link --print-out-paths)" "$out/content"
else
  echo "status=failure" > "$out/status"
  cat "$out/build_log.txt" > "$out/error_log.txt"
fi