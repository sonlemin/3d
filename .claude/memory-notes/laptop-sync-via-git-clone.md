---
name: laptop-sync-via-git-clone
description: "Sonlm clones/pulls repos to the laptop themselves and runs the game from the Godot editor; never give clone/pull or godot command-line steps"
metadata:
  node_type: memory
  type: feedback
---

Sonlm works on a remote dev server over SSH and plays and tests on their laptop. They get the code there themselves with git over SSH (never scp) and run it from the **Godot editor**, not a terminal.

**Why:** On 2026-11-12 Claude suggested scp and was told git clone is enough. On 2026-11-21, asked to guide manual checks M1/M2, Claude wrote out `git pull`, `--import` and `godot --path game -- --show=walk` commands. Sonlm replied: "I have the godot editor and can just git clone it. Stop asking me to do it that way. Remember it next time."

**How to apply:**
- Do not write clone, pull or import commands. Say only which branch and commit must be there (the ear test and the one-night game are `3d_game` on `ear-test-prototype`; `/home/sonlm/project/godot` is Mycelial).
- Give run steps as editor steps: open `game/project.godot` in the editor, press F5. For a show-me setup or other launch switch, set it in **Debug > Customize Run Instances > Main Run Args** (e.g. `-- --show=walk`); Sonlm asked for this on 2026-11-21, and unlike Project Settings it does not edit `project.godot`. Never a shell command.
- Make sure work is committed before saying it is ready. Git-ignored things such as `builds/` do not arrive by git.

Related: [[write-the-code-dont-hand-off]], [[engine-godot-only]], [[user-prefers-option-lists]].
