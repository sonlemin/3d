---
title: The Mourning Watch - Development Epics
scope: the one-night game
created: 2026-11-19
updated: 2026-11-28
status: draft 0.9 (epic 2's stories written in full with acceptance criteria, 2026-11-28; epic 1's in draft 0.8)
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - gdd.md (draft 0.7)
  - decision-log.md
  - ../../../game-architecture.md (AD-1 to AD-70)
  - ../../ux-designs/ux-3d_game-2026-11-19/DESIGN.md
  - ../../ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md
  - ../../ux-designs/ux-3d_game-2026-11-19/.decision-log.md (UX-1 to UX-66)
  - ../../implementation-readiness-report-2026-11-20.md (FR1 to FR115, NFR1 to NFR25)
  - ../../../implementation-artifacts/deferred-work.md
  - ../../../implementation-artifacts/epic-1-retro-2026-11-27.md
  - ../../../implementation-artifacts/ear-test-outcome.md
  - ../../../implementation-artifacts/spec-ear-test-prototype.md
  - ../../../project-context.md
---

# The Mourning Watch - Development Epics

Eight epics for the one-night game (GD-36). Each ends in something playable. `gdd.md` holds the design; this file holds the breakdown. Screens and the night's surfaces are specified in `../../ux-designs/ux-3d_game-2026-11-19/` (UX-n IDs point to its decision log). The Fog Season is planned only after gate 2.

Sizes are rough guesses at 5 to 10 hours a week. The ear test ran from 12 to 19 November 2026 against a guess of about 2 months, but its hours were not recorded. Since the epic 1 retrospective (2026-11-27) Sonlm gives one rough number of hours per epic at its retrospective; epic 1's was not given. The re-guess of epics 2 to 5 waits for those numbers (DW-18).

## Sequence

| # | Epic | Depends on | Rough size |
|---|---|---|---|
| 1 | The span | Nothing | 40 to 65 h |
| 2 | The ear | 1 (its setup and span stories; architecture AD-66) | 55 to 75 h |
| 3 | The dead | 1, 2 | 40 to 60 h |
| 4 | Rigs and hands | 1, 2, 3 | 45 to 70 h |
| 5 | The night | 1 to 4 | 65 to 90 h |
| 6 | Gate 2 | 5 | 20 to 40 h |
| 7 | The look | 6 passed | 40 to 80 h |
| 8 | Going public | 7 | 30 to 45 h |

Total: about 335 to 525 hours. The UX decisions added about 35 to 50 of them (GD-50) and the architecture's setup story about 10 to 15 (GD-63). Gate 2 is reached after about 265 to 400 hours.

How each epic is built is in `../../../game-architecture.md`; its "Built when" table says which parts of the architecture each epic brings in.

**Story detail.** Epic 1's and epic 2's stories are written in full, with acceptance criteria, under "Epic 1: story detail" and "Epic 2: story detail". Epics 3 to 8 have one line per story with the GDD section and decisions it delivers; each epic's stories are written in full before that epic starts. IN-n IDs are the inputs at the top of the GDD's `decision-log.md`.

Epics 1 and 2 carry the two biggest risks (the bridge as a system; play by ear with several cries and a walking player) and come first: epic 1, then epic 2, because the lesson and the listening round run on the simulation that epic 1 builds (architecture AD-66). Epic 2 ends with the early listen: the first time anyone but Sonlm hears the game. Epics 7 and 8 start only when gate 2 passes.

## What the ear-test prototype already provides

| Piece | Used in |
|---|---|
| The cry rules: one kind per level, the rear shadow, the three room sounds | Epic 2 |
| The loudness tool that measures every clip and writes the matching table | Epics 2 and 8 |
| The tool that cuts and evens out source recordings, and the credits file | Epic 2 |
| The first-person look, the per-trial session log and its scoring | Epics 1, 2 and 6 |
| The local checks that run before every commit | Epic 1 onward |
| Windows and Linux export settings | Epic 8 |

---

## Epic 1: The span

**Goal.** The bridge works as a system: it can be taken apart, it carries weight, and it falls.

**In**

- Setting up: the game starts beside the ear test, which keeps working unchanged; the checks that run before every commit cover both; a way to start the game in a chosen situation, for Sonlm's checks by eye and ear (architecture AD-54, AD-56).
- 6 sections of 8 planks and 2 rail ropes each; the two piers; the town pier landing.
- The warden walks at 3.5 m/s and looks around.
- Strip a plank (2 s), strip a rail rope (3 s), re-lay a plank (3 s). Parts are carried; the forearm shows the tallies while Tab is held, and the warden can still walk and look.
- Strength = planks left, as a count. A section is drawn with that many planks, which leave in a fixed order that keeps the rest evenly spaced; it can be walked over its whole length while it has any. Load from test weights.
- A section creaks at its limit, groans for 2 s above it, then falls for good with what is on it.
- An open section (no planks) cannot be stood on; the warden edges round it in 4 s; its side beams carry a load of 2.
- Section 6 cannot be stripped below 4 planks.
- A fallen section is a gap the warden crosses hand over hand in 8 s. A warden on a falling section catches the edge and climbs back in 5 s.
- The hold rules: a hold is cancelled by moving 0.5 m, by letting go, or when its action becomes impossible; looking is free; one action at a time; parts are counted when the hold completes. (A wound cancels a hold from epic 4; a pause freezes one from epic 5.) The Press once rule is built with them (architecture, Built when); its setting is switched on in epic 8.
- Every key in one table, bound by physical position, with the menu keys (architecture AD-20, AD-70).
- An overhead read-out of every section's planks, rails and strength, in the game's typeface at the canvas size of architecture AD-69.

**Out.** The dead, rigs, lanterns, cries.

**Playable at the end.** Walk the span, strip it, pile test weights on a weakened section and watch it fall.

**Stories**

1. Setup: the game runs beside the unchanged ear test, with its checks and a way to start in a chosen situation.
2. The span exists as 6 sections with countable planks and rails, drawn to the count.
3. The warden walks and looks in first person.
4. The warden strips and re-lays, carries what is stripped, and reads the tallies on the forearm.
5. Sections have strength, take load, creak, groan and collapse.
6. Open sections and gaps: what the warden can cross, and how long it takes.
7. The overhead read-out shows planks, rails and strength per section.

Each is written in full under "Epic 1: story detail" below.

**Delivers.** GDD Game Mechanics 2 and 3. Decisions GD-19, GD-21 (planks, rope), GD-63; UX-8, UX-11, UX-39 (the Press once rule). Architecture AD-69, AD-70.

### Epic 1: story detail

Written on 2026-11-20 after the readiness check. Times are also given in ticks (60 a second; architecture AD-33). Every story follows the architecture's build order (AD-46): the failing test first, with the GDD's number written out; then constants, state, rule and events; then the view; then a bot path that reaches the story's situation (AD-63), a show-me setup for each manual check (AD-56), and the list of manual checks for Sonlm. A story is done when `tools/ci.sh` passes and Sonlm has run its show-me setups. Those closing steps are not repeated in each story's criteria.

Sound is epic 2 onward. In epic 1 a creak, a groan and a fall are events in the trace and things seen; nothing is heard yet.

#### Story 1.1: The game starts beside the ear test

As Sonlm,
I want the game to start from the same project as the closed ear test, with its own checks,
So that every later story lands on a base that is tested on every commit and the ear test still works exactly as it did.

Delivers: architecture AD-10, AD-12, AD-20, AD-27, AD-28, AD-29, AD-36, AD-39, AD-43, AD-54, AD-59, AD-61, AD-70; GD-63.

**Acceptance Criteria:**

**Given** a clean clone with Godot 4.7.2
**When** `godot --path game` is run
**Then** the game's main scene `res://watch/main.tscn` opens on a bare start page
**And** the page lists every setup problem found at start, or says there are none.

**Given** the ear test
**When** `godot --path game res://scenes/ear_test.tscn` is run
**Then** it behaves as it did before this story
**And** nothing under `game/scripts/`, `game/scenes/`, `game/audio/cries/`, `game/default_bus_layout.tres` or `game/tools/measure_loudness.gd` has changed.

**Given** the ear test's two export presets, still named `Linux` and `Windows`, with their include filter kept and the feature `eartest` added
**When** `tools/ci.sh --export` builds them and starts the ear test build once
**Then** that build opens the ear test and not the game
**And** it writes to the same user folder as before (`use_custom_user_dir` with an `.eartest` override).

**Given** `project.godot`
**When** this story is done
**Then** the only changed lines are the main scene, the name, their `.eartest` overrides, the pinned user folder and `physics/common/physics_ticks_per_second=60`
**And** the viewport size, stretch mode and aspect are untouched (AD-69).

**Given** the test suite
**When** `tests/run_tests.gd` runs
**Then** it finds every test file and every `_test_` function itself
**And** the ear test's file, moved to `tests/ear_test/test_ear_test.gd` and extending `TestCase` with its test bodies unchanged, reports 120 passed with 23 expected errors.

**Given** `tools/ci.sh`
**When** it runs
**Then** it fails if a code line under `watch/sim/` names a node, `Input.`, `AudioServer`, `FileAccess`, `Time.`, `await`, `print(` or a global random call, as architecture boundary 1 lists them
**And** it fails if `print(` appears in a runtime folder outside `watch/debug/`
**And** it runs two smoke runs of 120 frames, the game's main scene and the ear test's scene, and fails on any ERROR or WARNING line.

**Given** the launch switches
**When** the game starts with `--seed=N` or `--start=<value>`
**Then** one table in `LaunchOptions` parses them once into a value that is passed down
**And** a CI test starts the game for 120 frames with each `--start` value that exists so far.

**Given** `InputActions`
**When** the game starts
**Then** every action of the GDD's Controls tables (night and planning) and the menu keys of AD-70 is registered in code from one table of physical keycodes, named `watch_` plus lower snake
**And** a test checks that each has a physical keycode and that no `watch_` action is defined in `project.godot`
**And** the printed name of a key comes from `DisplayServer.keyboard_get_label_from_physical`.

**Given** the core scripts
**When** this story is done
**Then** `WatchSession`, `WatchFaults`, `LaunchOptions`, `InputActions` and a first `EngineGlobals` (mouse mode, tree pause) exist under `watch/core/`, with no autoload
**And** `game/WATCH.md` says how to run the game and the ear test and what each switch does
**And** the three "until that story" notes are removed from `project-context.md`.

**Manual check for Sonlm:** start the game and see the start page; start the ear test from source and run one trial; run the exported ear test build once.

#### Story 1.2: The span exists and is drawn to the count

As the warden,
I want to see the bridge as six sections with their planks and rail ropes,
So that the strength of every section can be read by eye.

