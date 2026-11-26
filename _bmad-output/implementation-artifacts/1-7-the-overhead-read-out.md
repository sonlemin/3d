---
baseline_commit: 692cb92
---

# Story 1.7: The overhead read-out

Status: review

<!-- Created 2026-11-26 by gds-create-story from epics.md draft 0.8 ("Epic 1: story detail"). -->

## Story

As Sonlm planning a night,
I want to see every section's planks, rails and strength from above,
so that the state of the whole bridge can be read at once.

Delivers: GDD Game Mechanics 10 (what the view shows), first version. GD-11; UX-8. `DESIGN.md` span-section, Colors, Typography. Architecture AD-23 (one span view), AD-56, AD-61, AD-62, AD-69. The last story of epic 1.

## Acceptance Criteria

Canvas positions are in canvas units on the 1280×720 canvas (AD-69) unless a case says otherwise. Section numbers are the one night's (6 sections, 30 m); tests also run the 4-section def. No literal 6, 8 or 30 outside `night_defs.gd` and tests (AD-42).

1. **The span from above.** Given `--start=planning`, when the screen opens, then the whole span is seen from straight above on a `world` (`#070707`) ground, the far pier at the left and the town at the right, each section drawn with its planks to the count at the places `SpanGeometry` gives (GD-54), and `abyss` (`#000000`) wherever a plank is missing. The view is not mirrored: the RIGHT rail (+X) is the top edge and the LEFT rail (−X) the bottom edge (architecture: "the same word means the same rail in planning").
2. **Rails.** A standing rail is a solid `rail` (`#8d8982`) line along that edge; a stripped rail is a thin dashed `dim` (`#5f5d59`) line in the same place.
3. **One span view (AD-23).** It is the night's `SpanView` and `SectionView` that draw it, in a second look (the plan look), every shape placed by asking `SpanGeometry`. The night's look is unchanged: `tests/watch/test_span_view.gd` passes with no edit.
4. **Numbers.** Each section has its number above it (`label` style, `muted` `#8d8982`) and its strength below it (`number` style, `ink-bright` `#ddd6c8`). The strength is `SpanRules.strength()`: the planks while there are any, 2 for an open section (story 1.6 D4), so an all-black deck with its rails reads 2.
5. **A fallen section** is a dashed `dim` outline of its deck and nothing else inside it (no backing, no planks, no rails, no rope); it has no strength number, and keeps its section number (decision D2).
6. **Typeface and theme.** Text is Cormorant Garamond, bundled under `game/fonts/` with its licence, through a first `watch_theme.gd` that holds the `number` and `label` styles and the colours this screen uses. Every size is two thirds of its `DESIGN.md` token, rounded: 32 px and 19 px. A test checks the theme's sizes against the tokens written out, and that no other script or scene of the screen sets a pixel size (AD-69). Both styles are semibold (weight 600); figures are lining, and tabular in `number`.
7. **Read-only.** Given the read-out, when it is clicked or a key is pressed, then nothing changes (read-only until epic 5). It is flat unshaded shapes on `world`: no light, no texture, no shader, no woodcut treatment.
8. **`--show=readout`.** Given a `StartState` with mixed counts, a stripped rail and a fallen section, when `--show=readout` is run, then the planning screen opens on that state (not a night, and with no aim aid).
9. **CI.** `tools/ci.sh` starts the game with `--start=planning --seed=1` for 120 frames, and with `--show=readout`, with no error or warning line.

Also part of this story (from the documents or forced by the ACs; each has a test):

10. **It fits the window.** The sections fill the canvas width between the safe margins and the two end words, and sit in the vertical middle, on a 16:9, a wider (1706×720) and a taller (1280×960) canvas; the labels are placed again when the canvas changes size.
11. **Joints and ends** (decisions D3, D4). A rail's line stops 0.15 m short of each end of its section, so each joint between sections shows as a break in the two rail lines. The words FAR PIER and TOWN stand at the two ends in the `label` style, `muted`, capitals, turned to read upward as in the mock.
12. **The same state on foot.** `--show=readout_walk` opens the night on `readout`'s `StartState`, from the landing, so the read-out can be compared with the bridge itself.
13. **A 4-section def** is drawn with no change to any script.

**Closing steps (from "Epic 1: story detail"):** the story is done when `tools/ci.sh` passes and Sonlm has run the show-me setups below. Build order (AD-46), as far as it applies to a screen: the failing tests first, with the documents' values written out; then the geometry's shapes and the theme; then the view and the screen; then the show-me setups and the manual checks. There is no rule, event, tick step, sound or bot path in this story (see "What this story is").

**Manual checks for Sonlm** (an agent cannot verify these headless; never report one as verified unless judged from frames as the dev-story chores describe):

- **M1** (`--show=readout`; the epic's check, first half): in the default window (1280×720) and in a 1920×1080 window, the numbers are sharp and readable; the dashed lines of the stripped rail (section 2, bottom edge) and of the fallen section 4 can be seen; each section can be told from the next.
- **M2** (`--show=readout_walk`; the epic's check, second half): walk the span toward the far pier. Section 6 has 4 planks, section 5 has 1, section 4 is a gap, section 3 is open, section 2 has 5 planks and no rail on your left, section 1 is full. That is what `--show=readout` shows, left and right included.

## Decisions for this story

Points that neither the GDD, the UX documents nor the architecture settle. **Sonlm chose the recommended option for all four on 2026-11-26** (see "Decisions taken with Sonlm" in Dev Notes); the ACs and Dev Notes are written to them.

- **D1. How the night's span view becomes a flat read-out.** AC 1's last line in the epic and AD-23 say one span view draws planning, night and dawn. The night's view is 3D boxes; the read-out is flat with dashed lines and text. (Recommended) **The night's `SpanView` under a camera looking straight down, with no perspective, in a second look:** flat unshaded colours from the design tokens, an `abyss` backing under each standing section, a line for each rail (solid or dashed), a dashed outline for a fallen section, and none of the night's beams, posts, weights, piers, landing or gap rope. The numbers and words are ordinary screen text laid over it. A trial was rendered before the story was written (see "Trial results"): it proved the camera, the colours, the shapes and the text, and reads well at 720p and 1080p. It drew its own boxes, so sharing `SpanView` between the two looks is not yet proven. Declined: a separate 2D drawing of the span (crisper lines and easier rig marks in epic 5, but a second view to keep in step with the night's, and a change to AD-23); the night's boxes as they are, seen from above with light (not flat, and nothing drawn for a stripped rail).
- **D2. A fallen section's numbers.** The epic: "a fallen section is a dashed outline with no number", in a criterion about two numbers; `DESIGN.md`: "a dashed outline only" (said of the dawn view). (Recommended) **The section number stays, the strength goes:** a fallen section can still be named ("section 4 fell"), and the hints and the ledger name sections by number. Declined: no number at all above or below it.
- **D3. Telling one section from the next.** The mock draws six squares apart. On the real geometry the sections touch and the planks are evenly spaced across a joint, so in the trial a full section beside a 5-plank one could not be told apart except by where the numbers stand. (Recommended) **Each rail line stops 0.15 m short of its section's ends,** so every joint is a break in both rail lines; nothing new is drawn and every plank stays where the night has it. Declined: nothing (the numbers alone); the sections drawn apart as in the mock (the planks would not be at `SpanGeometry`'s places, against AC 3).
- **D4. The two ends of the span.** The epic asks for "far pier at the left and town at the right"; `DESIGN.md` names no mark for them; the mock has the words "Far pier" and "Town", turned upward, at the ends. (Recommended) **The two words as in the mock,** in the `label` style and `muted`. Declined: the night's two pier boxes drawn as flat shapes (GDD: the view shows planks, rails and strength; a 7 m wide pier is the biggest shape on the screen); nothing (section 1 is at the left; a newcomer cannot know which end is the town).

Settled without a question (each follows from the documents or the ACs; listed so Sonlm can revisit):

