---
baseline_commit: 62a13e7
---

# Story 1.5: Sections carry weight, creak, groan and fall

Status: done

<!-- Created 2026-11-21 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As the warden,
I want a weakened section to warn me and then give way under too much weight,
so that the bridge itself can be turned against whatever stands on it.

Delivers: GDD Game Mechanics 2 (strength, load, creak, collapse, what falls with a section, the warden catching the edge); Game Mechanics 4 (overload with no rig). GD-19. Architecture AD-33 (countdowns), AD-34 (steps 4, 6, 7, 8), AD-35, AD-48, AD-52 (the climb back is one of the warden's timed moves), AD-64, AD-67. Closes DW-34.

## Acceptance Criteria

Tick numbers below are `sim.tick`, which starts at 0 (AD-33: the first `advance()` is tick 0, its events carry `t = 0.0`). The epic's text counts `advance()` calls from 1 ("seen on tick 1, falls on tick 121"); in sim ticks that is "seen on tick 0, falls on tick 120, `t = 2.0`", which is also the architecture's own test (120 advances with no fall, the 121st falls) and AD-33's "a condition first true during tick T (a section overloaded) begins its countdown on T".

1. **Strength.** Given a section, when its strength is asked for, then it is the number of planks on it, 0 to 8, worked out each time and never stored (AD-35). Load is worked out each time too: the test weights on the section, each a load of 1. The warden is never part of it.
2. **Creak.** Given test weights placed through a `StartState`, each a load of 1, when a section's load equals its strength (and is more than 0, decision list), then the section creaks for as long as that holds: `CREAK_STARTED` on the first tick it holds, `CREAK_STOPPED` on the first tick it no longer does.
3. **Groan, then fall.** Given a section with 3 planks and 4 test weights from the start, when 2 s pass, then `GROAN_STARTED` is on tick 0 (`t = 0.0`) and `SECTION_FELL` on tick 120 (`t = 2.0`), and no `SECTION_FELL` on any tick before 120. The section falls for good.
4. **It holds.** Given a groaning section, when its load is back at or under its strength before the 2 s are up, then it holds: `GROAN_STOPPED`, no fall, and (if load now equals strength) `CREAK_STARTED` on the same tick. A later overload starts a fresh 2 s. How the load drops in this story is decision D1.
5. **What falls with it.** Given a section that falls, when what follows is settled (`ConsequenceRules.settle()`), then the weights on it fall (gone from the span), the planks and rail ropes still on it are lost (`PartPlace.lost()`, through the ledger), it is a gap for the rest of the night and cannot be re-laid, and planks and ropes still total 48 and 12 with the lost ones counted.
6. **The warden on it.** Given the warden standing on a section that falls, when it falls, then the warden catches the edge (`WARDEN_CAUGHT`) and is back on the nearest standing section toward the town, or on the landing, after 5 s (300 ticks: `WARDEN_CLIMBED` on tick F + 300), with no input but look until then (decision D3 says where the warden is meanwhile). The parts in hand are kept. (The wound that goes with it is epic 4.)
7. **Overload with no rig.** Given a section with 4 planks and 3 test weights, when the warden strips 2 planks from it, then it creaks from the tick the first strip completes (`PLANK_STRIPPED` then `CREAK_STARTED` on that tick), and on the tick the second completes it stops creaking and groans (`PLANK_STRIPPED`, `CREAK_STOPPED`, `GROAN_STARTED`), then falls 120 ticks later.
8. **Section 6.** Given section 6 (the def's last), when it is overloaded, then it falls like any other. A warden on it climbs onto the landing. (That this loses the night is epic 3.)
9. **The warden adds no load.** Given the warden standing on a section, then the section's load is the same as with the warden elsewhere (a section at 3 planks with 3 weights only creaks with the warden on it, and never groans).
10. **DW-34.** Given a hold running on a section that falls on tick F, then `HoldRules` cancels it on tick F + 1 (step 2; `HOLD_CANCELLED`, no part moves), also when the hold would have completed on F + 1. For a strip, a rail strip and a re-lay.

"Section 6" is the town section, `def.section_count` (section 4 on the 4-section test def); "8 planks" is `def.planks_per_section`. No literal 6 or 8 outside `night_defs.gd` and tests (AD-42).

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setups below. Build order (AD-46): failing test first; constants, state, tick step, rule and events, consequences; then the view; then the bot path, the show-me setups and the manual checks. Build-order step 7 (the sound-and-cue row) waits for epic 2: `content/sound_cues.gd` does not exist yet, and in epic 1 a creak, a groan and a fall are events in the trace and things seen; nothing is heard.

**Manual checks for Sonlm** (an agent cannot verify these headless; never report one as verified unless judged from frames as the dev-story chores describe):

- **M1** (`--show=overload`; reworded by the code review of 2026-11-22, Sonlm): standing on section 5 just short of section 4, look down at section 4's deck (4 planks, 3 weights) and strip it until it falls. After each strip, look up along section 4: after the first it creaks (the deck bows a little), after the second it groans (the bow deepens), and the 2 s between "too much" and the fall can be seen coming (decision D4). The bow is deepest at mid-section and close to nothing at the ends, so it cannot be seen looking straight down at the near end. The gap then reads black. Feel, whether D4's sizes (5 cm, 25 cm) are enough, and the 2 s "seen coming" need Sonlm.
- **M2** (`--show=fall_under`): standing on section 4 (4 planks, 3 weights) near its town end, clear of the weights, strip your own deck twice (look down just ahead of your feet); it falls under you, you hang at the edge of section 5 for 5 s (decision D3; at the catch your view is turned to face section 5, then you can look but not move or act), then you are up on section 5 with your planks still in hand (Tab). How the hang and the climb read needs Sonlm.

## Decisions for this story

Points that neither the GDD nor the architecture settles. **Sonlm chose the recommended option for all four on 2026-11-21** (see "Decisions taken with Sonlm" in Dev Notes).

- **D1. How a groan that holds (AC 4) is reached.** Test weights never move, and the only thing that raises strength is a re-lay: 3 s (180 ticks) against a groan of 2 s (120 ticks), with one action at a time, so a re-lay can never start in time. Without a way for load to drop, AC 4 can be reached by no command and no bot path, and `GROAN_STOPPED` breaks the coverage check (AD-63). (Recommended) **A weight can be lifted off on a set tick:** `StartState.lifts`, each `Vector2i(section, tick)`: on that tick (step 6, where the dead will be) one weight leaves that section, with a `WEIGHT_LIFTED` event. It stands in for one of the dead walking off a section (epic 3), and is set up only through a `StartState`, like the weights. Declined: test the hold only as a pure function and leave `GROAN_STOPPED` out of the coverage check until epic 3 (the stateful branch would have no test through the tick, as DW-34 had).
- **D2. The warden beside a section that falls.** The deck is reached only within about 1.2 m of the feet, so stripping a section from the next one puts the warden close to its edge, often within 0.3 m. When it falls, a warden whose feet are on the next section but within 0.3 m of the new gap can no longer stand there (`can_stand` is false), and today's `walk()` would freeze them. (Recommended) **The warden steps back:** in the same tick the feet move straight away from the gap until they are 0.3 m from its edge (at most 0.3 m, blended like a step, not cut); a hold on another target goes on (0.3 m is under the 0.5 m limit). Declined: like D3 of story 1.4, the warden stays and walks out (needs a temporary ledge at the lip of the gap; more code, and the warden could walk to the very edge); the warden falls with it (the usual stance for stripping from the next section would drop the warden nearly every time).
- **D3. Where the warden is during the 5 s.** (Recommended) **Hanging from the edge caught:** the feet go at once to the near edge (far-pier side) of the section, or the landing, being climbed onto, at the same x, 1.4 m below the deck top, so the eye is 0.2 m above the deck and looks along its planks; after 5 s the feet are on that deck, 0.3 m in from the edge. Both moves are cuts (the view snaps). Declined: the warden stays where they stood, over the gap, for the 5 s, then is cut onto the deck.
- **D4. How a creak, a groan and a fall are seen** (gray box; no sound until epic 2; GDD: "A section's creak and groan: its planks bow"). (Recommended) **The deck bows, then the section drops away:** creaking, the planks sag in a shallow curve, deepest at mid-section, 5 cm; groaning, the sag deepens steadily over the 2 s to 25 cm, read from the groan's ticks left (state, not a timer); at the fall every part of the section (planks, ropes, beams, posts, weights) drops out of sight over about 1.5 s, and the gap reads black. No shake, no flash, nothing flickers. Declined: the same bow, with the section gone at once on the fall.

Settled without a question (each follows from the documents; listed so Sonlm can revisit):

- **A section with nothing on it does not creak.** Read literally, a bare unloaded section (load 0, strength 0) is "at its limit"; the `walk` and `span_counts` starts have one. A creak needs a load above 0. A section with no planks and a weight on it (strength 0, load 1) groans and falls after 2 s by the general rule; story 1.6 replaces that with the side beams' load of 2 (GDD: "the side beams carry a load of 2").
- **The 2 s is counted from the first tick of overload and is not restarted by more load.** A section whose load goes from 4 to 6 over strength 3 still falls 120 ticks after the first overload. One that held (AC 4) and is overloaded again starts a fresh 120.
- **The fall is decided at step 7 of tick T + 120.** A load that drops on that tick's step 6 (a lift) saves the section; a strip completing in step 2 of a tick counts in step 7 of the same tick.
- **"Fallen" is a stored base fact** (`SpanState`), like a plank count: a section with no planks may be open or fallen, so it cannot be worked out. The creak flag and the groan's ticks left are stored too: they are a phase and a countdown (architecture, State Patterns), needed to emit an event on the tick a creak starts or stops. Strength and load stay computed (AD-35). All three go into the checksum.
- **A fallen section has no deck.** `LookRules` neither targets it nor is blocked by it; a press at it finds nothing (`NO_ACTION_HERE`, as at the sky). `HandRules.check()` refuses a re-lay onto a fallen section with `NO_ACTION_HERE` (as it does a rail strip of a rail that went: "a target is never a fallen deck; this is for a hold whose section fell"), so no new `Reason`. The ledger has no room on a fallen deck (`fits_at` 0: a move onto it is `span.no_room` and moves nothing). D3's `held_by_bare()` never counts a fallen section.
- **The hold cancel is on F + 1.** The fall is step 7 of tick F; `HoldRules` is step 2, so it sees the fall on F + 1. The architecture says so ("A hold that has become impossible is cancelled by `HoldRules` on the next tick, not here"). DW-34's text ("on the tick it falls") is corrected when it closes. `HoldRules.tick()` already checks before progress, so a hold that would complete on F + 1 is cancelled, not completed.
- **The climb.** It begins in step 8 of tick F (`WARDEN_CAUGHT`), counts down in step 1 of each later tick, and ends in step 1 of F + 300 (`WARDEN_CLIMBED`); for the rest of that tick the warden is free (walks, presses are taken). Where it ends is worked out when it ends: the first section toward the town from the fallen one that has planks and has not fallen, else the landing. So if the section being climbed onto falls or goes bare during the 5 s, the warden comes up on the next standing one. During the climb the move wish is ignored, and every press (hands and Tab) is ignored with no event, as during a hold; `HoldRules` cancels a running hold and lowers the forearm on F + 1. It is a timed move of `WardenRules` (AD-52), run in step 1 where the warden moves; story 1.6's edging and crossing follow the same pattern.
- **Who falls with a section.** The warden falls when the feet (the point itself) lie on the fallen section's floor and on no floor of a section that has not fallen, nor on the landing. A warden on a D3-held bare section that falls (story 1.4) falls with it. Feet on a shared edge with a standing section are on that section (then D2 applies).
- **Test weights are a count per section in `SpanState`**, as the architecture's test example writes them (`start.weights[3] = 4`). Its other sketch ("a weight is a kind of `DeadState`") cannot be followed yet: `DeadState` arrives in epic 2 (warnings) and 3 (the rest). Recorded for epic 3 as a new deferred item.
- **No event of their own for the weights and parts that fall.** `SECTION_FELL` says it; state shows what is left; the view animates the nodes it already has (it handles events before it reconciles, AD-49). The lift of D1 does have one (`WEIGHT_LIFTED`): it is a change on a standing section.
- **Event names** fit the trace's 17-letter kind column: `CREAK_STARTED`, `CREAK_STOPPED`, `GROAN_STARTED`, `GROAN_STOPPED`, `SECTION_FELL` (the architecture's own name), `WEIGHT_LIFTED`, `WARDEN_CAUGHT`, `WARDEN_CLIMBED`. Only sections creak and groan, so those kinds need no "who" (architecture: the kind names which only "where two things can do the same").

## Tasks / Subtasks

- [x] **T0. Baseline.** Run `tools/ci.sh` before any change and write the counts in the Debug Log (story 1.4 ended at 846 passed, 0 failed, 48 expected; the aim aid commits since then added tests, so read the real number). Re-read DW-34 and DW-35.
- [x] **T1. Failing tests first (AD-46)**, GDD numbers written out with their source in a comment, never read from the constants. Situations only through a `StartState` on the test's own `NightDef`, then commands and ticks (Dev Notes "Tests").
  - [x] 1.1 `test_span.gd`: strength = planks and load = weights (AC 1); creak start and stop (AC 2); 3 planks + 4 weights: `GROAN_STARTED` tick 0, no fall through tick 119, `SECTION_FELL` tick 120 with `t == 2.0` (AC 3); a lift that saves it, at "under" and at "equal" (AC 4); a lift on tick 120 itself saves it; a deeper overload does not restart the 2 s; an overload after holding starts a fresh 120; 4 planks + 3 weights stripped twice by commands (AC 7, literal ticks); section 6 (def's last) overloaded falls (AC 8); no creak with load 0; a bare section with a weight groans and falls; `StartState.weights` and `lifts` validation faults (`span.bad_start`).
  - [x] 1.2 `test_consequences.gd` (new): weights gone, parts lost and totals still 48/12 (AC 5); a fallen section is never re-laid (`fits_at` 0; E at the gap is `NO_ACTION_HERE`); the warden on it catches the edge and climbs (AC 6) with literal positions (Dev Notes "The climb"); the climb onto the landing from section 6 (AC 8); the climb ends on the next standing section when the first one fell during it; parts in hand kept; D2's step back with literal positions; `settle()` runs its steps in a fixed order (a list compared literally, like the tick steps) and a second run in the same tick changes nothing.
  - [x] 1.3 `test_hands.gd`: DW-34 / AC 10: a strip hold, a rail-strip hold and a re-lay hold on a section that falls on tick F are cancelled on F + 1, nothing moves; the strip hold set to complete on F + 1 is cancelled; during the climb every press and Tab is ignored (no event, no hold); a hold running when the warden falls is cancelled on F + 1; a forearm raised when the warden falls is lowered on F + 1.
  - [x] 1.4 `test_look.gd`: a fallen section's deck is not a target and does not block a target behind it.
  - [x] 1.5 `test_warden.gd`: the move wish does nothing during the climb; D3's `held_by_bare()` never returns a fallen section; AC 9 (the warden adds no load).
  - [x] 1.6 `test_night_sim.gd`: the checksum changes with each new base fact (weights, a lift taken, fallen, creak, groan ticks, the warden's timed move); the fields test also runs the new bot path so every kind is seen; `NightEvent` field list unchanged.
- [x] **T2. Constants** (Dev Notes "Constants"): `SpanConstants.GROAN_S`, `TEST_WEIGHT_LOAD`; `WardenConstants.CLIMB_BACK_S`, `HANG_DROP`; `NightTicks.groan`, `climb_back`.
- [x] **T3. State.** `SpanState`: fallen, creaking, groan ticks left, weights, pending lifts; `fits_at` 0 on a fallen deck; `values()` for the checksum. `StartState.weights`, `StartState.lifts`. `WardenState`: the timed move (`Move.WALKING`, `Move.CLIMBING`), its ticks left and the section it fell from. `NightSim._apply_start` (weights and lifts, validated), `checksum()`.
- [x] **T4. The tick (AD-34; step list unchanged).** Step 1: the climb counts down before the walk. Step 4 and step 8: `ConsequenceRules.settle(self)`. Step 6: lifts. Step 7: `SpanRules.tick_loads(self)`. Update each step's `##` comment (several name "story 1.5").
- [x] **T5. Rules and events.** `NightEvent`: 8 kinds with their "Fields:" lists. `SpanRules`: `strength()`, `load_on()`, `creaks()`, `overloaded()` (pure), `tick_loads()`, `take_lifts()`. `ConsequenceRules` (new, `sim/consequence_rules.gd`): `settle()` and its named steps. `WardenRules`: `fell_from()` pure footing query, `start_climb()`, the climb in `walk()` (or a `tick_moves()` it calls first), `climb_target()`, `step_back()` (D2). `HoldRules`: while the warden is not walking, presses (hands and Tab) are ignored and a running hold is cancelled and the forearm lowered in `tick()`. `HandRules.check()`: re-lay on a fallen section. `LookRules`: skip fallen decks.
- [x] **T6. Geometry.** `SpanGeometry.weight_box(section, i)` (Dev Notes "Geometry"); `hang_point()` and `climb_end()` (or equivalents) so no coordinate is typed in a rule.
- [x] **T7. View** (D4; Dev Notes "View"): `SectionView` draws weights, bows the planks from state, drops everything on `SECTION_FELL` and draws nothing for a fallen section; the fall effect is view-only and freed when done. `warden.gd`: `snap()` on `WARDEN_CAUGHT` and `WARDEN_CLIMBED`, `push()` otherwise. `AimAid.would_start()` mirrors the new `HoldRules` gate. Tests: `test_span_view.gd`, `test_warden_node.gd`, `test_aim_aid.gd`.
- [x] **T8. Bot path (AD-63)**: `NightBot.overload` (in `paths()`) plus `overload_script()` with no wander, on 6 and 4 sections; `test_bot_nights.gd`: `_test_overload_reaches_its_cases`, and the per-tick checks learn "fallen" and the climb (Dev Notes "Bot").
- [x] **T9. Show-me setups (AD-56)**: `overload` and `fall_under` (Dev Notes "Show-me setups"); `test_show_setups.gd`.
- [x] **T10. Trace**: lines for the 8 new kinds (Dev Notes "Trace"); `test_trace.gd`.
- [x] **T11. Docs**: `game/WATCH.md`; `_bmad-output/project-context.md`; `deferred-work.md` (close DW-34; note on DW-35; new items, Dev Notes "Docs").
- [x] **T12. CI and manual checks**: `tools/ci.sh` green; each rule undone on its own to see a test fail (story 1.4's habit); the end-of-story chores (Xvfb frames of both shows, agent time, commit; `_bmad/custom/gds-dev-story.toml`). M1 and M2 stay Sonlm's.

### Review Findings

Code review of 2026-11-22 (gds-code-review; Blind Hunter, Edge Case Hunter, Acceptance Auditor; the diff `62a13e7..edf6018`, 3,519 lines, of which `game/` is 2,981). Each reviewer read its whole diff. No high-severity finding. The Acceptance Auditor found AC 1 to 10 met, each with a test that fails if its rule is undone; nothing the story said to preserve was changed and nothing was built ahead. The reviewers ran no tests. 3 decisions, 18 patches, 0 deferred, 10 dismissed. Sonlm took the recommended option for each decision and chose "apply every patch"; all are applied. `tools/ci.sh` then: all checks passed, 1224 passed, 0 failed, 55 expected (was 1166 and 54); 7 shows, each smoke-run. Each fix was undone on its own to see a test fail: 23 undone, 22 caught; the one survivor is the 1-tick floor of a groan, which no `StartState` can reach. Three patches change no behaviour a test can tell apart and are not proven: that floor, the bow's place asked of the geometry (same numbers at 8 places), and the aim aid (documented, not changed). M1 and M2 were then rendered again and judged by the agent (Completion Notes); the story stays in `review` until Sonlm has run both shows.

- [x] [Review][Decision] The bow cannot be seen from M1's own stance — M1 has the warden on section 5 looking steeply down at the near end of section 4. The sag is `depth x 4u(1 - u)`, so the plank place nearest section 5 (u 0.94) gets 23% of it: 1.2 cm creaking, 5.9 cm at the groan's end, seen from straight above, where a drop of any size hardly shows. The dev record's frames 70 and 140 look the same. Looking along the section it shows as about 12 px over the 2 s. With no sound until epic 2, the bow is the only warning, so M1 as worded cannot pass [game/watch/night/section_view.gd:142]. Options: reword M1 to look along section 4 after the strips and keep D4's sizes for Sonlm to judge in play; the same with a deeper bow; or add a cue that shows from straight above. Decided by Sonlm: reword M1, keep the sizes. Done: M1 and `WATCH.md` reworded; rendered looking along (Completion Notes): the groan shows, the creak hardly does.
- [x] [Review][Decision] The edge the warden hangs from falls during the climb, and the warden hangs in mid-air until the cut — `start_climb()` sets the hang point once; `warden_footing()` skips a climbing warden; the end is worked out again only when the 300 ticks are up, so the feet stay 1.4 m below an edge that is gone, then cut a whole section further (5.3 m). Neither the GDD nor the architecture covers it; the dev record chose "left as it is" (Completion Note 3) without asking, and no deferred item tracks it. `_test_the_climb_ends_on_the_next_standing_section` checks nothing about the feet between ticks 240 and 420, and the bot accepts any hanging position at y -1.4. Reached only through a `StartState` in this story; common once the dead load sections (epic 3) [game/watch/sim/consequence_rules.gd:52] [game/watch/sim/warden_rules.gd:172]. Options: catch the next edge with the 5 s still running; catch the next edge with a fresh 5 s; or leave it and record it for epic 3. Decided by Sonlm: catch the next edge, the same 5 s. Done: `WardenRules.hang_on()`, called by `warden_footing()` for a climbing warden, moves the feet in step 8 of the tick the edge fell; no event; the warden's node snaps while climbing; the unit test pins the feet on tick 240 and to 419, and the bot test checks the hang edge by its own arithmetic every tick.
- [x] [Review][Decision] Straight after the catch the screen is nearly all black — the catch keeps the warden's view, so a warden who was looking down toward the far pier sees black with a strip of deck at the edges (the dev record's M2 frame 208) until they turn round toward the town. D3 says "the eye is 0.2 m above the deck and looks along its planks", and `WATCH.md` says "hang there for 5 s, looking along its deck"; neither is true until the player turns [game/watch/night/warden.gd] [game/WATCH.md:89]. Options: turn the view to face the edge at the catch; or leave the view alone, correct `WATCH.md`, and judge it in M2. Decided by Sonlm: turn the view. Done: on `WARDEN_CAUGHT` the warden's node cuts its yaw to face the town and its pitch to level (`Warden.TOWN_YAW`); the sim gets it through the next `set_view`, no rule changed; nothing else turns the view (not a second edge, not `WARDEN_CLIMBED`).
- [x] [Review][Patch] (medium) D2's step back counts toward a running hold's 0.5 m limit, so a hold on another target can be cancelled for distance the player never walked: a hold begun at along 19.7, walked to 20.1 (0.4 m), stepped back to 20.3, is 0.6 m from where it began and is cancelled on F + 1. D2 says "a hold on another target goes on" [game/watch/sim/warden_rules.gd:203] [game/watch/sim/hold_rules.gd:54]
- [x] [Review][Patch] (medium) A piece taken off the section on the tick it falls is drawn falling too: `fall()` gathers the nodes the last tick drew, before the view reconciles, so a plank stripped (step 2) or a weight lifted (step 6) on the fall tick drops into the gap while it is also in the hand or gone. The story's own test has that tick (`120 PLANK_STRIPPED s4`, `120 SECTION_FELL s4`) [game/watch/night/span_view.gd:34] [game/watch/night/section_view.gd:94]
- [x] [Review][Patch] (medium) `step_back()`'s far-pier side is run by no test: every D2 case and the bot stand on the town side of the gap (along 20.1, 30.1, `section_start(c) + 0.1`), so a sign slip in the other branch fails nothing (story 1.4's review asked for both directions of a rule) [game/watch/sim/warden_rules.gd:211]
- [x] [Review][Patch] (medium) No test for a warden held on a bare section (story 1.4's D3) when that section falls: "Who falls with a section" says they fall with it. Reachable through a `StartState`: one plank and one weight, the last plank stripped underfoot, the fall 120 ticks later [game/tests/watch/test_consequences.gd]
- [x] [Review][Patch] (medium) The two `fallen` clauses in the bot test's own `_held` arithmetic cannot fail: the first is dead (the erase loop below it runs in the same call before `_held` is read), the second only matters when the rule is already wrong. The Debug Log says so; the story's "every rule undone must fail a test" is unmet for them [game/tests/watch/test_bot_nights.gd:41]. Done: the dead clause is removed; the second stays as a guard, said to be unproven in a comment and on DW-43 (story 1.6, whose paths bare sections that can then fall)
- [x] [Review][Patch] A fallen section's rail still has room in the ledger: `fits_at()` returns 0 for a fallen deck only, so a rope moved onto a fallen section's rail is accepted with no fault and lost at the next settle. The record says "a fallen section has no room in the ledger" [game/watch/sim/span_state.gd:188]
- [x] [Review][Patch] A groan length of 0 ticks never falls: `groan_left > 0` is both the phase and the countdown, so with `ticks.groan == 0` an overloaded section emits `GROAN_STARTED` every tick for good. The view guards this case; the rule does not [game/watch/sim/span_rules.gd:84]. Done: a groan lasts at least 1 tick. Not proven by a test: a groan of 0 ticks cannot be reached through a `StartState`
- [x] [Review][Patch] The bow takes a plank's place along the section from `SpanGeometry.ORDER_PLACES`, where the weights two lines below ask the geometry; with more places than 8, `u` passes 1 and those planks bow upward [game/watch/night/section_view.gd:149]
- [x] [Review][Patch] Every `SectionView` runs `_process` each frame all night; it is needed only while a fall is dropping [game/watch/night/section_view.gd:126]
- [x] [Review][Patch] Tab or a hand button still held when the climb ends: the forearm is lowered with Tab down and stays down until a fresh press. That matches the mode-change rule (idle hands), but no test pins it and neither `HoldRules`' header nor `WATCH.md` says it [game/watch/sim/hold_rules.gd:47]
- [x] [Review][Patch] The reaching test lets the rule judge itself: "creak started", "groan started" and "groan stopped" are decided by `SpanRules.load_on()` and `strength()`, and "creak stopped" and "weight lifted" by the event alone; the story asked for each case told from events, commands and state (weights against planks) [game/tests/watch/test_bot_nights.gd]
- [x] [Review][Patch] Checks of AC 9 that cannot fail: `load_on(section, span)` never receives the warden, so comparing a span with and without the warden is true by its signature. Only the 300-tick check (creaks, never groans) proves it [game/tests/watch/test_warden.gd:296] [game/tests/watch/test_span.gd:244]
- [x] [Review][Patch] "dw34: a strip begun on tick 30" presses with `sim.tick == 29`, so the hold begins on 29; the case run is not the one named [game/tests/watch/test_hands.gd:803]
- [x] [Review][Patch] "The next standing section" means two things: `climb_target()` passes a bare section that has not fallen (as the story says: "has planks and has not fallen"), while `WATCH.md` and `WardenConstants` say "the next standing section" and `_standing_floors()` counts bare ones as standing. No test has a bare section between the fall and the target [game/watch/sim/warden_rules.gd:157] [game/WATCH.md:88] [game/watch/sim/warden_constants.gd:15]
- [x] [Review][Patch] `WATCH.md`'s sample trace reads as one run and cannot be one: section 4 falls with no groan of its own, and two `WARDEN_CLIMBED` lines share t 7.000 [game/WATCH.md:103]
- [x] [Review][Patch] The aim aid shows "not ready" on the climb's last tick though a press on the next tick is taken; its test table leaves the case out (Completion Note 7). Debug-only, DW-41 [game/watch/debug/aim_aid.gd:84]. Not changed, documented: the climb ends in step 1 of the next tick and the cut changes what is looked at, so nothing read on that tick says what a press would start; `would_start()`'s comment and the test's header now say so
- [x] [Review][Patch] `_test_steps_alone` runs the sim's private steps by a literal index (`sim._steps.slice(0, 7)`): a renumbered tick silently changes what it sets up [game/tests/watch/test_consequences.gd:297]
- [x] [Review][Patch] The File List leaves out `_bmad-output/implementation-artifacts/sprint-status.yaml`, which the story's commit changed

Dismissed (10), with the reason:

- A warden on the far-pier side of a gap has no way back to the town: that is story 1.6's crossing (8 s, hand over hand), listed under "Not in this story".
- A `SectionView` reused for a second night would stay "gone": `night.gd` builds a new `SpanView` for each night.
- `tick_moves()` ends any timed move as a climb: the climb is the only timed move; story 1.6 adds its own when it adds edging and crossing.
- The `settle()` order test restates the list: the story asked for the list compared literally, like the tick steps.
- The "settle twice emits nothing" check might be blind: `advance()` returns everything emitted since the last one, so an event from the extra `settle()` would be in the list checked.
- One expected error beside a fault count of 2: `WatchFaults.report()` logs a code once and counts every report.
- The bot's third strip lines up only while a strip and a groan are both 120 ticks: both are GD-19's numbers, and the tests hold them as literals by rule.
- `HandInput` iterated by its size: the enum has no explicit values.
- `add_weights()` and `add_lift()` called from `NightSim._apply_start()`: disclosed (Completion Note 9); weights are not parts, so the ledger has no say.
- The Tab guard in `_press_forearm` changes nothing that `tick()` does not already do: kept as the story's stated rule (Completion Note 6).

## Dev Notes

### What this story is

The span starts to bear weight. Each tick (step 7) every standing section compares its load (test weights, 1 each) with its strength (its planks): equal and above 0 is a creak, above is a groan that becomes a fall after 120 ticks unless the load drops back. A section that falls is a gap for good. Then `ConsequenceRules.settle()` (steps 4 and 8, a fixed list of small named steps, AD-48, AD-64) settles what follows: the weights on it fall, its parts are lost through the ledger, a warden on it catches the edge and climbs back toward the town in 300 ticks, and a warden beside it steps back from the gap (D2). The view bows a loaded deck and drops a fallen section (D4).

**Not in this story** (do not build ahead): open sections' side beams and their load of 2, edging (4 s), crossing a gap hand over hand (8 s), the warden on a section whose last plank goes (all story 1.6; D3 of story 1.4 stays as it is for a bare section that has not fallen); the dead, hooks, a Diver's landing load (epics 2 and 3); losing the night when section 6 falls (epic 3); the wound on the climb (epic 4); rigs (epic 4); sound of any kind (epic 2 on); the overhead read-out's dashed fallen section (story 1.7, which reads `fallen` from this story). **A section that starts fallen** (`StartState` has no `fallen` field in this story: a fall is reached only by load and 120 ticks); story 1.6's `gaps` show and story 1.7's read-out AC need one, and add it there. No HUD. Gray boxes.

### Current state of the files this story changes (read 2026-11-21, commit `62a13e7`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/sim/night_sim.gd` | 13 steps; 1 (walk, look, commands), 2 (holds), 5 (`NIGHT_STARTED`) do work; 4, 6, 7, 8 are `pass` with comments naming story 1.5 / epic 3. `_apply_start` moves `StartState` planks and rails to the hand; `_place_warden`; `refuse()`; `checksum()` = tick, rng state, position, yaw, pitch, holds, part counts, hands | Steps 1, 4, 6, 7, 8; `_apply_start` for weights and lifts; `checksum()` adds the span's new facts and the warden's move | The step names and order (`test_night_sim.gd` compares them literally); every fault code; `emit()` stamping `t`; `_place_warden` after the planks |
| `game/watch/sim/span_state.gd` | Planks, ropes, hand, lost; counts change only via `add_at()` from `move_parts()` (a test greps `add_at(`) | Fallen, creaking, groan left, weights, lifts; `fits_at` 0 on a fallen deck; `values()` | `add_at()` only from `span_rules.gd` (the grep test); `counts()` order; `total()` |
| `game/watch/sim/span_rules.gd` | `move_parts()` only | Load, strength, creak, overload, `tick_loads()`, `take_lifts()` | `move_parts()`'s four guards exactly |
| `game/watch/sim/span_constants.gd` | Sizes, hold times, town floor; header says load times "arrive with their rule (story 1.5)" | `GROAN_S`, `TEST_WEIGHT_LOAD` | The rest |
| `game/watch/sim/start_state.gd` | planks, stripped_rails, warden_along; "Test weights arrive in story 1.5" | `weights`, `lifts` | The rest |
| `game/watch/sim/warden_state.gd` | `position` only; "timed moves join this in 1.5, 1.6, epic 4" | The timed move | `position` |
| `game/watch/sim/warden_constants.gd` | Walk speed, eye height, clearance | `CLIMB_BACK_S`, `HANG_DROP` | The rest |
| `game/watch/sim/warden_rules.gd` | `walk()` with D3 (`held_by_bare()` adds every bare section under the feet or a probe); `can_stand`, `stands_on`, `walkable`, `reach` pure | The climb; `held_by_bare()` skips fallen sections; footing and step-back queries | `can_stand`/`stands_on`/`reach` pure and unchanged in meaning; exact stops (tests at 0.001 m); D3 for bare sections that have not fallen |
| `game/watch/sim/hold_rules.gd` | Owns holds; `tick()` checks move limit and `HandRules.check()` before progress | The warden-not-walking gate in `_press_hand`, `_press_forearm` and `tick()` | Everything else (Press once, grace, mode change) |
| `game/watch/sim/hand_rules.gd` | `check()` per action | Re-lay on a fallen section is `NO_ACTION_HERE` | Hand before deck for a re-lay (Sonlm, 2026-11-21) |
| `game/watch/sim/look_rules.gd` | Every deck (planked or not) a target; standing rails; landing and far pier block | Fallen decks skipped | The rest |
| `game/watch/sim/span_geometry.gd` | Every shape | Weight boxes; hang and climb-end points | Every existing shape and the plank order |
| `game/watch/sim/night_event.gd` | 7 kinds | 15 kinds | Fields and defaults; the "Fields:" convention |
| `game/watch/sim/night_ticks.gd` | strip, rail, re-lay, grace | `groan`, `climb_back` | `of()`, `TICKS_PER_SECOND` |
| `game/watch/night/section_view.gd` | Beams and posts made in `_init`; planks and rails reconciled | Weights, bow, fall effect, nothing when fallen | Every box from `SpanGeometry`; `_drop()` frees names at once |
| `game/watch/night/span_view.gd` | Builds piers, landing, sections; reconciles each tick | Passes events to sections (for the fall), holds falling pieces if they move out of the section | Box helper, colours |
| `game/watch/night/warden.gd` | `on_tick` pushes the position | Snaps on `WARDEN_CAUGHT` / `WARDEN_CLIMBED` | D2 of 1.3 (Esc, the recapture click); no bob, no roll |
| `game/watch/debug/aim_aid.gd` | `would_start()` mirrors `HoldRules._press_hand` gates | Adds "the warden is walking" | DW-41: it is temporary |
| `game/watch/debug/bot/night_bot.gd` | `span_counts`, `walk`, `strip` (+ `strip_script`) | `overload` (+ `overload_script`) | Existing paths unchanged |
| `game/watch/debug/show/show_setups.gd` | 5 setups | `overload`, `fall_under` | Existing rows |
| `game/watch/debug/trace.gd` | `WARDEN_KINDS`; `%-17s` kind column; `NIGHT_STARTED` line exact (CI greps it) | New kinds | `NIGHT_STARTED`'s line |
| `game/tests/watch/test_bot_nights.gd` | Totals, faults, stands-where-it-can by its own arithmetic incl. D3 (`_held` from `PLANK_STRIPPED`); coverage of kinds and reasons | Fallen and the climb in its arithmetic; overload cases | Its own arithmetic (the rule may not be its own judge) |
| `game/tests/watch/test_night_sim.gd` | Steps literal; fields test runs 600 ticks + the strip bot and requires every kind | Also runs the overload bot | The literal lists |

`consequence_rules.gd` and `test_consequences.gd` do not exist yet.

### Constants

| Constant | Value | Source |
|---|---|---|
| `SpanConstants.GROAN_S` | 2.0 | GD-19, GDD Game Mechanics 2: "groans for 2 s, then falls for good". (The architecture's Data Patterns example calls it `CREAK_GROAN_S`; the creak has no length, so `GROAN_S`.) |
| `SpanConstants.TEST_WEIGHT_LOAD` | 1.0 | The epic's AC: "each a load of 1" (a Grappler's load, GD-19) |
| `WardenConstants.CLIMB_BACK_S` | 5.0 | GDD Game Mechanics 2: "climbs back ... in 5 s" |
| `WardenConstants.HANG_DROP` | 1.4 | D3: the feet below the deck top while hanging; gray-box size, not a rule, tuned in M2 |
| `NightTicks.groan`, `climb_back` | 120, 300 | Converted once (AD-33) |

Load is a `float` (the architecture's `load_on` returns one; a hatchling will be 0.5 in epic 3). Every value is a multiple of 0.5, exact in binary, so `==` against an `int` strength is safe; say so in the `##` comment.

### State

- **`SpanState`** gains, per section: `_fallen: Dictionary[int, bool]`, `_creaking: Dictionary[int, bool]`, `_groan_left: Dictionary[int, int]` (0 = not groaning), `_weights: Dictionary[int, int]`; and `_lifts: Array[Vector2i]` (section, tick) still to come. Getters: `fallen(n)`, `creaking(n)`, `groan_left(n)`, `weights(n)`. Setters are called only by `SpanRules` and `ConsequenceRules` (name them plainly, e.g. `set_fallen`, `set_creaking`, `set_groan_left`, `take_weight`, `clear_weights`); a bad section is `span.bad_section` as today. `fits_at(PLANK, deck(n))` is 0 when `n` has fallen, so the ledger moves nothing onto it (`span.no_room`); `holds()` stays true, so `settle()` can move parts **off** it to `lost`. `values()` returns every new fact in a fixed order for the checksum.
- **`StartState.weights: Dictionary[int, int]`** (section → weights) and **`lifts: Array[Vector2i]`** (section, tick). `_apply_start`: a section outside 1..n is `span.bad_start` and skipped; a negative count is `span.bad_start`, clamped to 0; a lift with a bad section or a tick below 0 is `span.bad_start` and dropped; more lifts on a section than its weights is `span.bad_start` and the extra are dropped.
- **`WardenState`** gains `enum Move { WALKING, CLIMBING }` (story 1.6 adds edging and crossing), `move: Move`, `move_ticks_left: int`, `fell_from: int` (the section that fell, for working out where the climb ends). Only `WardenRules` changes them.

### The tick (AD-34; step names unchanged)

| Step | This story adds |
|---|---|
| 1 | Before the walk: if climbing, count down; on reaching 0, the climb ends (`WARDEN_CLIMBED`) and the warden is walking again for the rest of the tick. A climbing warden does not walk. Then the look target and the commands as today (`HoldRules` ignores presses while not walking). |
| 2 | `HoldRules.tick()`: if the warden is not walking, cancel a running hold (`HOLD_CANCELLED`) and lower the forearm; otherwise as today (check, progress, completion). |
| 4 | `ConsequenceRules.settle(self)` |
| 6 | `SpanRules.take_lifts(self)` (D1): each lift whose tick is this tick takes one weight off its section and emits `WEIGHT_LIFTED`; a lift on a fallen section or one with no weight left does nothing (the weights fell with it). |
| 7 | `SpanRules.tick_loads(self)` |
| 8 | `ConsequenceRules.settle(self)` |

`tick_loads()`, sections 1 to n in order, skipping fallen ones. With `L = load_on(n)`, `S = strength(n)`:

1. If groaning (`groan_left > 0`): if `L <= S`, the groan stops (`GROAN_STOPPED`, `groan_left = 0`); else `groan_left -= 1`, and at 0 the section falls (`set_fallen`, `creaking` false, `SECTION_FELL`) and is done for this tick.
2. Else if `L > S`: the groan starts (`groan_left = ticks.groan`, `GROAN_STARTED`). Since the creak needs `L == S`, a creaking section first stops creaking: `CREAK_STOPPED` comes before `GROAN_STARTED`.
3. Then the creak: `creaks = L > 0 and L == S` (only when not groaning); on a change emit `CREAK_STARTED` or `CREAK_STOPPED`. On one section a stop always comes before a start.

Check the arithmetic against AC 3: overload first seen tick 0 → `groan_left = 120`; ticks 1 to 120 decrement; tick 120 reaches 0 → falls. A lift on tick 120 (step 6) makes `L <= S` at step 7 of tick 120 → holds.

### ConsequenceRules (AD-48, AD-64)

`sim/consequence_rules.gd`, `class_name ConsequenceRules extends RefCounted`, static only. `settle(sim)` calls a literal ordered list of named steps, each its own static function with its own tests, in the AD-64 order (the footing of the dead, rigs, lanterns, parts, hooks, the warden):

1. `weights_fall(sim)`: every fallen section with weights: weights to 0, its pending lifts dropped. (Test weights stand where the footing of the dead will be.)
2. `parts_lost(sim)`: every fallen section: its planks and both ropes go to `PartPlace.lost()` through `SpanRules.move_parts()`. Nothing to move is not a call (no fault for 0).
3. `warden_footing(sim)`: only while the warden is walking. If `WardenRules.fell_from(sim)` names a section (the feet on a fallen section's floor and on no floor of a standing section nor the landing), the climb begins: `WardenRules.start_climb(n, sim)` sets the move, 300 ticks, `fell_from`, moves the feet to the hang point (D3) and emits `WARDEN_CAUGHT`. Else, if the feet cannot be stood on because of a fallen section (a clearance probe over it), `WardenRules.step_back(sim)` moves the feet along the span, away from the gap, to 0.3 m from its edge (D2).

Each step looks at the whole state, so a second `settle()` in the same tick changes nothing (test it). The architecture expects the list to grow (rigs, lanterns, hooks, the dead): a new consequence is a new step, never a branch in an old one.

### The climb (D3; AC 6 and 8)

- **Hang point** (at `WARDEN_CAUGHT`): with `m` = the first section after the fallen one (toward the town) that has planks and has not fallen, else the landing: x = the warden's x clamped to ±(half the width of `m` − 0.3), along = `section_start(m)` (or the span's length, for the landing's edge), y = −`HANG_DROP`. Ask `SpanGeometry` for both points; no coordinate in the rule.
- **End** (at `WARDEN_CLIMBED`, tick F + 300): `m` worked out again from `fell_from`; x as above; along = that edge + `CLEARANCE` (0.3); y = 0. `can_stand` is true there (a test checks). `WARDEN_CLIMBED.section` is `m`, or 0 for the landing.
- **Literal positions for the tests** (one night, 30 m, `world_z = along − 30`). `StartState.warden_along` places the warden on the centre line (x 0) only, so a test that needs another x walks there first with `set_move` (0.5 m across is 9 ticks at 3.5 m/s), before the fall (for example section 4 at 3 planks with 4 weights falls on tick 120). Warden at along 17.5, x 0.5 (mid section 4) when section 4 falls on tick F → on F the feet are (0.5, −1.4, −10.0); on F + 300 they are (0.5, 0.0, −9.7), `WARDEN_CLIMBED` section 5. Section 6 falling under a warden at along 27.5 → hang (x, −1.4, 0.0), end (x, 0.0, 0.3), section 0.
- **D2 literal** (reached the same way: start at along 20.1, walk to x 1.0): warden at along 20.1, x 1.0 (on section 5, 0.1 m from section 4), holding a strip of section 5's right rail (in reach: about 1.5 m across, 0.6 m up); section 4 falls on tick F → in step 8 of F the feet are at along 20.3, x 1.0 (moved 0.2 m, under the 0.5 m limit), and the rail hold keeps running and completes. A second sim, the same but holding a strip of section 4's deck: that hold is cancelled on F + 1.

### LookRules, HandRules, HoldRules

- `LookRules.target()`: skip `deck_box(n)` of a fallen section entirely (no target, no blocker). Its rails are gone already (ropes lost), so no rail target either.
- `HandRules.check(RELAY_PLANK, ...)`: after the hand check (hand first stays), a fallen section is `NO_ACTION_HERE`. A strip on it is already `NO_PLANKS_LEFT` (0 planks) and a rail strip `NO_ACTION_HERE` (rope gone): each cancels a running hold through `tick()`, which is DW-34's branch.
- `HoldRules`: one pure query, e.g. `WardenRules.walking(sim)`, used by `_press_hand`, `_press_forearm` (ignore, no event) and `tick()` (cancel and lower the forearm). Keep the order in `tick()`: not walking first, then the move limit and the check, then progress.

### Geometry

`SpanGeometry.weight_box(section, i) -> AABB`, `i` from 0: a cube of `WEIGHT_SIZE` (gray box, 0.5 m) standing on the deck top (y 0 up), laid out in a fixed grid (for example 3 across at x −1.5, 0, 1.5, rows along the middle of the section), never within 1.25 m of either end of the section (that is where the deck is aimed at from the next section), stacking upward when a layer is full, so any count is drawn. Deterministic; a test checks the boxes are inside the section's footprint and do not overlap. Weights are not shapes for `LookRules` or `WardenRules`: the warden walks through them (no colliders, AD-52).

### View (D4)

- **Weights**: `SectionView` reconciles one box per weight (`Weight1`, `Weight2`…; dark gray, a new `&"weight"` material in `SpanView`), like planks.
- **Bow**: each tick, from state only: depth = 0 when neither creaking nor groaning; `CREAK_BOW` (0.05 m) when creaking; when groaning, from `CREAK_BOW` growing linearly to `GROAN_BOW` (0.25 m) as `groan_left` goes from `ticks.groan` to 0. Each kept plank drops by `depth × 4u(1 − u)`, with `u` the plank's place centre along the section (0 to 1), so the mid-section planks sag most. A pure static function (`bow_depth(...)`, `plank_sag(...)`) tested headless; constants are view gray-box sizes in `section_view.gd`, not rules. Weights sit on the bowed deck or not, either is fine; say which.
- **Fall**: the consumer handles `SECTION_FELL` before it reconciles (AD-49): every node the section has (planks, rails, beams, posts, weights) is moved under a falling group that drops with gravity (`y = −½·g·t²`, view time, `_process`) for `FALL_S` (1.5 s), then is freed. View-only, not a rule: a frame-time `_process` is fine here (the rule "no timers or tweens for anything a rule times" is about rules). After it, a fallen section draws nothing at all, so the gap shows the black sky; its neighbours' posts stay. Make the drop drivable headless (a method the test calls with a delta).
- No shake, no flash, no flicker (EXPERIENCE.md, Accessibility Floor; project-context "The night screen").
- **`warden.gd`**: in `on_tick`, if this tick's events hold `WARDEN_CAUGHT` or `WARDEN_CLIMBED`, `_blend.snap(sim.warden.position)`; else `push()`. D2's step back is a push (blended). The camera's local position and roll stay as they are.
- **AimAid** (DW-41): `would_start()` returns false while the warden is not walking, mirroring `HoldRules`; a test.

### Events

| Kind | When | Fields |
|---|---|---|
| `CREAK_STARTED` | Step 7: load equals strength (> 0) | t, section |
| `CREAK_STOPPED` | Step 7: no longer | t, section |
| `GROAN_STARTED` | Step 7: load above strength, first tick | t, section |
| `GROAN_STOPPED` | Step 7: load back at or under strength before the fall | t, section |
| `SECTION_FELL` | Step 7: 120 ticks of groan | t, section |
| `WEIGHT_LIFTED` | Step 6: a lift of D1 | t, section |
| `WARDEN_CAUGHT` | Step 8: the warden's section fell; the climb begins | t, section (the section that fell) |
| `WARDEN_CLIMBED` | Step 1: the climb ends | t, section (climbed onto; 0 = the landing) |

Each kind's `##` comment ends with its "Fields:" list (the fields test parses it).

### Bot (AD-63)

`NightBot.overload(def, seed, faults, each_tick)` in `paths()`, and `overload_script()` (the same with no wander, for the reaching test, as `strip_script`). Every section number from the def: town = `def.section_count`, `c` = town − 1, `a` = town − 2, `b` = town − 3 (4 sections at least, else `bot.bad_def` as `strip`). Its `StartState`:

- `b`: 3 planks, 4 weights, lifts on ticks 60 and 90 (groans from tick 0; at 60 load 3 = strength 3: `GROAN_STOPPED` and `CREAK_STARTED`; at 90 `CREAK_STOPPED`). No warden needed.
- `a`: 4 planks, 3 weights. `c`: 4 planks, 3 weights. Town: full, 5 weights.

Script, from the landing:
1. Walk to along `section_start(c) + 0.1` (D2's band) and strip `a` twice from there (creak, then groan); start a third strip hold on `a` on the tick after the second completes, so it would complete on F + 1: it is cancelled; `a` falls; the warden steps back to 0.3 m. 
2. Walk to mid `c` and strip its own deck twice (creak, then groan). Then press Tab and keep it held (Hold mode), so the forearm is up when `c` falls under the warden (`WARDEN_CAUGHT`); `HoldRules` lowers it on F + 1. During the 300 ticks press every hand button and Tab, and push a move wish (all ignored: no event, the feet stay at the hang point); release Tab; `WARDEN_CLIMBED` onto the town section. (A hold running when the warden falls is covered by the unit tests of T1.3; one action at a time means the bot cannot also have the forearm up.)
3. On the town section, strip it to 4 planks (8 → 4 with 5 weights: creak at 5, groan at 4) and stay on it: it falls; the warden climbs onto the landing.
4. Aim at the gap where a section fell and press the hammer and E: `NO_ACTION_HERE`.
5. A short wander, as `strip`.

On 4 sections the same script runs with `b` = 1. `test_bot_nights.gd`:

- `_test_overload_reaches_its_cases` (script only, 6 and 4 sections, 3 seeds), each case told from events, commands and state, not taken on trust: creak started, creak stopped, groan started, groan stopped, weight lifted, fell with nobody on it, weights gone and parts lost on it, step back, a hold on it cancelled on F + 1 (and one that would have completed then), fell under the warden, the forearm lowered by the fall, presses and move ignored while climbing, climbed onto a section, climbed onto the landing, the town section fell, `NO_ACTION_HERE` at a gap. No fault.
- Per-tick arithmetic: a fallen section is never in `_held` and never stood on; while the warden is climbing, skip the standing checks and instead check the feet are at y −1.4 and the climb lasts exactly 300 ticks from `WARDEN_CAUGHT` to `WARDEN_CLIMBED`; after `WARDEN_CLIMBED` the warden stands where it can by this file's own arithmetic. Totals 48 and 12 (32 and 8) with lost counted, every tick.
- The coverage checks then see every new kind.

### Show-me setups (AD-56)

| Name | Description (as `--show=list` prints it) | `StartState` |
|---|---|---|
| `overload` | `section 4 at 4 planks with 3 weights; strip it from section 5 until it falls (M1 of story 1.5)` | `planks = {4: 4}`, `weights = {4: 3}`, `warden_along = 20.4` (section 5, 0.4 m from section 4, facing the far pier) |
| `fall_under` | `stand on section 4 (4 planks, 3 weights) and strip it under you (M2 of story 1.5)` | `planks = {4: 4}`, `weights = {4: 3}`, `warden_along = 19.2` (section 4, 0.8 m from section 5: inside the 1.25 m end strip that `weight_box()` keeps clear, so the warden does not stand inside a weight; the deck 0.6 m ahead, along 18.6, is still clear and in reach) |

Neither is overloaded at start (3 < 4), so the CI smoke run of 120 frames sees no fall. The planks taken off start in the hand (as every `StartState`), which is fine.

### Trace

Who and where follow story 1.4's rule. `WARDEN_CAUGHT` and `WARDEN_CLIMBED` join `WARDEN_KINDS` (who `warden`); `WARDEN_CLIMBED` with section 0 prints `landing` as its where. `WEIGHT_LIFTED`'s who is `weight`. The section kinds have no who. Examples: `  2.000 SECTION_FELL      s4`, `  2.000 WARDEN_CAUGHT     warden s4`, `  7.000 WARDEN_CLIMBED    warden landing`, `  1.000 WEIGHT_LIFTED     weight s3`. Every new name fits the 17-letter column. `NIGHT_STARTED`'s line stays exactly as it is.

### Tests

- New `test_consequences.gd` (`WatchTest`) for `ConsequenceRules`; the rest go into the files named in T1. One test file per system.
- Literal ticks: compare exactly on which tick an event lands. Positions within 0.001 m.
- Every rule undone on its own must fail a test (story 1.4 habit): the groan restarting on deeper load, the fall a tick early, the creak with load 0, fallen still targetable, fallen in `held_by_bare`, the lift after step 7, the climb walking, the hold not cancelled on F + 1, `settle()` order, the step back missing (the warden then freezes: a test walks away after it), the snap missing in `warden.gd`.
- Ear test: still 120 passed, 23 expected.

### Docs

- `WATCH.md`: what loads a section (test weights, only through show-me setups and tests in this epic), creak, groan, fall, the climb, the two new shows, the trace lines.
- `project-context.md`: "Store base facts only" gains fallen and the creak/groan phase; note that the groan's constant is `SpanConstants.GROAN_S` where the architecture's Data Patterns example writes `CREAK_GROAN_S` (project-context asks for differences with the architecture to be said); `ConsequenceRules` settles a fall (weights, parts, warden); a fallen section is no target and no floor; the climb is a timed move in `WardenRules`, presses ignored meanwhile; D2's step back. Update "Last Updated".
- `deferred-work.md`: close DW-34 (correct its "on the tick it falls" to F + 1); note on DW-35 that `held_by_bare()` now skips fallen sections; new items: (1) epic 3: test weights are a count in `SpanState`, the architecture's sketch says "a weight is a kind of `DeadState`", decide when `DeadState` is whole, and fold `lifts` into the dead walking off; (2) story 1.6: a section with no planks and a weight groans and falls by the general rule until 1.6's side-beam rule replaces it, and D2's step back is the precedent for a warden beside a section that goes open.

### Project Structure Notes

```
game/watch/sim/consequence_rules.gd                                   NEW (RefCounted, class_name)
game/watch/sim/night_sim.gd, night_event.gd, night_ticks.gd,
               span_state.gd, span_rules.gd, span_constants.gd,
               span_geometry.gd, start_state.gd, warden_state.gd,
               warden_constants.gd, warden_rules.gd, hold_rules.gd,
               hand_rules.gd, look_rules.gd                            UPDATE
game/watch/night/section_view.gd, span_view.gd, warden.gd             UPDATE
game/watch/debug/aim_aid.gd, bot/night_bot.gd,
               show/show_setups.gd, trace.gd                           UPDATE
game/tests/watch/test_consequences.gd                                  NEW
game/tests/watch/test_span.gd, test_hands.gd, test_look.gd,
                 test_warden.gd, test_night_sim.gd, test_span_view.gd,
                 test_warden_node.gd, test_aim_aid.gd, test_bot_nights.gd,
                 test_show_setups.gd, test_trace.gd                    UPDATE
game/WATCH.md, _bmad-output/project-context.md,
_bmad-output/implementation-artifacts/deferred-work.md                 UPDATE
```

- `consequence_rules.gd` is the architecture's own file name and place (System Location Mapping). `--import` after adding its `class_name`; commit the `.uid` it writes; never invent one.
- `watch/sim/` stays node-free and names nothing outside `watch/sim/`, `watch/content/` and `WatchFaults` (the purity check).
- No literal 6, 8 or 30 outside `night_defs.gd` and tests.

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, typed GDScript: type everything; `:=` only for `const X := preload(...)`; typed arrays and dictionaries (`Dictionary[int, bool]`).
- `class_name` for scripts named by type, PascalCase matching the file; `##` on every script and non-obvious member, saying why; constants cite GD-n or the story decision, with a unit suffix (`_S`; metres none).
- **Into the sim, nothing but** `set_move`, `set_view`, `command`; only the sim changes night state; a view reads state and handles its events before it reconciles (AD-49).
- **Store base facts only**: strength and load are computed (AD-35). **Parts move only through `SpanRules.move_parts()`**: losing a fallen section's parts is a ledger move to `lost`.
- **When the span changes, change only the span**; `ConsequenceRules.settle()` decides what follows, as small named steps (AD-48, AD-64). `HoldRules` alone cancels a hold.
- A rule that changes state takes `sim` last, returns nothing, reports with `sim.emit()`; a pure query returns a value. A phase change emits exactly one event, from the function that makes it.
- Time is whole ticks, converted once (`sim.ticks`); begun on T, lasting N, done on T + N; no `await`, timers or tweens for anything a rule times.
- No physics in the night (AD-52): the climb is a timed move of `WardenRules`.
- A designed "no" is `REFUSED`; a bug is `faults.report()`.
- No HUD at night; no shake, no flash, no flicker faster than 3 a second; gray boxes.
- No `print` outside `watch/debug/`.
- Tests: situations only through a `StartState`; spec values literal with their source; ticks and commands; no `await`; provoked faults inside `_expect_begin`/`_expect_end`; every `NightEvent.Kind` and `NightTypes.Reason` produced by some bot path (AD-63).
- Never `--no-verify`. What is on screen or felt is a manual check.

### Previous story intelligence (story 1.4, done)

- **DW-34** is this story's: the impossible-target cancel in `HoldRules.tick()` had no test through the tick. A strip hold on a falling section reaches it now (F + 1).
- **D3 of 1.4** (a bare section holds a warden who was on it or within 0.3 m) stays for bare sections that have not fallen. `held_by_bare()` loops over sections with 0 planks: a fallen section has 0 planks too, so it must be excluded explicitly, or the warden would walk onto the gap.
- **The bot's per-tick check has its own arithmetic** beside the rule; `_held` is filled from `PLANK_STRIPPED` events. A fallen section must leave `_held`.
- **Code review asked for:** tests that check both directions of a rule, every fix proven by undoing it, no check that cannot fail, a reaching test that runs the script without its wander, faults for a bot that cannot do what it is written to (`bot.bad_def`, `bot.walk_lost`), and every undisclosed choice listed under Completion Notes as "restrictive reading; Sonlm may revisit".
- **Sonlm's play of 1.4:** the holds felt slow (kept, DW-40) and the aim aid (DW-41) now shows what the hands reach. For M1 and M2 the aid shows `deck` when the deck is in reach: look well down (within about 1.2 m of the feet).
- **The Xvfb chore**: engine flags before `--`, switches after: `xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --write-movie <dir>/frame.png --fixed-fps 30 --quit-after 60 -- --show=overload`. With no input nothing falls; to judge the bow and the fall from frames, drive real input events from a scratch driver outside the project, as story 1.4 did (`Input.parse_input_event`).
- **M checks on the laptop**: Sonlm runs them from the Godot editor on their own clone; give editor steps (the show is chosen by the run's arguments), never command lines or git steps.

### Git intelligence

Branch `ear-test-prototype`, HEAD `62a13e7`. Recent: `62a13e7` 1.4's play record; `3d4c453` the temporary aim aid (DW-41, `watch/debug/aim_aid.gd`, `test_aim_aid.gd`, `main.gd` `add_debug_parts`); `3742b89` 1.4 done; `22eda17` 1.4 code review fixes; `16559ce` story 1.4. Pattern: one commit per story step, `Story 1.5: <what>`; the pre-commit hook runs `tools/ci.sh`. Commit on the current branch, never `main`, never `--no-verify`, never push.

### Latest technical notes (Godot 4.7.2)

- Nothing new outside Godot 4.7.2 and what the project already uses. `Dictionary[int, bool]` and `Array[Vector2i]` typed containers work as in the existing code. `AABB` has no `intersects_segment` change to worry about: a skipped fallen deck is simply not tested.
- A `Node3D` moved to another parent keeps its local `position`; reparent the falling pieces with `reparent(new_parent, true)` (keep global transform) or move them under a group placed at the section's origin.

### Decisions taken with Sonlm

Sonlm chose the recommended option for all four on 2026-11-21, at story creation:

1. **D1:** a `StartState` can lift one weight off a section on a set tick (`lifts`, step 6, `WEIGHT_LIFTED`), so a groan that holds can be reached through ticks.
2. **D2:** a warden on the next section within 0.3 m of a section that falls steps straight back to 0.3 m from the gap, in the same tick, blended; a hold on another target goes on.
3. **D3:** during the 5 s the warden hangs from the near edge of the section (or landing) being climbed onto, eye 0.2 m above its deck; then is cut up onto it, 0.3 m in.
4. **D4:** the deck bows (5 cm creaking, growing to 25 cm over the groan); at the fall the whole section drops out of sight over 1.5 s.

Taken at the code review of 2026-11-22 (Sonlm chose the recommended option for all three):

5. **The bow and M1:** M1 is reworded: after each strip, look up along section 4. D4's sizes stay (5 cm, 25 cm) for Sonlm to judge in play.
6. **The edge hung from falls during the climb:** the feet cut at once to the next edge toward the town; the same 5 s keep running; no event. This replaces Completion Note 3.
7. **The view at the catch:** it cuts to face the edge caught (toward the town, level), once; the player looks freely after it. This makes D3's "looks along its planks" true from the first frame and answers the M2 finding below.

Also settled without a question (see "Decisions for this story"): no creak with load 0; the 2 s not restarted by more load; the fall decided at step 7; fallen, creak and groan stored; a fallen section has no deck; the hold cancel on F + 1; the climb's timing, end point and ignored inputs; who falls with a section; weights as a count in `SpanState`; no events for weights and parts that fall; the event names.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1; "Epic 1: story detail" preamble; "Story 1.5"; stories 1.6 and 1.7 (what must not be built here)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Game Mechanics 2 (load table, creak, collapse, what falls with it, open and fallen sections, section 6), 3 (re-lay: "any section that has not fallen"), 4 (overload with no rig); Listening's cue table ("A section's creak and groan: its planks bow")
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-13, GD-19, GD-60, GD-68, GD-69
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: "A section near breaking: creak and groan; planks bow"; Accessibility Floor (no shake, flash or fast flicker)
- `_bmad-output/game-architecture.md`: Time (AD-33, countdowns); Order inside a tick (AD-34); Base facts (AD-35); Event System (AD-67); Novel Patterns 1 (ledger) and 5 (consequences, AD-48, AD-64); Entity Patterns (`TickBlend`, `snap()` for the climb back); State Patterns (phase and countdown); Data Patterns; The shape of a rule script (`load_on`) and of a test (`start.weights[3] = 4`); A feature's footprint (AD-46); AD-52 (timed moves in `WardenRules`); Built when (epic 1: `StartState` including test weights; `ConsequenceRules` for a collapse)
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-4-the-warden-strips-re-lays-carries-and-reads-the-forearm.md`: Decisions (D3), Dev Notes, Review Findings, Completion Notes
- `_bmad-output/implementation-artifacts/deferred-work.md`: DW-34, DW-35, DW-41
- Code as of `62a13e7`: `game/watch/sim/*.gd`; `game/watch/night/*.gd`; `game/watch/debug/**`; `game/tests/watch/*.gd`; `tools/ci.sh`; `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), Claude Code, gds-dev-story.

### Debug Log References

- T0 baseline, `tools/ci.sh` before any change (HEAD `62a13e7`): 913 passed, 0 failed, 48 expected; 5 shows. DW-34 and DW-35 re-read.
- T1 red phase: compile-only stubs for every new name first (so a file would not fail to parse and take its old tests down), then the tests: about 100 new failures, each an assertion. Two were the tests' own mistakes, fixed: `test_look.gd` read `sim.look` from step 1 of the fall's own tick (before step 7), and a `test_span.gd` list had tick 0's events in the wrong step order (step 1 `HOLD_STARTED` comes before step 7 `GROAN_STARTED`).
- Green after the sim: 1086 passed with only the coverage checks red (no path yet made the 8 new kinds); green throughout after the overload bot path.
- T12 "each rule undone on its own" (story 1.4's habit), with a scratch copy of the runner that runs only named files (not in the project): 27 mutations, each one rule removed or changed, the files restored after each. Caught: the groan restarting on deeper load, the fall a tick early, the creak with load 0, a fallen deck still targetable, a fallen section in `held_by_bare()`, the lift missing or moved after step 7, the climb walking, the DW-34 cancel removed, the not-walking cancel removed, the forearm not lowered, hand presses taken while climbing, the `settle()` order, no step back, weights not falling, parts not lost, no catch, a re-lay onto a fallen deck, room on a fallen deck, the climb's end not worked out again, the snap missing in `warden.gd`, the aim aid ignoring the climb, the view keeping a fallen section, no bow, no fall drop, the checksum without the span's facts. The first run showed the not-walking cancel survived its removal: the jump to the hang point is usually more than 0.5 m, so the move limit cancelled the hold anyway. A test now catches it: a warden 0.4 m from the next section, stripping that section. One survives by design, listed under Completion Notes: the Tab guard in `_press_forearm`. Then 3 more on `test_bot_nights.gd` alone: it catches a missing step back and a climb one tick short; the `fallen` clauses in its own `_held` arithmetic survive their removal (no path bares a section that later falls), so they are not proven either.
- Final `tools/ci.sh`: all checks passed, 1166 passed, 0 failed, 54 expected (ear test 120 passed, 23 expected); 7 shows, each smoke-run.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-21).
- **Built:** the span carries weight. `SpanRules` works out strength (planks) and load (test weights, 1 each) when asked; `tick_loads()` (step 7) creaks at load = strength > 0, groans above it, and fells the section 120 ticks after the first tick of overload unless the load drops back; `take_lifts()` (step 6) is decision D1. `ConsequenceRules` (new, steps 4 and 8) settles a fall in three named steps: `weights_fall`, `parts_lost` (through the ledger, totals kept), `warden_footing` (catch and climb, D3; step back, D2). The climb is a timed move of `WardenRules` (`WardenState.Move`, 300 ticks, counted in step 1 before the walk); while it runs the move wish and every press are ignored, and `HoldRules.tick()` cancels a hold and lowers the forearm. A fallen section is no target, no blocker, no floor, takes no re-lay and has no room in the ledger. DW-34 closed: holds on a falling section are cancelled on F + 1. The view bows a creaking or groaning deck from state and drops the whole section on `SECTION_FELL` (D4); the warden's node cuts on the catch and the climb. The overload bot path, two show-me setups, trace lines, docs.
- **Tests added:** `test_consequences.gd` (new, 12 tests); story 1.5 sections in `test_span.gd`, `test_hands.gd`, `test_look.gd`, `test_warden.gd`, `test_night_sim.gd`, `test_span_view.gd`, `test_warden_node.gd`, `test_aim_aid.gd`, `test_bot_nights.gd` (`_test_overload_reaches_its_cases` over 6 and 4 sections and 3 seeds, the per-tick arithmetic now knows falls and the climb, `_test_overload_needs_four_sections`), `test_show_setups.gd`, `test_trace.gd`. 913 to 1166 checks.
- **Restrictive readings and choices the story did not spell out; Sonlm may revisit:**
  1. D2's step back happens only when a clearance probe along the span lies over a fallen section and on no standing floor. A warden D3 holds on a bare section (story 1.4) is left as it was.
  2. In "who falls with a section", a bare section that has not fallen counts as standing floor: feet on its rectangle do not fall.
  3. (Replaced by the code review of 2026-11-22: the feet now cut to the next edge, the same 5 s running.) If the section the warden hangs from falls during the climb, the hang point is not moved. The warden keeps hanging where the edge was until the cut at the end, which then lands on the next standing section, as the story says. In gray boxes this means hanging in mid-air for the rest of the 5 s. A later story may want them to drop to the next edge.
  4. The weights ride the bowed deck (D4 said either was fine). They stand in a 3 by 3 grid filled from the middle out (a single weight sits mid-section), in rows 1.75, 2.5 and 3.25 m along the section. A full layer of 9 stacks a new one up.
  5. The fall drops with y = -1/2 g t^2 (g 9.8) for 1.5 s, about 11 m: out of sight against the black. View time, not a rule.
  6. The Tab guard in `HoldRules._press_forearm` (ignored while climbing) cannot be told apart by any test: step 2's `tick()` lowers the forearm in the same tick anyway, so the end-of-tick state is the same. It stays as the story's stated rule ("every press, Tab too, is ignored"). The same goes for `walkable()` leaving out fallen sections: their planks are lost in step 8 of the same tick, so they have none by the next walk. That one is defensive.
  7. The aim aid on the climb's very last tick shows "not ready", though a press on the next tick would be taken: the climb ends in step 1 and the cut changes what is looked at anyway. Not in its test table.
  8. A lift is used up on its tick whether or not it lifted anything. Lifts are checked against the weights in StartState order, and the extra ones are dropped.
  9. `SpanState.add_weights()` and `add_lift()` are called by `NightSim._apply_start()` while the night is built (the story said setters only from `SpanRules` and `ConsequenceRules`): it is the same exception the ledger makes for a StartState.
  10. The bot's "presses and move ignored while climbing" is checked as two cases ("presses ignored", "move ignored").
  11. The sim-level checksum test covers weights, a lift still to come and "fallen". Creak, groan and the warden's timed move cannot differ alone between two nights reachable through ticks, so they are checked on `SpanState.values()` and `WardenState.values()`, which `checksum()` takes whole.
- **New deferred items:** DW-42 (test weights as a count vs the architecture's "a weight is a kind of `DeadState`"; fold lifts into the dead walking off, epic 3), DW-43 (a plankless section with a weight falls by the general rule until 1.6's side beams; D2 as the precedent). DW-34 closed (its "on the tick it falls" corrected to F + 1); DW-35 noted.
- **M1: the drop and the black gap verified on a virtual display; the bow NOT verified** (`--show=overload`; Forward+ on llvmpipe, CPU Vulkan, not a real GPU). A scratch driver outside the project fed real input (mouse look down, left button held twice), and the trace matched the rule: `CREAK_STARTED` 2.467, `CREAK_STOPPED` and `GROAN_STARTED` 4.633, `SECTION_FELL` 6.633. Frames: `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000180.png` (groaning: 2 planks and 3 weights on section 4), `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000205.png` (the whole section dropping as one, the next section's deck untouched), `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000260.png` (the gap black, section 3 beyond, the aid's dot dim: nothing to aim at). Finding for Sonlm (D4): from M1's own stance, looking steeply down at the near end of section 4, the bow cannot be seen. The sag is near 0 at the ends (4u(1 - u)), and `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000070.png` (flat, mid strip 1) and `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000140.png` (just after the second strip, groaning) look the same. Looking along the section (pitch about -0.45), it shows as the middle plank and the weights sitting lower: about 12 px between `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000150.png` (groan begun) and `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M1/frame00000180.png` (groan nearly run out). **NOT verified, needs Sonlm:** whether the bow can be seen in play (look up along section 4 after the strips), whether the 5 cm and 25 cm sizes are enough, and whether the 2 s before the fall can be seen coming.
- **M2: the catch, the hang facing the town, the climb and the parts kept verified on a virtual display** (`--show=fall_under`; same renderer note). Trace: `SECTION_FELL` and `WARDEN_CAUGHT` at 6.633, `WARDEN_CLIMBED warden s5` at 11.633 (5 s). Frames: `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M2/frame00000300.png` (hanging, turned toward the town: the eye just above section 5's planks, looking along them; W was held during the hang and nothing moved; the aid shows `deck` but not ready), `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M2/frame00000395.png` (up on section 5 with Tab held: the forearm shows 6 planks in hand, 4 from the start and 2 stripped, and no ropes). Finding for Sonlm (D3; answered by the code review of 2026-11-22, the view now turns at the catch): the catch keeps the warden's view, so straight after it (still looking down toward the far pier) the screen is nearly all black, with only a strip of deck at the top and bottom edges: `/tmp/claude-1000/-home-sonlm-project-3d-game/61cb6c0a-5e65-45e8-a8d8-bd2a94322b35/scratchpad/M2/frame00000208.png`. The deck at eye height, as D3 describes it, shows only once you turn round toward the town. Turning the view at the catch was not in D3 and is not built. **NOT verified, needs Sonlm:** whether that black first view reads as hanging or as a glitch, how the cut to the hang and the cut up read and feel, whether 5 s of hanging is too long, and the mouse and keys under the hand.
- **Code review (2026-11-22, gds-code-review; Blind Hunter, Edge Case Hunter, Acceptance Auditor):** no high-severity finding, no acceptance criterion violated. 3 decisions, 18 patches, 0 deferred, 10 dismissed; all decisions and patches applied (see "Review Findings" under Tasks). Fixed in the game: a hold cancelled by D2's step back (the step is no longer charged to its 0.5 m), a plank stripped or weight lifted on the fall's tick drawn falling, room for a rope on a fallen section's rail, the mid-air hang (decision 6), the black first view after the catch (decision 7), sections processing every frame, a groan of 0 ticks. New tests: the far-pier side of the step back, a warden held on a bare section that falls, a bare standing section passed by the climb, buttons held through the climb, the hang edge in the bot's own arithmetic. `tools/ci.sh`: 1224 passed, 0 failed, 55 expected (was 1166 and 54). 23 fixes undone one at a time, 22 caught; not proven: the 1-tick floor of a groan, the bow's place asked of the geometry, and the aim aid's last climb tick (documented, not changed). Proven more narrowly than it may read: the catch of the next edge (decision 6) by the unit tests alone, since no bot path makes the hang edge fall during a climb (the bot's own hang-edge arithmetic runs every tick but meets only edges that stand); and the rail-strip and re-lay branches of `SectionView.fall()` by hand-built event lists, since no tick of this story can complete either on a fall's tick.
- **M1 after the review: the fall, the black gap and the groan's bow verified on a virtual display; the creak's bow NOT verified** (`--show=overload`; Forward+ on llvmpipe, CPU Vulkan, not a real GPU; real input from a scratch driver outside the project; trace: `CREAK_STARTED` 2.467, `GROAN_STARTED` 5.233, `SECTION_FELL` 7.233). Looking along section 4 as the reworded M1 says: `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000007.png` (flat, before any strip), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000090.png` (creaking: measured on the 1280 x 720 frame, the middle weight's top edge is 7 px lower than in frame 7, the mid plank 5 px, the near plank 7 px; a plank has also gone since frame 7, so the bow itself is hard to pick out), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000166.png` (9 frames into the groan), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000214.png` (the groan nearly run out: against frame 166 the weight's top edge is 20 px lower, the mid plank 17 px, the near plank 19 px; a steady sink over the 2 s that can be followed if watched), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000224.png` (the whole section dropping as one: 2 planks, 3 weights, beams, posts, rails), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M1/frame00000285.png` (the gap black, section 3 beyond). This run does not show the fix for a piece taken on the fall's own tick: here the second strip ended 2 s before the fall. That fix is proven by `test_span_view.gd` only. **NOT verified, needs Sonlm:** whether the creak's 5 cm can be seen at all in play, whether the groan's sink to 25 cm is warning enough, and whether the 2 s can be seen coming. The sizes are `CREAK_BOW` and `GROAN_BOW` in `section_view.gd`.
- **M2 after the review: the catch, the view turned to the edge, the hang, the climb and the parts kept verified on a virtual display** (`--show=fall_under`; same renderer note; the driver never moved the mouse after the strips; trace: `SECTION_FELL` and `WARDEN_CAUGHT` 6.633, `WARDEN_CLIMBED warden s5` 11.633). `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000198.png` (just before: looking down at the deck, 2 planks and 3 weights), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000201.png` (after the catch: facing the town, level, section 5's deck at eye height filling the lower half, its rails either side; the first frame after the catch, 200, measures the same, 92% of the lower half lit, where the old first view was nearly black), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000220.png` and `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000245.png` (hanging, before and after W was held for frames 225 to 240: the two frames are the same pixel for pixel, as are frames 201 and 345, so nothing moved during the hang), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000352.png` (up on section 5 after the cut at frame 349), `/tmp/claude-1000/-home-sonlm-project-3d-game/c4966c10-5e3c-41f1-bc42-ebf5588846f9/scratchpad/M2/frame00000395.png` (Tab: 6 planks in hand, no ropes). This replaces the "Finding for Sonlm (D3)" in the M2 note below. **NOT verified, needs Sonlm:** how the cut and the turn at the catch feel, whether 5 s of hanging is too long, and the mouse and keys under the hand.
- **Sonlm ran M1 and M2, 2026-11-22** (with a real mouse and keys; Sonlm did not say which machine or commit; the branch head was `1d444ea`). What Sonlm reported, in their words:
  - "the deck sag and fall" and "You can feel the fall is coming, i can see it sag a bit". Sonlm did not say after which strip the sag was seen, so the creak's bow on its own (5 cm) is still not judged (DW-44); the warning before the fall is accepted. `CREAK_BOW` and `GROAN_BOW` stay as they are.
  - "I fall as well", "hanging is ok", "Mouse and keys are fine fow now". Sonlm made no separate remark on the view being turned at the catch, or on the planks kept in hand.
  - "where i aim just randomly remove the plank from the deck". This is GD-54 as built in stories 1.2 and 1.4 (a deck is a count; planks leave in the fixed order 3, 7, 5, 1, 8, 2, 6, 4, wherever the warden aims). Explained to Sonlm, who decided the same day: keep it as it is (declined: mark the plank that will go; take the plank aimed at).
  - "get stuck a bit after coming back". Asked what this was (four options), Sonlm picked none and answered: "It automatically bring me back up. Or is there a way that i can go up by my self". Sonlm was then told, in a second option list, that the climb is automatic, that the 5 s is the GDD's (Game Mechanics 2, "climbs back ... in 5 s"), and that once up the warden stands 0.3 m from the gap facing the town, so S, or W after turning round, moves nothing. Sonlm picked "Keep the automatic climb", whose text read: "No change. The 'stuck a bit' was the 5 s hang, and that is fine as it is." (declined: climb with a press, a GDD change; "I was stuck after I was up", which would have reopened the story). Before that answer the agent replayed `fall_under` on a virtual display with scripted keys and read the sim's warden each frame: after the climb W (toward the town), A and D each moved the feet on the next tick, also with W held from the hang through the end of the climb; S, and W after turning round, moved nothing, because the climb ends 0.3 m from the gap, the nearest the warden may stand (D1 of story 1.3). No fault found; nothing changed in the game.
  - Sonlm asked "Is there any sound in this". There is none: sound is epic 2.
- Agent time: 2026-11-21 23:56 +0700 to 2026-11-22 00:35 +0700 (0 h 39 min), measured by the agent.
- Sonlm's own hours: (for Sonlm to fill in)

### File List

- game/watch/sim/consequence_rules.gd (new)
- game/watch/sim/consequence_rules.gd.uid (new)
- game/watch/sim/hand_rules.gd
- game/watch/sim/hold_rules.gd
- game/watch/sim/look_rules.gd
- game/watch/sim/night_event.gd
- game/watch/sim/night_sim.gd
- game/watch/sim/night_ticks.gd
- game/watch/sim/span_constants.gd
- game/watch/sim/span_geometry.gd
- game/watch/sim/span_rules.gd
- game/watch/sim/span_state.gd
- game/watch/sim/start_state.gd
- game/watch/sim/warden_constants.gd
- game/watch/sim/warden_rules.gd
- game/watch/sim/warden_state.gd
- game/watch/night/section_view.gd
- game/watch/night/span_view.gd
- game/watch/night/warden.gd
- game/watch/debug/aim_aid.gd
- game/watch/debug/bot/night_bot.gd
- game/watch/debug/show/show_setups.gd
- game/watch/debug/trace.gd
- game/tests/watch/test_consequences.gd (new)
- game/tests/watch/test_consequences.gd.uid (new)
- game/tests/watch/test_aim_aid.gd
- game/tests/watch/test_bot_nights.gd
- game/tests/watch/test_hands.gd
- game/tests/watch/test_look.gd
- game/tests/watch/test_night_sim.gd
- game/tests/watch/test_show_setups.gd
- game/tests/watch/test_span.gd
- game/tests/watch/test_span_view.gd
- game/tests/watch/test_trace.gd
- game/tests/watch/test_warden.gd
- game/tests/watch/test_warden_node.gd
- game/WATCH.md
- _bmad-output/project-context.md
- _bmad-output/implementation-artifacts/deferred-work.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-11-22: Story 1.5 implemented: load, creak, groan and fall; ConsequenceRules; the climb back (D3) and the step back (D2); lifts (D1); the bow and the fall in the view (D4); DW-34 closed; the overload bot path; `overload` and `fall_under` shows; trace lines; docs. Status set to review.
- 2026-11-22: Record corrected after the final check: test and mutation counts, M1 and M2 headlines narrowed to what the frames show, two findings (the bow cannot be seen from M1's stance; the first view after the catch is nearly black), the undo check on test_bot_nights.gd.
- 2026-11-22: Code review: 3 decisions (M1 reworded to look along the section; a warden whose hang edge falls catches the next edge with the same 5 s; the view turns to the edge at the catch) and 18 patches applied; 1224 checks; M1 and M2 rendered again. Status stays review until Sonlm has run both shows.
- 2026-11-22: Review record made exact: the bow's shift measured in pixels, the hang frames compared, and what the renders and the bot do not prove said.
- 2026-11-22: Sonlm ran M1 and M2: the sag and the fall are seen and the fall can be felt coming, the hang is fine, mouse and keys are fine for now. The plank that leaves looked random (GD-54; kept as it is, Sonlm). No fault found in the "stuck after coming back" report (the 5 s hang). Status done.
- 2026-11-22: Play record corrected to what was asked and answered: Sonlm keeps the automatic 5 s climb (declined: a press to climb). DW-44 for the creak's bow, not judged on its own.
