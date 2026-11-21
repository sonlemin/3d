---
baseline_commit: 6043d4a
---

# Story 1.4: The warden strips, re-lays, carries and reads the forearm

Status: done

<!-- Created 2026-11-21 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As the warden,
I want to take planks and rail ropes off the bridge, put planks back, and see what I carry,
so that the bridge is my supply of parts.

Delivers: GDD Game Mechanics 3 (strip, re-lay, carried parts); Controls and Input (hold rules, Tab, E to re-lay, Press once). GD-19, GD-21, GD-69; UX-11, UX-36, UX-39 (and UX-6's "can't" as a `REFUSED` event, no gesture yet). Architecture AD-15, AD-47, AD-50, AD-67 (`HoldRules` owns a hold's validity), the parts ledger (Novel Pattern 1), Novel Pattern 3 (hands). Also closes DW-27 and DW-28.

## Acceptance Criteria

1. **Strip a plank.** Given the warden looking at a section's deck from within 2 m, when the left mouse button is held for 2 s (120 ticks), then that section has 1 plank fewer and the warden holds 1 plank more. The count changes when the hold completes, not when it starts.
2. **Strip a rail rope.** Given the warden looking at a standing rail rope from within 2 m, when the right mouse button is held for 3 s (180 ticks), then that rail is gone and the warden holds 1 rope more.
3. **Re-lay a plank.** Given a section that is not fallen and has fewer than 8 planks, looked at from within 2 m, with a plank in hand, when E is held for 3 s (180 ticks), then that section has 1 plank more and the warden holds 1 fewer. (A section with no planks can take one: GD-69.)
4. **Refusals.** Given a re-lay with no plank in hand, a re-lay on a section with 8 planks, or a strip of section 6 at 4 planks, when the input is pressed, then the sim emits a `REFUSED` event with its reason and nothing changes; section 6's rail ropes can still be stripped.
5. **Cancel.** Given a hold in progress, when the button is let go, or the warden moves more than 0.5 m from where it began, or the action can no longer be started there, then the hold is cancelled, a `HOLD_CANCELLED` event is emitted and no part moves. Looking around does not cancel it.
6. **One action at a time.** Given a hold in progress, when another input is pressed, then it is ignored.
7. **Press once.** Given the Holds option set to Press once, when an input is pressed once, then the hold starts and runs its full time; a second press stops it; moving 0.5 m still cancels it. Tab becomes a toggle. The option is a rule inside `HoldRules`, tested here; its setting row arrives in epic 8.
8. **The forearm.** Given Tab held, with no hold running, when the forearm is raised, then it shows the planks and the ropes in hand as tally strokes in fives. The warden can walk and look, and neither hand can act until it is lowered. Tab during a hold is ignored.
9. **No carry limit.** Given any number of stripped parts, when the warden carries them, then there is no limit.
10. **The last plank underfoot.** Given the last plank of the section the warden stands on (sections 1 to 5), when it is stripped, then the strip completes and the section has no planks; what the warden then stands on is story 1.6, and until then the warden stays in place and can walk off (decision D3).
11. **Bot nights.** Given bot nights that walk, strip, re-lay and try refused actions, when every tick is checked, then planks over all places still total 48 and ropes 12, and every part moved through `SpanRules.move_parts()`.

"Section 6" is the town section, `def.section_count` (section 4 on the 4-section test def); "8 planks" is `def.planks_per_section`. No literal 6 or 8 outside `night_defs.gd` and tests (AD-42).

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setups below. Build order (AD-46): failing test first; constants, state, tick step, rule and events; then the view; then the bot path, the show-me setups and the manual checks.

**Manual checks for Sonlm** (an agent cannot verify these headless; never report one as verified unless judged from frames as the dev-story chores describe):

- **M1** (`--show=strip`): strip three planks and a rail, re-lay one, raise the forearm and count the strokes (2 planks, 1 rope); the hold lengths (2 s, 3 s, 3 s) feel like work, not waiting. Feel, mouse buttons and Tab: **cannot** be judged from frames, needs Sonlm. See decision D4 for what shows a hold in this story.
- **M2** (`--show=forearm`): hold Tab on the landing; the forearm shows 12 planks as two crossed fives and 2 strokes, and 3 ropes, the two kinds told apart (decision D2); the forearm is readable, stays drawn over the world, and walking and looking still work with it up. Needs Tab held: **cannot** be judged from frames by the agent, needs Sonlm.

## Decisions for this story

Points that neither the GDD nor the architecture settles. **Sonlm chose the recommended option for all four on 2026-11-21** (see "Decisions taken with Sonlm" in Dev Notes).

- **D1. What "looking at a rail rope" hits.** (Recommended) **A grab box around the rope:** `SpanGeometry.rail_grab_box(n, side)`, the rope's full length, `RAIL_GRAB_SIZE = 0.3` m across and 0.3 m tall, centred on the drawn rope. What is drawn stays the 5 cm rope, in the same place (AD-47's "what is drawn is what is hit" holds for placement; the reach is wider than the rope so a person can aim at it). Gray-box size, not a rule; tuned in M1. Declined: the drawn 5 cm rope only (a 5 cm target at up to 2 m is fiddly to hold the view on for 3 s); thickening the drawn rope to 0.15 m (reads as a beam).
- **D2. How the gray-box forearm tells planks from ropes.** (Recommended) **Two rows, each led by an inked sign:** planks on the upper row behind a small filled bar, ropes on the lower row behind a small ring; strokes in fives (four upright, the fifth across them); a row wraps after 5 groups. Ink is one dark colour on a light flat forearm (`DESIGN.md`: ink on skin, never a panel). Declined: two rows told apart by position only (the reader must already know which row is which); two ink colours (one ink, `DESIGN.md`).
- **D3. "Stays in place and can walk off" until story 1.6.** (Recommended) **A bare section still holds a warden who was on it, or within 0.3 m of it, when it went bare.** Two cases: the warden strips the last plank of the section underfoot (AC 10), or strips it from the next section while standing within 0.3 m of the edge (the deck is only reachable within about 1.2 m, so this is the usual stance). Either way the warden's spot can no longer be stood on. While that holds, every bare section under the feet or under one of the four clearance probes counts as floor for the warden, with the usual 0.3 m from the rails, so they can walk out through the 0.3 m band; once `can_stand` is true again the normal rule applies and the bare section blocks as before. No timer, no event, nothing stored: normal walking never reaches a spot that cannot be stood on (1.3's rule), so "cannot stand here" already means "was here when it went bare". Story 1.6 replaces it with edging toward the town (GD-68). Declined: snapping the warden at once to the nearest standable spot toward the town (a teleport that story 1.6 would have to undo); freezing the warden until 1.6 (the AC says "can walk off").
- **D4. What shows a hold in progress in this story.** (Recommended) **Nothing new: the part leaving the deck or the rail is the only sign.** The hands that show a hold (counted blows, rope hand over hand, a cancel dropping, the "can't") are epic 4 story 1 (UX-2, UX-5, UX-6), and sound is epic 2 on. M1 then judges the lengths (2 s, 3 s) and that parts move only at the end; whether a hold "feels like work" is judged again in epic 4 story 1 with the hands. `--trace` prints every `HOLD_STARTED`, `HOLD_CANCELLED` and completion line, if Sonlm wants to watch them. Declined: a throwaway block hand that dips once per 0.5 s during a hold (built again in epic 4); a debug progress bar (no HUD at night, even in debug builds outside F3).

Settled without a question (each follows from the documents; listed so Sonlm can revisit):

- **"Within 2 m" is measured along the view line from the eye** (`LookRules`, AD-47: "finds what is looked at within 2 m, by testing the view line"). With the eye at 1.6 m, the deck is reached within about 1.2 m of the feet (looking well down) and a rail from up to about 1.9 m across. M1 says if it feels too close.
- **Looking around never cancels a hold** (AC 5): "the action can no longer be started there" is checked against the hold's own target (that deck, that rail) and the state, not against what is looked at now. Only moving more than 0.5 m from where the hold began (feet, horizontal), letting go (Hold mode), a second press (Press once), or the action becoming impossible on its target cancel it.
- **A press that finds no action is a refusal** (`REFUSED`, reason `NO_ACTION_HERE`): UX-6 "applies to keys as well as clicks". So a hammer click at the sky, a right click on a deck, or 1, 2, R, F in this story (their actions arrive in epic 4) are refused, not ignored. A press **while a hold runs or while the forearm is up** is ignored (no event): "one action at a time" and UX-11 "neither hand can start an action".
- **The order of reasons for E on a deck:** a full deck is `DECK_FULL` before an empty hand is `NO_PLANK_IN_HAND` (the object is read first, UX-6). **(Reversed during development, Sonlm 2026-11-21: the hand is read first, `NO_PLANK_IN_HAND` before `DECK_FULL`; see Completion Notes.)** A strip of a deck with no planks is `NO_PLANKS_LEFT`.
- **Press once:** only a second press of the **same** input stops its hold; any other input during it is ignored; releases are ignored. Tab: a press raises the forearm, the next press lowers it. The mode in force when a command is taken decides what it does; switching mode mid-hold leaves the running hold as it is. **(Changed by the code review, Sonlm 2026-11-21: a change of mode cancels the running hold and lowers the forearm.)**
- **The forearm is sim state, not an event.** `sim.hands.forearm_raised` is read by the view like the warden's position; raising and lowering emit nothing (no rule or log needs them yet).

## Tasks / Subtasks

Build order (AD-46). Do not touch `watch/night/` until T1 to T5 pass.

