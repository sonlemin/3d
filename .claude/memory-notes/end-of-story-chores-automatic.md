---
name: end-of-story-chores-automatic
description: "After implementing a story, run the screen-checkable manual checks on Xvfb, record agent time, and commit — without asking"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 733060f2-8d30-42c2-b0b3-8f220fad9b3d
  modified: 2026-11-21T00:00:00.000Z
---

At the end of a story, Sonlm wants three steps done automatically, not left as next steps: (1) the manual checks that can be judged from the screen, run on a virtual display (`xvfb-run` + `godot --write-movie` frames, read by the agent); (2) the agent's time written into the story's hours line; (4) a commit on the current branch (never main, never `--no-verify`), and since 2026-11-26 a push of that branch. Encoded for gds-dev-story in `_bmad/custom/gds-dev-story.toml` (`on_complete`).

**Why:** said 2026-11-20 after story 1.1 ("Do 1 and 2, 4 automatically next time"). Code review stays a separate step Sonlm starts.

**How to apply:** sound, panning, feel, mouse capture, frame rate and the window title still can't be judged on Xvfb (llvmpipe, no window frame). List those as NOT verified for Sonlm. Applies to other story-implementing skills too (quick-dev, bmad-build), and to code review: a screen check left "needs Sonlm" must be rendered and judged by the agent before the story is called done. On 2026-11-21, after story 1.2's review, Sonlm asked "Can't you check it yourself" when told to test M1. A story's closing steps that include a manual check are not met by CI alone, so do not set `done` until the check is judged. Related: [[write-the-code-dont-hand-off]], [[tests-must-isolate-the-real-cue]].

**Checks that need buttons held or the mouse moved** can still be rendered: write a scratch `extends SceneTree` script outside the project that calls `change_scene_to_file("res://watch/main.tscn")` and, in `_process`, feeds timed `InputEventKey` / `InputEventMouseButton` / `InputEventMouseMotion` (set `relative` and `screen_relative`) through `Input.parse_input_event`; run it with `godot --path game -s <absolute path> --write-movie ... --fixed-fps 30 -- --show=<name> --trace`. At 30 fps one frame is 2 ticks; mouse look is 0.0025 rad per pixel. The server has no xdotool. Used for story 1.4's M1/M2 and the aim aid (2026-11-21).

**After a code review's fixes the story stays `review`, not `done`** (stories 1.3, 1.4 and 1.5): the story's own closing step needs Sonlm's run of the show-me setups, so ignore gds-code-review's step 6 where it says `done`. Commit as "Story <id>: code review fixes", re-render the M checks, and write measured facts only into the record (pixel shifts measured, frames compared), saying what the renders and the bot do not prove.

**A check at a window size other than 1280×720** (story 1.7, 2026-11-26): `--write-movie` always writes 1280×720 frames, and the server has no screen grabber. Copy `game/` to the scratchpad, add to the copy a scene whose script instances `res://watch/main.tscn`, waits 20 frames and `RenderingServer.frame_post_draw`, saves `get_viewport().get_texture().get_image()` to a path from an environment variable and quits; run it with `xvfb-run -a -s "-screen 0 1920x1080x24" godot --path <copy> res://<scene> --resolution 1920x1080 -- --show=<name>`. Judge text by measuring, not only by looking: the steepest step between neighbouring pixels of a glyph (PIL is installed, numpy is not) showed that 1080p text was softer than 720p text when a label sat on an odd canvas pixel, which the eye passed at first. Hand-placed labels now go through `WatchTheme.even_px()`.

**Push after committing** (Sonlm, 2026-11-26, after story 1.7 was committed and not pushed: "push next time since i clone it to my laptop"). Sonlm tests on the laptop from a clone of GitHub, so unpushed work cannot be tested. After a commit Sonlm will run or read (a story, review fixes, play results, these notes), run `git push origin <current branch>`: the branch only, never `main`, never a force push. My reading of the scope: every commit on the working branch, not only story commits; ask if a case is unclear. The repo is public, so still say so before pushing anything Sonlm may want private. Encoded as step 4 of `on_complete` in `_bmad/custom/gds-dev-story.toml`.
