---
project_name: '3d_game'
user_name: 'Sonlm'
date: '2026-11-20'
sections_completed: ['technology_stack', 'engine_rules', 'performance_rules', 'organization_rules', 'testing_rules', 'platform_rules', 'anti_patterns']
existing_patterns_found: 14
status: 'complete'
rule_count: 102
optimized_for_llm: true
architecture: '_bmad-output/game-architecture.md (AD-1 to AD-68, 2026-11-20)'
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing game code in this project. Focus on unobvious details that agents might otherwise miss._

**Two things live in this repository.** The **ear test** (`game/scripts/`, `game/scenes/`, `game/audio/cries/`) is closed and keeps its own conventions. The **game**, The Mourning Watch, is built under `game/watch/` and follows `_bmad-output/game-architecture.md`. Rules below are for the game unless they say "ear test". AD-n ids point to the architecture; GD-n and UX-n to the design decision logs.

---

## Technology Stack & Versions

- **Engine:** Godot 4.7.2 stable, pinned. Forward+ renderer. Binary: `godot` on PATH or `$GODOT`. Do not change the version or the renderer. Upgrades happen only between epics.
- **Language:** GDScript, fully typed. No C#, no GDExtension, no addons, no autoloads, no MCP server. No HRTF plugin (DW-1 is a separate trial and would be an architecture change).
- **Physics is not used in the night** (AD-52): no bodies, colliders, rays or areas. The physics tick is only the simulation's clock, fixed at 60 per second.
- **Offline tools:** Python 3 + numpy, in `game/tools/` only. Never a runtime dependency.
- **The Godot project root is `game/`**, not the repo root: every command uses `--path game`.
- **Targets:** Windows 10/11 x64 and Linux x86-64, on itch.io. Stereo output. Keyboard and mouse.
- **Canvas (AD-69):** 1280×720, `canvas_items` stretch, `expand` aspect, as `project.godot` has it. Never change those lines. `DESIGN.md` sizes are at 1080p; only `watch_theme.gd` turns a token into a canvas size (two thirds, rounded). No other script writes a pixel size for a screen.
- **Menu keys (AD-70):** menus read the `watch_menu_*` actions from the `InputActions` table, not Godot's `ui_*` actions.
- **CI:** `tools/ci.sh` (repo root) = import, the purity and `print` checks, tests, and smoke runs of 120 frames: the game's main scene, `res://scenes/ear_test.tscn`, and the game once per `--start` value that exists (none yet; story 1.2 adds `night`, run as `--start=night --seed=1`). `--export` adds the ear test's builds and one start of the Linux build. Local only, run by the pre-commit hook. The purity check also fails on a base type other than `RefCounted` or a class of `watch/sim/` itself, and the `print` check covers the whole `print` family.
- **Agents work headless: no editor, no screen, no speakers.** CI sees no rendering and hears no sound.
- **`project.godot` is the game's** since story 1.1: the main scene is `res://watch/main.tscn`, the user folder is pinned to `mourning_watch`, and `.eartest` overrides of the name, the main scene and the user folder keep the ear test's two presets opening the ear test and writing to `app_userdata/Ear Test` (AD-12, AD-43). Run the ear test from source with `godot --path game res://scenes/ear_test.tscn`.

## Critical Implementation Rules

### Engine-Specific Rules

**Typing and scripts**

