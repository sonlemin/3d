---
baseline_commit: 10cad8d1beaedae539149afcd5d244899575eae0
---

# Story 1.1: The game starts beside the ear test

Status: done

<!-- Created 2026-11-20 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As Sonlm,
I want the game to start from the same project as the closed ear test, with its own checks,
so that every later story lands on a base that is tested on every commit and the ear test still works exactly as it did.

Delivers: architecture AD-10, AD-12, AD-20, AD-27, AD-28, AD-29, AD-36, AD-39, AD-43, AD-54, AD-59, AD-61, AD-70; GD-63.

## Acceptance Criteria

1. **Game starts.** Given a clean clone with Godot 4.7.2, when `godot --path game` is run, then the game's main scene `res://watch/main.tscn` opens on a bare start page, and the page lists every setup problem found at start, or says there are none.
2. **Ear test unchanged.** Given the ear test, when `godot --path game res://scenes/ear_test.tscn` is run, then it behaves as it did before this story, and nothing under `game/scripts/`, `game/scenes/`, `game/audio/cries/`, `game/default_bus_layout.tres` or `game/tools/measure_loudness.gd` has changed (`git diff --stat` on those paths is empty).
3. **Ear test builds.** Given the ear test's two export presets, still named `Linux` and `Windows`, with their include filter kept and the feature `eartest` added, when `tools/ci.sh --export` builds them and starts the ear test build once, then that build opens the ear test and not the game, and it writes to the same user folder as before (`use_custom_user_dir` with an `.eartest` override).
4. **project.godot.** When this story is done, the only changed lines in `game/project.godot` are the main scene, the name, their `.eartest` overrides, the pinned user folder and `physics/common/physics_ticks_per_second=60`. The viewport size, stretch mode and aspect are untouched (AD-69).
5. **Test runner.** `tests/run_tests.gd` finds every test file and every `_test_` function itself. The ear test's file, moved to `tests/ear_test/test_ear_test.gd` and extending `TestCase` with its test bodies unchanged, reports **120 passed with 23 expected errors**.
6. **CI checks.** `tools/ci.sh` fails if a code line under `watch/sim/` names a node, `Input.`, `AudioServer`, `FileAccess`, `Time.`, `await`, `print(` or a global random call, as architecture boundary 1 lists them. It fails if `print(` appears in a runtime folder outside `watch/debug/`. It runs two smoke runs of 120 frames, the game's main scene and the ear test's scene, and fails on any ERROR or WARNING line.
7. **Launch switches.** When the game starts with `--seed=N` or `--start=<value>`, one table in `LaunchOptions` parses them once into a value that is passed down. A CI test starts the game for 120 frames with each `--start` value that exists so far.
8. **Input actions.** When the game starts, every action of the GDD's Controls tables (night and planning) and the menu keys of AD-70 is registered in code from one table of physical keycodes, named `watch_` plus lower snake. A test checks that each has a physical keycode and that no `watch_` action is defined in `project.godot`. The printed name of a key comes from `DisplayServer.keyboard_get_label_from_physical`.
9. **Core scripts.** `WatchSession`, `WatchFaults`, `LaunchOptions`, `InputActions` and a first `EngineGlobals` (mouse mode, tree pause) exist under `watch/core/`, with no autoload. `game/WATCH.md` says how to run the game and the ear test and what each switch does. The three "until that story" notes are removed from `project-context.md`.

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes, `tools/ci.sh --export` passes, and Sonlm has run the manual checks below. This story has no sim and no `--show` yet (`--show` arrives in story 1.2), so its manual checks are plain launches.

**Manual check for Sonlm** (an agent cannot verify these headless; never report them as done):
- M1. `godot --path game`: the start page appears and says there are no setup problems.
- M2. `godot --path game res://scenes/ear_test.tscn`: run one trial; it looks and sounds as before.
- M3. Run the exported Linux ear test build (`builds/ear-test-linux/ear_test.x86_64`) once: it opens the ear test, and its window title is "Ear Test".

## Tasks / Subtasks

Follow the architecture's build order (AD-46): the failing test first, then the code. There is no sim in this story, so steps 3 to 7 and 9 to 10 of AD-46 do not apply.

- [x] **T1. Split the test runner (AC 5)**. Do this first: every later task adds tests through it.
  - [x] 1.1 Create `game/tests/test_case.gd`: `class_name TestCase`, `extends RefCounted`. Move `_check`, `_expect_begin`, `_expect_end` into it **with their bodies unchanged**. Give it `var root: Window` (set by the runner, so ear test bodies that call `root.add_child(...)` / `root.remove_child(...)` still work unchanged), the per-file counters `passed`, `failed`, `expected_total`, a reference to the shared logger, and two empty virtual hooks `_before_all()` and `_after_all()`.
  - [x] 1.2 Move `LogCounter` (the `Logger` subclass) out of the ear test's code into `tests/test_case.gd` (or a `tests/log_counter.gd` beside it). It is shared by every file.
  - [x] 1.3 `git mv game/tests/run_tests.gd game/tests/ear_test/test_ear_test.gd` (keeps history), then cut it down: it `extends TestCase`; it keeps its preloads, its constants (`SCRATCH_DIR`, `SEEDS`, `TIMESTAMP`, `FOCUS_OUT`, `DESIGN_NOTES_BUS_FX`), `_fake_ms` and every ear-test helper (`_seeded`, `_count`, `_remove_tree`, `_read_lines`, `_read_csv`, `_fake_now`, `_new_scene`, ...). Remove `_initialize`, `_run` and the three moved helpers. Add `_before_all()` and `_after_all()`, each calling `_remove_tree(SCRATCH_DIR)` (what `_run()` did before and after). **No `_test_` function body changes.** Move the `.uid` along with the script (`run_tests.gd.uid` → `test_ear_test.gd.uid`), and let `--import` write a fresh `.uid` for the new runner.
  - [x] 1.4 Write the new `game/tests/run_tests.gd` (`extends SceneTree`, no `class_name`): install the logger, on the first frame scan `res://tests/` recursively for files named `test_*.gd` (sorted by path), load each, fail loudly if one does not extend `TestCase`, instantiate it, set `root`, call `_before_all()`, call every method whose name starts with `_test_` **in declaration order** (`get_script_method_list()` returns declaration order; checked on 4.7.2), call `_after_all()`, then run the per-file check `"logger: no unexpected engine/script errors or warnings during the run"` over what was logged during that file. Print one summary line per file and a final total line, `N passed, M failed. ...`, then `quit(0 or 1)`. Fail if no test file or no `_test_` function is found.
  - [x] 1.5 Run it. The ear test's file must report **120 passed** (119 of its own checks plus its logger check) **and 23 expected**, exactly as on 2026-11-20. The old `_run()` order differs from declaration order in a few places (`_test_pass_mark` / `_test_level_confusions`, `_test_scene_listener_geometry` / `_test_scene_rear_shadow`, and others). If a count changes because of order, **move whole functions** in the file to match the old `_run()` order. Never edit a body.
