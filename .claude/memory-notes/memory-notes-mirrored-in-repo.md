---
name: memory-notes-mirrored-in-repo
description: These memory notes are copied into the 3d_game repo at .claude/memory-notes/ so they survive a fresh clone; keep the copy in step when a note changes
metadata:
  node_type: memory
  type: project
  originSessionId: d0191b31-4cea-4501-b2be-125df3fcf63b
  modified: 2026-11-22T16:24:21.371Z
---

Since 2026-11-22 every note in this memory folder is also kept in the `3d_game` repo at `.claude/memory-notes/` (same file names, `MEMORY.md` as the index). The repo's root `CLAUDE.md` tells a session on a new machine to read them and save them into its own memory folder.

**Why:** On 2026-11-22 Sonlm pushed the project to GitHub for the first time (`origin` is `sonlemin/3d`; recorded then as private, but GitHub's API reported it public on 2026-11-25, branches `main` and `ear-test-prototype`) and asked whether BMad would still work after a fresh clone. The memory folder was the one thing that would not arrive, because it lives in the home folder, outside the repo. Offered a copy in the repo, Sonlm said "Write it here".

**How to apply:**
- When a note here is added, changed or deleted, make the same change in `.claude/memory-notes/` and commit it on the current branch (a docs-only commit does not run CI).
- On a machine where this folder is empty, restore from the repo copy before working.
- Pushing: until 2026-11-26 only on Sonlm's request; since then push the working branch after each commit ([[end-of-story-chores-automatic]]: "push next time since i clone it to my laptop"). Never `main`, never a force push. Since 2026-11-25 (new server 10.5.5.193, reached through the jump server 103.69.195.61) a GitHub token is stored on the server at Sonlm's request ("Save it somewhere safe"): a fine-grained token for `sonlemin/3d` only, expiring 2026-12-25, in `~/.config/git/credentials-3d` (mode 600), used through this repo's local `credential.helper`. Never copy the token into the repo, these notes or the memory folder. When it expires, git push fails: ask Sonlm for a new one and replace that file's line.
- The repo is public, so everything committed (these notes, play records, ear-test session files) can be read by anyone. Mention it before committing anything Sonlm may want private.

Related: [[laptop-sync-via-git-clone]].
