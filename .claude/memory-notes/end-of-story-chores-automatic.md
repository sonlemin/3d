---
name: end-of-story-chores-automatic
description: "After implementing a story, run the screen-checkable manual checks on Xvfb, record agent time, and commit — without asking"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 733060f2-8d30-42c2-b0b3-8f220fad9b3d
  modified: 2026-11-21T00:00:00.000Z
---

At the end of a story, Sonlm wants three steps done automatically, not left as next steps: (1) the manual checks that can be judged from the screen, run on a virtual display (`xvfb-run` + `godot --write-movie` frames, read by the agent); (2) the agent's time written into the story's hours line; (4) a commit on the current branch (never main, never `--no-verify`, never push). Encoded for gds-dev-story in `_bmad/custom/gds-dev-story.toml` (`on_complete`).

**Why:** said 2026-11-20 after story 1.1 ("Do 1 and 2, 4 automatically next time"). Code review stays a separate step Sonlm starts.

**How to apply:** sound, panning, feel, mouse capture, frame rate and the window title still can't be judged on Xvfb (llvmpipe, no window frame). List those as NOT verified for Sonlm. Applies to other story-implementing skills too (quick-dev, bmad-build), and to code review: a screen check left "needs Sonlm" must be rendered and judged by the agent before the story is called done. On 2026-11-21, after story 1.2's review, Sonlm asked "Can't you check it yourself" when told to test M1. A story's closing steps that include a manual check are not met by CI alone, so do not set `done` until the check is judged. Related: [[write-the-code-dont-hand-off]], [[tests-must-isolate-the-real-cue]].

**Checks that need buttons held or the mouse moved** can still be rendered: write a scratch `extends SceneTree` script outside the project that calls `change_scene_to_file("res://watch/main.tscn")` and, in `_process`, feeds timed `InputEventKey` / `InputEventMouseButton` / `InputEventMouseMotion` (set `relative` and `screen_relative`) through `Input.parse_input_event`; run it with `godot --path game -s <absolute path> --write-movie ... --fixed-fps 30 -- --show=<name> --trace`. At 30 fps one frame is 2 ticks; mouse look is 0.0025 rad per pixel. The server has no xdotool. Used for story 1.4's M1/M2 and the aim aid (2026-11-21).

**After a code review's fixes the story stays `review`, not `done`** (stories 1.3, 1.4 and 1.5): the story's own closing step needs Sonlm's run of the show-me setups, so ignore gds-code-review's step 6 where it says `done`. Commit as "Story <id>: code review fixes", re-render the M checks, and write measured facts only into the record (pixel shifts measured, frames compared), saying what the renders and the bot do not prove.
