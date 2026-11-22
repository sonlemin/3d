---
name: gdd-one-night-game
description: "The Mourning Watch GDD (one-night game in full) was drafted 2026-11-19; where it lives, what to read first, and the agreed next steps"
metadata:
  node_type: memory
  type: project
  originSessionId: 75de1b17-f015-4fc0-bc52-71087e992664
  modified: 2026-11-19T12:31:08.908Z
---

The GDD for The Mourning Watch was written on 2026-11-19 in a `gds-gdd` session. It lives in `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/` in the `3d_game` repo, branch `ear-test-prototype`: `gdd.md`, `epics.md`, `decision-log.md`, and `source-extracts/`.

Read `decision-log.md` first. It holds every decision (GD-1 onward), the inherited ones (IN-1 to IN-20), the finalize status, and anything still owed.

State on 2026-11-19: draft 0.6, with the UX decisions applied (GD-48 to GD-55) and a third validation's fixes in; nobody has read the result. Estimate about 325 to 510 hours, gate 2 after about 255 to 385. See [[ux-one-night-game]].

Scope Sonlm chose: the one-night game in full numbers, the Fog Season as an outline, later seasons out of scope. Game type: tower defense with horror sections.

Next steps Sonlm chose (GD-45):
- `gds-game-architecture` for the one-night game comes next.
- Narrative design (`gds-create-narrative`) waits until just before the Fog Season is planned.
- Build order is the eight epics in `epics.md`; epic 2 ends with an early listen by two or three newcomers, and epic 6 is gate 2 with five newcomers.

**Why:** gate 1 closed the same day ([[ear-test-gate-closed]]), and the GDD is what turns the brief into something buildable.

**How to apply:** when Sonlm asks for architecture, epics, stories or playtest plans for this game, start from the decision log, not the brief. Treat every number in the GDD as a starting value for gate 2 tuning. Related: [[recommended-option-is-the-decision]], [[engine-godot-only]].

Update 2026-11-20: draft 0.7 writes the architecture's decisions back (GD-56 to GD-67): smooth distance loudness, the full 4-cry limit with the tune protected, what a replay resets, dawn winning a tie, a diving Diver falling through, the 20 s stillness in full, the wound in detail. Epic order is now 1 then 2, epic 1 has a setup story, and the total is about 335 to 525 h (25 h over the brief's ceiling; the 10 to 15 h for setup was my guess, not Sonlm's choice). GDD, epics, architecture, project-context and EXPERIENCE.md were kept in step. Nobody has read the result after GD-64 to GD-67. Readiness check done 2026-11-20 ([[readiness-check-one-night-game]]); next is epic 1 stories ([[architecture-one-night-game]]).
