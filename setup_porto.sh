#!/bin/bash

# setup_porto.sh
# Automates the installation of dependencies for PORTO and Leo.

set -e

echo "------------------------------------------------"
echo "Starting PORTO & Leo Environment Setup..."
echo "------------------------------------------------"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. System Dependencies
echo "[1/5] Installing system dependencies (sudo may be required)..."
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev git curl erlang

# 2. Rust Environment
echo "[2/5] Setting up Rust environment..."
if command -v rustup >/dev/null 2>&1; then
    rustup update
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# 3. Erlang Build Tooling (Rebar3)
echo "[3/5] Setting up Rebar3..."
# Verify if rebar3 exists AND if it actually works (checks for BEAM compatibility)
if ! rebar3 --version >/dev/null 2>&1; then
    echo "Rebar3 not found or incompatible with current OTP. Bootstrapping from source..."
    
    # Ensure a clean slate by removing any broken version in the local bin
    if [ -f "$HOME/.local/bin/rebar3" ]; then
        rm "$HOME/.local/bin/rebar3"
    fi
    
    mkdir -p "$HOME/.local/bin"
    TMP_DIR=$(mktemp -d)
    (
        cd "$TMP_DIR"
        git clone --depth 1 https://github.com/erlang/rebar3.git
        cd rebar3
        ./bootstrap
        mv rebar3 "$HOME/.local/bin/rebar3"
    )
    rm -rf "$TMP_DIR"
    
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q ".local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
else
    echo "Rebar3 is already installed and compatible."
fi

# 4. Leo CLI Installation
echo "[4/5] Installing Leo CLI from source..."
# Try to find 'leo' as a sibling of the PORTO directory first, then fallback to $HOME/leo
LEO_DIR="$SCRIPT_DIR/../leo"

if [ ! -d "$LEO_DIR" ]; then
    LEO_DIR="$HOME/leo"
fi

if [ -d "$LEO_DIR" ]; then
    echo "Found Leo at: $LEO_DIR"
    (
        cd "$LEO_DIR"
        # Essential fix: target the correct crate, not the virtual manifest
        cargo install --path crates/leo
    )
else
    echo "Error: Leo source directory not found at $LEO_DIR"
    exit 1
fi

# 5. PORTO Compilation
echo "[5/5] Compiling PORTO core..."
cd "$SCRIPT_DIR/core"
rebar3 compile

echo "------------------------------------------------"
echo "Setup Complete!"
echo "Please restart your terminal or run: source ~/.bashrc"
echo "------------------------------------------------"
