---
title: 'Ear test prototype: can players place a cry by ear?'
type: 'feature'
created: '2026-11-12'
status: 'done'
baseline_commit: '459a388ec1b9a2b3086c25c531a990c3c762ce09'
context:
  - '{project-root}/_bmad-output/planning-artifacts/briefs/brief-3d_game-2026-11-12/addendum.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The game depends on players placing a cry's direction and level by ear, and Godot's built-in 3D audio has no front/back or elevation cue. That pillar is unproven.

**Approach:** A private gray-box Godot test. A first-person listener stands mid-span with free mouse-look; cries play from 4 directions × 3 levels; the tester names each on a 12-button grid. Each level has its own audio bus (filters and reverb); the kind of cry is mixed across levels, so only the sound treatment and position tell the level. Sessions are logged to CSV and scored against the brief's pass mark.

## Boundaries & Constraints

**Always:**
- Godot 4.7.2, Forward+, statically typed GDScript; the Godot project lives in `game/`.
- Directions are world terms: town, far bank, left rail, right rail (left/right as seen facing the far bank). Levels: above, inside, below.
- A session: tester ID and output mode (headphones/speakers) → 12 practice trials (each combination once, with feedback) → 24 scored trials (each combination twice, never the same combination back to back) → results.
- Pass = both direction and level correct on ≥ 80% of scored trials in that session. Results also show direction-only %, level-only %, and both-correct % per level.
- Each trial starts facing the far bank; mouse-look is free during the listen window; walking is not possible.
- Trial ordering, source positions and scoring live in one pure script that tests run headless. Positions, bus FX and timings are tunable constants in one place.
- Clips are discovered at runtime from `res://audio/cries/<level>/` via `ResourceLoader.list_directory()`; one random clip per trial, from any level's folder (`MIX_CRY_KINDS`).

**Ask First:** installing any addon or downloading anything (export templates, sound libraries); changing the direction/level set, trial counts or pass rule.

**Never:** HRTF or audio plugins (DW-1); AI-generated audio; visual cues, markers or subtitles during the listen window; enemies, ambience, music, fog or shaders; export presets or builds (DW-2); third-party test frameworks.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Correct answer | Scored trial, true = above · left rail, answer the same | CSV row with direction_correct=1, level_correct=1, both_correct=1 | N/A |
| Half right | True = below · town, answer = inside · town | direction_correct=1, level_correct=0, both_correct=0 | N/A |
| Practice feedback | Any practice answer | Shows "Correct" or the true combination for 2 s; logged as round=practice; excluded from score | N/A |
| Empty level folder | No `.wav` in `audio/cries/inside/` | Setup screen names the empty folder; Start disabled | No crash |
| Non-WAV files | `CREDITS.md`, `.ogg` beside clips | Only `.wav` used | Skipped audio files printed as a warning |
| Bad tester ID | Empty or spaces only, `ann/../x`, `Sơn` | Empty → Start disabled. Spaces at the ends are trimmed. In the filename, characters other than letters (any script), digits, `-` and `_` become `_`; the CSV `tester_id` keeps the trimmed ID as typed | N/A |
| Pause | Esc or focus loss mid-trial (silence, cry, answer grid, practice feedback) | Mouse released, cry stops. Paused in the silence or the first 1 s of the cry: resume replays the trial from its start. Paused later in the cry or at the answer grid: resume goes to the grid, no replay. Paused in feedback: resume goes to the next trial. Every pause counts in a CSV `pauses` column | N/A |
| Write failure | `user://` not writable | Results still shown, plus the error and the attempted path | No crash |

</frozen-after-approval>

## Code Map

Greenfield: no game code yet. The addendum (in `context`) holds the Godot audio research.

## Tasks & Acceptance

