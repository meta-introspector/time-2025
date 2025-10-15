#!/usr/bin/env bash

# This script transforms LLM call descriptions into structured "LLM Tasks" for a scheduler.

LLM_CALL_VECTOR_JSON="$1"
export KEY_OBJECT_JSON="$2"
MODEL_ROUTER_JSON="$3"
FLAKE_CONTENT="$4" # Assuming flake content is passed as a 4th argument

# Ensure jq is available
if ! command -v jq &> /dev/null
then
    echo "Error: jq is not installed. Please add it to buildInputs." >&2
    exit 1
fi

# Start the JSON output array
echo "["

first_call=true
# Iterate through each LLM call description in the vector
echo "$LLM_CALL_VECTOR_JSON" | jq -c '.calls[]' | while read -r call_desc; do
    if [ "$first_call" = false ]; then
        echo ","
    fi
    first_call=false

    prompt=$(echo "$call_desc" | jq -r '.prompt')
    checksum=$(echo "$call_desc" | jq -r '.checksum')
    expectedOutputFormat=$(echo "$call_desc" | jq -r '.expectedOutputFormat')

    # Construct the LLM Task object
    cat <<EOF
{
  "taskDescription": "$prompt",
  "modelDescription": {
    "name": "default-model",
    "config": $MODEL_ROUTER_JSON
  },
  "inputList": [
    {
      "type": "flakeContent",
      "checksum": "$checksum",
      "content": "$FLAKE_CONTENT"
    }
  ],
  "splitterFunction": {
    "type": "nixFunction",
    "name": "defaultSplitter",
    "config": {}
  },
  "metadata": {
    "originalChecksum": "$checksum",
    "expectedOutputFormat": "$expectedOutputFormat"
  },
  "cost": {
    "timeEstimate": "30s",
    "tokenEstimate": 2000,
    "computeEstimate": "0.02 CPU-hours"
  },
  "benefit": {
    "qualityScore": "high",
    "reproducibilityScore": "medium",
    "impactScore": "low"
  }
}
EOF
done

# End the JSON output array
echo "]"
