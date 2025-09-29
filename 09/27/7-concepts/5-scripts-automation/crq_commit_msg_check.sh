#!/usr/bin/env bash

set -e
set -o pipefail

# This script checks if the commit message adheres to conventional commit standards,
# including CRQ-XXX: format or standard types, and other rules like header length.

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Extract header (first line)
HEADER=$(echo "$COMMIT_MSG" | head -n 1)

# Check header length
if [[ ${#HEADER} -gt 72 ]]; then
  echo "Error: Commit header must not exceed 72 characters." >&2
  exit 1
fi

# Regex for conventional commit header: <type>(<scope>?): <subject>
# Also includes CRQ-XXX: as a valid type pattern
HEADER_REGEX="^((CRQ-[0-9]+|feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_-]+\))?: .*)"

if ! echo "$HEADER" | grep -E "$HEADER_REGEX"; then
  echo "Error: Commit message header must follow the conventional commit format: <type>(<scope>?): <subject>" >&2
  echo "       Valid types include: CRQ-XXX, feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert." >&2
  exit 1
fi

# Extract type, scope, and subject using sed and regex groups
# This is a simplified extraction, more robust parsing might be needed for complex scopes
TYPE=$(echo "$HEADER" | sed -E 's/^((CRQ-[0-9]+|feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert))(\([a-zA-Z0-9_-]+\))?:.*$/\1/')
SCOPE=$(echo "$HEADER" | sed -E 's/^((CRQ-[0-9]+|feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert))\(([a-zA-Z0-9_-]+)\):.*$/\3/')
SUBJECT=$(echo "$HEADER" | sed -E 's/^((CRQ-[0-9]+|feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_-]+\))?: )(.+)$/\4/')

# Validate subject is not empty
if [[ -z "$SUBJECT" ]]; then
  echo "Error: Commit subject cannot be empty." >&2
  exit 1
fi

# Validate type enum (already covered by HEADER_REGEX for now, but can be expanded)
# For CRQ-XXX, the type is CRQ-XXX, which is handled by the regex.
# For other types, we can add more specific checks if needed.

# Validate scope case (kebab-case) if scope exists and is not a CRQ number
if [[ -n "$SCOPE" && ! "$TYPE" =~ ^CRQ-[0-9]+$ ]]; then
  if ! echo "$SCOPE" | grep -E "^[a-z0-9]+(-[a-z0-9]+)*$"; then
    echo "Error: Commit scope must be in kebab-case." >&2
    exit 1
  fi
fi

# Validate subject case (simplified for now, just checking for leading uppercase or lowercase)
# This is a basic check, more sophisticated checks would involve iterating words.
FIRST_CHAR_SUBJECT=$(echo "$SUBJECT" | head -c 1)
if [[ ! "$FIRST_CHAR_SUBJECT" =~ [a-zA-Z] ]]; then
  echo "Error: Commit subject must start with a letter." >&2
  exit 1
fi

# Check for blank line between header and body
# BODY starts from the second line
BODY=$(echo "$COMMIT_MSG" | tail -n +2)

# If there's a body, ensure there's a blank line after the header
if [[ -n "$BODY" ]]; then
  SECOND_LINE=$(echo "$COMMIT_MSG" | sed -n 2p)
  if [[ -n "$SECOND_LINE" ]]; then
    echo "Error: There must be a blank line between the commit header and body." >&2
    exit 1
  fi
fi

# All checks passed
exit 0
