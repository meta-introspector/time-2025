#!/usr/bin/env bash

# This script installs the custom commit-msg hook.
# Usage: ./install_hook_script.sh [DRY_RUN]

DRY_RUN="$1"

# Derive HOOKS_DIR from the .git file content
GIT_DIR_LINE=$(grep "gitdir:" < .git)
RELATIVE_GIT_DIR=$(echo "$GIT_DIR_LINE" | cut -d' ' -f2)
HOOK_VAR=$(readlink -f "$RELATIVE_GIT_DIR")
HOOKS_DIR="${HOOK_VAR}/hooks"

echo "--- Installing custom commit-msg hook ---"

if [ "$DRY_RUN" = "true" ]; then
	echo "[DRY RUN] Would create directory: $HOOKS_DIR"
	echo "[DRY RUN] Would copy custom_commit_msg_hook.sh to $HOOKS_DIR/commit-msg"
	echo "[DRY RUN] Would make $HOOKS_DIR/commit-msg executable"
else
	mkdir -p "$HOOKS_DIR"
	cp custom_commit_msg_hook.sh "$HOOKS_DIR/commit-msg"
	chmod +x "$HOOKS_DIR/commit-msg"
fi

echo "--- Custom commit-msg hook installed successfully at $HOOKS_DIR/commit-msg ---"
echo ""
echo "--- You can now try your commit again. ---"
