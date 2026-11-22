# 3d_game

## Standing notes

`.claude/memory-notes/` holds the standing notes on how Sonlm works and where this project stands. `MEMORY.md` in that folder is the index. They are a copy of Claude Code's memory folder for this project, which lives in the home folder and does not arrive with a clone.

- If your memory folder for this project has no notes, read `.claude/memory-notes/MEMORY.md` and the notes it lists before you start work, and save them into your memory folder.
- When you add, change or delete a memory note, make the same change in `.claude/memory-notes/` and commit it.

## Fresh clone

- The work is on the branch `ear-test-prototype`. `main` is only the baseline.
- Run `git config core.hooksPath .githooks` once, or the pre-commit check (`tools/ci.sh`) does not run.
- Rules for writing code are in `_bmad-output/project-context.md`.