**Execution:**
- [x] `game/project.godot`, `game/default_bus_layout.tres` -- project (Forward+, `audio/general/3d_panning_strength` = 1.0, WAV importer default `force/mono`), buses Below/Above/Inside with filters and reverb -- level cues that don't depend on HRTF
- [x] `game/tools/make_placeholder_cries.py`, `game/audio/cries/{above,inside,below}/` -- Python stdlib script writing 2 mono 16-bit WAVs per level (shriek-like, sob-like, whisper-like), deterministic seed; `CREDITS.md` with a license-entry template -- runs today, real clips drop in later
- [x] `game/scripts/trial_plan.gd` -- combinations, ordering, source position per combination, scoring, CSV row -- pure and testable
- [x] `game/scripts/cry_library.gd` -- discover clips per level, skip non-WAV, report empty levels
- [x] `game/scripts/results_log.gd` -- write `user://ear_test_results/<id>_<mode>_<timestamp>.csv`
- [x] `game/scenes/ear_test.tscn`, `game/scripts/ear_test.gd`, `game/scripts/listener.gd` -- gray-box span (4 m deck, parapets, piers, lit boxes on the town end, open abyss), mouse-look rig, emitter, session state machine, setup/answer/results UI
- [x] `game/tests/run_tests.gd` -- SceneTree runner covering the I/O matrix and ordering invariants; exits non-zero on failure
- [x] `game/EAR_TEST.md` -- tester protocol: quiet room, both output modes in alternating order across testers, where CSVs land, the pass rule

**Acceptance Criteria:**
- Given a fresh checkout, when the placeholder script and Godot import run, then the project opens with no import or script errors.
- Given a scored session of 24 trials, when it ends, then the CSV has 24 scored rows plus 12 practice rows, and the results screen matches the CSV.
- Given any seed, when the plan builds a scored order, then each combination appears exactly twice and never twice in a row.
- Given a cry from the left rail, when the tester turns to face it, then it pans toward center.

## Spec Change Log

- **2026-11-12, human renegotiation (Sonlm), frozen Pause row.** Trigger: the build replayed the cry when a tester resumed from a pause taken at the answer grid, giving a free second listen that inflates scores. Amended: a pause at the answer grid now resumes to the grid with no replay; pauses in the silence or the cry still replay the trial. Known-bad state avoided: testers pausing on purpose to hear a cry twice. KEEP: pause on Esc and on focus loss; replay from the start when paused before the answer grid.
- **2026-11-12, human renegotiation (Sonlm) after step-4 review, frozen Pause row.** Trigger: all three reviewers found that a pause late in the cry still replayed the whole trial, so repeated pauses gave unlimited listens, invisible in the CSV. Amended: replay only if paused in the silence or the first 1 s of the cry; a later pause resumes at the grid; feedback pauses resume to the next trial; a `pauses` CSV column counts every pause. Known-bad state avoided: unlimited, unrecorded re-listens. KEEP: no replay from the grid; pause time excluded from response time.
- **2026-11-12, human renegotiation (Sonlm) after step-4 review, frozen Bad tester ID row.** Trigger: ASCII-only sanitizing merged distinct Vietnamese names (`Sơn`, `Sân` → `S_n`) in the CSV, and edge-space trimming wasn't in the row. Amended: letters of any script stay in the filename, ends are trimmed, and the CSV keeps the ID as typed. Known-bad state avoided: different testers' rows sharing an ID.
- **2026-11-14, human request (Sonlm): Replay button, practice only.** Trigger: a tester who missed a practice cry had no way to hear it again. Amended: the practice answer grid has a Replay button that plays the same cry again from the silence; a `replays` CSV column counts presses. Known-bad state avoided: extra listens in the scored round inflating the gate score. KEEP: one listen per scored trial; the frozen pause rules unchanged.
- **2026-11-18, human renegotiation (Sonlm), frozen Intent and Always.** Trigger: with one kind of cry per level (shriek above, sob inside, whisper below), testers could name the level from the kind of cry alone, so the level score didn't test hearing the level. Amended: each trial draws its clip from any folder (each kind equally likely) and plays it through the trial's level bus and position; a `cry_kind` CSV column records the source folder. Known-bad state avoided: a pass that only proves cry recognition. KEEP: per-level buses and positions; one random clip per trial.

## Design Notes

Starting values, tuned by ear:

| Level | Position (horizontal 6 m along the direction unless noted) | Bus FX |
|---|---|---|
| above | y +5 m | HighPass 400 Hz; Reverb room 0.4, damping 0.1, wet 0.2 (open air) |
| inside | ear height, in a parapet pylon (L/R at 1.85 m) or the deck (town/far bank, y −0.5 m) | LowPass 900 Hz; Reverb room 0.15, damping 0.8, wet 0.35 (boxy, muffled) |
| below | y −6 m, in the abyss | LowPass 2500 Hz; Reverb room 0.9, damping 0.3, wet 0.45 (cavernous) |

