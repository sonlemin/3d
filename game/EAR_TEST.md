# Ear test: tester protocol

Can a player tell where a cry comes from by ear: which direction (town, far bank, left rail,
right rail) and which level (above, inside, below)? This gray-box Godot project measures that.

## Before the first session

From the repo root:

```
python3 game/tools/make_placeholder_cries.py   # only if the placeholder WAVs are missing
godot --headless --path game --import          # after adding or changing any clip
godot --headless --path game -s res://tests/run_tests.gd
```

Then run the test with `godot --path game`, or open `game/` in the editor and press F5.

Until `build_scored_order()` in `game/scripts/trial_plan.gd` is implemented, the scored round
plays in a fixed, unshuffled order and one test reports `FAIL (awaiting Sonlm's build_scored_order)`.
Don't run real testers before that.

## Running a session

1. **Room.** Use a quiet room: no music, fans or open windows. Use the same machine and the same
   system volume for every tester. Set the volume once, at a comfortable level, and leave it.
2. **Output modes.** Each tester does two sessions: one on headphones and one on speakers.
   Alternate which comes first: odd-numbered testers start with headphones, even-numbered testers
   with speakers. On speakers, the tester sits centred between them.
3. **Setup screen.** Enter the tester ID (for example `t01`) and pick the output mode that is
   actually in use. Start stays disabled until both are set and every level folder has clips.
4. **Brief the tester, then keep quiet.** "You're standing in the middle of a bridge. Each trial
   starts facing the far bank. After a second of silence, a cry plays for 4 seconds. Move the
   mouse to turn your head while it plays. Then click where it came from: town, left rail,
   right rail or far bank, and above, inside or below." The map beside the grid shows which way
   is which. Don't give hints during the trials.
5. **Practice (12 trials).** Each combination plays once, with feedback for 2 seconds after
   each answer. Practice is logged but not scored.
6. **Scored round (24 trials).** Each combination plays twice, never twice in a row. No feedback.
7. **Esc** pauses: the cry stops and the mouse is released. Resuming replays the same trial
   from its start. Losing window focus also pauses.
8. **Results** appear at the end. **New session** goes back to the setup screen and keeps the ID
   and the output mode. Switch the mode before the tester's second session.

## Pass rule

A session passes when both direction **and** level are right on at least **80%** of its
24 scored trials, which means at least 20 of 24. The results screen also shows direction
accuracy (any level), level accuracy (any direction), and both-correct accuracy for each level.

## Where the CSVs are

Each session writes its own file: `user://ear_test_results/<tester>_<mode>_<YYYYMMDD-HHMMSS>.csv`.
A row is flushed after every answer, so a crash keeps everything answered so far.

- Linux: `~/.local/share/godot/app_userdata/Ear Test/ear_test_results/`
- Windows: `%APPDATA%\Godot\app_userdata\Ear Test\ear_test_results\`
- macOS: `~/Library/Application Support/Godot/app_userdata/Ear Test/ear_test_results/`

The results screen shows the full path, and **Open results folder** opens it. The columns are:
`tester_id, output_mode, round, trial_index, true_direction, true_level, answer_direction,
answer_level, direction_correct, level_correct, both_correct, response_ms, clip`.
`response_ms` is measured from the start of the cry, so it is always at least 4000 because the
grid appears only after the 4-second cry. If the file can't be written, the results screen
shows the error and the path it tried.

## Clips

- Clips go in `game/audio/cries/<above|inside|below>/` and must be `.wav` files. Other audio
  files are skipped with a warning. Every `.wav` is imported as mono.
- The `placeholder_*.wav` files are synthesized by `game/tools/make_placeholder_cries.py`.
  Delete them once real clips are in place.
- Log every real clip in `game/audio/cries/CREDITS.md`. No AI-generated audio.
- Run `godot --headless --path game --import` after adding clips. Clips that haven't been
  imported don't show up, and the setup screen names any level folder with no clips.

## Tuning

Source positions, bus filters and reverb, emitter settings, timings, trial counts and the pass
mark are constants at the top of `game/scripts/trial_plan.gd`. The bus FX constants are applied
over `default_bus_layout.tres` at startup.

## Manual check (can't be done headless)

Run one practice round on headphones and check three things: the three levels sound clearly
different, the cry pans as you turn your head (a left-rail cry moves to centre when you face it),
and a CSV appears in the results folder.
