#!/usr/bin/env bash
# Script to inspect Nix build results for bundle/gemini.js
# Documentation: This script provides detailed analysis of Nix builds and bundle locations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_GEMINI_DIR="$HOME/pick-up-nix2/vendor/external/gemini-cli"
LOGS_DIR="$PROJECT_DIR/logs"

# Ensure logs directory exists
mkdir -p "$LOGS_DIR"

echo "=== Nix Gemini Bundle Inspector ==="
echo "Timestamp: $(date -Iseconds)"
echo "Script: $0"
echo "Project Dir: $PROJECT_DIR"
echo "Vendor Dir: $VENDOR_GEMINI_DIR"
echo ""

# Function to check if directory exists
check_directory() {
    local dir="$1"
    local desc="$2"
    
    if [ -d "$dir" ]; then
        echo "✓ $desc exists: $dir"
        return 0
    else
        echo "✗ $desc missing: $dir"
        return 1
    fi
}

# Function to check if file exists and get info
check_file() {
    local file="$1"
    local desc="$2"
    
    if [ -f "$file" ]; then
        local size
        size=$(stat -c%s "$file" 2>/dev/null || echo "unknown")
        local readable_size
        readable_size=$(numfmt --to=iec "$size" 2>/dev/null || echo "$size bytes")
        echo "✓ $desc found: $file ($readable_size)"
        return 0
    else
        echo "✗ $desc missing: $file"
        return 1
    fi
}

# Function to inspect Nix result
inspect_nix_result() {
    local build_dir="$1"
    local desc="$2"
    
    echo "--- Inspecting $desc ---"
    
    if ! check_directory "$build_dir" "$desc directory"; then
        return 1
    fi
    
    cd "$build_dir"
    
    # Check for Nix result symlink
    if [ -L result ]; then
        local result_path
        result_path=$(readlink result)
        echo "✓ Nix result symlink: $result_path"
        
        # Look for bundle directory in result
        if [ -d "result/bundle" ]; then
            echo "✓ Bundle directory found in result"
            find result/bundle -maxdepth 1 -ls | head -10
        else
            echo "✗ No bundle directory in result"
            echo "Result contents:"
            find result -maxdepth 1 -ls | head -10
        fi
        
        # Search for any gemini.js files
        echo "Searching for gemini.js files in result..."
        find result -name "gemini.js" -type f 2>/dev/null | while read -r gemini_file; do
            check_file "$gemini_file" "gemini.js in result"
        done || echo "No gemini.js files found in result"
        
    else
        echo "✗ No Nix result symlink found"
    fi
    
    # Check source bundle directory
    if check_file "$build_dir/bundle/gemini.js" "Source bundle/gemini.js"; then
        echo "Source bundle analysis:"
        ls -la "$build_dir/bundle/"
    fi
}

# Main inspection process
echo "=== Step 1: Basic Directory Checks ==="
check_directory "$VENDOR_GEMINI_DIR" "Vendor Gemini CLI"
check_directory "$VENDOR_GEMINI_DIR/bundle" "Vendor bundle"
check_file "$VENDOR_GEMINI_DIR/bundle/gemini.js" "Vendor gemini.js"
check_file "$VENDOR_GEMINI_DIR/flake.nix" "Vendor flake.nix"

echo ""
echo "=== Step 2: Nix Result Inspection ==="
inspect_nix_result "$VENDOR_GEMINI_DIR" "Vendor Gemini CLI"

echo ""
echo "=== Step 3: Flake Information ==="
cd "$VENDOR_GEMINI_DIR"
echo "Flake outputs:"
nix flake show 2>&1 | head -20

echo ""
echo "=== Step 4: Build Status Check ==="
if [ -f "$LOGS_DIR/vendor-gemini-build.log" ]; then
    echo "Build log found. Recent entries:"
    tail -10 "$LOGS_DIR/vendor-gemini-build.log"
else
    echo "No build log found. Run 'make build-vendor-gemini' first."
fi

echo ""
echo "=== Inspection Complete ==="
echo "For detailed build, run: make build-vendor-gemini"
echo "Log location: $LOGS_DIR/"