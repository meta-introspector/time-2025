#!/usr/bin/env bash

# This script manages or interacts with different LLM personas.

MUSES_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/muses.sh"

function list_personas() {
    "$MUSES_SCRIPT" --list
}

function activate_persona() {
    local muse_name="$1"
    echo "Activating persona for muse: $muse_name"
    echo "Searching documentation for persona details..."
    grep -r -i "$muse_name" /data/data/com.termux.nix/files/home/pick-up-nix2/docs/ || echo "No specific persona details found for $muse_name in docs/."
    # TODO: Implement more sophisticated persona extraction/activation logic
}

case "$1" in
    --list)
        list_personas
        ;;
    --activate)
        if [ -z "$2" ]; then
            echo "Usage: $0 --activate <muse_name>"
            exit 1
        fi
        activate_persona "$2"
        ;;
    *)
        echo "Usage: $0 [--list | --activate <muse_name>]"
        exit 1
        ;;
esac