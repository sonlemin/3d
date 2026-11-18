# Ear test: tester protocol

Can a player tell where a cry comes from by ear: which direction (town, far bank, left rail,
right rail) and which level (above, inside, below)? This gray-box Godot project measures that.

## The gate

The ear test passes when **five outside players** (not Sonlm) each pass a session on
**headphones** and a session on **speakers**: both direction and level right on at least 80%
of the scored trials, every time. How to read the results:

- **Everyone passes on both:** the pillar holds.
- **Headphones pass, but speakers fail:** ship "best with headphones", with the visual cues on
  by default for speaker players.
- **Headphones fail:** Plan B. The lantern takes over scouting.

## Before the first session

From the repo root, on a fresh checkout:

```
python3 game/tools/make_placeholder_cries.py   # only on a fresh checkout with no clips yet
godot --headless --path game --import          # after a fresh checkout and after any clip change
godot --headless --path game -s res://tests/run_tests.gd
```

Then run the test with `godot --path game`, or open `game/` in the editor and press F5.

The placeholder script refuses any level folder that already holds a real clip (a `.wav` not
named `placeholder_*`) unless you pass `--force`, so it never mixes placeholders into real clips.

## Local CI (free, no hosted service)

`tools/ci.sh` runs the import, the test suite and a 120-frame smoke run (about 10 s);
`tools/ci.sh --export` also makes both builds. A pre-commit hook in `.githooks/` runs it
before any commit that touches `game/`, and blocks the commit if a check fails. Enable the
hook once per clone with `git config core.hooksPath .githooks`; skip it once with
`git commit --no-verify`.

## Builds (no Godot needed on the test machine)

`game/export_presets.cfg` has a **Windows** and a **Linux** preset (x86_64, game data embedded,
tests left out). They need the Godot 4.7.2 export templates installed. From the repo root:

```
godot --headless --path game --import
godot --headless --path game --export-release "Windows" ../builds/ear-test-windows/ear_test.exe
godot --headless --path game --export-release "Linux"   ../builds/ear-test-linux/ear_test.x86_64
```

Each build is a single file in `builds/` (git-ignored). **Rebuild after every clip change:** the
clips are packed into the file, so a build made with the placeholders keeps playing placeholders.
The Windows build isn't code-signed, so SmartScreen may warn on first launch ("More info" →
"Run anyway"). On Linux, keep the file executable (`chmod +x`). A build saves its CSVs to the
same per-OS folders listed under "Where the CSVs are".

## Running a session

1. **Room.** Use a quiet room: no music, fans or open windows. Use the same machine and the same
   system volume for every tester. Set the volume once, at a comfortable level, and leave it.
2. **Output modes.** Each tester does two sessions: one on headphones and one on speakers.
   Alternate which comes first: odd-numbered testers start with headphones, even-numbered testers
   with speakers. On speakers, the tester sits centred between them.
3. **Setup screen.** Enter the tester ID (for example `t01`) and pick the output mode that is
   actually in use. Start stays disabled until both are set, every level folder has clips, every
   clip is imported and loads, and the audio buses are in order. Anything wrong is listed on the
   setup screen.
4. **Brief the tester, then keep quiet.** "You're standing in the middle of a bridge. Each trial
   starts facing the far bank. After a second of silence, a cry plays for 4 seconds. Move the
   mouse to turn your head while it plays. Then click where it came from: town, left rail,
   right rail or far bank, and above, inside or below." The map beside the grid shows which way
   is which. Don't give hints during the trials.
5. **Listen screen (unscored).** Before practice, the tester hears the three levels side by
   side: **Play above**, **Play inside** and **Play below** play the same cry from straight
   ahead (the far bank), so only the level changes. **Another cry** steps through every clip.
   Under each button is a short hint of what the level sounds like (above "thin, open air",
   inside "muffled, boxed in", below "cave echo"); the answer grid shows the same hints beside
   each level, as a memory aid. They never say which level a trial's cry was.
   Let the tester take as long as they like, then press **Start practice**. Nothing here is
   logged. Esc just stops the sound.