- [x] **T2. project.godot and export presets (AC 3, 4)**
  - [x] 2.1 Write the test first: `tests/watch/test_project_setup.gd` checks the main scene, the name, the `.eartest` overrides, the pinned user folder and 60 physics ticks; checks that the viewport (1280×720), `canvas_items` and `expand` are unchanged; checks that both ear test presets have `custom_features="eartest"` and keep `include_filter="audio/cries/loudness.json"`. Note that the ear test's own `_test_loudness_table_real` already counts that filter line exactly twice. Keep that true.
  - [x] 2.2 Edit `game/project.godot` by hand (exact lines in Dev Notes). Then run `godot --headless --path game --import` and check with `git diff game/project.godot` that the import did not rewrite anything else.
  - [x] 2.3 Edit `game/export_presets.cfg`: `custom_features="eartest"` in `[preset.0]` and `[preset.1]`. Change nothing else.
- [x] **T3. Core scripts (AC 7, 8, 9)**. Test first for each.
  - [x] 3.1 `tests/watch/test_launch_options.gd`, then `watch/core/launch_options.gd` (`class_name LaunchOptions`).
  - [x] 3.2 `tests/watch/test_input_actions.gd`, then `watch/core/input_actions.gd` (`class_name InputActions`).
  - [x] 3.3 `tests/watch/test_watch_faults.gd`, then `watch/core/watch_faults.gd` (`class_name WatchFaults`).
  - [x] 3.4 `watch/core/watch_session.gd` (`class_name WatchSession`) and `watch/core/engine_globals.gd` (`class_name EngineGlobals`). Test what can be tested headless: tree pause on/off and the `enter_screen` clearing pause. Mouse mode is a manual-only fact.
  - [x] 3.5 `godot --headless --path game --import` after adding the `class_name`s.
- [x] **T4. Main and the start page (AC 1)**
  - [x] 4.1 `watch/main.tscn` + `watch/main.gd` (no `class_name`): parses `LaunchOptions`, registers `InputActions`, builds the `WatchSession` with the setup problems collected, calls `EngineGlobals.enter_screen(...)` and shows the start page. It holds the flow and nothing else (AD-59).
  - [x] 4.2 `watch/screens/title_screen.tscn` + `title_screen.gd`: the bare start page (see Dev Notes). Handed the `WatchSession`; draws the problem list or the no-problem line.
  - [x] 4.3 `watch/content/ui_text.gd` (`class_name UiText`, constants only) for the page's strings.
- [x] **T5. CI (AC 3, 6, 7)**: rewrite `tools/ci.sh` (details in Dev Notes)
  - [x] 5.1 Purity check on `game/watch/sim/` (absent folder = pass), with a built-in fixture self-check so the grep is proven to catch each banned token.
  - [x] 5.2 The `print(` check on runtime folders (`game/watch/` except `game/watch/debug/`).
  - [x] 5.3 Tests: grep the final total line.
  - [x] 5.4 Smoke runs: the game's main scene; the ear test's scene. Then one smoke run per `--start` value, listed by `tests/print_start_values.gd`.
  - [x] 5.5 `--export`: build both presets, start the Linux ear test build once headless for 120 frames, and confirm it opened the ear test and wrote to its old user folder.
- [x] **T6. Docs (AC 9)**
  - [x] 6.1 `game/WATCH.md`.
  - [x] 6.2 `game/EAR_TEST.md`: change only the lines that are now wrong: running the test (`godot --path game` now opens the game) and the test command path. The ear test's closed list does not include this file.
  - [x] 6.3 `_bmad-output/project-context.md`: replace the three "until that story" notes (exact edits in Dev Notes), and the matching line in Usage Guidelines.
- [x] **T7. Close**: `tools/ci.sh` and `tools/ci.sh --export` pass. Fill in the Dev Agent Record. List M1 to M3 for Sonlm as **not verified**. Set Status to `review`.

### Review Findings

<!-- gds-code-review, 2026-11-20, commit 05124dd against 10cad8d. Three reviewers on the 1833 lines of new work; the moved ear test file was compared mechanically (all 54 test bodies byte-identical; 120 passed, 23 expected). No acceptance criterion is violated. -->

