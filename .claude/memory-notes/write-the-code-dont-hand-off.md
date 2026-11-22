---
name: write-the-code-dont-hand-off
description: Sonlm wants Claude to write the code (including learning-mode TODO pieces) rather than leave functions for them to implement
metadata:
  node_type: memory
  type: feedback
  originSessionId: 846d93f9-78f7-44db-a844-ea10006e3c76
  modified: 2026-11-12T07:08:09.743Z
---

Write the code yourself, including the small "your turn" pieces that learning mode would normally hand to the user. Explain the design choice in an Insight instead of leaving a TODO stub.

**Why:** On 2026-11-12, during the ear-test build, Claude left `build_scored_order` as a TODO for Sonlm. Sonlm replied "write build_scored_order for me ... I just want the game for now." They care about getting a playable result, not about writing exercises.

**How to apply:** In gds-quick-dev and other build flows, implement every function. If a choice really belongs to Sonlm, ask it as an option list (see [[user-prefers-option-lists]]), not as code to write. Related: [[engine-godot-only]].
