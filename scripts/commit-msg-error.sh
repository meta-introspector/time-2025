#!/usr/bin/env bash

# This script generates a detailed error message for the commit message check.

COMMIT_MSG="$1"
REGEX="$2"

echo "--------------------------------------------------------------------------------" >&2
echo "ERROR: Commit message does not follow the required format!" >&2
echo "--------------------------------------------------------------------------------" >&2
echo "Failing Commit Message:" >&2
echo "'''" >&2
echo "${COMMIT_MSG}" >&2
echo "'''" >&2
echo "" >&2
echo "Expected Format (Regex):" >&2
echo "'''" >&2
echo "${REGEX}" >&2
echo "'''" >&2
echo "" >&2
echo "Allowed formats:" >&2
echo "  - CRQ-XXX: <message>" >&2
echo "  - <type>(<scope>): <message>" >&2
echo "" >&2
echo "Examples:" >&2
echo "  - feat(CRQ-041): add-new-feature" >&2
echo "  - fix: resolve-bug-in-module" >&2
echo "  - CRQ-007: implement-solana-feature" >&2
echo "" >&2
echo "Troubleshooting Tips:" >&2
echo "  - Ensure the CRQ ID (e.g., CRQ-041) exists as a '09/crq-XXX.foaf.nix' or 'docs/crqs/CRQ_XXX_*.md' file." >&2
echo "  - Verify the type (feat, fix, docs, etc.) is one of the conventional types." >&2
echo "  - Check for correct spacing after the colon ': '." >&2
echo "  - The scope (e.g., '(CRQ-041)') is optional but must be enclosed in parentheses if present." >&2
echo "--------------------------------------------------------------------------------" >&2
exit 1