- [x] [Review][Decision] The purity check lets node-based and unseeded-random code through — `extends Node2D`, `extends Control`, `Node.new()`, `Timer.new()`, `randfn(`, `seed(` and `rng.randomize()` all pass `SIM_BANNED`. The pattern matches the architecture's written list (boundary 1), which leaves base types to a test that is not in this story. `watch/sim/` is still empty. Widen now, or with story 1.2? [tools/ci.sh:40] — **Decided (Sonlm, 2026-11-20):** widen now. Fixed: `SIM_BANNED` also bans `Node`, `Node2D`, `SceneTree`, `Timer`, `get_main_loop`, `randfn(`, `seed(`, `rand_from_seed(` and any `randomize(`; `bad_bases` fails any `extends` that is neither `RefCounted` nor a class of the folder itself; the self-check covers each.
- [x] [Review][Decision] The physics-tick line is at the engine default, so an editor save may remove it — `physics/common/physics_ticks_per_second=60` is the default, and the editor does not write default values when it saves `project.godot`. The first save from the editor would then fail "60 in the file", though AC4 asks for the line. Not confirmed on 4.7.2. [game/tests/watch/test_project_setup.gd:50] — **Decided (Sonlm, 2026-11-20):** test the engine value only. Fixed: the "60 in the file" check is removed; the line stays in `project.godot`.
- [x] [Review][Decision] `register()`'s `input.defined_elsewhere` branch has no test — `_test_other_bindings_are_a_problem` says "register() must notice" but only calls `same_events()`; deleting the branch leaves every test green. A real test must write to the `InputMap`, which the story's rule (tests only read it) forbids. [game/tests/watch/test_input_actions.gd:158] — **Decided (Sonlm, 2026-11-20):** add the test, with cleanup. Fixed: `_test_register_reports_other_bindings` is the one test that writes to the `InputMap`, and it puts the bindings back.
- [x] [Review][Decision] The ear test builds now carry the game's code — both presets keep `all_resources` and exclude only `tests/*, tools/*`, so `watch/` ships inside the ear test builds; `config/description` still describes the ear test under the game's name. AC3 says to keep the include filter. Exclude `watch/*`, or accept? [game/export_presets.cfg:11] — **Decided (Sonlm, 2026-11-20):** accept as is. Dismissed: the ear test is closed, and `ci.sh --export` proves the build opens the ear test.
- [x] [Review][Patch] A test that aborts inside an expect window is swallowed: the run prints 0 failed (reproduced) [game/tests/test_case.gd:99, game/tests/run_tests.gd:76]
- [x] [Review][Patch] A `_test_` function that uses `await` stops at the await; later checks never run and the file passes (reproduced) [game/tests/run_tests.gd:77]
- [x] [Review][Patch] A bad first switch blocks a good repeat and says "the first stands": `--seed=abc --seed=5` gives no seed (reproduced) [game/watch/core/launch_options.gd:53]
- [x] [Review][Patch] A switch typed before `--` is ignored without a word: the start page says "No setup problems." (reproduced) [game/watch/core/launch_options.gd:39]
- [x] [Review][Patch] `tools/ci.sh --exports` or any other unknown argument skips the export checks and prints "all checks passed" [tools/ci.sh:135]
- [x] [Review][Patch] The print check misses `prints(`, `printt(`, `printerr(`, `printraw(`, `print_rich(`, `print_debug(`, `print_verbose(` and `print (` (AD-29) [tools/ci.sh:44]
- [x] [Review][Patch] Comment stripping cuts code after a `#` inside a string, so `"#" + str(randi())` passes both checks (reproduced) [tools/ci.sh:33]
- [x] [Review][Patch] Smoke and export logs: `SHADER ERROR` is not in `BAD_LINES`, export logs are never searched for errors, and the start check does not require a freshly built binary [tools/ci.sh:23, tools/ci.sh:138]
- [x] [Review][Patch] The export start check reads and writes the real `~/.local/share` folders; a game open in another window fails it falsely. Run it under a scratch `XDG_DATA_HOME` [tools/ci.sh:137]
- [x] [Review][Patch] A `TestCase` file under `tests/` not named `test_*.gd` is skipped without a word [game/tests/run_tests.gd:90]
- [x] [Review][Patch] `_test_no_pixel_sizes` only reads the `.tscn`; the labels are built in `title_screen.gd`, where a pixel size would go unnoticed (AD-69) [game/tests/watch/test_title_screen.gd:43]
- [x] [Review][Patch] `key_name()` calls every mouse button that is not the left one "Right mouse" [game/watch/core/input_actions.gd:86]
- [x] [Review][Patch] The title screen crashes on a null `session` when the scene is run alone (F6) [game/watch/screens/title_screen.gd:18]
- [x] [Review][Patch] The Xvfb command template puts `--write-movie`, `--fixed-fps` and `--quit-after` after `--`, where they become user arguments: no movie, no quit, and `launch.unknown` lines on the screen being judged [_bmad/custom/gds-dev-story.toml:16]
- [x] [Review][Patch] Completion Notes contradict themselves and are stale: M1 "verified" and M3 "partly verified" against a later block that lists M1 to M3 as NOT verified; no frame path; "Nothing is committed" inside the commit; agent time ends before the manual checks; `_bmad/custom/gds-dev-story.toml` is in the commit and not in the File List [this file, Completion Notes and File List]
- [x] [Review][Patch] `project-context.md` still opens two rules with things that do not exist yet: "three smoke runs" and "extending `WatchTest`" [_bmad-output/project-context.md:31, _bmad-output/project-context.md:121]
- [x] [Review][Patch] `EAR_TEST.md` tells the reader to skip the hook with `git commit --no-verify`; `WATCH.md` and the project rule say never [game/EAR_TEST.md:44]
- [x] [Review][Defer] Only the Linux ear test build is started; the Windows build is exported and never run, so a lost `eartest` feature there would go unseen [tools/ci.sh:137] — deferred, needs a Windows machine or Wine (DW-24)
- [x] [Review][Defer] `key_name()` may print an empty name or a word such as "Ampersand" on layouts where the key's label is a symbol or `KEY_NONE`; not reproducible here (US layout on Xvfb gave good names for all 27 actions) [game/watch/core/input_actions.gd:92] — deferred to the story that first draws key names (DW-25)

## Dev Notes

### What this story is

It is infrastructure only: no `NightSim`, no span, no `--show`, no `WatchTest` and no third smoke run. All of those are story 1.2 (architecture "Built when"). Do not create `watch/sim/` or any folder without a file in it (AD-62: "a folder is created with its first file").

### Current state of the files this story changes (read 2026-11-20)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/project.godot` | Ear test: `config/name="Ear Test"`, `run/main_scene="res://scenes/ear_test.tscn"`, description, features `4.7`/`Forward Plus`; audio `3d_panning_strength=1.0`, `default_bus_layout`; `untyped_declaration=2`; display 1280×720 `canvas_items` `expand`; wav `force/mono`; `forward_plus`. **No** user-dir lines, **no** physics section, **no** `[input]` section | Adds the lines below | Every other line, byte for byte. The ear test's test checks `3d_panning_strength` |
| `game/export_presets.cfg` | `Linux` (preset.0) and `Windows` (preset.1), `custom_features=""`, `include_filter="audio/cries/loudness.json"`, `exclude_filter="tests/*, tools/*"`, export paths `../builds/ear-test-*/` | `custom_features="eartest"` on both | Everything else. Do not add game presets (epic 2) |
| `game/tests/run_tests.gd` | 1832 lines, `extends SceneTree`; `LogCounter`; `_run()` calls 54 `_test_` functions by hand; helpers; prints `120 passed, 0 failed. Logger: 0 unexpected ..., 23 expected` | Becomes `tests/ear_test/test_ear_test.gd`; a new self-listing runner takes its path | Every `_test_` body; the 120/23 counts |
| `tools/ci.sh` | import → tests → one smoke run (main scene) → `--export` builds `Windows` and `Linux` into `builds/ear-test-*/` | Checks, two smoke runs, start-value runs, export start check | `GODOT` lookup, `step`/`fail` output style, the export paths, `set -uo pipefail` |
| `.githooks/pre-commit` | Runs `tools/ci.sh` when `game/` or `tools/ci.sh` is staged | Nothing | As is |
| `game/EAR_TEST.md` | Says `godot --path game` runs the test | Fix that line and the test command | The rest |

