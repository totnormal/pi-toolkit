#!/bin/bash
# fix-openrouter-cost.sh — Patch pi-ai to use OpenRouter's actual reported cost.
#
# OpenRouter returns usage.cost with the real USD amount. pi was ignoring it
# and using only its static per-token estimate, which meant:
#   - Custom OpenRouter models → $0.000 (cost defaults to all zeros)
#   - Built-in models → pi's estimate, not what OpenRouter actually charges
#
# This patch adds a fallback: after calculateCost(), if rawUsage.cost is
# present and positive, use it as the authoritative total.
#
# Idempotent: checks both a marker AND the actual file content, so it
# self-heals if node_modules gets updated.

MARKER="$HOME/.pi/agent/.patch-openrouter-cost-applied"
NEEDS_PATCH=0

# Check marker
if [ -f "$MARKER" ]; then
    # Marker exists — verify patches are actually present (self-heal if npm update wiped them)
    TARGET1="/Users/andreitarnovski/.bun/install/global/node_modules/@earendil-works/pi-ai/dist/providers/openai-completions.js"
    TARGET2="/Users/andreitarnovski/.bun/install/global/node_modules/@earendil-works/pi-ai/dist/providers/images/openrouter.js"

    if [ -f "$TARGET1" ] && ! grep -q 'OpenRouter returns the actual USD cost in usage.cost' "$TARGET1" 2>/dev/null; then
        NEEDS_PATCH=1
    fi
    if [ -f "$TARGET2" ] && ! grep -q 'OpenRouter returns the actual USD cost in usage.cost' "$TARGET2" 2>/dev/null; then
        NEEDS_PATCH=1
    fi

    if [ "$NEEDS_PATCH" -eq 0 ]; then
        exit 0
    fi
    # Patch was wiped by update — remove stale marker so we re-apply below
    rm -f "$MARKER"
fi

PATCHED=0

# 1. openai-completions.js — main chat path used by OpenRouter
TARGET1="/Users/andreitarnovski/.bun/install/global/node_modules/@earendil-works/pi-ai/dist/providers/openai-completions.js"
if [ -f "$TARGET1" ]; then
    if ! grep -q 'OpenRouter returns the actual USD cost in usage.cost' "$TARGET1" 2>/dev/null; then
        sed -i '' '/^    calculateCost(model, usage);$/a\
    // OpenRouter returns the actual USD cost in usage.cost. Use it when available\
    // instead of (or in addition to) the static per-token estimate.\
    if (rawUsage.cost != null && rawUsage.cost > 0) {\
        usage.cost.total = rawUsage.cost;\
    }' "$TARGET1" 2>/dev/null && PATCHED=$((PATCHED + 1))
    fi
fi

# 2. images/openrouter.js — image generation via OpenRouter
TARGET2="/Users/andreitarnovski/.bun/install/global/node_modules/@earendil-works/pi-ai/dist/providers/images/openrouter.js"
if [ -f "$TARGET2" ]; then
    if ! grep -q 'OpenRouter returns the actual USD cost in usage.cost' "$TARGET2" 2>/dev/null; then
        sed -i '' '/^    usage.cost.total = usage.cost.input + usage.cost.output + usage.cost.cacheRead + usage.cost.cacheWrite;$/a\
    // OpenRouter returns the actual USD cost in usage.cost. Use it when available.\
    if (rawUsage.cost != null && rawUsage.cost > 0) {\
        usage.cost.total = rawUsage.cost;\
    }' "$TARGET2" 2>/dev/null && PATCHED=$((PATCHED + 1))
    fi
fi

touch "$MARKER"
exit 0
