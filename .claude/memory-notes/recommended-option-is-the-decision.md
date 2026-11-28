---
name: recommended-option-is-the-decision
description: "Sonlm picks the option marked recommended almost every time, so a recommendation is in effect the decision; check its arithmetic and rule interactions before showing it"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 75de1b17-f015-4fc0-bc52-71087e992664
  modified: 2026-11-19T12:31:14.898Z
---

In the 2026-11-19 GDD session Sonlm chose the option marked "(Recommended)" in every one of about 45 choices. Whatever Claude recommends is, in practice, what gets decided.

**Why:** three number sheets Sonlm approved in that session had errors Claude had not checked. Lantern reach lit the whole span while the sheet said it could not. Five town windows faced 44 possible crossings. A playtest window stopped isolating the ear after a later choice. An independent validator caught them (2 critical and 14 major findings in the draft), and each needed a correction to an approved value.

**How to apply:**
- Before putting a sheet of numbers in a choice window, recompute it: totals, coverage, rates against durations, and how it interacts with choices already made.
- After a later choice, re-check earlier approved values it touches, and say so if one no longer holds.
- Run an adversarial validator before calling a design document ready, and run it again after large fixes.
- Tell Sonlm plainly when every choice in a session was Claude's recommendation, and when an approved value has to change because of Claude's own mistake.
- A rule about places or angles is a sheet of numbers too: compute it against the real geometry before recommending it. On 2026-11-28 the listening round's draw rule ("more than 45° off and at least 10 m away") was approved and then found empty on the 5 m wide span; a five-line script would have shown it (GD-72).

Related: [[user-prefers-option-lists]], [[tests-must-isolate-the-real-cue]], [[gdd-one-night-game]].
