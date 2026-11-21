# The Mourning Watch: running, testing, launch switches

The game lives in `game/watch/` and is the project's main scene (`res://watch/main.tscn`). The
closed ear test shares the project; see `EAR_TEST.md` for it. All commands run from the repo
root with Godot 4.7.2 (`godot` on PATH, or set `GODOT`).

## Running the game

```
godot --headless --path game --import     # once after a fresh checkout, and after adding assets
godot --path game                         # the game
```

Or open `game/` in the editor and press **F5**. Today the game opens on a bare start page that
lists every setup problem found at start (a bad launch switch, an input action already defined
elsewhere), or says "No setup problems."

## The night

```
godot --path game -- --start=night --seed=1       # the one-night span
godot --path game -- --show=span_counts           # a show-me setup
godot --path game -- --show=walk                  # walk the span and back from the landing
godot --path game -- --show=walk_close            # stand mid-span, facing the far pier
godot --path game -- --show=strip                 # mid section 5, nothing in hand: strip and re-lay
godot --path game -- --show=forearm               # 12 planks and 3 ropes in hand, on the landing
godot --path game -- --show=list                  # list the show-me setups, then quit
godot --path game -- --start=night --trace        # print every event of the night
```

`--start=night` opens the one-night span as gray boxes, and you stand on the landing at the
town end, facing the far pier: six sections of 5 m, each with its eight planks, two side beams,
posts and two rail ropes, the far pier beyond and the town pier under you.

The night is first person. Walk with **W A S D** (by key position, so the same keys on AZERTY
and other layouts) at 3.5 m/s; there is no sprint and no jump. Look with the mouse, which the
night captures. You stop 0.3 m short of the rails, the far pier, the landing's edges and any
section with no planks; you cannot cross a plankless section yet (story 1.6). Until the pause
screen arrives in epic 5, **Esc** only frees the mouse (the night keeps running, and you can
still walk), and a **left click** captures it again (that click does nothing else).

The hands act on what you look at within 2 m (measured along the view from the eye), and every
action is a hold:

| Button | Looking at | Hold | Does |
|---|---|---|---|
| Left mouse | a section's deck | 2 s | strips one plank into your hands |
| Right mouse | a standing rail rope | 3 s | strips the rope |
| E | a deck with room, a plank in hand | 3 s | re-lays one plank (a bare deck takes one too) |
| Tab | | held | raises the forearm: planks and ropes in hand as tally strokes in fives |

A part moves only when the hold completes. Letting go, walking more than 0.5 m from where you
began, or the action becoming impossible cancels it; looking around does not. One action at a
time: another button pressed during a hold is ignored, and with the forearm up neither hand acts
(you can still walk and look). A press that can't be done (nothing in hand, a full deck, the town
section at its last 4 planks, a bare deck, or nothing there) is refused: nothing happens yet (the
hands' "can't" gesture is epic 4), but `--trace` prints a `REFUSED` line with the reason. There is
no carry limit. Holds have a Press once option (a press starts it, a second press stops it, Tab
toggles); its setting arrives in epic 8.

Strip the last plank of the section you stand on and you stay where you are, and can walk off it;
once off, it blocks like any bare section (story 1.6 brings edging round an open section).

Show-me setups for story 1.3: `walk` (the landing, every section walkable, with sparse sections
at 1, 4 and 5 planks on the way) and `walk_close` (the same planks, standing mid section 5). For
story 1.4: `strip` (mid section 5 of a full span, nothing in hand) and `forearm` (12 planks and 3
ropes in hand, on the landing).

## Running the ear test

The ear test is no longer the main scene:

```
godot --path game res://scenes/ear_test.tscn
```

Or open `scenes/ear_test.tscn` in the editor and press **F6**. Its two export presets (`Linux`,
`Windows`, feature `eartest`) still build the ear test, which opens the ear test and writes to
its old folder (`app_userdata/Ear Test`).

## Tests

```
godot --headless --path game -s res://tests/run_tests.gd
```

The runner finds every `tests/**/test_*.gd` and every `_test_*` function in it by itself; each
file extends `TestCase` (`tests/test_case.gd`). It prints one line per file and a total line,
and fails on any failed check or any error or warning a test did not ask for. A test must run
to its end in one go: one that uses `await`, or stops on a script error inside an expect
window, fails. A file with `_test_` functions that is not named `test_*.gd` fails the run too.
The ear test's tests are in `tests/ear_test/test_ear_test.gd` (120 passed, 23 expected).

## CI

- `tools/ci.sh`: import, the purity check on `watch/sim/` (banned names, and any base type but
  `RefCounted` or a class of that folder; with a self-check of the greps), the check for any
  kind of `print` on `watch/` outside `watch/debug/`, the tests, and 120-frame smoke runs of
  the game, the ear test, the game with each `--start` value (with `--seed=1`), the game
  with each show-me setup that `--show=list` prints, and one traced night (`--trace`), whose
  first line must name the seed. A smoke run fails on any ERROR or WARNING
  line; the import and the exports fail on any ERROR line.
- `tools/ci.sh --export`: the same, then the ear test's Windows and Linux builds into `builds/`,
  and one headless start of the Linux build to confirm it opens the ear test and writes to
  `app_userdata/Ear Test`, not to the game's folder. That start uses a scratch data folder, so
  your real user folders are not touched. Only the Linux build is started; the Windows build
  is built and not run.
- Any other argument stops `tools/ci.sh` at once with an error.
- The pre-commit hook runs `tools/ci.sh` for commits that touch `game/` or `tools/ci.sh`. Enable it once per clone:
  `git config core.hooksPath .githooks`. Never commit with `--no-verify`.

## Launch switches

Switches go after `--`, for example `godot --path game -- --seed=3`. A switch that is unknown,
given twice, has a bad value, or is typed before `--` is a setup problem: it is reported once
as a warning and listed on the start page, and the game starts anyway. Of a switch given more
than once, the first good value stands.

| Switch | What it does |
|---|---|
| `--seed=N` | The seed for the night's randomness, a whole number. Without it a night gets a fresh random seed, which `NIGHT_STARTED` carries and `--trace` prints, so the night can be run again with `--seed=N` |
| `--start=<value>` | Start on that screen instead of the title. Today the one value is `night`; `planning` (story 1.7), `lesson` and `round` (epic 2) follow |
| `--trace` | Debug. Print every night event as one line: time, kind, who, where (`  0.000 NIGHT_STARTED     one_night seed=7`, `  4.000 RAIL_STRIPPED     warden s5 L`); a refusal ends with its reason. No value |
| `--show=<name>` | Debug. Open a show-me setup: the exact situation of a manual check. `--show=list` lists them and quits (with exit code 1 when the launch had a setup problem). Wins over `--start` (a setup problem says so); an unknown name is a setup problem and the title opens |

The debug switches (`--trace`, `--show`) work when run from source and in playtest builds only;
anywhere else they are a setup problem (`launch.no_debug`).

## Where the game writes

The game's user folder is pinned to `mourning_watch` (it does not follow the working title):

- Linux: `~/.local/share/mourning_watch/`
- Windows: `%APPDATA%\mourning_watch\`

Run from source, the ear test uses this folder too. Its exported builds keep
`~/.local/share/godot/app_userdata/Ear Test/` (Windows `%APPDATA%\Godot\app_userdata\Ear Test\`).

The playtest log and night recordings arrive in epic 2; nothing writes them yet.
