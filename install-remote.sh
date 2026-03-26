#!/usr/bin/env bash
set -euo pipefail

# ai-writing-toolkit remote installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/mcarruth/ai-writing-toolkit/main/install-remote.sh)

INSTALL_DIR="$HOME/.ai-writing-toolkit"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ai-writing-toolkit installer       ║"
echo "╚══════════════════════════════════════╝"
echo ""

if ! command -v git &>/dev/null; then
    echo "✗ git not found. Install git first." >&2
    exit 1
fi

if [[ -d "$INSTALL_DIR" ]]; then
    echo "  Updating existing installation..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo "  Cloning repository..."
    git clone https://github.com/mcarruth/ai-writing-toolkit.git "$INSTALL_DIR"
fi

echo ""
exec bash "$INSTALL_DIR/install.sh"