### project.godot: the exact lines

```ini
[application]

config/name="The Mourning Watch"
config/name.eartest="Ear Test"
config/description="Private gray-box test: can players place a cry's direction and level by ear?"   ; unchanged
run/main_scene="res://watch/main.tscn"
run/main_scene.eartest="res://scenes/ear_test.tscn"
config/use_custom_user_dir=true
config/custom_user_dir_name="mourning_watch"
config/use_custom_user_dir.eartest=false
config/features=PackedStringArray("4.7", "Forward Plus")   ; unchanged

[physics]

common/physics_ticks_per_second=60
```

**Why the ear test turns the custom folder *off*:** the ear test's builds today write to Godot's default folder: Linux `~/.local/share/godot/app_userdata/Ear Test/`, Windows `%APPDATA%\Godot\app_userdata\Ear Test\`. That folder comes from `config/name` with `use_custom_user_dir` off. A custom folder name cannot reproduce both paths (`godot` vs `Godot`). So `use_custom_user_dir.eartest=false` together with `name.eartest="Ear Test"` keeps the ear test's folder **exactly** as it was, on both systems. The game's folder is pinned to `custom_user_dir_name`, so it does not move when the working title changes. `mourning_watch` was chosen by Sonlm.

Feature overrides apply only to exported builds with that feature. Run from source, the ear test uses the game's folder (`~/.local/share/mourning_watch/`), and its test scratch goes to `user://ear_test_selftest` there. That is expected (architecture, "Keeping the ear test whole").

Godot 4.7.2 keeps an override as its own setting: `ProjectSettings.has_setting("application/config/name.eartest")` is `true` (checked headless). The test can read the overrides through `ProjectSettings` or by reading `res://project.godot` as text.

### The test runner

- **Keep the logger semantics exactly.** Any ERROR, WARNING, SCRIPT ERROR or SHADER ERROR outside an `_expect_begin`/`_expect_end` window fails the suite. That now gives one logger check per file. The ear test's count of 120 includes its logger check (today's 120 = 119 own + 1 logger).
- Per-file output, for example `ear_test/test_ear_test.gd: 120 passed, 0 failed, 23 expected`, then the total line. `tools/ci.sh` greps the **total** line.
- Discovery uses `script.get_script_method_list()`, which returns script methods in declaration order (verified on 4.7.2). Don't sort them alphabetically, or the ear test's order-sensitive fake clock may shift.
- `TestCase` is not runtime code. `class_name TestCase` in `tests/` is allowed. No runtime script may name it (boundary 5).
- `WatchTest` (sim helpers) is story 1.2. This story's new test files extend `TestCase` directly.
- Tests write only under `user://..._selftest`, and remove it first.
- **The runner itself may print.** `tests/` and `tools/` are not runtime.

### LaunchOptions (AD-61)

- One table: a `const` typed dictionary or array describing each switch (`--seed`: int; `--start`: one of a list of values). Parse **once**, from `OS.get_cmdline_user_args()` (the arguments after `--`; checked on 4.7.2: `godot ... -- --start=night --seed=3` gives `["--start=night", "--seed=3"]`), into a `LaunchOptions` value: `seed_given: bool`, `seed: int`, `start: StringName` (empty = the start page), `problems: PackedStringArray`.
- A static `parse(args: PackedStringArray) -> LaunchOptions`, pure, so tests pass arrays straight in.
- **The `--start` values that exist so far:** none. Lesson, planning, night and round arrive later (`night` in story 1.2). Keep the list as a `const` (e.g. `START_VALUES: Array[StringName] = []`), and don't invent a value to fill it.
- An unknown switch, an unknown `--start` value or a non-integer `--seed` is a **setup problem** (AD-28): added to `problems`, reported once with `push_warning("launch.<what>: ...")` **by `Main`, not by `parse()`** (so tests of `parse` provoke no warnings), and shown on the start page. Never crash.
- Later stories add `--show`, `--trace`, `--log`, `--debug`, `--wave`, `--plan`, `--def`, `--replay` to the same table. Shape it so a switch is one row.
- `tests/print_start_values.gd` (`extends SceneTree`, a tool, may print) prints `LaunchOptions.START_VALUES` one per line and quits. `tools/ci.sh` loops over its output (empty today).

### InputActions (AD-20, AD-70)

One table; every row is an action and its bindings. Keys use `InputEventKey.physical_keycode` with `keycode = 0`. Mouse buttons use `InputEventMouseButton.button_index`. Register with `InputMap.add_action` / `action_add_event` in `static func register()`. Calling it twice must change nothing (skip actions that already exist), so tests and `Main` can both call it.

| Action | Binding | Source |
|---|---|---|
| `watch_move_forward` / `_back` / `_left` / `_right` | W / S / A / D | GDD night: walk |
| `watch_hammer` | Left mouse | GDD night: hammer hand (strike, strip plank, wedge) |
| `watch_rope` | Right mouse | GDD night: rope and lantern hand (strip rail, haul, re-hang, bell rope) |
| `watch_use` | E | GDD night: hang/take/swap, re-lay, refill (UX-36) |
| `watch_shutter` | F | GDD night |
| `watch_build_trapdoor` | 1 | GDD night (hold 8 s) |
| `watch_build_swing_beam` | 2 | GDD night (hold 12 s) |
| `watch_dismantle` | R | GDD night (hold 4 s) |
| `watch_forearm` | Tab | GDD night (UX-11) |
| `watch_pause` | Esc | GDD night and planning; UX-24 |
| `watch_plan_select` | Left mouse | GDD planning: strip / place |
| `watch_plan_undo` | Right mouse | GDD planning: undo on that section |
| `watch_tool_trapdoor` / `_swing_beam` / `_lantern` | 1 / 2 / 3 | GDD planning (UX-16) |
| `watch_ring_bell` | Space | GDD planning (hold 1 s, UX-18) |
| `watch_journal` | J | GDD planning (UX-13) |
| `watch_menu_up` / `_down` / `_left` / `_right` | Up or W / Down or S / Left or A / Right or D | AD-70 |
| `watch_menu_confirm` | Enter or Space | AD-70 |
| `watch_menu_back` | Esc | AD-70 |
| `watch_ring_again` | R | AD-70 (left/right check) |