- [x] **T1. Tests first (AC 1 to 11)**
  - [x] 1.1 `tests/watch/test_look.gd` (`WatchTest`): the look target (Dev Notes "LookRules"). From a placed start (`warden_along`, plus walking sideways where x matters), aiming with `set_view` and one `advance()`, each aim worked out in the test from the numbers written out: the deck of the section underfoot at pitch −1.2 rad (the line meets the deck 1.71 m from the eye); the next section's deck across a section edge; nothing at pitch 0 (the horizon); nothing beyond 2 m (pitch −0.85: the deck is 2.1 m along the line); a standing rail from x −2.2 facing −X (yaw +π/2) at pitch −1.107 (atan of 0.6 down over 0.3 across: the rope is at x −2.5, y 1.0; at pitch 0 the line passes over the 0.3 m grab box); nothing where a stripped rail was (the line then goes on to the deck or to nothing); a blocker hit first gives nothing: from section 6 just short of the landing, looking toward the town and down so the line meets the landing's top, the target is `NONE`, and a little steeper so it meets section 6's deck first, the target is that deck. Yaw sign: yaw +π/2 faces −X (LEFT).
  - [x] 1.2 `tests/watch/test_hands.gd` (`WatchTest`), the rules. Spec values literally, with sources: strip plank 120 ticks (GD-19: 2 s), strip rail 180 (3 s), re-lay 180 (3 s), cancel at more than 0.5 m (GDD Controls), reach 2 m, town section floor 4 (GD-19).
    - AC 1: press `HAMMER` queued before tick T; `HOLD_STARTED` on T; planks and hand unchanged on every tick up to T+119; `PLANK_STRIPPED` on T+120 with deck −1, hand +1. The plank that leaves is the next in `SpanGeometry`'s order (the count is all the sim keeps).
    - AC 2: `ROPE` at a standing rail: `RAIL_STRIPPED` on T+180, `rail_standing` false, ropes in hand +1.
    - AC 3: `USE` at a deck of 5 with planks in hand: `PLANK_RELAID` on T+180; also onto a deck of 0 (GD-69).
    - AC 4: each refusal emits exactly one `REFUSED` with its reason (`NO_PLANK_IN_HAND`, `DECK_FULL`, `LAST_SECTION_MINIMUM`) and `checksum()` before equals after; plus `NO_PLANKS_LEFT` and `NO_ACTION_HERE`; the town section at 4 still gives its rails (on 6 sections and on 4).
    - AC 5: release on T+60 → `HOLD_CANCELLED` on T+60, nothing moved; a release on T+120 itself cancels (the release is taken in step 1, before completion in step 2); walking 0.5 m keeps it, 0.5 m + one step cancels; turning the view a full circle during the hold does not cancel. "Can no longer be started": `HandRules.check()` (pure) returns a refusal for the hold's own target once the state no longer allows it (tested on a second sim whose `StartState` has that state). **Known gap, say so in Completion Notes:** no rule in this story can change the span under a running hold (one action at a time, nothing else moves parts), so the cancel branch of `HoldRules.tick()` for "impossible" cannot be reached through commands and ticks, and no test fails if it is deleted. Do not reach into sim fields to force it. Record it as a new deferred item for story 1.5 (a section falling under a strip hold must cancel it), T10.
    - AC 6: a second input pressed mid-hold changes nothing and emits nothing; the first completes on time.
    - AC 7: `NightCommand.set_option(HOLDS, PRESS_ONCE)` before the press: the hold runs its full time with no release; a release is ignored; a second press of the same input cancels; a press of another input is ignored; walking 0.5 m + one step cancels; Tab press raises, Tab press again lowers, Tab release does nothing.
    - AC 8: Tab press with no hold → `hands.forearm_raised`; while raised, the warden still walks (60 ticks forward → 3.5 m) and a `HAMMER` press does nothing (no `HOLD_STARTED`, no `REFUSED`); Tab release lowers; a Tab press during a hold is ignored.
    - AC 9: strip 20 planks in a row (several sections), hand at 20, no limit and no fault.
    - AC 10 / D3, case 1: on section 3 at 1 plank (along 14.0), strip it from where the warden stands: `PLANK_STRIPPED`, section 3 at 0, the warden's position unchanged on that tick; walking toward the town moves them on every tick, through 15.0 to 15.3 without stopping (the band where a probe is still on the bare section), and on into section 4; then walking back toward section 3 stops at `section_end(3) + 0.3` = 15.3 (1.3's D1).
    - D3, case 2: the warden on section 4 at along 15.1 strips section 3's last plank (looking back toward the far pier and down): afterwards they can walk toward the town and also toward section 3 (it holds them), and once past 15.3 toward the town the bare section blocks again at 15.3.
    - D3, a negative: a warden standing at along 15.5 when section 3 goes bare in a `StartState` cannot walk into it (stops at 15.3); with section 3 bare from the start, no warden reaches 15.0 to 15.3.
    - On the town section the floor of 4 refuses before a last plank can go.
  - [x] 1.3 `test_night_sim.gd`: step list unchanged (13 steps). `checksum()` now also covers the hold and the forearm (same seed, same commands → same checksum; a different command → a different one). `set_option` with a value outside the enum is `sim.bad_input` and changes nothing.
  - [x] 1.4 `test_span_view.gd` (DW-27): `_test_reconcile_follows_state` drives the counts with strip and re-lay commands from a `StartState` (warden placed, view aimed), not with `SpanRules.move_parts()`; the same checks on the view.
  - [x] 1.5 `test_trace.gd` (DW-28): lines for the new kinds (Dev Notes "Trace").
- [x] **T2. Constants and ticks**
  - [x] 2.1 `SpanConstants`: `STRIP_PLANK_S: float = 2.0`, `STRIP_RAIL_S: float = 3.0`, `RELAY_PLANK_S: float = 3.0` (GD-19), `LAST_SECTION_MIN_PLANKS: int = 4` (GD-19: section 6, the town section).
  - [x] 2.2 `sim/hand_constants.gd` `HandConstants`: `REACH: float = 2.0` (GDD Controls: "within 2 m"; metres), `HOLD_MOVE_LIMIT: float = 0.5` (GDD Controls: "moving more than 0.5 m").
  - [x] 2.3 `NightTicks` becomes the object AD-33 and Data Patterns describe: keep `TICKS_PER_SECOND` and `of()`; add `var strip_plank: int`, `strip_rail: int`, `relay_plank: int`, filled in `_init()` from the constants. `NightSim.ticks: NightTicks`, built once in `_init`.
  - [x] 2.4 `SpanGeometry.rail_grab_box(n, side)` and `RAIL_GRAB_SIZE` (D1); its `##` says it is centred on `rail_box()`.
