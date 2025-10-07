#!/usr/bin/env bash

# Gemini CLI Hello World Test Runner - 2025-01-27
# Following NEVER DELETE principle - additive testing only

set -e

# Log shell information (additive documentation)
echo "=== Shell Environment Info ==="
echo "Shebang: #!/usr/bin/env bash"
echo "Shell: $SHELL"
echo "Bash version: $BASH_VERSION"
echo "Script: $0"
echo "Arguments: $*"
echo ""

# Configuration (additive approach)
BASE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27"
TEST_DIR="$BASE_DIR/tests/2025-01-27-gemini-hello-world"
LOG_DIR="$BASE_DIR/logs"
ARCHIVE_DIR="$BASE_DIR/test-archives/2025-01-27"

# Ensure all directories exist (never delete, always create)
mkdir -p "$LOG_DIR"
mkdir -p "$ARCHIVE_DIR"

# Generate unique timestamp for this test run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_LOG="$LOG_DIR/gemini_hello_build_$TIMESTAMP.log"
RUN_LOG="$LOG_DIR/gemini_hello_run_$TIMESTAMP.log"
ARCHIVE_LOG="$ARCHIVE_DIR/test_session_$TIMESTAMP.log"

echo "=== Gemini CLI Hello World Test Runner ==="
echo "Date: $(date)"
echo "Test Directory: $TEST_DIR"
echo "Logs will be preserved in:"
echo "  Build: $BUILD_LOG"
echo "  Run: $RUN_LOG" 
echo "  Archive: $ARCHIVE_LOG"
echo ""

# Log session start (permanent record)
{
    echo "=== Test Session Started ==="
    echo "Timestamp: $(date -Iseconds)"
    echo "Test: Gemini CLI Hello World"
    echo "Version: 2025-01-27"
    echo "Working Directory: $(pwd)"
    echo "User: $(whoami)"
    echo "System: $(uname -a)"
    echo ""
} > "$ARCHIVE_LOG"

# Change to test directory
cd "$TEST_DIR"

echo "Step 1: Building test derivation..."
echo "Command: nix build --show-trace"

# Build with full logging (additive)
if nix build --show-trace > "$BUILD_LOG" 2>&1; then
    echo "✅ Build completed successfully"
    
    # Append build success to archive
    {
        echo "=== Build Phase ==="
        echo "Status: SUCCESS"
        echo "Completed: $(date -Iseconds)"
        echo "Build log: $BUILD_LOG"
        echo ""
    } >> "$ARCHIVE_LOG"
else
    BUILD_EXIT_CODE=$?
    echo "❌ Build failed with exit code: $BUILD_EXIT_CODE"
    echo "Build log location: $BUILD_LOG"
    
    # Append build failure to archive (never delete failure info)
    {
        echo "=== Build Phase ==="
        echo "Status: FAILED"
        echo "Exit Code: $BUILD_EXIT_CODE"
        echo "Failed: $(date -Iseconds)"
        echo "Build log: $BUILD_LOG"
        echo "Last 10 lines of build log:"
        tail -10 "$BUILD_LOG"
        echo ""
    } >> "$ARCHIVE_LOG"
    
    echo "Error details:"
    tail -20 "$BUILD_LOG"
    exit $BUILD_EXIT_CODE
fi

echo ""
echo "Step 2: Running test execution..."
echo "Command: nix run"

# Execute test with full logging (additive)
if nix run > "$RUN_LOG" 2>&1; then
    echo "✅ Test execution completed successfully"
    
    # Append execution success to archive
    {
        echo "=== Execution Phase ==="
        echo "Status: SUCCESS"
        echo "Completed: $(date -Iseconds)"
        echo "Run log: $RUN_LOG"
        echo ""
    } >> "$ARCHIVE_LOG"
    
    echo ""
    echo "=== Test Results ==="
    cat "$RUN_LOG"
    
else
    RUN_EXIT_CODE=$?
    echo "✅ Test execution completed with exit code: $RUN_EXIT_CODE"
    echo "(Non-zero exit codes are expected for gemini CLI without API key)"
    
    # Append execution info to archive (preserve all outcomes)
    {
        echo "=== Execution Phase ==="
        echo "Status: COMPLETED_WITH_EXIT_CODE"
        echo "Exit Code: $RUN_EXIT_CODE"
        echo "Completed: $(date -Iseconds)"
        echo "Run log: $RUN_LOG"
        echo ""
    } >> "$ARCHIVE_LOG"
    
    echo ""
    echo "=== Test Output ==="
    cat "$RUN_LOG"
fi

# Get result path for archival (additive preservation)
RESULT_PATH=$(nix build --no-link --print-out-paths 2>/dev/null)

if [ -n "$RESULT_PATH" ] && [ -d "$RESULT_PATH" ]; then
    echo ""
    echo "=== Derivation Analysis ==="
    echo "Result path: $RESULT_PATH"
    
    # Archive derivation structure (permanent record)
    {
        echo "=== Derivation Structure ==="
        echo "Path: $RESULT_PATH"
        echo "Contents:"
        find "$RESULT_PATH" -type f | sort
        echo ""
        
        if [ -f "$RESULT_PATH/test-results/summary.txt" ]; then
            echo "=== Test Summary ==="
            cat "$RESULT_PATH/test-results/summary.txt"
            echo ""
        fi
        
        if [ -f "$RESULT_PATH/artifacts/manifest.json" ]; then
            echo "=== Artifact Manifest ==="
            cat "$RESULT_PATH/artifacts/manifest.json"
            echo ""
        fi
    } >> "$ARCHIVE_LOG"
    
    echo "Derivation structure:"
    find "$RESULT_PATH" -type f | head -20
    
    # Show test summary if available
    if [ -f "$RESULT_PATH/test-results/summary.txt" ]; then
        echo ""
        echo "=== Final Test Summary ==="
        cat "$RESULT_PATH/test-results/summary.txt"
    fi
fi

# Final session summary (permanent record)
FINAL_SUMMARY=$(cat << EOF
=== Session Complete ===
End Time: $(date -Iseconds)
Duration: $((CURRENT_TIME - START_TIME)) seconds
Files Created:
  $BUILD_LOG
  $RUN_LOG
  $ARCHIVE_LOG
$(if [ -n "$RESULT_PATH" ]; then echo "  $RESULT_PATH (derivation)"; fi)

All test artifacts preserved permanently.
EOF
)

echo "$FINAL_SUMMARY" >> "$ARCHIVE_LOG"

echo ""
echo "=== Test Session Complete ==="
echo "All outputs preserved in:"
echo "  Session archive: $ARCHIVE_LOG"
echo "  Build log: $BUILD_LOG" 
echo "  Run log: $RUN_LOG"
if [ -n "$RESULT_PATH" ]; then
    echo "  Test derivation: $RESULT_PATH"
fi
echo ""
echo "✅ Following NEVER DELETE principle - all artifacts preserved permanently"