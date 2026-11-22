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

**Why:** On 2026-11-22 Sonlm pushed the project to GitHub for the first time (`origin` is the private repo `sonlemin/3d`, branches `main` and `ear-test-prototype`) and asked whether BMad would still work after a fresh clone. The memory folder was the one thing that would not arrive, because it lives in the home folder, outside the repo. Offered a copy in the repo, Sonlm said "Write it here".

**How to apply:**
- When a note here is added, changed or deleted, make the same change in `.claude/memory-notes/` and commit it on the current branch (a docs-only commit does not run CI).
- On a machine where this folder is empty, restore from the repo copy before working.
- Pushing is still only on Sonlm's request ([[end-of-story-chores-automatic]]). No token is stored on the server: Sonlm gives one in the chat, and it is passed to git for that one command only.

Related: [[laptop-sync-via-git-clone]].