- Several actions share a physical key (1, 2, R, Esc, Space, W/A/S/D, the mouse buttons). That is intended: each screen reads only its own actions.
- Mouse look is not an action. "Start over" is a click on the tray, not a key. The lesson's answer keys are epic 2's to add, as rows in this table.
- **The test (AC 8):** every action in the table starts with `watch_`; every key event has `physical_keycode != 0` and `keycode == 0`; every mouse action has a button index; after `register()`, `InputMap.has_action` is true for each; and no `ProjectSettings` property starts with `input/watch_`. Write the table's expected bindings **literally** in the test (GDD values in comments). Never read them from `InputActions`.
- **Key names.** `static func key_name(action: StringName) -> String`. For a key: `OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(physical))`. ⚠ **In headless mode that call logs `ERROR: Not supported by this display server.`** (checked on 4.7.2), which fails every test and smoke run. Guard it: when `DisplayServer.get_name() == "headless"`, use `OS.get_keycode_string(physical)` instead. For a mouse button, return a fixed name ("Left mouse", "Right mouse") from `UiText`. Nothing on the start page shows key names yet. They are for the key card, tray and lesson prompts later.
- No gamepad and no rebinding (AD-55, deferred).

### WatchFaults (AD-28, AD-36)

`RefCounted`. `report(code: StringName, detail: String) -> void` calls `push_error("%s: %s" % [code, detail])` only on the **first** time a code appears, and counts every occurrence. It also has `count(code) -> int`, `total() -> int` and `codes() -> Array[StringName]`. It is the **only** code that calls `push_error` for a fault. One object per night later; in this story nothing reports a fault yet, but the test must cover it. Wrap the provoked error in `_expect_begin()` / `_expect_end(name, [["ERROR", "test.code", 1]])`.

### WatchSession, EngineGlobals, Main (AD-10, AD-51, AD-59)

- **No autoloads.** `project.godot` gets no `[autoload]` section.
- `WatchSession` (`RefCounted`) is made by `Main` once. For now it holds `options: LaunchOptions` and `setup_problems: PackedStringArray` (the launch problems plus any problem `InputActions.register()` reports). Settings, journal hints, the last `NightPlan` and the `PlaytestLog` come in later epics. Leave no placeholder fields for them.
- `EngineGlobals` (`RefCounted`, static functions taking the `SceneTree`): `enter_screen(tree, kind)` clears the tree pause and sets `Input.mouse_mode` for the kind of screen (a menu: visible; first person: captured). `set_paused(tree, on)` sets `tree.paused`. Bus values and the window come in epic 2 and epic 5. Setting the mouse mode headless logs nothing (checked on 4.7.2).
- `Main` (`watch/main.gd`, no `class_name`) parses options, registers input, builds the session, calls `EngineGlobals.enter_screen(get_tree(), MENU)`, instances the title screen, hands it the session, and pushes each setup problem once with `push_warning`. It draws nothing itself and holds no rule. Screen changes are deferred to the end of the frame (`call_deferred`).
- **Smoke runs fail on any WARNING line.** On a clean clone the start page must find **no** setup problem. If it did, `push_warning` would fail CI, which is the intent.

### The start page (title_screen)

It is bare by design. The game's look (Lantern light, the bundled font, `watch_theme.gd`) is epic 5. It is named `title_screen` because it **is** the title in its first form: AD-28 says setup problems are "shown on the title", and epic 5 grows this file rather than replacing it.

- A `Control` root filling the screen, a plain `Label` with the game's name, and one line per setup problem, or the single line "No setup problems." Strings come from `UiText`.
- **No pixel sizes** (AD-69): no `theme_override_font_sizes`, no hand-set offsets in pixels beyond anchors/containers. Only `watch_theme.gd` (epic 5) will turn a size token into canvas pixels.
- No other entries (no "Begin the watch" yet), and no sound.

### tools/ci.sh

Keep the existing style (`step` / `fail`, `GODOT` lookup, output tail on failure). The order:

1. **import**: as today.
2. **purity check** (boundary 1), on `game/watch/sim/**/*.gd`. If the folder does not exist, it passes. Drop comment lines (first non-space `#`) and text after a `#`. Then fail on whole-word `extends Node`, `Node3D`, `get_tree`, `Input\.` (not preceded by a word character, so `HandInput.` passes), `AudioServer`, `FileAccess`, `Time\.`, `await`, `print\(`; on `randi(`, `randf(`, `randi_range(`, `randf_range(`, `randomize(` **not preceded by a dot** (so `sim.rng.randi_range(` passes); and on `.shuffle(` and `.pick_random(`. Print the offending file:line on failure.
   - **Self-check:** before the real check, run the same function on a fixture written to a `mktemp -d` folder: one file per banned token (each must be caught) and one clean file with `HandInput.HAMMER`, `sim.rng.randi_range(0, 3)` and `# print(` in a comment (must pass). If the fixture result is wrong, CI fails. This proves the grep works while `watch/sim/` is still empty.
