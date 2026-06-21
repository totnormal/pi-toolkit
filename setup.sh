#!/bin/bash
# setup.sh — Install pi-toolkit into your pi environment.
# Idempotent: safe to re-run.
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_AGENT="$HOME/.pi/agent"
PI_BIN="$HOME/.pi/bin/pi"
PATCHES_DIR="$PI_AGENT/patches"

echo "==> Installing pi-toolkit from $TOOLKIT_DIR"

# --- Patches ---
echo "==> Installing patches into $PATCHES_DIR"
mkdir -p "$PATCHES_DIR"

for patch in "$TOOLKIT_DIR"/patches/*.sh; do
    [ -f "$patch" ] || continue
    name="$(basename "$patch")"
    dest="$PATCHES_DIR/$name"
    # Always update the patch file
    cp "$patch" "$dest"
    chmod +x "$dest"
    echo "    installed: patches/$name"
done

# --- Register patches in launcher (idempotent) ---
MARKER="# pi-toolkit managed patches below"

if ! grep -qF "$MARKER" "$PI_BIN" 2>/dev/null; then
    echo "" >> "$PI_BIN"
    echo "$MARKER" >> "$PI_BIN"
fi

# Add each patch line if missing
for patch in "$TOOLKIT_DIR"/patches/*.sh; do
    [ -f "$patch" ] || continue
    name="$(basename "$patch")"
    line="\"\$HOME/.pi/agent/patches/$name\" 2>/dev/null || true"
    if ! grep -qF "$name" "$PI_BIN" 2>/dev/null; then
        echo "$line" >> "$PI_BIN"
        echo "    registered in launcher: $name"
    fi
done

echo ""
echo "==> Done. Patches will auto-apply on next pi launch."
echo "==> Re-run this script after pulling updates: cd $TOOLKIT_DIR && ./setup.sh"
