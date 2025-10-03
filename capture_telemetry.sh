#!/usr/bin/env bash

# This script captures telemetry data (strace, perf) for a given command.
# Usage: ./capture_telemetry.sh "<command_to_execute>"

COMMAND_TO_EXECUTE="$1"

# Generate a unique timestamp for the output directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create a directory for the telemetry output
OUTPUT_DIR="telemetry_output/${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"

echo "--- Capturing telemetry for: ${COMMAND_TO_EXECUTE} ---"
echo "--- Output will be stored in: ${OUTPUT_DIR} ---"

# Capture strace output
STRACE_OUTPUT="${OUTPUT_DIR}/strace.log"
echo "Running strace..."
strace -o "${STRACE_OUTPUT}" -f -tt -T "${COMMAND_TO_EXECUTE}"
STRACE_EXIT_CODE=$?

# Capture perf data (if perf is available and permissions allow)
PERF_OUTPUT="${OUTPUT_DIR}/perf.data"
if command -v perf &> /dev/null && [ -w /sys/kernel/debug/tracing ]; then
    echo "Running perf record..."
    perf record -o "${PERF_OUTPUT}" "${COMMAND_TO_EXECUTE}"
    PERF_EXIT_CODE=$?
else
    echo "perf not available or insufficient permissions. Skipping perf capture."
    PERF_EXIT_CODE=0
fi

# Check exit codes and report
if [ ${STRACE_EXIT_CODE} -ne 0 ]; then
    echo "Error: strace command failed with exit code ${STRACE_EXIT_CODE}."
    exit ${STRACE_EXIT_CODE}
elif [ ${PERF_EXIT_CODE} -ne 0 ]; then
    echo "Error: perf command failed with exit code ${PERF_EXIT_CODE}."
    exit ${PERF_EXIT_CODE}
else
    echo "--- Telemetry capture complete. ---"
    exit 0
fi
