---
baseline_commit: 07808dc5d8c9bf7a5dbee0e0e38104cfd40ba5a5
---
# Story 1.2: The span exists and is drawn to the count

Status: review

<!-- Created 2026-11-20 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As the warden,
I want to see the bridge as six sections with their planks and rail ropes,
so that the strength of every section can be read by eye.

Delivers: GDD Game Mechanics 2 (the span's size and counts; planks as a count). GD-19, GD-54; UX-8. Architecture AD-1 to AD-4, AD-9, AD-33 to AD-35, AD-42, AD-47, AD-62.

## Acceptance Criteria

1. **The span's counts.** Given the one-night `NightDef`, when a `NightSim` is built from it, then the span has 6 sections, each 5 m long and 5 m wide, 30 m in all, with 8 planks and 2 rail ropes each: 48 planks and 12 ropes. And the warden holds none.
2. **The night is drawn from `SpanGeometry`.** Given `godot --path game -- --start=night --seed=1`, when the night scene is built, then the six sections, the far pier, the town pier and its landing are drawn as gray boxes, placed only by asking `SpanGeometry`. No coordinate of the span is typed into a `.tscn` (AD-62). This start is the third smoke run in `tools/ci.sh`.
3. **Drawn to the count.** Given a `StartState` with section 3 at 5 planks, when the scene is drawn, then section 3 shows exactly 5 planks, in the places `SpanGeometry` gives for a count of 5. A headless test finds each plank's placed position equal to `SpanGeometry`'s. (What "evenly spaced" means here: see Decision D1.)
4. **One fixed order.** Given any section, when its count goes from 8 down to 0 one plank at a time, then the planks leave in the one fixed order of `SpanGeometry` (GD-54), the same wherever the warden stands.
5. **No literal 6 or 30.** Given a `NightDef` with 4 sections, when a night is built and drawn from it, then it works with no change to any script (AD-42).
6. **One tick.** Given `NightSim.advance()`, when it is called, then it moves exactly one tick, runs the 13 numbered steps of AD-34 in order (steps with no rule yet are empty), and returns typed `NightEvent`s. The same seed and the same inputs give the same list of events, and the same state checksum, twice.
7. **Debug switches.** When the game runs with `--trace`, each event prints as one line: time, kind, who, where. `--show=list` lists the show-me setups, which so far is `--show=span_counts`.

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setup below. Follow the build order (AD-46): failing test first; constants, state, tick step, rule and events; then the view; then the bot path, the show-me setup and the manual check.

**Manual check for Sonlm** (an agent cannot fully verify this headless; never report it as verified unless judged from frames as the dev-story chores describe):
- M1 (`--show=span_counts`): sections at 8, 5, 4, 1 and 0 planks can be told apart at a glance from the landing end. This one can be judged from frames on Xvfb (`_bmad/custom/gds-dev-story.toml`, step 1); say it was llvmpipe, not a real GPU.

## Decisions for this story

Three points that neither the GDD nor the architecture settles. **Sonlm chose the recommended option for all three on 2026-11-20** (see "Decisions taken with Sonlm" in Dev Notes).

- **D1. Where the planks lie for a count.** (Recommended) **Eight fixed places, one leaving order.** Each section has 8 plank places, numbered 1 to 8 from the far-pier end. A plank never moves; stripping takes away the plank at the next place in `PLANK_LEAVE_ORDER = [3, 7, 5, 1, 8, 2, 6, 4]` (the first entry leaves first). That order keeps the rest as evenly spread as 8 places allow (worked out by search: the worst count is off the ideal spacing by about 2 places summed over all planks). Kept places per count, which the test writes out literally:

  | Count | Places kept |
  |---|---|
  | 8 | 1 2 3 4 5 6 7 8 |
  | 7 | 1 2 4 5 6 7 8 |
  | 6 | 1 2 4 5 6 8 |
  | 5 | 1 2 4 6 8 |
  | 4 | 2 4 6 8 |
  | 3 | 2 4 6 |
  | 2 | 4 6 |
  | 1 | 4 |
  | 0 | none |

  Declined alternative: re-space the planks for each count (perfectly even, but every remaining plank slides when one is taken, which in first person reads as a bug and breaks "leave").
- **D2. Gray-box sizes the GDD does not give.** (Recommended) Deck top at y = 0. Plank 5.0 m across (X) × 0.08 m thick × 0.5 m along, centred in a place 0.625 m long (5 m / 8). Two side beams per section, 0.25 m wide × 0.3 m deep, under the plank ends at the section's left and right edges, drawn whether or not planks remain (story 1.6 walks them). Rail rope 0.05 m thick at 1.0 m above the deck along each side edge, from one end of the section to the other, with a 0.1 m post at each section end, 1.1 m tall. Far pier: a box 7 m wide × 4 m along (along −4 to 0), from 20 m below the deck to 3 m above it (the warden never stands on it). Town pier: a box 7 m wide × 4 m along (along `length` to `length + 4`), from 20 m below up to the deck. **The landing** is the walkable top of the town pier: 5 m wide × 4 m along, at deck level. The warden's start is the landing's centre (`along = length + 2`), facing the far pier; eye height 1.6 m. All are starting values, tuned by eye in story 1.3's walk check.
- **D3. An event this story can emit.** (Recommended) **`NIGHT_STARTED`**, emitted once, on tick 0, in step 5 (the night clock: AD-33 puts the night's first toll on tick 0). Fields: `t` and `id` (the `NightDef`'s name, e.g. `&"one_night"`). It gives `--trace`, the determinism test and event coverage (AD-63) something real from the first story with a sim, and the playtest log a start row later. Declined alternative: no event kind until story 1.4; the trace would then be tested on hand-made events only, and the determinism test would compare empty lists.

## Tasks / Subtasks

Build order (AD-46). Do not draw anything until T1 to T5 pass.

- [x] **T1. Tests first (AC 1, 3, 4, 5, 6)**
  - [x] 1.1 `game/tests/watch/watch_test.gd`: `class_name WatchTest extends TestCase`, no `_test_` function (the runner then accepts it as a base). Helpers: `_def_with(start: StartState, sections: int = 6) -> NightDef`, `_sim_with(def: NightDef, seed: int) -> NightSim` (gives it a fresh `WatchFaults`, kept in `_faults` for the test to check), `_advance(sim, ticks) -> Array[NightEvent]` (all events of those ticks, in order), `_has(events, kind) -> bool`, `_kinds(events) -> Array[NightEvent.Kind]`.
  - [x] 1.2 `tests/watch/test_span.gd`: the counts of AC 1 (written literally: 6, 5.0, 5.0, 30.0, 8, 2, 48, 12, hand 0); `PLANK_LEAVE_ORDER` and the kept-places table of D1 written out; for counts 8 to 0, `SpanGeometry.plank_places(section, count)` gives exactly the places of the table (positions, not only how many); the same places for every section number (only the section's offset differs) and with no warden argument at all; `StartState` with section 3 at 5 planks gives `span.planks(3) == 5` and 3 planks in hand; a `StartState` with a stripped rail puts 1 rope in hand; the totals stay 48 and 12; `move_parts` with too few parts reports `span.parts_short` once (inside `_expect_begin`/`_expect_end`) and moves what there is.
  - [x] 1.3 `tests/watch/test_span_geometry.gd`: the span's numbers (architecture "The span's numbers"): section n covers along `(n − 1) × 5` to `n × 5`; `world_z = along − length`, so the town pier's edge is at z = 0 and the far pier toward −Z; `NightTypes.Side.LEFT` is −X (one test fixes left and right against world X); landing, piers and the warden's start as in D2; with a 4-section def the length is 20 and the landing starts at along 20.
  - [x] 1.4 `tests/watch/test_night_sim.gd`: `advance()` moves `sim.tick` by exactly 1; the 13 step names in order, written literally (see Dev Notes "The tick"); `NIGHT_STARTED` once on the first tick, at `t` 0.0 with the def's name, and never again; same seed + same `set_move`/`set_view`/`command` sequence twice → equal event lists (kind, `t` and every field) and equal `checksum()` after 600 ticks; a different seed gives a different `rng` state; after 600 ticks of nothing, no fault.
- [x] **T2. Constants, types, state (AC 1, 4)**
  - [x] 2.1 `watch/sim/span_constants.gd` `SpanConstants`: `SECTION_LENGTH = 5.0` and `SECTION_WIDTH = 5.0` (GD-19), metres, no suffix. Nothing else yet (strip and load times arrive with their rules).
  - [x] 2.2 `watch/sim/night_types.gd` `NightTypes`: `Side { LEFT, RIGHT }`, `Part { PLANK, ROPE }`, `HandInput { HAMMER, ROPE, USE, SHUTTER, BUILD_TRAPDOOR, BUILD_BEAM, DISMANTLE, FOREARM }` (AD-47 list; `NightCommand` needs it). `Reason`, `Level`, `DeadKind`, `Cue` arrive with their stories: do not add empty or guessed values.
  - [x] 2.3 `watch/sim/night_ticks.gd` `NightTicks`: `TICKS_PER_SECOND: int = 60` and `static func of(seconds: float) -> int` (`roundi(seconds * 60.0)`, AD-33). No duration fields yet: each arrives with its rule.
  - [x] 2.4 `watch/sim/part_place.gd` `PartPlace`: `Kind { DECK, RAIL, HAND, LOST }`, `section: int` (0 for none), `side: NightTypes.Side`; static makers `deck(n)`, `rail(n, side)`, `hand()`, `lost()`; `label()` for faults and the trace (`s3 deck`, `s3 L rail`, `hand`, `lost`). A rig is a place from epic 4.
  - [x] 2.5 `watch/sim/span_state.gd` `SpanState`: base facts only (AD-35): planks per section (`Dictionary[int, int]`, keys 1 to n), ropes per rail (`Dictionary[Vector2i, int]`, key `(section, side)`, value 0 or 1), parts in hand and lost per `Part`. Read: `section_count()`, `planks(section)`, `rail_standing(section, side)`, `in_hand(kind)`, `count_at(kind, place)`, `total(kind)`. Write: `add_at(kind, place, delta)`, called **only** by `SpanRules.move_parts()` (T2.7 test). A plank on a rail or a rope on a deck is a fault (`span.bad_place`), not a crash.
  - [x] 2.6 `watch/sim/start_state.gd` `StartState` and `watch/sim/night_def.gd` `NightDef`, `watch/sim/night_defs.gd` `NightDefs` (see Dev Notes). `NightDefs.one_night()` is the only place that writes 6 and 8.
  - [x] 2.7 `watch/sim/span_rules.gd` `SpanRules.move_parts(kind, count, from, to, sim)` exactly as architecture Novel Pattern 1 (the parts ledger). A test greps `game/watch/` for `add_at(` and finds it only in `span_rules.gd` and `span_state.gd`.
- [x] **T3. Geometry (AC 2, 3, 4, 5)**: `watch/sim/span_geometry.gd` `SpanGeometry` (see Dev Notes). Pure; built from a `NightDef`; the only source of positions and shapes; holds `PLANK_LEAVE_ORDER`.
- [x] **T4. The sim and its tick (AC 1, 6)**
  - [x] 4.1 `watch/sim/night_event.gd` `NightEvent` (all AD-30 fields, `Kind { NIGHT_STARTED }`, the `##` field list per kind) and `watch/sim/night_command.gd` `NightCommand` (`press(input)`, `release(input)`; `set_option()` arrives with Press once in story 1.4).
  - [x] 4.2 `watch/sim/night_sim.gd` `NightSim` (see Dev Notes "The tick"): built from `(def, seed, faults)`, builds its span from the def's `StartState` through `move_parts`, `set_move`, `set_view`, `command`, `advance`, `emit`, `checksum`. `NIGHT_STARTED` in step 5 on tick 0.
  - [x] 4.3 `godot --headless --path game --import` after adding the `class_name`s. Run the tests: T1 passes.
  - [x] 4.4 A test that every `NightEvent` kind's `##` comment names exactly the fields that kind sets (architecture, Event System): for `NIGHT_STARTED`, `t` and `id`.
- [x] **T5. Launch switches (AC 7)**: `watch/core/launch_options.gd`: `START_VALUES = [&"night"]`; new rows `--trace` (a flag: no value; `--trace=x` is a problem) and `--show=<name>` (any non-empty lower-snake name; whether it exists is checked by the debug tools, see Dev Notes). Update `tests/watch/test_launch_options.gd` first: the "no `--start` value exists yet" check and the `--start=night` rejection become `night` accepted; add the two new rows' good and bad forms.
- [x] **T6. The view (AC 2, 3, 5)**. Only now.
  - [x] 6.1 `tests/watch/test_span_view.gd` first: build a sim from a `StartState` (section 3 at 5 planks, one rail stripped), instance the span view, add it under `root`, call `on_tick([], sim)`, then check every plank, rail, beam, pier and landing node's `position` (and box size) against `SpanGeometry` (compare `position`, not `global_position`, or put the view in the tree first; see Latest technical notes); exactly 5 plank nodes on section 3; no rail node on the stripped side; the same on a 4-section def (4 section nodes, the landing at along 20). Free everything at the end.
  - [x] 6.2 `watch/night/span_view.gd` `SpanView` (`Node3D`) and `watch/night/section_view.gd` `SectionView` (`Node3D`): see Dev Notes "Drawing". Reconcile with state every tick (AD-49).
  - [x] 6.3 `watch/night/night.tscn` + `night.gd` (no `class_name`): root `Node3D` + script; children allowed with no place on the span: `Camera3D`, `DirectionalLight3D`, `WorldEnvironment`. Everything else built in code. `night.gd` builds the sim, the span view, places the camera at the warden's start from `SpanGeometry`, ticks in `_physics_process`, and calls each consumer `(events, sim)`; `add_consumer(c: Callable)`.
  - [x] 6.4 `watch/main.gd`: `--start=night` and `--show=<name>` open the night screen (Dev Notes "Main"); `--trace` adds the trace consumer.
- [x] **T7. Debug (AC 7)**: `watch/debug/debug_tools.gd`, `watch/debug/trace.gd`, `watch/debug/show/show_setups.gd`, `watch/debug/bot/night_bot.gd` (Dev Notes "Debug"). Tests: `tests/watch/test_trace.gd` (one `NIGHT_STARTED` prints `  0.000 NIGHT_STARTED     one_night`), `tests/watch/test_show_setups.gd` (`span_counts` exists, its def has sections at 8, 5, 4, 1 and 0 planks, and building a sim from it reports no fault).
- [x] **T8. Bot nights (AD-63)**: `tests/watch/test_bot_nights.gd`: run every bot path in `NightBot` over seeds 1 to 20 on the one-night def and on a 4-section def; on **every tick** check planks total 48 (32 on 4 sections) and ropes 12 (8) over all places, and no fault; run one seed twice and compare events and `checksum()`; at the end, every `NightEvent.Kind` value was produced at least once by some path (the event-coverage check; `NightTypes.Reason` is checked the same way once it exists in story 1.4).
- [x] **T9. CI (AC 2)**: `tools/ci.sh` (Dev Notes "CI"): each `--start` value runs with `--seed=1`; one smoke run per show-me setup listed by `--show=list`.
- [x] **T10. Docs**: `game/WATCH.md` (the `night` start value, `--trace`, `--show`, `--show=list`; what the night shows today); `_bmad-output/project-context.md` (Dev Notes "Docs").
- [x] **T11. Close**: `tools/ci.sh` passes. Fill in the Dev Agent Record. Run the end-of-story chores of `_bmad/custom/gds-dev-story.toml` (M1 on Xvfb with `--show=span_counts`, agent time, commit). Set Status to `review`.

## Dev Notes

### What this story is

The first sim. It builds the bones every later story hangs on: `NightSim` and its 13-step tick, `NightEvent`, `NightCommand`, `NightTicks`, `NightDef` + `StartState`, `SpanState` with the parts ledger, `SpanGeometry`, `WatchTest`, the night screen with a static gray-box span, `--start=night`, `--trace`, `--show`, the first bot path and the event-coverage check.

**Not in this story** (do not build ahead): walking, look, `TickBlend`, `WardenRules`, `LookRules` (1.3); strip, re-lay, holds, `HandRules`, `HoldRules`, `REFUSED`, `NightTypes.Reason`, the forearm, Press once, `set_option` (1.4); strength, load, test weights, creak, collapse, `ConsequenceRules` (1.5); open sections, gaps (1.6); the read-out, `--start=planning`, the font, `watch_theme` (1.7); `NightPlan` (epic 5); sound, lanterns, light and cues (epic 2 on). No HUD. No art: gray boxes until gate 2.

### Current state of the files this story changes (read 2026-11-20, commit `07808dc`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/main.gd` | Parses `LaunchOptions`, registers `InputActions`, builds `WatchSession`, pushes each setup problem with `push_warning`, then `_show_title` deferred (`EngineGlobals.enter_screen(MENU)`, instances the title, hands it the session). No `class_name`; types the title with `const TitleScreen := preload(...)` | Chooses title, night or a show-me setup; loads `watch/debug/` by path; adds the trace | One `WatchSession`; problems pushed once; screen changes deferred; it draws nothing and holds no rule (AD-59) |
| `game/watch/core/launch_options.gd` | One `SWITCHES` table (`--seed` INT, `--start` START); `START_VALUES = []`; `parse()` pure, never logs; `misplaced()` flags switches typed before `--`; first good value stands; `launch.<what>:` problem lines | `night` start value; `--trace` and `--show` rows; a FLAG and a NAME kind | Purity of `parse()`; problem wording style; `from_command_line()` |
| `game/tests/watch/test_launch_options.gd` | Asserts no start value exists and that `--start=night` is rejected | Those checks flip; new rows tested | Everything else |
| `tools/ci.sh` | import → purity (with self-check, `bad_bases`) → print check → tests → smoke: game, ear test → one smoke per `--start` value from `tests/print_start_values.gd` (none) → `--export` | Start values run with `--seed=1`; one smoke per show-me setup | All checks, the self-check fixture, `BAD_LINES`, argument handling |
| `game/WATCH.md` | Says no `--start` value exists; `--seed` "used from story 1.2" | Real values and switches | Structure and the rest |
| `_bmad-output/project-context.md` | CI bullet: "story 1.2 adds `night`"; Testing bullet: "story 1.2 adds `WatchTest`" | State both as done | Everything else |

`watch/sim/`, `watch/night/` and `watch/debug/` do not exist yet. The purity check already guards `watch/sim/` (it passes on an absent folder today; from this story on it runs on real files) and the print check already skips `watch/debug/`.

### The sim's files (all `extends RefCounted`, all under `watch/sim/`, all with `class_name`)

| File | Class | Holds |
|---|---|---|
| `night_sim.gd` | `NightSim` | `def: NightDef`, `geometry: SpanGeometry`, `span: SpanState`, `rng: RandomNumberGenerator` (seeded once, used only inside the sim), `faults: WatchFaults`, `tick: int`, the move wish, yaw and pitch (read-only outside the sim), the queued commands, the tick's event buffer |
| `night_types.gd` | `NightTypes` | The shared enums (T2.2) |
| `night_event.gd` | `NightEvent` | `kind`, `t`, `section`, `side`, `along`, `level`, `dead_id`, `dead_kind`, `slot`, `sound`, `reason`, `amount`, `id` (AD-30). Fields whose enum type does not exist yet (`level`, `dead_kind`, `reason`) are plain `int` with `-1` for none until their enum arrives; say so in a `##` line |
| `night_command.gd` | `NightCommand` | `Kind { PRESS, RELEASE }`, `input: NightTypes.HandInput`; static `press()`, `release()` |
| `night_ticks.gd` | `NightTicks` | T2.3 |
| `night_def.gd` | `NightDef` | `name: StringName`, `section_count: int`, `planks_per_section: int`, `start: StartState`. Plain data, built in code, never a `.tres` (AD-9) |
| `night_defs.gd` | `NightDefs` | `static func one_night() -> NightDef`: `&"one_night"`, 6 sections, 8 planks, an empty `StartState` (GD-19). The only runtime file that writes 6 or 8 |
| `start_state.gd` | `StartState` | `planks: Dictionary[int, int]` (section → planks; a missing key is full), `stripped_rails: Array[Vector2i]` (`(section, side)`). Parts a `StartState` takes off the span **start in the warden's hand**, so the ledger's totals always equal the def's (and a re-lay check in 1.4 has parts to use). Test weights arrive in 1.5 |
| `part_place.gd` | `PartPlace` | T2.4 |
| `span_state.gd` | `SpanState` | T2.5 |
| `span_rules.gd` | `SpanRules` | `move_parts()` only, for now |
| `span_constants.gd` | `SpanConstants` | T2.1 |
| `span_geometry.gd` | `SpanGeometry` | Below |

Building: `NightSim._init(def, seed, faults)` makes a full span (`section_count × planks_per_section` planks on decks, 2 ropes per section on rails, 0 in hand), then applies `def.start` by `SpanRules.move_parts()` from each deck or rail to `PartPlace.hand()`. A `StartState` naming a section outside 1 to n, or more planks than a section holds, is a fault (`span.bad_start`), clamped, and the night goes on. Nothing is emitted while building; `NIGHT_STARTED` comes on the first tick.

**Rules for every sim script** (boundary 1, CI-enforced): no `Node`, `get_tree`, `Input.`, `AudioServer`, `FileAccess`, `Time.`, `await`, any `print`; no global random call (`sim.rng.randi_range(...)` is fine); base type `RefCounted` or a class of `watch/sim/`. May name only `watch/sim/`, `watch/content/` and `WatchFaults`. Rule scripts: static functions; a function that changes state takes `sim: NightSim` last, returns nothing, reports through `sim.emit()`.

### The tick (AD-33, AD-34, AD-67)

- `tick` starts at 0. `advance()` runs the steps **for the current tick** and then adds 1. So the first call is tick 0 and its events carry `t = 0.0` (`t = tick / 60.0`). A thing begun on tick T lasting N completes on tick T + N.
  - ⚠ Story 1.5's criteria say "the overload is seen on tick 1; the section falls on tick 121". Under AD-33's "tick 0 is the sim's first tick", that is "seen on the first `advance()` (tick 0), falls on the 121st (tick 120)": the same count of calls. When 1.5 is created, write it with the tick numbers of this convention. Do not shift the clock to match that sentence.
- The 13 steps (AD-34), held as `_steps: Array[Callable]` built in `_init` and run in order by `advance()`; the test compares `_steps.map(func(c: Callable) -> StringName: return c.get_method())` with this list written literally:
  `_step_inputs`, `_step_holds`, `_step_rigs`, `_step_consequences_of_actions`, `_step_clock`, `_step_dead`, `_step_loads`, `_step_consequences_of_loads`, `_step_crossings_and_windows`, `_step_lanterns`, `_step_wounds_and_name`, `_step_voices_and_ally`, `_step_ending`.
  Each step's `##` comment gives its AD-34 number and wording. Steps with no rule yet have an empty body (`pass`) and that comment.
- `_step_inputs` stores this tick's move wish and view, and drains the command queue in arrival order (no rule reads them yet; walking is 1.3, hands are 1.4).
- `_step_clock`: on tick 0, emit `NIGHT_STARTED` with `id = def.name`.
- `set_move(direction: Vector2)` clamps to length ≤ 1 (a longer one is a fault `sim.move_too_long`, clamped). `set_view(yaw, pitch)` in radians (yaw 0 faces −Z, positive turns left; pitch 0 is level, positive up). `command(cmd)` queues for the next `advance()`.
- `emit(event)` sets `event.t` from the tick and appends to the buffer; `advance()` returns the buffer and starts a new one.
- `checksum() -> int`: a hash of `tick`, every deck, rail, hand and lost count, and `rng.state`. For the determinism test now and the replay check in epic 6 (AD-37).
- The ending step (13) has no rule until a story adds an ending; after an ending event `advance()` returns `[]`. Nothing ends a night in this story.

### SpanGeometry (AD-42, AD-47, AD-62, GD-54)

`SpanGeometry.new(def)`, held as `sim.geometry`; views reach it through the sim. Pure: no state but the def's numbers. Every number not from `SpanConstants` is a named constant here with a `##` comment ("gray-box size, D2; not a rule").

- `length() -> float` = `section_count × SECTION_LENGTH`. `world_z(along) -> float` = `along − length()`. `section_start(n)`, `section_end(n)` in `along`.
- `PLANK_LEAVE_ORDER: Array[int] = [3, 7, 5, 1, 8, 2, 6, 4]` (D1). `places_kept(count) -> Array[int]`: places 1 to 8 minus the first `8 − count` entries of the order, ascending. With a `planks_per_section` other than 8 the order cannot apply: report `span.plank_order` once and fall back to the first `count` places. (Only 8 is used; say so.)
- `plank_places(section, count) -> Array[Vector3]`: the centre of each kept plank, world coordinates. Place p's centre is at `along = section_start(n) + (p − 0.5) × SECTION_LENGTH / 8`. `plank_size() -> Vector3`.
- `rail_box(section, side) -> AABB`, `rail_posts(section, side)`, `side_beam_box(section, side) -> AABB`, `deck_box(section) -> AABB` (the deck's whole surface, for `LookRules` in 1.3/1.4), `far_pier_box()`, `town_pier_box()`, `landing_box()`, `warden_start() -> Vector3` (foot), `EYE_HEIGHT` (D2). `LEFT` is −X.
- No literal 6 or 30 anywhere: every count and length comes from the def.

### Drawing (AD-49, AD-62)

- `SpanView` (`Node3D`, a consumer): on the first `on_tick` it builds the piers, landing and one `SectionView` per section, all placed from `SpanGeometry`. Each tick it calls each `SectionView.show_state(sim, n)`.
- `SectionView`: side beams and posts always; one plank `MeshInstance3D` per kept place and one rail per standing rail. **Reconcile:** each tick it compares the places kept for `sim.span.planks(n)` with the planks it has, creates what is missing and frees what is gone (`queue_free` is fine in the night; the test uses `free()` on the whole view at the end). Never count events. Keep planks in a `Dictionary[int, MeshInstance3D]` keyed by place.
- Gray boxes: `BoxMesh` + one shared `StandardMaterial3D` per kind of part, plain colours (planks a light gray, beams and posts darker, rails lighter, piers mid-gray). Name the colours as constants in `span_view.gd` with "gray box until epic 7". No shader, no texture. A plain `DirectionalLight3D` and a `WorldEnvironment` with a black background (gaps read as `abyss`) and enough ambient light that every section can be read from the landing; real light (lanterns, fog) is epic 2 and 7.
- The camera: in this story a fixed `Camera3D` at `warden_start() + Vector3(0, EYE_HEIGHT, 0)`, facing −Z, set by `night.gd` from `SpanGeometry`. Story 1.3 replaces this with `warden.gd`. No bob, no roll.
- `night.gd` tick loop as architecture "Event System": `_physics_process` → `set_move(Vector2.ZERO)`, `set_view(0.0, 0.0)` (no warden yet) → `advance()` → every consumer. The span view is the first consumer; the trace, when on, is added by `Main`.

### Main (AD-59, AD-10, boundary 4)

- After building the session: if `options.show` is set → the debug tools (below) give the show's `NightDef`; if `options.start == &"night"` → `NightDefs.one_night()`; else the title as today. Both night paths open `night.tscn`, call its `setup(session, def, seed)` before adding it, and call `EngineGlobals.enter_screen(MENU)` (the mouse stays free until mouse look arrives in 1.3, which switches this to `FIRST_PERSON`).
- The seed: `options.seed` when given; otherwise a fresh `RandomNumberGenerator.new().seed` (a new generator is randomly seeded in 4.7.2; checked). Never `randomize()`, `randi()` or `seed()`.
- `--show` and `--start` together: `--show` wins and a setup problem `launch.conflict` says so.
- **Debug tools, by path only.** When `OS.has_feature("playtest") or OS.has_feature("editor")` (both run from source: `editor` is true there, checked on 4.7.2), `Main` does `load("res://watch/debug/debug_tools.gd")` at start, before any screen (AD-25: no `load()` during play). No `preload`, no class name of a debug script in `main.gd`. Calls go through the loaded object; check results with `is`. When debug is not allowed and `--show` or `--trace` was given: setup problem `launch.no_debug`.
- `--show=list`: the tools print the list, then `Main` quits the tree (exit code 0). An unknown show name: setup problem `launch.show: '<name>' is not a show-me setup (known: ...)`, and the title opens.

### Debug (`watch/debug/`, one-way; may print; excluded from public builds later)

- `debug_tools.gd` (`class_name DebugTools` is allowed; nothing outside `watch/debug/` and `tests/` names it): `show_names() -> PackedStringArray`, `show_def(name) -> NightDef` (null when unknown), `print_show_list()`, `make_trace() -> Callable`.
- `trace.gd` `NightTrace`: `on_tick(events, sim)` prints each event with `line(event) -> String` (pure, tested): `"%7.3f %-17s %s %s"` of `t`, the kind's name, who (`grappler#3`, `warden`, or the `id` when it is the only field, e.g. `one_night`), where (`s3 L`, or nothing). Trailing spaces trimmed.
- `show/show_setups.gd` `ShowSetups`: a table `name → [description, builder]`; this story's one row: `span_counts`, "sections at 8, 5, 4, 1 and 0 planks, seen from the landing": `StartState.planks = {1: 8, 2: 0, 3: 1, 4: 4, 5: 5}` (section 6 stays at 8). From the landing the nearest are 8 (s6), 5, 4, 1, 0, 8. `--show=list` prints `show: span_counts  <description>` per row.
- `bot/night_bot.gd` `NightBot`: bot paths as static functions `(sim: NightSim, each_tick: Callable) -> void` that drive a sim with commands and `advance()`, calling `each_tick(events, sim)` after every tick so tests check invariants per tick. This story's path, `span_counts`: build from the show's `StartState`, then 600 ticks of no input with a changing move wish and view (inputs are accepted and stored; nothing moves yet). `paths() -> Array[Callable]` lists them for `test_bot_nights.gd`.

### LaunchOptions rows (AD-61)

Keep one row per switch. New kinds: `FLAG` (no `=`; sets a bool) and `NAME` (non-empty, `[a-z0-9_]+`). Rows: `--trace` → `trace: bool`; `--show` → `show: StringName`. `START_VALUES = [&"night"]`; its comment names the ones still to come (planning in 1.7; lesson and round in epic 2). `tests/print_start_values.gd` needs no change.

### CI (`tools/ci.sh`)

- The start-value loop runs `-- "--start=$value" --seed=1` (AC 2: the third smoke run is `--start=night --seed=1`; with the game and the ear test that makes three, as architecture "Debug Tools" says).
- After it: `step "list show-me setups"` runs `"$GODOT" --headless --path game -- --show=list`, fails on `BAD_LINES`, reads names from `^show: ([a-z0-9_]+)`, fails if there are none, and smoke-runs each with `-- --show=<name> --seed=1`. (Beyond the AC: a broken show-me setup wastes Sonlm's review time.)
- Keep everything else as it is, including the purity self-check. The purity and print checks now see real files; if a check flags a sim file, fix the file, never the pattern.

### Docs

- `WATCH.md`: `--start=night` (the one-night span as gray boxes, seen from the landing; nothing moves yet), `--seed` now used, `--trace`, `--show=<name>`, `--show=list`, and that debug switches work from source and in playtest builds only.
- `project-context.md`: the CI bullet's "story 1.2 adds `night`" → the third smoke run exists (`--start=night --seed=1`), plus the show-me smoke runs; the Testing bullet's "story 1.2 adds `WatchTest`" → `WatchTest` (`tests/watch/watch_test.gd`) exists; add one line under "Rules, time and randomness": `advance()` runs the current tick then adds 1, the first call is tick 0. Update `Last Updated`.

### Project Structure Notes

```
game/watch/sim/night_sim.gd, night_types.gd, night_event.gd, night_command.gd,
              night_ticks.gd, night_def.gd, night_defs.gd, start_state.gd,
              part_place.gd, span_state.gd, span_rules.gd, span_constants.gd,
              span_geometry.gd                                   NEW (all RefCounted, class_name)
game/watch/night/night.tscn, night.gd                            NEW (no class_name; Main preloads it as a const)
game/watch/night/span_view.gd, section_view.gd                   NEW (SpanView, SectionView)
game/watch/debug/debug_tools.gd, trace.gd                        NEW
game/watch/debug/show/show_setups.gd                             NEW
game/watch/debug/bot/night_bot.gd                                NEW
game/watch/main.gd                                               UPDATE
game/watch/core/launch_options.gd                                UPDATE
game/tests/watch/watch_test.gd                                   NEW (WatchTest, no _test_)
game/tests/watch/test_span.gd, test_span_geometry.gd, test_night_sim.gd,
                 test_span_view.gd, test_trace.gd, test_show_setups.gd,
                 test_bot_nights.gd                              NEW
game/tests/watch/test_launch_options.gd                          UPDATE
game/WATCH.md, tools/ci.sh, _bmad-output/project-context.md      UPDATE
```

- Folders are created with their first file (no empty folders). `watch/core/` stays at five files: nothing new goes there.
- Each scene beside its script; scenes are thin. In `night.tscn` reference the script by `res://` path only and never invent a `uid://`. Commit the `.uid` files `--import` writes.
- No `warden.gd`, `tick_blend.gd`, `landing_view.gd` yet (1.3 and epic 2).

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, typed GDScript: type everything (`untyped_declaration=2` makes an untyped declaration a parse error); write types out, `:=` only for `const X := preload(...)`; typed arrays and dictionaries (no nested typed collections: `Dictionary[int, Array[int]]` is not allowed, hence `Vector2i` keys).
- `class_name` for every script another names by type, PascalCase matching the file; no bare generic word (AD-41). Run `--import` after adding one.
- `##` doc comment on every script and non-obvious member, saying why. Constants cite GD-n/UX-n and carry a unit suffix (metres carry none).
- No physics: no bodies, colliders, rays or areas (AD-52). No autoloads.
- Only the sim changes night state; views read state and send commands; consumers handle events first, then reconcile; they never emit or call the sim while handling one.
- Store base facts only (AD-35). Time is whole ticks. One seeded `sim.rng`. Parts move only through `SpanRules.move_parts()`.
- Sections 1 to n, never zero-based; `along` from the far pier; `world_z = along − length`; `LEFT` = −X; no literal 6 or 30 outside `night_defs.gd` and tests.
- No `print` outside `watch/debug/`; a clean run prints nothing. Faults via `WatchFaults.report`, `system.what` codes; no `assert`, no crash.
- Gray boxes until gate 2; no HUD at night; no camera bob or roll.
- Tests: set up only through a `StartState`; spec values written literally with the GDD value in a comment, never read from the constants under test; drive the sim by ticks; write only under `user://..._selftest` (this story writes no files); seeded logic over many seeds.
- Never `--no-verify`. Agents are headless: what is on screen is a manual check (here judged from Xvfb frames, see M1).

### Testing standards

- One file per system under `game/tests/watch/`, `_test_<topic>()` functions, asserting with `_check(name, ok, detail)`; files that need a night extend `WatchTest`.
- Any engine ERROR or WARNING outside an expect window fails the suite. A provoked fault is wrapped in `_expect_begin()` / `_expect_end(name, [["ERROR", "span.parts_short", 1]])`.
- A test may not `await`. View tests run synchronously: add the view under `root`, call `on_tick` directly, read `position`, `free()` the view.
- The ear test file must still report 120 passed, 23 expected. The current total is 237 passed, 0 failed, 28 expected; it only grows.

### Previous story intelligence (story 1.1, done)

- **Runner:** finds every `tests/**/test_*.gd`; a base class with no `_test_` method under another name is accepted (`_misnamed_test_files` only flags files that have `_test_` methods), and `_extends_test_case` walks the whole base chain, so `WatchTest` works as is. `get_script_method_list()` gives declaration order. A test that uses `await` or crashes inside an expect window fails the run.
- **`ConfigFile.get_value(section, key, null)` logs an ERROR** when the key is missing; use a typed default.
- **`"99999999999999999999".is_valid_int()` is true** and `to_int()` then errors; `LaunchOptions` already guards seeds over 18 digits. Keep that path for `--seed`.
- **`DisplayServer.keyboard_get_label_from_physical()` errors headless**; `InputActions.key_name` already guards it. The night shows no key names in this story.
- **Smoke runs fail on any WARNING line**, so a clean start (including `--start=night` and every `--show`) must push no warning at all.
- **Release templates refuse a scene path on the command line**; irrelevant here (no export changes), but don't route `--start` through a scene path.
- **The Xvfb chore template** puts engine flags before `--` and launch switches after: `xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --write-movie <dir>/frame.png --fixed-fps 30 --quit-after 60 -- --show=span_counts`.
- **Code review of 1.1** widened the purity check (`Node`, `Timer`, `SceneTree`, `seed(`, `randfn(`, `randomize(` anywhere, base types). Write sim code that would pass it from the first line; the self-check fixture already shows `sim.rng.randi_range(...)` and `sim.rng.seed` pass.
- Decisions an agent took in 1.1 were listed in Completion Notes as "restrictive reading; Sonlm may revisit". Do the same here for anything this story does not settle.

### Git intelligence

Branch `ear-test-prototype` (detached HEAD at `07808dc` at story creation). Last commits: `07808dc` (1.1 manual-check note), `b1335b6` (1.1 code review fixes), `05124dd` (1.1), `10cad8d` (1.1 ready for dev), `555918b` (readiness fixes, sprint plan). Pattern: one commit per story step, message `Story 1.2: <what>`, the pre-commit hook runs `tools/ci.sh`. Commit on the current branch (if HEAD is detached, ask Sonlm or create a branch rather than committing to nothing).

### Latest technical notes (Godot 4.7.2, checked on this server 2026-11-20)

- An empty `enum` parses and has size 0. Not needed: D3 gives `NightEvent.Kind` a value, and `NightTypes.Reason` waits for story 1.4.
- Run from source, `OS.has_feature("editor")` and `"editor_runtime"` are true and `"template"` false: debug tools are available in the smoke runs and in `godot --path game`.
- A new `RandomNumberGenerator` is randomly seeded (its `seed` is not 0); no `randomize()` needed for the night's seed when `--seed` is absent.
- `MeshInstance3D` + `BoxMesh` + `StandardMaterial3D` build and free headless with no error. **`global_position` on a node not yet in the tree logs `ERROR: Condition "!is_inside_tree()"`**, which fails the suite: compare `position` (the view's children are placed relative to a view at the origin), or add the view under `root` first. Tests run on the first frame, when `root` is in the tree.
- No new library or version: nothing outside Godot 4.7.2 is used.

### Decisions taken with Sonlm (2026-11-20, at story creation)

1. **D1:** eight fixed plank places, leaving order `[3, 7, 5, 1, 8, 2, 6, 4]`. A plank never moves. AC 3's "evenly spaced" means the kept places of D1's table.
2. **D2:** the gray-box sizes as proposed, as starting values to tune by eye in story 1.3's walk check.
3. **D3:** `NIGHT_STARTED` on tick 0, in step 5, with `t` and `id`.

Also settled here without a question (the architecture already decides it): `advance()` runs the current tick and then adds 1, so the first call is tick 0 (AD-33). Story 1.5's "tick 1 / tick 121" is the same count of calls and gets rewritten in this convention when 1.5 is created.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1; "Epic 1: story detail" (its preamble on build order, ticks and sound); "Story 1.2"; stories 1.3 to 1.7 for what must not be built here
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Game Mechanics 2 "The span" and 3; Level Design Framework (the landing's contents)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-19, GD-54, GD-68, GD-69
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/.decision-log.md`: UX-8; `DESIGN.md` span-section (planning colours, for 1.7)
- `_bmad-output/game-architecture.md`: Decision Summary (AD-1 to AD-4, AD-9, AD-11, AD-13, AD-25); Time (AD-33); Order inside a tick (AD-34); Base facts (AD-35); Error Handling (AD-28, AD-36); Logging (AD-29, the trace format); Event System (AD-30, AD-67); Debug Tools (AD-31, show-me setups, bot nights, three smoke runs); Directory Structure; System Location Mapping; Naming Conventions and "The span's numbers"; Architectural Boundaries 1, 2, 4, 5; Novel Pattern 1 (the parts ledger); Communication and Entity Patterns (reconcile, AD-49); Data Patterns; The shape of a rule script; The shape of a test; build order (AD-46); Consistency Rules; Built when (AD-54); Additions from the Round Table (AD-56, AD-61, AD-62, AD-63); AD-67 (the warden's inputs)
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-1-the-game-starts-beside-the-ear-test.md`: Dev Notes, Review Findings, Completion Notes
- Code as of `07808dc`: `game/watch/main.gd`, `game/watch/core/*.gd`, `game/tests/run_tests.gd`, `game/tests/test_case.gd`, `game/tests/watch/test_launch_options.gd`, `tools/ci.sh`, `game/WATCH.md`, `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), gds-dev-story, 2026-11-20.

### Debug Log References

- Red phase confirmed: the four new test files failed to load before any sim code (236 passed, 4 failed); the launch-options tests failed (19) before the FLAG and NAME rows existed.
- One test bug fixed on the way: the determinism test's move wish (`sin`/`cos` at two frequencies) went over length 1 and tripped `sim.move_too_long`; the input now stays within 1.
- `tools/ci.sh`: all checks passed, 368 passed, 0 failed, 34 expected (was 237 / 28). The ear test file still reports 120 passed, 23 expected. The purity check now runs on the 13 real files of `watch/sim/`.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-20).
- **Sim (T2 to T4):** `NightSim` with the 13 steps of AD-34 as `_steps` (empty steps carry their AD-34 number and wording); `advance()` runs the current tick then adds 1; `NIGHT_STARTED` in step 5 on tick 0 with `id = def.name`; `emit()`, `checksum()` (tick, `rng.state`, every deck, rail, hand and lost count). `SpanState` stores base facts only; `SpanRules.move_parts()` is the only caller of `add_at()` (a test greps for it). `SpanGeometry` holds `PLANK_LEAVE_ORDER` and every gray-box size of D2 as a named constant; nothing writes 6 or 8 outside `night_defs.gd` and tests.
- **View (T6):** `SpanView` builds the piers, landing and one `SectionView` per section on the first tick; each `SectionView` reconciles planks (keyed by place) and rails with state every tick and never counts events. `night.tscn` holds only the camera, a light and the environment; `night.gd` places the camera at `warden_start()` + eye height.
- **Debug (T7, T8):** `DebugTools`, `NightTrace`, `ShowSetups` (`span_counts`), `NightBot` (`span_counts` path). `Main` loads `debug_tools.gd` by path only when `editor` or `playtest`; `--show=list` prints and quits; `launch.conflict`, `launch.show`, `launch.no_debug` are setup problems.
- **Choices this story did not settle (restrictive reading; Sonlm may revisit):**
  1. **Bot path signature.** Dev Notes give `(sim, each_tick) -> void` but also say the path builds its night from the show's `StartState`. A path is therefore `(def, seed, faults, each_tick) -> NightSim`: it puts its own `StartState` on the given def (the one night or the 4-section def), builds the sim, runs 600 ticks and returns it. On 4 sections the show's start drops section 5.
  2. **`SpanGeometry` takes the night's `WatchFaults`** (`SpanGeometry.new(def, faults)`) so it can report `span.plank_order` once, at construction, as the story asks. It holds no other state.
  3. **`move_parts()` checks both places first.** The architecture's code would subtract from `from` and then refuse `to` for a plank sent to a rail, losing a part; the guard reports `span.bad_place` and moves nothing. The rest of the function is the architecture's code unchanged.
  4. **Extra fault codes:** `span.bad_section` (reading planks or a rail of a section that does not exist), `span.bad_start`, `sim.move_too_long` (with a 0.00001 slack for float rounding).
  5. **The landing is drawn as a 0.01 m slab** on the town pier's top (`SpanView.LANDING_MARK_THICKNESS`): `SpanGeometry.landing_box()` is a surface with no height, as D2 describes it.
  6. **`NightTrace.line()`** writes who as the event's `id` and where as `sN`; the dead, the warden and the side join with the events that carry them.
  7. **CI step labels** widened from 36 to 46 characters so the longer smoke-run names line up.
- **Manual checks:**
  - M1: verified on a virtual display only in part (`/tmp/claude-1000/-home-sonlm-project-3d-game/468a2678-e3e1-470d-84a4-565629deff5f/scratchpad/M1/frame00000059.png`, and the enlarged far half `crop_far.png` beside it; Forward+ on llvmpipe, CPU Vulkan, not a real GPU). From the landing, section 6 (8 planks) and section 5 (5) tell apart at a glance. Sections 4 (4), 3 (1) and 2 (0) lie 15 to 25 m away and take 20 to 40 px each. Their gaps show the far pier's gray face (it rises 3 m above the deck, D2) instead of black, so 4, 1 and 0 can be counted using the posts but do not read "at a glance". **NOT verified as passing; needs Sonlm on a real screen.** If it reads the same there, levers for story 1.3's walk check (where D2's sizes get tuned by eye): a lower far pier, so the abyss shows through gaps; more contrast between planks and the void.
- Agent time: 2026-11-20 17:24 +0700 to 2026-11-20 17:34 +0700 (0 h 10 min), measured by the agent.
- Sonlm's own time: ___ (for Sonlm to fill in).

### File List

New:
- `game/watch/sim/night_sim.gd`, `night_types.gd`, `night_event.gd`, `night_command.gd`, `night_ticks.gd`, `night_def.gd`, `night_defs.gd`, `start_state.gd`, `part_place.gd`, `span_state.gd`, `span_rules.gd`, `span_constants.gd`, `span_geometry.gd` (each with its `.uid`)
- `game/watch/night/night.tscn`, `night.gd`, `span_view.gd`, `section_view.gd` (scripts with their `.uid`)
- `game/watch/debug/debug_tools.gd`, `trace.gd`, `show/show_setups.gd`, `bot/night_bot.gd` (each with its `.uid`)
- `game/tests/watch/watch_test.gd`, `test_span.gd`, `test_span_geometry.gd`, `test_night_sim.gd`, `test_span_view.gd`, `test_trace.gd`, `test_show_setups.gd`, `test_bot_nights.gd` (each with its `.uid`)

Modified:
- `game/watch/main.gd`
- `game/watch/core/launch_options.gd`
- `game/tests/watch/test_launch_options.gd`
- `game/WATCH.md`
- `tools/ci.sh`
- `_bmad-output/project-context.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-11-20: Story 1.2 implemented: the first `NightSim` with its 13-step tick, the parts ledger, `SpanGeometry`, the gray-box span drawn to the count, `--start=night`, `--trace`, `--show` with `span_counts`, the first bot path and the event-coverage check, CI smoke runs per start value and show-me setup. 368 tests pass. Status → review.
