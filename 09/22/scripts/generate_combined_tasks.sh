#!/usr/bin/env bash

# This script generates new experimental tasks by combining muses and personas.

MUSES_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/muses.sh"
PERSONA_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/persona-script.sh"
CREATE_EXPERIMENTAL_TASK_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/create_experimental_task.sh"
GENERATE_TEXT_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/generate-text-to-review.sh"

if [ ! -f "$MUSES_SCRIPT" ]; then
    echo "Error: muses.sh not found at $MUSES_SCRIPT"
    exit 1
fi

if [ ! -f "$PERSONA_SCRIPT" ]; then
    echo "Error: persona-script.sh not found at $PERSONA_SCRIPT"
    exit 1
fi

if [ ! -f "$CREATE_EXPERIMENTAL_TASK_SCRIPT" ]; then
    echo "Error: create_experimental_task.sh not found at $CREATE_EXPERIMENTAL_TASK_SCRIPT"
    exit 1
fi

if [ ! -f "$GENERATE_TEXT_SCRIPT" ]; then
    echo "Error: generate-text-to-review.sh not found at $GENERATE_TEXT_SCRIPT"
    exit 1
fi

# Get lists of muses and personas
MUSES=$($MUSES_SCRIPT --list)
PERSONAS=$($PERSONA_SCRIPT --list) # Personas are now the same as muses

if [ -z "$MUSES" ]; then
    echo "No muses found. Please populate scripts/muses.sh."
    exit 1
fi

if [ -z "$PERSONAS" ]; then
    echo "No personas found. Please populate scripts/persona-script.sh."
    exit 1
fi

for MUSE in $MUSES; do
    for PERSONA in $PERSONAS; do
        TASK_TITLE="Generate and Review Text for ${MUSE} with ${PERSONA} Persona"
        echo "Creating combined task: $TASK_TITLE"

        # Create the experimental task
        "$CREATE_EXPERIMENTAL_TASK_SCRIPT" "$TASK_TITLE" "$MUSE" "" "" || {
            echo "Error: Failed to create experimental task for $MUSE and $PERSONA."
            exit 1
        }

    done
done

echo "All combined tasks generated."