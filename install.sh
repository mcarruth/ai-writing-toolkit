#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$REPO_ROOT/bin"

echo "AI Writing Toolkit — Installer"
echo "=============================="
echo ""

# Detect available backends
FOUND_BACKEND=""
if command -v kiro-cli &>/dev/null; then
    echo "✓ kiro-cli found: $(which kiro-cli)"
    FOUND_BACKEND="kiro"
fi
if command -v claude &>/dev/null; then
    echo "✓ claude found: $(which claude)"
    [[ -z "$FOUND_BACKEND" ]] && FOUND_BACKEND="claude-code"
fi
if [[ -z "$FOUND_BACKEND" ]]; then
    echo "⚠ No supported LLM CLI found."
    echo "  Install one of:"
    echo "    npm install -g @anthropic-ai/claude-code"
    echo "    npm install -g @amazon/kiro-cli"
    echo "  Or configure a custom backend after install:"
    echo "    ait config backend custom"
    echo "    ait config custom-command 'your-cli --flags'"
    echo ""
    FOUND_BACKEND="kiro"
fi

echo ""

# Make scripts executable
chmod +x "$BIN_DIR"/ait
echo "✓ Scripts are executable"

# Add bin/ to PATH
echo ""
echo "Configuring PATH..."

SHELL_RC=""
if [[ "${SHELL:-}" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "${SHELL:-}" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

PATH_ENTRY="export PATH=\"$BIN_DIR:\$PATH\"  # ai-writing-toolkit"

if [[ -n "$SHELL_RC" ]]; then
    if grep -q "$BIN_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "✓ PATH already configured in $(basename "$SHELL_RC")"
    else
        echo "" >> "$SHELL_RC"
        echo "# AI Writing Toolkit" >> "$SHELL_RC"
        echo "$PATH_ENTRY" >> "$SHELL_RC"
        echo "✓ Added to $SHELL_RC"
        echo ""
        echo "  → Run this to activate in your current terminal:"
        echo "    source $SHELL_RC"
    fi
else
    echo "Could not detect shell config file. Add this line manually:"
    echo ""
    echo "  $PATH_ENTRY"
fi

echo ""
echo "Configuring defaults..."

AIT_CONFIG_DIR="$HOME/.ait"
AIT_CONFIG_FILE="$AIT_CONFIG_DIR/config"
mkdir -p "$AIT_CONFIG_DIR"
touch "$AIT_CONFIG_FILE"

# Backend
EXISTING_BACKEND=$(grep '^backend=' "$AIT_CONFIG_FILE" 2>/dev/null | cut -d= -f2-)
if [[ -z "$EXISTING_BACKEND" ]]; then
    echo "backend=${FOUND_BACKEND}" >> "$AIT_CONFIG_FILE"
    echo "✓ Backend set to $FOUND_BACKEND"
else
    echo "✓ Backend already configured: $EXISTING_BACKEND"
fi

# Output directory
echo ""
echo "  When set, ait auto-saves output organized by command type."
echo "  Leave blank to output to stdout by default."
echo ""

EXISTING_DIR=$(grep '^output_dir=' "$AIT_CONFIG_FILE" 2>/dev/null | cut -d= -f2-)

read -rp "  Output directory${EXISTING_DIR:+ [$EXISTING_DIR]}: " INPUT_DIR
OUTPUT_DIR="${INPUT_DIR:-$EXISTING_DIR}"

if grep -q '^output_dir=' "$AIT_CONFIG_FILE" 2>/dev/null; then
    sed -i '' "s|^output_dir=.*|output_dir=${OUTPUT_DIR}|" "$AIT_CONFIG_FILE"
else
    echo "output_dir=${OUTPUT_DIR}" >> "$AIT_CONFIG_FILE"
fi

if [[ -n "$OUTPUT_DIR" ]]; then
    echo "✓ Output directory set to $OUTPUT_DIR"
else
    echo "✓ No output directory set (stdout mode)"
fi

echo ""
echo "=============================="
echo "Installation complete."
echo ""
echo "Open a new terminal (or source your shell config), then try:"
echo ""
echo "  ait --help"
echo ""
