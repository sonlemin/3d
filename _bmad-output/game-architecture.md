---
title: 'Game Architecture'
project: '3d_game'
game: 'The Mourning Watch (working title), the one-night game'
date: '2026-11-20'
author: 'Sonlm'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Godot 4.7.2 (pinned), Forward+, typed GDScript'
platform: 'Windows 10/11 x64 and Linux x86-64 (itch.io)'
decisions: 'AD-1 to AD-68'

# Source Documents
gdd: '_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md'
epics: '_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md'
brief: '_bmad-output/planning-artifacts/briefs/brief-3d_game-2026-11-12/brief.md'
ux: '_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/'
project_context: '_bmad-output/project-context.md'
---

# Game Architecture

## Executive Summary

**The Mourning Watch** (the one-night game) is built in Godot 4.7.2 for Windows and Linux, inside the existing `game/` project beside the closed ear test, by AI agents working without a screen or speakers.

**Key architectural decisions**

- **The night is a simulation.** One node-free `NightSim` owns every rule and all state of a night, including the warden's walking, what the warden is looking at, which cries sound and when the ally calls. It moves in whole ticks, 60 a second, from one seed. Nodes send it a move wish, a view and button presses, and draw and play what it reports as an ordered list of events (AD-1 to AD-3, AD-32, AD-47, AD-52).
- **A night is thrown away and rebuilt** from a `NightDef` (its content) and a `NightPlan` (the planning result, a list of actions), so nothing carries over (AD-4, AD-9, AD-23).
- **Sound is authored, not left to the engine.** Four cry slots with their own filters, loudness set by rule, and a table that ties every sound to its visual cue (AD-5 to AD-7, AD-45).
- **What agents cannot see or hear is either provable or routed to Sonlm.** Bot nights with invariants and event coverage prove the rules; a show-me setup per story puts Sonlm in front of the rest (AD-56, AD-63).
- **The ear test stays whole.** Same project, nothing of its own edited, nothing of it used by the game (AD-12, AD-39, AD-43, AD-65).

**How to read this document.** It was built in passes, and later sections amend earlier ones; an amended decision says so in its row. The Decision Summary is the index. Where an early passage and a later one seem to differ, the later one and the section "Architecture Validation" hold.

**Project structure:** all game code under `game/watch/`, grouped by system, with the rules in `watch/sim/` behind a boundary that CI enforces.

**Implementation patterns:** 5 novel and 7 standard, a fixed build order for every story, and 18 consistency rules, 15 of them enforced by CI, a test or the engine.

**Ready for:** refreshing `project-context.md`, then the readiness check, then epic 1.

---

## Document Status

Complete. Created through the GDS Architecture Workflow on 2026-11-20: 9 of 9 steps, with elicitation and a round-table review on every section and two independent validation reads.

---

## Project Context

### Game Overview

**The Mourning Watch** - a free, single-player tower defense game played up close and by ear. By day the warden plans from above and strips the bridge for parts; by night the warden stands on the deck in first person, listens for the dead, and springs rigs by hand until dawn. Scope of this document: the one-night game (one span, one sitting of about 21 minutes). The Fog Season is a growth constraint, not a deliverable.

### Technical Scope

**Platform:** Windows 10/11 x64 and Linux x86-64, itch.io, keyboard and mouse, stereo output
**Engine:** Godot 4.7.2 pinned, Forward+, typed GDScript, no addons
**Genre:** Tower defense with horror sections
**Project Level:** Medium-high (small content, dense interacting rules, solo, built by AI agents working headless)

### Core Systems

| System | Complexity | GDD reference |
|---|---|---|
| Span: sections, planks, rails, load, creak, collapse, open sections, gaps | High | Game Mechanics 2, 3 |
| Cry audio: level buses, rear shadow, distance loudness, 4-cry limit, warnings built from clips | High | Game Mechanics 1 |
| The dead: Grappler, Diver, nest and hatchlings, the one who keeps coming back | High | Enemy Wave Design |
| Hands: look-at context actions, holds, cancel, "can't", Press once | High | Controls and Input |
| Where things are and what is looked at (shared geometry, the 2 m rule, "the section ahead") | High | Controls and Input; UX-5, UX-9 |
| What follows when the span changes under something | High | Game Mechanics 2, 4 ("what falls with it") |
| Which cries sound: the 4-cry limit, slots, cut and skip | Medium | Game Mechanics 1 |
| Night clock: six waves, timetable, tolls, lulls, dawn, pause | Medium | Enemy Wave Design |
| Rigs: trapdoor, swing-beam, wedge, hook strike | Medium | Game Mechanics 4, 5 |
| Lanterns, oil, light areas, Diver targeting | Medium | Game Mechanics 6 |
| Visual cues in three modes, tied to light | Medium | Game Mechanics 1 |
| Planning view: strip, place, undo, start over, restore the last plan | Medium | Game Mechanics 10 |
| Ally: call rules by wave and cue mode, captions | Medium | Game Mechanics 8 |
| The name, the hum, the bell, the wrong ring | Medium | Game Mechanics 7 |
| Sitting flow: title, lesson, planning, night, dawn or loss, replay | Medium | Core Gameplay Loop |
| Playtest log, listening round, scoring | Medium | Success Metrics |
| Wounds: knockdown, one-sided hearing and view | Low | Game Mechanics 9 |
| Town windows, crossings, loss, hint choice | Low | Win/Loss Conditions |
| Settings and what persists (settings, lesson-done flag) | Low | Difficulty and Replayability |
| Screens in the Lantern light look | Low | UX `DESIGN.md` |

### Technical Requirements

- 60 FPS average (1% lows 45) on a GTX 1050-class card at 1080p with low fog; 30 FPS (1% lows 24) on Intel Iris Xe at 720p with the fog-sprite fallback. Peak scene: 18 dead, 3 lanterns, fog, 4 cries.
- A sprung rig reacts within 0.3 s. A lost night replays within 3 s. Cold start to menu within 10 s. Download 300 MB or less. 20 nights back to back with nothing carried over.
- Any two cries at the same distance within 1 LU. No threat affects the bridge before its full warning has sounded.
- No network and no save file: only settings and the lesson-done flag persist between launches.
- Everything timed must freeze on pause and be drivable by tests without a screen or speakers.
- Comfort limits (`EXPERIENCE.md`, Accessibility Floor): no full-screen flash, no screen shake, no camera bob or roll, nothing flickering faster than 3 times a second, full-view changes as slow fades. They bind every effect and every view.

### Complexity Drivers

**High complexity**

- Rule interactions: one event (a section falls, a trapdoor drops, a rail locks) changes what the dead, rigs, lanterns, holds and the warden may do in the same moment.
- Deterministic time: about 20 kinds of timed rule share one pausable, testable clock.
- Audio as gameplay: designed distance loudness, a voice limit and a dropping order, none of which Godot's default 3D audio provides.

**Novel concepts (no standard pattern)**

1. The base is the budget: the span is map, health, currency and path at once.
2. Play by ear: spatial audio with authored rules, and a visual cue for every sound that exists only where light falls, in three modes.
3. No HUD: the hands are the interface, so the action picker must explain itself through poses alone.
4. The plan is data: a planning result that can be undone, started, and restored after a loss while the name is rolled again.

### Technical Risks

| Risk | Where it bites |
|---|---|
| Rules spread across node scripts become untestable headless | Every epic |
| State leaking between nights (20-night target, 3 s replay) | Epics 5 and 8 |
| Godot's audio falloff and panning fighting the designed cues | Epic 2 |
| Fog cost on integrated graphics; neither reference machine in hand (DW-12) | Epic 7 |
| GDD assumption 11: the mono fold-down and the channel swap in 4.7.2 are unproven (AD-18). Its part about keys is closed by AD-20 | Epics 2 and 8 |
| The game must sit beside the closed ear test without changing it | Epic 1 |
| Fog Season growth: several spans, saving, gamepad, a fourth enemy | After gate 2 |
| Front-loaded infrastructure: the sim, shared geometry, the test runner split and the CI checks come before epic 1's first playable. See Staging | Epic 1 |
| Sourced models must fit `SpanGeometry` (5 m sections, fixed places for pins and poles), which narrows the free kits that can be used | Epic 7 |
| CI is headless: it sees no rendering and hears no sound. A broken shader or a wrong mix passes it | Epics 2 and 7 |
| Sonlm's review time (5 to 10 hours a week) is the scarcest resource: agents can finish stories faster than their look, sound and feel can be checked. See show-me setups (AD-56) | Every epic |

### Gaps found in GDD draft 0.6 (DW-4)

None blocks architecture. Gaps 1 to 5 are settled here; 6 and 7 are deferred on purpose (AD-55).

1. The GDD says nothing in the night is random except the Grappler's rail and the name's place, but the deck-hook edge, the wound side on a fall, and which of the 6 names are also rolled.
2. The 4-cry limit says which cries are dropped first, but not what happens to a dropped cry's 8 s repeat, or whether the tune and the hum count toward the limit.
3. "Replay within 3 s" and "a new run each night" mean a night is rebuilt from the saved plan. The GDD does not say whether oil and the flask reset on replay.
4. Hints last "for as long as the game is running"; leaving to the title is not defined as keeping or clearing them.

Gap 2 is settled by AD-7; gaps 1, 3 and 4 by AD-26. Three more were found later in the workflow:

5. Loss and dawn on the same tick: settled by AD-34 (dawn wins).
6. A Diver whose picked section opens or falls during its 1 s drop, after its warning has ended. Open: to be put to Sonlm as options when epic 3 story 3 is created.
7. Whether a Grappler still hanging from its hook stands still for the 20 s after the name is called. Open: to be put to Sonlm as options when epic 5 story 5 is created.

---

## Engine & Framework

### Selected Engine

**Godot 4.7.2 stable** (pinned), Forward+ renderer, typed GDScript.

**Rationale:** fixed constraint (Sonlm builds in Godot only). Forward+ is required by volumetric fog. 4.7.2 was verified as the current 4.7 maintenance release on 2026-11-20. The engine is upgraded only between epics, never inside one, and the loudness table is re-verified afterwards.

### Project Initialization

None. The game grows inside the existing `game/` project that holds the closed ear test. No starter template and no addons.

### Engine-Provided Architecture

| Component | Solution | Notes |
|---|---|---|
| Rendering | Forward+, volumetric fog, one OmniLight3D per lantern | Fog needs a low setting and a sprite fallback. Godot 4.7.2 falls back to the OpenGL (Compatibility) renderer by itself when Vulkan and D3D12 fail (`fallback_to_opengl3` is on by default, checked 2026-11-20): see AD-57 |
| Physics | Not used in the night (AD-52) | The physics tick is the sim's clock; no bodies, colliders or rays. Walking and looking are rules |
| Audio | AudioServer buses and effects, AudioStreamPlayer3D | Falloff and voice limits are the game's, not the engine's |
| Input | InputMap actions with physical keycodes | Printed key names via the DisplayServer keyboard lookup (GDD assumption 11) |
| Scenes | Scene tree, PackedScene instancing | No autoloads (AD-10) |
| UI | Control nodes, Theme, bundled font | Lantern light look from `DESIGN.md` |
| Persistence | ConfigFile under `user://` | Settings and the lesson-done flag only |
| Build | Export presets for Windows and Linux, `tools/ci.sh` | Local CI through the pre-commit hook |
| Tests | Own headless runner (`tests/run_tests.gd`) | The framework question is decided below |
| What CI cannot see | Rendering and real audio output | Headless runs draw nothing and play nothing: shaders, the look, panning and the mix are manual checks for Sonlm, listed in each story |

### AI Tooling (MCP)

None (decided 2026-11-20). Agents work headless on a server; the Godot MCP servers reviewed (GoPeak and others) drive a running editor through editor plugins, which the no-addons rule excludes. The verification loop is text scenes, `--import`, the test runner and the smoke runs.

### Remaining Architectural Decisions