6. **Practice (12 trials).** Each combination plays once, with feedback for 2 seconds after
   each answer. A **Replay** button under the grid plays the same cry again, as often as the
   tester likes; each press is counted in the `replays` column. Practice is logged but not
   scored. The scored round has no Replay button: each cry is heard once, as in the game.
7. **Scored round (24 trials).** At the practice break, **Hear the levels again** reopens the
   listen screen (its button then says **Start scored round**), so the levels are fresh just
   before scoring. Each combination plays twice, never twice in a row, in an order shuffled
   afresh for every session. No feedback.
8. **Pausing.** Esc pauses, and so does losing window focus: the cry stops and the mouse is
   released. What resume does depends on when the pause came:
   - in the second of silence, or in the first second of the cry: the trial replays from its
     start (same cry, same clip);
   - later in the cry, or at the answer grid: back to the answer grid, without hearing the cry
     again. The time spent paused doesn't count toward `response_ms`;
   - during practice feedback: on to the next trial.

   Every pause is counted in the trial's `pauses` column. Testers aren't told these rules: the
   setup screen says only "Esc pauses", and the pause screen says only "Paused.".
9. **Results** appear at the end. **New session** goes back to the setup screen. It keeps the
   tester ID, clears the output mode (so pick the other one for the second session), and shows
   "Last session: <ID> · <mode>".

## Pass rule

A session passes when both direction **and** level are right on at least **80%** of its
24 scored trials, which means at least 20 of 24. The results screen also shows direction
accuracy (any level), level accuracy (any direction), both-correct accuracy for each level, and
the **level mix-ups**: for each true level, what the tester answered instead (for example
"above → inside 2"). Use the mix-ups to decide which level's sound to tune.

**Mixed cries.** The three clip folders hold three kinds of cry (shriek in `above/`, sob in
`inside/`, whisper in `below/`), but every trial picks its clip from any folder, each kind
equally likely, and plays it through the trial's level filter, echo and position. A whisper can
come from above. So the level score measures hearing the level, not recognising the kind of cry.
The `cry_kind` column records which folder the clip came from. To go back to one kind per level,
set `MIX_CRY_KINDS = false` in `trial_plan.gd`.

## Where the CSVs are

Each session writes its own file: `user://ear_test_results/<tester>_<mode>_<YYYYMMDD-HHMMSS>.csv`.
An existing file is never overwritten: a clash gets `_2`, `_3`, and so on before `.csv`.
In the file name, the tester ID keeps letters in any script together with their accents and
vowel marks (so `Sơn` stays `Sơn`), digits, `-` and `_`. Anything else becomes `_`: spaces,
dots, slashes and other punctuation, and joiners such as `·`, `・`, `‿` or zero-width joiners.
The `tester_id` column keeps the ID as typed, with spaces at the ends trimmed (including
no-break, ideographic and zero-width spaces). An ID made only of spaces counts as empty.

