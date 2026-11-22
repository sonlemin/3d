---
baseline_commit: 64b35b0
---

# Story 1.6: Open sections and gaps

Status: review

<!-- Created 2026-11-22 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As the warden,
I want to get past a section with no planks and past a fallen one, slowly,
so that a broken bridge costs me time and does not trap me.

Delivers: GDD Game Mechanics 2 (open sections, side beams, fallen sections, the warden's crossing times); Game Mechanics 3 (re-lay onto an open section). GD-19, GD-68, GD-69. Architecture AD-33 (countdowns), AD-34 (steps 1, 4, 7, 8), AD-35 ("open" is computed), AD-48, AD-52 (edging and crossing are timed moves of `WardenRules`), AD-63, AD-64. Closes DW-35 and DW-43. Replaces story 1.4's decision D3.

## Acceptance Criteria

Tick numbers are `sim.tick`, from 0 (AD-33: the first `advance()` is tick 0). "Begun on T, lasting N, done on T + N." Section numbers are the one night's (6 sections, 30 m, `world_z = along − 30`); tests also run them on a 4-section def where they fit. No literal 6, 8 or 30 outside `night_defs.gd` and tests (AD-42).

1. **Edging round an open section.** Given a section with no planks that has not fallen (open), when the warden walks into it (decision D1), then the warden cannot stand on it and edges along its side beam to the far edge in 4 s (240 ticks: `EDGING_STARTED` on S, `EDGING_ENDED` on S + 240), with no input but look until the edging ends (the move wish is ignored; every press, Tab too, is ignored with no event).
2. **The last plank underfoot (GD-68).** Given the warden on a section when its last plank is taken, when the plank goes, then the warden is on the side beam from that moment (`EDGING_STARTED` in step 4 of the strip's tick, after `PLANK_STRIPPED`) and finishes the crossing toward the town from where they stand, in the share of 4 s that the distance left is of 5 m: `roundi(240 × left / 5)` ticks, at least 1, where `left` is the metres from the feet to the section's town-side edge. (Along 12.5 on section 3: 120 ticks; along 11.0: 192; along 14.9: 5.) This holds whichever way the warden faces.
3. **The side beams carry 2.** Given an open section, when more than a load of 2 is on its side beams for 2 s (120 ticks), then the section falls (`GROAN_STARTED` on T, `SECTION_FELL` on T + 120, as any section); and a load of exactly 2 never brings it down (it creaks). An open section's strength is 2 (decision D4); the warden on the beams adds no load.
4. **Re-lay (GD-69).** Given an open section, looked at from the next section within 2 m, with a plank in hand, when a plank is re-laid on it, then it has 1 plank and can be walked over its whole length again.
5. **Crossing a gap.** Given a fallen section, when the warden walks into the gap from either side (decision D1), then the warden crosses hand over hand in 8 s (480 ticks: `CROSSING_STARTED` on S, `CROSSING_ENDED` on S + 480), with no input but look; and two fallen sections side by side take 8 s each (two pairs of events, the second starting on the tick the first ends).
6. **Holds and parts.** Given a hold in progress, when a crossing, an edging or a climb begins, then `HoldRules` cancels the hold (`HOLD_CANCELLED`, nothing moves) and lowers the forearm: in step 2 of the same tick for a move begun in step 1 (walked in), on the next tick for one begun in step 4 or 8 (the climb begins in step 8 of the fall's tick F and cancels on F + 1, as story 1.5 built it); and the parts in hand are the same after each of the three as before.
7. **Never trapped, never off the span.** Given bot nights that strip sections bare and drop them, when every tick is checked, then the warden is always on a section with planks, on the landing, or in a timed move (edging, crossing, climbing) at that move's place, and no fault is reported.

Also part of this story (from the documents or forced by the ACs; each has a test):

8. **A section that goes open beside the warden** (decision D3): a warden standing on the next section within 0.3 m of a section whose last plank goes steps straight back to 0.3 m from it in the same tick, toward their own section, as story 1.5's D2 does beside a gap; a hold on another target goes on and is not charged for the step.
9. **A run of open and fallen sections** is crossed one section at a time, each at its own time (4 s or 8 s), one pair of events per section, with no input between them. Walking into one begins only if the run, in that direction, ends on a section with planks or on the landing; toward the far pier a run that ends at the far pier blocks like an edge (nothing begins; the feet stay 0.3 m short). Toward the town a run always ends on a floor (the landing).
10. **An edging warden whose section falls** catches the edge and climbs back toward the town exactly as story 1.5's climb (`WARDEN_CAUGHT` in step 8 of the fall's tick, `WARDEN_CLIMBED` 300 ticks later), whichever way they were edging.
11. **A section can start fallen.** `StartState.fallen` (sections that start as gaps): their planks and ropes go to lost through the ledger, so 48 and 12 still hold; weights or lifts on a section that starts fallen are `span.bad_start` and skipped. Needed by the `gaps` show here and by story 1.7.

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setups below. Build order (AD-46): failing test first, with the GDD's number written out; then constants, state, tick step, rule and events, consequences; then the view; then the bot paths, the show-me setups and the manual checks. Build-order step 7 (sound and cue) waits for epic 2: nothing is heard yet.

**Manual checks for Sonlm** (an agent cannot verify these headless; never report one as verified unless judged from frames as the dev-story chores describe):

- **M1** (`--show=gaps`; the epic's check): from section 5, walk toward the far pier into the gap of section 4 and keep pushing: you cross hand over hand (8 s) onto section 3; walk on into open section 2 and keep pushing: you edge along its side beam (4 s) onto section 1. Turn round and come back the same way. The difference between 4 s and 8 s is felt, and you never feel stuck.
- **M2** (`--show=last_plank`): standing on section 3 (1 plank) 1 m from section 2, facing the far pier, strip the deck in front of you: you go onto the side beam and edge toward the town behind you (3.2 s) onto section 4. Then turn round, look down at section 3's deck from section 4 and re-lay a plank (E): section 3 can be walked again. How the edging reads, going backward to your view, needs Sonlm.

## Decisions for this story

Points that neither the GDD nor the architecture settles. **Sonlm chose the recommended option for all four on 2026-11-22** (see "Decisions taken with Sonlm" in Dev Notes); the ACs and Dev Notes are written to them.

- **D1. What "walks into it" is.** The feet stop 0.3 m short of anything that cannot be stood on (story 1.3 D1), so "walking into" an open section or a gap needs a rule in ticks. The re-lay of AC 4 is done from that same edge (a deck is in reach within about 1.2 m of the feet), so a player walking up to re-lay will often reach the stop with W still down. (Recommended) **A deliberate push:** the crossing begins when the move wish has pushed straight into it at the stop for 0.5 s (30 ticks) in a row: the wish's along-span part points into the section and is at least as large as its across part (within 45° of straight in). A tick without that push starts the count again. Pushing from tick T, the move begins in step 1 of T + 30. A brush along the edge, or walking up to re-lay, never starts one. Declined: at once, on the first tick of pushing (the stop then never holds: a player reaching the edge to re-lay is carried across for 4 to 8 s); any push however slanted, after 0.5 s.
- **D2. Where the warden is during an edging and a crossing** (gray box; the view follows the feet). (Recommended) **Moving steadily:** edging, the feet stay at deck height and slide steadily from where they stand to the far edge of the section, drifting sideways onto the line of the nearer side beam (x ±2.2, right when x ≥ 0) as they go, so nothing jumps; crossing a gap, the feet hang 1.4 m below the deck (as story 1.5's hang, eye 0.2 m above deck level) and move steadily across, cut down at the start and cut up onto the far deck, 0.3 m in, at the end. The view blends every move but those two cuts and the climb. Declined: still at the start for the whole time, then cut to the far side (like the climb).
- **D3. A warden beside a section that goes open.** Stripping a section's last plank from the next one is the usual stance (the deck is reached within about 1.2 m), often within 0.3 m of its edge. Without story 1.4's D3, a warden there cannot stand and today's `walk()` would freeze them. (Recommended) **Step back**, as beside a gap (story 1.5 D2): in the same tick the feet move straight away from the open section until they are 0.3 m from it, on their own section; a hold on another target goes on (not reachable in epic 1, where only the warden's own strip opens a section; epic 3's deck hooks can). Declined: the warden goes onto the open section's beam and edges toward the town (GD-68 for someone who was not on it); keep story 1.4's D3 for this case only.
- **D4. An open section's strength.** GDD Game Mechanics 2: "Strength = planks left, 0 to 8" and "The side beams carry a load of 2". Read together, a section with 1 plank has strength 1 and one with none has strength 2, so **taking the last plank makes a section stronger**: a section at 1 plank groaning under 2 holds again when its last plank goes (a test pins it: AC 3 and Dev Notes "Literal cases" L5). (Recommended) **As the GDD is written:** strength is the planks while there are any, 2 when open; the oddity is kept and judged at gate 2 with the dead on the beams. Declined: strength never below 2 (`max(planks, 2)`; a section at 1 plank would then hold 2, a GDD change to GD-19).

Settled without a question (each follows from the documents or the ACs; listed so Sonlm can revisit):

- **"Open" is computed** (AD-35): `SpanRules.open(n, span)` = no planks and not fallen. Epic 4 adds "trapdoor down". Nothing new is stored for it.
- **Who is on an open section**: the feet (the point itself) lie on its floor and on no walkable floor (a section with planks, the landing). Feet on a shared edge with a section that has planks are on that section; then AC 8 applies, not AC 2.
- **One move per section.** `EDGING_STARTED`/`EDGING_ENDED` or `CROSSING_STARTED`/`CROSSING_ENDED` for each section crossed, each carrying the section. When one ends, the next section in the same direction decides what follows, worked out then: a floor (planks, or the landing) → the feet step onto it, 0.3 m in, and the warden walks again from that tick; open → an edging of it begins on the same tick; fallen → a crossing of it begins on the same tick.
- **Turning back.** If, when a move ends, the way on (toward the far pier only) no longer ends on a floor, because the section beyond fell meanwhile, the warden turns: the next move crosses back over the section just crossed, toward the town. Nothing ever leaves the warden with nowhere to go ("does not trap me"). Reachable only through a `StartState` in this story (L8).
- **The edging warden and the fall**: if the section being edged falls, the warden is caught (AC 10). Nothing can fall under a crossing warden (the gap has fallen already). A section beyond that falls or goes open during a move is met when the move ends (above).
- **The climb is unchanged**: it goes onto the first section toward the town with planks that has not fallen (an open one is passed), else the landing.
- **The open section creaks at a load of 2** by the general rule (load equals strength, above 0). It is seen as the weights sinking: story 1.5's bow moves the weights with the deck even with no planks.
- **Weights on an open section** are drawn where `weight_box()` puts them, over the void. Gray box; no show has one.
- **No view turn** at any move (the view is the player's; story 1.5's catch is the one exception). An edging toward the town of GD-68 may go backward to the view: M2 judges it.
- **The hold rules need nothing new**: `HoldRules` already ignores presses and cancels a hold while `WardenRules.walking(sim)` is false. A button still down when a move ends starts nothing until a fresh press (story 1.5 rule).
- **Event names** fit the trace's 17-letter column: `EDGING_STARTED`, `EDGING_ENDED`, `CROSSING_STARTED`, `CROSSING_ENDED`. Their `who` in the trace is `warden`. The dead edge and cross in epic 3 (12 s, 6 s); whether they reuse these kinds with `dead_id` set is epic 3's choice.
- **Story 1.4's D3 is removed** (`held_by_bare()` and its use in `walk()`). Story 1.4's AC 10 ("the warden stays in place and can walk off") is replaced by AC 2. DW-35 closes with it.

## Tasks / Subtasks

- [x] **T0. Baseline.** Run `tools/ci.sh` before any change and write the counts in the Debug Log (story 1.5 ended at 1224 passed, 0 failed, 55 expected; read the real number). Re-read DW-35 and DW-43.
- [x] **T1. Failing tests first (AD-46)**, GDD numbers literal with their source in a comment, never read from the constants. Situations only through a `StartState`, then commands and ticks (Dev Notes "Tests" and "Literal cases").
  - [x] 1.1 `test_warden.gd`: walk-in edging both directions (AC 1, L2); the push of D1 (30 ticks then a tick without it does nothing, L10; a slanted push never begins; a push at the stop beside an open section with the far pier beyond does nothing, AC 9); crossing a gap both ways and two side by side (AC 5, L3); the run chained (open then fallen, L9); turning back (L8); the move wish ignored during an edging and a crossing; `WardenState.values()` with the new facts. Rewrite `_test_a_section_with_no_planks_blocks` (below).
  - [x] 1.2 `test_span.gd`: `strength()` is 2 for an open section and planks otherwise, `open()` (AC 3); an open section with 1, 2, 3 weights (L4); the last plank saves a groaning section (L5, D4); `StartState.fallen` (parts lost, totals, `span.bad_start` for a bad section and for weights or lifts on it). Replace `_test_a_bare_section_with_a_weight_falls` (DW-43).
  - [x] 1.3 `test_consequences.gd`: GD-68 from along 12.5, 11.0 and 14.9 with literal ticks and positions (AC 2, L1); GD-68 chained into a gap (L9); the step back from an open section on both sides (AC 8, L7); the edging warden caught (AC 10, L6); `steps()` list compared literally (now four); a second `settle()` changes nothing. Rewrite `_test_a_bare_section_that_holds_the_warden_falls_with_them` as L6.
  - [x] 1.4 `test_hands.gd`: a hold cancelled when an edging, a crossing and (already) a climb begins, parts in hand unchanged (AC 6, L11); presses and Tab ignored during an edging and a crossing; re-lay onto an open section from either neighbour, then walked over its whole length (AC 4). Replace the "AC 10 and D3" block (`_test_last_plank_underfoot`, `_test_last_plank_from_the_next_section`, `_test_bare_from_the_start_blocks`) with GD-68 and AC 8 cases.
  - [x] 1.5 `test_night_sim.gd`: the checksum changes with each new warden fact and with a fallen start; the fields test also runs the new bot paths so every kind is seen; `NightEvent` field list unchanged.
- [x] **T2. Constants** (Dev Notes "Constants").
- [x] **T3. State.** `WardenState`: `Move.EDGING`, `Move.CROSSING` and the move's facts; `values()`. `StartState.fallen`. `NightSim._apply_start` (fallen, after planks and rails; validated), `checksum()` (unchanged if it already takes `warden.values()` whole: check).
- [x] **T4. The tick (AD-34; step list unchanged).** Step 1: `WardenRules.tick_moves()` ends or chains an edging or crossing as well as the climb; `walk()` counts the push and begins a move (D1). Steps 4 and 8: `ConsequenceRules.settle()` with its new step. Update each touched step's `##` comment.
- [x] **T5. Rules and events.** `NightEvent`: 4 kinds with their "Fields:" lists. `SpanRules`: `open()`, `strength()` with the side beams. `WardenRules`: remove D3 (`held_by_bare()`); the push; `begin_edging()`, `begin_crossing()`, the run's end (`way_on()` or similar, pure); `tick_moves()` per move kind; `step_back()` for open sections too; GD-68's start. `ConsequenceRules`: `warden_footing` handles an edging warden whose section fell and the wider step back; a new step `warden_on_beams` (GD-68). Read "Where the code assumes not walking = climbing" before changing anything.
- [x] **T6. Geometry.** `SpanGeometry`: the beam line's x for a side, an edging point and a crossing point at an along, and the far-side landing point of a move, so no coordinate is typed in a rule. Tests in `test_span_geometry.gd` with literal values (beam x ±2.2; the points of L2 and L3), and `can_stand` true at every point a move ends on.
- [x] **T7. View.** `warden.gd`: snap only while climbing and on `WARDEN_CAUGHT`, `WARDEN_CLIMBED`, `CROSSING_STARTED`, `CROSSING_ENDED`; push (blend) otherwise, edging included. `AimAid.would_start()` needs nothing new (it asks `walking()`): add one test row each for an edging and a crossing. Tests: `test_warden_node.gd`, `test_aim_aid.gd`.
- [x] **T8. Bot paths (AD-63)**: `NightBot.gaps` and `NightBot.beams` (+ `_script` forms with no wander); the `walk` path's start becomes section 1 open; the `strip` path's last-plank case becomes GD-68; `test_bot_nights.gd`: reaching tests for both new paths, the per-tick arithmetic rewritten without `_held` (Dev Notes "Bot").
- [x] **T9. Show-me setups (AD-56)**: `gaps` and `last_plank`; `test_show_setups.gd`.
- [x] **T10. Trace**: the 4 new kinds join `WARDEN_KINDS`; the edging kinds print their side; `test_trace.gd`.
- [x] **T11. Docs**: `game/WATCH.md`; `_bmad-output/project-context.md`; `deferred-work.md` (close DW-35 and DW-43).
- [x] **T12. CI and manual checks**: `tools/ci.sh` green; each rule undone on its own to see a test fail (story 1.4's habit), including DW-43's note (below); the end-of-story chores (Xvfb frames of both shows driven by a scratch input driver, agent time, commit; `_bmad/custom/gds-dev-story.toml`). M1 and M2 stay Sonlm's.

## Dev Notes

### What this story is

A broken bridge stops being a wall. An open section (no planks, not fallen) is edged along its side beam in 4 s; a gap is crossed hand over hand in 8 s; both are timed moves of `WardenRules` (AD-52), begun by pushing into them (D1), during which the warden only looks. A warden whose last plank goes is on the beam at once and finishes toward the town in the share of 4 s that is left (GD-68). An open section's side beams carry 2 (strength 2), and more for 2 s brings it down, with an edging warden on it caught as in story 1.5. A warden beside a section that goes open steps back (D3). Story 1.4's stand-in (D3: a bare section still holds the warden) goes.

**Not in this story** (do not build ahead): the dead edging (12 s) and crossing (Grapplers 12 s with a hook, hatchlings 6 s, stranded Divers and hatchlings: epic 3); a trapdoor making a section open (epic 4); the wound on a fall (epic 4); a lantern pole on a side beam (epic 4); sound of any kind (epic 2); hands or arms seen during a move (epic 4 story 1, epic 7); the overhead read-out (story 1.7, which reads `StartState.fallen` from this story). No HUD. Gray boxes.

### Current state of the files this story changes (read 2026-11-22, commit `64b35b0`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/sim/warden_rules.gd` | `walk()` with D3 (`held_by_bare()` adds bare floors when the feet cannot stand); `can_stand`, `stands_on`, `walkable` (planked, not fallen, + landing), `reach` pure; `walking()`; `fell_from()`; `climb_target()`; `start_climb()`; `hang_on()`; `tick_moves()` (**ends every timed move as a climb**); `step_back()` (**fallen sections only**, against `_standing_floors`, which counts bare sections as standing) | D3 removed; the push and the move's start (D1); `tick_moves()` per kind with chaining and turning back; `step_back()` from any section that cannot be stood on, against `walkable()`; GD-68's start | `can_stand`/`stands_on`/`reach` pure and unchanged in meaning; exact stops (tests at 0.001 m); the climb exactly as story 1.5 and its review left it (`hang_on`, the end worked out again, view cut) |
| `game/watch/sim/consequence_rules.gd` | `steps()` = `[weights_fall, parts_lost, warden_footing]`; `warden_footing` **calls `hang_on()` for any warden not walking**, else catch or step back, with `HoldRules.feet_moved()` for the step | Not walking: climbing → `hang_on()`; edging on a section that fell → `start_climb()`; crossing → nothing. Walking: as today, with the step back widened (D3). New step `warden_on_beams` (GD-68) | The order and names of the three steps; a second `settle()` changes nothing; the step back not charged to a hold |
| `game/watch/sim/warden_state.gd` | `Move { WALKING, CLIMBING }`, `position`, `move_ticks_left`, `fell_from`; `values()` | `EDGING`, `CROSSING` and the move's facts; the push count | `position`; the climb's fields |
| `game/watch/sim/span_rules.gd` | `strength()` = planks ("Story 1.6 adds an open section's side beams"); `load_on`, `creaks`, `overloaded`, `tick_loads`, `take_lifts`, `move_parts` | `open()`; `strength()` 2 when open | `move_parts()`'s four guards; `tick_loads()` exactly (it already works on any strength) |
| `game/watch/sim/span_constants.gd` | sizes, hold times, town floor, `GROAN_S`, `TEST_WEIGHT_LOAD` | `SIDE_BEAM_LOAD` | The rest |
| `game/watch/sim/warden_constants.gd` | walk speed, eye, clearance, `CLIMB_BACK_S`, `HANG_DROP` | `EDGE_S`, `CROSS_GAP_S`, `PUSH_TO_CROSS_S` | The rest |
| `game/watch/sim/night_ticks.gd` | strip, rail, re-lay, grace, groan, climb_back | `edge`, `cross_gap`, `push_to_cross` | `of()` |
| `game/watch/sim/start_state.gd` | planks, stripped_rails, warden_along, weights, lifts | `fallen: Array[int]` | The rest |
| `game/watch/sim/night_sim.gd` | `_apply_start` (planks, rails, weights, lifts); `_place_warden` after; step 1 = `tick_moves`, `walk`, look, commands | `_apply_start` adds fallen (after planks and rails, before weights; `set_fallen` through `SpanState`, parts to lost through `SpanRules.move_parts()`); step comments | The step names and order (literal test); fault codes; `_place_warden` after the span is built |
| `game/watch/sim/span_state.gd` | `fallen`, `set_fallen`, `fits_at` 0 on a fallen deck or rail | Nothing new expected (a fallen start uses `set_fallen` and the ledger) | `add_at()` only from `span_rules.gd` (a test greps it) |
| `game/watch/sim/span_geometry.gd` | every shape; `side_beam_box`; `hang_point`, `climb_end`, `_climb_x` | The beam line and move points (T6) | Every existing shape |
| `game/watch/sim/night_event.gd` | 15 kinds | 19 kinds | Fields; the "Fields:" convention |
| `game/watch/sim/hold_rules.gd` | Ignores presses and cancels while not walking | Nothing (header comment: "a timed move", not only the climb) | Everything |
| `game/watch/night/warden.gd` | `on_tick`: **`cut = not walking`**, so every tick of any timed move snaps | Snap only while climbing and on catch, climbed, crossing start and end | Mouse look, Esc, the catch's turn to the town |
| `game/watch/debug/bot/night_bot.gd` | `span_counts`, `walk` (**section 2 bare; "the plankless section 2 stops it"**), `strip` (**"walking off it toward the town (D3)"**), `overload` | `walk` start `{1: 0}`; `strip`'s last plank is GD-68; new `gaps`, `beams` | `span_counts` and `overload`'s code unchanged; but **`overload`'s behaviour changes**: its script ends on the landing 0.3 m from three gaps in a row (the town section, `c`, `a`) with `b` standing beyond, and two wander draws in a row toward the far pier (60 ticks) now begin a crossing. Over 20 seeds and two defs that is likely; the path then ends mid-crossing. The per-tick arithmetic must handle a move on any path |
| `game/watch/debug/show/show_setups.gd` | 7 setups | `gaps`, `last_plank` | Existing rows |
| `game/watch/debug/trace.gd` | `WARDEN_KINDS`; side printed for rail kinds | 4 new kinds, side for the edging kinds | `NIGHT_STARTED`'s line exactly |
| `game/tests/watch/test_bot_nights.gd` | `_held` (D3), `_inside` and `_in_band` use it; `_hang_edge`; walk reaching test expects the stop at along **10.3** | `_held` and `_in_band` removed; per-move arithmetic; walk stop at **5.3** | Its own arithmetic (the rule may not be its own judge); totals and no fault every tick |
| `game/tests/watch/test_warden.gd` | `_test_a_section_with_no_planks_blocks` (**pushes 120 ticks into bare section 3 and expects a stop**); `_test_a_fallen_section_is_no_floor` (**calls `WardenRules.held_by_bare()` twice**: removing the function without this test stops the whole file parsing) | The first rewritten: a stop while the push is under 31 ticks, and for good with nothing beyond; the edging itself in new tests. The second keeps its `walkable()` checks and loses its two D3 lines | The other walking tests |
| `game/tests/watch/test_span.gd` | `_test_a_bare_section_with_a_weight_falls` (**strength 0, 1 weight falls**) | Replaced: 1 weight on an open section does nothing (L4) | The rest |
| `game/tests/watch/test_consequences.gd` | `steps()` list literal (3); `_test_a_bare_section_that_holds_the_warden_falls_with_them` (**D3 held**) | 4 steps; that test becomes L6 | The rest |
| `game/tests/watch/test_hands.gd` | "AC 10 and D3" block (lines 676 to about 750) | GD-68 and AC 8 cases | The rest |

### Where the code assumes "not walking" means "climbing"

Three places, each must learn the new kinds or edging will break in ways no existing test sees:

1. `WardenRules.tick_moves()` ends any timed move at 0 ticks with the climb's end (`climb_end`, `WARDEN_CLIMBED`). It must branch on `warden.move`.
2. `ConsequenceRules.warden_footing()` calls `WardenRules.hang_on()` for any warden not walking. An edging or crossing warden would be moved to a hang point.
3. `Warden.on_tick()` (`warden.gd`) snaps the blend on every tick while not walking. Edging would then step 60 times a second with no blend: visible judder on any screen above 60 Hz, and M1 judges exactly that.

### Constants

| Constant | Value | Source |
|---|---|---|
| `SpanConstants.SIDE_BEAM_LOAD` | 2 (int: a strength) | GDD Game Mechanics 2: "The side beams carry a load of 2; more than that for 2 s and the section falls" |
| `WardenConstants.EDGE_S` | 4.0 | GDD Game Mechanics 2: "Crossing it along its side beams takes ... the warden 4 s" |
| `WardenConstants.CROSS_GAP_S` | 8.0 | GDD Game Mechanics 2: "The warden crosses hand over hand in 8 s" |
| `WardenConstants.PUSH_TO_CROSS_S` | 0.5 | D1; not a GDD value: a feel size, tuned in M1 |
| `NightTicks.edge`, `cross_gap`, `push_to_cross` | 240, 480, 30 | Converted once (AD-33) |

The beam line is not a new constant: it is the standable band's edge, `SECTION_WIDTH / 2 − CLEARANCE` = 2.2, asked of `SpanGeometry` (the same x `_climb_x` clamps to). The 45° of D1 is a comparison (`absf(along part) >= absf(across part)`), not a constant.

### State

- **`WardenState`**: `enum Move { WALKING, CLIMBING, EDGING, CROSSING }` (knockdown in epic 4). For a move: `move_section` (the section being edged or crossed), `move_toward` (+1 toward the town, −1 toward the far pier), `move_from: Vector3`, `move_to: Vector3`, `move_ticks_total`, and the existing `move_ticks_left`; `fell_from` stays the climb's. `pushed: int`, the ticks the wish has pushed into the section ahead (D1). Every one goes into `values()` in a fixed order; only `WardenRules` changes them. (Names are suggestions; keep the climb's working as it is.)
- **`StartState.fallen: Array[int]`**: sections that start as gaps. `_apply_start`, after planks and rails and before weights: a section outside 1..n is `span.bad_start` and skipped; a repeat is ignored; `set_fallen(n)`, then its planks and both ropes to `PartPlace.lost()` through `SpanRules.move_parts()` (a section also in `planks` first gives those to the hand, as for any section; what is left is lost). Weights on a section that starts fallen, and lifts for it, are `span.bad_start` and skipped. `_place_warden` then refuses a start on it by itself (`can_stand` is false there).

### The tick (AD-34; step names unchanged)

| Step | This story adds |
|---|---|
| 1 | `tick_moves()`: an edging or crossing advances its feet one tick along its line; on its last tick it ends (`EDGING_ENDED` / `CROSSING_ENDED`) and the next section decides: onto a floor and walking (the walk then runs this tick), or the next move begins on this same tick, or (toward the far pier with no floor at the end) the move back begins. Then `walk()` as today without D3, then the push (D1): while walking, count the push; on its 31st tick in a row (T + 30) begin the move (`EDGING_STARTED` / `CROSSING_STARTED`) and set the feet to its first point. Then look and commands as today (presses ignored while not walking). |
| 2 | Nothing new: `HoldRules.tick()` cancels a running hold and lowers the forearm while not walking. A move begun in step 1 or step 4 of tick T cancels on T in step 2 (step 1) or on T + 1 (step 4; there can be no running hold then: the strip that took the last plank has just completed). |
| 4, 8 | `ConsequenceRules.settle()`: the new step `warden_on_beams` and the widened `warden_footing` (below). |
| 7 | `tick_loads()` is unchanged; `strength()` now gives 2 for an open section. |

**Move timing.** A move begun on tick S lasting N ends on S + N. Its feet on tick S + k (0 ≤ k ≤ N) are `move_from.lerp(move_to, k / N)`, worked out from the ticks left, never summed. A crossing's feet are at `y = −HANG_DROP` from S to S + N; on S + N they go up onto the floor (or the next move's first point). An edging's are at `y = 0` throughout.

**The push (D1).** On a walking tick, after the walk: let `n` be the section just ahead of the feet along the span in the direction of the wish's along part (toward the town if it is positive in world z). It counts as a push when: `n` exists and cannot be stood on (open or fallen); the feet are within `CLEARANCE + EDGE_SLACK` of its near edge; the wish's along part is not 0 and `absf(along part) >= absf(across part)`; and the run starting at `n` in that direction ends on a floor (`way_on()`). Otherwise `pushed = 0`. From the landing, section n = the def's last; from section 1 toward the far pier, nothing (no push).

**Where moves start and end** (ask `SpanGeometry`; no coordinate in a rule):

- Edging section `n` toward `d`: `move_from` = the feet as they are, at y 0 (walked in: at the stop, 0.3 m short of the near edge; GD-68: where they stood; chained after a crossing: the crossing's end point brought up to y 0; chained after an edging or turned back: the last edging's end); `move_to` = (beam x, 0, far edge of `n`). So the x drifts onto the beam line over the move and nothing jumps (D2). Beam x: +2.2 when the feet's x ≥ 0 at the start, else −2.2. The move's time is the GDD's whatever its length (240 ticks walked in, chained or turned back, though the feet travel 5.3 m from the stop; the GD-68 share otherwise). For the first ticks of a walked-in edging the feet are still over the section they came from: the catch of AC 10 asks `move_section`, never the feet.
- Crossing section `n` toward `d`: `move_from` = (x, −HANG_DROP, near edge), `move_to` = (x, −HANG_DROP, far edge), x as the feet's, kept within ±2.2.
- Off the end onto a floor: the feet at (x, 0, far edge + d × CLEARANCE), x kept; `can_stand` is true there (a test checks).

### ConsequenceRules (AD-48, AD-64)

`steps()` becomes `[weights_fall, parts_lost, warden_footing, warden_on_beams]` (AD-64's order: the warden last; a new consequence is a new step). The literal list test changes with it.

- `warden_footing(sim)`: climbing → `hang_on()` (unchanged). Edging and `span.fallen(move_section)` → `start_climb(move_section)` (AC 10; the climb's own code decides where; a running move's fields are cleared). Crossing → nothing. Walking → as today (catch, else step back), where the step back now moves the feet away from any section that cannot be stood on (open or fallen) whose floor holds a clearance probe that is on no walkable floor (D3), still charged to no hold (`HoldRules.feet_moved()`). **The step back runs only when the feet point itself is on a walkable floor.** Today's `step_back()` looks only at the probes; for a fallen section that was safe (feet on a gap are caught first), but for an open one it is not: feet at along 14.9 on section 3 when its last plank goes have a probe on section 4 and one on section 3, and the probe-only rule would move them to 15.3 on section 4 instead of starting GD-68's edging (L7's negative).
- `warden_on_beams(sim)`: walking, and the feet (the point) on an open section's floor and on no walkable floor → begin the GD-68 edging of that section toward the town, `roundi(ticks.edge × left / SECTION_LENGTH)` ticks, at least 1.

The two conditions are disjoint (feet on a walkable floor vs not), so a second `settle()` changes nothing: test it.

### Literal cases (recomputed against the code; use them in the tests)

Positions are (x, y, world z), one night of 30 m. "Placed at along A" is `StartState.warden_along = A` (centre line, x 0). With D1 recommended.

- **L1. GD-68.** Section 3 at 1 plank, the warden at along 12.5 strips their own deck (aim ahead, e.g. along 11.9), the strip completing on tick X: tick X has `PLANK_STRIPPED s3` (step 2) then `EDGING_STARTED s3 R` (step 4), feet (0, 0, −17.5); `EDGING_ENDED s3 R` on X + 120, feet (2.2, 0, −14.7) on section 4, walking. From along 11.0: X + 192. From along 14.9: X + 5.
- **L2. Walking in.** Section 3 open, placed at along 15.3 (section 4, at the stop), wish (0, −1) from tick 0: `EDGING_STARTED s3 R` on tick 30, feet still (0, 0, −14.7); on tick 150 (half way) (1.1, 0, −17.35); `EDGING_ENDED s3 R` on 270, feet (2.2, 0, −20.3) on section 2, walking. The other way: placed at 9.7, wish (0, 1): ends on 270 at (2.2, 0, −14.7).
- **L3. A gap.** `StartState.fallen = [3]`, placed at 15.3, wish (0, −1) from tick 0: `CROSSING_STARTED s3` on 30, feet (0, −1.4, −15.0); `CROSSING_ENDED s3` on 510, feet (0, 0, −20.3). Fallen `[3, 4]`, placed at 20.3: `CROSSING_STARTED s4` 30; `CROSSING_ENDED s4` and `CROSSING_STARTED s3` both on 510; `CROSSING_ENDED s3` on 990, feet (0, 0, −20.3).
- **L4. Side beams.** Section 2 open with 1 weight: no event in 600 ticks. With 2: `CREAK_STARTED s2` on 0, nothing else in 600. With 3: `GROAN_STARTED s2` on 0, `SECTION_FELL s2` on 120.
- **L5. The last plank saves it (D4).** Section 3 at 1 plank with 2 weights, the warden placed at 15.4 aiming at section 3's deck (about along 14.9), the hammer pressed before tick 0 and held: tick 0 has `HOLD_STARTED` (step 1) and `GROAN_STARTED s3` (step 7); tick 120 has `PLANK_STRIPPED s3`, `GROAN_STOPPED s3`, `CREAK_STARTED s3`; no `SECTION_FELL` in 600 ticks; the warden (0.4 m away) does not step back.
- **L6. An edging warden falls.** Section 3 open with 3 weights, placed at 15.3, wish (0, −1) from tick 0: `GROAN_STARTED s3` 0; `EDGING_STARTED s3 R` 30; on tick 120 the edging is 90 of 240 ticks in, the feet at (0.825, 0, −16.6875) before step 7 (from (0, 0, −14.7) toward (2.2, 0, −20.0), 0.375 of the way); tick 120 has `SECTION_FELL s3` (step 7) then `WARDEN_CAUGHT s3` (step 8), feet (0.825, −1.4, −15.0) (section 4's edge, x kept); `WARDEN_CLIMBED s4` on 420, feet (0.825, 0, −14.7). No `EDGING_ENDED`.
- **L7. Step back (D3).** Section 3 at 1 plank, placed at 15.1, strips section 3's last plank (aim about along 14.6): on the strip's tick the feet go to (0, 0, −14.7) (0.2 m), no event; a second sim the same but placed at 9.9 on section 2, aiming at about 10.4 (yaw π): feet to (0, 0, −20.3). No other hold can be running here (the warden's own strip made the section open, and one action runs at a time), so "a hold on another target goes on" is not reachable in epic 1; keep `HoldRules.feet_moved()` on the step anyway (epic 3's deck hooks open sections) and say so in a comment. And the negative: placed at 14.9 **on** section 3 (1 plank), the last plank stripped: the feet are on the open section, not beside it, so GD-68's edging begins (5 ticks) and there is no step back.
- **L8. Turning back.** Section 2 open, section 1 at 1 plank with 2 weights (it groans from tick 0 and falls on 120), placed at 10.3, wish (0, −1) from tick 0: `EDGING_STARTED s2 R` on 30 (the run ends on section 1, standing then); `SECTION_FELL s1` on 120; on 270 `EDGING_ENDED s2 R` then `EDGING_STARTED s2 R` (back toward the town); `EDGING_ENDED s2 R` on 510, feet (2.2, 0, −19.7) on section 3.
- **L9. A run.** Section 3 at 1 plank, `fallen = [4]`, the warden at 12.5 strips their own deck (completing on X): `EDGING_STARTED s3 R` X; on X + 120 `EDGING_ENDED s3 R` then `CROSSING_STARTED s4` (feet cut to (2.2, −1.4, −15.0)); `CROSSING_ENDED s4` X + 600, feet (2.2, 0, −9.7) on section 5. And walking in from section 5 toward the far pier over fallen 4 and open 3: two moves, 480 then 240.
- **L10. Pushes that do not count.** Placed at 15.3 by open section 3: wish (0, −1) on ticks 0 to 29 (30 ticks), then (0, 0) on tick 30: nothing begins; (0, −1) again from tick 31: the edging begins on tick 61. Wish (0.8, −0.6) (more across than along): never begins, and the feet slide along x. Section 1 open, placed at 5.3: wish (0, −1) for 600 ticks: nothing (the far pier is beyond).
- **L11. A hold cancelled by an edging.** Placed at 15.3 by open section 3, aiming at section 4's own deck behind (about along 15.9, yaw π), the hammer pressed before tick 0: `HOLD_STARTED s4` 0; wish (0, −1) from tick 0; tick 30 has `EDGING_STARTED s3 R` then `HOLD_CANCELLED s4`; planks in hand the same before and after the edging.

### Bot (AD-63)

Two new paths in `paths()`, each with a `_script` form (no wander) for its reaching test, as `strip` and `overload`. Section numbers from the def: town `T`, `c` = T − 1, `a` = T − 2, `b` = T − 3; fewer than 4 sections is `bot.bad_def` (as `strip`). Use the existing helpers (`_go_to`, `_aim_at_deck`, `_hold`, `_tap`, `_until_walking`); add `_push(sim, wish, ticks)` and `_until_moving(...)` with `bot.walk_lost` guards.

- **`gaps`** (crossing): `StartState.fallen = [a, c]` (two gaps side by side, floors on both sides on 6 and on 4); on 6 sections also section 1 open with 2 weights (creaks all path, never falls; skipped on 4). From the landing: to the stop before `c`; push 30 ticks and let go (nothing begins, L10); aim at `T`'s own deck and press the hammer, then push until moving (`_until_moving`): `CROSSING_STARTED c` and `HOLD_CANCELLED` on the same tick; `c` then `a`, 480 each, onto `b`; from `b` push back: `a`, then `c`, onto `T`. A short wander on `T`.
- **`beams`** (open sections): `StartState`: `c` 1 plank; `a` open with 3 weights; `b` full; the warden placed at `section_start(c) + 0.3`. Push toward the far pier from tick 0: edging `a` (tick 30), `a` falls (120) with the warden on it: caught, climbs onto `c` (420). To mid `c`, strip its last plank underfoot: GD-68 edging toward the town onto `T`. From `T`'s stop, re-lay `c`; walk over `c` to its far end and back; from `section_start(T) + 0.1` strip `c`'s last plank: step back to `+ 0.3` (D3). Push until moving toward the far pier: edging `c` then crossing `a` onto `b`; push until moving back: crossing `a`, edging `c`, onto `T`. A short wander. (Every push in a script is "until moving", never a fixed 30: the move begins on the 31st pushing tick.)
- **`walk`**: its start becomes `{1: 0}` (section 1 open, the far pier beyond): the warden still meets a plankless edge, now at along 5.3, and pushes into it for about 140 ticks with nothing beginning (AC 9). Recomputed: from the landing (along 32) to 5.3 takes about 458 ticks of the first 600; after the rows for the rails and the diagonal the feet are near along 10.25, and 420 ticks at 3.5 m/s reach along 34.75, past the landing's back (33.7). Check it on 4 sections too. Update `WALK_SCRIPT`'s comment and `_test_walk_reaches_the_edges` (10.3 → 5.3).
- **`strip`**: the 8th strip of `b` underfoot (at `mid_b`) is now GD-68: an edging of 120 ticks toward the town onto `a`, then `_go_to(mid_a)` as today. Its reaching test's "last plank underfoot" and "walked off it toward the town" become "last plank underfoot" and "edged off it toward the town (GD-68)", told from `EDGING_STARTED`/`EDGING_ENDED` and positions.

**`test_bot_nights.gd`**: `_held` and `_in_band` go; `_inside` keeps its own arithmetic for a walking warden (feet at y 0 on a section with planks or the landing, 0.3 m from every edge that is not shared). While a move runs, this file's own record of it (from the `_STARTED` event: the section, the tick, the feet then) is checked every tick: edging, y 0, |x| ≤ 2.2 and moving monotonically from the starting x to ±2.2 (exactly ±2.2 at `EDGING_ENDED`), along between the starting along and the section's far edge, moving one way; crossing, y −1.4 and along within the gap; each move lasts exactly 240 (walked in, chained or turned back), 480, or `roundi(240 × left / 5)` (GD-68, `left` worked out here from the along at `EDGING_STARTED`); an edging may instead end in `WARDEN_CAUGHT` with no `EDGING_ENDED` (AC 10), and the climb's checks take over; climbing as today. Any path can start a move (the wanders of `overload`, `gaps` and `beams` will), so the record is kept on every path, not only the two new ones. `_test_gaps_reaches_its_cases` and `_test_beams_reaches_its_cases` (scripts only, 6 and 4 sections, 3 seeds), each case told from events, commands and state, never by asking the rule. Coverage then sees the 4 new kinds. **DW-43's note:** once `_held` is gone its `fallen` clause goes with it; say so when closing DW-43.

### Show-me setups (AD-56)

| Name | Description (as `--show=list` prints it) | `StartState` |
|---|---|---|
| `gaps` | `section 4 fallen, section 2 open; from section 5, cross the gap and edge round the open section, both ways (M1 of story 1.6)` | `planks = {2: 0}`, `fallen = [4]`, `warden_along = 22.5` (mid section 5, facing the far pier). Section 2's 8 planks start in hand. |
| `last_plank` | `on section 3 at 1 plank; strip it under you and edge toward the town, then re-lay it (M2 of story 1.6)` | `planks = {3: 1}`, `warden_along = 11.0` (section 3, facing the far pier; the deck ahead, about along 10.4, is in reach). 7 planks start in hand. |

Neither starts a move, so the CI smoke run of 120 frames sees none.

### Trace

`EDGING_STARTED`, `EDGING_ENDED`, `CROSSING_STARTED`, `CROSSING_ENDED` join `WARDEN_KINDS` (who `warden`). The edging kinds print their side like a rail action: `  0.500 EDGING_STARTED    warden s3 R`; the crossing kinds `  0.500 CROSSING_STARTED  warden s3`. `NIGHT_STARTED`'s line stays exactly as it is.

### Events

| Kind | When | Fields |
|---|---|---|
| `EDGING_STARTED` | Step 1 (walked in, or chained, or turned back) or step 4 (GD-68) | t, section, side |
| `EDGING_ENDED` | Step 1: the edging of that section is done | t, section, side |
| `CROSSING_STARTED` | Step 1 (walked in or chained) | t, section |
| `CROSSING_ENDED` | Step 1: the crossing of that gap is done | t, section |

Each kind's `##` comment ends with its "Fields:" list (the fields test parses it).

### View

- `warden.gd`: `cut` is true while `sim.warden.move == CLIMBING`, and on a tick whose events hold `WARDEN_CAUGHT`, `WARDEN_CLIMBED`, `CROSSING_STARTED` or `CROSSING_ENDED`; otherwise `push()`. Edging (it starts from where the feet stand, so its first tick moves them one tick's share) and walking blend. Nothing turns the view.
- Nothing else is drawn new: the side beams are drawn already (`SectionView`), a fallen section draws nothing, and open sections are drawn as they are. A test in `test_warden_node.gd`: across an edging, consecutive ticks push (the blend's previous and current differ by one tick's step); across a crossing's start and end, the blend is snapped.

### Tests

- One test file per system; situations only through a `StartState`; ticks and commands; no `await`; provoked faults inside `_expect_begin`/`_expect_end`.
- Literal ticks: compare exactly on which tick an event lands. Positions within 0.001 m.
- Every rule undone on its own must fail a test: the push count (30 vs 29), the 45° test, the run's floor check, chaining, turning back, the GD-68 share and its rounding, the step back from an open section on each side, `strength()` 2, the edging warden's catch, `hang_on()` not called for an edging warden, the view's snap list, `StartState.fallen` losing the parts.
- Ear test: still 120 passed, 23 expected.

### Docs

- `WATCH.md`: lines 39 to 40 and 79 (you can now cross: push into an open section or a gap for half a second; 4 s and 8 s; the last plank under you; stepping back; what the side beams carry); the two new shows; the trace lines.
- `project-context.md`: line 63 (a fallen section) loses "(nor does story 1.4's D3 count it)"; line 70 (`ConsequenceRules` now has four steps; the widened step back; GD-68); line 71 (timed moves: `EDGING`, `CROSSING`, the push, chaining, turning back, the snap list); line 80 (remove "Until story 1.6 ... D3"); "Store base facts only": "open" computed, the side beams in `strength()`. Update "Last Updated".
- `deferred-work.md`: close DW-35 (D3 removed; the case can no longer happen) and DW-43 (`strength()` has the side beams; L4 replaces the old test; the `_held` clause is gone). Add a new item only for something found and left.

### Project Structure Notes

```
game/watch/sim/warden_rules.gd, warden_state.gd, warden_constants.gd,
               consequence_rules.gd, span_rules.gd, span_constants.gd,
               span_geometry.gd, start_state.gd, night_sim.gd,
               night_ticks.gd, night_event.gd, hold_rules.gd (comment)     UPDATE
game/watch/night/warden.gd                                                  UPDATE
game/watch/debug/bot/night_bot.gd, show/show_setups.gd, trace.gd            UPDATE
game/tests/watch/test_warden.gd, test_span.gd, test_consequences.gd,
                 test_hands.gd, test_night_sim.gd, test_warden_node.gd,
                 test_aim_aid.gd, test_bot_nights.gd, test_show_setups.gd,
                 test_trace.gd, test_span_geometry.gd                       UPDATE
game/WATCH.md, _bmad-output/project-context.md,
_bmad-output/implementation-artifacts/deferred-work.md                      UPDATE
```

No new script file is expected (the moves are `WardenRules`', AD-52, System Location Mapping). If one is added after all, run `--import` and commit the `.uid` it writes; never invent one. `watch/sim/` stays node-free and names nothing outside `watch/sim/`, `watch/content/` and `WatchFaults`.

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, typed GDScript: type everything; `:=` only for `const X := preload(...)`; typed arrays and dictionaries.
- `class_name` for scripts named by type; `##` on every script and non-obvious member, saying why; constants cite GD-n or the story decision, with a unit suffix (`_S`; metres none).
- **Into the sim, nothing but** `set_move`, `set_view`, `command`; only the sim changes night state; a view reads state and handles its events before it reconciles (AD-49).
- **Store base facts only** (AD-35): strength, load and "open" are computed. A move's from, to and ticks are a phase and a countdown (State Patterns), stored.
- **Parts move only through `SpanRules.move_parts()`**: a section that starts fallen loses its parts through the ledger.
- **When the span changes, change only the span**; `ConsequenceRules.settle()` decides what follows, as small named steps (AD-48, AD-64). `HoldRules` alone cancels a hold.
- A rule that changes state takes `sim` last, returns nothing, reports with `sim.emit()`; a pure query returns a value. A phase change emits exactly one event, from the function that makes it.
- Time is whole ticks, converted once (`sim.ticks`); begun on T, lasting N, done on T + N; no `await`, timers or tweens for anything a rule times.
- No physics in the night (AD-52): edging and crossing are timed moves of `WardenRules`.
- A designed "no" is `REFUSED`; a bug is `faults.report()`. Walking into an edge is neither.
- No HUD at night; no shake, no flash, no flicker faster than 3 a second; gray boxes. The view is the player's.
- No `print` outside `watch/debug/`. Never `--no-verify`. What is on screen or felt is a manual check.

### Previous story intelligence (story 1.5, done)

- **The climb is the pattern**: a timed move counted down in step 1 before the walk, begun in step 8 (`start_climb`), ignored presses through `walking()`, the view cut. Edging and crossing reuse it; read "Where the code assumes ..." above first.
- **D2 of 1.5 (`step_back()`) is D3's precedent**, and DW-43 says so. Its review found the far-pier side untested: test both sides here too.
- **Its review asked for**: tests in both directions of every rule; every fix proven by undoing it; no check that cannot fail; reaching tests that run the script without its wander and tell each case from events, commands and state, not from the rule; the File List to include `sprint-status.yaml`.
- **Sonlm's play of 1.5**: the 5 s hang was fine; "stuck a bit after coming back" was the hang, not a fault. Sonlm notices being held without control: M1 asks whether 4 s and 8 s feel stuck.
- **The Xvfb chore**: engine flags before `--`, switches after: `xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --write-movie <dir>/frame.png --fixed-fps 30 --quit-after <n> -- --show=gaps --trace`. With no input nothing moves; drive real input from a scratch `extends SceneTree` driver outside the project (`Input.parse_input_event`, timed key events; at 30 fps one frame is 2 ticks), as stories 1.4 and 1.5 did.
- **M checks on the laptop**: Sonlm runs them from the Godot editor on their own clone; give editor steps (the show is chosen by the run's arguments), never command lines or git steps.

### Git intelligence

Branch `ear-test-prototype`, HEAD `64b35b0`. Recent: `64b35b0` DW-44 lines; `c4c6e7e` 1.5's play record; `3506bc3` 1.5 done; `feaeef7` 1.5 code review fixes; `b395b76` story 1.5. Pattern: one commit per story step, `Story 1.6: <what>`; the pre-commit hook runs `tools/ci.sh`. Commit on the current branch, never `main`, never `--no-verify`, never push.

### Latest technical notes (Godot 4.7.2)

Nothing outside what the project already uses. `Vector3.lerp()` gives the move's feet from the ticks left; compare positions with a tolerance in tests (0.001 m). `roundi()` is the same rounding `NightTicks.of()` uses.

### Decisions taken with Sonlm

Sonlm chose the recommended option for all four on 2026-11-22, at story creation:

1. **D1:** a move begins after 0.5 s (30 ticks) of pushing straight into the open section or gap at the stop, within 45° of straight in; anything less starts the count again. (Declined: at once; any push however slanted.)
2. **D2:** the warden moves steadily: edging at deck height from where they stand to the far edge, drifting onto the nearer side beam's line (x ±2.2); crossing a gap hanging 1.4 m below the deck, cut down at the start and up at the end. (Declined: still, then a cut.) The start from where the feet stand (not cut to the beam) was settled after the answer, so that nothing jumps, as the option promised.
3. **D3:** a warden on the next section within 0.3 m of a section that goes open steps straight back to 0.3 m from it in the same tick. (Declined: onto its beam and edging toward the town; keeping story 1.4's D3 for this case.)
4. **D4:** an open section's strength is 2 and a section with planks has its planks, as the GDD is written, so taking the last plank of a 1-plank section makes it stronger; pinned by L5 and judged at gate 2. (Declined: strength never below 2, a GD-19 change.)

Also settled without a question (see "Decisions for this story"): "open" computed; who is on an open section; one move per section, chained; turning back toward the town; the edging warden caught by a fall; the climb unchanged; the creak at 2; weights drawn over the void; no view turn; no new hold rules; the event names; story 1.4's D3 removed.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1; "Epic 1: story detail" preamble; "Story 1.6"; story 1.7 (it reads `StartState.fallen`)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Game Mechanics 2 (strength, an open section, a fallen section, what falls with it), 3 (re-lay, "parts in hand are kept through every wound, climb and crossing")
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-19, GD-68, GD-69
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: "Knocked down, hanging, crossing a gap: the view shows it; no input but look until it ends"; Accessibility Floor
- `_bmad-output/game-architecture.md`: Time (AD-33); Order inside a tick (AD-34); Base facts (AD-35); Novel Pattern 5 (AD-48, AD-64); AD-52 ("edging round an open section, crossing a gap hand over hand, the climb back"); System Location Mapping (`warden_rules.gd`: "crossings, climbs, knockdowns")
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-5-sections-carry-weight-creak-groan-and-fall.md`: Decisions D2, D3; Review Findings; Completion Notes
- `_bmad-output/implementation-artifacts/1-4-the-warden-strips-re-lays-carries-and-reads-the-forearm.md`: AC 10 and D3 (replaced here)
- `_bmad-output/implementation-artifacts/deferred-work.md`: DW-35, DW-43
- Code as of `64b35b0`: `game/watch/sim/*.gd`; `game/watch/night/warden.gd`; `game/watch/debug/**`; `game/tests/watch/*.gd`; `tools/ci.sh`; `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), gds-dev-story, 2026-11-22.

### Debug Log References

- T0 baseline (`tools/ci.sh` at `64b35b0`, before any change): tests 1224 passed, 0 failed, 55 expected; 7 show-me setups; all checks passed.
- T1 red: with the names and stubs in place (constants, `Move` values, `WardenState`/`StartState` fields, the four kinds, stub `SpanRules.open`, geometry and `way_on`), the new tests failed on their checks, not on parsing: test_warden 33, test_span 18, test_consequences 47, test_hands 14, test_span_geometry 12, test_night_sim 3, test_show_setups 2, test_trace 4, test_warden_node 2. The coverage checks ("every kind produced", "the events checked include every kind") stayed red until T8 by design.
- One test of mine was wrong, not the rule: GD-68 "facing the town" from along 14.9 aims at section 4's deck (0.622 m ahead), so that case faces the far pier only; the 12.5 and 11.0 cases cover both ways.
- After the rules (T5) everything but the coverage checks was green on the first run; the bot nights (T8) passed on their first run.
- T12, each rule undone on its own (scratch script, every file restored after): all 17 caught by a failing test: the push count (30 → 29), the 45° comparison, the run's floor check, chaining, turning back, GD-68's share (whole 4 s) and its rounding (floor), the step back from an open section, the step back only from a floor, `strength()` 2, the edging warden's catch, `hang_on()` for an edging warden, the view's crossing cuts, the view's cut while not walking, `StartState.fallen` losing the parts, the GD-68 step, the move wish during a move. And the bot file alone against an edging that does not drift onto the beam line (test_bot_nights.gd alone: both "every path" checks failed on tick 2037, "stepped off s3 at (0.0, -14.64), wanted (2.2, -14.7)", on 6 and on 4 sections; the per-tick x check alone allows an x that does not move, the step-off check does not).

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-22).
- **Rules (sim).** `SpanRules.open()` (no planks, not fallen) and `strength()` with the side beams (`SIDE_BEAM_LOAD` 2 when open, D4). `WardenRules`: D3 of story 1.4 removed (`held_by_bare()` gone); `walk()` then `push()` (D1: 30 ticks of pushing at the stop within 45°, the move in step 1 of the 31st, only if `way_on()`); `begin_move()` (edging from where the feet stand toward the far edge on the nearer beam line, x ±2.2; crossing cut down 1.4 m at the near edge, x kept); `tick_moves()` per move kind (feet from `move_from.lerp(move_to, k / N)`); `end_move()` (step onto a floor 0.3 m in, or chain the next section on the same tick, or turn back toward the town when the far-pier run no longer ends on a floor); `begin_beams()` (GD-68's share, `maxi(roundi(240 × left / 5), 1)`); `on_open()`, `feet_on_floor()`; `step_back()` widened to open sections against `walkable()`; `start_climb()` clears a move's facts. `ConsequenceRules`: `warden_footing` branches on the move (climbing → `hang_on`, edging on a fallen section → caught, crossing → nothing, walking → catch or, with the feet on a floor, step back); new fourth step `warden_on_beams` (GD-68).
- **State.** `WardenState.Move` gains `EDGING`, `CROSSING`; new facts `move_section`, `move_toward`, `move_from`, `move_to`, `move_ticks_total`, `pushed`, all in `values()` (so in `checksum()`, which needed no change). `StartState.fallen`: applied after planks and rails, before weights, parts to lost through the ledger; bad sections, weights and lifts on it are `span.bad_start`.
- **Geometry.** `SpanGeometry.beam_line_x()`, `near_edge()`, `far_edge()`, `edging_point()`, `crossing_point()`, `move_end()` (toward the town exactly `climb_end()`).
- **View.** `warden.gd` cuts while climbing and on `WARDEN_CAUGHT`, `WARDEN_CLIMBED`, `CROSSING_STARTED`, `CROSSING_ENDED` (`CUT_KINDS`); everything else blends, edging included. No view turn at any move.
- **Debug.** Trace: the four kinds are the warden's; the edging kinds print their side. Shows `gaps` and `last_plank`. Bot: `walk` starts with section 1 open (its stop is now along 5.3, pushed into with nothing begun); `strip`'s last plank is GD-68; new `gaps` and `beams` (+ `_script` forms), helpers `_push()` and `_until_moving()`. `test_bot_nights.gd` drops `_held`/`_in_band` and keeps its own record of every move from its `_STARTED` event on every path (place, length, direction, the step off).
- **Tests added or rewritten** in test_warden (walking in both ways and on the left beam, the push, gaps one and two, runs, turning back, `way_on`, the wish ignored, `values()`), test_span (open and the beams, L4, L5, fallen starts and bad ones), test_consequences (four steps, GD-68 from 12.5/11.0/14.9, half way, into a gap, the step back both sides and its negative, the edging warden caught both ways, second settle), test_hands (GD-68 and AC 8 replacing story 1.4's AC 10/D3 block, holds cancelled by an edging and a crossing, presses ignored in both modes, re-lay from either neighbour then walked over), test_night_sim (the push and a fallen start in the checksum; the fields test runs gaps and beams; the "fallen" checksum case now uses 3 weights, since 1 no longer brings an open section down), test_span_geometry, test_warden_node, test_aim_aid (two mid-move rows), test_show_setups, test_trace, test_bot_nights.
- **Found beyond the story's file table:** `test_bot_nights._test_a_walk_that_cannot_arrive_is_a_fault` now uses section 1 open (with section 2 open the bot's walk would edge across and arrive); `test_night_sim._test_checksum_covers_the_load_facts` needed 3 weights (D4).
- **For Sonlm, M2's wording:** M2 says "turn round, look down at section 3's deck from section 4". The edging toward the town goes backward to the view, so after it the warden still faces the far pier, and section 3's deck is already ahead and below; turning round would face section 4's own deck (a re-lay there is refused, DECK_FULL; the first Xvfb run did exactly that). The story text is not mine to change; read M2 as "look down ahead".
- **Ear test:** 120 passed, 23 expected (unchanged).
- After the advisor's closing review, three more tests: the forearm lowered on the tick an edging or a crossing begins (AC 6, test_hands), the warden edging a section at exactly the beams' load of 2 adds no load (AC 3, test_warden), a placed start on a section that starts fallen is `warden.bad_start` (AC 11, test_warden); and the `##` comments of steps 1, 4, 7 and 8 in `night_sim.gd`.
- `tools/ci.sh` on the final tree: all checks passed; tests 1483 passed, 0 failed, 63 expected (baseline 1224 / 0 / 55); 9 show-me setups, each smoke-run.
- M1: partly verified on a virtual display (Xvfb 1280x720, Forward+ on llvmpipe (CPU Vulkan), not a real GPU), real input from a scratch driver holding W, then turning 1257 px and holding W again. Trace of that run: CROSSING s4 1.283 to 9.283 s (8 s), EDGING s2 R 11.033 to 15.033 s (4 s), back EDGING s2 R 16.683 to 20.683 s, CROSSING s4 22.433 to 30.433 s. Frames judged: /tmp/claude-1000/-home-sonlm-project-3d-game/55290bf8-4728-4995-8e26-ff43e23c0c95/scratchpad/M1/frame00000030.png (at the gap's edge), frame00000150.png (hanging in the gap, section 3's deck at eye height), frame00000290.png (on section 3, open section 2's beams ahead), frame00000390.png (mid edging, on the right beam's line), frame00000455.png (on section 1); return leg /tmp/claude-1000/-home-sonlm-project-3d-game/55290bf8-4728-4995-8e26-ff43e23c0c95/scratchpad/M1b/frame00000480.png, 00000560.png, 00000760.png, 00000950.png. Verified: the moves happen, both ways, at their times, and the view is where D2 puts it. NOT verified, needs Sonlm: whether the difference between 4 s and 8 s is felt and whether it ever feels stuck (feel).
- M2: partly verified on a virtual display (same renderer note), --show=last_plank: look down, strip (HOLD_STARTED 0.267 s, PLANK_STRIPPED and EDGING_STARTED s3 R 2.267 s), EDGING_ENDED 5.467 s (3.2 s), then E held facing the far pier: PLANK_RELAID s3 at 9.167 s. Frames judged: /tmp/claude-1000/-home-sonlm-project-3d-game/55290bf8-4728-4995-8e26-ff43e23c0c95/scratchpad/M2/frame00000060.png (strip ring on section 3's deck), frame00000075.png and frame00000120.png (edging, looking down between the beams), frame00000170.png (on section 4 at the right beam's line), frame00000200.png (re-lay ring), frame00000300.png. NOT verified, needs Sonlm: how the edging reads going backward to the view (feel). Wording: no "turn round" is needed for the re-lay (see the note above).
- Agent time: 2026-11-22 14:41 +0700 to 2026-11-22 15:46 +0700 (1 h 5 min), measured by the agent.
- Sonlm's hours: (for Sonlm to fill in)
- **Sonlm's play of M1 and M2 (2026-11-22), in Sonlm's words:** M1: "Why do i slide diagnally at section 2. i can feel the second. The first one feels a bit strange, like i am swimming over to the other section. I only feel stuck when "moving" through the dark". M2: "It work. I slide backward. First time player might not understand. Also i am at 1 plank and can still walk through still look rather strange like i am walking on air".
- **Sonlm's choices on that play (2026-11-22, the recommended option each time):** (1) the edging sidesteps onto the beam line in its first 0.5 s, then goes straight along it (replaces D2's drift over the whole edging; still 4 s, nothing jumps): `WardenConstants.EDGE_SIDESTEP_S`, `NightTicks.edge_sidestep`; (2) the crossing goes hand over hand: reaches of 0.5 m (10 over the gap), each pulled over 60 % of its 48 ticks (eased) and then still, forward only, no bob: `CROSS_REACH`, `CROSS_PULL_SHARE`; both in the new pure `WardenRules.move_point()`; (3) sliding backward (GD-68) kept as built, no view turn: DW-45; (4) walking over a 1-plank section kept (GDD rule), the look is epic 7's: DW-46. Tests pinned first (red), then the rule: the sidestep at ticks 45, 60 and 150 of L2, GD-68's at 135 and 180, L6 now caught on the beam line (x 2.2); a crossing's reach (tick 54 at z -15.462963, still from tick 59 to 78, moving on 79). Undone each on its own (sidestep over the whole edging; crossing linear; pulls with no still): all three caught.
- **Sonlm's replay of M1 (2026-11-22), in Sonlm's words:** the crossing: "It feels like I am walking midair"; the edging: "Yes feels like i am stepping on the beam" (the sidestep: verified by Sonlm). Asked "What is the point of the first crossing. Is the character supposed to walk through missing section": told that GD's validator round made it "no stranding" (an early draft let a gap strand the warden) and that the GDD names nothing to hold. Sonlm chose (recommended): **one rope stays strung across a fallen section**, on its centre line, tied 0.1 m under the deck top at each end and sagging 0.4 m at mid-gap; the warden crosses hanging under it, feet 2.4 m down (eye 0.3 m under its lowest point). The crossing now runs on the rope's line (x 0; the start is a cut anyway). `SpanGeometry.gap_rope_points()`, `GAP_ROPE_*`, `crossing_point(along)`; `WardenConstants.CROSS_HANG_DROP`; `SectionView` draws the rope (`GapRope`, 10 pieces) for a fallen section. GDD write-back: DW-47. Tests first (red), then the code: rope points, the crossing line and height, a crossing begun off the centre line, the view's rope and its pieces, the bot's own crossing check (x 0, 2.4 m down). On a virtual display (Forward+ on llvmpipe, not a real GPU), /tmp/claude-1000/-home-sonlm-project-3d-game/55290bf8-4728-4995-8e26-ff43e23c0c95/scratchpad/M1c/frame00000030.png (the rope across the gap), 00000045.png (cut down under it, the far deck edge above), 00000160.png, 00000270.png (under the far deck): verified that the rope is drawn and the view hangs under it. NOT verified, needs Sonlm: whether it now feels like hanging and pulling rather than walking midair.
- After the rope: `tools/ci.sh` all checks passed; tests 1498 passed, 0 failed, 63 expected. Agent time for the rope: 2026-11-22 16:56 +0700 (first edit) to 17:04 +0700, measured by the agent (the questions before it not measured).
- **Sonlm's second replay of M1 (2026-11-22):** the crossing under the rope: "It feels like hanging now" (verified by Sonlm).
- Settled by Sonlm's replays: the sidestep reads as stepping onto the beam; the crossing under the rope feels like hanging. Still open from M2: how sliding backward reads to a newcomer (DW-45).
- `tools/ci.sh` after these changes: all checks passed; tests 1489 passed, 0 failed, 63 expected.
- Agent time for this follow-up: 2026-11-22 16:10 +0700 (first edit) to 16:18 +0700 (about 10 min, reading the GDD and asking from about 16:05 not measured), measured by the agent.

### File List

- game/watch/sim/consequence_rules.gd
- game/watch/sim/hold_rules.gd
- game/watch/sim/night_event.gd
- game/watch/sim/night_sim.gd
- game/watch/sim/night_ticks.gd
- game/watch/sim/span_constants.gd
- game/watch/sim/span_geometry.gd
- game/watch/sim/span_rules.gd
- game/watch/sim/start_state.gd
- game/watch/sim/warden_constants.gd
- game/watch/sim/warden_rules.gd
- game/watch/sim/warden_state.gd
- game/watch/night/section_view.gd
- game/watch/night/warden.gd
- game/watch/debug/bot/night_bot.gd
- game/watch/debug/show/show_setups.gd
- game/watch/debug/trace.gd
- game/tests/watch/test_aim_aid.gd
- game/tests/watch/test_bot_nights.gd
- game/tests/watch/test_consequences.gd
- game/tests/watch/test_hands.gd
- game/tests/watch/test_night_sim.gd
- game/tests/watch/test_show_setups.gd
- game/tests/watch/test_span.gd
- game/tests/watch/test_span_geometry.gd
- game/tests/watch/test_span_view.gd
- game/tests/watch/test_trace.gd
- game/tests/watch/test_warden.gd
- game/tests/watch/test_warden_node.gd
- game/WATCH.md
- _bmad-output/project-context.md
- _bmad-output/implementation-artifacts/deferred-work.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- _bmad-output/implementation-artifacts/1-6-open-sections-and-gaps.md

## Change Log

- 2026-11-22: Story 1.6 implemented (gds-dev-story). Open sections are edged along a side beam (4 s) and gaps crossed hand over hand (8 s), begun by 0.5 s of pushing straight in (D1), chained one section at a time, turning back when the far-pier run loses its floor; GD-68's edging toward the town when the last plank goes underfoot; the step back from a section that goes open (D3); an open section's strength 2 (D4); an edging warden caught when the section falls; `StartState.fallen`; story 1.4's D3 removed. Shows `gaps` and `last_plank`; bot paths `gaps` and `beams`; DW-35 and DW-43 closed. Status: review.
- 2026-11-22: Sonlm's replay of M1: one rope stays strung across a gap and the warden crosses hanging under it (DW-47 to write it into the GDD). Status: review.
- 2026-11-22: Sonlm's play of M1 and M2. The edging sidesteps onto the beam in its first 0.5 s, then goes straight along it; the crossing goes hand over hand in 0.5 m reaches (pull, then still). Sliding backward and walking over a 1-plank section kept; DW-45 and DW-46 opened. Status: review.