- **Strength is asked of `SpanRules.strength()`** (AD-35: computed, never stored or re-derived in a view). An open section shows 2 and a section with one plank shows 1 (story 1.6 D4, DW-49). `readout` has one of each, side by side with the gap.
- **Lining figures in both styles.** Cormorant's figures are old-style by default: its 1 reads as a small capital I, and the `label` style is capitals ("1 TRAPDOOR" in epic 5). `DESIGN.md` asks for lining and tabular figures "wherever numbers stack or change"; the trial showed the section numbers need lining ones too. `label`: lining. `number`: lining and tabular.
- **Not drawn in the plan look:** side beams and posts (GDD: "the view does not show what lies under the planks"), test weights (they stand in for the dead; planning has no dead), the piers and the landing (D4), the rope across a gap (AC 5), any bow.
- **Where the state comes from.** Planning has no `PlanEditor` until epic 5. The screen builds one `NightSim` from the `NightDef` (which applies the `StartState` through the ledger, as every test does), never advances it, and hands its geometry and span to the view once. `--start=planning` is the one night's full span; `--seed` is accepted and unused.
- **A show-me setup names its screen.** `readout` opens planning; every other row opens the night. `--show` still wins over `--start`.
- **Nothing is interactive.** No key, click or pointer does anything, Esc included (pause is epic 5); the window is closed to leave, as on the title. The mouse is visible (`ScreenKind.MENU`).
- **Line sizes are in metres** (plan-look sizes in `SpanGeometry`, "not a rule"), so they scale with the span and no pixel size is written outside the theme: a standing rail's line is 0.12 m wide, a dashed line 0.05 m (the night rope's own thickness), dashes 0.25 m long every 0.5 m.
- **The title screen is not restyled** (epic 5 grows it). The italic file of the typeface is not bundled yet (italic is for the epitaph and the vow, epic 5).
- **No bot path and no new event:** nothing in the sim changes, so the coverage test (AD-63) needs nothing.

## Tasks / Subtasks