3. **print check**: `print(` in a code line of any `.gd` under `game/watch/` outside `game/watch/debug/` fails. Use the same comment stripping. (`game/scripts/` is the ear test's and is closed; its `print` at session start stays.)
4. **tests**: `-s res://tests/run_tests.gd`; grep the final total line.
5. **smoke runs**, each `--headless --quit-after 120`, failing on `^(ERROR|SCRIPT ERROR|WARNING)`:
   - the game: `"$GODOT" --headless --path game --quit-after 120`
   - the ear test: `"$GODOT" --headless --path game --quit-after 120 res://scenes/ear_test.tscn`
   - one per `--start` value from `tests/print_start_values.gd`: `... --quit-after 120 -- --start=<v>` (no runs today).
6. **`--export`**: build `Windows` and `Linux` exactly as today. Then start the **Linux ear test build** once: `builds/ear-test-linux/ear_test.x86_64 --headless --quit-after 120`, failing on ERROR or WARNING lines. To confirm it **opened the ear test and wrote to its old folder**, use Godot's file logging (on by default for desktop): after the run, `~/.local/share/godot/app_userdata/Ear Test/logs/godot.log` must be newer than a timestamp taken just before the run, and `~/.local/share/mourning_watch/` must not have been written by it. This proves the `eartest` overrides were applied, and `run/main_scene.eartest` is applied by the same mechanism. If you can also confirm the scene directly (for example, whether `--verbose` in a release template prints the loaded scene path), add that. **If neither proves which scene opened, stop and put options to Sonlm.** Do not weaken the AC silently. The Windows build cannot be started on this server, so M3 covers it by hand only if Sonlm wants.
7. `echo "ci: all checks passed"`.

The ear test's own test `_test_loudness_table_real` reads `res://export_presets.cfg` and counts `include_filter="audio/cries/loudness.json"` == 2. Adding `custom_features` keeps that true.

### WATCH.md (beside EAR_TEST.md)

It covers how to run the game (`godot --path game`, editor F5), how to run the ear test now that it is not the main scene (`godot --path game res://scenes/ear_test.tscn`, or open `scenes/ear_test.tscn` in the editor and press F6), the tests (`godot --headless --path game -s res://tests/run_tests.gd`), CI (`tools/ci.sh`, `--export`, the hook: `git config core.hooksPath .githooks`), each launch switch that exists (`--seed=N`, `--start=<value>`: none yet; arguments go after `--`), and where the game's user folder is (`~/.local/share/mourning_watch/`, `%APPDATA%\mourning_watch\`). The ear test's builds still write to `app_userdata/Ear Test`. The playtest log arrives in epic 2: say so in one line.

### project-context.md edits (AC 9)

- **CI bullet:** replace "The checks and the second and third smoke runs are added in epic 1; until that story lands, CI is import + tests + one smoke run." with: the purity and `print` checks and the first two smoke runs exist since story 1.1, and the third (`--start=night`) arrives with story 1.2.
- **`project.godot` bullet** ("Until epic 1's setup story lands, `project.godot` is still the ear test ..."): state it as done. The main scene is `res://watch/main.tscn`; `.eartest` overrides of name, main scene and user folder keep the ear test's presets and folder.
- **Testing bullet** ("(Until epic 1's setup story splits it, the ear test's tests are in `run_tests.gd`, where each must be listed in `_run()`.)"): remove it. The ear test's tests are in `tests/ear_test/test_ear_test.gd`; new files extend `TestCase` (or `WatchTest` from story 1.2).
- Usage Guidelines: remove "After epic 1's setup story lands, remove the three 'until that story' notes". Update the `Last Updated` date.

### Project Structure Notes

Files this story creates (everything else stays as is):

```
game/project.godot                       UPDATE (lines above only)
game/export_presets.cfg                  UPDATE (custom_features only)
game/EAR_TEST.md                         UPDATE (run/test lines only)
game/WATCH.md                            NEW
game/watch/main.tscn, main.gd            NEW (no class_name)
game/watch/core/launch_options.gd        NEW  LaunchOptions
game/watch/core/input_actions.gd         NEW  InputActions
game/watch/core/watch_faults.gd          NEW  WatchFaults
game/watch/core/watch_session.gd         NEW  WatchSession
game/watch/core/engine_globals.gd        NEW  EngineGlobals
game/watch/content/ui_text.gd            NEW  UiText (strings only)
game/watch/screens/title_screen.tscn/.gd NEW (no class_name: nobody names it by type)
game/tests/run_tests.gd                  NEW (self-listing runner; replaces the old file's role)
game/tests/test_case.gd                  NEW  TestCase (+ LogCounter)
game/tests/ear_test/test_ear_test.gd     MOVED from tests/run_tests.gd (git mv), bodies unchanged
game/tests/print_start_values.gd         NEW (tool for ci.sh)
game/tests/watch/test_project_setup.gd   NEW
game/tests/watch/test_launch_options.gd  NEW
game/tests/watch/test_input_actions.gd   NEW
game/tests/watch/test_watch_faults.gd    NEW
game/tests/watch/test_engine_globals.gd  NEW
tools/ci.sh                              UPDATE
_bmad-output/project-context.md          UPDATE
```

- `watch/core/` is a **closed list of seven** (AD-40, AD-59). This story makes five; `watch_settings.gd` and `build_info.gd` come in epic 2. Nothing else goes in `core/`.
- Commit the `.uid` files that `--import` writes. Never invent a `uid://` in a hand-written `.tscn`; reference by `res://` path (`[ext_resource type="Script" path="res://watch/main.gd" id="1"]`).
- Scenes are thin (AD-62): `main.tscn` is a root `Node` + script; `title_screen.tscn` a root `Control` + script. The labels can be built in code or be children with no position on the span.

### Project Context Rules (from project-context.md, the ones this story touches)

- Godot **4.7.2** pinned, Forward+, `godot` on PATH (`/home/sonlm/.local/bin/godot` on this server) or `$GODOT`. Every command uses `--path game`.
- **Type everything.** `untyped_declaration=2` makes an untyped declaration a parse error. Write types out (`var x: float = 0.0`); use `:=` only for `const X := preload(...)`. Use typed arrays and dictionaries; check a `Variant` with `is`.
- `class_name` per game script that another script names by type, PascalCase matching the file. There is no bare generic word (AD-41). Run `--import` after adding one.
- `##` doc comment on every script and every non-obvious member, saying **why**.
- **No `print` in runtime code** outside `watch/debug/`. A clean run prints nothing.
- Errors: a setup problem → collected at start, `push_warning`/`push_error`, shown on the title; a fault → `WatchFaults.report`. **No `assert`, no crash.**
- No autoloads, no addons, no C#, no MCP server, no network code.
- The ear test is **closed**: `scripts/`, `scenes/`, `audio/cries/`, `default_bus_layout.tres`, `tools/measure_loudness.gd`. The game names nothing in them, and they name nothing in `watch/`.
- `tests/` and `tools/` are not runtime. `watch/debug/` is one-way (none exists yet).
- Screens do not reach into each other. A screen gets `WatchSession` and reports to `Main` with a signal.
- Never `--no-verify`. Fresh clone: `git config core.hooksPath .githooks`.
- Agents are headless. Mouse capture, what is on screen and sound are **manual checks for Sonlm**; never report them as verified.

### Testing standards

- Test first, then code (AD-46). One test file per system under `game/tests/watch/`, `_test_<topic>()` functions, asserting with `_check(name, ok, detail)`.
- Write spec values literally, with their source in a comment. Never read the value under test from the code under test.
- Any engine ERROR/WARNING outside an expect window fails the suite.
- Tests touch the real `InputMap` and `ProjectSettings` only by reading them, except `InputActions.register()`, which is idempotent.
- The ear test: still 120 passed, 23 expected, from its own file.

### Previous story intelligence

This is the first story of epic 1; there is no previous story file. What the ear test's history teaches (commits `cf1a5e0`..`992b2bb`):
- The ear test's logger-based runner, the 120 checks and the "fail on any ERROR/WARNING" smoke run are the bar this story inherits. Do not lower it.
- `992b2bb` turned untyped declarations into errors. Every new script must parse under that.
- The ear test's tests drive its scene with a fake clock and `root.add_child`. That is why `TestCase` needs `root` and why declaration order matters (T1.5).

### Git intelligence

Branch `ear-test-prototype`, last commit `555918b` (planning: readiness fixes and sprint plan). All work so far has been the ear test plus planning documents; `game/watch/` does not exist yet. The pre-commit hook runs `tools/ci.sh` on any commit touching `game/` or `tools/ci.sh`.

### Latest technical notes (Godot 4.7.2, checked on this server 2026-11-20)

- `get_script_method_list()` returns methods in declaration order.
- `OS.get_cmdline_user_args()` returns the arguments after `--`.
- `DisplayServer.keyboard_get_label_from_physical()` **errors in headless mode**; guard it (see InputActions).
- `Input.mouse_mode = ...` in headless mode logs nothing.
- Feature-override keys such as `application/config/name.eartest` are readable as their own settings.
- Without a custom user folder, the user folder is `~/.local/share/godot/app_userdata/<config/name>`.
- `Logger` subclassing with `OS.add_logger` is what the ear test runner already uses on 4.7.2; keep it.

### Decisions taken with Sonlm (2026-11-20, at story creation)

1. **The game's user folder** is `mourning_watch` (`config/custom_user_dir_name`). It does not follow the working title.
2. **Mouse buttons are in the same `InputActions` table.** The AC 8 test checks per kind: each key uses `physical_keycode` (with `keycode == 0`), and each mouse action has a button index.
3. **Action names** are as in the table above.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1 and "Story 1.1: The game starts beside the ear test"
- `_bmad-output/game-architecture.md`: Decision Summary (AD-10, AD-12, AD-20, AD-27); Error Handling (AD-28, AD-36); Logging (AD-29); Configuration; Debug Tools (smoke runs); Directory Structure; System Location Mapping; Architectural Boundaries 1 to 7; Keeping the ear test whole (AD-43); Reading and running; The shape of a test; Consistency Rules; Built when (AD-54, AD-66); Additions from the Round Table (AD-59, AD-61, AD-62); Decisions made at the readiness check (AD-69, AD-70); Development Environment
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Controls and Input (night and planning tables)
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: Input Schemes; menu-item and two-choice components
- `_bmad-output/project-context.md`: all sections
- `game/tests/run_tests.gd`, `tools/ci.sh`, `game/project.godot`, `game/export_presets.cfg`, `game/EAR_TEST.md` as of commit `555918b`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5), gds-dev-story, 2026-11-20.

