---
name: ux-one-night-game
description: "UX spines for the one-night game; finalised 2026-11-19, updated 2026-11-28 (DW-5, DW-54: scale B, UX-42 to UX-66); GDD wording owed (DW-59)"
metadata:
  node_type: memory
  type: project
  originSessionId: 5b516bf1-65ea-428d-9af6-d975e909dbd2
  modified: 2026-11-27T17:56:09.623Z
---

DESIGN.md and EXPERIENCE.md for the one-night game live in `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/` (look: "Lantern light", no panels; night has no HUD except the ally's caption). Read its `.decision-log.md` first (UX-1 to UX-66).

The update run of 2026-11-27 to 2026-11-28 closed DW-5, DW-52, DW-54, DW-56 and DW-39. It set type scale B (floor 42 px at 1080p, every size divisible by 3), all text `ink` or brighter with `dim` retired, a three-line planning tray, and 16 rules for the check screen, the night and the screens. Sonlm took the recommended option in all 25 choices (UX-62, the ledger at 45%, came after a measurement mistake of mine; UX-63 to UX-66 after the review).

**Why:** the first sizes were written before anything was seen on Sonlm's screen and were too small (see [[screens-must-read-on-sonlm-laptop]]). The GDD and the architecture have not yet absorbed this run's rules.

**How to apply:**
- The GDD's wording is owed to the next gds-gdd run (DW-59, with DW-47). The code's label size and label gap follow in story 5.1 (DW-58).
- Epic 2's story 2.9 needs UX-46, UX-48 and UX-49; they are written into DW-20.
- Cues everywhere has not been played muted; do not claim deaf-playable until the muted night in epic 8 passes.

Related: [[gdd-one-night-game]], [[architecture-one-night-game]].