- **Type everything:** variables, parameters, returns, loop variables, lambdas. An untyped declaration is a parse error (`untyped_declaration=2`).
- Write the type out (`var x: float = 0.0`). `:=` is used only for `const X := preload(...)`.
- Use typed arrays and typed dictionaries (`Dictionary[int, DeadView]`). A value read from JSON or `ConfigFile` is `Variant`: check it with `is` before use.
- **Game scripts use `class_name`** (AD-11): one per script that another script names by type, PascalCase, matching the file. A script nobody names by type (a screen's root, `main.gd`) declares none. Ear test scripts keep `const X := preload(...)` and get no `class_name`.
- **No bare generic or engine word as a `class_name`** (AD-41): `NightPlan`, `NightCommand`, `WatchSettings`, `WatchSession`, `WatchFaults`, `watch_theme.gd`. Never `Plan`, `Settings`, `Theme`.
- After adding or renaming a `class_name`, run `godot --headless --path game --import`, or the name does not resolve.
- `##` doc comment on every script and every non-obvious member, saying why.

**The night is a simulation (AD-1, AD-2, AD-32)**

- One node-free `NightSim` (`watch/sim/`) owns every rule and all state of a night. **Something is a rule, and lives in the sim, if a pause must freeze it, the gate 2 log scores it, or another rule depends on it.** That includes the warden's walking, what the warden is looking at, which cry holds which slot, and when the ally calls.
- **Into the sim, nothing but:** `set_move(Vector2)` (world X/Z wish, length ≤ 1), `set_view(yaw, pitch)` in radians, and `command(NightCommand)` for each press and release. Nodes send button states, never meanings.
- **Out of the sim:** `advance()` moves one tick and returns an ordered `Array[NightEvent]`; state is read through typed fields. Only the sim changes night state. Nothing outside `watch/sim/` assigns to a sim field.
- **State says what exists; events say what just happened** (AD-49). A view reconciles with sim state every tick (creates what is missing, frees what is gone) and uses events only for one-shot effects. A consumer handles its events first, then reconciles.
- Consumers are callbacks registered with the night screen (`on_tick(events, sim)`), not a base class. They never emit events or call the sim while handling one. An event about an unknown id is a fault and is skipped.
- Godot signals are for UI wiring inside one screen. They never carry a rule of play.

**Rules, time and randomness inside the sim**

- Rule scripts are `*_rules.gd`: static functions only. A **pure query** takes the pieces it reads and returns a value. A function that **changes state** takes `sim: NightSim` last, returns nothing, and reports with `sim.emit(event)` or `sim.refuse(reason)` (AD-67).
- **Store base facts only** (planks, rails, hooks, positions, oil). Strength, "open", load, "lit" and "locked" are computed when needed, never stored (AD-35).
- **Time is whole ticks** (AD-33). Constants are in seconds with `_S`; they are converted once into `sim.ticks` (`NightTicks`). Rules count ticks down; nothing adds up float seconds. Begun on tick T and lasting N ticks means done on tick T + N.
- **Every rule has a numbered step in the tick order** (AD-34, 13 steps). Add the step before writing the rule. Nothing ticks outside it. Dawn wins a tie with a loss on the same tick.
- **Randomness:** the sim's one seeded generator is `sim.rng`, used only inside the sim. A consumer that needs variety owns its own generator seeded from the night's seed. Never `randi()`, `randf()`, `randomize()`, `Array.shuffle()` or `pick_random()`.
- **Parts move only through `SpanRules.move_parts()`** (the parts ledger). No other code changes a plank or rope count.
- **When the span changes, change only the span.** `ConsequenceRules.settle()` decides what follows for the dead, rigs, lanterns, parts, hooks and the warden, as an ordered list of small named steps (AD-48, AD-64). `HoldRules` alone cancels a hold that became impossible.
- A phase change always emits exactly one event, from the function that makes the change. Event kinds are past tense, upper snake, and name who (`DEAD_FELL`, `SECTION_FELL`).
- No `await`, scene-tree timers or tweens for anything timed by a rule.

**Where things are**

- `SpanGeometry` is the only source of positions and shapes. **Scenes are thin** (AD-62): a `.tscn` holds a root node, its script and children with no place on the span. Everything on the span is created in code and placed by asking `SpanGeometry`. Never type a span coordinate into a `.tscn`.
- **The span's numbers:** sections are 1 to 6 (1 at the far pier), never zero-based; `0` means none. `along` is metres from the far pier. The span runs along Z with the town at +Z; `world_z = along − length`. Left and right are the warden's when facing the far pier (`LEFT` = −X), also in planning.
- **No literal 6 or 30** outside `night_defs.gd` and tests: ask the `NightDef` (AD-42).
- A view that moves holds a `TickBlend` and blends the last two ticks; a teleport calls `snap()`. Project-wide physics interpolation stays off.
- In a hand-written scene, reference resources by `res://` path only and never invent a `uid://` value. Commit the `.uid` and `.import` files the import writes.

**Sound**

- The game loads its own bus layout (`watch/sound/watch_bus_layout.tres`); the ear test's `default_bus_layout.tres` is not touched. Slot buses sit to the right of the level buses: a bus can only send to a bus on its left, or Godot silently sends it to Master.
- Bus values have one owner each (AD-51): constants through `EngineGlobals.apply()` (never during a night); the settings layer through `apply_settings()`; a cry slot's send and filters through `CryAudio`. Edits in the editor's Audio panel are overwritten. Change the constant.
- The audio node never schedules or decides anything: the sim emits each part of a warning as a timed event, and `CRY_STARTED` carries its slot.
- **A sound that is not a row in `content/sound_cues.gd` cannot be played**, and every row names its visual cue (AD-45). Cues come from sim state, never from whether audio is playing.

**Errors and logs (AD-28, AD-29)**

- A designed "no" (a second strike on a shaken hook) is `sim.refuse(reason)`: an event, never an error.
- A setup problem (a missing clip, bus or table entry) is collected at start, reported with `push_warning` or `push_error`, and shown on the title. No `assert`, no crash.
- A fault (a bug) is `faults.report(&"system.what", detail)` on the night's `WatchFaults`, the only code that calls `push_error` for one. Put the value back in range and carry on.
- **No `print` in runtime code** outside `watch/debug/`. A clean run prints nothing.

### Performance Rules

- **Frame rate (GD-31)**, over the whole 12-minute night including wave 6:
  - GTX 1050-class, 1080p, low fog: average 60 FPS or more, 1% lows 45 or more.
  - Intel Iris Xe, 720p, fog-sprite fallback: average 30 FPS or more, 1% lows 24 or more.
- **Peak scene to budget for:** 18 dead on the span, 3 lanterns, fog, 4 cries.
- Every fog effect needs a low setting and a sprite fallback. The low end is met with those and resolution, never by choosing another renderer. Godot can fall back to OpenGL by itself when Vulkan fails: the game records which renderer started and treats anything but `forward_plus` as a setup problem (AD-57).
- A sprung rig reacts within 0.3 s of the blow. Replaying a lost night starts within 3 s. Start-up time and download size: GDD, Technical Specifications.
- **Nothing carries over between nights** (AD-4, AD-51): each night is a new `NightSim` and a freshly instanced night scene; the old ones are freed. Engine state that outlives a scene (audio buses, mouse mode, tree pause) is reset through `EngineGlobals`. Never reset a night in place.
- Preload everything once behind the title. No `load()` during play.
- The dead have no physics or navigation: a position along the span, a side lane and a phase. Their views are made and freed only by `DeadViews`; pooling is decided in epic 7 by measurement, not before.
- Neither reference machine is in hand yet (DW-12). Never report a frame-rate target as met from the dev server.

### Code Organization Rules

- **Game code:** `game/watch/` by system, each scene beside its script: `core/` (a closed list of seven scripts), `content/`, `sim/`, `night/`, `sound/`, `planning/`, `lesson/`, `screens/`, `log/`, `debug/`. The architecture's System Location Mapping names the file for every system. A folder is created with its first file.
- **`watch/sim/` is node-free.** Scripts extend `RefCounted` and name nothing outside `watch/sim/`, `watch/content/` and `WatchFaults`. CI fails on `Node`, `get_tree`, `Input.`, `AudioServer`, `FileAccess`, `Time.`, `await`, `print(` or a global random call there.
- **The ear test is closed.** Do not edit anything in `game/scripts/`, `game/scenes/`, `game/audio/cries/`, `default_bus_layout.tres` or `game/tools/measure_loudness.gd`, and keep its 120 checks passing. The game uses nothing from it: its cry library, clips, loudness table and loudness tool are its own (AD-39, AD-65).
- `watch/debug/` (overlay, trace, replay, the bot, show-me setups) is one-way: nothing outside it names a debug class, and public builds leave it out.
- `tests/` and `tools/` are not runtime: no runtime script names anything in them.
- Screens do not reach into each other. A screen is handed `WatchSession` and reports to `Main` with a signal; `Main` holds the flow and nothing else.
- **Names:** files lower snake; sim suffixes `_rules`, `_state`, `_constants`; outside the sim `_view`, `_audio`; scripts in `watch/screens/` end in `_screen`. String ids lower snake; bus names PascalCase `StringName` (`&"CrySlot1"`); input actions `watch_` + lower snake; fault codes `system.what`.
- **Every number that is a rule of play or of sound is a named constant** with a `##` comment citing its GD-n or UX-n and a unit suffix (`_S`, `_MS`, `_DB`, `_HZ`; metres carry none), in one `*_constants.gd` per system. GDD numbers are starting values; tuning is a commit (AD-9). There are no tuning files.
- **A night's content** (timetable, section count, starting parts, names, hints, lines) is a `NightDef` built in `night_defs.gd`, never constants and never a `.tres`.
- Settings are read through the `WatchSession` a screen was handed. Launch switches are parsed once into `LaunchOptions`. Nothing reads a global.
- **Assets:** the game's sounds live under `game/audio/watch/`, each folder with its own `CREDITS.md`. Cry clips: `<freesound id>_<author>_<n>.wav` in `game/audio/watch/cries/<level>/`, each with an entry in that folder's `loudness.json`. A `placeholder_*.wav` never sits beside real clips. Raw recordings stay in `source_audio/`, outside the Godot project.

### Testing Rules

- **No test framework** (AD-27). One test file per system, `game/tests/watch/test_<system>.gd`, extending `TestCase` (`tests/test_case.gd`); story 1.2 adds `WatchTest` on top of it for tests that need a night. The runner finds every `test_*.gd` and every `_test_<topic>()` by itself. A test runs to its end in one go: no `await`, and a script error inside an expect window fails it. The ear test's tests are in `tests/ear_test/test_ear_test.gd`.
- Assert with `_check(name, ok, detail)`. Any engine error or warning during the run fails the suite; a test that provokes one on purpose wraps it in `_expect_begin()` / `_expect_end(name, [[kind, text, count]])`.
- **Build order for every story** (AD-46): the failing test first, then constants, state, the tick-order step, the rule and its events, shapes and consequences, the sound-and-cue row; only then the view and the sound; then a bot path and a show-me setup. The sim part passes before anything is drawn.
- **Set up a situation only through a `StartState` on the test's own `NightDef`**, then use commands and ticks. Never write sim fields from a test.
- Write spec values literally in the test, with the GDD's value in a comment. Never read them from the constants under test.
- Tests drive the sim by ticks. Outside the sim, swap in `Callable`s and paths (folder listing, clip loader, results folder). No real waiting, no mocks.
- **Every story adds a scripted bot path** to its own situation. The suite fails if any `NightEvent.Kind` or `NightTypes.Reason` has never been produced (AD-63), and bot nights check on every tick that parts are conserved and no threat arrives before its full warning.
- Test seeded logic over many seeds. Tests write only under a `user://..._selftest` folder, and remove it first.
- **Headless cannot check** real sound, panning, what is on screen, mouse capture or feel. List those as manual checks for Sonlm in the story, each with a **show-me setup** (`--show=<name>`, in `watch/debug/show/`) that puts Sonlm in exactly that situation (AD-56). A story without one is not done. Never report such a check as verified.
- Run `tools/ci.sh` before calling work done. Never commit with `--no-verify`.

### Platform & Build Rules

- **After adding or changing any asset, and on a fresh clone:** `godot --headless --path game --import`. `ResourceLoader.list_directory()` only sees imported files.
- **Non-resource files read at runtime** (JSON, text) are not exported unless listed in the `include_filter` of each preset that needs them. The ear test's two presets must keep exactly their own filter line: one of its tests counts it.
- **Presets:** `Linux` and `Windows` are the ear test's (names kept, feature `eartest`). The game adds two playtest presets (feature `playtest`) in epic 2 and two public ones in epic 8. Keep each Windows and Linux pair in step.
- `tests/*` and `tools/*` are excluded from builds. Public builds also exclude `watch/debug/` and the ear test.
- **In an exported build `res://` is read-only and raw source files do not exist.** Guard editor-only checks with `OS.has_feature("template")`. Write only to `user://`.
- **The playtest log and night recordings are written only with the `playtest` feature or `--log`** (AD-53). A test, a smoke run or a plain editor run writes nothing. Log files are never overwritten (a clash gets `_2`, `_3`), and every row is flushed as it is written. Only `PlaytestLog` writes them.
- Debug tools are guarded by `OS.has_feature("playtest") or OS.has_feature("editor")`; the F3 overlay also needs `--debug`. No cheat keys.
- WAVs import as mono by project default. Do not override that per file for cries.
- **Input:** actions are registered in code from the one table in `InputActions`, by physical position (`physical_keycode`), and shown as the player's keyboard prints them. `project.godot`'s input map stays empty. No rebinding and no gamepad in the one-night game.
- Every night hold has a press-once alternative with the same timing (UX-39), handled inside `HoldRules`; views do not know which is on. Planning's two 1 s holds stay holds.
- Losing window focus pauses the lesson and the night. Pause is an overlay, not a screen change: it resets nothing.
- **No network code.** The public build collects nothing.
- Fresh clone: run `git config core.hooksPath .githooks`, or the pre-commit CI does not run.

### Critical Don't-Miss Rules

**Sound is the game**

- **One kind of cry per level:** shrieks above, sobs inside, whispers below. The ear test's `MIX_CRY_KINDS = true` was a test condition. The game never mixes kinds.
- **Loudness:** every clip plays at its measured gain for its level. Two cries at the same distance stay within 1 LU. After changing a game clip, a slot or level effect, or a sound setting, run `godot --headless --path game -s res://tools/measure_watch_loudness.gd -- --write`, then the same with `-- --verify`. Never balance with bus volume.
- **Distance loudness is a rule, not the engine's** (AD-6): 0.6 dB per metre along the span only, capped at 15 dB. Players use `ATTENUATION_DISABLED`; `CryMix` sets the gain and the engine only pans.
- **Four cry slots** (AD-5, AD-7). A warning holds a slot for its whole length and may cut the farthest deck cry; a deck cry without a slot skips to its next 8 s mark. At most three falling cries at once.
- Keep the rear-shadow front/back cue, applied per cry in its slot. No HRTF.
- **A wound** (GD-62, GD-66) cuts every sound that has a place by up to 12 dB, growing from nothing ahead or behind to the full cut at that side of the head; cries, the tune and the wind are also dulled. The ally's voice and the warden's hands are never cut. One pure function gives the cut for every sound.
- **The tune** takes a free cry slot before any other deck cry and is never the cry a warning cuts (GD-65).
- No AI voices and no AI-made cries. Every asset allows commercial use and is credited.

**The night screen**

- **No HUD at night:** no prompts, bars, rings or icons. The only things drawn over the view are the ally's caption and, if switched on, the centre dot. The F3 overlay is a debug tool and never appears in a session.
- No screen shake, no full-screen flash, no camera bob or roll. Nothing flickers faster than 3 times a second. Full-view changes are slow fades.
- **Gray boxes until gate 2 passes.** No art, shader or woodcut work before epic 7.
- Pause stops and silences everything (UX-24).

**Decisions**

- Rules and numbers are decided in the GDD and UX decision logs (GD-n, UX-n); structure in the architecture (AD-n). Read the decision log first. GDD draft 0.7 carries the rules the architecture changed (GD-56 to GD-62). If the two still differ on a rule of play, the GDD holds and the difference goes to Sonlm.
- **Deferred on purpose** (AD-55): the woodcut technique, fog and its fallback, pooling, the hands' models, HRTF, gamepad and rebinding, saving, and several spans. An agent that meets one stops and puts options to Sonlm. Silence is not permission to choose.
- A case neither the GDD nor the architecture covers goes to Sonlm as options. Never pick one silently.
- Never claim that newcomers can place threats by ear (only Sonlm was tested), or that the game is deaf-playable (the muted night in epic 8 has not run).

---

## Usage Guidelines

**For AI agents**

- Read this file before implementing any game code, then the sections of `_bmad-output/game-architecture.md` your story touches. Its Executive Summary says how to read it.
- Follow every rule as written. When in doubt, take the more restrictive reading.
- This file is a digest. Where it and the architecture differ, the architecture holds; say so, so this file can be corrected.

**For humans**

- Update when the architecture, the engine version, CI or the folder layout changes.
- Remove a rule once the code makes it obvious.

Last Updated: 2026-11-20