Delivers: GDD Game Mechanics 2 (the span's size and counts; planks as a count). GD-19, GD-54; UX-8. Architecture AD-1 to AD-4, AD-9, AD-33 to AD-35, AD-42, AD-47, AD-62.

**Acceptance Criteria:**

**Given** the one-night `NightDef`
**When** a `NightSim` is built from it
**Then** the span has 6 sections, each 5 m long and 5 m wide, 30 m in all, with 8 planks and 2 rail ropes each: 48 planks and 12 ropes
**And** the warden holds none.

**Given** `godot --path game -- --start=night --seed=1`
**When** the night scene is built
**Then** the six sections, the far pier, the town pier and its landing are drawn as gray boxes, placed only by asking `SpanGeometry`
**And** no coordinate of the span is typed into a `.tscn` (AD-62)
**And** this start is the third smoke run in `tools/ci.sh`.

**Given** a `StartState` with section 3 at 5 planks
**When** the scene is drawn
**Then** section 3 shows exactly 5 planks, evenly spaced, in the places `SpanGeometry` gives for a count of 5
**And** a headless test finds each plank's placed position equal to `SpanGeometry`'s.

**Given** any section
**When** its count goes from 8 down to 0 one plank at a time
**Then** the planks leave in the one fixed order of `SpanGeometry` (GD-54), the same wherever the warden stands.

**Given** a `NightDef` with 4 sections
**When** a night is built and drawn from it
**Then** it works with no change to any script (no literal 6 or 30; AD-42).

**Given** `NightSim.advance()`
**When** it is called
**Then** it moves exactly one tick, runs the numbered steps of AD-34 in order (steps with no rule yet are empty), and returns typed `NightEvent`s
**And** the same seed and the same inputs give the same list of events twice.

**Given** the debug switches
**When** the game runs with `--trace`
**Then** each event prints as one line: time, kind, who, where
**And** `--show=list` lists the show-me setups, which so far is `--show=span_counts`.

**Manual check for Sonlm** (`--show=span_counts`): sections at 8, 5, 4, 1 and 0 planks can be told apart at a glance from the landing end.

#### Story 1.3: The warden walks and looks

As the warden,
I want to walk the deck and look around in first person,
So that I can go to any part of the bridge.

Delivers: GDD Controls and Input (W A S D, mouse). GD-22. Architecture AD-13, AD-44, AD-52, AD-67. Comfort limits of `EXPERIENCE.md`, Accessibility Floor.

**Acceptance Criteria:**

**Given** a night has started
**When** nothing has been pressed
**Then** the warden stands on the town pier landing, facing the far pier.

**Given** the warden on a section with planks
**When** forward is held for 60 ticks
**Then** the warden has moved 3.5 m (GDD: 3.5 m/s)
**And** there is no sprint and no jump.

**Given** W, A, S and D
**When** they are pressed on any keyboard layout
**Then** they act by physical position (AD-20).

**Given** the mouse
**When** it moves
**Then** the view turns at once, not on the next tick
**And** the camera has no bob and no roll.

**Given** the edge of what can be walked on (the sections that have planks, and the landing)
**When** the warden walks into a rail side, the far pier or the landing's limits
**Then** the warden stops there
**And** nothing is decided by a physics body, a collider or a ray (AD-52).

**Given** the warden's node
**When** frames are drawn between ticks
**Then** the camera follows the sim's position through a `TickBlend`, with no visible step at 60 FPS or above.

**Given** the bot
**When** it walks whole nights in the sim alone, over many seeds, on the 6-section and the 4-section `NightDef`
**Then** no fault is reported
**And** the warden is never outside what can be walked on.

**Manual check for Sonlm** (`--show=walk`): walk the whole span and back; turning feels immediate; walking speed feels like a walk.

#### Story 1.4: The warden strips, re-lays, carries and reads the forearm

As the warden,
I want to take planks and rail ropes off the bridge, put planks back, and see what I carry,
So that the bridge is my supply of parts.

Delivers: GDD Game Mechanics 3 (strip, re-lay, carried parts); Controls and Input (hold rules, Tab, E to re-lay, Press once). GD-19, GD-21; UX-11, UX-36, UX-39. Architecture AD-15, AD-47, AD-50, the parts ledger.

**Acceptance Criteria:**

**Given** the warden looking at a section's deck from within 2 m
**When** the left mouse button is held for 2 s (120 ticks)
**Then** that section has 1 plank fewer and the warden holds 1 plank more
**And** the count changes when the hold completes, not when it starts.

**Given** the warden looking at a standing rail rope from within 2 m
**When** the right mouse button is held for 3 s (180 ticks)
**Then** that rail is gone and the warden holds 1 rope more.

**Given** a section that is not fallen and has fewer than 8 planks, looked at from within 2 m, with a plank in hand
**When** E is held for 3 s (180 ticks)
**Then** that section has 1 plank more and the warden holds 1 fewer.

**Given** a re-lay with no plank in hand, a re-lay on a section with 8 planks, or a strip of section 6 at 4 planks
**When** the input is pressed
**Then** the sim emits a `REFUSED` event with its reason and nothing changes
**And** section 6's rail ropes can still be stripped.

**Given** a hold in progress
**When** the button is let go, or the warden moves more than 0.5 m from where it began, or the action can no longer be started there
**Then** the hold is cancelled, a `HOLD_CANCELLED` event is emitted and no part moves
**And** looking around does not cancel it.

**Given** a hold in progress
**When** another input is pressed
**Then** it is ignored: one action at a time.

**Given** the Holds option set to Press once
**When** an input is pressed once
**Then** the hold starts and runs its full time; a second press stops it; moving 0.5 m still cancels it
**And** Tab becomes a toggle
**And** the option is a rule inside `HoldRules`, tested here; its setting row arrives in epic 8.

**Given** Tab held, with no hold running
**When** the forearm is raised
**Then** it shows the planks and the ropes in hand as tally strokes in fives
**And** the warden can walk and look, and neither hand can act until it is lowered
**And** Tab during a hold is ignored.

**Given** any number of stripped parts
**When** the warden carries them
**Then** there is no limit.

**Given** the last plank of the section the warden stands on (sections 1 to 5)
**When** it is stripped
**Then** the strip completes and the section has no planks; what the warden then stands on is story 1.6, and until then the warden stays in place and can walk off.

**Given** bot nights that walk, strip, re-lay and try refused actions
**When** every tick is checked
**Then** planks over all places still total 48 and ropes 12, and every part moved through `SpanRules.move_parts()`.

**Manual check for Sonlm** (`--show=strip`): strip three planks and a rail, re-lay one, raise the forearm and count the strokes; the hold lengths feel like work, not waiting.

#### Story 1.5: Sections carry weight, creak, groan and fall

As the warden,
I want a weakened section to warn me and then give way under too much weight,
So that the bridge itself can be turned against whatever stands on it.

Delivers: GDD Game Mechanics 2 (strength, load, creak, collapse, what falls with a section); Game Mechanics 4 (overload with no rig). GD-19. Architecture AD-35, AD-48, AD-64.

**Acceptance Criteria:**

**Given** a section
**When** its strength is asked for
**Then** it is the number of planks on it, 0 to 8, worked out each time and never stored (AD-35).

**Given** test weights placed through a `StartState`, each a load of 1
**When** a section's load equals its strength
**Then** the section creaks for as long as that holds (an event when it starts and when it stops).

**Given** a section with 3 planks and 4 test weights
**When** 2 s pass (the overload is seen on tick 1; the section falls on tick 121)
**Then** it groans from the first of those ticks and falls for good on the last
**And** it does not fall a tick earlier.

**Given** a groaning section
**When** its load is back at or under its strength before the 2 s are up
**Then** it holds and the groan stops.

**Given** a section that falls
**When** what follows is settled (`ConsequenceRules`)
**Then** the weights on it fall, and the planks and rail ropes still on it are lost
**And** it is a gap for the rest of the night and cannot be re-laid
**And** planks and ropes still total 48 and 12 with the lost ones counted.

**Given** the warden standing on a section that falls
**When** it falls
**Then** the warden catches the edge and is back on the nearest standing section toward the town, or on the landing, after 5 s (300 ticks), with no input but look until then
**And** the parts in hand are kept. (The wound that goes with it is epic 4.)

**Given** a section with 4 planks and 3 test weights
**When** the warden strips 2 planks from it
**Then** it creaks after the first and groans and falls after the second: an overload with no rig.

**Given** section 6
**When** it is overloaded
**Then** it falls like any other. (That this loses the night is epic 3.)

**Given** the warden
**When** the warden stands on a section
**Then** the warden adds no load.

**Manual check for Sonlm** (`--show=overload`): from the next section, strip a loaded section until it falls; the two seconds between "too much" and the fall can be seen coming.

#### Story 1.6: Open sections and gaps

As the warden,
I want to get past a section with no planks and past a fallen one, slowly,
So that a broken bridge costs me time and does not trap me.

Delivers: GDD Game Mechanics 2 (open sections, side beams, fallen sections); Game Mechanics 3 (re-lay). GD-19, GD-68, GD-69. Architecture AD-48, AD-52.

**Acceptance Criteria:**

**Given** a section with no planks that has not fallen
**When** the warden walks into it
**Then** the warden cannot stand on it and edges along its side beam to the far edge in 4 s (240 ticks)
**And** there is no input but look until the crossing ends.

**Given** the warden on a section when its last plank is taken
**When** the plank goes
**Then** the warden is on the side beam from that moment and finishes the crossing toward the town from where they stand, in the share of 4 s that the distance left is of 5 m.

**Given** an open section
**When** more than a load of 2 is on its side beams for 2 s (120 ticks)
**Then** the section falls
**And** a load of exactly 2 never brings it down.

**Given** an open section, looked at from the next section within 2 m, with a plank in hand
**When** a plank is re-laid on it
**Then** it has 1 plank and can be walked over its whole length again.

**Given** a fallen section
**When** the warden walks into the gap from either side
**Then** the warden crosses hand over hand in 8 s (480 ticks) with no input but look
**And** two fallen sections side by side take 8 s each.

**Given** a hold in progress
**When** a crossing, an edging or a climb begins
**Then** the hold is cancelled
**And** parts in hand are kept through all three.

**Given** bot nights that strip sections bare and drop them
**When** every tick is checked
**Then** the warden is always on a section with planks, on the landing, or in a timed crossing, and no fault is reported.

**Manual check for Sonlm** (`--show=gaps`): edge round an open section and cross a gap in both directions; the difference between 4 s and 8 s is felt.

Two rules here were chosen by Sonlm on 2026-11-20, where the GDD did not say: the warden finishes such a crossing toward the town (GD-68), and a section with no planks can be re-laid (GD-69).

#### Story 1.7: The overhead read-out

As Sonlm planning a night,
I want to see every section's planks, rails and strength from above,
So that the state of the whole bridge can be read at once.

Delivers: GDD Game Mechanics 10 (what the view shows), first version. GD-11; UX-8. `DESIGN.md` span-section. Architecture AD-23 (one span view), AD-69.

**Acceptance Criteria:**

**Given** `--start=planning`
**When** the screen opens
**Then** the whole span is seen from above, far pier at the left and town at the right, with each section drawn with its planks to the count and gaps in `abyss` black
**And** a standing rail is a solid line and a stripped rail a thin dashed one
**And** it is the same span view that the night uses, placed from `SpanGeometry`.

**Given** each section
**When** it is drawn
**Then** its number is shown above it and its strength below it as a number
**And** a fallen section is a dashed outline with no number.

**Given** the typeface
**When** the read-out draws text
**Then** it is Cormorant Garamond, bundled under `game/fonts/` with its licence, through a first `watch_theme` that holds the `number` and `label` styles and the colours this screen uses
**And** every size is two thirds of its `DESIGN.md` token (32 px and 19 px on the 1280×720 canvas), checked by a test (AD-69).

**Given** the read-out
**When** it is clicked
**Then** nothing changes: it is read-only until epic 5
**And** it is flat shapes on `world`, with no woodcut treatment.

**Given** a `StartState` with mixed counts, a stripped rail and a fallen section
**When** `--show=readout` is run
**Then** the read-out shows that state.

**Given** the launch-switch test in CI
**When** it runs
**Then** it also starts the game with `--start=planning` for 120 frames.

**Manual check for Sonlm** (`--show=readout`): at a 1080p window and at 720p the numbers are sharp and readable, and the read-out matches what the same state looks like on foot.


---

## Epic 2: The ear

**Goal.** A player can place a threat by ear while walking, with several cries sounding, helped by the ally and by what the lantern shows.

**In**

- The cries re-cut from the original downloads at full quality, with loudness re-measured.
- The ear test's rules carried into the game: one kind of cry per level, the rear shadow, equal loudness at equal distance, the three room sounds.
- Farther is quieter: 3 dB per section, smoothly, along the span only, up to 15 dB (GD-56).
- Cries that come from places: the rails, the piers, overhead.
- The four warnings, built from whole clips: Grappler, Diver, nest (sobs that quicken), and the tune of the one who keeps coming back.
- Several cries at once: never more than 4, warnings at least 1.5 s apart, ambience at least 6 dB under the quietest a cry can be. A warning that cannot start waits, and its threat with it (GD-57). Cutting and skipping the cries of the dead on the deck is epic 3, where those cries arrive.
- Enough of the dead to warn: each kind's warning sounds from its place and ends; what they do after arriving is epic 3. A test timetable with the bell's toll; the full six waves are epic 5.
- The ally's calls, each with a caption at the bottom centre of the view: every warning 2 s in, or only the warnings the player has not turned toward within 4 s.
- The bridge shows where, inside the carried lantern's light and the town gate's light on section 6 and the landing: shaking rope, falling dust, swirling fog, and the flame leaning toward the nearest cry inside its light. A cue lasts for the whole of its warning.
- The town bell, and a tally chalked at each toll.
- The dusk lesson, listening part: on a dark screen, one bell stroke to check left and right, answered Left, Right or "I can't hear it", with a key to ring again and a setting to swap the sides (the answer "I can't hear it" is recorded here; its offer of Cues everywhere is wired in epic 5, where that setting is built); then three harmless dead, one per level, the first cry within 15 s and serving as the look lesson, with walking prompted once it is faced; each cry repeats until faced, with "listen again" after each playing not faced and the place's cue shown after three; the ally confirms a right turn. The hands-on part of the lesson is built in epic 5, once the hammer and lantern exist.
- The listening round: 12 warnings from unpredictable places, 4 from each level, in the dark with no ally; scored for direction (within 45° in 4 s) and place (within 5 m in 15 s). It comes after the lesson, with no lantern and the pointer cues off; each trial ends 15 s after its warning starts. Its instruction is read aloud from the session script.
- A per-warning log: did the player turn to within 45° within 4 s; in the dark or in the light; did the ally call it.
- **The early listen** (GD-43): two or three newcomers, at least one on headphones and one on speakers, try the listening lesson and the listening round.

**Out.** What the dead do after they arrive; rigs; oil and hung lanterns.

**Needs.** Epic 1's setup and span stories. Sonlm's six stand-in recordings of the ally's lines, before the early listen (the final voice by epic 6, DW-9). The original downloads of the 11 recordings, before story 2.1 closes (DW-11). Two or three newcomers by the end of the epic (DW-10).

**Playable at the end.** The listening lesson and the listening round.

**Stories**

1. The cries are re-cut at full quality and re-measured. (Audio and Music; Asset Requirements; the 1 LU rule. IN-19)
2. The ear test's cry rules work for a walking, turning listener. (Mechanics 1: level, side, behind, room sounds. GD-7; IN-19)
3. Cries come from rails, piers and overhead, and get quieter with distance. (Mechanics 1: distance. GD-40, GD-56)
4. The four warnings play as specified, and the nest's sobs quicken. (Mechanics 1: warnings)
5. The 4-cry limit, the 1.5 s spacing and the ambience level hold. (Mechanics 1: during the night. GD-57)
6. The ally calls the level with a caption: every warning, or only the missed ones. (Mechanics 8. GD-7, GD-26, GD-39; UX-1, UX-26)
7. The bridge shows where, inside the carried lantern's light and the town gate's, and the flame leans. (Mechanics 1: visual cues; Mechanics 6: light. GD-9; UX-29)
8. The town bell tolls from the town side, and the tally is chalked. (Enemy Wave Design: the toll; Mechanics 1: cue table. GD-24)
9. The listening lesson runs from the left/right check to the last cry, with feedback and the look and walk prompts. (Core Gameplay Loop: dusk lesson. GD-8, GD-71, GD-74; UX-20, UX-22, UX-38, UX-46 to UX-49, UX-65)
10. The listening round runs and scores direction and place. (Success Metrics: the ear re-check. GD-30, GD-46, GD-72 to GD-74; IN-20)
11. Every warning is logged: turn, dark or lit, called or not; the playtest builds write the log. (Success Metrics: the night log)
12. The early listen is run and written up. Run by Sonlm. (Success Metrics: the early listen. GD-43, GD-77)

Each is written in full under "Epic 2: story detail" below.

**Delivers.** GDD Game Mechanics 1 and 8; the early listen in Success Metrics. Decisions GD-7, GD-8, GD-9 (the carried lantern, and the town gate's light), GD-24, GD-26, GD-39 (the rule), GD-40, GD-43, GD-56, GD-57 (warnings), GD-71 to GD-77; IN-19, IN-20; UX-1, UX-20, UX-22 (the look and walk prompts), UX-26, UX-29 (the gate's light), UX-38 (the left/right check), UX-42, UX-43 (the caption and the check screen), UX-46 to UX-49, UX-65; UX-47 is built for, and switched on in story 5.8. Architecture A1 to A18 (the "Built when" row for epic 2).

### Epic 2: what the stories must cover

Gathered on 2026-11-28 before epic 2's stories were written (DW-20). FR and NFR numbers are those of the readiness report (`../../implementation-readiness-report-2026-11-20.md`, GDD Analysis), which numbered GDD draft 0.7; where a later decision changed a rule, it is named beside it. Each story below cites the numbers it delivers, and every number here lands in a story.

**From the GDD: what the game does**

| ID | Epic 2's part of it |
|---|---|
| FR2 | The left/right check: one stroke of the town bell on a dark screen, ring again, "I can't hear it"; two wrong answers offer the swap and warn the sound may be single-channel. The answer "I can't hear it" is recorded; its offer of Cues everywhere is wired in story 5.8. With UX-46, UX-48, UX-49, UX-65. |
| FR3 | The lesson's listening part: three harmless dead, one per level, the first cry within 15 s, each repeating until faced within 45°, "listen again" after each playing not faced, the place's cue after three, the ally's confirming word, walking prompted once the first cry is faced. Built so a cue can show from the first playing (UX-47). |
| FR13 | One kind of cry, one kind of place, one cue and one call per level; a kind never sounds at another level. |
| FR14 | The tune's warning as a fourth voice below, at a rail. (Its 3 variations, resolving phrase and hum: story 5.9.) |
| FR15 to FR18 | Side by stereo following the head; the rear shadow; farther is quieter, 0.6 dB per metre along the span only, up to 15 dB (GD-56); the three room sounds as atmosphere. |
| FR19 | The four warnings, built from whole 4.3 s clips, from where the threat will arrive. |
| FR21 to FR23 | Never more than 4 cries; a warning sounds its whole length; two warnings never start within 1.5 s; a warning that cannot start waits and its threat with it (GD-57). Cutting and skipping the cries of the dead on the deck is epic 3. |
| FR26 | Ambience at least 6 dB under the quietest a cry can be; no music. (The silence before the sixth toll: story 5.2.) |
| FR28 | The level cues and a lit flame leaning toward the nearest cry inside its own light, for the whole of the warning; the tune's ropes sway. In the carried lantern's light only. |
| FR30 | One tally chalked on the board at the town pier for each toll. |
| FR31 | Only In the light is played in epic 2, but `CueRules` answers all three modes; the setting is story 5.8. |
| FR56, part | The carried lantern's light, 4 m. |
| FR72 to FR74 | The ally calls by wave, one call at a time, dropped if it cannot start within 4 s of when it was due; the lines epic 2 needs (3 level calls, 3 lesson lines); a caption for every line. |
| FR93 | The toll: one stroke for wave 1 up to six, 1.5 s apart, from the town side; a wave's clock starts at its first stroke. |
| FR109, part | For each warning: turned within 45° at 4 s, heading toward the arrival at 4 s, dark or lit, called or not; the left/right check's answers; the time from the lesson opening to the first cry. |
| FR110 | The listening round: 12 warnings from places that cannot be predicted, 4 per level, in the dark, no ally, no lantern, pointer cues off, each trial ending 15 s after its warning starts; scored for direction (within 45° in 4 s) and place (within 5 m in 15 s). |
| FR111 | Fairness, epic 2's half: a warning always sounds its full length, and one that waits holds its threat back. The arrivals and the bot invariant "no arrival before its full warning" are epic 3 (architecture, Built when). |
| FR112 | The early listen: two or three newcomers, at least one on headphones and one on speakers, try the lesson and the round. Direction under 80% means a rethink before epic 3. |

**From the GDD: how well**

| ID | Epic 2's part of it |
|---|---|
| NFR10 | Any two cries at the same distance within 1 LU, measured through the game's own buses, straight ahead, before the rear shadow. |
| NFR11 | The first cry within 15 s of the lesson opening. |
| NFR14 | Stereo on headphones or speakers. The mono fold-down and the left/right swap are proven by a measurement test (AD-18); the Mono setting is epic 8. |
| NFR16 | No network; the log is a local file. |
| NFR17 | No flash, no shake, nothing flickering faster than 3 times a second: binds the cue effects, the flame and the caption. |
| NFR18 | Captions in every cue mode. (The Caption size setting is story 5.8; epic 2 draws the default size.) |
| NFR21 | Every sound allows commercial use and is credited. Nothing AI-voiced; no AI-made cries. A stand-in is named `placeholder_*`. |
| NFR22 | Cormorant Garamond for the caption, the key prompts and the check screen. |

**From the architecture: what epic 2 builds** (Built when, epic 2)

| # | Piece |
|---|---|
| A1 | The game's own cry clips, `WatchCryLibrary`, the game's bus layout with its slots, `SoundSetup`, and the bus values in `EngineGlobals` (AD-5, AD-39, AD-65) |
| A2 | `measure_watch_loudness`, through the game's own buses (AD-39) |
| A3 | `voice_rules`: slots for warnings, `CRY_STARTED` with its slot (AD-7, AD-32) |
| A4 | `CryMix`, pure: measured gain, distance, rear shadow; the wound's input stays empty until epic 4 (AD-6, AD-17) |
| A5 | `DeadState` with the warning phases only, for all four warnings |
| A6 | `wave_rules` running any `NightDef` timetable, with the toll, the 1.5 s spacing and the waiting (AD-7) |
| A7 | The carried lantern and `light_rules` for its light (AD-16) |
| A8 | The sound-and-cue table and `CueRules`, with the table test (AD-45) |
| A9 | `ally_rules` and the caption |
| A10 | `landing_view` with the tally board |
| A11 | The left/right check screen, outside the sim |
| A12 | `lesson_rules`, `round_rules` and their screens; `--start=lesson` and `--start=round` in the launch-switch test (AD-22, AD-61) |
| A13 | `score_rules` and its `WARNING_SCORED` marks |
| A14 | `PlaytestLog`, written only with the `playtest` feature or `--log` (AD-24, AD-53) |
| A15 | `WatchSettings`, saved with `ConfigFile` (AD-21) |
| A16 | The mono and swap measurement test (AD-18) |
| A17 | `build_info` and the two playtest export presets |
| A18 | The ending events `LESSON_ENDED` and `ROUND_ENDED`, and a first `NightResult` for a lesson and a round (AD-67) |

Every story also follows the build order (AD-46), adds a bot path to its own situation (AD-63) and a show-me setup for each manual check (AD-56).

**From the UX documents**

| ID | Rule |
|---|---|
| UX-1, UX-26 | Every spoken line has its caption, always, saying only what the voice says. |
| UX-20, UX-38 | The left/right check: two-choice, "I can't hear it", ring again (R). |
| UX-22, part | The lesson's look and walk key prompts. (The hands-on prompts: story 5.11.) |
| UX-46 | "A bell rings on one side." above the question. |
| UX-47 | In Cues everywhere each lesson cry shows its cue from the first playing: story 2.9 makes this possible, story 5.8 switches it on. |
| UX-48 | One wrong answer rings again from a random side, with no word; a second wrong answer brings the offers. |
| UX-49, UX-65 | The check opens with nothing chosen; A/D and the arrows answer at once; Down or S then Enter or Space for "I can't hear it"; Up or W clears; the pointer chooses only once it has moved. |
| UX-42, UX-43 | Scale B: caption 48 px at 1080p (32 on the canvas), body 42 (28), heading 60 (40); all text `ink` or brighter. `DESIGN.md`: caption-line, key-prompt, two-choice and note-line, the halo over 3D. |
| EXPERIENCE.md | The raised forearm stays clear of the caption band, checked on a frame (DW-20). |

**From the deferred work and the epic 1 retrospective**

| Item | What it asks of epic 2 |
|---|---|
| DW-20 | Say where the tune comes from, or that a stand-in is allowed until story 5.9 (readiness G3, Q4). Name the mono-and-swap test, the saved settings, `build_info` and the playtest presets (B3). Name the fairness invariant (G7, B4). |
| Retro A3 | Every sound criterion has two checks: one measured by a test, one listening check for Sonlm with its own show-me setup. An agent never reports a sound as heard. |
| DW-26 | The first rule that rolls `sim.rng` brings the test "a roll changes the events". |
| DW-31 | Anything about the span's state read from more than about 10 m away brings its own cue. |
| DW-44, DW-45 | The creak's bow judged once the creak has a sound; sound to explain the slide when the last plank goes. Which story gives the creak its sound is still to settle (see below). |
| DW-51 | `fonts/OFL.txt` in both playtest presets; decide whether the ear test's private builds need it too. |
| DW-9, DW-10, DW-11 | Sonlm's: stand-in ally lines are fine until epic 6; two or three newcomers by the end of the epic; the original downloads before story 2.1. |
| DW-18, DW-59 | Change the "hours are logged from epic 1" line (one rough number per epic since the retrospective). Cite UX-42 to UX-66 in the stories that build them, in epics 4 and 5 as well. |

**Settled by Sonlm on 2026-11-28** (each was the recommended option):

- **The story numbers stay 2.1 to 2.12,** and the architecture's pieces with no story of their own go to the first story that needs them: the mono and swap test to 2.2; the timetable runner, with its spacing and waiting, to 2.5 (moved from 2.2 in the party-mode round, below); the town gate's light (section 6 and the landing) to 2.7, with the carried lantern, so the tally board is lit from epic 2 (story 4.7 keeps the hung lanterns); the toll to 2.8; `WatchSettings` and `--start=lesson` to 2.9; `--start=round` to 2.10; `build_info` and the two playtest presets, with `OFL.txt` and the cries' `loudness.json` in their include filter, to 2.11.
- **Epic 2's other sounds are stand-ins Claude makes** with a script, by synthesis, not by AI: the town bell, the straining rope, the wind bed and the tune's warning phrase. Each is a `placeholder_*` file with its credit line, and story 5.9 replaces them with recordings. Only the 13 cries are real in epic 2.
- **Sonlm records the ally's six stand-in lines** on the laptop from a one-page sheet. A small trim-and-level script prepares them (story 2.6). Until they arrive, each line is a short soft tone with its caption, so no story waits on them.
- **The creak and the groan get their sounds in story 5.9,** as `epics.md` already had it. DW-44 (judging the bow) moves there, and DW-45's "the sound explains the slide" goes to 5.9 and to the hands (4.1).

**Where each item lands**

| Story | Delivers |
|---|---|
| 2.1 | NFR10, NFR21; A1, A2; DW-11 |
| 2.2 | FR13, FR15, FR16, FR18; NFR14; A3 (one slot per warning), A4, A5 (a warning's first cry, set up through the `StartState`), A8 (the table), A16 |
| 2.3 | FR17; FR19 (from where the threat will arrive) |
| 2.4 | FR14, FR19; A5 (all four warnings) |
| 2.5 | FR21 to FR23, FR26, FR111 (epic 2's half); A3 (the limit), A6 (the timetable runner, spacing and waiting) |
| 2.6 | FR72 to FR74; NFR18; A6 (waves), A9; UX-1, UX-26, UX-42, UX-43; the caption band |
| 2.7 | FR28, FR31, FR56 (part); NFR17; A7, A8 (`CueRules`); the gate's light; DW-31 |
| 2.8 | FR30, FR93; A6 (the toll), A10 |
| 2.9 | FR2, FR3; NFR11, NFR22; A11, A12 (the lesson), A15, A18 (the lesson's ending); UX-20, UX-22, UX-38, UX-42, UX-43, UX-46 to UX-49, UX-65 |
| 2.10 | FR110; A12 (the round), A13 (the round's scores), A18 (the round's ending); DW-26 |
| 2.11 | FR109; NFR16; A13, A14, A17 (A17 may become 2.11a); DW-51 |
| 2.12 | FR112; DW-10 |

Retro A3 (two checks for every sound criterion) applies to 2.1 to 2.10. DW-9's recordings feed 2.6 and 2.9.

**Added after an elicitation pass** (pre-mortem, assumption audit, second-order effects, edge cases, epic 1's lessons; applied by Sonlm on 2026-11-28 as a set). Each goes into the story named:

- **2.1** builds the pipeline (library, bus layout, slots, loudness tool) on the 13 clips in hand, copied into the game's folder; the re-cut from the original downloads (DW-11) is its last step and replaces those files, so the epic does not wait on the downloads. The offline tools (the cutting tool, the stand-in script) run through `uv` with numpy, which this server lacks as a system package.
- **2.2** carries the architecture's fallback for the swap (one shared function mirrors every placed sound across the listener's own forward line, used by `CryMix` and `SfxAudio`) in case the measurement test shows `pan_pullout` −1 does not swap cleanly (AD-18).
- **2.4, 2.5, 2.8 and 5.9:** every stand-in is measured like the sound it stands for: the tune's phrase is a cry and has its `loudness.json` entry under the 1 LU rule; the wind is what the ambience rule is measured against. Story 5.9 measures again when it replaces them.
- **2.5:** when several warnings wait, the first due starts first; the 1.5 s gap counts from the last warning that started. Whether a warning still waiting may start in a lull is settled in step 3.
- **2.6:** the test night has at least four waves, so the ally's fade from wave 4 is reached.
- **2.9:** the lesson holds each cry's cue back until its third unfaced playing even where light falls (the gate's light reaches section 6 and the landing from 2.7), and can show it from the first playing for UX-47.
- **2.9 and 2.10:** the lesson and the round use only the places the night's dead can use: the rails and decks of every section but the last, and the two piers (10 rails, 5 decks and 2 piers on the one-night span), asked of the `NightDef`, so a 4-section night works too. Their screens draw no aim aid (DW-41 removes it from the night in 4.1).
- **2.11:** each loss of window focus during a lesson or a round is logged with its trial, so that trial can be dropped from the score (the pause arrives in epic 5). The start page of a playtest build or an editor run has a "New listener" entry that clears the saved settings and the lesson flag, so one laptop can serve several newcomers with no command line.
- **2.12:** the sessions run on Sonlm's laptop, so no other machine is needed (DW-24 stays open); how the game gets there is settled below (from the editor). Sonlm's six recordings are a precondition; the write-up says which sounds were stand-ins and reports only counts and the newcomers' own words. Epic 3's stories may be written meanwhile, but epic 3 starts only when the early listen is scored (GD-43). If Sonlm's voice works, it may become the final one (GD-26), which would close DW-9.
- **Every story:** each measured sound criterion names the value that would make its test fail.
- **Elsewhere:** the one-liners of story 4.7 (hung lanterns only; the gate's light is 2.7's) and 5.9 (replaces and re-measures every stand-in) are reworded; DW-44 and DW-45 get their new owners in `deferred-work.md`.

**Added after a party-mode round** (Samus Shepard, Cloud Dragonborn, Link Freeman, Murat, Indie; chosen by Sonlm on 2026-11-28, each the recommended option):

- **Warnings start through the `StartState` until story 2.5.** The `StartState` can already place one of the dead in a phase (architecture, boundary 2), so 2.2 and 2.4 set up each warning that way, one show-me setup per kind. The timetable runner arrives in 2.5 with the spacing and the waiting, the waves in 2.6, the toll in 2.8. This lightens 2.2, the heaviest story.
- **The re-cut stays the last step of 2.1** (DW-11). Sonlm gets the downloads early, so the listening checks from 2.2 on are made on the real clips; 2.1 stays open until then.
- **Each stand-in has a listening check of its own** (2.4 for the rope and the tune, 2.5 for the wind, 2.8 for the bell): Sonlm judges that it reads as what it stands for, as well as the measured checks. The straining rope ends every below warning, so a rope that sounds like a second cry would blur what the round measures.
- **The round reports its place score per level as well as overall** (2.10). With two piers, an inside trial's place is close to a coin toss; the 70% mark itself is unchanged.

**Rules settled for the lesson and the round** (Sonlm, 2026-11-28, each the recommended option; the GDD did not say):

- **The lesson's playing** (2.9): one 4.3 s clip of that level's kind from its place. The warden starts mid-span facing the town. The three cries come from the far pier (sobs, straight behind; the first playing 5 s in), from under the left rail of section 5 (whispers), and from over section 2 (shrieks). Faced means within 45° at any moment from the playing's start to 1 s after it ends. Faced: the confirming word, and the next cry 3 s after it ends. Not faced: 1.5 s of quiet, "Listen again", and the cry again 1 s after the line ends. After three unfaced playings the place's cue shows, self-lit, until faced.
- **The round's trials** (2.10): the round starts with the warden mid-span facing the far pier, and the warden is never moved. There are 3 s of quiet between trials. Each place is drawn with `sim.rng` from all of its level's places more than 5 m along the span from the warden (strictly, so a neighbouring section's centre at exactly 5 m, which would earn the place mark standing still, is not drawn; tightened after the final validation); if none is, the farthest is taken. The levels are shuffled, 4 each, never three of one in a row. Each trial records whether its place started within 45° of the facing ("ahead"); direction is reported overall and for the other trials apart. *Corrected the same day:* the rule first approved ("more than 45° from the facing and at least 10 m along") leaves no place on a 5 m wide span, because anything 10 m or more ahead is at most 14° off the facing; from mid-span facing the far pier it left no rail or deck, from the landing nothing. The facilitator had not checked it; Sonlm chose again from options. A player who never moves would score about 60% on direction under the new rule, which is why direction must reach 80% both over all trials and over the trials that did not start ahead (GD-77, chosen after the final check: about 7 of 12 trials start ahead, so 80% overall could be reached with only about 60% of the trials that need a turn).
- **The place mark** (2.10): it counts if, before the trial ends, the warden has stood still (no move wish) for 1 s with the feet within 5 m along the span of the arrival point. For a rail or a deck that point is the section's centre; for a pier, the span's end. Raw positions are logged, so a stricter rule can be scored later, and the score is reported per level.
- **Facing, wherever the GDD says "within 45°"** (the lesson, the round, the ally from wave 4, the log): measured flat, by turning only, to the point on the span at or under the source. Within 1.5 m of that point the warden counts as facing it.
- **When facing counts for a warning** (the ally from wave 4, the round's direction mark, the log's "turned"): the warden faces it at the 4 s mark, tick T + 240, as the GDD's ally rule reads ("4 s after it starts"). A cry that starts ahead counts only if the warden keeps facing it, so turning away from a cry in front is caught. (The lesson keeps its own window, below.)
- **The early listen runs from the Godot editor on the laptop,** with `-- --log` in Debug > Customize Run Instances > Main Run Args. No build has to reach the laptop; CI still builds and starts both playtest presets.
- **Epic 2 draws plain versions of three looks** that DW-21 has not chosen yet: the caption's halo is Godot's own solid label outline in `abyss` (2 canvas px), with no soft spread; a chosen word is `warm` with its 2 px warm rule, with no glow; a self-lit cue is an unshaded copy of the cue object. Sonlm judges them on the laptop in 2.6 and 2.9; the soft spread and the glow wait for DW-21.
- **A warning still waiting when the lull begins** (2.5) starts as soon as a slot and the 1.5 s gap allow, lull or not, as the GDD already says for a stranded Diver's dive. The lull rule keeps nothing new from being scheduled there.
- **The two lesson lines Sonlm records** (stand-ins; final wording in story 5.10): "Listen. When one calls, turn to it." and the confirming word "Yes."

### Epic 2: story detail

Written on 2026-11-28 by `gds-create-epics-and-stories` (DW-20). As in epic 1, times are also given in ticks (60 a second; AD-33). Every story follows the build order (AD-46): the failing test first, with the GDD's number written out, then the constants, state, rule and events, then the view and the sound. It adds a bot path that reaches its situation (AD-63), a show-me setup for each manual check (AD-56), and the list of manual checks for Sonlm. A story is done when `tools/ci.sh` passes and Sonlm has run its show-me setups. Each story adds its show-me setups and launch switches to `game/WATCH.md` in the form Sonlm uses, the editor's Debug > Customize Run Instances > Main Run Args (for example `-- --show=cry_turn`), not as shell commands.

Stories 2.2, 2.9 and 2.11 are the largest. If one is too big for one dev session, it is split without renumbering: 2.2's swap measurement tool, 2.9's check screen with the saved settings, or 2.11's `build_info` and playtest presets becomes a story of its own just before the rest (2.2a, 2.9a, 2.11a in `sprint-status.yaml`).

**Sound is checked twice** (epic 1 retrospective, A3). Each sound criterion has a measured test, which names the value that would make it fail, and a listening check for Sonlm with its own show-me setup. An agent never reports a sound as heard, a pan as correct, or a mix as balanced. Its record says what was measured.

**Readings taken while writing these stories,** where the documents were silent. Each is a starting value or a plain reading, and each can be overruled:

- R1. A cry clip is chosen by the cry player, not the sim, with its own generator seeded from the night's seed, never the same clip twice running on a level. Which clip sounds is variety, not a rule; the loudness table keeps them equal.
- R2. The sounds of a warning that are not cries (the straining rope) follow the same 0.6 dB per metre along the span as the cries, so they never contradict the cry's distance.
- R3. "Lit" is measured flat, like facing: a place is lit when the point on the span at or under it is within 4 m of the carried lantern, or on section 6 or the landing (the gate's light). Height does not count.
- R4. The left/right check plays its stroke at the loudness of a near cry straight ahead, not at the ambience level, because it tests the channels.
- R5. Until story 5.8 adds Show cues everywhere, the check's offers are "Swap left and right" and "Go on". Story 5.8 replaces "Go on" with "Show cues everywhere".
- R6. The bell sounds from the town, on the span's centre line 20 m beyond the landing, so it turns with the warden's head like any placed sound. It loses nothing with distance (the distance rule is for warnings, R2): it is the town's bell, heard the same anywhere on the span, at its measured level.
- R7. The heading mark counts when, 4 s into the warning, the warden is walking with the move direction within 45° of the flat bearing to the arrival point. The lit mark counts when the warning's place was lit as it started.
- R8. *A departure, not a reading:* the GDD says the ear re-check covers the tune, but in epic 2 the round's below trials are Grapplers only, because the tune is a stand-in. Whether gate 2's round includes the real tune is decided in epic 6.
- R9. After the lesson the round opens on a dark page with one entry, "Begin the round". The person running the session reads the instruction aloud and then the newcomer chooses it. This is the session script's cue, not an instruction screen.
- R10. A `StartState` can give each warning it places a start tick, so a show-me setup can play warnings one after another before the timetable exists.
- R11. In the default cue mode the ally speaks only the lesson's three lines in the lesson, never a level call: the lesson teaches the level from the kind of cry. In Cues everywhere (from story 5.8) each lesson cry is also called, with its caption, from the first playing, as UX-47 says ("with the ally's caption"); 2.9 builds the switch.
- R12. "A cue lasts for the whole of its warning" is read as: on every tick of the warning that its place is lit. Walking the lantern away hides it; the cue is not held on once seen.

#### Story 2.1: The cries are re-cut at full quality and re-measured

As Sonlm,
I want the game to have its own cry clips, buses and loudness table, measured through the game's own mix,
So that every cry the game plays is equally loud at equal distance, and loudness never gives away the level.

Delivers: GDD Audio and Music; Asset Requirements (cries); Technical Metrics (the 1 LU rule). NFR10, NFR21. IN-19. Architecture A1, A2: AD-5, AD-39, AD-51, AD-65. DW-11.

**Acceptance Criteria:**

**Given** the 13 clips in hand (5 shrieks, 4 sobs, 4 whispers)
**When** this story starts
**Then** they are copied into `game/audio/watch/cries/<level>/` under the naming rule `<freesound id>_<author>_<n>.wav`, with that folder's `CREDITS.md`
**And** nothing under `game/audio/cries/` changes: a test compares every file there with a list of checksums written into the test now, so a later commit that changes one still fails it
**And** every cry clip is 4.3 s, 258 ticks give or take 1 (a test reads each clip's length), because the warnings' ticks in story 2.4 assume it.

**Given** `WatchCryLibrary` (`watch/sound/watch_cry_library.gd`, the game's own copy, AD-65)
**When** the game starts
**Then** it finds every `.wav` under `audio/watch/cries/<level>/` and skips other files
**And** a level with no clip, a clip with no entry in `loudness.json`, or an entry with no clip is a setup problem listed on the start page; the game still starts.

**Given** the game's bus layout `watch/sound/watch_bus_layout.tres`, loaded at start by `SoundSetup` through `EngineGlobals`
**When** it is loaded
**Then** it has `CrySlot1` to `CrySlot4`, `FallSlot1` to `FallSlot3` and `Hum`, each with a high shelf and a low-pass; the level buses `Above`, `Inside` and `Below` carry the ear test's room effects (above mostly above 1000 Hz, inside mostly below 650 Hz, below mostly below 2500 Hz with the long cave echo) and send to `Cries`; `Ambience`, `Ally`, `Bridge`, `Town`, `Hands` and `Screens` send to Master
**And** every slot bus sits to the right of the level buses (a test reads each send and fails if any bus sends to a bus on its right)
**And** the four cry slots are identical, and so are the three falling-cry slots (a test compares their effects and values), so a measurement through one slot holds for all
**And** every effect value comes from a constant in `sound_constants.gd`, written by `EngineGlobals.apply()`, never from the `.tres` (a test changes the file's value and sees the constant win).

**Given** `game/tools/measure_watch_loudness.gd`
**When** it is run with `-- --write`, then with `-- --verify`
**Then** it measures each clip straight ahead at 0 m, before the rear shadow, through a slot and its level bus, and writes each clip's gain to `audio/watch/cries/loudness.json`
**And** `--verify` fails if any two clips measure more than 1 LU apart (a test feeds it a table with one gain 1.1 LU off and expects it to fail)
**And** `tools/ci.sh` runs `--verify`.

**Given** the offline tools in `game/tools/` (the cutting tool, and from story 2.4 the stand-in script)
**When** they are run
**Then** they run through `uv` with numpy, as `game/WATCH.md` says, and need no system package.

**Given** the original downloads of the 11 recordings (DW-11, Sonlm's)
**When** they are in `source_audio/cries/`
**Then** the 13 clips are cut again from them with the cutting tool, replace the copies above under the same names, still pass the length test, and are measured again (`--write`, then `--verify`)
**And** `CREDITS.md` names each original
**And** this criterion is the last of the story. The story stays open until it is met; the others can be built and reviewed before it.

**Manual check for Sonlm** (`--show=cry_gallery`): every clip plays in turn from straight ahead at 0 m. They sound equally loud. Each sounds like its kind (whisper, shriek, sob). After the re-cut, the clips sound cleaner than before, not duller.

#### Story 2.2: The ear test's cry rules work for a walking, turning listener

As the warden,
I want a cry to come from its place, turning with my head, duller behind me, in its level's room,
So that I can tell its side and its level by ear while I walk and look around.

Delivers: GDD Game Mechanics 1 (level, side, behind, room sounds). FR13, FR15, FR16, FR18; NFR14. GD-7, IN-19. Architecture A3 (one slot per warning), A4, A5 (a warning's first cry), A8 (the table), A16: AD-5, AD-7, AD-17, AD-18, AD-32, AD-45.

**Acceptance Criteria:**

**Given** a `StartState` that places one of the dead in its warning phase at a place, with a start tick (R10)
**When** the sim reaches that tick
**Then** it emits `WARNING_STARTED` (who, kind, level, section, side, along) and `CRY_STARTED` with its slot and its sound id
**And** the warning holds that slot until its `WARNING_ENDED`
**And** `DeadState` has the warning phase only; nothing arrives when the warning ends (epic 3).

**Given** the three levels
**When** a warning starts
**Then** its cry is of its level's one kind: whispers below at a rail, shrieks above over a deck, sobs inside in a pier (FR13)
**And** a test fails if any kind can be started at another level.

**Given** `CryMix` (pure, `watch/sound/cry_mix.gd`)
**When** it is asked for a cry straight ahead, at the side and straight behind
**Then** it gives a high shelf above 2 kHz of 0, −5 and −10 dB and a gain of 0, −1 and −2 dB, each the full cut times (1 − cos θ) / 2 of the flat angle θ to the source, the ear test's curve (GDD: up to 10 dB and 2 dB behind, half at the side)
**And** it adds the clip's measured gain from `loudness.json`
**And** it takes the wounds as an input that stays empty until epic 4 (AD-17).

**Given** the cry's slot
**When** `CRY_STARTED` is carried out by `CryAudio`
**Then** that slot's send is switched to the cry's level bus, its shelf and gain are set from `CryMix` each frame as the warden turns and walks, and the player uses `ATTENUATION_DISABLED`, so the engine only pans (AD-6)
**And** a slot can play two clips at once, so a second cry of the same warning (the Diver's second shriek, story 2.4) does not cut the first
**And** which clip of the level plays is `CryAudio`'s choice (R1), never the same clip twice running on a level, which a test checks over many cries
**And** `CryAudio` decides nothing else: a test feeds it events and checks the slots it set.

**Given** the sound-and-cue table `watch/content/sound_cues.gd` (AD-45)
**When** the suite runs
**Then** it fails if a row has an empty cue id, or if the sim can emit a sound id that has no row
**And** every cry, and from later stories every other sound, is a row.

**Given** one `AudioEffectStereoEnhance` on Master (AD-18)
**When** a measurement tool, `game/tools/measure_watch_stereo.gd` (a script that renders and waits, like the loudness tool, so not a test; `tools/ci.sh` runs it), renders a hard-left source through the game's layout with `pan_pullout` −1, and then with 0
**Then** with −1 the right channel carries at least 20 dB more than the left, and the reverse for a hard-right source (swap)
**And** with 0 the two channels are within 0.5 dB (mono)
**And** with the default, 1, the left channel carries at least 20 dB more (nothing changed)
**And** if the swap fails, the architecture's fallback is built instead: one shared function mirrors every placed sound across the listener's own forward line (left of the head becomes right, whatever way the warden faces) while the swap is on, used by `CryMix` and by `SfxAudio` alike, so the rope, the toll and the check's stroke (placed left or right of the head) swap too; the same tool passes against it, with a source on the span's centre line and the warden facing a rail among its cases.

**Given** bot nights on `NightDef`s whose `StartState` places warnings, walking and turning through them
**When** every tick is checked
**Then** no slot is ever held by two warnings, and every `CRY_STARTED` names a slot the audio node has.

**Given** `CryAudio`
**When** a warning ends (`WARNING_ENDED`)
**Then** that slot's players stop, and a test feeding it events finds no player sounding in a slot the sim says is free. (A cut, with its 0.1 s fade, is story 2.10's.)

**Manual checks for Sonlm:**

- `--show=cry_turn`: a whisper repeats from the left rail a section ahead. Turn slowly through a full circle. It stays where it is as the head turns, and it is duller behind.
- `--show=cry_rooms`: one cry of each level in turn, each from its own kind of place at the same distance along the span (a rail, over a deck, the far pier). Above sounds thin and open, inside muffled and close, below far off with a long echo.
- Both on headphones and on the laptop's speakers.

#### Story 2.3: Cries come from the rails, the piers and overhead, and get quieter with distance

As the warden,
I want a cry to sound from where its threat will arrive, and quieter the farther along the span it is,
So that I can hear how far away it is, as well as which side.

Delivers: GDD Game Mechanics 1 (distance; a warning sounds from where the threat will arrive). FR17, FR19 (the place). GD-40, GD-56. Architecture AD-6, AD-42.

**Acceptance Criteria:**

**Given** `SpanGeometry`
**When** it is asked for a cry's place
**Then** below is under the given rail of the given section; above is over the given section's centre, above the deck; inside is in the far or the town pier, at the span's end
**And** a test places one of each on a 6-section and a 4-section `NightDef` with no literal 6 or 30.

**Given** `CryMix` and the distance along the span between the warden's feet and the cry's place
**When** that distance is 0, 5, 12.5, 25 and 30 m
**Then** the distance gain is 0, −3, −7.5, −15 and −15 dB (GDD: 0.6 dB per metre, up to 15 dB)
**And** it changes smoothly: at 4.99 and 5.01 m the two differ by less than 0.02 dB (a stepped rule fails this)
**And** a cry over a section and a cry under its rail, at the same distance along, are equally loud: height and sideways offset do not count (a straight-line distance fails this).

**Given** the warden walking toward a cry
**When** each frame is mixed
**Then** the slot's gain follows the warden's position through the `TickBlend`, with no step at a section's edge.

**Given** bot nights that walk the whole span while warnings sound from every kind of place
**When** every tick is checked
**Then** no gain is above 0 dB or below −15 dB before the clip's own gain and the rear shadow, and no fault is reported.

**Manual check for Sonlm** (`--show=cry_distance`): standing on the landing, the same whisper plays from under the rail of section 5, then section 3, then section 1. Near, middle and far can be told apart. Then a shriek over section 3 and a whisper under its rail sound equally loud.

#### Story 2.4: The four warnings play as specified, and the nest's sobs quicken

As the warden,
I want each kind of threat to announce itself with its own whole warning,
So that I know what is coming and have the full warning to act on.

Delivers: GDD Game Mechanics 1 (warnings; the one named exception); Asset Requirements (the tune, as a stand-in). FR14, FR19. Architecture A5 (all four warnings): AD-45 (a warning is a sequence the sim emits). Decided 2026-11-28: stand-ins made by script.

**Acceptance Criteria:**

**Given** a Grappler's warning starting on tick T
**When** it runs
**Then** its whisper starts on T, the straining rope (`&"rope_strained"`, a `SOUNDED` event from the same rail, on the `Bridge` bus) on T + 258 (4.3 s), and `WARNING_ENDED` comes on T + 360 (6 s)
**And** the rope follows story 2.3's distance rule, so it is never louder or quieter for its distance than the whisper before it (R2).

**Given** a Diver's warning starting on tick T
**When** it runs
**Then** its two shrieks start on T and T + 222 (3.7 s), both in the warning's one slot (the second does not cut the first), and it ends on T + 480 (8 s).

**Given** a nest's warning starting on tick T
**When** it runs
**Then** its seven sobs start on T, T + 456, T + 872, T + 1249, T + 1586, T + 1884 and T + 2142, which leaves gaps of 198, 158, 119, 79, 40 and 0 ticks (GDD: closing from about 3.3 s to none), and it ends on T + 2400 (40 s)
**And** every sob plays at the same gain: the sobs quicken, they do not get louder.

**Given** the warning of the one who keeps coming back, starting on tick T
**When** it runs
**Then** one phrase of the tune starts on T, from a rail, through the `Below` level bus, the straining rope on T + 258, and it ends on T + 360 (6 s)
**And** it counts as a cry and holds a slot (FR21).

**Given** the stand-in script `game/tools/make_watch_stand_ins.py` (run through `uv`, a fixed seed, no AI)
**When** it is run
**Then** it writes the tune's phrase to `audio/watch/tune/`, the straining rope to `audio/watch/bridge/`, the town bell to `audio/watch/town/` and the wind bed to `audio/watch/ambience/`, each named `placeholder_*.wav`, with a line in that folder's `CREDITS.md` saying it is a stand-in until story 5.9
**And** the tune's phrase has its entry in `audio/watch/tune/loudness.json`, which `measure_watch_loudness` writes and verifies with the cries' table, and it passes the 1 LU check against the cries
**And** no `placeholder_*.wav` sits in a folder with a real file
**And** the tune's phrase is 258 ticks and the rope 102 (1.7 s), give or take 1, checked by the same length test as the cries.

**Given** any warning
**When** it is cut short in a test (a fault)
**Then** the bot invariant fails: every `WARNING_ENDED` comes exactly its full length after its `WARNING_STARTED`.

**Manual checks for Sonlm** (one show-me setup per warning, standing mid-span): `--show=warning_grappler`, `--show=warning_diver`, `--show=warning_nest` and `--show=warning_tune`. Each sounds as the GDD describes. The nest's sobs are heard to quicken without getting louder. The straining rope reads as a rope under strain, not as a second cry. The tune reads as a different voice from the whispers, and as below.

#### Story 2.5: The 4-cry limit, the 1.5 s spacing and the ambience level hold

As the warden,
I want warnings that never pile on top of each other faster than I can hear them, over a bed of wind that never hides them,
So that several threats at once can still be told apart, and none of them catches me without its full warning.

Delivers: GDD Game Mechanics 1 (during the night: the limit, warnings first, spacing, ambience). FR21 to FR23, FR26, FR111 (epic 2's half). GD-57. Architecture A3 (the limit), A6 (the timetable runner, spacing and waiting): AD-7.

**Acceptance Criteria:**

**Given** a `NightDef` timetable of warnings (wave, seconds after that wave's first stroke, kind, place)
**When** `wave_rules` runs it
**Then** each warning is due on its tick, with wave *n*'s clock starting on tick (*n* − 1) × the wave's length
**And** the wave's length and the start of its lull are the `NightDef`'s: 7200 ticks (2 minutes) and 75 s in the one-night definition, shorter in test and show-me definitions, so a show-me setup can reach wave 4 in about a minute
**And** a test fails a `NightDef` that schedules a warning in a wave's lull.

**Given** a warning due 60 ticks (1 s) after another started
**When** it is due
**Then** it waits, emitting `WARNING_HELD`, and starts 90 ticks (1.5 s) after the last warning started, not after the last that was due
**And** its threat waits with it: the whole warning is shifted, never shortened.

**Given** four warnings sounding and a fifth due
**When** the fifth is due
**Then** it waits until a slot is free and 90 ticks have passed since the last start
**And** when several wait, the first due starts first (ties in timetable order)
**And** a warning still waiting when the lull begins starts as soon as it can, lull or not (settled 2026-11-28).

**Given** any tick
**When** the slots are counted
**Then** never more than 4 cries sound (the tune counts; the hum, the tune's resolving phrase, falling cries, the ally and ambience do not)
**And** a warning always sounds its whole length. (Cutting and skipping the cries of the dead on the deck is epic 3.)

**Given** a night, a lesson or a round
**When** it runs
**Then** the wind bed plays on `Ambience` from its first tick, looped, and stops with the scene.

**Given** the wind bed on `Ambience`
**When** `measure_watch_loudness --verify` measures it
**Then** it is at least 23 LU under the cries' measured loudness straight ahead at 0 m (the GDD's arithmetic: 6 dB under the quietest cry, far by 15 and behind by 2); the check fails at 22.9
**And** there is no music.

**Given** bot nights over many seeds on test timetables that crowd warnings (the GDD's wave 6, and a made-up wave of five warnings inside 3 s)
**When** every tick is checked
**Then** no two warnings start within 90 ticks, never more than 4 sound, every warning ends its full length after it starts, and none starts before it is due. This is epic 2's half of the fairness check (FR111); epic 3 adds "no arrival before its full warning".

**Manual checks for Sonlm:**

- `--show=four_warnings`: five warnings due inside 3 s: a Grappler, a Diver, a nest, the tune and a second Grappler. Each start can be heard as its own. The fifth comes in later, not on top.
- `--show=ambience`: the wind alone, then a whisper far and behind over it. The whisper is still clearly heard. The wind reads as wind.

#### Story 2.6: The ally calls the level, with a caption

As the warden,
I want the ally to call out the level of a warning, and to see their words at the bottom of the view,
So that early on I learn which cry is which level, and later the ally catches the warnings I missed.

Delivers: GDD Game Mechanics 8. FR72 to FR74; NFR18. GD-7, GD-26, GD-39; UX-1, UX-26, UX-42, UX-43. Architecture A6 (waves), A9: AD-32. `DESIGN.md` caption-line. Decided 2026-11-28: Sonlm records the stand-in lines.

**Acceptance Criteria:**

**Given** a warning starting in waves 1 to 3, on tick T
**When** T + 120 (2 s) comes
**Then** the call for its level is due: "Below!" (the tune's warning too), "Above!" or "In the walls!"
**And** the sim emits `ALLY_CALLED` with the line's id when the call starts.

**Given** a warning starting in waves 4 to 6, on tick T
**When** T + 240 (4 s) comes
**Then** a call is due only if the warden is not facing the warning's place at that tick, by the facing rule settled on 2026-11-28.

**Given** a call that is due while another line is being spoken or its caption is still shown
**When** it cannot start
**Then** it starts when the caption has been gone for 18 ticks (0.3 s, `EXPERIENCE.md` caption-line)
**And** if it cannot start within 240 ticks (4 s) of when it was due, it is dropped (`ALLY_CALL_DROPPED`): one call at a time.

**Given** the cue mode
**When** it is Everywhere (the setting comes in story 5.8)
**Then** `ally_rules` already calls every warning 2 s in, all night, and a test covers it through `NightCommand.set_option()`.

**Given** a spoken line
**When** it plays on the `Ally` bus
**Then** its caption shows at the bottom centre: one line in `caption` (48 px at 1080p, 32 on the canvas), in `caption` colour, with a solid `abyss` outline of 2 canvas px (the plain halo settled 2026-11-28; no soft spread until DW-21), its baseline `spacing.5` above the bottom safe margin, no wider than 60% of the view
**And** `WatchTheme` gains the `caption` style and the colours it uses, checked against `DESIGN.md` by its test; its `label` size and `spacing.2` stay as they are for story 5.1 (DW-58)
**And** it stays for as long as the line plays and at least 120 ticks (2 s), and says only what the voice says
**And** the `Ally` bus is never cut by a wound (AD-17's input, empty until epic 4).

**Given** the six lines (`ally_below`, `ally_above`, `ally_inside`, `lesson_open`, `lesson_yes`, `lesson_again`)
**When** Sonlm's recordings are not yet in
**Then** each is a `placeholder_<line id>.wav`, a short soft tone of the line's length, with its caption
**And** a one-page sheet `game/audio/watch/ally/RECORDING.md` lists the six lines to record, with how to name and hand them over
**And** when the recordings arrive, a small trim-and-level script in `game/tools/` (the cutting tool cuts fixed 4.3 s stretches, so it does not fit spoken lines) trims each one's silence, evens their loudness with each other, and they replace the tones as `<line id>.wav`; the `placeholder_` name is for the tones only.

**Given** the sim, which reads no files
**When** it times a line (its caption, the lesson's next step)
**Then** each line's length in ticks is data in `watch/content/ally_lines.gd`, beside its caption text
**And** a test fails if any length differs from its clip's by more than 1 tick, so a new recording that is longer or shorter is caught.

**Given** the forearm raised while a caption shows
**When** the forearm's bounds are projected through the warden's camera onto a 1280×720 canvas
**Then** they do not reach into the caption's band (a headless geometry test; EXPERIENCE.md, over the caption band)
**And** a 1080p frame captured on a virtual display (Xvfb), as epic 1's screen checks were, shows the same; that frame is a screen check for the story record, not a CI test, since CI renders nothing.

**Given** bot nights on a test timetable of at least four waves, where the bot sometimes turns toward a warning and sometimes not
**When** every tick is checked
**Then** waves 1 to 3 call every warning that is not dropped, waves 4 to 6 call only the ones not faced, and two calls never overlap.

**Manual checks for Sonlm:**

- `--show=ally_calls`: a four-wave night with short waves (story 2.5's wave length). In waves 1 to 3 every warning is called about 2 s in. In wave 4, turning toward a warning stops its call.
- `--show=caption`: the caption at a 1080p window on the laptop. With only its solid outline, it is easy to read over the lit deck and over the dark, and it is clear of the raised forearm. If it does not read, rendered options follow (DW-21).

#### Story 2.7: The bridge shows where, inside the carried lantern's light, and the flame leans

As the warden,
I want to see the ropes shake, the fog swirl or the dust fall where a warning comes from, and my lantern's flame lean toward it,
So that in the light I can see where a threat is, as well as hear it.

Delivers: GDD Game Mechanics 1 (every sound has a visual cue; the cue modes); Game Mechanics 6 (the carried lantern's reach; the town gate's light). FR28, FR31, FR56 (part); NFR17. GD-9; UX-29. Architecture A7, A8 (`CueRules`): AD-16, AD-45. DW-31. Decided 2026-11-28: the gate's light comes in here.

**Acceptance Criteria:**

**Given** a night
**When** it starts
**Then** the warden carries one lantern, lit, whose light reaches 4 m (oil, the shutter and hung lanterns are epic 4)
**And** `light_rules` answers whether a place is lit, flat, by R3: within 4 m of the carried lantern, or on section 6 or the landing (the town gate's light, which cannot be moved or shuttered).

**Given** `CueRules.is_shown(cue_class, lit, cue_mode, lesson_cue)`, where `lesson_cue` is the cue's lesson state (`NONE` at night; `HELD` or `REVEALED` from the lesson, story 2.9)
**When** it is asked for every class, mode and state
**Then** `HELD` is never shown and `REVEALED` is always shown, self-lit; with `NONE` it gives the architecture's table: `POINTER` where lit in In the light, everywhere (self-lit) in Everywhere, never in Ears only; `PHYSICAL` where lit; `PHYSICAL_GLOW` where lit, and also self-lit in Everywhere; `ALWAYS` always; `EVERYWHERE_ONLY` only in Everywhere
**And** it is the only place that table becomes yes or no
**And** a cue drawn self-lit is an unshaded copy of the cue object (settled 2026-11-28; used by the lesson in 2.9 and by Everywhere from 5.8).

**Given** a warning sounding
**When** its place is lit
**Then** its level's cue shows on every tick of the warning, from `WARNING_STARTED` to `WARNING_ENDED`, that its place is lit (walking the lantern away hides it; the log's lit mark, R7, is judged once, at the start): that rail's ropes shake (below), the fog over that section swirls (above), dust falls from that pier's stones (inside)
**And** the tune's rail's ropes sway in time with it instead of shaking
**And** the cue comes from sim state, never from whether the audio is playing (a test runs the sim with no audio node and finds the same cues).

**Given** cries sounding
**When** the carried flame is drawn
**Then** it leans toward the nearest cry whose place is inside the lantern's own 4 m light and whose lesson state is not `HELD` (a `REVEALED` lesson cry counts), by the flat bearing the sim gives, and stands straight when there is none
**And** in Everywhere (from story 5.8) it leans to the nearest cry anywhere; `light_rules` already answers both.

**Given** the cue effects and the flame
**When** they move
**Then** nothing flashes, nothing flickers faster than 3 times a second, and a self-lit glow does not pulse (NFR17)
**And** a test reads every cue view's brightness constants and finds none that changes brightness more than 3 times a second; it cannot see a shader or a noise-driven flame, so the manual check below is the real safeguard.

**Given** DW-31
**When** this story's cues are judged
**Then** none of them is meant to be read from more than the lantern's reach, so none needs a far cue of its own.

**Given** bot nights walking among warnings of every level
**When** every tick is checked
**Then** a pointer cue is shown exactly when `CueRules` says, and the flame's lean target is always a cry that is sounding and lit.

**Given** the cue views, built headless
**When** they are fed the same ticks
**Then** each cue object is visible exactly when `CueRules` says for its class, its light and the cue mode, and hidden otherwise (a view that ignores `CueRules` fails this).

**Manual checks for Sonlm** (`--show=lantern_cues`): walking with the lantern near a rail, a section and a pier while each level's warning sounds. Each cue is seen inside the light and not beyond it, and goes when the lantern is walked away. The flame's lean points the right way. Nothing flickers or flashes. Then the same on section 6, by the gate's light, with no lantern needed.

#### Story 2.8: The town bell tolls from the town side, and the tally is chalked

As the warden,
I want the town's bell to toll the wave at its start, from behind me, and to see a tally chalked for it at the town pier,
So that I always know which wave it is and which way is home.

Delivers: GDD Enemy Wave Design (the toll); Game Mechanics 1 (the cue table: the toll). FR30, FR93. GD-24. Architecture A6 (the toll), A10. DW-31.

**Acceptance Criteria:**

**Given** a night's timetable
**When** wave *n* begins
**Then** the town bell strikes *n* times, 90 ticks (1.5 s) apart, the first on the wave's first tick, each a `BELL_STRUCK` event with its stroke number
**And** the wave's clock starts at its first stroke (FR93).

**Given** a stroke
**When** it is carried out
**Then** it sounds from the town (R6) on the `Town` bus, and turns with the warden's head like any placed sound
**And** it loses nothing with distance (R6), and `measure_watch_loudness --verify` measures it as played, through `Town`, and checks it is at least 23 LU under the cries, as the wind is (FR26; fails at 22.9)
**And** the manual check confirms its strokes can still be counted at that level.

**Given** a toll
**When** its last stroke rings
**Then** the ally chalks one tally on the board at the town pier (`TALLY_CHALKED`), and the board shows one stroke per wave so far, drawn in `landing_view`
**And** the tally is an `ALWAYS` cue, shown in every cue mode, and the board stands in the gate's light (story 2.7).

**Given** DW-31
**When** the warden is far from the board
**Then** the toll's count of strokes is the cue for the wave; the board is read up close.

**Given** bot nights over test timetables of one to six waves
**When** every tick is checked
**Then** each wave has exactly its number of strokes and one tally, in order.

**Manual checks for Sonlm** (`--show=toll`): a night of four short waves (story 2.5's wave length). Each toll's strokes can be counted. Each comes from behind when facing the far pier, and in front when facing the town. The bell stand-in reads as a bell. The board shows the tallies when walked up to.

#### Story 2.9: The listening lesson, from the left/right check to the last cry

As a newcomer,
I want to check my sound is the right way round and then learn, three times, to turn to a cry,
So that before anything can hurt me I know that the kind of cry tells me the level and that turning toward a sound works.

Delivers: GDD Core Gameplay Loop (the dusk lesson, listening part); Technical Metrics (first cry within 15 s). FR2, FR3; NFR11, NFR22. GD-8, GD-71, GD-74, GD-76; UX-20, UX-22 (look and walk), UX-38, UX-42, UX-43, UX-46 to UX-49, UX-65. Architecture A11, A12 (the lesson), A15, A18 (the lesson's ending): AD-21, AD-22, AD-32, AD-61. `DESIGN.md` two-choice, note-line, key-prompt. Settled 2026-11-28: the lesson's playing and places; the facing rule; the two lines.

**Acceptance Criteria:**

**Given** the start page
**When** "Begin" is chosen
**Then** the left/right check opens (`watch/screens/sound_check_screen.gd`), and after it the lesson.

**Given** the check opening
**When** it is shown
**Then** it is dark, with the note-line "A bell rings on one side." above the question "Left or right?", the words Left and Right side by side in `heading`, and "I can't hear it" below in `body`, all through `WatchTheme` at scale B (UX-42, UX-43: `heading` 60 px at 1080p, 40 on the canvas; `body` 42, 28; every word `ink` or brighter; the theme gains both styles)
**And** a chosen word is `warm` with its 2 canvas px warm rule and no glow (settled 2026-11-28)
**And** nothing is chosen, and one stroke of the town bell sounds from a side picked by the screen's own generator, seeded from `--seed` when it is given and otherwise from the clock at start, at the loudness of R4; the seed is kept for the log.

**Given** the check
**When** A or the Left arrow, or D or the Right arrow, is pressed, or a word is clicked
**Then** that answer is given at once
**And** Down or S chooses "I can't hear it" and Enter or Space confirms it; Up or W clears the choice; Enter does nothing while nothing is chosen; R rings again; Esc goes back to the start page
**And** the pointer chooses what it rests on only once it has moved after the screen opened (UX-65).

**Given** a wrong answer
**When** it is the first in a row
**Then** nothing says it was wrong, the stroke comes again from a side picked at random, and the question repeats
**And** a right answer goes on to the lesson.

**Given** two wrong answers in a row
**When** the second is given
**Then** the screen warns that the sound may be coming from one channel only and offers "Swap left and right" and "Go on" (R5) as menu-items; either goes on to the lesson
**And** "Swap left and right" switches the swap on (AD-18, story 2.2) and saves it.

**Given** "I can't hear it"
**When** it is confirmed
**Then** the answer is kept for the log (story 2.11) and the lesson opens. (Its offer of Cues everywhere is story 5.8's.)

**Given** `WatchSettings` (`watch/core/watch_settings.gd`)
**When** the swap is changed or the lesson is finished
**Then** the swap and the lesson-done flag are saved in one `ConfigFile` under `user://` and read back at the next start
**And** a missing or damaged file gives the defaults and a setup problem, never a crash; a value of the wrong type is checked with `is` and replaced by its default.

**Given** `--start=lesson`, or the check's end
**When** the lesson opens (`watch/lesson/`, driving a `NightSim` from the lesson's `NightDef`, AD-22)
**Then** the wind plays as at night, the warden stands mid-span facing the town, carrying the lit lantern (whose flame's lean is held back like the cues, below), the ally says "Listen. When one calls, turn to it.", and the first cry (sobs in the far pier) starts 300 ticks (5 s) after the lesson opens, or 60 ticks after that line ends if it is longer, and always within 900 ticks (GDD: within 15 s; a test fails at 901)
**And** the look key-prompt shows while that cry is not yet faced, and the walk key-prompt once it has been, each in `body`, `caption` colour with the halo, where the caption sits, never at the same moment as a caption (the caption wins and the prompt waits), and each never returns once its action has been done.

**Given** a lesson cry
**When** it is played
**Then** a playing is one 4.3 s clip of its level's kind from its place (far pier, then under the left rail of section 5, then over section 2)
**And** faced, by the facing rule, at any moment from the playing's start to 60 ticks after it ends: the ally says "Yes.", and the next cry starts 180 ticks (3 s) after the word ends
**And** not faced: 90 ticks (1.5 s) of quiet, then "Listen again" with its caption, then the cry again 60 ticks after the line ends.

**Given** a lesson cry not faced in three playings
**When** it plays the fourth time
**Then** its place's cue shows, self-lit, so it can be seen from anywhere, until it is faced: `lesson_rules` sets the cry's cue state to `REVEALED` (story 2.7's `CueRules` input)
**And** until then its state is `HELD`, so no pointer cue of that cry shows, even where light falls (the gate's light reaches section 6), and the carried flame does not lean toward it
**And** the lesson's `NightDef` has a switch that shows the cue from the first playing and has the ally call each lesson cry's level with its caption, tested here, which story 5.8 turns on in Cues everywhere (UX-47, R11).

**Given** the third cry faced and its "Yes." spoken
**When** the line ends
**Then** the sim emits `LESSON_ENDED` and builds a `NightResult` for the lesson (playings per cry, the tick of the first cry)
**And** the lesson-done flag is saved, and the flow goes back to the start page (story 2.10 puts the round here).

**Given** the lesson and the check screens
**When** they are drawn
**Then** no aim aid is drawn (DW-41).

**Given** the launch-switch test
**When** it runs
**Then** it also starts the game with `--start=lesson` for 120 frames.

**Given** a scripted bot that faces each cry at once, one that never faces until the cue shows, and one that walks about
**When** each plays the lesson to its end
**Then** each reaches `LESSON_ENDED`, the first cry always starts within 900 ticks, and no fault is reported.

**Manual checks for Sonlm:**

- `--show=sound_check`: answer right; answer wrong once (the stroke rings again); twice (the offers); try "I can't hear it", R and the pointer. With the swap on, the next check is heard the other way round.
- `--start=lesson`: the whole lesson once facing each cry, and once letting a cry go unfaced three times to see its cue. The prompts appear and go when they should, and the lines and captions match.

#### Story 2.10: The listening round runs and scores direction and place

As the person running a playtest,
I want twelve warnings from places the newcomer cannot predict, scored for direction and for place,
So that I can tell from hearing alone whether a newcomer can find a threat.

Delivers: GDD Success Metrics (the ear re-check: the listening round). FR110. GD-30, GD-46; IN-20. Architecture A12 (the round), A13 (the round's scores), A18 (the round's ending): AD-22, AD-61. DW-26. Settled 2026-11-28: trial start and places, the place mark, the facing rule.

**Acceptance Criteria:**

**Given** the lesson ended
**When** the flow goes on
**Then** a dark page shows one entry, "Begin the round" (R9), and choosing it opens the round (`--start=round` opens it directly).

**Given** the round's `NightDef`
**When** the round runs
**Then** it has 12 trials, 4 per level, in an order shuffled with `sim.rng` that never has three of one level in a row
**And** the warden starts mid-span facing the far pier
**And** the warden carries no lantern, the ally is silent, and the cue mode is Ears only, so the gate's light shows nothing
**And** the wind plays as at night.

**Given** a trial starting on tick T
**When** its place is drawn with `sim.rng`
**Then** it is a place of its level, from every section but the last and the two piers (10 rails, 5 decks, 2 piers on the one-night span), more than 5 m along the span from the warden on tick T (strictly: a neighbouring section's centre, exactly 5 m away, does not count, so standing still never earns the place mark); if none is, the farthest
**And** the trial's `TRIAL_STARTED` event says whether the place was within 45° of the facing on tick T ("ahead").

**Given** a trial
**When** it runs
**Then** its level's full warning starts on T (Grappler, Diver or nest; R8), the trial ends on T + 900 (15 s), and the next trial starts 180 ticks (3 s) after
**And** a warning still sounding when its trial ends (only a nest's, 40 s) is cut with a `WARNING_CUT` event, and `CryAudio` fades its slot out over 0.1 s and frees it; the full-length invariant of stories 2.4 and 2.5 exempts exactly this case, and a test checks that nothing else is ever cut
**And** the warden is never moved by the round.

**Given** a trial's scoring (`score_rules`)
**When** it ends
**Then** direction is right if the warden faces the place on T + 240 (4 s), by the facing rule
**And** place is right if, before T + 900, the warden stood still (no move wish) for 60 ticks (1 s) with the feet within 5 m along the span of the arrival point (a section's centre for a rail or deck, the span's end for a pier)
**And** the warden's position and facing during the trial go to the log (story 2.11).

**Given** the twelfth trial ended
**When** the round ends
**Then** the sim emits `ROUND_ENDED`, and the `NightResult` holds direction and place as counts and percentages, overall and per level, direction also over the trials that did not start ahead, with each trial's marks
**And** the flow shows a page that says the round is over, and goes back to the start page.

**Given** the same seed twice, and two different seeds (DW-26)
**When** the round's draws are compared
**Then** the same seed gives the same levels and places, and different seeds give different ones: a test that fails if the rolls stop changing the events.

**Given** the round's screens
**When** they are drawn, from the editor or a playtest build
**Then** no aim aid is drawn (DW-41).

**Given** the launch-switch test
**When** it runs
**Then** it also starts the game with `--start=round` for 120 frames.

**Given** scripted bots that turn to each place at once and walk to it, that never turn, and that walk at random
**When** each plays the round over many seeds
**Then** the first scores 12 of 12 on both marks, the second scores on direction exactly the trials that started ahead and 0 on place, and no place is ever drawn at 5 m or less along when one farther exists.

**Manual check for Sonlm** (`--start=round`): play the round once, honestly. It takes about 4 minutes (12 trials of 15 s with 3 s between; the GDD's "about 5 minutes" is rounded up and its wording is owed to the next gds-gdd run). No place can be guessed from the last one. The result page appears. Note the score; it is yours, not a newcomer's.

#### Story 2.11: Every warning is logged, and the playtest build writes the log

As the person running a playtest,
I want every warning, every answer and every focus loss written to a local file by a build I can hand to the laptop,
So that the early listen and gate 2 can be scored from what actually happened.

Delivers: GDD Success Metrics (the night log); Platform (no network). FR109; NFR16. GD-30. Architecture A13, A14, A17: AD-24, AD-53, AD-60, AD-67. DW-51. Decided 2026-11-28: the playtest presets land here.

**Acceptance Criteria:**

**Given** a warning in a night or a round, starting on tick T (a lesson's playings are not warnings and get no marks; the log records each playing and whether it was faced)
**When** T + 240 (4 s) comes
**Then** `score_rules` emits the `WARNING_SCORED` events `&"turned"`, `&"heading"` and `&"lit"`, `amount` 1 or 0: turned if the warden faces it at 4 s by the facing rule; heading and lit by R7
**And** it emits `&"called"` when the ally's call for that warning starts (1) or is dropped or never due (0), which can be as late as 8 s after the warning starts (story 2.6), so a call delayed by a caption is still counted.

**Given** `PlaytestLog` (`watch/log/playtest_log.gd`), owned by `WatchSession`
**When** the build has the `playtest` feature or the game was started with `--log`
**Then** it writes one CSV row per `NightEvent`, plus rows for the left/right check's answers, each loss of window focus (with the trial or the lesson cry it fell in), the time from the lesson opening to its first cry, the warden's place along the span, sideways place, facing and whether walking every 6 ticks (0.1 s) during each round trial, each `NightResult` and "New listener"
**And** each row is flushed as it is written, a file is never overwritten (a clash gets `_2`, `_3`), and it is written under `user://`
**And** with neither, it writes nothing: a test, a smoke run and a plain editor run leave no file (AD-53).

**Given** the start page of a playtest build or of an editor run
**When** "New listener" is chosen
**Then** the saved settings and the lesson-done flag are cleared, a "New listener" row is written, and the check opens, so one laptop can serve several newcomers with no command line.

**Given** `build_info.gd`
**When** `tools/ci.sh --export` runs
**Then** it writes the commit hash into `build_info.gd` before exporting, and the game shows "dev" when run from source.

**Given** two playtest presets, Linux and Windows, kept in step
**When** they are exported
**Then** each has the feature `playtest`, includes `audio/watch/cries/loudness.json`, `audio/watch/tune/loudness.json` and `fonts/OFL.txt` in its include filter (DW-51), and leaves out `tests/` and `tools/`
**And** the ear test's two presets keep exactly their own filter line (its own test still passes)
**And** `tools/ci.sh --export` builds both and starts the Linux build once for 120 frames, failing on any ERROR or WARNING line.

**Given** the ear test's two private builds, which carry the font file but not `OFL.txt`
**When** they are exported
**Then** they are left as they are: Sonlm chose on 2026-11-28 not to rebuild them (they are private and closed, and the font file's own metadata holds its copyright and licence); public builds carry `OFL.txt` (epic 8, DW-51).

**Given** a bot night, a lesson and a round run with `--log` in a test's own `user://..._selftest` folder
**When** the files are read back
**Then** every event and summary row is there, in order, and every warning has its four marks, including a warning whose call was delayed by another caption and then made (`called` 1).

**Manual check for Sonlm** (from the editor, with `-- --log` in Main Run Args, as the early listen will run): choose "New listener", do the check, the lesson and the round, then open the log folder. There is one file, and its rows match what was done, including an alt-tab during the round.

#### Story 2.12: The early listen is run and written up

As Sonlm,
I want two or three people who have never heard the game to try the lesson and the round,
So that I know whether strangers can place a threat by ear before I build the dead on top of it.

Delivers: GDD Success Metrics (the early listen). FR112. GD-43. DW-10. Run by Sonlm; the session script, the scoring and the write-up are Claude's.

**Acceptance Criteria:**

**Given** the preconditions
**When** the first session is booked
**Then** story 2.1's re-cut is done (DW-11), Sonlm's six recordings have replaced the tones (story 2.6), and the editor run with `-- --log` on the laptop has passed story 2.11's check.

**Given** the session script `_bmad-output/implementation-artifacts/early-listen/session-script.md`, written by Claude and approved by Sonlm
**When** a session runs
**Then** it says, in Godot editor terms with no command line (the run with `-- --log` in Main Run Args): the quiet room, headphones or speakers (at least one newcomer on each), "New listener", the check and the lesson untouched by the person running it, and the round's instruction, read aloud word for word before "Begin the round"
**And** it says what the person running it must not do: point, hint, or say whether a turn was right
**And** it records the device (which headphones or speakers) and the volume used
**And** it ends with three questions asked aloud after the round, answers written down as said: which cry came from below, which from above, which from inside the walls; and was anything confusing.

**Given** two or three newcomers' sessions
**When** each is done
**Then** its log file is copied into `_bmad-output/implementation-artifacts/early-listen/`, with the output (headphones or speakers) and anything the newcomer said, written down as said.

**Given** the logs
**When** a small script in `game/tools/` reads them
**Then** it prints, per newcomer and together, direction and place as counts and percentages, overall and per level, the time to the first cry, the check's answers, and which trials fell in a focus loss and are left out.

**Given** the write-up `_bmad-output/implementation-artifacts/early-listen-outcome.md`
**When** it is written
**Then** it reports only the counts, the newcomers' own words and which sounds were stand-ins (bell, rope, wind, tune), with no claim about what anyone heard beyond what they did
**And** it gives Sonlm's own round score (story 2.10's check) as a baseline, marked as Sonlm's
**And** it says which of the GDD's assumptions the early listen tested and which it did not: it tests a walking listener with the wind and one cry at a time (assumption 1 in part) and distance (assumption 3), not four cries at once (assumption 2), which rests on gate 2's night log (DW-61)
**And** it says whether direction reaches 80% both over all trials and over the trials that did not start ahead, pooled across the newcomers (GD-77). If either is under 80%, the design is rethought before epic 3 (GD-43), with options put to Sonlm. If not, epic 3 may start. Epic 3's stories may be written before then, but epic 3 starts only when the early listen is scored.

**Manual check for Sonlm:** run the sessions. If Sonlm's own voice worked for the ally, say so in the write-up: it may become the final voice (GD-26) and close DW-9.

---

## Epic 3: The dead

**Goal.** The three kinds of dead arrive, cross and cost the town its lights.

**In**

- Grapplers, step by step: the warning under a rail on sections 1 to 5 (the rail locks); the hook lands (at most 2 per rail) and the Grappler hangs for 6 s with a load of 1; then it walks to the town.
- No rail, no hook; with no free rail, a hook on the deck of the section with the most planks, tearing one off. The deck hook picks an edge at random, and its warning rattles that edge's planks.
- Section 6 takes no hooks and no Divers while any other section has planks.
- Divers: a Diver whose section opens or falls during its 1 s drop falls through (GD-60). A section picked when the warning starts, and the shrieks come from over it; here the section with the fewest planks (the light rule arrives in epic 4); a landing that counts 5; then a walk.
- Hollow Nesters: 40 s of quickening sobs in a pier, then 4 hatchlings at 3.0 m/s.
- On the deck each of the dead repeats its cry every 8 s with footsteps. Warnings come first: one may cut the farthest cry on the deck, and a deck cry with no place is skipped until its next 8 s mark (GD-57). Anything that falls lets out a cry that fades; at most three at once.
- A stranded Diver's second dive is a full 8 s warning (GD-65).
- Loads on sections from every body and every set hook.
- The town's 12 windows; a crossing is stepping off section 6 onto the landing; each puts one window out; hatchlings put one out per two. A window going out makes a small sound from the town side; a lone hatchling's crossing makes the next window flicker low.
- Losing the night: section 6 falls, or the last window goes dark.
- Falling: gone until dawn.
- What each kind does at an open section and at a gap.

**Out.** Rigs; the six-wave timetable (a simple test timetable stands in); the one who keeps coming back.

**Playable at the end.** An undefended span: the dead cross, the windows go out, the night is lost.

**Stories**

1. Grapplers warn, hook, haul and walk. (Mechanics 3: a Grappler, step by step; Enemy Wave Design. GD-15 to GD-17)
2. The rail rule decides where Grapplers can come up. (Mechanics 3: no rail, no hook; Mechanics 1: a hook on the deck. GD-20)
3. Divers warn, choose a section, land hard and walk. (Enemy Wave Design; Mechanics 2: a Diver's landing; Mechanics 6: the 1 s drop. GD-15 to GD-17, GD-60)
4. Nests warn for 40 s and hatch four. (Enemy Wave Design. GD-15 to GD-17)
5. On-deck cries, footsteps and the falling cry. (Mechanics 1: during the night. GD-57, GD-65)
6. The town's windows go out as the dead cross, with their sound and the flicker. (Win/Loss: crossing, windows. GD-12; UX-30, UX-37)
7. The night can be lost in both ways. (Win/Loss. GD-12)
8. The fallen are gone until dawn. (Mechanics 2: falling. GD-13)
9. Each kind handles open sections and gaps as the GDD states. (Mechanics 2: open and fallen sections, section 6. GD-65)

**Delivers.** GDD Enemy Wave Design (types), Win/Loss Conditions. Decisions GD-12, GD-13, GD-15, GD-16, GD-17, GD-20, GD-57 (deck cries), GD-60, GD-65 (the second dive); UX-30, UX-37.

---

## Epic 4: Rigs and hands

**Goal.** The warden can hold a wave with tools and the bridge, and every spring spends a part.

**In**

- Context hands: the hammer hand and the rope and lantern hand show the action before the click. A ready pose when something usable is within 2 m; a hold shown by its own animation and sound, with no bar; a cancelled hold dropping from the hand; an impossible action reaching and opening empty. In gray boxes: block hands holding a recognisable hammer, rope or lantern. Hands and forearm keep a minimum brightness, so the ready pose can be told with every lantern shuttered.
- Trapdoor: build (8 s at night), spring, drop, haul up; each drop loses 1 plank; it cannot be sprung under 4 planks.
- Swing-beam: build (12 s at night) on the rail the warden is looking toward, spring, sweep, re-hang; each re-hang costs 1 rope; it knocks hooks off its section's rails and deck edge.
- No rig on section 6. A rail holding a beam, or a hook, cannot be stripped.
- Building, hauling, re-hanging and dismantling only from within 2 m of a section's town-side edge, on the next section toward the town, where the hands take out the tool. A rig cannot be worked while that next section is open or fallen. A warden on a trapdoor when it drops catches the edge and is wounded.
- The wedge: 3 s of hammering, 1 plank, a nest shut for the wave.
- Striking a hook: one blow restarts the haul, once per Grappler.
- Dismantling a rig: planks return, one rope is lost.
- Lanterns: three; one pole on each section; the lantern held over the centre of the section; one lantern in hand, hung, taken or swapped at a pole with one press, and kept lit in hand through holds and wounds; 4 m and 5 m of light; cues wherever light falls, which includes the town gate's light on section 6 (built in story 2.7).
- Oil: 6-minute tanks; one spare flask that stays at the town pier and refills the lantern in hand, once; the shutter (carried and hung); the level read from the lantern's glass, a shrinking, sputtering flame in the last 60 s, and a seam glow when shuttered.
- E acts on what the warden looks at: a pole or the flask (re-laying a plank is already in epic 1). F acts on the hung lantern looked at, otherwise on the lantern in hand.
- Divers pick their section by the light rule, at the start of the warning. An open section cannot be picked, and a redirected Diver lands within sections 1 to 5 when it can. A trapdoor sprung during a Diver's 1 s drop catches it (GD-60); a Diver landing in a beam's sweep is swept off.
- Wounds: knocked down for 1.5 s; sounds on that side of the head quieter, growing to 12 dB at the side, cries also dulled, the ally's voice and the warden's hands never cut, and that side of the view darkened for 20 s (GD-62, GD-66); from the dead, the warden's own beam, a Diver's landing, or a falling section. A wound cancels a hold.

**Out.** The planning view; the full wave timetable; the name.

**Playable at the end.** One scripted wave of Grapplers, a Diver and a nest, held with a trapdoor, a swing-beam, a wedge and lanterns.

**Stories**

1. The hands show and perform the right action for what the warden looks at: ready pose, hold, cancel, can't. (Controls and Input: context hands, what the player sees and hears. GD-22; UX-2, UX-5, UX-6, UX-50)
2. The trapdoor, and the plank each drop costs. (Mechanics 4. GD-18, GD-41)
3. The swing-beam, and the rope each re-hang costs. (Mechanics 4. GD-18, GD-41)
4. Building and dismantling at night, from the town-side edge. (Mechanics 4; Mechanics 3: dismantle. UX-9, UX-51: judge in play whether a brushed movement key ends a build, DW-60)
5. The wedge. (Mechanics 5. GD-17, GD-19)
6. Striking a hook. (Mechanics 3. GD-38)
7. Lanterns hung, taken and swapped at poles; cues wherever their light falls. (The carried lantern and the town gate's light are story 2.7's.) (Mechanics 6. GD-28, GD-49; UX-29, UX-36)
8. Oil, the flask at the town pier, the shutter, and reading the level. (Mechanics 6. GD-28; UX-7, UX-36)
9. Divers follow the light. (Mechanics 6: Divers and light. GD-60)
10. Wounds. (Mechanics 9. GD-27, GD-62, GD-66; UX-52: the darkened side's limits, chosen from rendered frames)

**Delivers.** GDD Game Mechanics 4, 5, 6, 9; Controls and Input (night). Decisions GD-18, GD-19 (costs), GD-22, GD-27, GD-28, GD-38, GD-41, GD-49, GD-62, GD-66; UX-2, UX-5, UX-6, UX-7, UX-9, UX-29, UX-36.

---

## Epic 5: The night

**Goal.** The whole sitting, start to dawn, in gray boxes.

**In**

- Planning from above: strip the next plank or a rail, place rigs on sections 1 to 5, hang lanterns, undo, Start over, hold Space to ring the bell. Strength numbers, the tool tray with costs, and the why-not line. An undo that needs a spent part is refused, and the bell waits until both lanterns are hung. The view never shows what is under the planks.
- The six waves on their timetable, the lulls, the bell's tolls, the silence before wave 6, the paling sky, dawn on the clock.
- The ally's calls fade to a safety net from wave 4.
- The name under the planks: a random section from 2 to 5, the hum, the leaning flame, read on foot by lantern light with about 1 s of looking, the forearm rising once to show it.
- The one who keeps coming back.
- Calling the name at the bell: its owner passes, and the dead on and under the span stand still and silent for 20 s, hanging Grapplers and anything that arrives meanwhile included (GD-61, GD-64). A wrong ring hurries the walkers; during the stillness it does nothing.
- The tune comes before every other cry on the deck and is never cut by a warning (GD-65).
- Dawn wins if the night would be lost in the same instant, and that instant's loss does not count (GD-59, GD-67). Dawn: the silence, the ally's one line, then the ledger page written in beside the span, with the name learned, its epitaph and the soul released, ending on "The fallen will return." (GD-53); then another night on a fresh span, or leave.
- A lost night: dark, then the journal page with the hint, or the same hint again if its cause repeats; replay from planning, on the plan that night was started with. Every night start rolls the name and its section again and clears the forearm (GD-52), and the oil and the flask are full again (GD-58).
- Starting up: the title (Begin the watch, Settings, Credits, Quit), the headphones-or-speakers question, and skipping the lesson once it has been finished on this machine. Credits opens a page that lists the asset licences from the credits files kept since epic 2; the AI-use disclosure is added to it in epic 8.
- The lesson's hands-on part, with its key prompts: strike a practice pin on the landing, strip a plank, hang and shutter the lantern, raise the forearm. The span and lanterns are put back before planning.
- Pause as a full stop, which also freezes a hold, with five entries: Resume, Keys, Journal, Settings, and Leave the bridge, which asks first. The key card. The journal page, opened with J in planning and from pause; its hints survive a return to the title (GD-58).
- Settings: Visual cues (In the light, Everywhere, Ears only), with the cues drawn self-lit in the dark for Everywhere; centre dot; volume; headphones or speakers; swap and check left and right; mouse sensitivity; invert look; fullscreen or window; resolution; brightness; field of view; caption size. The left/right check's offer of Cues everywhere is wired here. (Fog quality joins the list in epic 7, with the fog it sets.)
- Every screen in the Lantern light look from `DESIGN.md`, at the canvas size of architecture AD-69. Keys are bound by physical position since epic 1; the key card shows each key as the player's keyboard prints it.
- The night's few texts are written: 6 names with epitaphs, 6 journal hints, the ally's lines.
- Every sound the night still lacks is in place: the hum and the tune, both bells, footsteps, creaks and groans, the collapse, the rigs, the lanterns; and the small sounds of the hands and screens (cancel, can't, sputter, pen-scratch, planning).

**Out.** The woodcut look; stream-safe sound and the accessibility extras of epic 8; the public page.

**Playable at the end.** The full one-night game in gray boxes, about 21 minutes.

**Stories**

1. The planning view, its tray and its undo. (Mechanics 10; Controls and Input: planning. GD-11; UX-15 to UX-18, UX-44, UX-45, UX-55, UX-63; DW-55, DW-57, DW-58)
2. The six-wave timetable with its lulls, tolls, silence, sky and dawn. (Enemy Wave Design: the six waves, timetable; Mechanics 8: the fade from wave 4. GD-23, GD-39)
3. The carved name: the hum, the flame, reading it, the forearm. (Mechanics 7. GD-14; UX-10)
4. The one who keeps coming back. (Mechanics 7; Mechanics 1: the tune. GD-25, GD-65)
5. Calling the name, and the wrong ring. (Mechanics 7. GD-14, GD-42, GD-61, GD-64)
6. Dawn and the ledger page. (Win/Loss: dawn, the dawn ledger. GD-53, GD-59, GD-67; UX-14, UX-57, UX-62)
7. Losing, the journal page, the six hints and the replay on the last plan. (Win/Loss: a lost night, journal hints. GD-52, GD-58; UX-12, UX-13, UX-31, UX-40, UX-41, UX-54)
8. Title, sound-output question, pause, key card, settings and lesson skip. (Core Gameplay Loop; Difficulty and Replayability: settings. GD-35; UX-3, UX-4, UX-19, UX-21, UX-23, UX-24, UX-25, UX-27; UX-47 switched on, the check screen's rules UX-49 and UX-65 reused, UX-56, UX-60, UX-61, UX-64; R5's "Go on" becomes Show cues everywhere)
9. All remaining sounds in place, including the creak and groan (DW-44: judge the creak's bow then); every epic 2 stand-in (town bell, straining rope, wind, the tune) replaced by a recording and measured again. (Asset Requirements: other sounds; Audio and Music: small sounds)
10. The 6 names with their epitaphs, the 6 hints and the ally's lines are written. (Asset Requirements: text; Mechanics 8: the lines. GD-26)
11. The lesson's hands-on part and its key prompts. (Core Gameplay Loop: dusk lesson. UX-22)
12. Every screen in the Lantern light look. (Art Style: screens; `DESIGN.md`. UX-32, UX-42, UX-43, UX-66 in place of UX-34's floors; architecture AD-69; DW-21 before it)

**Delivers.** GDD Core Gameplay Loop; Game Mechanics 7 and 10; Enemy Wave Design (waves); Difficulty and Replayability. Decisions GD-11, GD-14, GD-23, GD-25, GD-35 (one-night items), GD-39 (from wave 4), GD-42, GD-52, GD-53, GD-58, GD-59, GD-61, GD-64, GD-65 (the tune), GD-67; UX-3, UX-4, UX-10, UX-12 to UX-25, UX-27, UX-31 to UX-34, UX-39 (brightness, field of view), UX-40, UX-41.

---

## Epic 6: Gate 2

**Goal.** Know whether the night is fun and whether newcomers can hold it by ear.

**In**

- The listening round, run with each newcomer before their first night. The ear re-check's pass marks apply to it.
- A playtest build that logs to a local file: each warning in waves 4 to 6 (turn, heading, section, dark or lit, called or not); each night (sections, windows, tries, length, name found, name called); and time spent on each section. It also records the headphones-or-speakers answer, the Visual cues and Holds settings for each night, the time from Begin the watch to the first cry, and every pause. This night log is supporting data.
- A fixed question sheet: play again? what felt clever?
- Five newcomers, at least two on headphones and two on speakers, playing at the default settings.
- Scoring the three checks and the ear re-check; a written outcome.
- A tuning pass on the starting values.
- If a check fails: fix the cause and run the gate again with people who have not played.
- If the ear re-check fails: the fallbacks in the GDD.

**Out.** Art.

**Needs.** Five people who have never seen the game. The ally's final recorded lines.

**Playable at the end.** The tuned night, with a gate 2 outcome document beside it.

**Stories**

1. The playtest log. (Success Metrics: the night log, shape of the sitting; Technical Metrics)
2. The question sheet and the session script, with the listening round's instruction to read aloud. (Success Metrics: gate 2, the listening round. GD-29, GD-46)
3. Five sessions run. Run by Sonlm. (Success Metrics: gate 2. GD-29)
4. The three checks and the listening round scored and written up, with the night log beside them. (Success Metrics: gate 2, the ear re-check. GD-29, GD-30, GD-40)
5. Starting values tuned from what the sessions showed. (Assumption 8; Difficulty and Replayability: target band)
6. A failed check is fixed and the gate re-run; fallbacks chosen if the ear re-check fails. (Success Metrics: gate 2, fallbacks. GD-30; IN-20)

**Delivers.** GDD Success Metrics (gate 2, ear re-check). Decisions GD-29, GD-30, GD-40 (the place score), GD-46; IN-20.

---

## Epic 7: The look

**Goal.** The proven night in its real look, at the performance targets.

**In**

- The woodcut treatment.
- Sourced models and animation: the span kit, the town and its 12 windows, the dead, the warden's arms and tools, with the forearm's ink kept clear of the hatching and the minimum brightness of epic 4 kept under the woodcut treatment; the lantern with its glass reservoir; the tally board, the ally's silhouette.
- Fog, its low setting and the fog-sprite fallback; the Fog quality setting; the cue effects.
- Measuring on a GTX 1050-class machine and an Intel Iris Xe machine.
- The look test.

**Out.** Any change to rules or numbers.

**Needs.** Gate 2 passed. Models and animation that allow commercial use. The two reference machines.

**Playable at the end.** The same night, in the woodcut look, averaging 60 FPS on the GTX 1050 machine.

**Stories**

1. The woodcut treatment over the gray boxes. (Art Style: look. IN-10)
2. The span kit and the town. (Asset Requirements: models. GD-32)
3. The dead. (Asset Requirements: models. GD-32)
4. The warden's arms, tools and forearm. (Asset Requirements: models; Art Style: no HUD at night. DW-6: the flame's carry height and lean)
5. Fog, its fallback, the cue effects, and the Fog quality setting. (Platform-Specific Details: fog; Asset Requirements: effects; Difficulty and Replayability: settings)
6. Performance on both reference machines. (Performance Requirements. GD-31)
7. The look test run and written up. Run by Sonlm. (Success Metrics: the look test)

**Delivers.** GDD Art Style; Performance Requirements. Decisions GD-31, GD-32, IN-10.

---

## Epic 8: Going public

**Goal.** The one-night game is on itch.io for Windows and Linux.

**In**

- Loudness measured one last time on the final build.
- 20 nights played back to back without a crash. The other targets checked on the final build: cold start, replay, rig reaction and download size.
- Stream-safe sound. The three clip moments, each checked in a recorded clip.
- The accessibility extras (GD-50): Cues everywhere strengthened (footsteps and bowing planks glow in the dark, a shuttered lantern's seam glow still leans, flames dip with each toll, the ally calls every warning all night); Holds: Press once, which also makes Tab a toggle; Mono sound, which suggests Cues everywhere when chosen. Frame rate is measured again with the extras on.
- The muted night: one night played with the sound off and Visual cues on Everywhere. A check, not a gate.
- Credits completed (the page exists since epic 5) and the AI-use disclosure.
- The title checked on itch.io by hand; the *LAST STAGE* demo checked for overlaps.
- The itch.io page, with the public pitch, at "$0 or donate", and its follow button; a first devlog post.
- Windows and Linux builds tested on a clean machine.

**Out.** Steam (tips are saved toward its $100 fee); a Mac build; gamepad.

**Playable at the end.** The public release.

**Stories**

1. Final loudness measurement on the final build. (Technical Metrics: the 1 LU rule)
2. The 20-night run without a crash. (Performance Requirements)
3. The start-up, replay, rig-reaction and download-size targets checked on the final build. (Performance Requirements)
4. Stream-safe sound. (Audio and Music)
5. Clip moments. (Audio and Music: clip moments)
6. Credits completed, with the AI-use disclosure. (Background and Rationale: constraints)
7. Title and overlap checks. Run by Sonlm. (Dependencies)
8. The itch.io page and a first devlog post. Run by Sonlm. (Project Goal 2)
9. Windows and Linux builds on a clean machine. (Platform-Specific Details)
10. Cues everywhere strengthened: footsteps and bowing planks glow in the dark, a shuttered lantern's seam glow leans, flames dip with each toll, the ally calls every warning all night. (Mechanics 1: cue modes. GD-50; UX-28, UX-38)
11. Holds: Press once switched on in Settings, with Tab as a toggle; its rule is epic 1's. (Controls and Input. GD-50; UX-39)
12. Mono sound, which suggests Cues everywhere when chosen. (Platform-Specific Details: sound output. GD-50; UX-39)
13. Frame rate measured again with the extras on. (Performance Requirements)
14. The muted night, run and written up. Run by Sonlm. (Success Metrics: the muted night. GD-50; UX-38)

**Delivers.** GDD Project Goal 2; Audio and Music (stream-safe sound, clip moments); Game Mechanics 1 (the cue modes); Success Metrics (the muted night). Decisions GD-50; UX-28, UX-38, UX-39 (Holds, Mono sound).

---

## Coverage

Every mechanic in the GDD lands in an epic:

| GDD mechanic | Epic |
|---|---|
| Listening: cries, side, distance, loudness, room sounds, warnings, limits | 2 |
| Visual cues for every sound | 2 (carried lantern, the gate's light), 3 (windows), 4 (hung lanterns, oil, wound), 5 (the hum; the three cue modes), 8 (the Cues everywhere extras) |
| The span: strength, load, creak, collapse, open sections, gaps | 1 |
| Stripping and re-laying; carried parts | 1 |
| Rigs: trapdoor, swing-beam; what each spring spends; night building | 4 |
| The wedge; striking a hook | 4 |
| Lanterns and light; Divers and light | 2 (carried, the gate's light), 4 (hung, oil, shutter, Divers) |
| The bell and the name; the wrong ring; the one who keeps coming back | 5 |
| The ally | 2 (calls, captions, listening lesson), 5 (the fade by wave), 8 (every warning in Cues everywhere) |
| Wounds | 4 |
| Planning from above | 5 |
| The three kinds of dead; on-deck and falling cries; windows; losing | 3 |
| The six waves and their timetable; dawn; the town bell as clock | 2 (bell), 5 (waves, dawn) |
| The dawn ledger; the six hints; replay | 5 |
| Settings: the three cue modes and the settings list | 5; Fog quality in 7; Holds and Mono sound in 8 |
| The hold rules | 1 (move, let go, impossible; the Press once rule), 4 (wounds), 5 (pause), 8 (the Press once setting) |
| The hands: ready pose, hold feedback, cancel, can't; build target; E and F by look | 4 |
| Keys by physical position; the menu keys | 1 (setup story); printed names on the key card in 5 |
| The dusk lesson | 2 (listening part), 5 (hands-on part, skip) |
| Screens: captions, the left/right check, title, first-launch question, skip question, planning tray, pause, key card, journal and lost-night page, ledger page | 2 (captions, the check), 5 |
| The targets beyond frame rate: start-up, replay, rig reaction, download size, first cry | 6 (first cry logged), 8 |
| The early listen; the listening round | 2 (built, first run), 6 (at gate 2) |
| Gate 2; the ear re-check; the camping log | 6 |
| The look test; performance | 7 |
| Stream-safe sound; clip moments; the accessibility extras; the muted night | 8 |
