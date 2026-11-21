---
baseline_commit: e83e2da5dfd47be2a96424c131507bb81d34d062
---

# Story 1.3: The warden walks and looks

Status: review

<!-- Created 2026-11-21 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As the warden,
I want to walk the deck and look around in first person,
so that I can go to any part of the bridge.

Delivers: GDD Controls and Input (W A S D, mouse); GD-19 (3.5 m/s), GD-22. Architecture AD-13, AD-20, AD-44, AD-52, AD-67 (the warden's inputs and place). Comfort limits of `EXPERIENCE.md`, Accessibility Floor (no bob, no roll). Also closes DW-26 (in part), DW-29, DW-30 and DW-31.

## Acceptance Criteria

1. **Where a night starts.** Given a night has started, when nothing has been pressed, then the warden stands on the town pier landing (at `SpanGeometry.warden_start()`), facing the far pier (yaw 0, pitch 0).
2. **Walking speed.** Given the warden on a section with planks, when forward is held for 60 ticks, then the warden has moved 3.5 m (GDD: 3.5 m/s, GD-19). There is no sprint and no jump.
3. **Keys by position.** Given W, A, S and D, when they are pressed on any keyboard layout, then they act by physical position (AD-20).
4. **Look at once.** Given the mouse, when it moves, then the view turns at once, not on the next tick. The camera has no bob and no roll.
5. **Edges stop the warden.** Given the edge of what can be walked on (the sections that have planks, and the landing), when the warden walks into a rail side, the far pier or the landing's limits, then the warden stops there. Nothing is decided by a physics body, a collider or a ray (AD-52). (Where "there" is: decision D1.)
6. **Smooth between ticks.** Given the warden's node, when frames are drawn between ticks, then the camera follows the sim's position through a `TickBlend`, with no visible step at 60 FPS or above.
7. **Bot nights.** Given the bot, when it walks whole nights in the sim alone, over many seeds, on the 6-section and the 4-section `NightDef`, then no fault is reported, and the warden is never outside what can be walked on.

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setups below. Follow the build order (AD-46): failing test first; constants, state, tick step, rule; then the view; then the bot path, the show-me setups and the manual checks.

**Manual checks for Sonlm** (an agent cannot fully verify these headless; never report one as verified unless judged from frames as the dev-story chores describe):

- **M1** (`--show=walk`): walk the whole span and back; turning feels immediate; walking speed feels like a walk. Feel and mouse capture: **cannot** be judged from frames, needs Sonlm.
- **M2** (`--show=walk_close`, DW-31): from the middle of the span, the sections ahead at 5, 4 and 1 planks can be told apart at a glance. Can be judged from Xvfb frames (say it was llvmpipe, not a real GPU). If they cannot, stop and put the levers to Sonlm as options (Dev Notes "DW-31"); do not tune D2's sizes silently.

## Decisions for this story

Points that neither the GDD nor the architecture settles. **Sonlm chose the recommended option for all three on 2026-11-21** (see "Decisions taken with Sonlm" in Dev Notes).

- **D1. Where "stops there" is.** (Recommended) **0.3 m from every edge.** The warden's feet keep `WardenConstants.CLEARANCE = 0.3` m from every edge of the walkable area that is not shared with another walkable part: the two rail sides, the far pier's face, the landing's sides and back, and the edge of a section with no planks. Shared edges (section to section, section 6 to the landing) are walked across freely. With D2's sizes that gives: x from −2.2 to 2.2; along from 0.3 (far pier) to `length + 4 − 0.3` (back of the landing). The eye (1.6 m) then never sits inside a rail rope (1.0 m, at x ±2.5) or a post. Declined: no clearance (the camera's near plane, 0.05 m, would cut into posts and the far pier); clearance only at solid things and none at a plankless edge (two rules where one does).
- **D2. Getting the mouse back before the pause screen exists.** (Recommended) **Esc frees the mouse; a left click captures it again.** The night becomes a first-person screen (captured mouse). Until the pause overlay arrives in epic 5, `watch_pause` (Esc) only frees the mouse and stops mouse look; the sim keeps running (no pause yet) and walking still works. A left click while the mouse is free captures it again and is not sent anywhere else. Epic 5 replaces this with the pause overlay. Declined: Esc quits the game (loses the night on a reflex press); nothing (the only way out is closing the window).
- **D3. Where a show-me setup can place the warden.** (Recommended) **`StartState.warden_along`.** A float, metres from the far pier along the centre line; `-1.0` (the default) means the landing's centre, `SpanGeometry.warden_start()`. A start that cannot be stood on (D1) is a fault `warden.bad_start`, and the warden starts at the landing. It lets `--show=walk_close` (M2) start mid-span, and stories 1.4 to 1.6 put the warden beside the section their checks need. AD-67 makes `StartState` the only way to set up a situation, so this is where it goes. Declined: every show starts on the landing (M2 then needs Sonlm to walk there; Xvfb frames could only judge the landing view).

Settled without a question (each follows from the documents or from the ear test Sonlm already played):

- **Walking is instant and the same in every direction.** Full speed on the first tick a key is held, still on the first tick none is; strafing and walking back are 3.5 m/s too, and a diagonal is 3.5 m/s (the wish has length ≤ 1, AD-67). AC 2 (60 ticks → 3.5 m) only holds with no ramp.
- **Look values are the ear test's** (`game/scripts/listener.gd`, `ear_test.tscn`): 0.0025 rad per pixel of mouse travel, pitch clamped to ±80°, field of view 75° (Godot's default, also the ear test's). No smoothing, no acceleration. Mouse sensitivity, Invert look and Field of view become settings in epic 5 (UX-25, UX-39); until then they are named constants in `warden.gd`, not rules.
- **Walking emits no event.** A position is continuous state, read from the sim, never sent as an event (architecture, Event System). Stopping at an edge is not an event either. No new `NightEvent.Kind`.

## Tasks / Subtasks

Build order (AD-46). Do not touch `watch/night/` until T1 to T4 pass.

- [x] **T1. Tests first (AC 1, 2, 5, 7)**
  - [x] 1.1 `tests/watch/test_warden.gd` (extends `WatchTest`). Write every spec value literally with its source in a comment:
    - AC 1: a fresh sim's `sim.warden.position` equals `sim.geometry.warden_start()` (on the one night: `Vector3(0, 0, 2)`, along 32); `sim.yaw` and `sim.pitch` are 0 before any input.
    - AC 2: from a `StartState` with `warden_along = 17.5` (mid section 4), `set_move(Vector2(0, -1))` (toward the far pier) for 60 ticks moves the warden by 3.5 m (GD-19) in −Z, within 0.001 m; x unchanged; y stays 0 on every tick (no jump). Strafing is the same speed: 30 ticks of `(1, 0)` from x 0 end at x 1.75 (60 would reach the rail limit). A diagonal `Vector2(1, -1).normalized()` covers 3.5 m in 60 ticks. Half a wish (`(0, -0.5)`) covers 1.75 m.
    - Walking from the landing onto section 6 and on to section 1 crosses every shared edge without stopping (60-tick blocks; check the along after each block).
    - AC 5 / D1, each from a placed start, 120 ticks of pushing: into the left rail → x = −2.2; into the right rail → x = 2.2; into the far pier (along 0) → along 0.3; into the landing's back → along `length + 3.7` (33.7 on 6 sections, 23.7 on 4); into the landing's side → x = ±2.2; each within 0.001 m. Diagonal into a rail slides: x stops at the limit and along keeps moving at its own share (`wish.y × 3.5 / 60` a tick).
    - A section with no planks blocks: `StartState.planks = {3: 0}`, start on section 4, push toward the far pier → along stops at `section_end(3) + 0.3` = 15.3; from section 2 pushing toward the town → `section_start(3) − 0.3` = 9.7. (Crossing it is story 1.6.)
    - D3: `warden_along = 17.5` starts at `Vector3(0, 0, 17.5 − 30)`; a start on a plankless section, on the far pier or past the landing reports `warden.bad_start` once (inside `_expect_begin()` / `_expect_end()`) and starts at the landing.
    - `WardenRules.can_stand(position, sim)` is true at every position the warden reaches in the tests above and false at x 2.3, at along 0.2, on a plankless section, and at along `length + 3.8`.
  - [x] 1.2 `tests/watch/test_night_sim.gd` (DW-26): after 600 ticks, two sims with the same seed and **different** move wishes have different `checksum()`s; the same wishes give the same checksum (already there; it now covers a moving warden). Leave "a roll changes the events" open: no rule rolls yet (DW-26 stays open for that half; say so in its entry).
  - [x] 1.3 `tests/watch/test_span_geometry.gd` (DW-29): the eye-height check moves to `test_warden.gd` as `WardenConstants.EYE_HEIGHT` 1.6 (D2 of story 1.2).
- [x] **T2. Constants and state (AC 1, 2, 5)**
  - [x] 2.1 `watch/sim/warden_constants.gd` `WardenConstants`: `WALK_SPEED: float = 3.5` (GD-19; metres per second; say the unit in the `##` comment, as metres carry no suffix), `EYE_HEIGHT: float = 1.6` (moved from `SpanGeometry`, DW-29; D2 of story 1.2), `CLEARANCE: float = 0.3` (D1; not a GDD value: a gray-box size, tuned by eye in M1).
  - [x] 2.2 Remove `EYE_HEIGHT` from `SpanGeometry`; point every user at `WardenConstants.EYE_HEIGHT`.
  - [x] 2.3 `watch/sim/warden_state.gd` `WardenState`: `position: Vector3` (feet, world axes, y 0 on the deck and the landing; AD-67). Base facts only (AD-35). The timed moves (edging, crossing, climb back, knockdown) join it in stories 1.5, 1.6 and epic 4; do not add them.
  - [x] 2.4 `StartState.warden_along: float = -1.0` (D3), with its `##` line.
  - [x] 2.5 `NightSim`: `var warden: WardenState`, built in `_init` from `def.start` (D3; `warden.bad_start` as in T1.1); the move per tick `walk_step: float = WardenConstants.WALK_SPEED / NightTicks.TICKS_PER_SECOND`, worked out once in `_init` (AD-33: convert once, never add up seconds); `checksum()` also hashes the warden's position (DW-26).
- [x] **T3. The rule (AC 2, 5, 7)**: `watch/sim/warden_rules.gd` `WardenRules` (Dev Notes "The walking rule"). `walk(sim)` changes state and returns nothing; `can_stand(position, sim) -> bool` is a pure query. Called from step 1, after the wish and the view are taken (AD-34: "the warden moves (AD-52)"). Update step 1's `##` comment: walking is done; the look target is story 1.4.
- [x] **T4. Run the sim tests**: `godot --headless --path game --import` (new `class_name`s), then the tests. T1 passes before T5 starts.
- [x] **T5. The view (AC 1, 3, 4, 6)**. Only now.
  - [x] 5.1 Tests first: `tests/watch/test_tick_blend.gd` and `tests/watch/test_warden_node.gd` (Dev Notes "Tests of the node"), and the key-position check of AC 3 added to `tests/watch/test_input_actions.gd`.
  - [x] 5.2 `watch/night/tick_blend.gd` `TickBlend` (Dev Notes "TickBlend").
  - [x] 5.3 `watch/night/warden.gd` `Warden` (Dev Notes "The warden's node").
  - [x] 5.4 `night.tscn`: the existing `Camera3D` moves under a new `Warden` node (`Node3D`, script `res://watch/night/warden.gd`). No transform typed on either: `night.gd` and `warden.gd` place them in code (AD-62). Reference the script by `res://` path, never a made-up `uid://`.
  - [x] 5.5 `night.gd`: `setup()` hands the warden the sim's start (`warden.start_at(sim)`, which snaps the blend); `_physics_process` becomes the architecture's loop: `set_move(_warden.move_direction())`, `set_view(_warden.yaw(), _warden.pitch())`, `advance()`, consumers. The warden is a consumer too (it pushes the sim's new position into its `TickBlend`), added after the span view. Remove the fixed-camera code and the "story 1.2: no warden yet" comment.
  - [x] 5.6 `main.gd`: the night (both `--start=night` and `--show`) enters as `EngineGlobals.ScreenKind.FIRST_PERSON`; the comment about story 1.3 goes. With DW-30 (T7).
  - [x] 5.7 D2: the mouse release and re-capture, in `warden.gd`, through a new `EngineGlobals.capture_mouse(on)` (Dev Notes "The warden's node"). `test_engine_globals.gd`: `capture_mouse` runs headless with no error or warning (the mode itself is M1).
- [x] **T6. Bot and show-me setups (AC 7; M1, M2)**
  - [x] 6.1 `NightBot.walk` (Dev Notes "Bot"), added to `paths()`. `test_bot_nights.gd`'s per-tick check gains: `WardenRules.can_stand(sim.warden.position, sim)` on every tick, on every path.
  - [x] 6.2 `ShowSetups`: rows `walk` and `walk_close` (Dev Notes "Show-me setups"). `test_show_setups.gd`: both exist, their starts are what the Dev Notes give, and a sim built from each reports no fault.
- [x] **T7. `Main`'s choice of screen (DW-30)**: move the choice into a static function a test can call (Dev Notes "Main"), and add `tests/watch/test_main_flow.gd` for the conflict, unknown-show, no-debug and list branches. `Main` behaves exactly as before except that the night is first person.
- [x] **T8. CI**: no new step needed: the two new show-me setups are smoke-run by the existing loop over `--show=list`. Check that CI's show count goes from 1 to 3 and every smoke run stays free of warnings (capturing the mouse headless must log nothing).
- [x] **T9. Docs**: `game/WATCH.md` (the night is now walked: W A S D, mouse, Esc frees the mouse and a click takes it back until the pause screen in epic 5; `--show=walk`, `--show=walk_close`); `_bmad-output/project-context.md` (Dev Notes "Docs"); `deferred-work.md`: close DW-29, DW-30 and DW-31 (or record what M2 found), and narrow DW-26 to the half still open.
- [x] **T10. Close**: `tools/ci.sh` passes. Fill in the Dev Agent Record. Run the end-of-story chores of `_bmad/custom/gds-dev-story.toml` (M2 on Xvfb with `--show=walk_close`; M1 listed as NOT verified, needs Sonlm; agent time; commit). Set Status to `review`.

## Dev Notes

### What this story is

The warden arrives. The sim gets a `WardenState` and a `WardenRules` that moves the feet inside what can be walked on; the night screen gets a `Warden` node with mouse look and a `TickBlend` that the camera rides on. The night becomes a first-person screen. Three deferred items from story 1.2 close here (DW-29 the eye height, DW-30 `Main`'s branches, DW-31 reading the far sections), and DW-26 half closes (inputs now change the checksum).

**Not in this story** (do not build ahead): `LookRules` and the look target (1.4: the first rule that reads it); hands, holds, strip, re-lay, `HandRules`, `HoldRules`, `REFUSED`, `NightTypes.Reason`, the forearm, sending press and release commands from `night.gd` (1.4); load, creak, collapse, the climb back (1.5); edging round an open section and crossing a gap (1.6); the pause overlay, focus-loss pause and the settings for sensitivity, invert and field of view (epic 5); the centre dot (epic 5); footsteps or any sound (epic 2 on). No HUD. Gray boxes.

### Current state of the files this story changes (read 2026-11-21, commit `e83e2da`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/sim/night_sim.gd` | 13 steps; step 1 stores `move_wish`, `yaw`, `pitch`, `commands`; no warden; `checksum()` = tick, `rng.state`, part counts; `set_move` clamps to length 1 (`sim.move_too_long`), non-finite wish/view is `sim.bad_input`; `sim.bad_def` | `warden: WardenState`, `walk_step`; step 1 calls `WardenRules.walk(self)` after storing the inputs; checksum adds the position | Everything else, including the step list the test compares literally and the faults |
| `game/watch/sim/span_geometry.gd` | Holds `EYE_HEIGHT = 1.6`; `warden_start()` = landing centre (along `length + 2`); `deck_box(n)`, `landing_box()` (5 × 4 m, at y 0), `far_pier_box()` | `EYE_HEIGHT` leaves (DW-29). Nothing else needs to change; `WardenRules` asks it for the boxes | All shapes and the plank order |
| `game/watch/sim/start_state.gd` | `planks`, `stripped_rails` | `warden_along` (D3) | Both fields and their meaning |
| `game/watch/night/night.gd` | Builds sim and `SpanView`; places the fixed `Camera3D` at `warden_start() + EYE_HEIGHT`; ticks with `set_move(ZERO)`, `set_view(0, 0)` | The warden node replaces the fixed camera; the loop sends the warden's move and view | `setup()` before the tree; `add_consumer`; `night.no_setup` warning when run alone; consumers called in order |
| `game/watch/night/night.tscn` | Root `Night` + `Camera3D` + `DirectionalLight3D` + `WorldEnvironment` (black, ambient 0.6) | `Camera3D` moves under a `Warden` node | Light and environment as they are (M1 of 1.2 was judged with them) |
| `game/watch/main.gd` | Chooses title, night or show in `_ready()`; `_show_night` enters as `MENU` | The choice moves into a testable function; the night enters as `FIRST_PERSON` | One `WatchSession`; problems pushed once; `--show=list` quits with 0 or 1; screen changes deferred; the debug tools loaded by path only |
| `game/watch/debug/bot/night_bot.gd` | `paths()` = `[span_counts]`, 600 ticks, wish `from_angle(i × 0.05) × 0.9` | Adds `walk`. `span_counts` keeps its inputs; its warden now really walks (still never out of bounds: the walking rule stops it) | The signature `(def, seed, faults, each_tick) -> NightSim` |
| `game/watch/debug/show/show_setups.gd` | One row, `span_counts` | Rows `walk`, `walk_close` | `def_of()` naming the night after the setup; `list` reserved |
| `game/tests/watch/test_bot_nights.gd` | Per tick: parts totals and no fault; twice-run; event coverage | Per tick also `can_stand` | Everything else |
| `game/tests/watch/test_night_sim.gd`, `test_span_geometry.gd`, `test_input_actions.gd`, `test_show_setups.gd` | As story 1.2 left them | T1.2, T1.3, T5.1, T6.2 | Everything else |

`warden.gd`, `tick_blend.gd`, `warden_rules.gd`, `warden_state.gd`, `warden_constants.gd` do not exist yet.

### The walking rule (`WardenRules`, AD-52)

- **What can be walked on** this tick: the floor rectangle (x across, z along, from `SpanGeometry.deck_box(n)`) of every section with at least one plank, and the landing's (`landing_box()`). Ask `SpanGeometry` for every edge; type no coordinate.
- **`can_stand(position, sim) -> bool`** (pure): the point, moved `CLEARANCE` in each of the four axis directions (±x, ±z), is still on a walkable rectangle each time (D1). Points on a shared edge between two walkable rectangles count as on both. With the one-night sizes this gives the numbers of T1.1.
- **`walk(sim)`**: `step = sim.move_wish × sim.walk_step` (metres this tick, world X and Z). Resolve the X part first, then the Z part from the new X: on each axis, take the whole move if `can_stand`, otherwise move to the farthest point on that axis that can be stood on, which is the clearance limit (AC 5: "stops there", not a step short; the tests check within 0.001 m). The axis that is not blocked keeps its full share (sliding along a rail). Because every walkable rectangle is axis-aligned, the limit is found from the rectangles' edges, not by searching in small steps. y stays 0.
- A wish of zero moves nothing and costs nothing. The rule never emits and never faults on a normal push into an edge (an edge is not a mistake).
- **Not yet:** a warden standing on a section whose last plank is taken (story 1.4: "the warden stays in place and can walk off"; story 1.6 makes it an edging). Today no rule can take a plank, so a warden can only be off the walkable area through a bad start, which D3 refuses. Write `walk()` so that 1.4 can add "may step from a spot that cannot be stood on onto one that can" without rewriting it; leave a `##` line saying so.
- **Look** is not a rule here: the sim only stores the yaw and pitch it was sent (step 1, as today). `LookRules` reads them from story 1.4.

### The tick (unchanged order, AD-34)

Step 1 stays: take the move wish and the view → `WardenRules.walk(self)` → (look target: 1.4) → drain the commands. Its `##` comment keeps AD-34's wording and says which parts exist. The step list test is untouched.

### TickBlend (AD-44)

`watch/night/tick_blend.gd`, `class_name TickBlend extends RefCounted` (not a node; the architecture calls it "a blend helper object"). Holds the last two pushed positions.

- `push(position: Vector3)`: the previous becomes the older one; this becomes the newest.
- `snap(position: Vector3)`: both become `position` (a teleport, a newly made view; the climb back in 1.5 will use it).
- `value(fraction: float) -> Vector3`: `older.lerp(newest, clampf(fraction, 0, 1))`. Takes the fraction as a parameter so it is testable headless; the warden node passes `Engine.get_physics_interpolation_fraction()` (in 4.7.2 it exists and is 0.0 headless; checked on this server 2026-11-21).
- This draws the view one tick (16.7 ms) behind the sim, which is the usual price of blending and is what AD-44 asks for. Project-wide physics interpolation stays off.

### The warden's node (`watch/night/warden.gd`)

`class_name Warden extends Node3D` (`night.gd` names it by type). Yaw on this node, pitch on its `Camera3D` child, as the ear test's `listener.gd` does (that file stays untouched: the game uses nothing from the ear test).

- **Constants** (not rules; settings in epic 5): `LOOK_RADIANS_PER_PIXEL: float = 0.0025`, `MAX_PITCH_DEGREES: float = 80.0` (both the ear test's, `listener.gd`). Field of view: leave the camera's 75° default and say so in a comment.
- **Mouse look, at once (AC 4).** In `_unhandled_input`, an `InputEventMouseMotion` while the mouse is captured turns the node and the camera right away (`screen_relative`, as the ear test): `look(delta: Vector2)` does the turn and is what tests call. Yaw is kept in −π to π (`wrapf`) so it never grows without bound. Pitch clamped to ±80°. Camera `rotation.z` is never written (no roll); the camera's local position is `Vector3(0, WardenConstants.EYE_HEIGHT, 0)`, set once and never changed (no bob).
- **`yaw()`, `pitch()`**: radians, as AD-67 defines them (yaw 0 faces −Z, positive turns left; pitch positive looks up). Node3D `rotation.y` already has that sign; check it in the test rather than assume.
- **`move_direction() -> Vector2`**: `Input.get_vector(&"watch_move_left", &"watch_move_right", &"watch_move_forward", &"watch_move_back")`, turned by the yaw through a **pure static** `wish_from(keys: Vector2, yaw: float) -> Vector2`, which is what the tests check (`Input.parse_input_event` is not seen by `Input.get_vector` in the same frame headless; checked). With `keys = (right, back)`: forward at yaw 0 is world `(0, −1)`; at yaw π/2 (turned left) forward is `(−1, 0)`. The result has length ≤ 1 (`get_vector` already limits a diagonal to 1). While the mouse is free (D2), walking still works.
- **Following the sim (AC 6).** `start_at(sim)`: snaps the blend to `sim.warden.position` and sets yaw and pitch to 0 (AC 1). `on_tick(events, sim)` (a consumer): pushes `sim.warden.position`. `_process`: `position = _blend.value(Engine.get_physics_interpolation_fraction())`. It never writes to the sim and never decides where the warden may stand.
- **D2, the mouse.** `watch_pause` (Esc) pressed while captured: `Input.mouse_mode = MOUSE_MODE_VISIBLE`, mark the input handled. A left mouse press while visible: back to captured, mark handled. Mouse mode belongs to `EngineGlobals` (AD-51): add `EngineGlobals.capture_mouse(on: bool)` and call it, rather than writing `Input.mouse_mode` in the node. A `##` comment says epic 5's pause overlay replaces this. Headless, setting the mouse mode logs nothing (story 1.1's `test_engine_globals.gd` relies on that).

### Tests of the node (headless)

- `test_tick_blend.gd` (`TestCase`): after `snap(a)`, `value(f)` is `a` for 0, 0.5, 1; after `push(b)`, `value(0) == a`, `value(1) == b`, `value(0.5)` is the midpoint; a fraction outside 0 to 1 is clamped; pushing the same position twice gives no movement.
- `test_warden_node.gd` (`WatchTest`): instance `night.tscn`, call `setup()` with a test def, add it under `root`, then:
  - AC 1: the warden node's position equals `geometry.warden_start()`; yaw and pitch 0; the camera faces −Z (`-camera.global_basis.z` ≈ `(0, 0, −1)`).
  - AC 4: `look(Vector2(100, 0))` changes the camera's facing before any tick (no `advance()` in between); `look(Vector2(0, -100000))` clamps pitch to 80°; the camera's `rotation.z` is 0 and its local position is `(0, 1.6, 0)` after any looks (no roll, no bob).
  - `wish_from`: yaw 0 → forward `(0, −1)`, right `(1, 0)`; yaw π/2 → forward `(−1, 0)`; a diagonal input of length 1 stays length 1; zero stays zero.
  - AC 6 (the wiring, not the feel): call `on_tick([], sim)` after a few `sim.advance()` with a wish, and `value(1.0)` of the node's blend equals `sim.warden.position`.
  - Free the night at the end with `free()`. No `await`; compare `position` (or use `global_*` only with the node in the tree, see story 1.2's notes).
- `test_input_actions.gd` (AC 3): an `InputEventKey` with `physical_keycode = KEY_W` and `keycode = KEY_Z` (AZERTY's key in the W place) is `watch_move_forward` (`InputMap.event_is_action`), and one with `physical_keycode = KEY_Z`, `keycode = KEY_W` is not; the same idea for A (AZERTY Q). Checked on this server: Godot 4.7.2 matches on the physical code.
- AC 4's "feels immediate" and AC 6's "no visible step at 60 FPS" are M1: Sonlm's, not a test.

### Bot (AD-63)

`NightBot.walk(def, seed, faults, each_tick) -> NightSim`, 2400 ticks (40 s; the span and back is about 64 m ≈ 18 s at 3.5 m/s):

1. Its own `StartState`: one section with no planks (section 2 on six sections; on four, section 2 too), so the bot meets a plankless edge; every other section full.
2. Ticks 0 to ~1100: walk toward the far pier until stopped (it stops at the plankless section's edge), push into the left rail, then the right rail, diagonally, then walk back past the landing's back edge and push into it.
3. The rest: a wander driven by the bot's **own** `RandomNumberGenerator` seeded from the night's seed (the bot is not the sim, AD-33's "a consumer owns its own generator"; never a global random call). New wish every 30 ticks, including length-1 diagonals and zero; the view changes too.
4. `each_tick` after every tick. `test_bot_nights.gd` checks `can_stand` on every tick of every path, both defs, seeds 1 to 20, plus its existing checks.

The `span_counts` path stays as it is; its warden now walks (wish 0.9 turning slowly), and the same per-tick check covers it.

### Show-me setups (AD-56)

| Name | Description (as `--show=list` prints it) | `StartState` |
|---|---|---|
| `walk` | `walk the span and back from the landing (M1 of story 1.3)` | `planks = {1: 8, 2: 1, 3: 4, 4: 5, 5: 8}` (section 6 full), warden on the landing |
| `walk_close` | `the span from mid-span: sections ahead at 5, 4 and 1 planks (M2, DW-31)` | The same planks; `warden_along = 22.5` (mid section 5), facing the far pier |

Every section has at least one plank so M1 can walk the whole span (crossing a plankless section is story 1.6). From `walk_close` the sections ahead are 5 (s4, 2.5 to 7.5 m away), 4 (s3), 1 (s2), 8 (s1). The same planks in both, so M1's walk also passes the sparse sections up close.

### Main (DW-30, AD-59)

Move the decision in `_ready()` into `static func choose(options: LaunchOptions, debug: Object) -> Dictionary` (or a small typed result class in `main.gd`'s own file if a `Dictionary` reads poorly): what to open (`title`, `night`, `list`), the `NightDef` if any, and the problems added. `_ready()` does the side effects (register inputs, push warnings, quit or open) exactly as now. `tests/watch/test_main_flow.gd` calls it with hand-built `LaunchOptions` (through `LaunchOptions.parse()`) and the real `DebugTools` (tests may name debug classes) or `null`:

- `--show=walk --start=night` → the `walk` def and one `launch.conflict` line;
- `--show=nope` → the title and one `launch.show` line naming the known setups;
- `--show=walk` with `debug == null` → `--start` still stands, one `launch.no_debug` line;
- `--show=list` → `list`;
- `--start=night` → the one night; nothing → the title.

`main.gd` has no `class_name` today; a test reaches the static function with `const MainScript := preload("res://watch/main.gd")`. Nothing in runtime code may name a debug class to do this.

### Docs

- `WATCH.md`: what the night is now (walk with W A S D by position, look with the mouse; Esc frees the mouse and a left click takes it back, until the pause screen of epic 5); the two new show-me setups.
- `project-context.md`: under "Where things are" add one line: the warden's position is `sim.warden.position` (feet); `WardenRules.can_stand` is what can be walked on; the eye is `WardenConstants.EYE_HEIGHT`. Under "The night screen", that the night is a first-person screen and Esc frees the mouse until epic 5. Update `Last Updated`.

### DW-31 (owned here; M2)

Story 1.2's M1 found that from the landing the sections 20 to 25 m away are seen nearly edge-on. This story checks whether walking up to them is enough (`--show=walk_close`, M2). If the frames show 5, 4 and 1 clearly apart, close DW-31 with the frame path. If not, **stop and put options to Sonlm** (project-context: a case the documents do not settle goes to Sonlm as options): wider gaps (shorter `PLANK_ALONG`), more contrast between planks and the black, or a cue other than the gaps. Do not change D2's sizes on your own.

### Project Structure Notes

```
game/watch/sim/warden_constants.gd, warden_state.gd, warden_rules.gd   NEW (RefCounted, class_name)
game/watch/sim/night_sim.gd, span_geometry.gd, start_state.gd          UPDATE
game/watch/night/warden.gd, tick_blend.gd                              NEW (Warden, TickBlend)
game/watch/night/night.gd, night.tscn                                  UPDATE
game/watch/core/engine_globals.gd                                      UPDATE (capture_mouse)
game/watch/main.gd                                                     UPDATE (choose(), FIRST_PERSON)
game/watch/debug/bot/night_bot.gd, show/show_setups.gd                 UPDATE
game/tests/watch/test_warden.gd, test_tick_blend.gd,
                 test_warden_node.gd, test_main_flow.gd                NEW
game/tests/watch/test_night_sim.gd, test_span_geometry.gd,
                 test_input_actions.gd, test_bot_nights.gd,
                 test_show_setups.gd, test_engine_globals.gd           UPDATE
game/WATCH.md, _bmad-output/project-context.md,
_bmad-output/implementation-artifacts/deferred-work.md                 UPDATE
```

- `watch/core/` is a closed list (AD-40, AD-59): `capture_mouse` goes into the existing `engine_globals.gd`; no new core file.
- `tick_blend.gd` lives in `watch/night/` (architecture, System Location Mapping), not in `watch/sim/`: it reads `Engine`, which the sim may not.
- Commit the `.uid` files `--import` writes; never invent one.

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, typed GDScript: type everything (`untyped_declaration=2`); `:=` only for `const X := preload(...)`; typed arrays and dictionaries.
- `class_name` for every script another names by type, PascalCase matching the file; no bare generic or engine word (AD-41). `--import` after adding one.
- `##` doc comment on every script and non-obvious member, saying why. Constants cite GD-n/UX-n or the story decision, with a unit suffix (metres none).
- **Into the sim, nothing but** `set_move`, `set_view`, `command`. Only the sim changes night state; nothing outside `watch/sim/` assigns a sim field. Walking is a rule; mouse look is not (AD-52).
- **No physics** in the night: no bodies, colliders, rays or areas (AD-52). No autoloads.
- `watch/sim/` is node-free: CI fails on `Node`, `Node3D`, `Input.`, `Time.`, `print(`, a global random call and the rest of boundary 1. `WardenRules` names only `watch/sim/` classes.
- Time is whole ticks; durations and rates converted once (`walk_step`). The sim's `rng` is untouched by walking.
- The span's numbers: `along` from the far pier, `world_z = along − length`, LEFT = −X; no literal 6 or 30 outside `night_defs.gd` and tests.
- A view that moves holds a `TickBlend`; a teleport calls `snap()`; project-wide physics interpolation stays off.
- `EngineGlobals` owns the mouse mode (AD-51).
- No HUD at night; no camera bob or roll. Gray boxes.
- No `print` outside `watch/debug/`; faults via `WatchFaults.report`, `system.what` codes (`warden.bad_start`).
- Tests: situations only through a `StartState`; spec values written literally with their source; drive by ticks; no `await`; a provoked fault inside `_expect_begin`/`_expect_end`.
- Never `--no-verify`. What is on screen or felt is a manual check.

### Testing standards

- One file per system under `game/tests/watch/`, `_test_<topic>()` functions, `_check(name, ok, detail)`; files that need a night extend `WatchTest`.
- Any engine ERROR or WARNING outside an expect window fails the suite.
- Positions are floats: compare with a tolerance of 0.001 m (`absf(a − b) < 0.001`), never `==`.
- The ear test file must still report 120 passed, 23 expected. Story 1.2 ended at 402 passed, 0 failed, 39 expected; run `tools/ci.sh` once before starting to confirm the baseline. It only grows.

### Previous story intelligence (story 1.2, done)

- **Bot path signature** is `(def, seed, faults, each_tick) -> NightSim`, and a path puts its own `StartState` on the def it is given (on 4 sections it drops the sections that do not exist; see `ShowSetups.span_counts_start`). Follow that for `walk`.
- **`SpanGeometry.new(def, faults)`** takes the night's faults; pure otherwise.
- **`global_position` on a node outside the tree logs an ERROR** and fails the suite: add the night under `root` first, or compare `position`.
- **Smoke runs fail on any WARNING**, so `--show=walk` and `--show=walk_close` must start with no warning. `night.tscn` run alone still warns `night.no_setup` on purpose (not smoke-run).
- **The Xvfb chore**: engine flags before `--`, switches after: `xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --write-movie <dir>/frame.png --fixed-fps 30 --quit-after 60 -- --show=walk_close`. With no input the warden stands still facing the far pier, which is exactly what M2 needs.
- **M1 of 1.2 failed first time** from perspective, not from the renderer; the fix (2 m deep piers) was chosen by Sonlm from rendered variants. Do the same if M2 fails: render the options and ask.
- Code review of 1.2 asked for: faults on bad inputs (keep them), no silent fallbacks, tests that check both directions of a rule, and nothing an agent decided left undisclosed. List every choice this story does not settle under Completion Notes as "restrictive reading; Sonlm may revisit".

### Git intelligence

Branch `ear-test-prototype`, HEAD `e83e2da` (1.2's M1 fix). Recent: `e83e2da` piers 2 m deep; `4080c17` 1.2 code review fixes; `a57e6e4` story 1.2; `07808dc`, `b1335b6` story 1.1. Pattern: one commit per story step, `Story 1.3: <what>`; the pre-commit hook runs `tools/ci.sh`. Commit on the current branch.

### Latest technical notes (Godot 4.7.2, checked on this server 2026-11-21)

- `Engine.get_physics_interpolation_fraction()` exists and returns 0.0 headless.
- `InputMap.event_is_action()` matches an event registered by `physical_keycode` on the physical code alone: physical W with label Z is `watch_move_forward`; physical Z with label W is not.
- `Input.parse_input_event()` is not seen by `Input.get_vector()` in the same frame headless: test the pure `wish_from()`, not the `Input` singleton.
- `Camera3D` defaults: `fov` 75, `near` 0.05.
- `wrapf(4.0, -PI, PI)` gives −2.283; use it for yaw.
- No new library or version: nothing outside Godot 4.7.2.

### Decisions taken with Sonlm

Sonlm chose the recommended option for all three on 2026-11-21, at story creation:

1. **D1:** 0.3 m from every edge of the walkable area that is not shared (rails, far pier, landing limits, a section with no planks).
2. **D2:** Esc frees the mouse and a left click captures it again, until epic 5's pause overlay; the night keeps running.
3. **D3:** `StartState.warden_along` (−1 = the landing's centre); a start that cannot be stood on is `warden.bad_start` and falls back to the landing.

Also settled without a question (see "Decisions for this story"): instant walking at 3.5 m/s in every direction; the ear test's look values (0.0025 rad/px, ±80°, 75° field of view); no event for walking.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1; "Epic 1: story detail" preamble; "Story 1.3"; stories 1.4 to 1.6 for what must not be built here (and where they lean on this story: "the warden stays in place and can walk off", edging, the climb back)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Controls and Input; Game Mechanics 2; Level Design Framework (the landing)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-19 (3.5 m/s, sizes), GD-22
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: Input Schemes; Accessibility Floor (no bob, no roll; sensitivity, invert and field of view are settings); `.decision-log.md` UX-25, UX-39
- `_bmad-output/game-architecture.md`: Decision Summary (AD-13, AD-20); State Management; Time (AD-33); Order inside a tick (AD-34); Event System; Novel Pattern 3 (step 1: the warden gives only a move and a view); Entity Patterns, Smoothing (AD-44); Global engine state (AD-51); System Location Mapping (Warden's walking, Warden's node); AD-52; Built when (epic 1); AD-56, AD-62, AD-63; AD-67 "The warden's inputs and place"
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-2-the-span-exists-and-is-drawn-to-the-count.md`: Dev Notes, Review Findings, Completion Notes (M1)
- `_bmad-output/implementation-artifacts/deferred-work.md`: DW-26, DW-29, DW-30, DW-31
- Code as of `e83e2da`: `game/watch/sim/night_sim.gd`, `span_geometry.gd`, `start_state.gd`; `game/watch/night/night.gd`, `night.tscn`, `span_view.gd`; `game/watch/main.gd`; `game/watch/core/engine_globals.gd`, `input_actions.gd`; `game/watch/debug/bot/night_bot.gd`, `show/show_setups.gd`; `game/tests/watch/*.gd`; `game/scripts/listener.gd` (read only, for the look values); `tools/ci.sh`; `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), gds-dev-story, 2026-11-21.

### Debug Log References

- Baseline before work: `tools/ci.sh` 402 passed, 0 failed, 39 expected.
- Red first: `test_warden.gd` failed to load (no `WardenConstants`, `WardenRules`) and the DW-26 checksum check failed; then green.
- One test of mine was wrong, not the rule: a diagonal from the centre line reaches the right rail before 60 ticks (x share 2.47 m > 2.2 m). The test now starts 1.75 m left of centre.
- Final: `tools/ci.sh` 522 passed, 0 failed, 43 expected; show-me setups listed: 3 (was 1); every smoke run warning-free (capturing the mouse headless logs nothing). Ear test still 120 passed, 23 expected.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-21).
- **Sim (T1 to T4).** `WardenConstants` (WALK_SPEED 3.5, EYE_HEIGHT 1.6 moved from `SpanGeometry`, CLEARANCE 0.3), `WardenState.position`, `StartState.warden_along` (D3). `NightSim` builds the warden after the planks are set (`warden.bad_start` falls back to the landing), converts `walk_step` once, calls `WardenRules.walk()` in step 1 between taking the inputs and taking the commands, and hashes the position in `checksum()`. `WardenRules.can_stand()` tests the four clearance points against the walkable rectangles (planked decks and the landing, from `SpanGeometry`); `walk()` resolves X then Z, and on a blocked axis stops at the nearest rectangle-side-less-clearance candidate beyond which the next spot cannot be stood on (no small-step search). A `##` line in `walk()` marks where story 1.4's "step off a plankless spot" goes (`_reach()`).
- **View (T5).** `TickBlend` (RefCounted, push/snap/value). `Warden` node: yaw on the node, pitch on the camera, 0.0025 rad/px, ±80°, yaw wrapped to −π..π, camera at (0, 1.6, 0) and never rolled; `wish_from()` is pure (keys rotated by −yaw, limited to 1); a consumer pushing the sim's position; `_process` draws from the blend. D2 through the new `EngineGlobals.capture_mouse()`. `night.tscn`: `Camera3D` moved under a `Warden` node, no transforms typed. `night.gd`: the architecture's loop (move, view, advance, consumers; span view then warden).
- **Main (T5.6, T7, DW-30).** The choice is `static func choose(options, debug, debug_allowed) -> Choice` (an inner typed class: `open`, `def`, `problems`); `_ready()` keeps every side effect in the same order. The night enters as `FIRST_PERSON`.
- **Bot and shows (T6).** `NightBot.walk` (2400 ticks: section 2 plankless; scripted far pier, both rails, a diagonal, back into the landing's back; then a wander from the bot's own generator seeded from the night's seed). `test_bot_nights.gd` checks `can_stand` on every tick of every path, both defs, seeds 1 to 20, and that the walk path really reaches the plankless edge, both rails and the landing's back. Shows `walk` and `walk_close` as the Dev Notes table gives.
- **M2 / DW-31, decided with Sonlm.** First render: sections 4 (5 planks) and 3 (4) read, section 2 (1 plank, 12.5 to 17.5 m ahead) did not: from along 22.5 every gap more than about 10 m ahead looks down onto the far pier's face (it reaches 2 m below the deck), which was 0.5 gray. Rendered four variants (as is; dark piers; planks 0.35 m; both) and asked. **Sonlm chose B: dark piers** (`SpanView.PIER_COLOR` 0.5 to 0.12, both piers). D2's sizes unchanged. DW-31 closed; how a 2 m pier looks in fog is not checked (no fog until epic 7).
- **M2: verified on a virtual display** (`/tmp/claude-1000/-home-sonlm-project-3d-game/062af491-909f-47c7-90b1-1a9da0dad755/scratchpad/M2/frame00000059.png`, the last of 60 frames of `--show=walk_close`, after variant B): from mid section 5, the sections ahead at 5, 4 and 1 planks are told apart at a glance; section 2 reads as open dark space with one plank. Renderer: Forward+ on llvmpipe (CPU Vulkan) under Xvfb, not a real GPU. Variant sheet: `.../scratchpad/M2_variants.png` and `M2_variants_zoom.png`.
- **M1: NOT verified, needs Sonlm** (`--show=walk`): walking the span and back, whether turning feels immediate, whether 3.5 m/s feels like a walk, mouse capture, Esc freeing the mouse and a click taking it back, and no visible step at 60 FPS (AC 4's feel, AC 6). Feel, mouse capture and frame rate cannot be judged from frames. Also worth a glance in M1: the landing view (`--show=span_counts`) with the darker piers.
- **Restrictive readings; Sonlm may revisit:**
  - `choose()` takes a third parameter, `debug_allowed`, beside the Dev Notes' `(options, debug)`: without it Main could not tell "debug not allowed" (one `launch.no_debug` line from choose) from "allowed but missing from the build" (Main's own line when loading), and keeping Main's behaviour exactly as before needs that difference.
  - `WardenRules` has two float tolerances that are not rules: `EDGE_SLACK` 0.0001 m (a limit computed as edge − 0.3 may land a rounding error past the edge) and `PROBE` 0.001 m (how far past a candidate stop the next spot is probed). Both are far below the tests' 0.001 m.
  - `can_stand` is false for a non-finite position, so a `warden_along` of NaN is `warden.bad_start`.
  - A `warden_along` that is negative but not −1.0 (say −2) is read as a place (on the far pier) and refused as `warden.bad_start`, not as "the landing".
  - A left click while the mouse is captured is left unhandled (it is `watch_hammer`, story 1.4); only a click while the mouse is free is taken to recapture it.
  - The warden's `blend()` accessor exists for tests only.
  - `test_warden_node.gd` turns off the night's physics process after adding it, so ticks come only from the test.
- Agent time: 2026-11-21 13:55 +0700 to 2026-11-21 14:15 +0700 (0 h 20 min), measured by the agent.
- Sonlm's own hours: (for Sonlm to fill in)

### File List

- game/watch/sim/warden_constants.gd (new) + .uid
- game/watch/sim/warden_state.gd (new) + .uid
- game/watch/sim/warden_rules.gd (new) + .uid
- game/watch/sim/night_sim.gd
- game/watch/sim/span_geometry.gd
- game/watch/sim/start_state.gd
- game/watch/night/tick_blend.gd (new) + .uid
- game/watch/night/warden.gd (new) + .uid
- game/watch/night/night.gd
- game/watch/night/night.tscn
- game/watch/night/span_view.gd
- game/watch/core/engine_globals.gd
- game/watch/main.gd
- game/watch/debug/bot/night_bot.gd
- game/watch/debug/show/show_setups.gd
- game/tests/watch/test_warden.gd (new) + .uid
- game/tests/watch/test_tick_blend.gd (new) + .uid
- game/tests/watch/test_warden_node.gd (new) + .uid
- game/tests/watch/test_main_flow.gd (new) + .uid
- game/tests/watch/test_night_sim.gd
- game/tests/watch/test_span_geometry.gd
- game/tests/watch/test_input_actions.gd
- game/tests/watch/test_bot_nights.gd
- game/tests/watch/test_show_setups.gd
- game/tests/watch/test_engine_globals.gd
- game/WATCH.md
- _bmad-output/project-context.md
- _bmad-output/implementation-artifacts/deferred-work.md

### Change Log

- 2026-11-21: Story 1.3 implemented. The warden walks (WardenRules, 0.3 m clearance) and looks (Warden node, TickBlend); the night is first person, Esc frees the mouse until epic 5; Main.choose() with tests (DW-30); EYE_HEIGHT moved (DW-29); checksum covers the warden (DW-26 in part); piers darkened after M2 (DW-31, Sonlm chose variant B); bot path `walk`, shows `walk` and `walk_close`. Tests 402 to 522.
