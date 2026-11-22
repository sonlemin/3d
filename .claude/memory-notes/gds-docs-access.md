---
name: gds-docs-access
description: "Reading BMad Game Dev Studio docs — per-page URLs 404, llms-full.txt works; docs use legacy /bmgd-* names"
metadata:
  node_type: memory
  type: reference
  originSessionId: 5dd2de03-88f8-48e2-ac57-b409b106277c
  modified: 2026-11-11T17:44:24.213Z
---

Game Dev Studio (GDS) docs index: https://game-dev-studio-docs.bmad-method.org/llms.txt. As of 2026-11-12 the page URLs it lists (e.g. `/tutorials/quick-start`, `/explanation/what-is-bmgd`, with or without trailing slash) return 404; the full content loads from https://game-dev-studio-docs.bmad-method.org/llms-full.txt.

The docs use legacy names (`/bmgd-game-brief`, `/bmgd-create-gdd`, `/bmgd-quick-prototype`, Scrum Master "Max"). Installed equivalents in this project are `gds-*` skills (`gds-create-game-brief`, `gds-gdd`, `gds-quick-dev`); Max's duties live in Link Freeman (`gds-agent-game-dev`). No quick-prototype skill is installed — Indie (`gds-agent-game-solo-dev`) routes prototyping through `gds-quick-dev`.

**How to apply:** fetch llms-full.txt for GDS workflow guidance, then translate command names via `_bmad/_config/bmad-help.csv`, which is authoritative for what's installed.
