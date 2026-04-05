#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"
MANAGED_DIR="$HOME/.ai-writing-toolkit"

# ─────────────────────────────────────────────
# Remote install bootstrap
# If not running from a proper clone (e.g. curl | bash), clone to
# ~/.ai-writing-toolkit and re-exec from there.
# ─────────────────────────────────────────────

if [[ ! -f "$REPO_ROOT/bin/ait" ]]; then
    if ! command -v git &>/dev/null; then
        echo "✗ git not found. Install git first." >&2
        exit 1
    fi
    if [[ -d "$MANAGED_DIR" ]]; then
        echo "  Updating existing installation..."
        git -C "$MANAGED_DIR" pull --ff-only
    else
        echo "  Cloning repository..."
        git clone https://github.com/mcarruth/ai-writing-toolkit.git "$MANAGED_DIR"
    fi
    exec bash "$MANAGED_DIR/install.sh"
fi

BIN_DIR="$REPO_ROOT/bin"
MARKER="# ai-writing-toolkit"
AIT_CONFIG_DIR="$HOME/.ait"

# ─────────────────────────────────────────────

# Helpers

# ─────────────────────────────────────────────

detect_shell_rc() {
if [[ -f "$HOME/.zshrc" ]]; then
echo "$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
echo "$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
echo "$HOME/.bashrc"
else
echo ""
fi
}

is_installed() {
local rc
rc="$(detect_shell_rc)"
[[ -n "$rc" ]] && grep -qF "$MARKER" "$rc" 2>/dev/null
}

do_add_to_path() {
local rc
rc="$(detect_shell_rc)"
if [[ -z "$rc" ]]; then
echo ""
echo "  Could not find a shell config file. Add this line manually:"
echo "  $MARKER"
echo "  export PATH="$BIN_DIR:$PATH""
return
fi
if grep -qF "$MARKER" "$rc" 2>/dev/null; then
echo "✓ PATH entry already present in $(basename "$rc")"
else
{
printf '\n'
printf '%s\n' "$MARKER"
printf 'export PATH="%s:$PATH"\n' "$BIN_DIR"
} >> "$rc"
echo "✓ Added to $rc"
echo "  Activate now: source $rc"
fi
}

do_remove_from_path() {
local rc
rc="$(detect_shell_rc)"
if [[ -z "$rc" ]] || ! grep -qF "$MARKER" "$rc" 2>/dev/null; then
echo "✓ No PATH entry found in shell config"
return
fi
python3 - "$rc" "$BIN_DIR" <<'PYEOF'
import sys, re
rc_file, bin_dir = sys.argv[1], sys.argv[2]
content = open(rc_file).read()

# Remove the marker line and the export PATH line that follows it

pattern = r'\n# ai-writing-toolkit\nexport PATH="[^"]*:\$PATH"\n?'
content = re.sub(pattern, '\n', content)
open(rc_file, 'w').write(content)
PYEOF
echo "✓ Removed PATH entry from $(basename "$rc")"
}

do_detect_backend() {
local found=""
if command -v claude &>/dev/null; then
found="claude-code"
echo "✓ claude found"
elif command -v kiro-cli &>/dev/null; then
found="kiro"
echo "✓ kiro-cli found"
elif command -v ollama &>/dev/null; then
found="ollama"
echo "✓ ollama found"
fi

if [[ -z "$found" ]]; then
echo ""
echo "  No supported LLM CLI found. Install one before using ait:"
echo "  npm install -g @anthropic-ai/claude-code"
echo "  curl -fsSL https://cli.kiro.dev/install | bash"
echo "  curl -fsSL https://ollama.com/install.sh | sh  (local, no account needed)"
echo ""
echo "  Then run: ait config backend <claude-code|kiro|ollama>"
else
mkdir -p "$AIT_CONFIG_DIR"
touch "$AIT_CONFIG_DIR/config"
if grep -q "^backend=" "$AIT_CONFIG_DIR/config" 2>/dev/null; then
echo "✓ Backend already configured (run 'ait config' to change)"
else
echo "backend=${found}" >> "$AIT_CONFIG_DIR/config"
echo "✓ Backend set to ${found}"
fi
fi
}

# ─────────────────────────────────────────────

# Actions

# ─────────────────────────────────────────────

action_install() {
echo ""
chmod +x "$BIN_DIR/ait"
echo "✓ bin/ait is executable"
echo ""
do_add_to_path
echo ""
echo "Detecting LLM backend…"
do_detect_backend
echo ""
echo "=============================="
echo "Done. Run 'ait config' to review or change settings."
echo ""
}

action_update() {
echo ""
echo "Pulling latest changes…"
git -C "$REPO_ROOT" pull
echo ""
chmod +x "$BIN_DIR/ait"
echo "✓ bin/ait is executable"
echo ""
echo "=============================="
echo "Update complete. Config and settings unchanged."
echo ""
}

action_reinstall() {
echo ""
echo "Removing existing PATH entry…"
do_remove_from_path
echo ""
chmod +x "$BIN_DIR/ait"
echo "✓ bin/ait is executable"
echo ""
do_add_to_path
echo ""
echo "Detecting LLM backend…"
do_detect_backend
echo ""
echo "=============================="
echo "Reinstall complete. Config preserved."
echo ""
}

action_uninstall() {
    "$BIN_DIR/ait" uninstall
}

# ─────────────────────────────────────────────

# Entry point

# ─────────────────────────────────────────────

echo "AI Writing Toolkit — Installer"
echo "=============================="

if is_installed; then
echo ""
echo "Existing installation detected."
echo ""
echo "  [1] Update (git pull, keep config)"
echo "  [2] Full reinstall (reset PATH entry, keep config)"
echo "  [3] Uninstall"
echo "  [4] Cancel"
echo ""
read -rp "Choose [1-4]: " choice
case "$choice" in
1) action_update ;;
2) action_reinstall ;;
3) action_uninstall ;;
4) echo ""; echo "Cancelled."; echo "" ;;
*) echo ""; echo "Invalid choice. Exiting."; exit 1 ;;
esac
else
action_install
fi