1. Where the rules live: one simulation model of the night, or rules per system
2. How systems talk: direct calls, signals, an event list from the simulation
3. Time, pause and determinism; the seeded random source and what it rolls
4. Night lifecycle: build, reset, replay from a stored plan
5. The dead: representation, movement on the span, spawning or pooling
6. Audio: distance loudness, voice limit, warnings, ambience, wound and mono effects
7. Hands: how the action under the look is chosen and how holds run
8. Light and visual cues in three modes
9. Data: constants versus tuning files; timetable, names, hints and lines as data
10. Flow between title, lesson, planning, night and dawn; autoloads and `class_name`
11. Input action map; settings storage
12. Playtest log and build variants (public versus playtest)
13. How the game sits beside the ear test; folder layout; test file split

---

## Architectural Decisions

Decision IDs are AD-n. AD-1 to AD-12 and AD-27 were chosen by Sonlm from option lists on 2026-11-20 (each was the facilitator's recommendation). AD-13 to AD-26 are defaults that follow from those or from the engine, accepted as a set. No technology beyond Godot 4.7.2 is introduced, so there are no other versions to verify.

### Decision Summary

| ID | Category | Decision | Rationale |
|---|---|---|---|
| AD-1 | Rules | One node-free `NightSim` owns all night state and rules. Nodes send facts and commands, and draw. | Rule interactions are this game's main risk; they must sit where headless tests reach |
| AD-2 | Communication | `NightSim.advance()` returns an ordered list of typed `NightEvent`s. Audio, views, captions and the log read the same list. | One ordered source; tests assert on it; the fairness metric and night log fall out of it |
| AD-3 | Time | Fixed 60 Hz tick driven from `_physics_process`. One seeded `RandomNumberGenerator` for every roll; the seed is logged. | Timed rules resolve the same on every machine; a seed plus inputs reproduces a night |
| AD-4 | Night lifecycle | Each night: a new `NightSim` and a freshly instanced night scene, built from a stored `NightPlan`. The old ones are freed. | Nothing survives, so nothing leaks (20-night target); the scene is preloaded (3 s target) |
| AD-5 | Audio voices | Four cry slots, each a bus with its own rear-shadow and wound filter, routed per cry into the level's room bus. Separate slots for falling cries and the hum. The game loads its own bus layout. | Godot effects live on buses, so a per-cry filter needs a per-cry bus; the 4-cry limit becomes physical; the ear test's layout is untouched |
| AD-6 | Distance loudness | 0.6 dB per metre of distance along the span, capped at 15 dB. Engine attenuation is off. | No jump at section edges; height never hints at level; one pure function is both played and tested |
| AD-7 | 4-cry limit | A warning holds a slot for its whole length and may cut the farthest deck cry (0.1 s fade). A deck cry without a slot skips to its next 8 s mark; nearest dead first. Falling cries are outside the limit, but at most three sound at once; more falls in the same moment share them. The tune is a cry like any other: its warning holds a slot and its deck repeats count. The hum is outside the limit. A warning starts only when 1.5 s have passed since the last warning started and a slot can be had; otherwise it waits, and the whole threat waits with it (owned by `wave_rules`, which asks `voice_rules` for the slot). | No threat's warning is ever delayed by a deck cry (fairness); the 8 s rhythm is kept |
| AD-8 | Views of the dead | Instanced through one `DeadViews` factory when one of the dead first has a body (its hook lands, it dives, it hatches), freed when it is gone. Pooling is decided in epic 7 by measurement. | Gray boxes cost nothing; the seam makes a pool a local change |
| AD-9 | Data | Rule numbers are named constants per system. A night's content is a `NightDef` built in code and passed to `NightSim`. | Tuning stays in git with its GD-n; `NightDef` is the Fog Season's growth seam |
| AD-10 | Globals | No autoloads. `Main` owns the flow and hands one `WatchSession` to each screen. | Screens stay testable; nothing global loads with the ear test |
| AD-11 | Script references | `class_name` for game scripts. The ear test keeps its preload constants. | Typed arrays and two-way references across 60 or more scripts |
| AD-12 | Ear test | Same Godot project. The main scene becomes the game; the ear test's presets select its scene by feature tag. Amended by AD-39 and AD-65: the game has its own cry clips, loudness table, loudness tool and cry library, and uses nothing from the ear test's scripts. | CI is reused directly; ear test behaviour is unchanged |
| AD-13 | The warden | Amended by AD-52: the sim moves the warden always. The node sends a move direction and the view direction, and follows the sim's position. | Where the warden may stand is a rule that changes all night |
| AD-14 | The dead | No physics and no navigation mesh: a position along the span, a side lane, and one `DeadState.Phase` enum in the sim; each kind's rules use the phases they need. | The span is one line; 18 bodies need no physics |
| AD-15 | Hands | The sim works out the look target itself from the warden's position and view direction (amended by AD-47: no physics ray); a pure `HandRules` picks the action for each input; holds run inside the sim. | Pause, cancel, "can't", Press once, the 2 m rule and "the section ahead" share one implementation and are testable headless |
| AD-16 | Light and cues | "Lit" is distance math in the sim (4 m carried, 5 m placed, the gate on section 6). Lights only draw. A pure `CueRules` answers whether a cue shows, per cue mode. | Diver targeting and cue visibility must not depend on the renderer |
| AD-17 | Wounded ear | Per cry: a source on the wounded side is 12 dB quieter and cut above 1 kHz in its slot. Ambience is ducked on that side by pan. | Reads the GDD's "everything on that side" as sources on that side; uses the slot filters of AD-5 |
| AD-18 | Mono and swap | One `AudioEffectStereoEnhance` on Master: `pan_pullout` 0 for Mono sound, −1 to swap left and right. Proven by a measurement test in epic 2 before the lesson relies on it. | No addon; Godot 4.7.2 accepts both values (checked 2026-11-20); the sound itself is unverified |
| AD-19 | Pause | The sim is not ticked; the tree is paused and only the pause overlay keeps processing; the game's buses are muted. Detailed by AD-67. | UX-24: everything stops and falls silent, including reverb tails |
| AD-20 | Input | Actions are registered in code from one table of physical keycodes. Key names are shown through `DisplayServer.keyboard_get_label_from_physical`. | `project.godot` stays shared with the ear test; closes GDD assumption 11 for keys |
| AD-21 | Persistence | One `ConfigFile` under `user://`: settings and the lesson-done flag. | The one-night game has no save |
| AD-22 | Lesson and listening round | The same `NightSim` with their own `NightDef`s. | No second rule set to keep in step |
| AD-23 | Planning | A `NightPlan` is an ordered list of `PlanAction`s. A pure `PlanEditor` replays it on a fresh span and returns a `PlanResult` (the span, rigs and lanterns, or the refusal). Undo and Start over edit the list. One span view draws planning, night and dawn. | Undo, Start over and "restore the last plan" are data operations |
| AD-24 | Builds | One codebase; export feature tags `playtest` and `eartest`. Amended by AD-53: the playtest log and recordings are written only with the `playtest` feature or the `--log` switch; editor and CI runs write nothing. Debug tools are available in editor runs. | No branch per build; a smoke run must not write files |
| AD-25 | Loading | Everything is preloaded once behind the title. No `load()` during play. | Small game; 10 s start and 3 s replay targets |
| AD-26 | GDD gaps | A replay resets oil and the flask. Journal hints survive a return to the title and clear on quit. Every roll (rail, deck edge, wound side on a fall, name, its section) comes from the night's seed. | Plainest reading of GD-52 and UX-41 |
| AD-27 | Tests | Own runner, no framework: one test file per system, and the runner finds every `_test_` function itself. The ear test's tests move to their own file unchanged. | Removes the silent-skip trap without an addon |

### State Management

**Approach:** one simulation object per night (AD-1), a flow state machine in `Main` (AD-10).

- `NightSim` (`RefCounted`) holds the span, the dead, rigs, lanterns, oil, windows, wounds, the hold in progress, the wave clock and the name. It makes no engine calls: no nodes, no files, no audio, no global random functions.
- **In:** `set_move(direction)` and `set_view(yaw, pitch)` once per tick (types in AD-67); `command(cmd)` for each press and release. Nothing else enters the sim (AD-52).
- **Out:** `advance()` moves one tick (AD-33) and returns `Array[NightEvent]` in the order things happened. State is read through typed fields.
- **Views never write sim state.** A view that needs something to change sends a command.
- `Main` holds the flow: title, first-launch questions, lesson, planning, night, dawn, lost night. It owns the `WatchSession` (settings, journal hints, lesson-done flag, the last `NightPlan`, the `PlaytestLog`).

### Data Persistence

**Save system:** none. `ConfigFile` at `user://` for settings and the lesson-done flag (AD-21). The playtest log is written to `user://` as CSV, one flushed row per event, never overwritten (AD-24).

The Fog Season's save (dawn as the save point) is expected to serialise `WatchSession` plus a season state. `NightPlan` and `NightDef` are plain data so that this stays possible; nothing is built for it now.

### Asset Management

**Loading strategy:** preload all at start (AD-25). Cry streams are discovered and loaded once by `WatchCryLibrary` (AD-65), in the way the ear test's library does today. The night scene is a preloaded `PackedScene` instanced per night (AD-4).

### Audio Architecture

- **Bus layout (the game's own file, loaded at start by `SoundSetup`, which `EngineGlobals` calls):** `CrySlot1..4`, `FallSlot1..3` and `Hum` each carry a high-shelf (rear shadow) and a low-pass (wound). Each slot's send is switched to `Above`, `Inside` or `Below` when a cry takes it. The level buses carry the room sound and send to `Cries`, which sends to Master. `Ambience`, `Ally`, `Bridge`, `Town`, `Hands` and `Screens` send to Master. Slot buses sit to the right of the level buses, because a bus can only send leftwards.
- **`CryMix` (pure):** given listener position and facing, source position, level, clip and wounds, returns gain in dB, shelf gain, and low-pass cutoff. Gain = the clip's measured gain from `loudness.json` + distance (AD-6) + rear shadow + wound (AD-17). Players use `ATTENUATION_DISABLED`; the engine only pans.
- **The voice allocator is a rule inside `NightSim`** (AD-32): it owns the slot table and applies AD-7, because which cries are sounding decides when the hum is heard and where a flame leans. It emits `CRY_STARTED` (with its slot), `CRY_CUT` and `CRY_SKIPPED`; the audio node carries them out and decides nothing.
- Stream-safe sound lifts `Cries` by 6 dB. Mono and swap are one effect on Master (AD-18).
- The game's loudness tool (`game/tools/measure_watch_loudness.gd`) measures the game's clips through the game's layout into the game's table (AD-39); it is re-verified whenever a clip, a slot effect or a level effect changes.

### Architecture Decision Records

**AD-1, AD-2, AD-3 together: the night is a simulation.** Considered: rule scripts per system, as the ear test has; node components. Rejected because the interactions between systems would land in node code, which agents cannot verify without a screen or speakers. Consequence: `NightSim` will be the largest part of the code and must be split internally into rule scripts it owns (span, dead, rigs, lanterns, holds, waves); a rule function that changes state is handed the `NightSim` and reaches other systems through it (see the shape of a rule script).

**AD-5: voice slots.** Considered: twelve fixed buses (three times the reverbs); the ear test's single shared shadow bus (loses the measured front/back cue with two cries). Consequence: the game's bus layout differs from the ear test's, so the loudness table is measured again for the game in epic 2 story 1.

**AD-6, AD-7 and AD-17 change the GDD's wording.** Distance is smooth, not stepped, and measured along the span only. A deck cry can be cut mid-clip by a warning. A wound dulls the cries and ambience on its side, not footsteps and hooks. All three are to be written back into the GDD (Listening; Wounds).

**AD-12: one project, two games.** The ear test's scripts, scene, clips and loudness table are not edited. Its two export presets gain the `eartest` feature and `project.godot` gains `run/main_scene.eartest` and `config/name.eartest` overrides. Details and the checks that keep it whole are under Project Structure (AD-39, AD-43).

**AD-17: the wounded ear is per source.** A true one-ear filter would need a custom audio effect, which typed GDScript without addons cannot provide. If playtests show the wound does not read, revisit.

**AD-18 is unproven.** That `pan_pullout` −1 swaps the channels cleanly is read from how the effect is computed, not heard. Fallback if the measurement test fails: mirror every source's position across the span's centre line in `CryMix`, which swaps the engine's panning.

---

## Cross-cutting Concerns

These patterns apply to every system. AD-28 to AD-31 were chosen by Sonlm on 2026-11-20. AD-32 to AD-37 came out of an elicitation pass on this section the same day (pre-mortem, cascading failure, edge-case sweep, assumption audit) and were accepted as a set.

### Rule or consumer? (AD-32)

Something is a **rule** and lives inside `NightSim` if any of these is true: a pause must freeze it; the gate 2 log scores it; another rule depends on it. Everything else is a **consumer** that only obeys events and reads state. Pure presentation maths (such as `CryMix`) sits beside its consumer; it is tested like any pure function, and that alone does not make it a rule.

By this test the ally's call rules, the cry voice allocator, and the steps of the lesson and the listening round are rules. The left/right check that opens the lesson is not: it runs before any night exists and is a screen. The sim decides when the ally calls and which cry holds which slot, and emits `ALLY_CALLED`, `CRY_STARTED` (with its slot), `CRY_CUT` and `CRY_SKIPPED`. The audio node and the caption carry those out and decide nothing.

### Time (AD-33)

- The sim counts whole ticks (`tick: int`), 60 per second. It never adds up float seconds.
- Every duration constant is written in seconds with its `_S` suffix and converted to ticks once, when the sim is built (`roundi(seconds * 60.0)`).
- An event's `t` is `tick / 60.0`, measured from the first toll.
- Physics runs at 60 ticks per second (`physics/common/physics_ticks_per_second=60`, set explicitly). One physics frame is one sim tick.
- **Countdowns (AD-67).** Something that begins on tick *T* and lasts *N* ticks completes on tick *T + N*, and its event carries that tick. A 6 s warning that starts at 5.000 lands its hook at 11.000. A condition first true during tick *T* (a section overloaded) begins its countdown on *T*.

### Order inside a tick (AD-34)

Each `advance()` runs the same steps in the same order, and events appear in that order:

1. Inputs: the move wish and the view; the warden moves (AD-52); the look target is worked out (AD-47); then queued commands in the order they arrived
2. Holds and taps: first whether the running action is still possible, then progress, then completion
3. Rigs in motion: a trapdoor's drop, a beam's sweep
4. Consequences of what steps 2 and 3 changed (AD-48)
5. The wave clock and the timetable: warnings that are due start, or wait (AD-7). In a lesson or a listening round, their own steps run here instead
6. The dead, including one reaching the warden
7. Loads, creaks, groans and collapses
8. Consequences of what step 7 changed (AD-48)
9. Crossings and windows
10. Lanterns, oil and what is lit
11. Wounds, the name (the hum's range, reading it), and the night-wide countdowns (the dead standing still, hurrying)
12. Voices, the ally, and the scoring marks for the log
13. The ending

A new system gets a numbered place in this list before its rule is written; nothing ticks outside it.

- The ending event is always the last event of its tick. It is `DAWN_CAME` or `NIGHT_LOST` for a night, `LESSON_ENDED` or `ROUND_ENDED` for those two definitions (each `NightDef` names which rule ends it), and `NIGHT_ABANDONED` when the player leaves from the pause screen, which the night screen asks for with `sim.abandon()`. After it, `advance()` changes nothing and returns an empty list; calling it is not a fault.
- **Dawn wins a tie.** If the last window goes out, or section 6 falls, on the tick dawn comes, the night ends in dawn (GDD: "dawn comes at 12:00 whatever is on the span").

### Base facts and derived values (AD-35)

The sim stores base facts only: planks, rails, hooks, positions, oil, shutters, wounds. Strength, "open", load, "lit" and "locked" are computed from them each time they are needed and are never stored. A repair after a fault therefore cannot leave a stale value behind.

### Error Handling

**Strategy (AD-28):** report once, repair, carry on. There are three kinds of "wrong", each with its own channel. Never mix them.

| Kind | Example | Channel | Effect |
|---|---|---|---|
| A designed "no" | A second strike on a shaken hook; a tool that cannot be afforded | A `REFUSED` event with a `NightTypes.Reason` | The empty-hand gesture; planning's why-not line. Not a problem, not reported |
| A setup problem | A missing clip, bus or loudness entry | Collected in a list at start, `push_warning` or `push_error`, shown on the title | The game starts if it can; the title says what is missing |
| A fault (a bug) | One of the dead placed beyond the span's end; a `CRY_STARTED` naming a slot the audio node does not have | `faults.report(code, detail)` | The value is put back in range and the night goes on |

- **One fault channel (AD-36).** Each night owns one `WatchFaults` object, handed to the sim and to every consumer. It is the only code that calls `push_error` for a fault. It reports the first occurrence of each code in a night and counts every occurrence.
- No `assert`, no crash, no error page during a night.
- Codes are `system.what`, lower snake: `dead.off_span`, `sound.unknown_slot`.
- **Faults are visible at gate 2.** Each night's summary row in the playtest log carries the fault count and codes, and beside them the number of refusals by reason (AD-60). The gate 2 write-up lists every night that had one; such a night is judged with that in mind.
- Tests and all three smoke runs fail on any ERROR or WARNING line. A test that provokes a fault on purpose wraps it in `_expect_begin()` / `_expect_end()`.

```gdscript
# inside a rule function that was handed the sim
if dead.along < 0.0:
	sim.faults.report(&"dead.off_span", "id=%d along=%.2f" % [dead.id, dead.along])
	dead.along = 0.0

# a designed "no" is an event, not an error
if hook.shaken:
	sim.refuse(NightTypes.Reason.HOOK_ALREADY_SHAKEN)
	return
```

### Logging

**Approach (AD-29):** engine messages plus an event trace.

- Problems: `push_error` and `push_warning` only, with the `system.code` prefix.
- **No `print` in runtime code.** A clean run prints nothing. Offline tools, the test runner and the trace may print. `tools/ci.sh` fails if `print(` appears in a runtime folder outside `watch/debug/` (the trace, `--show=list` and replay print by design).
- `--trace` prints every `NightEvent` as one line: time, kind, who, where.
- The **playtest log** is not a debug log. It is the gate 2 data: a CSV of events and per-night summary rows under `user://`, written only with the `playtest` feature or the `--log` switch (AD-53), flushed row by row, never overwritten. It is written by one `PlaytestLog`, owned by `WatchSession`; no other script writes to it.

```
$ godot --path game -- --trace --seed=7 --start=night
  5.000 WARNING_STARTED grappler#1 s3 L
  5.000 CRY_STARTED     grappler#1 slot2
  9.300 SOUNDED         rope_strained s3 L
 11.000 HOOK_LANDED     grappler#1 s3 L
 17.000 CLIMBED_ON_DECK grappler#1 s3
```

### Configuration

**Approach:** AD-9 and AD-21.

| Type | Where | Rule |
|---|---|---|
| Rule numbers | One `*_constants.gd` per system | Named constant, unit suffix, `##` comment citing GD-n or UX-n |
| A night's content | `NightDef`, built in `night_defs.gd` | Timetable, section count, starting parts, name pool, hints, lines |
| Player settings | `WatchSettings` object inside `WatchSession`, saved by `ConfigFile` | Read through `WatchSession`; never a global |
| Launch switches | One table in `LaunchOptions`, parsed once into a value | Passed down; no other script reads the command line |
| Build facts | `build_info.gd`, written by `tools/ci.sh` before an export | The commit hash; "dev" when run from source |
| Platform | None | The game's Windows and Linux presets are kept in step |

Tests write spec values literally and never read them from the constants under test.

### Event System

**Pattern (AD-2, AD-30):** a synchronous, ordered, typed event list. No event bus, no autoload, no string event names.

- One class, `NightEvent`, with a `kind: NightEvent.Kind` enum and a fixed set of typed fields: `t`, `section`, `side`, `along`, `level`, `dead_id`, `dead_kind`, `slot`, `sound` (the sound id, AD-45), `reason`, `amount`, `id` (a `StringName` for a line, hint, name or fault code). Unused fields keep their defaults. One event is one row of the playtest log. Each kind's `##` comment in `night_event.gd` lists the fields it sets, and a test checks that no kind sets a field its comment does not name.
- Kinds are named for what happened, past tense, upper snake: `WARNING_STARTED`, `HOOK_LANDED`, `CLIMBED_ON_DECK`, `DEAD_FELL`, `SECTION_FELL`, `WINDOW_WENT_OUT`, `HOLD_CANCELLED`, `REFUSED`. Where two things can do the same, the kind names which: `DEAD_FELL`, `SECTION_FELL`.
- **How a rule reports (AD-67).** A rule function that changes state returns nothing; it calls `sim.emit(event)` for what happened and `sim.refuse(reason)` for a designed "no", which emits the `REFUSED` event. A pure query returns its value and emits nothing.
- The night screen calls `sim.advance()` once per physics tick and passes the same array, in the same order, to every consumer: audio, span view, dead views, hands, captions, cues, playtest log, trace. (The recording needs the inputs, not the events: `night.gd` passes it each tick's move, yaw, pitch and commands directly.)
- A consumer is a callback registered with the night screen, not a base class (see Implementation Patterns, Communication). It handles a kind with `match event.kind:` and ignores kinds it does not know.
- State says what exists; events say what just happened (AD-49).
- Consumers never add events and never call the sim while handling one. A player input that changes the night is a command, queued and applied at the start of the next tick.
- Continuous things (positions, oil, a flame's lean) are read from sim state, not sent as events. Views that draw between ticks interpolate.
- Godot signals are for node-to-node UI wiring inside one screen (a button, a slider). They never carry a rule of play.

```gdscript
# night.gd. Not called while the tree is paused.
func _physics_process(_delta: float) -> void:
	_sim.set_move(_warden.move_direction())
	_sim.set_view(_warden.yaw(), _warden.pitch())
	var events: Array[NightEvent] = _sim.advance()
	for consumer: Callable in _consumers:
		consumer.call(events, _sim)
```

**Pause (AD-67).** Pause is an overlay on the night screen (and on the lesson screen, in the same way), not a change of screen. The overlay calls `EngineGlobals.set_paused(true)`, which pauses the tree, mutes the game's buses and frees the mouse; only the overlay keeps processing. The night screen's tick loop and its input handler are simply not called, so the sim is not ticked, and nothing is reset. Losing window focus pauses too (AD-51). Press and release commands are not queued while paused. On resume the night screen sends a `release` command for every input that was held at the pause and is no longer held, so a button let go during the pause cancels its hold on the first tick; these commands are recorded like any other. A setting that is a rule (cue mode, Holds) changed on the pause screen is queued as `NightCommand.set_option()` and applied on that first tick.

**What leaves a night (AD-67).** On the ending event, whichever it is, the sim builds a `NightResult`: how it ended, the cause of a loss, sections standing, windows lit, planks and ropes left, wounds, the name and whether it was called, ticks spent on each section, the final span for the dawn view, refusal counts by reason, and for a lesson or a round its scores. The night screen hands it to `Main` with one signal, `night_ended(result: NightResult)`. The ledger, the lost-night page, the hint choice and the log's summary row all read it; none of them reads the sim.

The night screen adds what the sim cannot know and writes the night's summary row with `playtest_log.night_row(result, faults, frame_stats)`: the fault counts and codes from the night's `WatchFaults` (which hears the sim and every consumer), and the frame times.

**The playtest log.** `WatchSession` owns one `PlaytestLog` (in `watch/log/`) for the whole sitting. Its `on_tick` is registered as a consumer each night, and it has calls for rows that are not events: the night row above, and the headphones-or-speakers answer, the left/right check's answers, every pause with its cause, the time from Begin the watch to the first cry, and the renderer. No other script writes to the log's files.

### Debug Tools

**Available (AD-31):**

| Tool | What it does | Available in |
|---|---|---|
| Launch switches | `--seed=N`, `--start=lesson\|planning\|night\|round`, `--wave=N`, `--plan=name`, `--def=name`, `--show=name`, `--trace`, `--log`, `--debug`, `--replay=file` | Every build except public |
| F3 overlay | Frame rate, section planks and loads, voice slots, wave clock, seed | Editor and `playtest`, and only when launched with `--debug` |
| Night recording | Every sim input per tick (move direction, view direction, commands), and a state checksum every 600 ticks | Written with `playtest` or `--log`; replayed anywhere |
| Bot nights | Whole nights run in the sim alone, over many seeds, by a scripted player that presses legal and illegal inputs | The test suite |
| Show-me setups (AD-56) | `--show=<name>` starts a scripted situation for a manual check; `--show=list` lists them | Editor and `playtest` |
| Frame times | With `--log`, each night's summary row carries the average frame rate and the 1% low over the whole night | Editor and `playtest` |

- Debug code is guarded by `OS.has_feature("playtest") or OS.has_feature("editor")`. The public build contains none of it.
- The bot and the show-me setups live in `watch/debug/` (`bot/`, `show/`), because playtest builds run them and builds exclude `tests/`. Tests may use them; nothing else outside `watch/debug/` names them.
- `--wave=N` starts a night on a fresh span and the given plan with the wave clock at wave N's first toll. `--plan=<name>` picks a named `NightPlan` from `watch/debug/plans.gd`. Both arrive in epic 5.
- The overlay is the one exception to "no HUD at night". It cannot appear in a gate 2 session, because sessions are launched without `--debug`.
- No cheat keys.

**Night recording (AD-37).** A recording holds the build's commit hash, the seed, the `NightDef` name, the `NightPlan`, and for each tick whatever changed among the sim's inputs: move direction, view direction, and commands. It is flushed at least once a second, so a crash leaves a usable file. `--replay=file` feeds those inputs straight into a `NightSim` with no scene, prints the trace, and stops at the first tick whose checksum differs from the recorded one, naming that tick. It refuses a recording from another commit. Replaying a Windows recording on Linux is expected to work and is not proven; the checksums are what will say.

**Bot nights and the smoke runs.** Faults are only caught on paths that run, so:

- The test suite plays whole nights in the sim (it needs no nodes, so a night takes about a second) over many seeds, with a bot that walks, strips, builds, springs, and also tries refused actions. Any fault fails the suite. Twenty nights in a row on one process stand in for "20 nights back to back" at the rules level.
- `tools/ci.sh` runs three smoke runs of 120 frames: the game's main scene, the game started in a night (`--start=night --seed=1`) so the night's nodes and audio run, and `res://scenes/ear_test.tscn`.

---

## Project Structure

### Organization Pattern

**Pattern (AD-38, chosen by Sonlm 2026-11-20):** all game code under `game/watch/`, grouped by system, each scene beside its script. The ear test's `scripts/`, `scenes/` and `audio/cries/` are left exactly as they are.

AD-39 to AD-43 came out of an elicitation pass on this section (inversion, second-order thinking, a check against the real repo, stakeholder lenses) and were accepted as a set.

**Rationale:** agents and reviews look for "everything about X"; the folder edge of `watch/sim/` lets CI enforce AD-1; the closed ear test is not touched.

### Directory Structure

```
3d_game/
├── game/                              # the Godot project root (--path game)
│   ├── project.godot                  # main scene = watch/main.tscn; .eartest overrides
│   ├── export_presets.cfg             # Linux, Windows (ear test, names kept); Watch playtest ×2;
│   │                                  #   Watch public ×2 (epic 8)
│   ├── EAR_TEST.md  WATCH.md          # how to run each; launch switches; where logs go
│   ├── default_bus_layout.tres        # ear test's layout, untouched
│   ├── scripts/  scenes/              # EAR TEST (closed). The game uses nothing in them (AD-65)
│   ├── audio/
│   │   ├── cries/<level>/             # EAR TEST's clips, loudness.json, CREDITS.md (frozen)
│   │   └── watch/                     # every sound of the game
│   │       ├── cries/<level>/         # re-cut clips, their own loudness.json and CREDITS.md
│   │       ├── tune/                  # the tune, its last phrase, the hum
│   │       ├── ally/                  # spoken lines
│   │       ├── bridge/                # creak, groan, collapse, rigs, hooks, footsteps
│   │       ├── hands/                 # hammer, rope, plank, cancel, knock, lantern
│   │       ├── town/                  # both bells, windows
│   │       ├── ambience/              # wind and fog bed
│   │       └── screens/               # pen-scratch, planning's dry sounds
│   ├── fonts/                         # Cormorant Garamond + its licence
│   ├── art/                           # empty until epic 7 (models, textures, shaders)
│   ├── watch/
│   │   ├── main.tscn  main.gd         # Main: the flow, owns WatchSession
│   │   ├── core/                      # CLOSED LIST: watch_session, watch_settings, launch_options,
│   │   │                              #   input_actions, watch_faults, build_info, engine_globals
│   │   ├── content/                   # names, hints, ally_lines, key_card, ui_text, sound_cues
│   │   ├── sim/                       # NODE-FREE. night_sim, night_types, night_def, night_defs,
│   │   │                              #   night_plan, plan_action, plan_result, plan_editor, night_event,
│   │   │                              #   night_command, night_result, part_place,
│   │   │                              #   span_geometry, *_state.gd, *_rules.gd, *_constants.gd
│   │   ├── night/                     # night.tscn + night.gd (tick loop, consumers), warden,
│   │   │                              #   hands, span_view, section_view, dead_views, dead_view,
│   │   │                              #   lantern_view, town_view, landing_view, sky_view, cue_views,
│   │   │                              #   caption, tick_blend
│   │   ├── sound/                     # watch_bus_layout.tres, sound_setup, sound_constants,
│   │   │                              #   cry_mix (pure), watch_cry_library, cry_audio, sfx_audio,
│   │   │                              #   ambience_audio
│   │   ├── planning/                  # planning.tscn, planning.gd, tray
│   │   ├── lesson/                    # the lesson's and listening round's screens only
│   │   ├── screens/                   # title_screen, first_launch_screen, sound_check_screen,
│   │   │                              #   pause_screen, key_card_screen, journal_screen,
│   │   │                              #   ledger_screen, lost_night_screen, settings_screen,
│   │   │                              #   credits_screen, watch_theme (Lantern light), hold_timer
│   │   ├── log/                       # playtest_log, recording
│   │   └── debug/                     # overlay, trace, replay, plans, bot/, show/
│   │                                  #   (not in public builds)
│   ├── tests/
│   │   ├── run_tests.gd               # the runner: finds every test file and _test_ function
│   │   ├── test_case.gd               # the base: _check, _expect_begin, _expect_end
│   │   ├── ear_test/test_ear_test.gd  # the ear test's tests (120 checks, bodies unchanged)
│   │   └── watch/                     # watch_test.gd (sim helpers), test_span.gd, test_dead.gd,
│   │                                  #   ..., test_bot_nights.gd
│   └── tools/                         # offline: measure_loudness (ear test), measure_watch_loudness,
│                                      #   cut_cries, decode_audio
├── source_audio/                      # raw recordings, outside the Godot project
├── tools/ci.sh                        # import, purity check, tests, three smoke runs, exports
├── builds/                            # git-ignored
└── _bmad-output/                      # planning; this document
```

### System Location Mapping

| System | Location | Responsibility |
|---|---|---|
| Flow between screens | `watch/main.gd` | Title, first-launch questions, lesson, planning, night, dawn, lost night. It creates `WatchSession` and decides what screen comes next, and holds nothing else (AD-59) |
| Launch switches | `watch/core/launch_options.gd` | The one table of switches; parsed once into a value that is passed down |
| Engine globals | `watch/core/engine_globals.gd` | Applies constants and then settings to the buses and the window; sets mouse mode and clears tree pause at each screen change (AD-51) |
| Settings, lesson-done flag | `watch/core/watch_settings.gd`, `watch_session.gd` | Values, load and save through `ConfigFile` |
| Input actions and key names | `watch/core/input_actions.gd` | The one table of physical keys; registers actions; returns printed key names |
| Fault channel | `watch/core/watch_faults.gd` | The only caller of `push_error` for faults; counts per code |
| Texts | `watch/content/` | Names and epitaphs, hints, ally lines and captions, key card, screen text |
| Night rules and state | `watch/sim/night_sim.gd` + `*_rules.gd`, `*_state.gd` | Everything AD-32 calls a rule |
| Shared enums | `sim/night_types.gd` | `NightTypes.Side`, `Level`, `DeadKind`, `Reason`, `Part`, `HandInput`, `Cue` |
| Span | `sim/span_rules.gd`, `span_state.gd`, `span_constants.gd` | Planks, rails, load, creak, collapse, open sections, gaps |
| The dead | `sim/dead_rules.gd` (what all kinds share: load, walking, falling), `grappler_rules.gd`, `diver_rules.gd`, `nest_rules.gd`, `dead_state.gd`, `dead_constants.gd` | Warnings, arrival, walking, crossing, falling; the one who keeps coming back |
| Waves | `sim/wave_rules.gd`, `night_defs.gd` | Timetable, tolls, lulls, the silence, dawn |
| Where things are | `sim/span_geometry.gd` | The position and shape of every section, plank, rail, pin, pole, hook and landing, and the fixed order in which planks leave a section (GD-54); used by the sim and by every view (AD-47) |
| Look target | `sim/look_rules.gd` | What the warden is looking at within 2 m; "the section ahead" |
| Hands and holds | `sim/hand_rules.gd`, `hold_rules.gd` | Which action each input does; taps and holds, cancel, refuse, Press once |
| What follows a change to the span | `sim/consequence_rules.gd` | The one place that settles the dead, rigs, lanterns, parts, hooks and the warden after the span changes (AD-48) |
| Rigs, wedge, hook strike | `sim/rig_rules.gd`, `rig_constants.gd` | Build, spring, reset, dismantle |
| Lanterns, oil, light | `sim/lantern_rules.gd`, `light_rules.gd` | Hang, take, swap, shutter, burn, refill; what is lit; Diver targeting |
| Cues | `sim/cue_rules.gd` | Whether a cue shows, per cue mode and light |
| Voices | `sim/voice_rules.gd` | Slots, the 4-cry limit, cut and skip |
| Ally | `sim/ally_rules.gd` | When a call is due, dropped or made |
| Name, bell | `sim/name_rules.gd` | The hum's range, reading, calling, the wrong ring |
| Windows, loss, hints | `sim/window_rules.gd`, `hint_rules.gd` | Crossings, flicker, both losses, which hint |
| Wounds | `sim/wound_rules.gd` | Knockdown, side, timers |
| Scoring marks | `sim/score_rules.gd` | For each warning: turned within 45° at 4 s, heading toward the arrival at 4 s, dark or lit, called or not, each as its own `WARNING_SCORED` event whose `id` names the mark (`&"turned"`, `&"heading"`, `&"lit"`, `&"called"`) and whose `amount` is 1 or 0; ticks spent on each section |
| The night's result | `sim/night_result.gd` | Built by the sim at the ending event (AD-67) |
| Planning rules | `sim/plan_editor.gd`, `night_plan.gd`, `plan_action.gd`, `plan_result.gd` | Strip, place, undo, Start over; the `NightPlan` value |
| Lesson and listening-round steps | `sim/lesson_rules.gd`, `sim/round_rules.gd` | The three harmless dead, repeats until faced, "listen again", the cue after three, the hands-on steps; the twelve trials and their scoring. (The left/right check is a screen, below) |
| Night screen | `watch/night/night.gd` | Builds sim and scene from a `NightDef` and a `NightPlan` (empty until epic 5; before that a situation comes from the `NightDef`'s `StartState`); ticks; feeds consumers and the recording; owns the pause overlay |
| Warden's walking | `sim/warden_rules.gd` | Moves the warden at walking speed inside what is walkable now; crossings, climbs, knockdowns (AD-52) |
| Warden's node | `watch/night/warden.gd` | Mouse look, applied at once; sends move and view directions; follows the sim's position through a `TickBlend`. No physics body, no ray |
| What is drawn at night | `watch/night/*_view.gd`, `hands.gd`, `caption.gd`, `tick_blend.gd` | Consumers: reconcile with state each tick, play one-shot effects from events (AD-49) |
| Cry mixing | `watch/sound/cry_mix.gd`, `cry_audio.gd` | Gain and filters per cry; the slot players |
| Bus setup | `watch/sound/sound_setup.gd`, `watch_bus_layout.tres` | Loads the game's layout; writes effect values from constants |
| Other sound | `watch/sound/sfx_audio.gd`, `ambience_audio.gd` | Event sounds from the sound-and-cue table; the bed |
| Cry clips and loudness | `watch/sound/watch_cry_library.gd`, `game/tools/measure_watch_loudness.gd` | Finds the game's clips under `audio/watch/cries/`; the table is measured through the game's buses (AD-65) |
| Planning screen | `watch/planning/` | The overhead view and tray, driving `PlanEditor`. Its first version is epic 1's overhead read-out. Its two 1 s holds use `screens/hold_timer.gd`, a pure counter the screen ticks, so a pause freezes them and a test can drive them |
| The landing and the sky | `watch/night/landing_view.gd`, `sky_view.gd` | The bell, the flask, the tally board and its chalk, the ally's silhouette, the practice pin; the sky paling in wave 6 |
| Dawn | `watch/screens/ledger_screen.gd` over the planning view | The overhead span drawn from the `NightResult`'s final span, with the ledger written beside it |
| The left/right check | `watch/screens/sound_check_screen.gd` | One bell stroke on a dark screen, the three answers and ring again. A screen, not part of the night and not in the sim: it opens the lesson and is also reached from Settings. It plays its stroke through `SfxAudio` on the left or right. Its answers go to the playtest log |
| Display and comfort settings | `watch/core/engine_globals.gd`; `night/night.gd`; `night/caption.gd` | Window mode and resolution; brightness and field of view applied to the night's environment and camera; the centre dot and caption size on the caption layer |
| Build facts | `watch/core/build_info.gd` | The commit hash, written by `tools/ci.sh` before an export |
| Lesson, listening round (screens) | `watch/lesson/` | Prompts, the dark screen, the answer keys; each drives a `NightSim` with its own `NightDef` |
| Screens | `watch/screens/` | Every menu and page, in the Lantern light look. In playtest builds the title has an entry that opens the log folder |
| Playtest log, recording | `watch/log/playtest_log.gd`, `recording.gd` | The log is a consumer owned by `WatchSession`. The recording is not a consumer: `night.gd` hands it each tick's inputs directly |
| Debug | `watch/debug/` | Overlay, trace, replay, named plans, the bot and its paths, show-me setups |

### Naming Conventions

#### Files

- Scripts and scenes are lower snake. A scene has the same base name as its script and sits beside it: `night.tscn`, `night.gd`.
- **Scenes are thin (AD-62).** A scene file holds a root node and its script, and at most child nodes that have no position on the span (a camera, a `CanvasLayer`, an audio player). Everything that has a place on the span is created in code and placed by asking `SpanGeometry`. No coordinate of the span is typed into a `.tscn`.
- A folder is created with its first file. No empty folders, no placeholder files.
- A game script that another script names by type has one `class_name`, PascalCase, matching the file: `night_sim.gd` is `NightSim`. A script nobody names by type (a screen's root script, `main.gd`) declares none. "`Main`" in this document is the main scene's root, not a class.
- Scripts in `watch/screens/` end in `_screen`. (`night.gd`, `planning.gd` and the lesson's scripts are named for what they are.) A file is never named so that its class would be an engine class or a bare generic word: `watch_theme.gd`, not `theme.gd`; `settings_screen.gd`, not `settings.gd`.
- **No bare generic word as a `class_name` (AD-41).** Global names carry `Night` or `Watch` when the plain word could one day be an engine or plugin class: `NightPlan`, `NightCommand`, `WatchSettings`, `WatchSession`, `WatchFaults`. Not `Plan`, `Command`, `Settings`.
- Suffixes say what a sim script is: `*_rules.gd` (static or pure functions), `*_state.gd` (base facts, no logic beyond accessors), `*_constants.gd` (numbers). Outside the sim: `*_view.gd` draws, `*_audio.gd` plays.
- Tests: `test_<system>.gd`, functions `_test_<topic>()`.

#### Code Elements

| Element | Convention | Example |
|---|---|---|
| Classes | PascalCase | `NightSim`, `SpanRules` |
| Functions, variables | lower snake, fully typed | `strip_plank(section: int, sim: NightSim) -> void` |
| Private members | leading underscore | `_slots` |
| Constants | UPPER_SNAKE with unit suffix (`_S`, `_MS`, `_DB`, `_HZ`; metres carry none) | `TRAPDOOR_HAUL_S`, `REAR_SHADOW_DB` |
| Enums | PascalCase type, UPPER_SNAKE values | `NightEvent.Kind.SECTION_FELL` |
| Event kinds | what happened, past tense | `HOOK_LANDED`, `WINDOW_WENT_OUT` |
| Commands | what the player did with an input, never what it means | `NightCommand.press(HandInput.HAMMER)`, `release(...)`, `set_option(...)` |
| Fault and warning codes | `system.what`, lower snake `StringName` | `&"span.parts_short"` |
| String ids | lower snake | `"left_rail"`, `&"ally_below"` |
| Bus names | PascalCase `StringName` | `&"CrySlot1"`, `&"Below"` |
| Input actions | `watch_` + lower snake | `&"watch_hammer"`, `&"watch_forearm"` |

#### The span's numbers (every script uses these)

- **Sections are numbered 1 to 6**, as in the GDD: 1 touches the far pier, 6 the town pier. `0` means "no section". Never zero-based.
- **`along`** is a position on the span in metres: 0.0 at the far pier, the span's length at the town pier's edge (30.0 in the one-night game). Section *n* covers `(n − 1) × 5` up to `n × 5`. The landing is beyond the length.
- **World axes:** the span runs along Z. The far pier is toward −Z, the town toward +Z; `world_z = along − length`, so the town pier's edge is always at the origin. Up is +Y.
- **No literal 6 or 30 (AD-42).** Scripts ask the `NightDef` for the section count and the span's length. Only `night_defs.gd` and tests write those numbers.
- **Left and right** are the warden's when facing the far pier: `NightTypes.Side.LEFT` is −X, `RIGHT` is +X. The same word means the same rail in planning.
- **Levels** are `NightTypes.Level.BELOW`, `ABOVE`, `INSIDE`, with the ids `"below"`, `"above"`, `"inside"` for folders and buses, as the ear test has.
- **The dead** have an `id: int` that is never reused within a night. In text and logs: `grappler#3`.

#### Game Assets

- **The game has its own cry clips (AD-39).** They live in `game/audio/watch/cries/<level>/` with their own `loudness.json` and `CREDITS.md`, and keep the naming rule `<freesound id>_<author>_<n>.wav`. `game/audio/cries/` belongs to the ear test and is never re-cut, re-measured or added to.
- Every other sound: `<what>_<n>.wav` in its folder under `game/audio/watch/`, each folder with its own `CREDITS.md`. A `placeholder_*.wav` never sits beside real files.
- Stand-in ally lines are named `placeholder_<line id>.wav` until the recorded ones arrive.

### Architectural Boundaries

1. **`watch/sim/` is node-free.** Scripts there extend `RefCounted`, and name nothing outside `watch/sim/`, `watch/content/` and `WatchFaults`. `tools/ci.sh` fails if a code line there contains `extends Node`, `Node3D`, `get_tree`, `Input.`, `AudioServer`, `FileAccess`, `Time.`, `await` or `print(` as whole words (so that `HandInput.` does not match `Input.`); a global random call, that is `randi(`, `randf(`, `randi_range(`, `randf_range(` or `randomize(` not preceded by a dot; or `.shuffle(` or `.pick_random(`. The sim's own seeded generator is `sim.rng`, and `sim.rng.randi_range(...)` passes; and a test checks that every script in the folder has the base type `RefCounted`.
2. **Only the sim changes night state.** Everything outside `watch/sim/` reads sim state and sends commands. It never assigns to a sim field. A test or a show-me setup that needs a particular situation describes it as a `StartState` on its `NightDef` (planks per section, rails, rigs, lanterns, the dead and their phases, test weights), which the sim builds itself from; after that it uses only commands and ticks.
3. **The ear test is closed (AD-39, AD-65).** Nothing in `scripts/`, `scenes/`, `audio/cries/`, `default_bus_layout.tres` or `game/tools/measure_loudness.gd` is edited, and nothing there may name anything in `watch/`. The game names nothing in `scripts/` or `scenes/` either: its cry library is its own copy. The public build leaves the ear test out.
4. **`watch/debug/` is one-way.** Nothing outside it names a debug class. `Main` loads it by path, at start, only when the build allows. Public presets exclude the folder.
5. **`tests/` and `tools/` are not runtime.** No runtime script preloads or names anything in them.
6. **Screens do not reach into each other.** A screen gets `WatchSession` and reports back to `Main` with a signal; `Main` decides what comes next.
7. **`watch/core/` is a closed list (AD-40)** of seven scripts (the seventh, `engine_globals.gd`, was added by AD-59). An eighth is a change to this document, not a place to put something that has no other home.

### Keeping the ear test whole (AD-43)

- **Export presets.** The ear test's two presets keep their names (`Linux`, `Windows`) and their include filter, and gain the feature `eartest`. `project.godot` gains `run/main_scene.eartest` and `config/name.eartest`. The game's four presets include `audio/watch/cries/loudness.json`, a different line, so the ear test's own check that exactly two presets include its table still holds.
- **User folders.** Both are pinned with `config/use_custom_user_dir` and `config/custom_user_dir_name` (with an `.eartest` override), so the ear test's exported builds keep writing where they do today and the game's folder does not follow the working title. Feature overrides apply only to exported builds: the ear test run from source (its tests, its smoke run) uses the game's folder, in its own sub-folders. The gate 1 results are already kept in `_bmad-output/implementation-artifacts/ear-test-sessions/`.
- **Tests.** After the split, the ear test's file must still report 120 passed with 23 expected errors (the count on 2026-11-20). Its helper functions (`_check`, `_expect_begin`, `_expect_end`) move into `tests/test_case.gd`, which its file then extends; its test bodies do not change. The runner only finds files and functions, runs them and reports the counts.
- **CI.** Three smoke runs: the game's main scene, the game started in a night, and `res://scenes/ear_test.tscn`. With `--export`, the ear test build is started once to confirm it opens the ear test and not the game.
- That the feature-tag override selects the main scene in an exported build is taken from Godot's documented behaviour and is confirmed by that last check, in the first story of epic 1.

### Reading and running (AD-43)

`game/WATCH.md` sits beside `EAR_TEST.md` and says how to run the game from the editor and from a terminal, what each launch switch does, how to open the ear test now that it is not the main scene, and where the playtest log and recordings are written.

---

## Implementation Patterns

These patterns keep every agent's code the same shape. AD-44 to AD-46 were chosen by Sonlm on 2026-11-20. AD-47 to AD-51 came out of an elicitation pass on this section (edge-case sweep, rubber duck, critique, chaos monkey); Sonlm chose AD-47 from options and accepted the rest as a set. Examples are typed GDScript, indented with tabs; the constructs they rely on (typed dictionaries, a list of consumer callbacks, a blend helper object) were run under the project's strict typing in Godot 4.7.2.

### Novel Patterns

#### 1. The parts ledger (the base is the budget)

**Purpose:** planks and ropes are map, health and currency at once, so none may appear or vanish by accident.

**Rule:** every plank and rope is always in exactly one place, and moves only through `SpanRules.move_parts()`. Places: a section's deck, a section's rail, a rig, the warden's hand, `LOST`.

```gdscript
## Moves parts from one place to another. The only function that changes a part count.
static func move_parts(kind: NightTypes.Part, count: int,
		from: PartPlace, to: PartPlace, sim: NightSim) -> void:
	if sim.span.count_at(kind, from) < count:
		sim.faults.report(&"span.parts_short", "%s from %s" % [kind, from.label()])
		count = sim.span.count_at(kind, from)
	sim.span.add_at(kind, from, -count)
	sim.span.add_at(kind, to, count)
```

**Proof:** after every tick of every bot night, the totals over all places equal the `NightDef`'s starting planks and ropes.

#### 2. The sound-and-cue table (every sound has a visual cue) (AD-45)

**Purpose:** pillar 2's promise is kept by construction.

**Rule:** `watch/content/sound_cues.gd` holds one row per sound of the night, keyed by a **sound id**: the clip folder, the bus, the cue id, and the cue class. An audible event carries its sound id in `sound`. `SfxAudio` and the cue views both read this table and nothing else. A sound that is not in the table cannot be played.

```gdscript
# watch/content/sound_cues.gd
const ROWS: Array[Array] = [
#  sound id            clips           bus        cue              class
[&"hook_landed",      "bridge/hook",  &"Bridge", &"hook_seen",    NightTypes.Cue.PHYSICAL],
[&"rope_strained",    "bridge/strain",&"Bridge", &"ropes_shake",  NightTypes.Cue.POINTER],
[&"window_went_out",  "town/window",  &"Town",   &"window_dark",  NightTypes.Cue.PHYSICAL],
[&"ally_below",       "ally/below",   &"Ally",   &"caption",      NightTypes.Cue.ALWAYS],
]
```

- **A warning is a sequence the sim emits.** A Grappler's warning is `CRY_STARTED` at its first tick and an event with `&"rope_strained"` 4.3 s later; a nest's is seven `CRY_STARTED` events at closing gaps. The audio node never schedules anything.
- **Cues come from sim state, never from audio playback.** A level cue shows while its warning's phase lasts; a flame leans toward the nearest cry the sim's voice rules say is sounding. With the speakers off, every cue is the same.

| Cue class | Shown when |
|---|---|
| `POINTER` (points at a cry or the hum) | In the light; also in the dark, self-lit, in Cues everywhere; never in Ears only |
| `PHYSICAL` (the event itself: a hook landing, a fall) | Where light falls |
| `PHYSICAL_GLOW` (footsteps of the dead, bowing planks) | Where light falls; also in the dark, self-lit, in Cues everywhere |
| `ALWAYS` (captions, chalk, the wound's dark side) | In every cue mode |
| `EVERYWHERE_ONLY` (every lit flame dipping with each stroke of the bell; a shuttered lantern's seam glow leaning) | Only in Cues everywhere |

How far a flame's lean reaches is a `light_rules` function of the cue mode: its own light by default, the nearest cry anywhere in Cues everywhere.

`CueRules.is_shown(cue_class, lit, cue_mode)` is the only place that table is turned into yes or no.

**Proof:** a test fails if any row has an empty cue id, or if the sim can emit a sound id that has no row.

#### 3. Hands: position and buttons in, the sim decides (no HUD) (AD-47, AD-50)

**Purpose:** one implementation of "what does this button do here, and how far along is it", testable without a screen.

**Flow:**

1. `warden.gd` gives the sim only a move direction and the direction of the view (yaw and pitch). The sim moves the warden (AD-52). There is no physics body and no ray. Mouse look turns the camera at once, between ticks; the sim reads the view direction at the next tick.
2. In the sim, `LookRules.target(eye, yaw, pitch, state)` finds what is looked at within 2 m, by testing the view line against simple shapes from `SpanGeometry`: a box for each pin, holding rope, hook, rail, pole, lantern, the flask, the bell rope, a nest's crack, a section's deck, the carved name. It also answers "the section ahead" (UX-9).
3. **`SpanGeometry` is the single source of where things are.** Views place every pin, rail, hook and pole by asking it. What is drawn is what is hit.
4. `night.gd` turns input actions into `NightCommand.press(input)` and `NightCommand.release(input)`, where `input` is a `NightTypes.HandInput` (`HAMMER`, `ROPE`, `USE`, `SHUTTER`, `BUILD_TRAPDOOR`, `BUILD_BEAM`, `DISMANTLE`, `FOREARM`). It sends nothing about meaning.
5. `HandRules.action_for(input, target, state)` returns the action or a refusal. `HoldRules` runs it in ticks.
6. The sim exposes `hands: HandsState`: for each hand a pose, the action in progress and its progress from 0 to 1. `hands.gd` draws that and decides nothing.

```gdscript
# night.gd: input becomes a command, nothing more. Not called while the tree is paused.
func _unhandled_input(event: InputEvent) -> void:
	for input: NightTypes.HandInput in InputActions.NIGHT_INPUTS:
		var action: StringName = InputActions.action_of(input)
		if event.is_action_pressed(action):
			_sim.command(NightCommand.press(input))
		elif event.is_action_released(action):
			_sim.command(NightCommand.release(input))
```

**Taps and holds (AD-50).**

- A **tap** action (strike, hang, take or swap a lantern, shutter) starts on the press and runs to its end whatever happens to the button. A strike's blow lands 0.5 s after the press.
- A **hold** action cancels on release, on moving 0.5 m from where it began, on a wound, or when it becomes impossible. `HoldRules` is the one owner of that last check: every tick, before adding progress, it asks `HandRules` whether the running action could still be started here, and cancels it if not. That covers every cause alike (a rail locking, a section opening, a nest hatching). A hold that reached its full length on an earlier tick has already completed; a release on the same tick as the last one cancels it.
- A press while another action is running is ignored: no event, no gesture.
- Press once (UX-39) is handled inside `HoldRules`: the same press and release commands arrive, and the rule reads the sim's current option. Views do not know which mode is on.

**Look-only rules.** Some rules have no button: reading the name (about 1 s of looking), "faced within 45° of a warning", the dead reaching the warden. They read the warden's position, view direction and look target directly, in their own rule scripts.

#### 4. The plan is a list of actions

**Purpose:** undo, Start over and "restore the last plan" are the same operation.

**Rule:** a `NightPlan` is an ordered `Array[PlanAction]` (strip a plank, strip a rail, place a rig, hang a lantern). `PlanEditor.apply(plan, night_def)` replays the list on a fresh span and returns a `PlanResult`: the span, the rigs and the lanterns as placed, the parts in hand, and the reason of the first refused action, if any.

- Undo on a section removes the last action that names that section, then replays. If the replay is refused (a part was spent elsewhere), the undo is refused with that reason.
- Start over empties the list.
- Starting a night stores the list in `WatchSession`. After a loss, planning opens on it and it can be undone step by step.
- A night recording stores the same list.

#### 5. Consequences are settled in one place (AD-48)

**Purpose:** "the thing under you is gone" has one implementation, not one per cause.

**Rule:** a rule that changes the span (a trapdoor drops, a section falls, the last plank is stripped, a beam sweeps, a rail is stripped) changes only the span and emits its event. `ConsequenceRules.settle(sim)` then looks at the whole state and applies what follows: the dead with no footing fall, move to the side beams or are stranded; rigs, lanterns and parts on a fallen section are lost; hooks on a missing rail are knocked off; a warden with no footing catches the edge. (A hold that has become impossible is cancelled by `HoldRules` on the next tick, not here.) It runs twice per tick (see the tick order).

No other rule script decides what happens to something because the span changed under it.

**`settle()` is an ordered list of small named steps (AD-64),** each a function with its own tests: the footing of the dead, rigs, lanterns, parts, hooks, the warden. It is never one long function, and a new consequence is a new step, not a new branch in an old one.

### Communication Patterns

**Pattern:** position and commands in, events and state out (AD-2, AD-30). **State says what exists; events say what just happened (AD-49).**

- A view that mirrors a set of things (the dead, hooks, rigs, lanterns, planks) **reconciles with sim state every tick**: it creates what is missing and frees what is gone. It never tracks existence by counting events, so a missed event cannot leave a ghost.
- Events drive one-shot effects only: a sound, a hit, a fall cry, a caption.
- **Consumers are callbacks, not a base class.** A node registers its `on_tick` method with the night screen. A view is a `Node3D`; GDScript has single inheritance, so nothing is inherited for this.
- **Consumers are tolerant.** An event about an id the consumer does not know is reported as a fault and skipped. A sound whose clips are missing was reported at start; in play it is skipped silently and its cue still shows.

```gdscript
# night.gd. Not called while the tree is paused.
var _consumers: Array[Callable] = []

func _physics_process(_delta: float) -> void:
	_sim.set_move(_warden.move_direction())
	_sim.set_view(_warden.yaw(), _warden.pitch())
	var events: Array[NightEvent] = _sim.advance()
	for consumer: Callable in _consumers:
		consumer.call(events, _sim)
```

```gdscript
# town_view.gd: obeys events, reads state, never writes it
class_name TownView
extends Node3D

func on_tick(events: Array[NightEvent], sim: NightSim) -> void:
	for event: NightEvent in events:              # events first: what just happened
		match event.kind:
			NightEvent.Kind.WINDOW_WENT_OUT:
				_puff(event.amount)
	_show_lit(sim.windows.lit)                    # then state: what exists
```

### Entity Patterns

**Creation:** the sim creates the entity; a factory keeps its view in step (AD-8, AD-49).

- Only rule scripts create a `DeadState`, giving it the next id from the sim.
- `DeadViews` is the only script that instances or frees a view of the dead.

```gdscript
class_name DeadViews
extends Node3D

const VIEW: PackedScene = preload("res://watch/night/dead_view.tscn")
var _views: Dictionary[int, DeadView] = {}

func on_tick(events: Array[NightEvent], sim: NightSim) -> void:
	for event: NightEvent in events:              # one-shot effects first,
		if event.kind == NightEvent.Kind.DEAD_FELL:   # while the view still exists
			_play_fall(event)
	for dead: DeadState in sim.dead:              # then what exists
		if not dead.has_body():
			continue
		if not _views.has(dead.id):
			_views[dead.id] = _make(dead)
		_views[dead.id].show_state(dead)
	for id: int in _views.keys():
		if not sim.has_body(id):
			_release(id)
```

One `dead_view.tscn` serves every kind; the kind picks the gray box now and the model in epic 7. A consumer always handles its events before it reconciles, so an effect can use a view that is about to go.

**Smoothing (AD-44).** A view that moves holds a `TickBlend` helper object. Each tick it pushes the new position; each drawn frame it asks for the blend, which uses `Engine.get_physics_interpolation_fraction()`. A teleport (the warden's climb back, a newly made view) calls `snap()`. Godot's project-wide physics interpolation stays off.

**Variety without the sim's dice.** A consumer that needs a random choice (which of four whisper clips) owns its own `RandomNumberGenerator`, seeded from the night's seed. The sim's generator is used only inside the sim. Global random functions are used nowhere.

### State Patterns

**Pattern:** a phase enum and a tick countdown on a state object; a `match` in the rule script. No state-machine nodes, no behaviour trees.

```gdscript
# grappler_rules.gd
static func tick(dead: DeadState, sim: NightSim) -> void:
	match dead.phase:
		DeadState.Phase.WARNING:
			dead.ticks_left -= 1
			if dead.ticks_left == 0:
				_land_hook(dead, sim)
		DeadState.Phase.HAULING:
			dead.ticks_left -= 1
			if dead.ticks_left == 0:
				_climb_onto_deck(dead, sim)
		DeadState.Phase.WALKING:
			_walk(dead, sim)
```

- A phase change always emits one event, from the function that makes the change.
- A timed rule counts ticks down to zero. Nothing compares against the clock except the wave timetable.
- A night-wide effect (the dead standing still for 20 s, hurrying for 10 s) is a countdown on the sim; walking speed is derived from it (AD-35).

### Data Patterns

**Access:** by argument, never by reaching for a global.

- Rule numbers: `SpanConstants.CREAK_GROAN_S`. Converted to ticks once, when the sim is built, into `sim.ticks`, a `NightTicks` object (`sim/night_ticks.gd`) with one `int` field per duration.
- Night content: the `NightDef` the sim was built with.
- Settings: the `WatchSession` a screen was handed. The sim gets only the options that are rules (cue mode, Holds), copied in when the night is built. A setting changed on the pause screen reaches a running night through one `NightCommand.set_option()`.
- Text: `watch/content/`, looked up by id.
- New code uses typed dictionaries (`Dictionary[int, DeadView]`). A value read from JSON or `ConfigFile` is still `Variant` and is checked with `is` before use.

### Global engine state (AD-51)

A night is thrown away (AD-4), but some engine state is global and outlives it. The game touches only this list, each with one owner:

| Global | One owner | When |
|---|---|---|
| The bus layout, and every bus value that comes from a constant (level and slot effects, base volumes) | `EngineGlobals.apply(settings)`, through `SoundSetup` | At start, at each night build, on each return to a menu. Never during a night |
| The settings layer on the buses: volume, stream-safe, mono, swap | `EngineGlobals.apply_settings(settings)` | After the constants above, and alone whenever a sound setting changes, including on the pause screen |
| Each cry slot's send, and its shelf and low-pass values | `CryAudio`, from `CRY_STARTED` events and `CryMix` | During a night. Put back to neutral by the constants above at the next night build |
| The window: mode and resolution | `EngineGlobals.apply_settings(settings)` | At start and when a display setting changes |
| `get_tree().paused`, the pause mute on the game's buses, and `Input.mouse_mode` | `EngineGlobals.set_paused(on)` and `EngineGlobals.enter_screen(kind)` | The pause overlay calls `set_paused`; `Main` calls `enter_screen` at each screen change, which clears the pause and sets the mouse mode for that kind of screen |
| `InputMap` | `InputActions` | Registered once at start; never reset |

Pause is not a screen change (AD-67), so pausing resets nothing in this table. The lesson pauses in the same way as the night.

- `Engine.time_scale` and project settings are never changed at run time.
- **Losing focus pauses the lesson and the night**, as the ear test does. The pause is logged with its cause.
- **Screen changes are deferred** to the end of the frame; a night that has emitted its ending event is not ticked again.

### The shape of a rule script

```gdscript
class_name SpanRules
extends RefCounted
## Planks, rails, load, creak, groan and collapse (GDD Game Mechanics 2; GD-19).

## Load on a section: every body standing on it, hanging from a hook on it, or set
## there as a test weight. Derived, never stored (AD-35).
static func load_on(dead: Array[DeadState], section: int) -> float:
	var total: float = 0.0
	for one: DeadState in dead:
		if one.section == section:
			total += DeadRules.load_of(one)   # 0 while only warning; a weight is a kind of DeadState
	return total
```

- Static functions only. A **pure query** takes just the pieces it reads and returns a value (`load_on` above). A function that **changes state** takes the `NightSim` as its last argument, returns nothing, and reports through `sim.emit()` and `sim.refuse()`.
- A rule script may call another rule script's pure functions. It changes another system's state only through that system's own rule functions, or leaves it to `ConsequenceRules`.

### The shape of a test

```gdscript
# tests/watch/test_span.gd
extends WatchTest

func _test_overload_groans_two_seconds_then_falls() -> void:
	var start: StartState = StartState.new()
	start.planks[3] = 3                                 # section 3 down to 3 planks
	start.weights[3] = 4                                # four test weights: load 4 > strength 3
	var sim: NightSim = _sim_with(_def_with(start), 7)  # seed written out
	var events: Array[NightEvent] = _advance(sim, 120)  # overload seen on tick 1; GDD: 2 s = 120 ticks
	_check("no fall before 2 s", not _has(events, NightEvent.Kind.SECTION_FELL))
	events = _advance(sim, 1)                           # tick 121 = 1 + 120
	_check("falls 2 s after the overload", _has(events, NightEvent.Kind.SECTION_FELL))
```

- `TestCase` (`tests/test_case.gd`) holds `_check`, `_expect_begin` and `_expect_end`. The ear test's file extends it directly. `WatchTest` (`tests/watch/watch_test.gd`) extends it and adds the helpers that build a sim from a `StartState` and advance it.
- A test sets up a situation only through a `StartState` (boundary 2), never by writing sim fields.
- Spec numbers are written out in the test, with the GDD's value in a comment. Never read from the constants.
- A test builds its own `NightDef` with only what it needs. It never depends on the one-night timetable unless it is testing that timetable.

### A feature's footprint and build order (AD-46)

A story that adds something to the night touches these, in this order:

| # | What | Where |
|---|---|---|
| 1 | The failing test, with the GDD's numbers written out | `tests/watch/test_<system>.gd` |
| 2 | Constants, each citing its GD-n or UX-n | `sim/<system>_constants.gd` |
| 3 | Base facts, if new | `sim/<system>_state.gd` |
| 4 | Its step in the tick order, if new | `night_sim.gd` (AD-34) |
| 5 | The rule, and its event kinds | `sim/<system>_rules.gd`, `night_event.gd` |
| 6 | Shapes, if something new can be looked at; what follows if the span changes under it | `sim/span_geometry.gd`; `sim/consequence_rules.gd` |
| 7 | Sound and cue rows | `content/sound_cues.gd` |
| 8 | The view and the sound that react | `night/`, `sound/` |
| 9 | A scripted bot path that reaches this story's situation (AD-63) | `watch/debug/bot/` |
| 10 | A show-me setup for each manual check (AD-56) | `watch/debug/show/`, launched with `--show=<name>` |
| 11 | Manual checks for Sonlm: what a headless agent could not verify (look, sound, feel), each naming its show-me setup | The story file |

Steps 1 to 7 are finished and passing before step 8 starts. A story is not done until steps 10 and 11 exist: every story ends in something Sonlm can launch and see or hear.

### Consistency Rules

| Pattern | Convention | Enforcement |
|---|---|---|
| Node-free sim | Boundary 1 | `tools/ci.sh` grep; base-type test |
| No `print` in runtime code | AD-29 | `tools/ci.sh` grep |
| Every test runs | The runner finds `_test_` functions itself | The runner; ear test count stays 120 |
| No faults | AD-28 | Any ERROR or WARNING line fails tests and smoke runs; bot nights |
| Parts are conserved | The parts ledger | Bot-night invariant |
| Every sound has a cue | The sound-and-cue table | Table test |
| Same night from the same seed | AD-3, AD-33 | A test runs one seed twice and compares the event lists |
| Nothing survives a night | AD-4, AD-51 | 20 bot nights in one process; the night scene built and freed 20 times headless with no leaked nodes and every bus value back at its constant |
| No threat before its warning | GDD fairness metric | Bot-night invariant: every arrival is preceded by its full warning in the event list |
| What is drawn is what is hit | Views place things from `SpanGeometry` (AD-47) | A headless test compares each view's placed position with `SpanGeometry` |
| Views cannot drift | Reconcile with state each tick (AD-49) | A headless test drops events on purpose and checks the views still match the sim |
| Every rule has been run | Event coverage (AD-63) | The suite fails if any `NightEvent.Kind` or `NightTypes.Reason` was never produced by any test or bot night |
| Launch switches work | One table (AD-61) | A CI test starts the game with each `--start` value for 120 frames |
| Sections 1 to 6, `along`, left and right | The span's numbers | Review; one test fixes left and right against world X |
| No literal 6 or 30 | AD-42 | A test runs a 4-section `NightDef` through a bot night |
| Constants cite their decision | `##` comment with GD-n or UX-n | Review |
| `class_name` matches the file; no bare generic or engine names | AD-11, AD-41 | Review; a clash with an engine class is a parse error |
| Typed everywhere | `untyped_declaration=2` | The engine: a parse error |

---

## Staging and Deferred Decisions

Added after an elicitation pass on the Project Context, Engine and Decisions sections (2026-11-20). Sonlm chose AD-52 from options and accepted AD-53 to AD-55 as a set.

### AD-52: the warden's walking is a rule

The player's input enters the sim as a move direction. `WardenRules` moves the warden at walking speed inside what is walkable at that tick (sections with planks, the landing), and runs the timed moves: edging round an open section, crossing a gap hand over hand, the climb back, a knockdown. The night uses no physics bodies, colliders or rays.

- **Why:** where the warden may stand changes all night, so colliders would be a second copy of a rule. And bot nights have no scene: with a physics body a bot could only teleport, leaving the walking rules, the 0.5 m hold-cancel and the crossing times untested.
- **Kept outside the sim:** mouse look. It turns the camera at once and is never delayed to a tick.

### AD-53: when logs are written

The playtest log and night recordings are written only when the build has the `playtest` feature or the game was started with `--log`. A run from the editor, a test or a smoke run writes nothing unless `--log` is given. Debug tools (the trace, the overlay with `--debug`, show-me setups, replay) are available in editor runs and playtest builds alike.

### Built when (AD-54, corrected by AD-66)

The architecture is built as epics need it, not all first. **Order: epic 1, then epic 2** (AD-66): the lesson and the listening round run on the sim that epic 1 builds. Epic 1 gains a setup story, sized when its stories are created.

| Epic | Infrastructure it builds |
|---|---|
| 1, setup story | Main scene switched to `watch/main.tscn` with the `eartest` overrides and pinned user folders; `TestCase`, the runner split and self-listing (ear test still 120); CI's purity and `print` checks and two smoke runs (the game's main scene, the ear test's scene); `Main` with a bare flow and a start page that lists setup problems; `WatchSession`, `WatchFaults`, `LaunchOptions` (`--seed`, `--start`), `InputActions`, a first `EngineGlobals` (mouse mode, tree pause); `WATCH.md`; the launch-switch test, covering the `--start` values that exist so far |
| 1 | `NightSim` with the tick order; `NightTypes`, `NightEvent`, `NightCommand`, `NightTicks`; `night.gd` and `warden.gd`; `WatchTest`; the third smoke run (`--start=night`); `--trace` and `--show`; `NightDef` with `StartState` (including test weights); an empty `NightPlan`; `SpanState`, `SpanRules` and the parts ledger; `SpanGeometry`; `WardenRules`; `LookRules`; `HandRules` and `HoldRules` for strip and re-lay; `ConsequenceRules` for a collapse; `TickBlend`; the span view; `hands.gd` for the forearm tallies; the overhead read-out as the first planning view. The bot, walking and stripping, with the invariants: parts conserved, same seed same events, a 4-section night, event coverage |
| 2 | The game's clips, `WatchCryLibrary`, bus layout and slots; `measure_watch_loudness`; voice rules; `CryMix`; `DeadState` with the warning phases only, for all four warnings; `wave_rules` running any `NightDef` timetable, with the toll; the carried lantern and `light_rules` for its light; the sound-and-cue table and `CueRules`; ally rules and the caption; `landing_view` with the tally board; the left/right check screen; lesson and round rules; `score_rules`; the playtest log and `--log`; `WatchSettings` saved by `ConfigFile`; bus values in `EngineGlobals`; the mono and swap measurement test; `build_info` and the two playtest export presets (the early listen needs a build); the ending and a first `NightResult` for a lesson and a round |
| 3 | The rest of `DeadState` and the rules per kind, `dead_rules`, `DeadViews`; windows and loss; `NightResult` for a night; the footing of the dead in `ConsequenceRules`; the no-threat-before-its-warning invariant |
| 4 | Rigs, hung lanterns, oil, the rest of `light_rules`, wounds; tap actions. The scripted wave's rigs and lanterns are placed through a `StartState`; no planning code yet |
| 5 | `PlanAction`, `PlanEditor`, `PlanResult` and the planning screen; the one-night `NightDef`; name rules; `sky_view`; dawn on the planning view; screens and the theme; the pause overlay and focus loss; display settings and the renderer check (it records and warns; the fog-sprite fallback it switches to arrives in epic 7); `--wave` and `--plan`; the 20-night test |
| 6 | Night recording, replay and checksums; the F3 overlay and `--debug`; frame times and refusal counts in the night summary; the log-folder entry on the title; `--def` |
| 7 | The look layer, `fog_view` with its low setting and sprite fallback, and the pooling decision (see Deferred decisions) |
| 8 | The two public export presets, without `watch/debug/` and without the ear test; Press once, stream-safe sound and the Mono setting switched on in Settings (their rules exist from epics 1, 2 and 2) |

This table names what is easy to schedule wrongly. A file in the System Location Mapping that it does not name arrives with the first epic whose stories need it.

### Deferred decisions (AD-55)

These are undecided on purpose. An agent that meets one stops and puts options to Sonlm; silence here is not permission to choose.

| Decision | Decided when | Where it will plug in |
|---|---|---|
| The woodcut technique (a full-screen pass, materials, or both) | Epic 7 story 1 | A look layer on the night scene's camera and environment. Views use plain materials until then; no rule reads anything rendered |
| Fog: the volumetric settings, the low setting, the sprite fallback | Epic 7 story 5 | `watch/night/fog_view.gd`, driven by the fog quality setting |
| Pooling the views of the dead | Epic 7 story 6, by measurement | Inside `DeadViews` (AD-8) |
| Models and animation for the hands | Epic 7 story 4 | `hands.gd` reads `HandsState`; poses are named there |
| The flame as a direction-finder: carry height, minimum lean (DW-6) | Epic 7 story 4, checked on the muted night | `lantern_view.gd`; the lean's direction is already a rule |
| Caption backing; a reduce-camera-motion setting (DW-13) | Epic 8, after the muted night | `caption.gd`; `WatchSettings` |
| An HRTF plugin (DW-1) | Only if the ear re-check fails on headphones | The slot players in `cry_audio.gd`. It would break the no-addons rule, so it is a change to this document |
| Gamepad and key rebinding (DW-8) | When the Fog Season is planned | The table in `InputActions`; `NightTypes.HandInput` |
| Saving | When the Fog Season is planned | `WatchSession` and `NightPlan` are plain data |
| Several spans; falling back from pier to pier | When the Fog Season is planned | `NightDef` and `SpanGeometry` (AD-42) |
| GDD gaps 6 and 7 | When their stories are created | `diver_rules.gd`; `name_rules.gd` |

---

## Additions from the Round Table

A party-mode review of every section (Cloud Dragonborn, Link Freeman, Murat, Indie; 2026-11-20) produced AD-56 to AD-64. Sonlm accepted all nine. Each is also written into the section it changes.

| ID | Decision | Why |
|---|---|---|
| AD-56 | **Show-me setups.** Every story with manual checks ships a scripted setup, launched with `--show=<name>`, that puts Sonlm in exactly the situation to look at or listen to. A setup is a small `NightDef` with a `StartState` and, where needed, a scripted bot path. It lives in `watch/debug/show/` and is listed by `--show=list`. | Sonlm's review time is the scarcest resource; an unheard story is an unverified one |
| AD-57 | **Know which renderer started.** At start the game reads `RenderingServer.get_current_rendering_method()`. If it is not `forward_plus`, that is a setup problem shown on the title, the fog-sprite fallback is used (once it exists, in epic 7), and the renderer is written to the playtest log with every night. Godot's automatic fallback stays on. | A tester's machine may silently run a different renderer; a game that runs with the fact recorded beats a crash dialog, and beats frame-rate numbers from an unknown renderer |
| AD-58 | **Named night variants.** `--def=<name>` picks among the `NightDef`s in `night_defs.gd`. The name is written to the log and the recording. | Tuning play mostly changes when and how many, which is content; it stays in git (AD-9) |
| AD-59 | **`Main` holds the flow only.** The global reset is `core/engine_globals.gd`; launch switches are `core/launch_options.gd`. The closed list of AD-40 is seven. `Main` has no rule of play and draws nothing. | Without autoloads, `Main` is where a GameManager would grow |
| AD-60 | **Refusals are counted by reason** in each night's summary row. | Each refusal is a newcomer trying something the hands did not warn them off: direct evidence for GDD assumption 9 |
| AD-61 | **Launch switches are one table,** and a CI test starts the game with every `--start` value for 120 frames. | A switch nobody has used since epic 2 is broken by epic 5 |
| AD-62 | **Scenes are thin.** Everything with a place on the span is built in code from `SpanGeometry`. Folders appear with their first file. | Makes "what is drawn is what is hit" impossible to break by hand; agents write scene files without an editor |
| AD-63 | **Event coverage.** Each story adds a scripted bot path to its own situation. The suite fails if any event kind or refusal reason has never been produced. | A random bot never reaches the deep situations; an event nobody has emitted is a rule nobody has run |
| AD-64 | **`ConsequenceRules.settle()` is an ordered list of small named steps,** each tested alone. | The one place for consequences must not become the one function nobody dares touch |

---

## Architecture Validation

### Validation Summary

Validated on 2026-11-20 by mechanical checks and by two independent readers who had seen none of the workflow. The first compared this document with `gdd.md`, `epics.md` and `project-context.md` and found 39 problems. The second re-read the document after those fixes and found 37 more (8 that would have made two agents write code that does not fit, 15 medium, 14 small), most of them left or caused by the first round of fixes. All are resolved in the text or handed on by name. The second round's fixes have had mechanical checks only.

| Check | First pass | After fixes | Notes |
|---|---|---|---|
| Decision Compatibility | 17 contradictions | Pass | Three were rules that defeated themselves (show-me setups in `tests/`; the purity check against `HandInput`; file names that produced banned class names) |
| GDD Coverage | 8 gaps | Pass | Log measures, warning spacing, display settings, the landing and sky, frame times, two more cue classes, the left/right check, planning's holds |
| Pattern Completeness | 8 loose interfaces | Pass | Settled by AD-67 |
| Epic Mapping | 6 schedule conflicts | Pass | Built-when table rewritten; epic 2 now follows epic 1 (AD-66) |
| Document Completeness | AD-53 cited but not stated | Pass | No placeholders; AD-1 to AD-68 all present |

### Coverage Report

**Systems covered:** the 20 of Project Context, each with its files in System Location Mapping.
**Patterns defined:** 5 novel (the parts ledger, the sound-and-cue table, hands, the plan as a list of actions, consequences in one place) and 7 standard. All but the plan, consequences, data access and global state come with a code example; those four are stated as rules and tables.
**Decisions made:** 68 (AD-1 to AD-68).
**Consistency rules:** 18, of which 15 are enforced by CI, a test or the engine.

### Decisions made during validation

| ID | Decision | Why |
|---|---|---|
| AD-65 | **The game has its own cry library** (`watch/sound/watch_cry_library.gd`), a copy of the ear test's adapted to the game's folder, table and tool. The game names nothing in the ear test's `scripts/` or `scenes/`. Chosen by Sonlm. | The ear test's script loads `trial_plan.gd` and names the ear test's loudness tool in its messages |
| AD-66 | **Epic 2 depends on epic 1.** `epics.md` and the GDD's sequence line are changed to say so. Chosen by Sonlm. | AD-22 runs the lesson and the listening round on the sim that epic 1 builds |
| AD-67 | **Interfaces fixed:** how a rule reports (`sim.emit`, `sim.refuse`); the fields of `NightEvent`; the warden's inputs (below); the countdown convention; `HoldRules` as the one owner of a hold's validity; `NightResult` and the session-owned playtest log; pause as an overlay; `TestCase` as the one test base; `StartState` as the only way to set up a situation. | These were the places two agents would have written code that does not fit together |
| AD-68 | **GDD coverage added:** `score_rules` for the night log's measures; warning spacing owned by `wave_rules`; display settings in `EngineGlobals`; `landing_view` and `sky_view`; dawn on the planning view; frame times in the night summary; the `PHYSICAL_GLOW` and `EVERYWHERE_ONLY` cue classes; the left/right check as a screen; `hold_timer` for planning's holds; the plank order in `SpanGeometry`. | Each was in the GDD with no home here |

**The warden's inputs and place (AD-67).**

- The sim holds the warden's position as a `Vector3` in the world axes of the span's numbers, at foot level. `WardenConstants.EYE_HEIGHT` gives the eye for `LookRules` and for the camera.
- `set_move(direction: Vector2)`: the wish to move in world X and Z, already turned from the keys by the camera's yaw, length at most 1.
- `set_view(yaw: float, pitch: float)`: radians; yaw 0 faces the far pier (−Z), positive yaw turns left; pitch 0 is level, positive looks up.

### Handed on

| Item | To |
|---|---|
| `project-context.md`: 8 open markers to fill and 12 rules this document overturns (rays and overlaps, `advance(delta)` and the clock, who owns the random generator, no `class_name`, the single test file, the single smoke run, the bus layout, folders, the loudness tool, the 3 dB step, "`project.godot` is still the ear test", "both presets") | `gds-generate-project-context`, run next |
| GDD wording: AD-6 (smooth distance), AD-7 (cut and skip, three falling cries, warning spacing), AD-17 (the wounded ear), AD-34 (dawn wins a tie), AD-26 (what a replay resets; hints on leaving), AD-50 and AD-67 (a hold that becomes impossible is cancelled on the next tick, not the same moment) | A `gds-gdd` update |
| GDD gaps 6 and 7 (a Diver whose section opens during its drop; hanging Grapplers when the name is called) | Option lists when epic 3 story 3 and epic 5 story 5 are created |
| Epic 1's setup story, and the pieces the built-when table adds to epic 2 | `gds-create-epics-and-stories`, when stories are written |
| The full table of input actions (only the mechanism and two examples are here) | Epic 1's setup story; it follows the GDD's Controls tables one to one |
| Whether the `eartest` feature override picks the main scene in an exported build | Checked by CI in epic 1's setup story (AD-43) |
| Whether `pan_pullout` −1 swaps the channels cleanly | The measurement test in epic 2 (AD-18) |
| Whether a night recorded on Windows replays on Linux | The recording's checksums will say, from epic 6 (AD-37) |

### Validation Date

2026-11-20

---

## Development Environment

### Prerequisites

- Godot 4.7.2 stable (the official build), on `PATH` as `godot` or named by `$GODOT`. Export templates for 4.7.2 are needed only for `tools/ci.sh --export`.
- Git, with the repository's hooks switched on (below).
- Python 3 with numpy, only for the offline audio tools in `game/tools/`.
- No addons, no package manager, no editor plugins.

### AI Tooling (MCP Servers)

No engine-specific MCP servers were selected (decided 2026-11-20): agents work headless on a server, and the Godot MCP servers reviewed drive a running editor through editor plugins. One can be added later for sessions on a machine with the editor open; that would be a change to this document.

### Setup Commands

```bash
# once per clone
git config core.hooksPath .githooks          # the pre-commit hook runs tools/ci.sh
godot --headless --path game --import        # also after adding or changing any asset or script with a class_name

# every change
tools/ci.sh                                  # import, checks, tests, smoke runs
tools/ci.sh --export                         # the same, then the builds

# run from source (the game's switches arrive with epic 1's setup story)
godot --path game                            # the game, once the main scene is switched
godot --path game res://scenes/ear_test.tscn # the ear test
godot --path game -- --show=list             # the show-me setups for manual checks
```

### First Steps

1. Refresh `_bmad-output/project-context.md` with `gds-generate-project-context`: 8 open markers to fill and 12 rules that this architecture overturns. Agents read that file first, so it must not contradict this one.
2. Run `gds-check-implementation-readiness` across the GDD, the UX documents, this architecture and the epics.
3. Write the GDD's wording changes back (see Handed on, in Architecture Validation).
4. Create epic 1's stories, starting with the setup story in "Built when".
