---
title: The Mourning Watch - Development Epics
scope: the one-night game
created: 2026-11-19
updated: 2026-11-20
status: draft 0.8 (epic 1's stories written with acceptance criteria; readiness check fixes)
---

# The Mourning Watch - Development Epics

Eight epics for the one-night game (GD-36). Each ends in something playable. `gdd.md` holds the design; this file holds the breakdown. Screens and the night's surfaces are specified in `../../ux-designs/ux-3d_game-2026-11-19/` (UX-n IDs point to its decision log). The Fog Season is planned only after gate 2.

Sizes are rough guesses at 5 to 10 hours a week. The ear test ran from 12 to 19 November 2026 against a guess of about 2 months, but its hours were not recorded, so hours are logged from epic 1.

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

**Story detail.** Epic 1's stories are written in full, with acceptance criteria, under "Epic 1: story detail". Epics 2 to 8 have one line per story with the GDD section and decisions it delivers; each epic's stories are written in full before that epic starts. IN-n IDs are the inputs at the top of the GDD's `decision-log.md`.

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
- The bridge shows where, inside the carried lantern's light: shaking rope, falling dust, swirling fog, and the flame leaning toward the nearest cry inside its light. A cue lasts for the whole of its warning.
- The town bell, and a tally chalked at each toll.
- The dusk lesson, listening part: on a dark screen, one bell stroke to check left and right, answered Left, Right or "I can't hear it", with a key to ring again and a setting to swap the sides (the answer "I can't hear it" is recorded here; its offer of Cues everywhere is wired in epic 5, where that setting is built); then three harmless dead, one per level, the first cry within 15 s and serving as the look lesson, with walking prompted once it is faced; each cry repeats until faced, with "listen again" after each playing not faced and the place's cue shown after three; the ally confirms a right turn. The hands-on part of the lesson is built in epic 5, once the hammer and lantern exist.
- The listening round: 12 warnings from unpredictable places, 4 from each level, in the dark with no ally; scored for direction (within 45° in 4 s) and place (within 5 m in 15 s). It comes after the lesson, with no lantern and the pointer cues off; each trial ends 15 s after its warning starts. Its instruction is read aloud from the session script.
- A per-warning log: did the player turn to within 45° within 4 s; in the dark or in the light; did the ally call it.
- **The early listen** (GD-43): two or three newcomers, at least one on headphones and one on speakers, try the listening lesson and the listening round.

**Out.** What the dead do after they arrive; rigs; oil and hung lanterns.

**Needs.** Epic 1's setup and span stories. The ally's recorded lines (stand-in recordings are fine until epic 6). The original downloads of the 11 recordings. Two or three newcomers.

**Playable at the end.** The listening lesson and the listening round.

**Stories**

1. The cries are re-cut at full quality and re-measured. (Audio and Music; Asset Requirements; the 1 LU rule. IN-19)
2. The ear test's cry rules work for a walking, turning listener. (Mechanics 1: level, side, behind, room sounds. GD-7; IN-19)
3. Cries come from rails, piers and overhead, and get quieter with distance. (Mechanics 1: distance. GD-40, GD-56)
4. The four warnings play as specified, and the nest's sobs quicken. (Mechanics 1: warnings)
5. The 4-cry limit, the 1.5 s spacing and the ambience level hold. (Mechanics 1: during the night. GD-57)
6. The ally calls the level with a caption: every warning, or only the missed ones. (Mechanics 8. GD-7, GD-26, GD-39; UX-1, UX-26)
7. The bridge shows where, inside the carried lantern's light, and the flame leans. (Mechanics 1: visual cues. GD-9)
8. The town bell tolls from the town side, and the tally is chalked. (Enemy Wave Design: the toll; Mechanics 1: cue table. GD-24)
9. The listening lesson runs from the left/right check to the last cry, with feedback and the look and walk prompts. (Core Gameplay Loop: dusk lesson. GD-8; UX-20, UX-22, UX-38)
10. The listening round runs and scores direction and place. (Success Metrics: the ear re-check. GD-30, GD-46; IN-20)
11. Every warning is logged: turn, dark or lit, called or not. (Success Metrics: the night log)
12. The early listen is run and written up. Run by Sonlm. (Success Metrics: the early listen. GD-43)

**Delivers.** GDD Game Mechanics 1 and 8; the early listen in Success Metrics. Decisions GD-7, GD-8, GD-9 (carried lantern only), GD-24, GD-26, GD-39 (the rule), GD-40, GD-43, GD-56, GD-57 (warnings); IN-19, IN-20; UX-1, UX-20, UX-22 (the look and walk prompts), UX-26, UX-38 (the left/right check).

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
- Lanterns: three; one pole on each section; the lantern held over the centre of the section; one lantern in hand, hung, taken or swapped at a pole with one press, and kept lit in hand through holds and wounds; 4 m and 5 m of light; cues wherever light falls, which includes the town gate's light on section 6.
- Oil: 6-minute tanks; one spare flask that stays at the town pier and refills the lantern in hand, once; the shutter (carried and hung); the level read from the lantern's glass, a shrinking, sputtering flame in the last 60 s, and a seam glow when shuttered.
- E acts on what the warden looks at: a pole or the flask (re-laying a plank is already in epic 1). F acts on the hung lantern looked at, otherwise on the lantern in hand.
- Divers pick their section by the light rule, at the start of the warning. An open section cannot be picked, and a redirected Diver lands within sections 1 to 5 when it can. A trapdoor sprung during a Diver's 1 s drop catches it (GD-60); a Diver landing in a beam's sweep is swept off.
- Wounds: knocked down for 1.5 s; sounds on that side of the head quieter, growing to 12 dB at the side, cries also dulled, the ally's voice and the warden's hands never cut, and that side of the view darkened for 20 s (GD-62, GD-66); from the dead, the warden's own beam, a Diver's landing, or a falling section. A wound cancels a hold.

**Out.** The planning view; the full wave timetable; the name.

**Playable at the end.** One scripted wave of Grapplers, a Diver and a nest, held with a trapdoor, a swing-beam, a wedge and lanterns.

**Stories**

1. The hands show and perform the right action for what the warden looks at: ready pose, hold, cancel, can't. (Controls and Input: context hands, what the player sees and hears. GD-22; UX-2, UX-5, UX-6)
2. The trapdoor, and the plank each drop costs. (Mechanics 4. GD-18, GD-41)
3. The swing-beam, and the rope each re-hang costs. (Mechanics 4. GD-18, GD-41)
4. Building and dismantling at night, from the town-side edge. (Mechanics 4; Mechanics 3: dismantle. UX-9)
5. The wedge. (Mechanics 5. GD-17, GD-19)
6. Striking a hook. (Mechanics 3. GD-38)
7. Lanterns hung, taken and swapped at poles; cues wherever light falls. (Mechanics 6. GD-28, GD-49; UX-29, UX-36)
8. Oil, the flask at the town pier, the shutter, and reading the level. (Mechanics 6. GD-28; UX-7, UX-36)
9. Divers follow the light. (Mechanics 6: Divers and light. GD-60)
10. Wounds. (Mechanics 9. GD-27, GD-62, GD-66)

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

1. The planning view, its tray and its undo. (Mechanics 10; Controls and Input: planning. GD-11; UX-15 to UX-18)
2. The six-wave timetable with its lulls, tolls, silence, sky and dawn. (Enemy Wave Design: the six waves, timetable; Mechanics 8: the fade from wave 4. GD-23, GD-39)
3. The carved name: the hum, the flame, reading it, the forearm. (Mechanics 7. GD-14; UX-10)
4. The one who keeps coming back. (Mechanics 7; Mechanics 1: the tune. GD-25, GD-65)
5. Calling the name, and the wrong ring. (Mechanics 7. GD-14, GD-42, GD-61, GD-64)
6. Dawn and the ledger page. (Win/Loss: dawn, the dawn ledger. GD-53, GD-59, GD-67; UX-14)
7. Losing, the journal page, the six hints and the replay on the last plan. (Win/Loss: a lost night, journal hints. GD-52, GD-58; UX-12, UX-13, UX-31, UX-40, UX-41)
8. Title, sound-output question, pause, key card, settings and lesson skip. (Core Gameplay Loop; Difficulty and Replayability: settings. GD-35; UX-3, UX-4, UX-19, UX-21, UX-23, UX-24, UX-25, UX-27)
9. All remaining sounds in place. (Asset Requirements: other sounds; Audio and Music: small sounds)
10. The 6 names with their epitaphs, the 6 hints and the ally's lines are written. (Asset Requirements: text; Mechanics 8: the lines. GD-26)
11. The lesson's hands-on part and its key prompts. (Core Gameplay Loop: dusk lesson. UX-22)
12. Every screen in the Lantern light look. (Art Style: screens; `DESIGN.md`. UX-32, UX-34; architecture AD-69)

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
| Visual cues for every sound | 2 (carried lantern), 3 (windows), 4 (hung lanterns, the gate's light, oil, wound), 5 (the hum; the three cue modes), 8 (the Cues everywhere extras) |
| The span: strength, load, creak, collapse, open sections, gaps | 1 |
| Stripping and re-laying; carried parts | 1 |
| Rigs: trapdoor, swing-beam; what each spring spends; night building | 4 |
| The wedge; striking a hook | 4 |
| Lanterns and light; Divers and light | 2 (carried), 4 (hung, oil, shutter, Divers) |
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