- [x] **T3. Types, events, commands, state**
  - [x] 3.1 `NightTypes`: `enum Reason { NONE, NO_ACTION_HERE, NO_PLANKS_LEFT, LAST_SECTION_MINIMUM, DECK_FULL, NO_PLANK_IN_HAND }`; `enum HandAction { NONE, STRIP_PLANK, STRIP_RAIL, RELAY_PLANK }`; `enum Option { HOLDS }`; `enum Holds { HOLD, PRESS_ONCE }`. Each with a `##` line.
  - [x] 3.2 `NightEvent`: kinds `HOLD_STARTED`, `HOLD_CANCELLED`, `PLANK_STRIPPED`, `RAIL_STRIPPED`, `PLANK_RELAID`, `REFUSED`, each with its "Fields:" comment (Dev Notes "Events"). `reason` becomes `NightTypes.Reason = NightTypes.Reason.NONE` (its comment loses "until story 1.4").
  - [x] 3.3 `NightCommand`: `Kind.SET_OPTION`, `static func set_option(option: NightTypes.Option, value: int)`, fields `option` and `value`; update the header comment.
  - [x] 3.4 `sim/look_target.gd` `LookTarget` (value: `kind` enum `NONE, DECK, RAIL`, `section`, `side`, `distance`); `sim/hands_state.gd` `HandsState` (Dev Notes "HandsState").
  - [x] 3.5 `NightSim`: `hands: HandsState`, `look: LookTarget` (this tick's, worked out in step 1), `holds: NightTypes.Holds = HOLD`, `refuse(reason, ...)` (AD-67), `checksum()` adds the hands' state. Step 1 and step 2 bodies (Dev Notes "The tick").
- [x] **T4. The rules**: `sim/look_rules.gd` `LookRules`, `sim/hand_rules.gd` `HandRules`, `sim/hold_rules.gd` `HoldRules` (Dev Notes); `WardenRules` gains D3 (Dev Notes "WardenRules and D3").
- [x] **T5. Run the sim tests**: `godot --headless --path game --import` (new `class_name`s), then the tests. T1 passes before T6 starts.
- [x] **T6. The view**. Only now.
  - [x] 6.1 Tests first: `tests/watch/test_hands_view.gd` and the input half of `test_warden_node.gd` (Dev Notes "Tests of the nodes").
  - [x] 6.2 `InputActions`: `const NIGHT_INPUTS: Array[NightTypes.HandInput]` and `static func action_of(input) -> StringName` (the architecture's Novel Pattern 3 example), mapping every `HandInput` to its night action. No new action in the table. `test_input_actions.gd`: every `HandInput` value is in `NIGHT_INPUTS` once and maps to an action that is in `ACTIONS` (HAMMER → `watch_hammer`, ROPE → `watch_rope`, USE → `watch_use`, SHUTTER → `watch_shutter`, BUILD_TRAPDOOR → `watch_build_trapdoor`, BUILD_BEAM → `watch_build_swing_beam`, DISMANTLE → `watch_dismantle`, FOREARM → `watch_forearm`), and no two inputs share one.
  - [x] 6.3 `night.gd`: `_unhandled_input` sends `NightCommand.press` / `release` for each night input (Novel Pattern 3's code), only once `setup()` has run; the `HandsView` consumer is added after the warden.
  - [x] 6.4 `watch/night/hands.gd` `HandsView` (the forearm; Dev Notes "The forearm view"), a child of the warden's `Camera3D` built in code by `night.gd` (no `.tscn` edit needed; if one is made, no transforms typed, AD-62).
- [x] **T7. Bot and show-me setups (AC 11; M1, M2)**
  - [x] 7.1 `NightBot.strip` (Dev Notes "Bot"), added to `paths()`. `test_bot_nights.gd`: per-tick check updated for D3 (Dev Notes); `_test_every_kind_produced` also covers every `NightTypes.Reason` but `NONE` (its header promised this for 1.4); a new `_test_strip_reaches_its_cases` checks the path really produced each case it is written for, on both nights and three seeds.
  - [x] 7.2 `ShowSetups`: rows `strip` and `forearm` (Dev Notes "Show-me setups"); `test_show_setups.gd` checks both and that each sim reports no fault.
- [x] **T8. Trace (DW-28)**: `NightTrace.line()` gains "who" and the side (Dev Notes "Trace").
- [x] **T9. CI**: no new step. The show count goes from 3 to 5; every smoke run stays warning-free.
- [x] **T10. Docs**: `game/WATCH.md` (left mouse strips a plank, right mouse a rail, E re-lays, Tab raises the forearm; holds; `--show=strip`, `--show=forearm`); `_bmad-output/project-context.md` (Dev Notes "Docs"); `deferred-work.md`: close DW-27 and DW-28; add to DW-33 that from this story a refocus click is a real hammer press; add a new item (next free DW number) owned by story 1.5: "a hold made impossible by the span changing under it is cancelled by `HoldRules.tick()`, but nothing in story 1.4 can change the span under a hold, so that branch has only its pure `check()` test; story 1.5 adds a strip hold on a section that falls and checks the `HOLD_CANCELLED`".
- [x] **T11. Close**: `tools/ci.sh` passes. Fill in the Dev Agent Record. Run the end-of-story chores of `_bmad/custom/gds-dev-story.toml`: M1 and M2 listed as NOT verified, needs Sonlm; the agent may still render `--show=strip` and `--show=forearm` on Xvfb as a smoke look (the forearm stays down with no Tab), and say so; agent time; commit. Set Status to `review`.

### Review Findings

Code review of 2026-11-21 (gds-code-review; Blind Hunter, Edge Case Hunter, Acceptance Auditor; the `game/` diff `6043d4a..11c38bb`, 2931 lines). No high-severity finding. The Acceptance Auditor found no acceptance criterion violated: AC 1 to 4 and 6 to 11 met; AC 5 partly (the "impossible" cancel has no test through the tick, as the story allowed: DW-34). The reviewers ran no tests; Every decision and patch below is applied; `tools/ci.sh` then: 846 passed, 0 failed, 48 expected (was 804 and 46). What is on screen in M1 and M2 was then rendered and judged by the agent (Completion Notes); how the holds feel is still Sonlm's.

- [x] [Review][Decision] Press once: a press meant to stop a hold that lands one tick after it completed starts a new hold, which then runs its full time unattended and moves a second part — `HoldRules._clear()` forgets the finished hold, so on tick T+N+1 the same press is a fresh start; in Press once nothing but another press or a 0.5 m move stops it [game/watch/sim/hold_rules.gd:75]. Not covered by the story's "settled" list. Options: a short grace after completion in which the same button is ignored; or leave it and record it for epic 8 (the Holds setting row). Decided by Sonlm: a short grace. Done: `HandConstants.PRESS_ONCE_GRACE_S` 0.25 s (15 ticks); the hold's own button is ignored for that long after it completes, in Press once only; another button acts at once.
- [x] [Review][Decision] The Holds option changed while a hold runs or the forearm is up leaves a state no button is holding — Press once to Hold with the forearm toggled up: it stays up and every hand press is silently dropped until Tab is pressed and released; with a hold running: it completes with no button down. Hold to Press once with a button down: its release is ignored and the hold runs on. The story settled "switching mode mid-hold leaves the running hold as it is" without a question, and no test covers either case [game/watch/sim/hold_rules.gd:58]. Options: a mode change cancels the running hold and lowers the forearm; or keep the recorded reading and add tests that pin it. Decided by Sonlm: cancel and lower. Done: a change of the Holds option cancels the running hold (`HOLD_CANCELLED`), lowers the forearm and ends the grace; setting the mode it already has changes nothing.
- [x] [Review][Patch] (medium) "ac8: raising emits nothing" cannot fail: the Tab press tick's and the release tick's events are thrown away, and the check repeats the one above it on the same list [game/tests/watch/test_hands.gd:504]
- [x] [Review][Patch] (medium) `_test_strip_reaches_its_cases` also counts what the wander's random taps produce, so "cancel by letting go", "forearm raised", "walked with the forearm up", "forearm lowered" and `NO_ACTION_HERE` stay green with their scripted steps removed; and any cancel while Press once is on counts as "a second press" [game/tests/watch/test_bot_nights.gd:153] [game/watch/debug/bot/night_bot.gd:197]
- [x] [Review][Patch] The strip bot hard-codes its hold lengths (120, 180) beside `sim.ticks`; one `LONG_HOLD_TICKS` serves two durations that are tuned apart [game/watch/debug/bot/night_bot.gd:35]
- [x] [Review][Patch] Checks that cannot fail: `before != 0` in the bad-option twin check [game/tests/watch/test_night_sim.gd:301]; `get_node("Skin") == first` (the skin is never rebuilt) [game/tests/watch/test_hands_view.gd:98]; "no setup: nothing sent" asserts only `_sim == null` [game/tests/watch/test_warden_node.gd:350]; consumer order named in a comment but not asserted [game/tests/watch/test_warden_node.gd:355]; a result overwritten unread [game/tests/watch/test_hands.gd:412]
- [x] [Review][Patch] Missing tests: a press and a release of the same button taken in one tick; a hand press with the forearm toggled up in Press once; the strip night run by `_test_event_fields_match_comments` has its faults looked at by nothing [game/tests/watch/test_hands.gd] [game/tests/watch/test_night_sim.gd:205]
- [x] [Review][Patch] `LookRules`' far-pier blocker has no test: removing `far_pier_box()` fails nothing. Add a case if one exists; if nothing targetable can lie behind the pier, say so beside the blocker [game/watch/sim/look_rules.gd:15] [game/tests/watch/test_look.gd:110]
- [x] [Review][Patch] `NightBot.strip` on a def with fewer than 4 sections silently folds its sections `a`, `b` and the town into one another, and `_go_to` gives up silently when its guard runs out: report a fault [game/watch/debug/bot/night_bot.gd:118] [game/watch/debug/bot/night_bot.gd:233]
- [x] [Review][Patch] Stale comments: "then its left rail" over `Side.RIGHT` [game/watch/debug/bot/night_bot.gd:181]; "section 1 at 7 so a strip of section 6 (at 8) is allowed" over a plain start, and the unused `def_a` [game/tests/watch/test_night_sim.gd:265]; the label "14.517 + 30 steps" over `15.1 + 20 * STEP` [game/tests/watch/test_hands.gd]; the over-long header line [game/watch/sim/warden_rules.gd:4]
- [x] [Review][Patch] Ledger: DW-34 carries two gaps with two owners (story 1.5, and epic 3 for `refuse()`'s side branch): split the second into its own item, so closing DW-34 does not lose it. The view check "the rail is back", dropped with DW-27, has no item that brings it back when a rule re-hangs a rope (epic 4): add one [_bmad-output/implementation-artifacts/deferred-work.md]
- [x] [Review][Patch] Docs: `sprint-status.yaml` is missing from the File List; this story still gives the old refusal order (`DECK_FULL` before `NO_PLANK_IN_HAND`) in "Decisions for this story", "HandRules" and "Decisions taken with Sonlm"; `project-context.md` gives `sim.refuse(reason)` in two places and `sim.refuse(reason, target, action)` in a third [_bmad-output/project-context.md:60]
- [x] [Review][Defer] A button whose release never arrives (the window loses focus while it is held) leaves a Hold-mode hold running to completion, or the forearm up; the same lost release leaves the warden's `_swallow_release` set, so the next hammer release is swallowed; and with the mouse freed by Esc, right mouse, E and Tab still act [game/watch/night/night.gd:65] [game/watch/night/warden.gd:99] — deferred to epic 5's focus-loss pause, with DW-33 (DW-36)

Dismissed (9): D3 letting a held warden cross the bare section, and step onto a neighbour that was already bare (D3 is Sonlm's decision; DW-35 carries the neighbour, owner story 1.6); the rail's 0.3 m grab box winning over the deck behind it (D1, tuned in M1); `HOLD_CANCELLED` carrying no cause (the story leaves it out on purpose); the bot's per-tick check "waiving" `can_stand` whenever a section holds the warden (`_held` is emptied the tick the warden leaves the band, so it is never waived elsewhere); `_complete()` with no default branch and `HandsView` with no bound on rows (both unreachable with three actions and 48 planks); the `MOVE_SLACK` test leaning on one float sum (the same engine build gives the same sum); the build order not provable from whole commits; `LookRules` reading the section count from the span and not the def.

## Dev Notes

### What this story is

The warden's hands arrive in the sim. Each tick the sim works out what the warden looks at within 2 m (`LookRules`), turns each button press into an action or a refusal (`HandRules`) and runs holds in ticks (`HoldRules`), moving parts only through the ledger. The forearm is sim state (`hands.forearm_raised`), drawn by a first `HandsView` as ink tallies in fives. Two deferred items close: DW-27 (a view test that moved parts by hand) and DW-28 (the trace's who and side).

**Not in this story** (do not build ahead): the hands themselves, ready poses, hold animations, cancel and "can't" gestures (epic 4 story 1; D4); sound of any kind (epic 2 on); load, creak, collapse, "fallen", test weights (1.5); edging round an open section and crossing a gap (1.6; D3 is the stand-in); "the section ahead" (epic 4, building); the name on the forearm (epic 5); a wound cancelling a hold (epic 4); pause freezing a hold (epic 5; nothing to do: a paused sim is not ticked); the Holds setting row (epic 8); a strike or any tap action (epic 4); the playtest log's refusal counts (epic 6). No HUD. Gray boxes.

### Current state of the files this story changes (read 2026-11-21, commit `6043d4a`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/sim/night_sim.gd` | 13 steps; step 1 takes move, view, `WardenRules.walk()`, then stores the queued commands in `commands` (read by nothing); steps 2 to 13 empty but 5 (`NIGHT_STARTED`); `checksum()` = tick, rng state, warden position, yaw, pitch, part counts; `_apply_start` moves what `StartState` takes into the hand; `_place_warden` (D3 of 1.3) | `ticks`, `look`, `hands`, `holds`; step 1 adds the look target and applies the commands; step 2 runs the hold; `refuse()`; checksum adds the hands | The step list (the test compares it literally), the faults (`sim.bad_input`, `sim.move_too_long`, `sim.bad_def`, `span.bad_start`, `warden.bad_start`), `emit()` stamping `t`, the start's parts going to the hand |
| `game/watch/sim/night_types.gd` | `Side`, `Part`, `HandInput` | `Reason`, `HandAction`, `Option`, `Holds` | Existing enums and their order (tests and the checksum rely on them) |
| `game/watch/sim/night_event.gd` | One kind, `NIGHT_STARTED`; `reason: int = -1` | Six kinds; `reason` typed | Every field and its default; the "Fields:" comment convention (a test parses it) |
| `game/watch/sim/night_command.gd` | `PRESS`, `RELEASE` | `SET_OPTION` | `press()` / `release()` |
| `game/watch/sim/night_ticks.gd` | Static only | Also an object with one field per duration | `TICKS_PER_SECOND`, `of()` and their callers (`walk_step`) |
| `game/watch/sim/span_constants.gd` | Sizes | Strip and re-lay times, the town section's floor | The sizes |
| `game/watch/sim/span_geometry.gd` | Boxes for decks, rails, posts, beams, piers, landing | `rail_grab_box` (D1) | Every shape and the plank order |
| `game/watch/sim/warden_rules.gd` | `walk`, `can_stand`, `stands_on`, `walkable`, `reach`; `reach` returns `from` when `from` cannot be stood on; its `##` names this story | D3 | Exact stops (the tests at 0.001 m), sliding, the bot's own arithmetic |
| `game/watch/core/input_actions.gd` | The table; no `NIGHT_INPUTS` | `NIGHT_INPUTS`, `action_of()` | The table exactly (a test compares it to the GDD list) |
| `game/watch/night/night.gd` | Builds sim, span view, warden; ticks with move and view | Sends press and release commands; adds `HandsView` | `setup()` before the tree; consumer order; `night.no_setup` when run alone |
| `game/watch/night/warden.gd` | Look, wish, blend, D2 (Esc frees, click recaptures, its release swallowed) | Nothing, unless a test shows the recapture click reaching the hands | D2 exactly: the recapture click must never become a `HAMMER` press |
| `game/watch/debug/bot/night_bot.gd` | `span_counts` (presses and releases `USE` every 60 ticks, which did nothing until now), `walk` | `strip`; `span_counts`' `USE` presses now meet the rules (its warden looks at the sky most of the time, so they are refusals; that is fine, and the per-tick checks still hold) | Signatures; `walk` unchanged |
| `game/watch/debug/show/show_setups.gd` | `span_counts`, `walk`, `walk_close` | `strip`, `forearm` | Existing rows and `def_of()` |
| `game/watch/debug/trace.gd` | Time, kind, id as who, `s3` | Who and side (DW-28) | `NIGHT_STARTED`'s line exactly (CI greps it) |
| `game/tests/watch/test_bot_nights.gd` | Totals, faults, `can_stand` and its own arithmetic per tick; event coverage | D3 in its arithmetic; reasons in coverage | The rest |
| `game/tests/watch/test_span_view.gd` | Reconcile test moves parts directly (DW-27) | Commands and ticks | The view checks |

`look_rules.gd`, `hand_rules.gd`, `hold_rules.gd`, `hand_constants.gd`, `look_target.gd`, `hands_state.gd`, `watch/night/hands.gd` do not exist yet.

### LookRules (AD-15, AD-47)

`class_name LookRules extends RefCounted`, static, pure: `static func target(eye: Vector3, yaw: float, pitch: float, geometry: SpanGeometry, span: SpanState) -> LookTarget`.

- The view line: from `eye` along `Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch))` (AD-67: yaw 0 faces −Z, positive turns left; pitch positive up), as a segment of length `HandConstants.REACH`.
- Shapes, all from `SpanGeometry`: `deck_box(n)` of every section (planked or not; "fallen" joins in 1.5), `rail_grab_box(n, side)` of every **standing** rail, and two blockers that are never targets: `landing_box()` and `far_pier_box()`. The nearest hit wins; a blocker hit first means `NONE`.
- `AABB.intersects_segment(from, to)` returns the entry point or `null`, works on the landing's zero-height box and returns `from` when `from` is inside (checked on this server, 2026-11-21). `distance` = `eye.distance_to(hit)`.
- Called once per tick in step 1, after `WardenRules.walk()`, with `eye = warden.position + Vector3(0, WardenConstants.EYE_HEIGHT, 0)`; the result is `sim.look`, this tick's value (derived each tick, never carried over; AD-35).

### HandRules (AD-15, AD-47)

`class_name HandRules extends RefCounted`, static.

- `static func action_for(input: NightTypes.HandInput, target: LookTarget) -> NightTypes.HandAction` (pure): `HAMMER` + `DECK` → `STRIP_PLANK`; `ROPE` + `RAIL` → `STRIP_RAIL`; `USE` + `DECK` → `RELAY_PLANK`; everything else → `NONE`.
- `static func check(action: NightTypes.HandAction, target: LookTarget, def: NightDef, span: SpanState) -> NightTypes.Reason` (pure): `NONE` when the action can be started on that target now, otherwise the reason:
  - `NONE` action → `NO_ACTION_HERE`;
  - `STRIP_PLANK`: deck at 0 → `NO_PLANKS_LEFT`; the town section (`def.section_count`) at `LAST_SECTION_MIN_PLANKS` or fewer → `LAST_SECTION_MINIMUM`;
  - `STRIP_RAIL`: rail not standing → `NO_ACTION_HERE` (a target is only ever a standing rail, so this happens only for a hold whose rail went; GDD's locked rails and beam rails are epic 3 and 4);
  - `RELAY_PLANK`: deck at `def.planks_per_section` → `DECK_FULL`; no plank in hand → `NO_PLANK_IN_HAND`. ("Not fallen" joins in 1.5.) **(Reversed during development, Sonlm 2026-11-21: the hand is read first, `NO_PLANK_IN_HAND` before `DECK_FULL`; see Completion Notes.)**
- `HoldRules` calls `check()` every tick on the running hold's **own** target. That is the one owner of "the action can no longer be started there" (AD-67).

### HoldRules (AD-50, UX-39)

`class_name HoldRules extends RefCounted`, static; the functions that change state take `sim` last and return nothing.

- **`take(command, sim)`**, in step 1 for each queued command in arrival order:
  - `SET_OPTION`: `HOLDS` sets `sim.holds`; an unknown option or value is `sim.bad_input` (fault) and changes nothing.
  - `PRESS` of `FOREARM`: ignored during a hold; in Hold mode raises; in Press once mode toggles.
  - `RELEASE` of `FOREARM`: in Hold mode lowers; in Press once mode ignored.
  - `PRESS` of a hand input: while the forearm is up → ignored; while a hold runs → in Press once mode a press of the hold's own input cancels it (`HOLD_CANCELLED`), anything else is ignored; otherwise `action_for(input, sim.look)`, then `check()`: a reason → `sim.refuse(reason, ...)` with the target's section and side; none → the hold begins (`HOLD_STARTED`), storing action, input, a copy of the target, the warden's position, the begin tick and its length in ticks.
  - `RELEASE` of the running hold's input in Hold mode → `HOLD_CANCELLED`; any other release → nothing.
- **`tick(sim)`**, step 2, for a running hold, in AD-34's order: (1) still possible? the feet more than `HOLD_MOVE_LIMIT` from where it began (x and z only) or `check()` gives a reason → `HOLD_CANCELLED`; (2) progress; (3) completion → the ledger move, its completion event, the hand empty again.
- **Timing (AD-33, AD-67).** A press taken on tick T begins the hold on T; it completes on tick T + N (N = 120 or 180), never earlier, and its event carries that tick. Count it down, starting on the tick after it began (a hold begun in step 1 of tick T has no progress in step 2 of tick T). A release taken on tick T + N cancels it, because step 1 runs before step 2 (AD-50: "a release on the same tick as the last one cancels it").
- **Completion moves:** `STRIP_PLANK`: 1 plank `deck(n)` → `hand()`; `STRIP_RAIL`: 1 rope `rail(n, side)` → `hand()`; `RELAY_PLANK`: 1 plank `hand()` → `deck(n)`. Only through `SpanRules.move_parts()`.
- **`progress(hands) -> float`** (pure): 0 to 1, for epic 4's hands. Nothing in this story draws it.

### HandsState (Novel Pattern 3)

`class_name HandsState extends RefCounted`: base facts only. `action: NightTypes.HandAction` (`NONE` when idle), `input: NightTypes.HandInput`, `target: LookTarget` (a copy taken when the hold began), `began_at: Vector3` (the feet), `ticks_left: int`, `ticks_total: int`, `forearm_raised: bool`. A hand pose per hand joins it in epic 4. "Is a hold running" is `action != NONE`, worked out, never stored twice.

### Events

Every new kind's `##` comment ends with its "Fields:" list (the fields test parses it). `id` carries the action as a lower-snake name: `&"strip_plank"`, `&"strip_rail"`, `&"relay_plank"`; side is set only for a rail action.

| Kind | When | Fields |
|---|---|---|
| `HOLD_STARTED` | A hold began (step 1) | t, section, side, id |
| `HOLD_CANCELLED` | Let go, a second press in Press once, moved more than 0.5 m, or impossible on its target | t, section, side, id |
| `PLANK_STRIPPED` | A strip completed (step 2) | t, section |
| `RAIL_STRIPPED` | A rail strip completed | t, section, side |
| `PLANK_RELAID` | A re-lay completed | t, section |
| `REFUSED` | A designed "no" (AD-28): `sim.refuse()` | t, reason, section, side, id |

`REFUSED` with `NO_ACTION_HERE` has `section` 0 and `id` `&""`. The cause of a cancel is not a field: no rule or log reads it yet (epic 6 may ask).

`NightSim.refuse(reason: NightTypes.Reason, target: LookTarget, action: NightTypes.HandAction)` (or an equivalent the dev finds plainer) builds and emits the `REFUSED` event. The architecture's `sim.refuse(reason)` is the minimum; the extra arguments only fill the event's fields.

### The tick (AD-34; step list unchanged)

- **Step 1:** move wish and view → `WardenRules.walk(self)` → `look = LookRules.target(...)` → each queued command through `HoldRules.take()` → `commands` keeps the taken list for the recording (epic 6). Update its `##` comment.
- **Step 2:** `HoldRules.tick(self)`. Update its `##` comment.
- Nothing else changes. Step 4's consequences stay empty: the last plank going under the warden is D3, not `ConsequenceRules` (story 1.5 brings `settle()`; 1.6 the edging).

### WardenRules and D3

`walk()` today: `reach()` returns `from` when `from` cannot be stood on. D3: in `walk()`, when the warden's own position cannot be stood on, add to this tick's floors the deck rectangle of every bare section that holds the feet or one of the four clearance probes (feet ± 0.3 m in x and z), then call `reach()`. Adding only "the section under the feet" is wrong: a warden at along 15.04 has the feet on section 4 and a probe on bare section 3, so `from` still could not be stood on and `reach()` would return `from` for good (frozen in the 15.0 to 15.3 band); the same happens to a warden on section 4 within 0.3 m of the edge who strips section 3's last plank. With the probes' sections added, the warden walks out through the band; once `can_stand` is true again no extra floor is added, so the bare section blocks as before (1.3's D1). Keep `can_stand`, `stands_on`, `reach` pure and unchanged in meaning; update `walk()`'s `##` (it named this story).

### NightBot.strip (AD-63)

A new path, `(def, seed, faults, each_tick) -> NightSim`, on its own `StartState`. Its length follows from its script: a full section stripped bare is 960 ticks alone and the town section down to 4 another 480, so expect 3000 to 4500 ticks. If one empty-handed start cannot reach every case below in that, split it into two paths (`strip` and `strip_refusals`), each on its own `StartState`. Scripted, with a short wander at the end from the bot's own generator (as `walk`). It aims by computing yaw and pitch from the eye to a point given by `SpanGeometry` (a small helper in the bot; the sim is never asked to aim). It must produce, on 6 and on 4 sections:

1. every refusal: `NO_ACTION_HERE` (hammer at the sky), `NO_PLANK_IN_HAND` (E at a deck before any plank is in hand: start with an empty hand, so the path's `StartState` takes nothing off), `DECK_FULL` (E at a full deck once a plank is in hand), `LAST_SECTION_MINIMUM` (the town section stripped to 4 by the bot itself, then once more), `NO_PLANKS_LEFT` (hammer at a bare deck);
2. a strip, a rail strip (including a town-section rail at 4 planks), a re-lay, and a re-lay onto a bare deck;
3. a cancel by letting go, by walking 0.6 m, and a second press in Press once mode (via `set_option`);
4. the last plank of the section underfoot stripped, then walking off it toward the town (D3);
5. Tab: raised, walked with, a hammer press ignored, lowered.

`test_bot_nights.gd`'s per-tick "stands where it can" arithmetic gains D3: a warden on, or within 0.3 m of, a section with no planks is allowed only while it has been on or within 0.3 m of that section without a break since the tick that section's last plank was stripped. Track that in the test file from the `PLANK_STRIPPED` events and positions, not by asking `WardenRules`.

### Show-me setups (AD-56)

| Name | Description (as `--show=list` prints it) | `StartState` |
|---|---|---|
| `strip` | `strip planks and a rail, re-lay one, read the forearm (M1 of story 1.4)` | Full span, nothing in hand, `warden_along = 22.5` (mid section 5) |
| `forearm` | `12 planks and 3 ropes in hand; hold Tab on the landing (M2 of story 1.4)` | `planks = {1: 0, 2: 4}` (12 planks in hand), `stripped_rails` of three rails on sections 1 and 2 (3 ropes in hand); warden on the landing |

### The forearm view (`watch/night/hands.gd`)

`class_name HandsView extends Node3D` ("Hands" alone is a bare generic word, AD-41; the architecture's file name `hands.gd` stays). A consumer (`on_tick(events, sim)`) that reconciles with state every tick (AD-49): shown when `sim.hands.forearm_raised`, hidden otherwise; its strokes rebuilt only when the counts in hand change.

- A child of the warden's `Camera3D`, so it turns with the view at once and needs no `TickBlend` (it does not move in the world; the camera does). Lowered = hidden: no raise animation in gray box (epic 4/7).
- A flat light box ("skin") about 0.35 m in front of the eye, below centre, tilted toward the eye; strokes are thin dark boxes on it. Rows per D2. A group of five is four upright strokes and one across them; a row wraps after 5 groups; 48 planks need 2 rows.
- Materials unshaded (`EXPERIENCE.md`: the forearm keeps a minimum brightness with no lantern lit), with `no_depth_test` and a raised render priority so the forearm is never cut by a rail or post; sizes are named gray-box constants in this file, not rules.
- Pure and testable: `static func strokes(count: int) -> Array[...]` (or similar) gives the layout of `count` strokes; the node only places boxes from it.

### Tests of the nodes (headless)

- `test_hands_view.gd` (`WatchTest`): `strokes(0)` is empty; `strokes(5)` is four upright and one across; `strokes(12)` is two fives and two; `strokes(48)` wraps to 2 rows of planks; the view hidden when the forearm is down and shown when up (driven by commands and ticks on a sim, not by writing sim fields); rebuilt when the hand's count changes; the plank row and the rope row each carry their sign (D2).
- `test_warden_node.gd` (or a new `test_night_input.gd`): with the night in the tree and `setup()` done, a left mouse press and release sent through the viewport reach the sim as `HAMMER` press and release (a `HOLD_STARTED` or `REFUSED` follows on the next tick); E, right mouse and Tab likewise; with the mouse free (D2), the recapture click reaches **no** hand (no `HAMMER` command at all, press or release); a night opened without `setup()` sends nothing.

### Trace (DW-28)

`NightTrace.line()`: "who" is `warden` for the six new kinds (the hands are the warden's) and the event's `id` (the action) follows it where it has one, e.g. `  4.000 PLANK_STRIPPED    warden s3`, `  7.000 RAIL_STRIPPED     warden s5 L`, `  9.000 REFUSED           warden strip_plank s6 LAST_SECTION_MINIMUM`. Where is `s3`, plus ` L` or ` R` when the event carries a side (a rail action: `RAIL_STRIPPED`, or a hand event whose `id` is `strip_rail`). The kind column widens to fit the longest kind name (`HOLD_CANCELLED` and `PLANK_STRIPPED` are 14 letters; the column is 17 today, keep 17 if every name fits). `NIGHT_STARTED`'s line stays exactly as it is (CI greps it).

### Docs

- `WATCH.md`: the night's hand keys and holds (Hold mode; Press once has no setting until epic 8); the two new show-me setups.
- `project-context.md`, "Where things are": what is looked at is `sim.look` (`LookRules`, from the eye within 2 m); a hold is `sim.hands` (`HoldRules` alone starts, runs, cancels and completes it); refusals are `REFUSED` with a `NightTypes.Reason`. Under "The night screen": the forearm is `HandsView`, drawn over the world. Update `Last Updated`.

### Project Structure Notes

```
game/watch/sim/look_rules.gd, hand_rules.gd, hold_rules.gd,
               hand_constants.gd, look_target.gd, hands_state.gd     NEW (RefCounted, class_name)
game/watch/sim/night_sim.gd, night_types.gd, night_event.gd,
               night_command.gd, night_ticks.gd, span_constants.gd,
               span_geometry.gd, warden_rules.gd                     UPDATE
game/watch/core/input_actions.gd                                     UPDATE (NIGHT_INPUTS, action_of)
game/watch/night/hands.gd                                            NEW (HandsView)
game/watch/night/night.gd                                            UPDATE
game/watch/debug/bot/night_bot.gd, show/show_setups.gd, trace.gd     UPDATE
game/tests/watch/test_look.gd, test_hands.gd, test_hands_view.gd     NEW
game/tests/watch/test_night_sim.gd, test_span_view.gd, test_trace.gd,
                 test_bot_nights.gd, test_show_setups.gd,
                 test_warden_node.gd, test_input_actions.gd          UPDATE
game/WATCH.md, _bmad-output/project-context.md,
_bmad-output/implementation-artifacts/deferred-work.md               UPDATE
```

- The architecture's file names are kept (`look_rules.gd`, `hand_rules.gd`, `hold_rules.gd`, `hands.gd`). `HandsState` follows the architecture's own name for it.
- `watch/sim/` stays node-free: `AABB`, `Vector3` and `Rect2` are values, not nodes. The purity grep passes `HandInput.` (whole words; story 1.1 checked).
- `InputActions` (core) naming `NightTypes` is what the architecture's own example does.
- Commit the `.uid` files `--import` writes; never invent one.

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, typed GDScript: type everything (`untyped_declaration=2`); `:=` only for `const X := preload(...)`; typed arrays and dictionaries.
- `class_name` for every script another names by type, PascalCase matching the file; no bare generic or engine word (AD-41): `HandsView`, not `Hands`. `--import` after adding one.
- `##` doc comment on every script and non-obvious member, saying why. Constants cite GD-n/UX-n or the story decision, with a unit suffix (`_S`; metres none).
- **Into the sim, nothing but** `set_move`, `set_view`, `command`. Nodes send button states, never meanings: `night.gd` sends press and release, the sim decides.
- **Parts move only through `SpanRules.move_parts()`.** Strength is the count, never stored.
- A rule that changes state takes `sim` last, returns nothing, reports with `sim.emit()` / `sim.refuse()`. A pure query returns a value and emits nothing.
- Time is whole ticks; durations converted once (`sim.ticks`); begun on T, lasting N, done on T + N. No `await`, timers or tweens for anything a rule times.
- `HoldRules` alone cancels a hold that became impossible (AD-67). A designed "no" is `REFUSED`, never an error or a fault; a bug is `faults.report()`.
- No physics in the night: no rays; the look target is maths on `SpanGeometry` boxes (AD-47, AD-52).
- No literal 6 or 30 (or 8) outside `night_defs.gd` and tests: the town section is `def.section_count`, a full deck `def.planks_per_section`.
- No HUD at night; the forearm is an object in the world (ink on skin), not a screen panel. Gray boxes.
- No `print` outside `watch/debug/`.
- Tests: situations only through a `StartState`; spec values written literally with their source; drive by ticks and commands; no `await`; a provoked fault inside `_expect_begin`/`_expect_end`; every `NightEvent.Kind` and `NightTypes.Reason` produced by some test or bot path (AD-63).
- Never `--no-verify`. What is on screen or felt is a manual check.

### Testing standards

- One file per system under `game/tests/watch/`, `_test_<topic>()` functions, `_check(name, ok, detail)`; files that need a night extend `WatchTest`.
- Any engine ERROR or WARNING outside an expect window fails the suite.
- Positions are floats: compare within 0.001 m. Ticks are ints: compare exactly (on which tick an event lands is the point of AC 1 to 3).
- The ear test must still report 120 passed, 23 expected. Story 1.3 ended at 570 passed, 0 failed, 44 expected; run `tools/ci.sh` once before starting to confirm the baseline. It only grows.

### Previous story intelligence (story 1.3, done)

- **The recapture click (D2 of 1.3)** is swallowed press and release by `warden.gd`. It must reach the warden before `night.gd` turns it into a command: Godot sends `_unhandled_input` to nodes in reverse tree order, so a child normally sees an event before its parent, but check it with the test of T6.1 rather than trust it; if the order is wrong, have `night.gd` skip a left click the warden says it swallowed, never the reverse. Test that it never becomes a `HAMMER` command.
- **`EngineGlobals.mouse_captured()`**, never `Input.mouse_mode` (headless never reads captured).
- **`Input.parse_input_event()` is not seen by `Input.get_vector()` in the same frame headless**, but `_unhandled_input` does receive events pushed through the tree's root viewport (`root.push_input(event)`, `test_warden_node.gd` line 215), which is how 1.3's D2 tests drive it.
- **`test_warden_node.gd` turns off the night's physics process** after adding it, so ticks come only from the test. Do the same for input tests.
- **`global_position` on a node outside the tree logs an ERROR**: add the night under `root` first, or compare `position`.
- **The bot's per-tick check has its own arithmetic** beside the rule (the rule may not be its own judge): keep that for D3.
- **Code review asked for:** faults on bad inputs, no silent fallbacks, tests that check both directions of a rule, every fix proven by undoing it, and nothing an agent decided left undisclosed: list every choice the Dev Notes do not settle under Completion Notes as "restrictive reading; Sonlm may revisit".
- **The Xvfb chore**: engine flags before `--`, switches after: `xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --write-movie <dir>/frame.png --fixed-fps 30 --quit-after 60 -- --show=strip`. With no input the warden stands still facing the far pier and the forearm stays down.
- **M checks on the laptop**: Sonlm runs them from the Godot editor on a real GPU at the story's commit; give editor steps, not command lines (the show is chosen by the run's arguments as in story 1.3's M1).

### Git intelligence

Branch `ear-test-prototype`, HEAD `6043d4a` (1.3 done). Recent: `6043d4a` 1.3 done (M1 passed, M2 accepted, DW-31 closed); `fb2ef00` 1.3 code review fixes; `7d7a7ab` story 1.3; `e83e2da` 1.2's pier fix. Pattern: one commit per story step, `Story 1.4: <what>`; the pre-commit hook runs `tools/ci.sh`. Commit on the current branch.

### Latest technical notes (Godot 4.7.2, checked on this server 2026-11-21)

- `AABB.intersects_segment(from, to)` returns the entry point as a `Vector3` or `null`: a 2 m segment down onto a 0.08 m deck hits at its top; a 1 m one misses; a zero-height box (the landing) is hit; a 5 cm rope box is hit when aimed at; a segment starting inside a box returns its start. Typed code must check `is Vector3` before using the result (`Variant`).
- `AABB.intersects_ray` behaves the same without a length.
- No new library or version: nothing outside Godot 4.7.2.

### Decisions taken with Sonlm

Sonlm chose the recommended option for all four on 2026-11-21, at story creation:

1. **D1:** a 0.3 m grab box around the rail rope counts as the rail (`SpanGeometry.rail_grab_box`); the drawn rope stays 5 cm.
2. **D2:** two rows on the forearm, planks above behind an inked bar, ropes below behind an inked ring; strokes in fives; one ink.
3. **D3:** a bare section still holds a warden who was on it, or within 0.3 m of it, when it went bare; they walk off normally, then it blocks.
4. **D4:** nothing new shows a hold in this story; M1 checks the lengths, and "feels like work" is judged again in epic 4 story 1.

Also settled without a question (see "Decisions for this story"): reach measured along the view line from the eye; looking never cancels a hold; a press with no action is `REFUSED` (`NO_ACTION_HERE`), a press during a hold or with the forearm up is ignored; `DECK_FULL` before `NO_PLANK_IN_HAND` (reversed during development: hand first, see Completion Notes); Press once stops only on the same input; the forearm emits no event. The code review of 2026-11-21 changed two of these with Sonlm: a change of the Holds option cancels the running hold and lowers the forearm, and in Press once a hold's own button is ignored for 0.25 s after it completes (see Review Findings).

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1; "Epic 1: story detail" preamble; "Story 1.4"; stories 1.5 and 1.6 (what must not be built here); epic 4 (the hands, story 1)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Game Mechanics 2 (section 6's floor; open sections) and 3 (stripping and re-laying); Controls and Input (the key tables, the hold rules paragraph, "what the player sees and hears")
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-19, GD-21, GD-54, GD-68, GD-69
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: Input Schemes (Hold, Raise to read), HUD & Diegetic UI (forearm tallies; seen without a lantern), Accessibility Floor (Holds: Press once); `.decision-log.md` UX-2, UX-5, UX-6, UX-11, UX-36, UX-39; `DESIGN.md` (the forearm is ink on skin)
- `_bmad-output/game-architecture.md`: Decision Summary (AD-15, AD-20); Time (AD-33); Order inside a tick (AD-34); Error Handling (designed "no"); Event System (how a rule reports, AD-67); Novel Patterns 1 (parts ledger) and 3 (hands, taps and holds, AD-50); Data Patterns (`sim.ticks`, options copied in, `set_option`); Entity Patterns (`TickBlend`); System Location Mapping (look target, hands and holds, what is drawn at night); Built when (epic 1); AD-56, AD-62, AD-63, AD-67
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-3-the-warden-walks-and-looks.md`: Dev Notes, Review Findings, Completion Notes
- `_bmad-output/implementation-artifacts/deferred-work.md`: DW-27, DW-28, DW-33
- Code as of `6043d4a`: `game/watch/sim/*.gd`; `game/watch/core/input_actions.gd`, `engine_globals.gd`; `game/watch/night/night.gd`, `warden.gd`, `span_view.gd`, `night.tscn`; `game/watch/debug/bot/night_bot.gd`, `show/show_setups.gd`, `trace.gd`; `game/tests/watch/*.gd`; `tools/ci.sh`; `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), gds-dev-story, 2026-11-21.

### Debug Log References

- Baseline before work: `tools/ci.sh` 570 passed, 0 failed, 44 expected.
- The sim tests (`test_hands.gd`, `test_look.gd`) passed on their first run, so each key rule was then undone on its own to see the right test fail: no progress skip on the begin tick (AC 1 and 2 fail: done on T+119), D3 with the feet only (frozen at 15.05), no D3, deck before hand, the town floor `<` for `<=`, a looser move limit, Press once cancelling on any input, the forearm not blocking hands, the checksum without the hands, every bare section walkable (the bot's own arithmetic fails), the recapture click not swallowed. All caught. "No blockers" was not caught at first: the landing test had nothing behind the landing. A case was added where the landing hides section 6's deck end (from along 31.05), and then it was caught.
- Final (first commit): `tools/ci.sh` 799 passed, 0 failed, 46 expected (804 after the follow-up below); show-me setups listed: 5 (was 3); every smoke run warning-free; the traced night's first line unchanged. Ear test still 120 passed, 23 expected.
- Follow-up after the first commit (a self-review): two holes the undo-a-rule pass had not reached. With `side` never set on rail events the suite stayed green (every rail stripped was LEFT, the field's default), and with `HoldRules.MOVE_SLACK` removed it stayed green too (the "exactly 0.5 m" walk happened to sum at or under 0.5). Added: a right-rail test (`HOLD_STARTED`, `HOLD_CANCELLED`, `RAIL_STRIPPED` say RIGHT); the strip bot now takes the town's right rail; a walk that sums 0.50000006 m (10 sideways ticks from along 15.0, found by search) and must keep the hold; the fields-against-comments test also runs over the strip bot's night, so it sees every kind. Both undos now fail. Nits: `InputActions.action_of()` returns `&""` for a value outside the enum (was a silent `watch_forearm`, now tested), `##` lines on the remaining `HandsView` constants, `warden_rules.gd`'s header names D3. `tools/ci.sh` 804 passed, 0 failed, 46 expected.
- The strip bot path is 3739 ticks on both nights (3139 scripted, 600 wander): one path was enough, no split.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-21).
- **Decision taken with Sonlm during development (2026-11-21): a re-lay reads the hand before the deck.** The story's "settled" order (`DECK_FULL` before `NO_PLANK_IN_HAND`) made `NO_PLANK_IN_HAND` impossible: with nothing lost, every plank is on a deck or in hand, so an empty hand means every deck is full. AC 4 and the bot's coverage both need it. Sonlm chose "hand first" (recommended): an empty hand is `NO_PLANK_IN_HAND` even at a full deck; a plank in hand at a full deck is `DECK_FULL`. This reverses the Dev Notes line "a full deck is `DECK_FULL` before an empty hand is `NO_PLANK_IN_HAND`". `project-context.md` says so.
- **Sim (T2 to T5).** `SpanConstants` strip and re-lay times and the town floor; `HandConstants` (reach 2 m, hold move limit 0.5 m); `NightTicks` is now an object (`strip_plank` 120, `strip_rail` 180, `relay_plank` 180), built once as `sim.ticks`; `SpanGeometry.rail_grab_box()` (D1). `NightTypes` gains `Reason`, `HandAction`, `Option`, `Holds`; `NightEvent` six kinds with their "Fields:" lists, and `reason` is typed; `NightCommand.set_option()`. `LookTarget` and `HandsState` are values. `LookRules.target()` tests the 2 m view line against every deck, every standing rail's grab box, and the landing and far pier as blockers; the nearest wins. `HandRules.action_for()`/`check()` are pure. `HoldRules.take()` (step 1, per command) and `tick()` (step 2: still possible, then progress, then completion) own every hold; parts move only through `SpanRules.move_parts()`. `NightSim.refuse(reason, target, action)` emits `REFUSED`; `checksum()` adds the hands and the Holds option. D3 is in `WardenRules.walk()`: when the feet cannot be stood on, `held_by_bare()` adds every bare section under the feet or a clearance probe.
- **View (T6).** `InputActions.NIGHT_INPUTS` and `action_of()`. `night.gd` sends press and release for every night button once `setup()` has run, and marks nothing handled; the warden's node sees input first, so the recapture click never becomes a command (tested: no `HAMMER` press or release at all). `HandsView` (`watch/night/hands.gd`) is a child of the camera: a light skin plate with ink tallies, planks behind a bar on the upper row(s), ropes behind a ring below (D2); `strokes()` and `rows_for()` are pure; it shows while `sim.hands.forearm_raised` and rebuilds only when the counts in hand change.
- **Bot and shows (T7).** `NightBot.strip` (in `paths()`), on a full span with an empty hand, every section number taken from the def. `test_bot_nights.gd`: D3 in its own arithmetic (a section that went bare with the warden in its band holds them until they leave the band; reset per run), every `Reason` but `NONE` produced, and `_test_strip_reaches_its_cases` checks 19 cases from events and state on both nights and three seeds. Shows `strip` and `forearm`.
- **Trace (T8, DW-28).** Who is `warden` plus the action; where carries ` L`/` R` for a rail action; a refusal ends with its reason. `NIGHT_STARTED` is unchanged.
- **Docs (T10).** `WATCH.md` (hand keys, holds, the two shows, the trace example); `project-context.md` (look, hands, holds, refusals, the forearm, D3); `deferred-work.md`: DW-27 and DW-28 closed; a note on DW-33; **DW-34** (new, owner story 1.5): the known gap below; **DW-35** (new, owner story 1.6): D3 and a neighbouring section that was already bare.
- **Known gap (AC 5, as the story asked): the "impossible" cancel branch of `HoldRules.tick()` cannot be reached through commands and ticks in this story.** Nothing can change the span under a running hold, so that branch is covered only by the pure `HandRules.check()` test (`_test_check_on_a_changed_target`), and deleting the branch would fail no test. Recorded as DW-34 for story 1.5. Likewise the side branch of `NightSim.refuse()` (a refused rail action) cannot be reached: a rail is only a target while it stands, so a rope-hand press at one is never refused; noted on DW-34.
- **DW-27.** The view test is driven by strip, rail-strip and re-lay commands from a `StartState`. Its old last check, "the rail is back", is dropped: no rule puts a rope back yet (epic 4), and keeping it would need the direct ledger call DW-27 removes.
- **M1: NOT verified, needs Sonlm** (`--show=strip`). Mouse buttons, Tab, whether the 2 s / 3 s / 3 s holds feel like work and not waiting, counting the strokes after raising the forearm: none of it can be judged from frames. Smoke look only, on a virtual display (Forward+ on llvmpipe, CPU Vulkan, not a real GPU; no input): `/tmp/claude-1000/-home-sonlm-project-3d-game/880dd55f-cb8c-4faa-9dac-b3a8c26986a5/scratchpad/M1/frame00000059.png` shows the full span from mid section 5, forearm down. Nothing wrong seen.
- **M2: NOT verified, needs Sonlm** (`--show=forearm`, Tab held). Smoke look only: `/tmp/claude-1000/-home-sonlm-project-3d-game/880dd55f-cb8c-4faa-9dac-b3a8c26986a5/scratchpad/M2/frame00000059.png` (forearm down, no Tab). A scratch-only render with the forearm forced up (a one-line local change to `hands.gd`, reverted before commit; checked with `git diff`): `/tmp/claude-1000/-home-sonlm-project-3d-game/880dd55f-cb8c-4faa-9dac-b3a8c26986a5/scratchpad/M2-forced/frame00000059.png`. It shows a bar then two crossed fives and 2 strokes, and a ring then 3 strokes; the ink reads over the skin, and the forearm draws over the right-hand post behind it. Same renderer note. Whether it is readable, stays drawn over the world as you walk and look, and tells the two kinds apart at a glance is Sonlm's to judge.
- **Restrictive readings; Sonlm may revisit:**
  - `HoldRules.MOVE_SLACK` 0.0001 m: "more than 0.5 m" is tested as more than 0.5001 m, because the feet are summed from float steps and an exact 0.5 m walk lands a rounding error past it. Not a rule number; far below one tick's step (0.058 m).
  - `HandsState` also stores `began_tick` (the Dev Notes list `ticks_left` and `ticks_total`), so the hold gets no progress on the tick it began. A cancel or completion resets every field.
  - `HandsState.holding()`, `LookTarget.values()`/`copy()`, `HandsState.values()`, `HandRules.ticks_of()` and `id_of()` are small helpers the Dev Notes do not name.
  - A refusal with `NO_ACTION_HERE` leaves section 0 and an empty id even when something was looked at (the rope hand at a deck): the reason says there is no action, so there is no action or target to name.
  - A bad `set_option` (an option or value outside its enum) is reported when the tick takes it (step 1), not when `command()` queues it. Three bad ones in one tick count 3 and log once.
  - The mode in force when a command is taken decides what it does: a release in Hold mode cancels a hold even if Press once was on when it began; Tab's release in Hold mode lowers the forearm whatever raised it.
  - The trace's refusal line ends with the reason's name (the Dev Notes example has it; the "who/where" rule alone would not).
  - `HandsView` materials are in the transparent pass (alpha 1.0), so `render_priority` puts the forearm after the world and the ink after the skin. The skin is sized for three rows (48 planks need two, ropes one), so with few parts its lower part is bare. The stroke across a group is scaled 1.3 to reach over the four. Every size is a named gray-box constant.
  - The night's input test reads the night node's `_sim` (reading only) to see which commands it took.
  - The strip bot's wander taps a random night button every 30 ticks and releases every button on the next tick, so no hold completes in the wander and the script's span stands (no neighbouring bare sections; see DW-35).
- **Code review (2026-11-21, gds-code-review; Blind Hunter, Edge Case Hunter, Acceptance Auditor):** no high-severity finding, no acceptance criterion violated. 2 decisions, 10 patches, 1 deferred (DW-36), 9 dismissed; all decisions and patches applied (see "Review Findings" under Tasks). `tools/ci.sh`: 846 passed, 0 failed, 48 expected (was 804 and 46); 5 show-me setups; every smoke run warning-free. Each fix was undone on its own to see a test fail: 18 undone, 18 caught.
  - **Two rule changes decided by Sonlm in the review.** Press once: for 0.25 s (15 ticks, `HandConstants.PRESS_ONCE_GRACE_S`) after a hold completes, a press of that hold's button is ignored, so a press meant to stop it that lands late cannot start a second, unattended hold. A change of the Holds option cancels the running hold, lowers the forearm and ends the grace, so a mode always starts from idle hands; this reverses "switching mode mid-hold leaves the running hold as it is". `HandsState` gains `done_input` and `done_tick` (in the checksum).
  - **Bot.** `NightBot.strip` takes its hold lengths from `sim.ticks`; `strip_script()` is its script without the wander, and `_test_strip_reaches_its_cases` runs that, telling what cancelled a hold from the commands of that tick. New faults `bot.bad_def` (strip on fewer than 4 sections) and `bot.walk_lost` (a walk that cannot arrive), both tested.
  - **Tests.** Raising and lowering the forearm are now seen to emit nothing; a press and a release in one tick; the forearm toggled up blocking the hands in Press once; the far pier as a blocker (an eye placed by hand: no warden can stand where it hides a target); the strip night in the fields test is checked for faults; the consumer order is asserted; five checks that could not fail are fixed or dropped.
  - **Ledger.** DW-36 (a release that never arrives; owner epic 5, with DW-33), DW-37 (the unreached side branch of `refuse()`, split from DW-34; owner epic 3), DW-38 (the view check of a rail coming back; owner epic 4), DW-39 (the mode-change rule meets "pause does not cancel a hold"; owner epic 5).
- **M1, the part that is on screen: verified on a virtual display** (`--show=strip`; Forward+ on llvmpipe, CPU Vulkan, not a real GPU). A scratch driver outside the project fed real input events (mouse move, left and right button, E, A, Tab) through `Input.parse_input_event`: three planks stripped, one re-laid, the left rail of section 5 stripped. The trace shows each hold at its length (`HOLD_STARTED` 0.467, `PLANK_STRIPPED` 2.467; re-lay 6.967 to 9.967; rail 11.800 to 14.800) and parts moving only at the end. Frames: `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M1/frame00000170.png` (two planks gone, the gaps black), `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M1/frame00000205.png` (the third gone), `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M1/frame00000300.png` (one re-laid: the nearest plank is back), `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M1/frame00000475.png` (forearm up: a bar and 2 strokes, a ring and 1 stroke; the near left rope gone). **NOT verified, needs Sonlm:** whether 2 s / 3 s / 3 s feel like work and not waiting, the real mouse buttons and Tab under the hand, and whether the rail's 0.3 m grab box (D1) is easy to aim at.
- **M2, the part that is on screen: verified on a virtual display** (`--show=forearm`, Tab held by the same driver; same renderer note). `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M2/frame00000015.png`: a bar, two crossed fives and 2 strokes; a ring and 3 strokes; dark ink on a light plate, read at a glance, the two rows told apart by their signs. `/tmp/claude-1000/-home-sonlm-project-3d-game/af312843-3eab-4b39-8578-1dd76ebb01e3/scratchpad/M2/frame00000065.png`: after walking and turning with Tab held, the forearm is still drawn over the deck and rails, nothing cuts it. It reads as a flat card more than an arm (gray box; the arm is epic 4/7). **NOT verified, needs Sonlm:** how it reads on a real GPU and screen, and holding Tab while walking.
- **Sonlm ran M1 and M2 on the laptop, 2026-11-21** (from the Godot editor on their own clone, with a real mouse and keys; the branch head was `3ffb318`, and Sonlm did not say which commit or machine details): "Ok it all work". Stripping a plank and a rail, the re-lay and the forearm all worked with the real buttons and Tab. Sonlm made no separate remark on how the forearm reads. Two findings on feel, each decided by Sonlm the same day:
  - **The holds felt too slow** ("shouldnt it be faster or even instant"). M1's "feel like work, not waiting" is therefore **not accepted yet**. Decision: the 2 s / 3 s / 3 s stay (GD-19's starting values; the time is the cost), and are judged again when a hold has its own feedback and the night has threats. DW-40, owner epic 5.
  - **Nothing tells the player what the hands target** ("i have to aim because i can't know if i am targetting it or not"). This is decision D4 of this story felt in play: the hands' ready pose (UX-5) is epic 4. Decision: a temporary aim aid in the debug tools now (a centre dot that lights when the hands can act, and shows a hold's progress), removed when epic 4's hands arrive. Built as its own change after this story; DW-41.
  - At first Sonlm saw only walking: a press aimed ahead along the span reaches nothing (the deck is in reach only within about 1.2 m of the feet), and a hold shows nothing while it runs. The aim aid answers both.
- Agent time, code review: 2026-11-21 16:40 +0700 to 2026-11-21 17:30 +0700 (0 h 50 min). The start is the time stamp of the review's first scratch file (the diff), not a clock reading taken at the start; the end was read from the clock.
- Agent time: 2026-11-21 15:42 +0700 to 2026-11-21 16:33 +0700 (0 h 51 min), measured by the agent (16:21 at the first commit; the rest is the follow-up).
- Sonlm's own hours: (for Sonlm to fill in)

### File List

- game/watch/sim/hand_constants.gd (new) + .uid
- game/watch/sim/hand_rules.gd (new) + .uid
- game/watch/sim/hands_state.gd (new) + .uid
- game/watch/sim/hold_rules.gd (new) + .uid
- game/watch/sim/look_rules.gd (new) + .uid
- game/watch/sim/look_target.gd (new) + .uid
- game/watch/sim/night_command.gd
- game/watch/sim/night_event.gd
- game/watch/sim/night_sim.gd
- game/watch/sim/night_ticks.gd
- game/watch/sim/night_types.gd
- game/watch/sim/span_constants.gd
- game/watch/sim/span_geometry.gd
- game/watch/sim/warden_rules.gd
- game/watch/core/input_actions.gd
- game/watch/night/hands.gd (new) + .uid
- game/watch/night/night.gd
- game/watch/debug/bot/night_bot.gd
- game/watch/debug/show/show_setups.gd
- game/watch/debug/trace.gd
- game/tests/watch/test_hands.gd (new) + .uid
- game/tests/watch/test_hands_view.gd (new) + .uid
- game/tests/watch/test_look.gd (new) + .uid
- game/tests/watch/test_bot_nights.gd
- game/tests/watch/test_input_actions.gd
- game/tests/watch/test_night_sim.gd
- game/tests/watch/test_show_setups.gd
- game/tests/watch/test_span_view.gd
- game/tests/watch/test_trace.gd
- game/tests/watch/test_warden_node.gd
- game/WATCH.md
- _bmad-output/project-context.md
- _bmad-output/implementation-artifacts/deferred-work.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-11-21: Story 1.4 implemented (gds-dev-story). The hands in the sim (look target, hand rules, holds, refusals, Press once, the forearm as state), D3, `HandsView`, the strip bot path, the `strip` and `forearm` shows, the trace's who and side. DW-27 and DW-28 closed; DW-34 and DW-35 opened. A re-lay now reads the hand before the deck (Sonlm, 2026-11-21). Status: review.
- 2026-11-21: Follow-up: tests for a rail event's side (right rail), for `MOVE_SLACK` (a walk summed past 0.5 m), and the event-fields check over every kind; the strip bot takes the town's right rail; `action_of()` has no silent fallback; doc comments.
- 2026-11-21: Code review (gds-code-review): 2 decisions, 10 patches, 1 deferred, 9 dismissed; all applied. Press once ignores a hold's own button for 0.25 s after it completes; a change of the Holds option cancels the hold and lowers the forearm (both Sonlm). The strip bot reads its hold lengths from `sim.ticks` and faults on a short def or a lost walk; vacuous checks fixed; DW-36, DW-37, DW-38 opened. The on-screen parts of M1 and M2 judged from driven renders. Status stays review until Sonlm's feel checks, as in story 1.3.
- 2026-11-21: Sonlm ran M1 and M2 in the Godot editor: everything works. The holds felt too slow (kept; DW-40, judged again in epic 5) and nothing shows what the hands target (a temporary aim aid follows as its own change; DW-41). Status done.