- [x] **T0. Baseline.** Run `tools/ci.sh` before any change (in the background: it takes about 10 minutes) and write the counts in the Debug Log (story 1.6's review ended at 1561 passed, 0 failed, 64 expected, 9 shows; read the real numbers). Read "Trial results" and "Current state of the files".
- [x] **T1. The typeface** (AC 6). `game/fonts/cormorant_garamond.ttf`, `game/fonts/OFL.txt`, `game/fonts/CREDITS.md` (Dev Notes "The typeface"). Import; commit the `.import` file the import writes.
- [x] **T2. Failing tests first (AD-46)**, the documents' values written out with their source in a comment, never read from the constants under test (Dev Notes "Tests" and "Literal cases").
  - [x] 2.1 `tests/watch/test_watch_theme.gd` (`TestCase`): sizes, colours, weight, figures, the bundled file (AC 6).
  - [x] 2.2 `tests/watch/test_span_geometry.gd`: the plan shapes (backing, rail line, rail dashes, outline dashes) with literal values (AC 1, 2, 5, 11).
  - [x] 2.3 `tests/watch/test_span_plan_view.gd` (`WatchTest`): the plan look of `SpanView` (AC 1, 2, 3, 5, 13). `test_span_view.gd` is not edited.
  - [x] 2.4 `tests/watch/test_planning.gd` (`WatchTest`): the screen (AC 1, 4, 5, 7, 10, 11, 13).
  - [x] 2.5 `test_launch_options.gd`, `test_main_flow.gd`, `test_show_setups.gd`: `planning` as a start value; `readout` and `readout_walk`; the literal lists (AC 8, 9, 12).
- [x] **T3. Geometry.** `SpanGeometry`: the plan-look sizes and shapes (Dev Notes "Plan shapes").
- [x] **T4. Theme.** `watch/screens/watch_theme.gd` (Dev Notes "The theme"). `UiText`: the two end words.
- [x] **T5. View.** `SpanView` and `SectionView`: the plan look, and a way in that needs no sim (Dev Notes "The view").
- [x] **T6. Screen.** `watch/planning/planning.tscn` and `planning.gd` (Dev Notes "The screen").
- [x] **T7. Launch.** `LaunchOptions.START_VALUES`; `Main.choose()` and `_show_planning()`; `ShowSetups` rows `readout` and `readout_walk` with a screen per row; `DebugTools.show_screen()` (Dev Notes "Launch and shows").
- [x] **T8. Docs**: `game/WATCH.md`; `_bmad-output/project-context.md`; `deferred-work.md` (Dev Notes "Docs").
- [x] **T9. CI and manual checks**: `tools/ci.sh` green; each drawing rule undone on its own to see a test fail (Dev Notes "Tests"); the end-of-story chores (`_bmad/custom/gds-dev-story.toml`) with the 1080p frame taken as "Frames at 1080p" says. M1 and M2 stay Sonlm's.

## Dev Notes

### What this story is

The first planning view: a screen that shows the span from straight above, with each section's planks, rails and strength, in the game's typeface. It reads and never writes. It brings four new things into the project: the bundled typeface, the first `watch_theme.gd`, the `watch/planning/` folder, and a second look for the night's span view. It changes no rule: nothing under `watch/sim/` changes except new pure shapes in `SpanGeometry`.

**Not in this story** (do not build ahead): clicks, strips, undo, Start over, the tray, the why-line, parts in hand, rig marks, lantern reach, Ring the bell, the journal and key entries, `PlanAction`, `PlanEditor`, `PlanResult`, `NightPlan`, `hold_timer` (all epic 5); pause (epic 5); the chosen-item glow, the halo, any other theme style or colour than this screen uses (epic 5); the title in the theme (epic 5); the dawn view and the town's windows (epic 5); sound (epic 2); any art, shader or texture (epic 7). No test weights, dead, rigs or lanterns in the read-out.

### Trial results (a scratch copy of `game/`, 2026-11-26; Godot 4.7.2, Forward+ on llvmpipe under Xvfb)

A trial of D1 was built outside the project and rendered at four window sizes. Use these facts; re-check any you build on.

- **The camera.** `Camera3D`, `PROJECTION_ORTHOGONAL`, `keep_aspect = KEEP_WIDTH` (then `size` is the metres across the canvas width), `transform = Transform3D(Basis(Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 1, 0)), Vector3(0, h, mid_z))`: the camera's right is world +Z (the town), its up is world +X (the RIGHT rail), it looks down −Y. Checked: section 1's LEFT corner at the far pier lands at the bottom left, section 6's RIGHT corner at the town at the top right. Any other basis that puts the town at the right mirrors the rails.
- **`Camera3D.unproject_position()` gives canvas units**, the same at a 1280×720 and a 1920×1080 window (both (67, 455.5) and (1213, 264.5) for the two corners above), and follows the canvas on 1280×960 and 1706×720.
- **Colours come out exact** with `StandardMaterial3D.shading_mode = SHADING_MODE_UNSHADED` and an `Environment` whose `background_mode` is `BG_COLOR`: sampled pixels were `#070707`, `#55534f`, `#8d8982` and `#000000`. No light is needed.
- **A `Node3D` under a `Control` root draws behind the screen's labels.** No `SubViewport` is needed.
- **The typeface file is a variable font** (`CormorantGaramond[wght].ttf`, weight 300 to 700). Its default is Light 300, which `DESIGN.md` forbids below title size. Weight 600 is set with a `FontVariation`: `variation_opentype = {ts.name_to_tag("weight"): 600}`, with `ts = TextServerManager.get_primary_interface()`. Lining and tabular figures are `opentype_features = {ts.name_to_tag("lnum"): 1, ts.name_to_tag("tnum"): 1}`; with both, every digit is 16 px wide at 32 px (11 to 16 px without). Preloading the imported file works; the bracketed name loads too, but the file is renamed (lower snake, like every file of the game).
- **Text stays sharp at a 1080p window:** with `canvas_items` stretch Godot draws the glyphs again at the window's size. Keep the import's defaults; do not switch on MSDF.
- **Label heights:** a one-line `Label` is 24 px high at 19 px and 40 px high at 32 px.
- **A dashed `dim` line on plank colour cannot be seen** (`#5f5d59` on `#55534f`). The rope is on the deck's edge, over the plank ends, so the plan look draws a rail's line just outside the deck's edge, on the ground.
- **`--write-movie` always writes 1280×720 frames,** whatever `--resolution` says. See "Frames at 1080p".
- **Headless, the root canvas is not 1280×720.** With no display the window is 64×64 (100×100 under `-s`), and the `expand` aspect makes the root's visible rectangle 1280×1280: under `root` the deck's edges are at y 544.5 and 735.5, not 264.5 and 455.5. A `SubViewport` does report the size it is given headless (1280×720, 1706×720 and 1280×960 were tried), a screen added under it fits in the same call (its `_ready` runs at once), and `size_changed` fires inside the assignment of a new `size`. Under a `SubViewport` of 1280×720 the headless run gave the same corners as the window: (67, 455.5) and (1213, 264.5). The 120-frame smoke run of the trial printed no error on the square canvas.
- **What the trial did not do:** it drew its boxes itself (not through `SpanView`), set fonts by override (not through a `Theme`), and ran no input.

### Current state of the files this story changes (read 2026-11-26, commit `692cb92`)

| File | Today | This story | Must be preserved |
|---|---|---|---|
| `game/watch/night/span_view.gd` | A night consumer: `on_tick(events, sim)` builds once (`_build(geometry, section_count)`: piers, landing, one `SectionView` per section, four lit gray materials), hands `SECTION_FELL` to its section, then `show_state(sim, n)` for each | A look (`NIGHT` by default, `PLAN`), and `show_span(geometry, span, groan_ticks)` that `on_tick()` calls after the events; in the plan look no piers and no landing, and unshaded materials in the colours it is handed | `on_tick()`'s signature and order (events first, AD-49); `box()`; every colour and node name of the night look |
| `game/watch/night/section_view.gd` | `_init(geometry, section, materials)` makes beams and posts; `show_state(sim, n)` reads `sim.span` and `sim.ticks.groan`; `fall()`, `fall_step()`, the bow, the gap rope; `_drop()` | `show_state()` takes the span and the groan ticks, not the sim; the plan look per "The view" | Everything the night look does: `test_span_view.gd` is the guard and is not edited |
| `game/watch/sim/span_geometry.gd` | Every shape of the night; "gray-box" sizes as constants | Plan-look sizes and four pure shapes | Every existing shape and value |
| `game/watch/main.gd` | `choose()` → `Choice{open, def, problems}` with `OPEN_TITLE`, `OPEN_NIGHT`, `OPEN_LIST`; every show opens the night; `_show_night()` adds the debug parts | `OPEN_PLANNING`; `--start=planning`; a show's screen asked of the debug tools; `_show_planning(def)` with no debug parts | `choose()` logs nothing; `--show` wins over `--start`; the debug tools are called, never named (boundary 4); screen changes deferred (AD-51) |
| `game/watch/core/launch_options.gd` | `START_VALUES = [&"night"]`; its comment says planning comes in story 1.7 | `[&"night", &"planning"]`; the comment | One table; `parse()` logs nothing |
| `game/watch/debug/show/show_setups.gd` | `_table()`: name → `[description, builder]`; 9 rows | A screen per row (`&"night"` or `&"planning"`), `screen_of()`; rows `readout`, `readout_walk` | The existing rows and their order; `list_line()`'s format (CI reads it) |
| `game/watch/debug/debug_tools.gd` | `show_names()`, `show_def()`, `print_show_list()`, `make_trace()`, `make_aim_aid()` | `show_screen(show_name) -> StringName` | The rest |
| `game/watch/content/ui_text.gd` | The name, the two setup-problem lines, the mouse button names | The two end words | The rest |
| `game/tests/watch/test_launch_options.gd` | `_test_start_values_so_far` compares `START_VALUES == [&"night"]` | Both values, and `--start=planning` accepted | The rest |
| `game/tests/watch/test_show_setups.gd` | `_test_debug_tools_list` compares the 9 names literally | 11 names; the two new setups; `screen_of()` | The rest |
| `game/tests/watch/test_main_flow.gd` | 8 tests of `choose()` | `--start=planning`; `--show=readout` opens planning with its def; `--show=readout --start=night`: the show wins, planning opens | The rest |
| `tools/ci.sh` | Starts the game once per `--start` value (`tests/print_start_values.gd`) and once per show in `--show=list` | **No change needed:** both lists grow by themselves (AC 9). Check the run prints `ok (2)` start values and 11 shows | Everything |
| `game/project.godot`, `game/export_presets.cfg` | The canvas lines; the ear test's two presets | **No change.** The theme is set on the screen's root, never as the project's theme (the ear test shares the file) | Every line (`test_project_setup.gd`) |

New: `game/fonts/` (the font, `OFL.txt`, `CREDITS.md`), `game/watch/screens/watch_theme.gd`, `game/watch/planning/planning.tscn`, `planning.gd`, three test files.

### The typeface

- Source: Google Fonts, `https://github.com/google/fonts/tree/main/ofl/cormorantgaramond` (files `CormorantGaramond[wght].ttf`, 1,195,560 bytes, sha256 `b20b7d9626dd956b2c5e558692ad328b1f19e3275e2782db4fa07670d83f35e0`, and `OFL.txt`, 4,387 bytes, read on 2026-11-26). Upstream: `github.com/CatharsisFonts/Cormorant`, commit `6d210fd3550b7358ca62d6ba3e354ec1ec940813`. Designer: Christian Thalmann. SIL Open Font License 1.1; no Reserved Font Name is declared, and renaming the file is not a change to the font.
- Download with `curl` into the scratchpad first, check the hash, then copy: the font as `game/fonts/cormorant_garamond.ttf` (bytes unchanged), the licence as `game/fonts/OFL.txt` (unchanged). If the hash differs, the upstream file has changed: record the new hash and re-check weight 600 and the two figure features before going on.
- `game/fonts/CREDITS.md`: the family, designer, licence, both URLs, the upstream commit, the original file name, the hash, the date, and that only the upright file is bundled so far.
- `godot --headless --path game --import`, then commit `cormorant_garamond.ttf.import` as written (never invent a `uid://`).
- Only `watch_theme.gd` names the font file.
- The licence must go with the font in every build. The game's presets do not exist yet (epic 2), and `OFL.txt` is not a resource, so nothing exports it today; the ear test's presets export all resources and will now carry the `.ttf` (its own metadata holds the copyright and licence text). Do not edit the presets. Write the deferred-work item of "Docs".

### The theme (`game/watch/screens/watch_theme.gd`, `class_name WatchTheme`, `extends RefCounted`)

The one place a `DESIGN.md` token becomes a canvas size (AD-69). Static only; no state.

- **Tokens at 1080p**, as named constants with the `DESIGN.md` section in a `##` comment: `number` 48 px, weight 600, letter spacing 0; `label` 28 px, weight 600, letter spacing 0.16 em, capitals; `spacing.2` 16 px; `safe-margin` 48 px.
- **`canvas_px(token_px: float) -> int`**: `roundi(token_px * 2.0 / 3.0)`. This reproduces `DESIGN.md`'s whole "At 720p" column (see L1). Every pixel value of a screen goes through it: font sizes, the label's letter spacing (0.16 × 28 = 4.48 → 3 px, as the `FontVariation`'s `spacing_glyph`), the gap (16 → 11) and the safe margin (48 → 32).
- **Colours** of this screen, by token name: `world` `#070707`, `abyss` `#000000`, `ink-bright` `#ddd6c8`, `muted` `#8d8982`, `dim` `#5f5d59`, `plank` `#55534f`, `rail` `#8d8982`. No others yet.
- **`build() -> Theme`**: two type variations of `Label`, `&"WatchNumber"` and `&"WatchLabel"`, each with its font (a `FontVariation` on the bundled file: weight 600; `number` with `lnum` and `tnum`, `label` with `lnum` and its letter spacing), its `font_size` and its `font_color` (`ink-bright` for `number`, `muted` for `label`: the only colour each has on this screen; epic 5 adds the rest). The screen sets `theme` on its root and `theme_type_variation` on each label; no label gets a font, size or colour override.
- Capitals are part of the `label` style but are a property of the `Label` (`uppercase`), not of a `Theme`. Give the theme a small helper that makes a styled label (variation set, `uppercase` for `label`), so epic 5's screens do not each remember it.
- The line-height tokens (1.0 and 1.2) are not applied: every label here is one line, and the layout measures the label's own rectangle.

### Plan shapes (`SpanGeometry`; pure, sizes in metres, each constant marked "plan-view size; not a rule")

| Constant | Value | For |
|---|---|---|
| `PLAN_RAIL_WIDTH` | 0.12 | A standing rail's line, across |
| `PLAN_DASH_WIDTH` | 0.05 | A dashed line, across |
| `PLAN_DASH_LENGTH` | 0.25 | One dash, along its line |
| `PLAN_DASH_STEP` | 0.5 | From one dash's start to the next |
| `PLAN_JOINT_INSET` | 0.15 | How far short of each section end a standing rail's line stops (D3) |

- `plan_backing_box(section)`: the deck's footprint (`deck_box()`'s x and z), lying wholly under the planks (its top at the planks' underside).
- `plan_rail_box(section, side)`: the standing rail's line: `PLAN_RAIL_WIDTH` across, its inner edge on the deck's edge (x ±2.5) and the rest outside it; along, from `section_start + 0.15` to `section_end − 0.15`; at the rope's height.
- `plan_rail_dashes(section, side) -> Array[AABB]`: the stripped rail's line: `PLAN_DASH_WIDTH` across, inner edge on the deck's edge; dashes of 0.25 m starting 0.125 m, 0.625 m, … from the section's start (centred, so 10 on a 5 m section, the last ending 0.125 m before its end). The count comes from `SECTION_LENGTH / PLAN_DASH_STEP`, not a literal.
- `plan_outline_dashes(section) -> Array[AABB]`: the fallen section's outline: the four edges of the deck's footprint, each dashed in the same way, `PLAN_DASH_WIDTH` across and centred on the edge, at the deck's top.

Heights only decide what covers what from above: the backing under the planks, the lines above them.

### The view

- **A way in with no sim.** `SpanView.show_span(geometry: SpanGeometry, span: SpanState, groan_ticks: int)` builds on its first call (the section count is `span.section_count()`) and reconciles every section; `on_tick()` handles its events and then calls it with `sim.geometry`, `sim.span`, `sim.ticks.groan`. `SectionView.show_state(span, n, groan_ticks)`. Epic 5's `PlanResult` and the dawn's `NightResult` will hand their span to the same function.
- **The look** is set before the first `show_span()` (a property or a second constructor; the default is the night's, so `night.gd` and every existing test are untouched). The plan look is handed its four colours by the planning screen (`plank`, `rail`, `dim`, `abyss` from `WatchTheme`): `watch/night/` names no screen script.
- **In the plan look `SpanView`** builds no pier and no landing, and its materials are unshaded.
- **In the plan look `SectionView`** builds no beams and no posts, and reconciles with state as the night look does (make what is missing, free what is gone, by name):
  - standing: `Backing` (abyss), `Plank<place>` at `plank_place()` exactly as the night (plank colour), and per side `Rail<L|R>` (`plan_rail_box()`, rail colour) when the rope stands or `RailDashes<L|R>` (one box per dash, dim) when it does not;
  - fallen: everything above is dropped and `Outline` (one box per dash, dim) is made; no `GapRope`;
  - no weights, no bow (a bow moves planks down only, which cannot be seen from above; leave the planks at `plank_place()`).
- `fall()` and `fall_step()` are the night's: nothing falls in planning (no events are handed to it).

### The screen (`game/watch/planning/planning.tscn`, `planning.gd`; no `class_name`, `Main` preloads it as it does the night)

- The scene is thin (AD-62): a `Control` root filling the screen by anchors, and its script. Everything else is made in code.
- `setup(session: WatchSession, def: NightDef)`, called by `Main` before the screen enters the tree. Opened without it (the scene run alone from the editor): `push_warning("planning.no_setup: ...")` and nothing is drawn, as `night.gd` does.
- It makes its own `WatchFaults` and `NightSim.new(def, 0, faults)`, and never calls `advance()`, `command()`, `set_move()` or `set_view()`. It reads `sim.geometry` and `sim.span` only.
- Tree, by name (tests find these): `Plan` (`Node3D`) with `Camera` (`Camera3D`, current, with the `world`-coloured environment) and `SpanView`; then the labels `Number<n>` and `Strength<n>` for each section, `FarPierWord` and `TownWord`.
- **The fit** is one function, called in `_ready()` itself (never deferred, never after an `await`: a test reads the result in the same call) and again whenever the canvas changes size (`get_viewport().size_changed`). The canvas is `get_viewport().get_visible_rect().size`. If the canvas is not wider than twice `room`, the fit leaves the camera as it is (no division by nothing, no negative size, no fault).
  - `room = canvas_px(48) + (the end word's line height) + canvas_px(16)` (32 + 24 + 11 = 67 at the sizes above);
  - the sections' whole length fills the canvas width less `room` at each side: `camera.size = length × W / (W − 2 × room)`; the camera is over the span's middle (`world_z(length / 2)`, x 0), so the deck's centre line is at half the canvas height;
  - `Number<n>`: centred over the section's middle, its bottom edge `canvas_px(16)` above the deck's top edge (the +X edge, through `unproject_position()`);
  - `Strength<n>`: centred under the section's middle, its top edge `canvas_px(16)` below the deck's bottom edge; hidden for a fallen section;
  - `FarPierWord`, `TownWord`: turned a quarter turn to read upward, centred on the deck's centre line, their line box between the safe margin and `canvas_px(16)` from the span's end.
- Texts: `str(n)`; `str(SpanRules.strength(n, span))`; `UiText`'s two words ("Far pier", "Town", shown in capitals by the style).
- Every label has `mouse_filter = MOUSE_FILTER_IGNORE`; the screen has no `_input`, `_unhandled_input` or `_gui_input` and connects no input signal (AC 7).
- No literal 6 or 30: counts from `span.section_count()`, lengths from `SpanGeometry`.

### Launch and shows

- `LaunchOptions.START_VALUES = [&"night", &"planning"]`. `tests/print_start_values.gd` and CI follow by themselves.
- `Main.choose()`: `--start=planning` → `OPEN_PLANNING` with `NightDefs.one_night()`. A show → `OPEN_PLANNING` when `debug.call(&"show_screen", show_name)` is `&"planning"`, else `OPEN_NIGHT`, with the show's def either way.
- `Main._show_planning(def)`: `EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)`, instance, `setup(_session, def)`, `add_child`. No trace, no aim aid.
- `ShowSetups`:
  - `readout_start(section_count)`: planks `{2: 5, 3: 0, 5: 1, 6: 4}`, stripped rails `[Vector2i(2, LEFT)]`, fallen `[4]` (each left out when the def is shorter, as `span_counts_start()` does). Strengths read 8, 5, 2, none, 1, 4. In hand: 22 planks and 1 rope; lost: 8 planks and 2 ropes (48 and 12 hold).
  - `readout` (screen `&"planning"`): "the overhead read-out: sections at 8, 5, 0, fallen, 1 and 4 planks, section 2's left rail stripped (M1 of story 1.7)".
  - `readout_walk` (screen `&"night"`): the same start, the warden on the landing: "the read-out's span on foot, from the landing (M2 of story 1.7)".

### Literal cases (worked out by hand and against the trial; use them in the tests)

- **L1. Sizes.** `canvas_px()` of 104, 56, 48, 44, 40, 32, 28 is 69, 37, 32, 29, 27, 21, 19 (`DESIGN.md`, Typography, "At 720p"); of 36 and 56, 24 and 37 (the two other caption sizes); of 16 and 48, 11 and 32. The theme's `WatchNumber` font size is 32 and `WatchLabel`'s is 19.
- **L2. The fit at 1280×720, 6 sections.** `room` 67; 38.2 px per metre; `camera.size` 33.5079 (30 × 1280 / 1146). Section n spans x 67 + 191 (n − 1) to 67 + 191 n: 67, 258, 449, 640, 831, 1022, 1213. The deck's top edge is y 264.5 and its bottom edge 455.5. `Number1`'s rectangle is centred on x 162.5 with its bottom at y 253.5; `Strength1`'s is centred on x 162.5 with its top at y 466.5. `FarPierWord`'s centre is (44, 360) and `TownWord`'s (1236, 360).
- **L3. Other canvases.** 1280×960: the same x, the deck's edges at y 384.5 and 575.5. 1706×720: 52.4 px per metre, section 1 from x 67 to 329 and section 6's town end at x 1639, the deck's edges at y 229 and 491. 4 sections at 1280×720: 57.3 px per metre, `camera.size` 22.3386, section 1 from x 67 to 353.5, the deck's edges at y 216.75 and 503.25.
- **L4. Not mirrored.** Section 1's LEFT (−X) corner at the far pier, `Vector3(−2.5, 0, −30)`, is at canvas (67, 455.5): left and low. Section 6's RIGHT corner at the town, `Vector3(2.5, 0, 0)`, is at (1213, 264.5): right and high.
- **L5. Plan shapes, section 2 of 6** (along 5 to 10, world z −25 to −20). Backing: x −2.5 to 2.5, z −25 to −20, top at y −0.08. `plan_rail_box(2, RIGHT)`: x 2.5 to 2.62, z −24.85 to −20.15. `plan_rail_box(2, LEFT)`: x −2.62 to −2.5. `plan_rail_dashes(2, LEFT)`: 10 boxes, x −2.55 to −2.5, the first z −24.875 to −24.625, the last z −20.375 to −20.125. `plan_outline_dashes(4)`: 40 boxes (10 per edge); the +X edge's are x 2.475 to 2.525.
- **L6. `readout`.** Strength texts by section: "8", "5", "2", hidden, "1", "4"; number texts "1" to "6", all shown. Section 2 has `RailR` and `RailDashesL`; section 3 has `Backing`, no plank, `RailL` and `RailR`; section 4 has `Outline` only; planks drawn: 8, 5, 0, 0, 1, 4, each at `plank_place()` of `places_kept(count)`.

If the label's height is not 24 px at 19 px on the build machine, the rules of "The fit" hold and the literals of L2 and L3 follow from the height read; say so in the Debug Log and do not loosen the rule.

### Tests

- One test file per system; a situation only through a `StartState` on the test's own `NightDef`; no `await`; a provoked warning inside `_expect_begin`/`_expect_end`. Views run synchronously under `root` (`test_span_view.gd` and `test_title_screen.gd` are the models).
- **Theme:** L1; the two colours and the seven colour constants as literal hex; the base font's `resource_path` is the bundled file and its name begins "Cormorant Garamond"; weight 600 on both; in `number` all ten digits have the same width and it differs from the base font's widths; `label` has `lnum` and a letter spacing of 3.
- **The screen sets no pixel size** (AC 6): `planning.tscn`'s text has no `theme_override`; no control in the built screen has a font, font size or colour override or a `custom_minimum_size` (the helper of `test_title_screen.gd`); and no `.gd` under `watch/` but `watch_theme.gd` contains `font_size` (a scan of the files' text, comments left out).
- **Plan look:** L5 and L6 through node names and `position`/mesh size, as `test_span_view.gd` does; no `FarPier`, `TownPier`, `Landing`, `Beam*`, `Post*`, `Weight*` or `GapRope` node exists; every material is unshaded with the colour it was handed; a reconcile follows state (a second `show_span()` after the span changed through a sim driven by commands and ticks: a plank stripped, a rail stripped, a section fallen); the 4-section def.
- **The screen:** every canvas case, the 16:9 one included, places the screen in a `SubViewport` of that size made by the test (headless, `root`'s own canvas is 1280×1280; see "Trial results"). L2, L3, L4, L6; the labels are placed again after a size change; read-only: a left click, a right click and a key press pushed through the viewport change neither `sim.span.values()` nor any label's text nor any node of the view; opened with no `setup()`: one `planning.no_setup` warning and no labels.
- **Launch:** `START_VALUES == [&"night", &"planning"]`; `choose()` for `--start=planning`, `--show=readout`, `--show=readout --start=night`, `--show=readout_walk`; `--start=planning` without the debug tools still opens planning.
- **Each drawing rule undone on its own must fail a test** (story 1.4's habit; do it in scratch copies of `game/`, running only the named test files, never on the real tree): the camera's basis (mirrored), `KEEP_WIDTH`, the room in the fit, the label gap, a hidden strength for a fallen section, strength asked of `SpanRules.strength()` (not `planks()`), the joint inset, the rail's line outside the deck's edge, dashes for a stripped rail, the outline for a fallen section, the backing, each of beams, posts, piers and weights left out, unshaded materials, weight 600, `lnum`, `tnum`, each of the two sizes, the letter spacing, the re-fit on a size change.
- Ear test: still 120 passed, 23 expected.

### Frames at 1080p (for M1 in the end-of-story chores)

`--write-movie` writes 1280×720 frames whatever the window's size, and the server has no screen grabber (`import`, `xwd`, `scrot` and `ffmpeg` are missing). What worked in the trial:

1. Copy `game/` to the scratchpad. In the copy only, add a scene whose script instances `res://watch/main.tscn` as a child, waits 20 frames and `RenderingServer.frame_post_draw`, saves `get_viewport().get_texture().get_image()` as a PNG to a path given after `--`, and quits.
2. `xvfb-run -a -s "-screen 0 1920x1080x24" godot --path <copy> res://<that scene> --resolution 1920x1080 -- --show=readout <the scene's own switches>`. `Main` reads the switches after `--` itself; an unknown one is a setup problem, so give the scratch scene's path through an environment variable or a file, not a launch switch.
3. The image is 1920×1080: the window's real pixels. Judge the numbers from a crop at full size, and sample the four colours.

The 720p frame comes from the chores' usual `--write-movie` command with `-- --show=readout`. Say beside each result that it is Forward+ on llvmpipe. Whether the numbers are sharp on Sonlm's screen, and M2, stay Sonlm's.

### Docs

- `game/WATCH.md`: a "Planning" section (what `--start=planning` shows; how to read it: far pier left, town right, your left rail at the bottom, numbers above and strengths below, an open section reads 2, a gap is a dashed outline; it does nothing yet); the two shows in the list; the font in the fresh-checkout note.
- `_bmad-output/project-context.md`: Technology Stack (the bundled typeface under `game/fonts/`; `watch_theme.gd` exists and is the only script that names the font or a pixel size); CI line (the `--start` values are now two); Code Organization (`watch/planning/`; a show-me setup names its screen); Testing Rules (a show opens the night or planning); the night screen's "Gray boxes" rule (the read-out's flat colours are `DESIGN.md`'s, not art); "Last Updated".
- `deferred-work.md`, two new items (next free ids): (a) **the typeface's licence must ship with every build that carries the font**: `fonts/OFL.txt` in the include filter of the playtest presets when they are made (epic 2) and of the public ones (epic 8), and the credits (epic 8 story 6); the ear test's presets carry the `.ttf` from now on and are not edited. (b) **`DESIGN.md`'s span-section does not say** what D2, D3 and D4 settled, nor the section number's type style and lining figures: for the `gds-ux` update of DW-5.
- `sprint-status.yaml` and this file's record, as every story.

### Project Structure Notes

```
game/fonts/cormorant_garamond.ttf (+ .import), OFL.txt, CREDITS.md          NEW
game/watch/screens/watch_theme.gd                                           NEW
game/watch/planning/planning.tscn, planning.gd                              NEW
game/watch/sim/span_geometry.gd                                             UPDATE (plan shapes)
game/watch/night/span_view.gd, section_view.gd                              UPDATE
game/watch/main.gd, core/launch_options.gd, content/ui_text.gd              UPDATE
game/watch/debug/show/show_setups.gd, debug/debug_tools.gd                  UPDATE
game/tests/watch/test_watch_theme.gd, test_span_plan_view.gd,
                 test_planning.gd                                           NEW
game/tests/watch/test_span_geometry.gd, test_launch_options.gd,
                 test_main_flow.gd, test_show_setups.gd                     UPDATE
game/WATCH.md, _bmad-output/project-context.md, deferred-work.md            UPDATE
```

- `watch/planning/` and `game/fonts/` are in the architecture's tree; each is created with its first file. `watch_theme.gd` is in `watch/screens/` as the architecture places it; it is not a screen, so it has no `_screen` suffix.
- `watch/core/` is a closed list: nothing is added there but the one constant's new value.
- `SpanGeometry` stays pure and names nothing outside `watch/sim/`; the purity check covers the new functions.
- Variance from the architecture, to say in the Completion Notes: "Planning screen: driving `PlanEditor`" is not yet true (the screen reads an un-advanced `NightSim`); and AD-56's show-me setups now open either the night or planning.

### Project Context Rules (the ones this story touches)

- Godot 4.7.2, Forward+, GDScript fully typed (`untyped_declaration=2`); `:=` only for `const X := preload(...)`. `##` doc comment on every script and non-obvious member, saying why.
- `class_name` only for a script another script names by type (`WatchTheme`); the planning screen's root declares none. After adding a `class_name`: `godot --headless --path game --import`.
- **AD-69:** the canvas is 1280×720 and `project.godot`'s display lines never change. Only `watch_theme.gd` turns a token into a canvas size; no other script writes a pixel size for a screen.
- **AD-62:** scenes are thin; everything on the span is made in code and placed by asking `SpanGeometry`. No span coordinate in a `.tscn`, none typed in a view.
- **AD-42:** no literal 6 or 30 outside `night_defs.gd` and tests.
- **AD-35:** strength is computed (`SpanRules.strength()`), never stored and never worked out again in a view.
- **Boundary 2:** nothing outside `watch/sim/` assigns to a sim field. The screen reads.
- **Boundary 4:** nothing outside `watch/debug/` names a debug class; `Main` calls the tools by method name.
- **Boundary 6:** screens do not reach into each other; a screen is handed `WatchSession`.
- **AD-28, AD-29:** a setup problem is a `push_warning`; no `assert`; no `print` outside `watch/debug/`. A clean run prints nothing, and a smoke run fails on any warning.
- **The ear test is closed:** nothing under `game/scripts/`, `game/scenes/`, `game/audio/cries/`, `default_bus_layout.tres`, `game/tools/measure_loudness.gd`; its presets and `project.godot` untouched; 120 checks still pass.
- Gray boxes until gate 2: the read-out's flat colours are the design tokens, not art. No shader, no texture.
- A case the documents do not cover goes to Sonlm as options. Never pick one silently.
- `tools/ci.sh` before calling the work done; never `--no-verify`; never push. CI and any commit touching `game/` take about 10 minutes: run them in the background, one at a time.

### Previous story intelligence (story 1.6, done)

- `StartState.fallen` exists for this story: a section that starts as a gap, its parts moved to lost through the ledger. `SpanState.fallen(n)`, `planks(n)`, `rail_standing(n, side)`, `section_count()` are what the view reads.
- `SpanRules.strength()` is 2 for an open section and `SpanRules.open()` is "no planks and not fallen". Do not write `planks()` where strength is meant.
- The review of 1.6 found comments left wrong by later commits, check names that claimed more than the body compared, and paths the rules allow that no test ran. Name a check for what it compares; when a later change makes a comment wrong, fix the comment in the same commit.
- Sonlm's plays changed the build twice after the first commit (the sidestep, the rope). Expect M1 to change line weights or the joint mark; keep each such size a named constant in one place.
- A full test run is about 10 minutes, 8 of them `test_bot_nights.gd`. Run the named test files from a scratch copy of the runner while working; run `tools/ci.sh` whole before the commit.
- Frames are judged by the agent on llvmpipe and said so; feel and sharpness on a real screen are never reported as verified.

### Git intelligence

- `692cb92` Story 1.6: done; Sonlm's play results. `16b65b4` Story 1.6: code review fixes. `2d78688`, `e645050`: Claude's memory notes are mirrored in `.claude/memory-notes/` (change both together when a note changes). The branch is `ear-test-prototype`; never commit on `main`.
- A story is one commit named "Story 1.7: The overhead read-out" (the chores), then one per round of Sonlm's results or review fixes. Stage exactly the File List, the `.uid` and `.import` files with it.

### Latest technical notes (Godot 4.7.2)

See "Trial results": each line there was run on this server on 2026-11-26. Two more:

- A new font file is seen only after `--import`; `preload()` of it in `watch_theme.gd` fails to parse before that, and every script that names `WatchTheme` fails with it. CI imports first; a scratch copy of `game/` must be imported too.
- `Label.reset_size()` after setting a text gives the label its minimum size at once, so a rectangle can be placed in the same call (used in the trial).

### Decisions taken with Sonlm

Sonlm chose the recommended option for all four on 2026-11-26, at story creation:

1. **D1:** the night's own span view, seen by a camera looking straight down with no perspective, in a second flat look in the design colours. (Declined: a separate 2D drawing, which would change AD-23; the night's lit boxes seen from above.)
2. **D2:** a fallen section is the dashed outline with its section number above it and no strength below. (Declined: no number at all.)
3. **D3:** each rail line stops 0.15 m short of its section's ends, so every joint is a break in both rail lines. (Declined: numbers only; sections drawn apart as in the mock.)
4. **D4:** the words FAR PIER and TOWN at the two ends, small `muted` capitals turned to read upward; no pier shapes. (Declined: the piers as flat shapes; nothing.)

Sonlm was shown text sketches of D2 and D3, not the rendered trial. Also settled without a question (see "Decisions for this story"): strength from `SpanRules.strength()`; lining figures in both styles; what the plan look leaves out; the un-advanced `NightSim` as the state's source; a screen per show-me setup; nothing interactive; line sizes in metres; the title and the italic file left for epic 5; no bot path.

### References

- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md`: Epic 1 ("In", "Stories"); "Epic 1: story detail" preamble; "Story 1.7"
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`: Game Mechanics 10 (Planning from above); Game Mechanics 2 (planks are a count; the fixed order)
- `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md`: GD-11, GD-54
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/DESIGN.md`: Colors; Typography (the "At 720p" column, Rules); Layout & Spacing (Planning); Shapes ("missing things are drawn dashed"); Components, span-section; Do's and Don'ts
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`: Component Patterns, span-section (UX-8); the HUD table, "A section's strength"
- `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/mockups/key-screens.html`: Planning (the end words; number above, strength below)
- `_bmad-output/game-architecture.md`: AD-23; Directory Structure (`fonts/`, `watch/planning/`, `watch_theme`); System Location Mapping (Planning screen, Dawn); Naming Conventions; Architectural Boundaries; Built when (epic 1: "the overhead read-out as the first planning view"); AD-69
- `_bmad-output/planning-artifacts/implementation-readiness-report-2026-11-20.md`: Q4 (the typeface and a first theme in story 1.7), NFR22
- `_bmad-output/project-context.md`: all sections
- `_bmad-output/implementation-artifacts/1-6-open-sections-and-gaps.md`: AC 11 (`StartState.fallen`), D4, Review Findings
- `_bmad-output/implementation-artifacts/deferred-work.md`: DW-5, DW-49
- Code as of `692cb92`: `game/watch/main.gd`; `game/watch/core/launch_options.gd`; `game/watch/night/span_view.gd`, `section_view.gd`, `night.gd`; `game/watch/sim/span_geometry.gd`, `span_state.gd`, `span_rules.gd`, `start_state.gd`, `night_sim.gd`; `game/watch/debug/show/show_setups.gd`, `debug_tools.gd`; `game/watch/screens/title_screen.gd`; `game/tests/watch/*.gd`; `tools/ci.sh`; `_bmad/custom/gds-dev-story.toml`

## Dev Agent Record

### Agent Model Used

Claude Fable 5.2 (claude-fable-5-2), gds-dev-story, 2026-11-26.

### Debug Log References

- T0 baseline (`tools/ci.sh` at `692cb92`, before any change): tests 1561 passed, 0 failed, 64 expected; 1 `--start` value; 9 show-me setups; all checks passed.
- T1: the font file's sha256 is the story's (`b20b7d96…35e0`, 1,195,560 bytes); `OFL.txt` is 4,387 bytes. The `.import` file is the one the import wrote.
- T2 red: before any code, the three new test files and `test_main_flow.gd` / `test_show_setups.gd` did not load (`WatchTheme`, `planning.gd`, `OPEN_PLANNING`, `readout_start` not there yet); `test_launch_options.gd` failed 3 checks and `test_span_geometry.gd` its new ones.
- Found while going green: a `FontVariation` handed a typed `Dictionary[int, int]` for its features logs an engine error each time a label is shaped ("Attempted to use 'has' a variable of type 'String' into a TypedDictionary.Key of type 'int'"): the engine keeps the dictionary it is given and also looks features up by name. `watch_theme.gd` hands it plain dictionaries, with a comment saying why; project-context.md has the rule.
- The trial's sizes hold on this machine through the theme (not by override): a one-line label is 24 px high at 19 px and 40 px at 32 px, a tabular digit 16 px wide (`test_watch_theme.gd`, `_test_a_styled_label`). So no literal of L2 or L3 had to be recomputed for the build machine. (The labels' own places changed later, by Sonlm's choice of even pixels; the camera and every edge of the span are as L2 and L3 give them.)
- The screen's first 57 checks (L2, L3, L4, L6 written out) passed on their first run.
- **Found while judging M1's frames:** in the 1920×1080 capture three of the five strength digits (8, 2, 1) across, and all five top to bottom, were softer than in the 720p one: the steepest step between neighbouring pixels was about 105 of 214, against about 200 at 720p. Cause, checked against each label's place: Godot draws a control from a whole canvas pixel, and at 1.5 times an odd canvas pixel is half a screen pixel (x 155 → 232.5, y 467 → 700.5); the two digits on even x (5 at 346, 4 at 1110) were sharp across. The story's trial ("text stays sharp at a 1080p window") had not measured this. Put to Sonlm as options; see Completion Notes.
- T9, each drawing rule undone on its own (a scratch copy of `game/` per rule, the project untouched; the named test files run on the copy): 45 undone, 45 caught by a failing test on the final tree (the first pass, before the even-pixel rule: 42 undone, 41 caught; see the end of this item). Caught: the camera's basis mirrored (11 checks); `KEEP_WIDTH`; the room in the fit; the narrow-canvas guard; the gap above a number and below a strength; a fallen section's strength shown; strength from `planks()`; the re-fit on a size change; the end words not turned; the ground not `world`; a rail in the plank colour; the plan look not asked for; the joint inset 0; the rail's line centred on the deck's edge; dashes not centred in their step; no dashes for a stripped rail; the solid line left beside the dashes; no outline; a fallen section not cleared; no backing; beams, posts, the gap's rope, weights, a pier and the landing each drawn; lit materials; the late look not refused; weight 600 not applied; no `lnum`; no `tnum`; each of the two sizes swapped; the two thirds left out; no letter spacing; no capitals; the number style in `muted`; a show's screen ignored by `Main.choose()`; `--start=planning` not chosen; `readout` opening the night; a number, a strength and an end word each not moved to an even pixel; `even_px()` rounding to any whole pixel. **Not caught in the first pass, and removed:** my own line setting each label's `mouse_filter` to ignore. A Godot `Label` ignores the pointer by default, so the line did nothing; the test that every label ignores the pointer stays.
- **Not covered by a test:** the branch of `Main._ready()` that opens the planning screen for `OPEN_PLANNING` (the side effects of `_ready()` are covered by the smoke runs, which pass whichever screen opens). It is shown by the frames of `--start=planning` and `--show=readout` below.

### Completion Notes List

- Ultimate context engine analysis completed: comprehensive developer guide created (gds-create-story, 2026-11-26).
- **What was built.** `--start=planning` opens the first planning view: the span from straight above on the `world` ground, far pier left, town right, the RIGHT rail the top edge; planks to the count at the night's own places with `abyss` where one is missing; a solid `rail` line for a standing rail, a dashed `dim` line for a stripped one; each section's number above it and its strength below it in Cormorant Garamond; a fallen section as a dashed outline with its number and no strength; the words FAR PIER and TOWN at the ends. It reads and never writes: no input does anything.
- **Typeface (T1).** `game/fonts/cormorant_garamond.ttf` (bytes unchanged, renamed), `OFL.txt`, `CREDITS.md`, and the `.import` file as written.
- **Theme (T4).** `WatchTheme` (`watch/screens/watch_theme.gd`): the tokens at 1080p as named constants, `canvas_px()` (two thirds, rounded), seven colours, `build()` (two `Label` type variations, `WatchNumber` and `WatchLabel`: weight 600, lining figures, tabular in `number`, the label's 3 px letter spacing), `make_label()` (the variation, capitals for `label`) and `even_px()` (Sonlm's choice below). `UiText.FAR_PIER`, `UiText.TOWN`.
- **Geometry (T3).** `SpanGeometry`: `PLAN_RAIL_WIDTH` 0.12, `PLAN_DASH_WIDTH` 0.05, `PLAN_DASH_LENGTH` 0.25, `PLAN_DASH_STEP` 0.5, `PLAN_JOINT_INSET` 0.15 (each "plan-view size; not a rule"), and `plan_backing_box()`, `plan_rail_box()`, `plan_rail_dashes()`, `plan_outline_dashes()`. Nothing else under `watch/sim/` changed. The backing is one plank's thickness deep and the outline's dashes are 0.05 m deep with their top at the deck's top: the story gave no depth for either, and from above depth cannot be seen.
- **View (T5).** `SpanView`: `Look { NIGHT, PLAN }`, `use_plan_look(plank, rail, dim, abyss)` (before the first show; later it is `span_view.late_look`, a warning, and the look is kept), and `show_span(geometry, span, groan_ticks)`, which `on_tick()` now calls after the events (build, events, reconcile: unchanged). `SectionView.show_state(span, n, groan_ticks)` no longer takes the sim; in the plan look it draws `Backing`, the planks, `Rail<L|R>` or `RailDashes<L|R>`, and for a fallen section `Outline` only. `test_span_view.gd` passes unedited.
- **Screen (T6).** `watch/planning/planning.tscn` (the root alone) and `planning.gd`: an un-advanced `NightSim` from the def, `Plan/Camera` (no perspective, `KEEP_WIDTH`, the `world` environment), `Plan/SpanView` in the plan look, the labels, and one `_fit()` called in `_ready()` and on the viewport's `size_changed`.
- **Launch (T7).** `LaunchOptions.START_VALUES` is `night`, `planning`. `Main`: `OPEN_PLANNING`, `--start=planning`, a show's screen asked of the debug tools (`show_screen`), `_show_planning()` with no debug parts. `ShowSetups`: a screen per row, `screen_of()`, `readout` (planning) and `readout_walk` (the night), `readout_start()`. `DebugTools.show_screen()`.
- **Docs (T8).** `game/WATCH.md` (a Planning section, the shows, the `--start` and `--show` rows, the font in the fresh-checkout note); `project-context.md` (the typeface and theme, planning, the two `--start` values, a show's screen, the read-out's colours, "Last Updated"); `deferred-work.md` DW-51 (the licence must ship with the font), DW-52 (what `DESIGN.md`'s span-section does not say) and DW-53 (text is on whole screen pixels only at some window sizes).
- **Tests.** New: `test_watch_theme.gd` (61 checks), `test_span_plan_view.gd` (35), `test_planning.gd` (64). Extended: `test_span_geometry.gd` (the plan shapes, L5), `test_launch_options.gd`, `test_main_flow.gd`, `test_show_setups.gd`. Every layout case opens the screen in a `SubViewport` of the canvas size it is about.
- **Sonlm's choice, 2026-11-26 (the recommended option): every label is placed on an even canvas pixel.** `WatchTheme.even_px()`; `planning.gd` moves each number and strength to the nearest even pixel after the fit, and each end word so that the corner it is drawn from is on one. A label moves by at most 1 px. This changes the literal places of L2 and L3 (the fit's rules are as written; the move comes after them): at 1280×720 the strengths are at x 154, 346, 536, 918, 1110, y 466 (466.5 by L2) and a number's top is y 230 (its bottom 254, where L2 has 253.5); a number is centred within 1 px of its section's middle; an end word is within 1 px of the centre line along its own line and still starts at the safe margin. The camera, the span and every edge of L2, L3 and L4 are unchanged. The tests write the new places out. It makes a whole screen pixel at 1080p, 1440p and 4K; other window sizes are DW-53. Declined: leave it and judge at M1.
- **Beyond the story's file table:** a comment in `game/tests/watch/test_title_screen.gd` that said `watch_theme.gd` comes in epic 5 (it exists now; no check changed). `tools/ci.sh` needed no change.
- **Variances from the architecture, to know about:** (1) "Planning screen: driving `PlanEditor`" is not yet true: the screen reads an un-advanced `NightSim` until epic 5. (2) AD-56's show-me setups now open either the night or planning. (3) The Dev Notes ask that every label has `mouse_filter` ignore: that holds, by Godot's default for a `Label`, and no line of the screen sets it.
- **Ear test:** 120 passed, 23 expected (unchanged). Its two presets export all resources and so carry the `.ttf` from now on; they were not edited (DW-51).
- `tools/ci.sh` on the final tree: all checks passed; tests 1787 passed, 0 failed, 66 expected (baseline 1561 / 0 / 64; before the even-pixel rule 1773 / 0 / 66, also all passed); 2 `--start` values and 11 show-me setups, each smoke-run (`--start=planning --seed=1` and `--show=readout` among them, no error or warning line).
- **M1: partly verified on a virtual display** (Xvfb, Forward+ on llvmpipe (CPU Vulkan), not a real GPU), `--show=readout`, on the final tree. What was measured, and nothing more:
  - The 1280×720 window, `--write-movie`, frame judged: /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M1_720/frame00000019.png. The numbers 1 to 6 stand above the sections and 8, 5, 2, (none), 1, 4 below them; FAR PIER reads upward at the left, TOWN at the right; section 4 is a dashed outline on the ground colour; section 2's bottom edge is dashed.
  - The 1920×1080 window (the window's own pixels, saved by a scratch scene in a copy of `game/`; `--write-movie` only writes 1280×720): /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M1/readout_1080.png, with crops `crop_1080_span.png`, `crop_1080_strengths_x2.png`, `crop_1080_s2_bottom_x4.png` beside it. Sampled pixels: ground `#070707`, a plank `#55534f`, the deck between section 2's planks `#000000`, the open section 3's deck `#000000`, inside the gap of section 4 `#070707`, section 1's two rail lines `#8d8982`. Section 2's stripped rail: 10 dashes of `#5f5d59` on each of 3 pixel rows; section 4's outline: 10 dashes on its top edge (3 rows). The top rail line is broken for about 12 canvas px at the joint of sections 1 and 2.
  - The digits' edges, as the steepest step between neighbouring pixels (0 to 214 is the whole range from ground to ink), across / down, for 8, 5, 2, 1, 4. Before the even-pixel rule: 720p 201/201, 207/207, 183/207, 202/207, 200/207; 1080p 105/103, 192/105, 105/104, 104/104, 197/105. After it: 1080p 199/199, 202/207, 194/207, 199/207, 197/207 (720p unchanged). So at 1080p the strength digits are now as sharp-edged as at 720p in these captures. The section numbers above (19 px, `muted`: the whole range is 7 to 137, 130) measured after the rule: 720p across 118 to 126, down 99 to 130; 1080p across 98 to 119, down 104 to 130: none is held to half the range, as the strengths were. FAR PIER at 1080p, judged from a 3 times crop (`crop_1080_far_pier_x3.png`): every letter reads, bottom to top.
  - Also captured, same state: a 1706×720 and a 1280×960 window (/tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M1/readout_wide.png, readout_tall.png): the span fills the width and sits in the vertical middle in both.
  - The re-fit in a real window: a scratch scene opened `--show=readout` at 1280×720, then set the window to 1706×720 while the screen was open. The capture after it (/tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M1/resize_after.png) is the same as the one opened at 1706×720, pixel for pixel (0 of 1,228,320 differ).
  - `--start=planning --seed=1`, frame judged: /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/f_planning/frame00000019.png: the planning screen with six full sections, each reading 8 (this is what shows that `Main` opens planning for `--start=planning`).
  - **NOT verified, needs Sonlm:** whether the numbers are sharp and readable on a real screen at both sizes (a capture on llvmpipe says nothing about a monitor's own scaling); whether the stripped rail's dashes can be seen well enough. They are the faintest mark: 0.05 m is about 2 px at 720p and 3 px at 1080p, and where a dash lies beside a plank's end the two colours are close (`#5f5d59` beside `#55534f`); beside the black between planks it is plain. If Sonlm wants it stronger, the sizes are `PLAN_DASH_WIDTH`, `PLAN_DASH_LENGTH` and `PLAN_RAIL_WIDTH` in `span_geometry.gd`.
- **M2: partly verified on a virtual display** (Xvfb 1280×720, same renderer note; run before the even-pixel rule, which touches no file of the night), `--show=readout_walk --trace`, real input from a scratch driver: the view turned 0.3 rad down, then W held. Trace of that run: CROSSING s4 5.300 to 13.300 s (8 s), EDGING s3 R 13.300 to 17.300 s (4 s): the gap is section 4 and the open section is section 3, as the read-out shows. Frames judged: /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M2/frame00000040.png (from the landing: section 6 has 4 planks and both rails, section 5 beyond it has 1); /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M2/frame00000150.png (at the gap: one rope across section 4, section 3 beyond it is two side beams with both rails and no plank, section 2 beyond that has a rope on the right and none on the left); /tmp/claude-1000/-home-sonlm-project-3d/006710ef-5247-4acc-9ce4-2ff2f0ecec56/scratchpad/M2/frame00000521.png (on section 2 after the edging: section 1 ahead is full with both rails). The missing rope is on the left walking toward the far pier, and the read-out draws it dashed on the bottom edge: the same rail. **NOT verified, needs Sonlm:** the walk itself and the comparison by a person, side by side with `--show=readout`.
- Agent time: 2026-11-26 13:08 +0700 to 2026-11-26 13:40 +0700 (0 h 32 min; the commit's own CI run comes after it), measured by the agent.
- Sonlm's hours: (for Sonlm to fill in)

### File List

- game/fonts/cormorant_garamond.ttf (new)
- game/fonts/cormorant_garamond.ttf.import (new)
- game/fonts/OFL.txt (new)
- game/fonts/CREDITS.md (new)
- game/watch/screens/watch_theme.gd (new, with its .uid)
- game/watch/planning/planning.tscn (new)
- game/watch/planning/planning.gd (new, with its .uid)
- game/watch/sim/span_geometry.gd
- game/watch/night/span_view.gd
- game/watch/night/section_view.gd
- game/watch/main.gd
- game/watch/core/launch_options.gd
- game/watch/content/ui_text.gd
- game/watch/debug/show/show_setups.gd
- game/watch/debug/debug_tools.gd
- game/tests/watch/test_watch_theme.gd (new, with its .uid)
- game/tests/watch/test_span_plan_view.gd (new, with its .uid)
- game/tests/watch/test_planning.gd (new, with its .uid)
- game/tests/watch/test_span_geometry.gd
- game/tests/watch/test_launch_options.gd
- game/tests/watch/test_main_flow.gd
- game/tests/watch/test_show_setups.gd
- game/tests/watch/test_title_screen.gd (a comment only)
- game/WATCH.md
- _bmad-output/project-context.md
- _bmad-output/implementation-artifacts/deferred-work.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- _bmad-output/implementation-artifacts/1-7-the-overhead-read-out.md

## Change Log

- 2026-11-26: story created (gds-create-story).
- 2026-11-26: implemented (gds-dev-story): the typeface and the first theme, the plan shapes, the span view's plan look, the planning screen, `--start=planning`, the show-me setups `readout` and `readout_walk`, tests and docs. After Sonlm's choice the same day, every label of the screen is placed on an even canvas pixel (`WatchTheme.even_px()`), so its text is on whole screen pixels in a 1080p window. Status: review.
