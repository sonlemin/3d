---
name: architecture-one-night-game
description: Game architecture for the one-night game was completed 2026-11-20 (AD-1 to AD-68); where it is, how to read it, and what comes next
metadata:
  type: project
---

The architecture for The Mourning Watch (one-night game) was completed on 2026-11-20 with `gds-game-architecture`. It is `_bmad-output/game-architecture.md` in the `3d_game` repo (branch `ear-test-prototype`), decisions AD-1 to AD-68. Not committed at the end of that session.

Core of it: one node-free `NightSim` owns every rule of a night (including the warden's walking, the look target, cry slots and the ally), ticks 60 times a second from one seed, and reports an ordered event list; nodes only draw and play. Game code goes under `game/watch/`; the ear test stays untouched and the game uses nothing of it.

**Why:** agents work without a screen or speakers, so anything that is a rule must be testable headless; see [[gdd-one-night-game]] and [[ux-one-night-game]].

**How to apply:**
- The document was built in passes; later sections amend earlier ones. Read the Executive Summary, the Decision Summary and "Architecture Validation" first.
- Two cold reads found 39 and then 37 problems; the second round of fixes was not re-read (DW-19). The readiness check re-read it on 2026-11-20 and closed DW-19 with three small notes ([[readiness-check-one-night-game]]).
- `_bmad-output/project-context.md` was refreshed from the architecture the same day (102 rules, no open markers; it carries three "until epic 1's setup story lands" notes to remove later). Readiness check and DW-16 are done; next is epic 1 stories starting with a setup story (DW-18). Epic order is now 1 then 2 (AD-66).
- During the session Sonlm asked for advanced elicitation and party mode on every step, and for a second cold read before finishing. My reading: for foundation documents Sonlm wants the extra review passes, not the fastest path. Offer them.
