---
name: fast-test-runs-and-undo-pass
description: "Full test run and tools/ci.sh take about 10 min (bot nights are 8 of them); run named test files from a scratch runner copy, and undo rules in copies of game/"
metadata:
  node_type: memory
  type: reference
  originSessionId: d0191b31-4cea-4501-b2be-125df3fcf63b
  modified: 2026-11-22T11:53:16.852Z
---

Measured 2026-11-22 during story 1.6's code review on Sonlm's server:

- `tools/ci.sh` (and so the pre-commit hook on any commit touching `game/`) takes about 10 minutes. `test_bot_nights.gd` alone is about 8 of them; all the other watch test files together run in about 15 s.
- A foreground command is cut off at 10 minutes, so run CI and commits that touch `game/` in the background, one at a time. Never start a second godot run on the real tree while one is going (a second `ci.sh` re-imports under the first).
- To run only some test files: copy `game/tests/run_tests.gd` to the scratchpad, filter its `paths` by `OS.get_cmdline_user_args()`, and run `godot --headless --path game -s <scratch copy> -- test_warden test_hands`. Nothing in the project changes.
- The "each rule undone on its own" pass ([[end-of-story-chores-automatic]]): `game/` is about 8 MB with its `.godot` folder, so copy it to the scratchpad once per undone rule, change the copy, and run the named test files there, several copies in parallel. The project tree is never touched, and 25 undone rules took about 3 minutes.
- `pgrep -f "a\|b"` matches nothing (pgrep takes `a|b`); check running engines with `pgrep -fa "ci.sh|run_tests|godot"`.

Related: [[tests-must-isolate-the-real-cue]].
