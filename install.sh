#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$REPO_ROOT/bin"
MARKER="# ai-writing-toolkit"

echo "AI Writing Toolkit — Installer"
echo "=============================="
echo ""

# Make ait executable
chmod +x "$BIN_DIR/ait"
echo "✓ bin/ait is executable"
echo ""

# Detect shell RC by file existence, not $SHELL
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

PATH_ENTRY="export PATH=\"$BIN_DIR:\$PATH\""

if [[ -n "$SHELL_RC" ]]; then
    if grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
        echo "✓ Already configured in $(basename "$SHELL_RC")"
    else
        {
            printf '\n'
            printf '%s\n' "$MARKER"
            printf '%s\n' "$PATH_ENTRY"
        } >> "$SHELL_RC"
        echo "✓ Added to $SHELL_RC"
    fi
    echo ""
    echo "  Activate now: source $SHELL_RC"
else
    echo "Could not find a shell config file. Add this line manually:"
    echo ""
    echo "  $MARKER"
    echo "  $PATH_ENTRY"
fi

echo ""

# Detect and configure backend
echo "Detecting LLM backend..."
FOUND_BACKEND=""
if command -v claude &>/dev/null; then
    FOUND_BACKEND="claude-code"
    echo "✓ claude found"
elif command -v kiro-cli &>/dev/null; then
    FOUND_BACKEND="kiro"
    echo "✓ kiro-cli found"
fi

if [[ -z "$FOUND_BACKEND" ]]; then
    echo ""
    echo "  No supported LLM CLI found. Install one before using ait:"
    echo "    npm install -g @anthropic-ai/claude-code"
    echo "    curl -fsSL https://cli.kiro.dev/install | bash"
    echo ""
    echo "  Then run: ait config backend <claude-code|kiro>"
else
    mkdir -p "$HOME/.ait"
    touch "$HOME/.ait/config"
    if grep -q "^backend=" "$HOME/.ait/config" 2>/dev/null; then
        echo "✓ Backend already configured"
    else
        echo "backend=${FOUND_BACKEND}" >> "$HOME/.ait/config"
        echo "✓ Backend set to ${FOUND_BACKEND}"
    fi
fi

echo ""
echo "=============================="
echo "Done. Run 'ait config' to review or change settings."
echo ""
