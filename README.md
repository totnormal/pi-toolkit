# pi-toolkit

Your personal customization layer for [pi-coding-agent](https://github.com/earendil-works/pi).

This repo holds everything that makes pi yours: patches, custom models,
extensions, skills, launcher configs, and other overrides. Because it lives
outside `node_modules`, a `bun update` or `npm update` won't wipe your changes.

## How it works

`setup.sh` installs your customizations into `~/.pi/agent/`:
- **`patches/`** → `~/.pi/agent/patches/` (auto-applied on every pi launch)
- **`models.json`** → `~/.pi/agent/models.json` (model overrides)
- **`skills/`** → `~/.pi/agent/skills/` (custom skills)
- **`extensions/`** → `~/.pi/agent/extensions/` (custom extensions)
- **`launcher.sh`** → appends to `~/.pi/bin/pi` (env vars, PATH tweaks)

Your pi launcher (`~/.pi/bin/pi`) runs every script in `~/.pi/agent/patches/`
on startup, so patches persist and self-heal after package updates.

## Quick start

```bash
git clone https://github.com/totnormal/pi-toolkit.git ~/.pi/agent/toolkit
cd ~/.pi/agent/toolkit
./setup.sh
```

Re-run `./setup.sh` after pulling updates to refresh.

## Current patches

- **`fix-openrouter-cost.sh`** — Uses OpenRouter's actual reported USD cost
  instead of pi's static per-token estimate. Fixes $0.000 for custom OpenRouter
  models and aligns built-in models with what OpenRouter actually charges.
  ([upstream PR](https://github.com/earendil-works/pi/pull/5950))

## Repo structure

```
pi-toolkit/
├── setup.sh              # installer — copies everything into ~/.pi/agent/
├── patches/              # idempotent node_modules patch scripts
│   └── fix-openrouter-cost.sh
├── models.json           # (future) provider + model overrides
├── skills/               # (future) custom pi skills
├── extensions/           # (future) custom pi extensions
├── launcher.sh           # (future) extra launcher config
├── .env.example          # (future) API keys / env vars template
└── README.md
```

## Adding a new patch

1. Create `patches/my-fix.sh`
2. Make it idempotent: use a marker file in `~/.pi/agent/`
3. Run `./setup.sh` to register it in the launcher

## License

MIT
