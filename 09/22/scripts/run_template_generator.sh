#!/usr/bin/env bash

# Wrapper script to run template_generator_bin via Nix.
# Usage: ./scripts/run_template_generator.sh <template-type> <crq-number> <description>

TEMPLATE_TYPE="$1"
CRQ_NUMBER="$2"
DESCRIPTION="$3"

if [ -z "$TEMPLATE_TYPE" ] || [ -z "$CRQ_NUMBER" ] || [ -z "$DESCRIPTION" ]; then
    echo "Usage: $0 <template-type> <crq-number> <description>"
    exit 1
fi

#nix run .#template-generator-bin -- generate
nix run "github:meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify-workflow#template-generator-bin -- generate --template-type ${TEMPLATE_TYPE} --crq-number ${CRQ_NUMBER} --description ${DESCRIPTION}"
