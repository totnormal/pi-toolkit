# pi-toolkit

Custom patches, models, extensions, and tools for [pi-coding-agent](https://github.com/earendil-works/pi).

Persists across `bun update` / `npm update` because the launcher re-applies
patches on every session start.

## What's here

| Path | Purpose |
|---|---|
| `patches/` | Idempotent shell scripts that patch `node_modules` on launch |
| `setup.sh` | Installs/updates patches and registers them in your pi launcher |
| `extensions/` | (future) custom pi extensions |
| `models.json` | (future) model overrides for your providers |
| `skills/` | (future) custom skills |

## Current patches

- **`fix-openrouter-cost.sh`** — Uses OpenRouter's actual reported USD cost
  instead of pi's static per-token estimate. Fixes $0.000 for custom OpenRouter
  models and aligns built-in models with what OpenRouter actually charges.
  ([upstream PR](https://github.com/earendil-works/pi/pull/5950))

## Setup

```bash
git clone https://github.com/totnormal/pi-toolkit.git ~/.pi/agent/toolkit
cd ~/.pi/agent/toolkit
./setup.sh
```

Re-run `./setup.sh` after pulling updates.

## How it works

Your pi launcher (`~/.pi/bin/pi`) runs every script in `~/.pi/agent/patches/`
on startup. Each script:
1. Checks a marker file — skips if already applied
2. Patches the target `node_modules` dist file with `sed`
3. Creates the marker

This means npm/bun updates don't wipe your fixes; they get re-applied next launch.

## License

MIT
