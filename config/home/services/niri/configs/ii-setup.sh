#!/usr/bin/env bash
# ii-setup.sh - Initialize Python virtual environment for iNiR/illogical-impulse
# This script sets up the materialyoucolor library needed for theme generation

set -e

VENV_DIR="${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-$HOME/.local/state/quickshell/.venv}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"

# Create necessary directories
mkdir -p "$STATE_DIR/user/generated"
mkdir -p "$CACHE_DIR/matugen"

# Create venv if it doesn't exist or is broken
if [ ! -f "$VENV_DIR/bin/python" ]; then
    echo "[ii-setup] Creating Python virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

# Check if materialyoucolor is installed
if ! "$VENV_DIR/bin/python" -c "import materialyoucolor" 2>/dev/null; then
    echo "[ii-setup] Installing materialyoucolor and dependencies..."
    "$VENV_DIR/bin/pip" install --quiet materialyoucolor pillow
fi

echo "[ii-setup] Python environment ready"