- Linux: `~/.local/share/godot/app_userdata/Ear Test/ear_test_results/`
- Windows: `%APPDATA%\Godot\app_userdata\Ear Test\ear_test_results\`
- macOS: `~/Library/Application Support/Godot/app_userdata/Ear Test/ear_test_results/`

The results screen shows the full path, and **Open results folder** opens it. The columns are:
`tester_id, output_mode, round, trial_index, true_direction, true_level, answer_direction,
answer_level, direction_correct, level_correct, both_correct, response_ms, pauses, replays, cry_kind, clip`.

- A scored row is written as soon as the tester answers. A practice row is written when its
  2 seconds of feedback end, so a pause during the feedback counts in that row. A crash or a
  forced kill during those 2 seconds can therefore lose that one unscored practice row (closing
  the window normally still writes it).
- `replays` counts Replay presses; it is always 0 in scored rows.
- `response_ms` is measured from the start of the last cry heard (after a replay, the replayed
  one), not counting time spent paused. It is
  at least 4000, because the grid appears only after the 4-second cry, unless the tester paused
  late in the cry and resumed straight to the grid (that row has `pauses` of at least 1).
- If the file can't be written, a red banner says so at once ("Results are NOT being saved")
  and stays up for the session; the results screen shows the error and the path it tried.

## Clips

- The clips are 13 real CC0 recordings from Freesound (5 shrieks, 4 sobs, 4 whispers), cut by
  `game/tools/cut_cries.py` from the recordings in `source_audio/cries/` (see the README there).
  `game/audio/cries/CREDITS.md` lists every clip. No AI-generated audio.
- Clips go in `game/audio/cries/<above|inside|below>/` and must be `.wav` files. Other audio
  files are skipped with a warning. Every `.wav` is imported as mono.
- Clips should be at least as long as the 4-second cry window (the cut ones are 4.3 s). A
  shorter clip loops, which changes how many times the cry starts within a trial.
- `game/tools/make_placeholder_cries.py` can still synthesize stand-ins for a checkout with no
  clips; the setup screen warns when a folder mixes placeholders and real clips.
- **After adding, removing or re-cutting clips, re-measure loudness** (see Tuning): a clip with
  no entry in the loudness table is named on the setup screen and Start stays disabled.
- Run `godot --headless --path game --import` after adding clips. A `.wav` that hasn't been
  imported yet, or that doesn't load, is named on the setup screen, and Start stays disabled
  until every clip in the folders is imported and loads. A level folder with no clips is named
  too.

## Tuning

Source positions, bus filters and reverb (room size, damping, wet, dry and predelay for each
level; `REVERB_KEYS` lists them), emitter settings, timings, trial counts and the pass
mark are constants at the top of `game/scripts/trial_plan.gd`. The bus FX live in `BUS_FX` there
and nowhere else that counts: they are applied over `default_bus_layout.tres` at startup, with
both effects forced on and each level bus forced unmuted, unbypassed, not solo, at
`LEVEL_BUS_VOLUME_DB` and sending to the Shadow bus. So values changed in the editor's Audio panel are
overwritten, and any other effect added to a level bus is listed on the setup screen and
disables Start. (A test checks that the `.tres` still matches, effects enabled included;
update both together.) The emitter has distance attenuation turned off,
so every source plays at the same loudness and only panning and the level buses tell them apart.

**Loudness matching, per trial.** Filters and reverb change how loud a cry comes out, and with
real recordings it depends on the clip and the level together: a hissy whisper through inside's
650 Hz low-pass is about 12 dB quieter than a sob, and a narrow shriek loses most of itself
there too. Left alone, "a quiet shriek" would mean inside. So every clip has a measured gain
for every level, in `game/audio/cries/loudness.json`, and the emitter plays each trial (and
each listen-screen demo) at that gain, so every cry comes out equally loud. Make the table with

```
godot --headless --path game -s res://tools/measure_loudness.gd -- --write
godot --headless --path game -s res://tools/measure_loudness.gd -- --verify
```

The first plays every clip through every level's real buses for the whole cry window and
measures the output (ITU-R BS.1770 integrated loudness: K-weighted, gated, both ears summed);
the second replays everything with the gains and fails if any cry lands more than 1 LU from
the target. Both run in real time, about 6.5 s per clip per level. **Re-run both after changing
`BUS_FX` or the clips.** The level buses' own volumes (`LEVEL_BUS_VOLUME_DB`) stay at 0 dB; the
table was measured that way.

**Rear shadow (front/back cue).** Plain stereo panning sounds the same ahead and behind. The
`Shadow` bus, which every level bus feeds, copies what the head and outer ears do: the further
behind you a cry is, the more its treble is cut (up to `REAR_SHADOW_TREBLE_DB`, -10 dB above
`REAR_SHADOW_CUTOFF_HZ`, 2 kHz) and the quieter it is (up to `REAR_SHADOW_VOLUME_DB`, -2 dB);
half of each when it's square to one side. It updates every frame, so a cry brightens as you
turn to face it. The bus must stay before the level buses in `default_bus_layout.tres` (Godot
only sends to buses on the left) and hold only its high-shelf filter; anything else is listed
on the setup screen and disables Start. Note: Godot's shelf `gain` cuts by 40·log10(gain) dB
(measured), so `shelf_gain_for_db()` does the conversion.

## Manual check (can't be done headless)

Run one practice round on headphones and check four things: the three levels sound clearly
different, the cry pans as you turn your head (a left-rail cry moves to centre when you face it),
a cry from behind (town, at the start of a trial) sounds duller and brightens as you turn to
face it, and a CSV appears in the results folder.
