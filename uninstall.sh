#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$REPO_ROOT/bin"

echo "AI Writing Toolkit — Uninstaller"
echo "================================="
echo ""

# Remove PATH entry from shell config
SHELL_RC=""
if [[ "${SHELL:-}" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "${SHELL:-}" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [[ -n "$SHELL_RC" ]] && grep -q "$BIN_DIR" "$SHELL_RC" 2>/dev/null; then
    python3 -c "
import re
content = open('$SHELL_RC').read()
content = re.sub(r'\n# AI Writing Toolkit\nexport PATH=\"[^\"]*ai-writing-toolkit[^\"]*\"[^\n]*\n', '\n', content)
open('$SHELL_RC', 'w').write(content)
"
    echo "✓ Removed PATH entry from $(basename "$SHELL_RC")"
else
    echo "✓ No PATH entry found in shell config"
fi

# Remove config
if [[ -d "$HOME/.ait" ]]; then
    rm -rf "$HOME/.ait"
    echo "✓ Removed ~/.ait"
else
    echo "✓ No config directory found"
fi

echo ""
echo "================================="
echo "Uninstall complete."
echo ""
echo "Run 'source $SHELL_RC' or open a new terminal to update your PATH."
echo ""
echo "The repository at $REPO_ROOT was not removed."
echo "To remove it: rm -rf \"$REPO_ROOT\""
echo ""
