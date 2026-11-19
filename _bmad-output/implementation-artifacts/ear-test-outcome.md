# Ear test outcome (gate 1)

**Closed 2026-11-19 by Sonlm, on Sonlm's own results.** The brief's gate asks for five outside
players; Sonlm chose to skip them and move on to the one-night game. The caveats below say what
that leaves unproven, and the last section says how the one-night game covers it.

## Results

Sonlm's sessions with the real CC0 cries (12 combinations × 2 scored trials, kinds of cry mixed
across levels). Raw CSVs: [`ear-test-sessions/`](ear-test-sessions/).

| Output | Both right | Direction | Level |
|---|---|---|---|
| Speakers | 62.5% | 87.5% | 62.5% |
| Headphones | 62.5% | 95.8% | 62.5% |

Before that, three sessions with synthesized placeholders went 70% both → direction 95 / level
70 → level 87.

## What the numbers say

- **Direction passes** on both outputs. The rear-shadow cue (treble cut for cries behind)
  carries front/back without HRTF. The three speaker misses were all rail cries heard as town.
- **Level from the room effects alone fails with real voices.** With the kinds of cry mixed,
  shrieks played below were never placed right (0/7) and whispers played above only 1/6. Sonlm:
  the echo is faint on some sounds, and inside sounds echoey too.
- **Level the way the brief designs it works.** On the trials where the cry matched its own
  level (whisper below, shriek above, sob inside), the level was right 8 times out of 9.
- **The effects didn't get weaker; the voices changed.** Rendered through the real buses, the
  levels differ as much with the real cries as with the placeholders (above vs the rest about
  19–22 dB apart in frequency balance; below still rings at about −14 dB after a cry stops, versus
  −18 dB before). Real recordings carry their own room sound and narrow spectra, so the effects
  read as flavor, not as a cue a newcomer can rely on. With only 6 placeholder clips (18 distinct
  sounds) the earlier 87% was partly learned sounds.

## Caveats (what is not proven)

- One listener who practiced over five sessions and knows the design, not five newcomers.
- One kind of cry per level was never run as its own session; the 8/9 come from the mixed
  sessions and is a small sample.

## What the one-night game takes from this

- **One kind of cry per level**, as the brief says (whispers below, shrieks above, sobbing inside
  the walls). Never put a kind of cry on another level: that is where level by ear breaks.
- Keep the rear shadow for front/back, and per-clip loudness matching
  (`tools/measure_loudness.gd`) so volume never gives a level away.
- Room effects per level stay, as atmosphere.
- **Replacement check for the skipped testers:** the one-night game's first playtests must check
  that newcomers can tell where a threat comes from, on headphones and on speakers, before more
  content is built on it. If they can't, the brief's answers apply: "best with headphones" with
  the visual cues on for speaker players; if headphones fail too, Plan B (the lantern scouts).
- Every sound has a visual cue (brief, Sound section): that is the safety net either way.

## Reusable from the prototype (branch `ear-test-prototype`)

- The cry pipeline: `game/tools/cut_cries.py` (cut and normalize sources), `decode_audio.gd`,
  `measure_loudness.gd` (ITU-R BS.1770 loudness through the real buses), `audio/cries/CREDITS.md`.
- The Shadow bus and rear-shadow code in `scripts/ear_test.gd` and `scripts/trial_plan.gd`.
- The 13 CC0 clips and their sources in `source_audio/cries/`.
- Local CI: `tools/ci.sh` and `.githooks/pre-commit`.