### Debug Log References

- Baseline before any change: old runner `120 passed, 0 failed ... 23 expected`; saved and compared check by check after the split.
- `ConfigFile.get_value(section, key, null)` logs an ERROR when the key is missing (a `null` default counts as "no default"). The project test uses a string default instead.
- Probe (Godot 4.7.2): `"99999999999999999999".is_valid_int()` is `true`, then `to_int()` logs `ERROR: Cannot represent ... as a 64-bit signed integer`. `LaunchOptions` therefore rejects a seed over 18 digits (a test covers it).
- Probe: `PackedStringArray(Array[StringName])` converts fine (the problem line that lists `--start` values; exercised by temporarily setting `START_VALUES = [&"night", &"lesson"]`, then restored).
- Release export templates refuse a scene path on the command line (`compiled without support for path overrides`). `--verbose` in a release build does log `Completed load for: 'res://scenes/ear_test.tscn'`, which CI now requires; from source the same line names `res://watch/main.tscn` for the game.
- Negative checks run and removed afterwards: a `Time.` line in a probe `watch/sim/` file fails the purity check; a `print(` in `watch/core/` fails the print check while one in `watch/debug/` passes; removing `await` from the pattern fails the self-check; the runner fails on a file not extending `TestCase`, an empty test file, a failing check and a stray warning; rebinding `watch_use` to Q fails the input test.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-20).
- Hours: epics.md logs hours from epic 1 onward. Record the hours spent on this story here (Sonlm).
- Agent time: 2026-11-20 15:42 to 15:57 +0700 (0 h 15 min), measured by the agent: from the first file it wrote (the baseline test run) to setting the status to review. Reading the story and context before that took a few more minutes. This end time is before the virtual-display checks below and the commit at 16:10, so the true figure is nearer 0 h 30 min (corrected at code review; not measured).
- Manual checks after the fact, on a virtual display (Xvfb, Forward+ on llvmpipe CPU Vulkan, not a real GPU; frames written with `--write-movie` to the session's scratch folder, not kept, so no frame path can be given; the code review repeated M1 and saw the same frame 19):
  - M1: verified on a virtual display. Frame 19 of `godot --path game` shows "The Mourning Watch" and "No setup problems." centred on a plain background.
  - M2: NOT verified, needs Sonlm (one trial must be played and heard).
  - M3: NOT verified, needs Sonlm (the window title "Ear Test" cannot be seen on Xvfb, which draws no window frame). Seen on the way: frame 19 of `builds/ear-test-linux/ear_test.x86_64` shows the ear test's start screen ("Ear test", Tester ID, Output, "Clips found: above 5 · inside 4 · below 4"), not the game.
- **Result:** `tools/ci.sh` and `tools/ci.sh --export` both pass. Tests: 221 passed, 0 failed, 28 expected (ear test 120 passed, 23 expected; project setup 39; launch options 23; input actions 16; watch faults 11 passed, 5 expected; engine globals 7; title screen 5). `git diff --stat` on the ear test's closed paths is empty. `project.godot` differs only by the AC 4 lines.
- **T1, runner split.** `TestCase` keeps the counter names `_passed`, `_failed`, `_expected_total` and `_logger`, so the moved `_check` / `_expect_begin` / `_expect_end` bodies are byte-identical. `LogCounter` is an inner class (`TestCase.LogCounter`), so `tests/` gains no second global name. Every helper and `_test_` body in `test_ear_test.gd` is byte-identical to the old file (checked with `diff`). Declaration order differs from the old `_run()` order in three places, but the counts are unchanged and the 120 check names are the same set, so no function was moved (T1.5).
- **Runner, stricter than asked:** a test file with no `_test_` function fails, and so does an error or warning logged outside any file.
- **Decisions an agent took (restrictive reading; Sonlm may revisit):** (1) a switch given twice is a setup problem `launch.repeated`, and the first good value stands (a bad value does not block a later good one; changed at code review); (2) a seed over 18 digits is a `launch.seed` problem; (3) `InputActions.register()` reports `input.defined_elsewhere` when an action already exists with other bindings; (4) the start page shows a heading line "Setup problems found at start:" above the list (`UiText.SETUP_PROBLEMS_HEADING`), and nothing above "No setup problems.".
- **Additions beyond the story's file list:** `tests/watch/test_title_screen.gd` checks AC 1 headless (name plus "No setup problems.", or the heading plus each problem in order, and no pixel sizes). `EngineGlobals.mouse_mode_for()` makes the screen-kind → mouse-mode mapping testable; the engine's actual mouse mode stays a manual check.
- **Main** types the title screen through `const TitleScreen := preload(...)`, because the screen has no `class_name`.
- **EAR_TEST.md:** the test command line is still correct (the runner kept its path), so it is unchanged. Besides the run line and the CI line, one note was added: run from source, the ear test's CSVs now go to the game's folder (`mourning_watch/ear_test_results/`). Without it, "Where the CSVs are" would be wrong for source runs.
- **project-context.md:** the three "until that story" notes and the Usage Guidelines line are replaced or removed. `Last Updated` was already 2026-11-20.
- **Manual checks still for Sonlm** (the results above stand; this list is what is left):
  - M2. `godot --path game res://scenes/ear_test.tscn`: run one trial; it looks and sounds as before.
  - M3. `builds/ear-test-linux/ear_test.x86_64` (built by the last `--export` run): the window title is "Ear Test".
- Committed as `05124dd` on `ear-test-prototype`.
- **Code review, 2026-11-20 (gds-code-review, Claude Fable 5.2):** no acceptance criterion was violated. 4 decisions (3 fixed, 1 dismissed), 17 patches applied, 2 deferred (DW-24, DW-25), 13 dismissed. See "Review Findings" under Tasks. After the fixes `tools/ci.sh` and `tools/ci.sh --export` pass: 237 passed, 0 failed, 28 expected (ear test 120 passed, 23 expected; launch options 28; input actions 20; project setup 37; title screen 7; runner rules 7; watch faults 11 passed, 5 expected; engine globals 7). Negative checks run and removed: `extends Node2D` and `"#" + str(randi())` in a probe `watch/sim/` file fail the purity check, a sim class extending another sim class passes, `print_rich(` in `watch/core/` fails the print check, `tools/ci.sh --exports` exits 2; in a scratch copy, a test crashing inside an expect window, a test using `await` and a misnamed test file each fail the run.

### File List

- `_bmad-output/implementation-artifacts/1-1-the-game-starts-beside-the-ear-test.md` (modified)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified)
- `_bmad-output/project-context.md` (modified)
- `game/EAR_TEST.md` (modified)
- `game/WATCH.md` (new)
- `game/export_presets.cfg` (modified)
- `game/project.godot` (modified)
- `game/tests/ear_test/test_ear_test.gd`, `.gd.uid` (moved from `game/tests/run_tests.gd`, `.gd.uid`; cut down)
- `game/tests/run_tests.gd`, `.gd.uid` (new: the self-listing runner)
- `game/tests/test_case.gd`, `.gd.uid` (new)
- `game/tests/print_start_values.gd`, `.gd.uid` (new)
- `game/tests/watch/test_project_setup.gd`, `.gd.uid` (new)
- `game/tests/watch/test_launch_options.gd`, `.gd.uid` (new)
- `game/tests/watch/test_input_actions.gd`, `.gd.uid` (new)
- `game/tests/watch/test_watch_faults.gd`, `.gd.uid` (new)
- `game/tests/watch/test_engine_globals.gd`, `.gd.uid` (new)
- `game/tests/watch/test_title_screen.gd`, `.gd.uid` (new)
- `game/watch/main.tscn`, `main.gd`, `main.gd.uid` (new)
- `game/watch/core/launch_options.gd`, `.gd.uid` (new)
- `game/watch/core/input_actions.gd`, `.gd.uid` (new)
- `game/watch/core/watch_faults.gd`, `.gd.uid` (new)
- `game/watch/core/watch_session.gd`, `.gd.uid` (new)
- `game/watch/core/engine_globals.gd`, `.gd.uid` (new)
- `game/watch/content/ui_text.gd`, `.gd.uid` (new)
- `game/watch/screens/title_screen.tscn`, `title_screen.gd`, `title_screen.gd.uid` (new)
- `tools/ci.sh` (modified)
- `_bmad/custom/gds-dev-story.toml` (new; was in commit `05124dd` and missing from this list)

