---
title: 'Ear test prototype: can players place a cry by ear?'
type: 'feature'
created: '2026-11-12'
status: 'in-review'
baseline_commit: '459a388ec1b9a2b3086c25c531a990c3c762ce09'
context:
  - '{project-root}/_bmad-output/planning-artifacts/briefs/brief-3d_game-2026-11-12/addendum.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The game depends on players placing a cry's direction and level by ear, and Godot's built-in 3D audio has no front/back or elevation cue. That pillar is unproven.

**Approach:** A private gray-box Godot test. A first-person listener stands mid-span with free mouse-look; cries play from 4 directions × 3 levels; the tester names each on a 12-button grid. Each level has its own kind of cry and its own audio bus (filters and reverb). Sessions are logged to CSV and scored against the brief's pass mark.

## Boundaries & Constraints

**Always:**
- Godot 4.7.2, Forward+, statically typed GDScript; the Godot project lives in `game/`.
- Directions are world terms: town, far bank, left rail, right rail (left/right as seen facing the far bank). Levels: above, inside, below.
- A session: tester ID and output mode (headphones/speakers) → 12 practice trials (each combination once, with feedback) → 24 scored trials (each combination twice, never the same combination back to back) → results.
- Pass = both direction and level correct on ≥ 80% of scored trials in that session. Results also show direction-only %, level-only %, and both-correct % per level.
- Each trial starts facing the far bank; mouse-look is free during the listen window; walking is not possible.
- Trial ordering, source positions and scoring live in one pure script that tests run headless. Positions, bus FX and timings are tunable constants in one place.
- Clips are discovered at runtime from `res://audio/cries/<level>/` via `ResourceLoader.list_directory()`; one random clip per trial.

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
| Bad tester ID | Empty, or `ann/../x` | Empty → Start disabled; otherwise characters other than letters, digits, `-` and `_` become `_` in the filename | N/A |
| Pause | Esc mid-trial | Mouse released, cry stops; on resume the same trial replays from its start | N/A |
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

## Design Notes

Starting values, tuned by ear:

| Level | Position (horizontal 6 m along the direction unless noted) | Bus FX |
|---|---|---|
| above | y +5 m | HighPass 400 Hz; Reverb room 0.4, damping 0.1, wet 0.2 (open air) |
| inside | ear height, in the parapet (L/R at 2 m) or the deck (town/far bank, y −0.5 m) | LowPass 900 Hz; Reverb room 0.15, damping 0.8, wet 0.35 (boxy, muffled) |
| below | y −6 m, in the abyss | LowPass 2500 Hz; Reverb room 0.9, damping 0.3, wet 0.45 (cavernous) |

Emitter: `attenuation_filter_db` = 0, so distance filtering doesn't blur the level filters. Listen window: 1 s of silence, then 4 s of cry (looped if shorter), then the grid appears; response time is measured from cry start.

## Verification

**Commands:**
- `python3 game/tools/make_placeholder_cries.py` -- expected: 6 WAVs, mono
- `godot --headless --path game --import` -- expected: exit 0, no errors
- `godot --headless --path game -s res://tests/run_tests.gd` -- expected: all pass, exit 0
- `godot --headless --path game --quit-after 120` -- expected: no script errors

**Manual checks:**
- `godot --path game`: one practice round on headphones. The levels sound distinct, panning follows head turns, and the CSV is written.
