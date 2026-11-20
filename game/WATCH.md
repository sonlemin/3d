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
  the game, the ear test, and the game with each `--start` value. A smoke run fails on any
  ERROR or WARNING line; the import and the exports fail on any ERROR line.
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
| `--seed=N` | The seed for the night's randomness, a whole number. Used from the night on (story 1.2) |
| `--start=<value>` | Start on that screen instead of the title. **No value exists yet**; `night` arrives in story 1.2, then `lesson`, `planning` and `round` |

## Where the game writes

The game's user folder is pinned to `mourning_watch` (it does not follow the working title):

- Linux: `~/.local/share/mourning_watch/`
- Windows: `%APPDATA%\mourning_watch\`

Run from source, the ear test uses this folder too. Its exported builds keep
`~/.local/share/godot/app_userdata/Ear Test/` (Windows `%APPDATA%\Godot\app_userdata\Ear Test\`).

The playtest log and night recordings arrive in epic 2; nothing writes them yet.