Emitter: `attenuation_filter_db` = 0, so distance filtering doesn't blur the level filters. Listen window: 1 s of silence, then 4 s of cry (looped if shorter), then the grid appears; response time is measured from cry start.
Review fixes: the emitter uses `ATTENUATION_DISABLED` (no distance loudness cue), the cry fades out over the last 50 ms of the window, and the inside-rail sources sit at ear height in a 1.9 m parapet pylon at x = ±1.85 m (the rest of the parapet stays 1.2 m).

## Verification

**Commands:**
- `python3 game/tools/make_placeholder_cries.py` -- expected: 6 WAVs, mono
- `godot --headless --path game --import` -- expected: exit 0, no errors
- `godot --headless --path game -s res://tests/run_tests.gd` -- expected: all pass, exit 0
- `godot --headless --path game --quit-after 120` -- expected: no script errors

**Manual checks:**
- `godot --path game`: one practice round on headphones. The levels sound distinct, panning follows head turns, and the CSV is written.

## Suggested Review Order

**Session flow and the pause rules (start here)**

- The state machine every trial walks; pause/resume rules live in one place.
  [`ear_test.gd:15`](../../game/scripts/ear_test.gd#L15)

- Pause records where it stopped; early-cry pauses replay, later ones go to the grid.
  [`ear_test.gd:281`](../../game/scripts/ear_test.gd#L281)

- Resume applies the decision and keeps paused time out of response_ms.
  [`ear_test.gd:307`](../../game/scripts/ear_test.gd#L307)

- Look is enabled only at cry start, after facing resets to the far bank.
  [`ear_test.gd:373`](../../game/scripts/ear_test.gd#L373)

- Practice rows land after feedback (so feedback pauses count); scored rows immediately.
  [`ear_test.gd:262`](../../game/scripts/ear_test.gd#L262)

**Trial plan: the single home for every tunable**

- Replay window, fade, attenuation and bus FX constants: tune by ear here only.
  [`trial_plan.gd:67`](../../game/scripts/trial_plan.gd#L67)

- Scored order by rejection sampling: uniform over valid orders, block fallback.
  [`trial_plan.gd:165`](../../game/scripts/trial_plan.gd#L165)

- Where each direction × level cry sits in the world.
  [`trial_plan.gd:199`](../../game/scripts/trial_plan.gd#L199)

- Scoring: both-correct pass mark plus direction, level and per-level breakdowns.
  [`trial_plan.gd:265`](../../game/scripts/trial_plan.gd#L265)

**Audio: level cues without HRTF**

- BUS_FX overwrites the editor's buses at startup; any mismatch blocks Start.
  [`ear_test.gd:134`](../../game/scripts/ear_test.gd#L134)

- Fade-out curve that removes the end-of-window click.
  [`trial_plan.gd:221`](../../game/scripts/trial_plan.gd#L221)

**Clips and results data**

- Discovery loads every clip and flags un-imported files; any problem blocks Start.
  [`cry_library.gd:77`](../../game/scripts/cry_library.gd#L77)

- Tester ID: Unicode-aware trim; letters of any script kept in file names.
  [`results_log.gd:36`](../../game/scripts/results_log.gd#L36)

- Never overwrite a finished session: `_2`, `_3` suffixes.
  [`results_log.gd:91`](../../game/scripts/results_log.gd#L91)

**Peripherals**

- Logger that fails the suite on any unexpected engine or script error.
  [`run_tests.gd:36`](../../game/tests/run_tests.gd#L36)

- Pause tests across every state, including the scored round.
  [`run_tests.gd:1094`](../../game/tests/run_tests.gd#L1094)

- Placeholder generator refuses folders that already hold real clips.
  [`make_placeholder_cries.py:276`](../../game/tools/make_placeholder_cries.py#L276)

- Panning strength and WAV-to-mono import default.
  [`project.godot:20`](../../game/project.godot#L20)
