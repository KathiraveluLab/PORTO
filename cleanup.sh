#!/bin/bash

# cleanup.sh
# Performs a radical cleanup of build artifacts and persistence data for PORTO.

set -e

echo "------------------------------------------------"
echo "PORTO Cleanup & Reset Utility"
echo "------------------------------------------------"
echo "This script will PERMANENTLY DELETE:"
echo "1. Erlang build artifacts (core/_build)"
echo "2. Local orchestration state (core/data)"
echo "3. Leo circuit build artifacts (build/ and outputs/)"
echo "4. Benchmark kernel binaries (circuits/heavy_workload)"
echo ""
read -p "Are you sure you want to proceed? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "[1/5] Cleaning Erlang build artifacts..."
rm -rf "$SCRIPT_DIR/core/_build"

echo "[2/5] Resetting local orchestration state (Mnesia)..."
rm -rf "$SCRIPT_DIR/core/data"

echo "[3/5] Cleaning Leo circuit artifacts..."
# Find and remove all Leo build/ and outputs/ directories recursively
find "$SCRIPT_DIR" -type d \( -name "build" -o -name "outputs" \) -path "*/circuits/*" -exec rm -rf {} +

echo "[4/5] Removing benchmark kernel binaries..."
rm -f "$SCRIPT_DIR/circuits/heavy_workload"

echo "[5/5] Performing ASCII-Safety Scan..."
# Search for the toolchain-breaking em-dash in core, circuits, and examples
BAD_CHARS=$(grep -r "—" "$SCRIPT_DIR/core" "$SCRIPT_DIR/circuits" "$SCRIPT_DIR/examples" 2>/dev/null || true)

if [ -n "$BAD_CHARS" ]; then
    echo "WARNING: Non-ASCII characters (em-dashes) detected!"
    echo "These can cause rebar3 or leo to crash during compilation."
    echo "Detected at:"
    echo "$BAD_CHARS"
else
    echo "ASCII-Safety Scan: Pass (No em-dashes found)."
fi

echo ""
echo "------------------------------------------------"
echo "Cleanup Complete!"
echo "You can now run ./setup_porto.sh or rebar3 compile for a fresh start."
echo "------------------------------------------------"
