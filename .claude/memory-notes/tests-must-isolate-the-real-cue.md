---
name: tests-must-isolate-the-real-cue
description: "Playtests should measure only the skill the game needs: remove real giveaways (e.g. loudness), but check the design docs before removing a cue the design relies on (e.g. cry kind = level)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 846d93f9-78f7-44db-a844-ea10006e3c76
  modified: 2026-11-19T08:45:53.216Z
---

When a test measures a skill, Sonlm wants the answer to depend only on that skill: remove side cues that let a player get it right another way. But the skill is the one the *game* needs, so a cue the design deliberately gives the player is not a giveaway.

**Why:** On 2026-11-18, Sonlm said the ear test was "just testing kind of cry, not level", and I recommended mixing cry kinds across levels. The brief, though, makes the kind of cry the level cue (whispers below, shrieks above, sobs inside). With real voices, level from room effects alone fell to 62.5% (shrieks below 0/7), while trials where the kind matched its level were 8/9. The mixed test was harder than the game, and it cost several tuning rounds. Matching loudness on 2026-11-19 was a real fix: below had played about 10 dB louder, and volume isn't a designed cue.

**How to apply:** Before removing a cue from a test, check the brief or GDD: is it a confound (loudness, timing, position pattern) or the designed signal? Remove confounds. Keep designed signals, and say so when Sonlm asks to remove one. Measure on the real output where you can, and offer the choice as options.

Related: [[write-the-code-dont-hand-off]], [[user-prefers-option-lists]], [[ear-test-gate-closed]].
