#!/bin/bash

# Test script for Gemini CLI Hello World test
# This script runs the test and displays results

set -e

TEST_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/gemini_hello_world_test"
LOG_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/logs"

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Generate timestamp for log files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_LOG="$LOG_DIR/gemini_hello_build_$TIMESTAMP.log"
RUN_LOG="$LOG_DIR/gemini_hello_run_$TIMESTAMP.log"

echo "=== Gemini CLI Hello World Test ==="
echo "Test directory: $TEST_DIR"
echo "Build log: $BUILD_LOG"
echo "Run log: $RUN_LOG"
echo ""

cd "$TEST_DIR"

echo "Step 1: Building test derivation..."
if nix build --show-trace > "$BUILD_LOG" 2>&1; then
    echo "✅ Build completed successfully"
else
    echo "❌ Build failed - check $BUILD_LOG for details"
    echo "Last 20 lines of build log:"
    tail -20 "$BUILD_LOG"
    exit 1
fi

echo ""
echo "Step 2: Running test..."
if nix run > "$RUN_LOG" 2>&1; then
    echo "✅ Test execution completed"
    echo ""
    echo "=== Test Results ==="
    cat "$RUN_LOG"
else
    echo "❌ Test execution failed - check $RUN_LOG for details"
    echo "Test output:"
    cat "$RUN_LOG"
    exit 1
fi

echo ""
echo "=== Test Complete ==="
echo "Full logs available at:"
echo "  Build: $BUILD_LOG"
echo "  Run: $RUN_LOG"

# Check if result directory exists and show contents
RESULT_PATH=$(nix build --no-link --print-out-paths 2>/dev/null)
if [ -n "$RESULT_PATH" ] && [ -d "$RESULT_PATH" ]; then
    echo ""
    echo "=== Derivation Contents ==="
    echo "Result path: $RESULT_PATH"
    echo "Structure:"
    find "$RESULT_PATH" -type f | head -20
    
    if [ -f "$RESULT_PATH/test-results/summary.txt" ]; then
        echo ""
        echo "=== Test Summary ==="
        cat "$RESULT_PATH/test-results/summary.txt"
    fi
fi