Changed by the code review (2026-11-20):

- `_bmad-output/implementation-artifacts/deferred-work.md` (modified: DW-24, DW-25)
- `_bmad-output/project-context.md`, `_bmad/custom/gds-dev-story.toml`, `game/EAR_TEST.md`, `game/WATCH.md`, `.githooks/pre-commit` (modified)
- `game/tests/test_runner_rules.gd`, `.gd.uid` (new)
- `game/tests/run_tests.gd`, `game/tests/test_case.gd` (modified)
- `game/tests/watch/test_input_actions.gd`, `test_launch_options.gd`, `test_project_setup.gd`, `test_title_screen.gd` (modified)
- `game/watch/core/input_actions.gd`, `game/watch/core/launch_options.gd`, `game/watch/screens/title_screen.gd` (modified)
- `tools/ci.sh` (modified)

## Change Log

- 2026-11-20: Story 1.1 implemented (gds-dev-story). The test runner is split into a self-listing runner plus `TestCase`, with the ear test's file moved, bodies unchanged and still 120/23. `project.godot` and the presets carry the game's main scene, name and user folder, with `.eartest` overrides. New core scripts: `LaunchOptions`, `InputActions`, `WatchFaults`, `WatchSession`, `EngineGlobals`; plus `UiText`, `Main` and the bare start page. CI adds the purity and print checks with a self-check, smoke runs of the game and the ear test, a run per `--start` value, and a start check of the ear test build. Docs: `WATCH.md`, `EAR_TEST.md` fixes, `project-context.md` notes. Status → review; M1 to M3 left for Sonlm.
- 2026-11-20: Code review (gds-code-review). The runner now fails a test that stops before its end (a script error inside an expect window, or `await`) and a misnamed test file. `LaunchOptions`: a bad value no longer blocks a later good one, and a switch typed before `--` is a setup problem. `tools/ci.sh`: unknown arguments stop it; strings are dropped before the greps; the print check covers the whole `print` family; the purity check is wider and checks base types; exports fail on error lines or a stale build; the build start uses a scratch data folder. Smaller fixes to `InputActions.key_name`, the title screen, the tests and the docs. Status → done; M2 and M3 are still for Sonlm.
