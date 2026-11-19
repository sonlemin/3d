# Extract: ear-test prototype results and tuned audio values

> Extract made on 2026-11-19 by a reader subagent for the GDD session. It is a summary of the sources below, not a source itself; check the original before quoting.
>
> Sources: `_bmad-output/implementation-artifacts/` (ear-test-outcome.md, spec-ear-test-prototype.md, deferred-work.md), `game/EAR_TEST.md`, `game/scripts/trial_plan.gd`, `game/audio/cries/`

**Source keys** (all under `/home/sonlm/project/3d_game/`): OUT = `_bmad-output/implementation-artifacts/ear-test-outcome.md`; SPEC = `_bmad-output/implementation-artifacts/spec-ear-test-prototype.md`; DW = `_bmad-output/implementation-artifacts/deferred-work.md`; PROTO = `game/EAR_TEST.md`; TP = `game/scripts/trial_plan.gd`; LJ = `game/audio/cries/loudness.json`; CRED = `game/audio/cries/CREDITS.md`; CSV = my own tally of the two raw files in `_bmad-output/implementation-artifacts/ear-test-sessions/` (the documents do not state these figures).

**Flag:** the gate was closed by Sonlm's decision, not by a pass. Both real-cry sessions scored 62.5% both-right against an 80% pass mark, and the five outside players were skipped (OUT, PROTO).

## 1. What was tested
- **Task:** stand mid-span on a bridge, facing the far bank; 1 s silence, then a 4 s cry heard once; free mouse-look, no walking; then name direction and level on a 12-button grid (SPEC, PROTO).
- **Set:** 4 directions (town, far bank, left rail, right rail) × 3 levels (above, inside, below) = 12 combinations (SPEC).
- **Session:** unscored listen screen → 12 practice trials (2 s feedback, Replay allowed) → 24 scored trials (each combination twice, no feedback, no replay) (SPEC, PROTO).
- **Pass rule:** both right on ≥ 80% of scored trials, at least 20 of 24; the gate wanted five outside players passing on headphones and on speakers (PROTO).
- **Kinds of cry were mixed across levels**, so level had to be heard from sound treatment and position alone (SPEC, 2026-11-18).
- **Devices:** headphones and speakers, one session each; models not stated. Speakers ran first (CSV file names).
- **Conditions:** one cry at a time; no ambience, music, enemies or visual cues during listening (SPEC "Never"); text hints per level on the answer grid (SPEC).

## 2. Results
Sonlm, real cries, 24 scored trials per device (OUT):

| Output | Both right | Direction | Level |
|---|---|---|---|
| Speakers | 62.5% | 87.5% | 62.5% |
| Headphones | 62.5% | 95.8% | 62.5% |

Three earlier placeholder sessions: "70% both → direction 95 / level 70 → level 87" (OUT); device not stated.

By direction and by level, right/trials (CSV):

| True | Headphones direction | Headphones level | Speakers direction | Speakers level |
|---|---|---|---|---|
| Town | 6/6 | 4/6 | 6/6 | 4/6 |
| Far bank | 5/6 | 2/6 | 6/6 | 3/6 |
| Left rail | 6/6 | 5/6 | 5/6 | 4/6 |
| Right rail | 6/6 | 4/6 | 4/6 | 4/6 |
| Above | 8/8 | 5/8 | 8/8 | 6/8 |
| Inside | 7/8 | 5/8 | 8/8 | 8/8 |
| Below | 8/8 | 5/8 | 5/8 | 1/8 |

- **Direction misses:** the three on speakers were all rail cries heard as town (OUT); all three were below-level (CSV).
- **Level failed** when the kind of cry was on another level: shrieks played below 0/7, whispers played above 1/6. Sonlm: the echo is faint on some sounds, and inside sounds echoey too (OUT).
- **Level passed** when the cry matched its own level (whisper below, shriek above, sob inside): 8 of 9 (OUT). Mismatched trials: 22/39 (CSV).
- **Kind × level, both devices** (CSV): shriek above 3/3, inside 5/6, below 0/7; sob above 7/7, inside 3/4, below 4/7; whisper above 1/6, inside 5/6, below 2/2.
- **Commonest mix-up:** below answered as inside, 5 on speakers and 3 on headphones (CSV).

## 3. Proven audio cue design
1. **One kind of cry per level, never crossed:** whispers below, shrieks above, sobbing inside the walls (OUT). [`MIX_CRY_KINDS = false`; the test ran `true`] (TP)
2. **A cry behind you is duller and slightly quieter, and brightens as you turn to face it.** Treble above 2 kHz is cut up to 10 dB and volume up to 2 dB straight behind, half of each at the side, updated every frame. Works without HRTF (OUT, PROTO). [`Shadow` bus high shelf: `REAR_SHADOW_CUTOFF_HZ` 2000, `REAR_SHADOW_TREBLE_DB` −10, `REAR_SHADOW_VOLUME_DB` −2; shelf gain = 10^(dB/40)] (TP)
3. **Loudness never gives away level or distance:** every cry plays equally loud (PROTO).
   - Raw: a gain per (clip, level) in `loudness.json`, target −20.1 LUFS, gains −13.5 to +16.1 dB (LJ); verify tolerance 1 LU; ITU-R BS.1770 through the real buses (PROTO); level bus volumes 0 dB, `ATTENUATION_DISABLED`, `attenuation_filter_db` 0 (TP).
   - Unmatched, a whisper through the inside filter was about 12 dB quieter than a sob (PROTO).
   - Re-measure whenever clips or bus effects change (SPEC).
   - SPEC's earlier per-level trims (+1.3 / +4.8 / −9.3 dB) are superseded.
4. **Each level keeps its own room sound, as atmosphere only** (OUT). Values match in TP `BUS_FX` and `game/default_bus_layout.tres`:
   - **Above**, "thin, open air": only what is over 1000 Hz, almost dry. [HighPass 1000 Hz; reverb room 0.25, damping 0.5, wet 0.06, dry 1.0, predelay 10 ms]
   - **Inside**, "muffled, boxed in": only what is under 650 Hz. [LowPass 650 Hz; room 0.08, damping 0.95, wet 0.45, dry 1.0, predelay 3 ms]
   - **Below**, "cave echo": distant, long tail. [LowPass 2500 Hz; room 1.0, damping 0.15, wet 0.7, dry 0.6, predelay 120 ms]
5. **Left/right by stereo panning that follows head turns.** [`3d_panning_strength` 1.0, clips mono] (SPEC)
6. **Tested geometry** (TP): sources 6 m out; above y +5 m; below y −6 m; inside at ear height 1.6 m in a pylon 1.85 m away (rails) or in the deck at y −0.5 m (town, far bank).

## 4. What the next stage must do (OUT)
- One kind of cry per level; keep the rear shadow and loudness matching; room effects stay as atmosphere.
- **Replacement check:** the first playtests must check that newcomers can tell where a threat comes from, on headphones and on speakers, before more content is built on it. Number of newcomers and pass threshold: not stated.
- **Fallbacks:** if speakers fail, "best with headphones" with visual cues on for speaker players; if headphones fail too, Plan B (the lantern scouts).
- Every sound has a visual cue (brief, Sound section): the safety net either way.

## 5. Deferred work (DW)
| ID | Status | Description | Affects |
|---|---|---|---|
| DW-1 | open, medium | Trial the Nexus Resonance HRTF plugin (Steam Audio for Godot, v1.0.1, MIT, Godot 4.6–4.8), headphones only, against the built-in baseline; check against pinned Godot 4.7.2 | Game design |
| DW-2 | done 2026-11-12 | Windows and Linux export presets and builds | Build/tooling |
| DW-3 | open, low | CSV session metadata (seed, start time, session order, "complete" row) and an abort-session button | Prototype only |

## 6. Audio assets
- 13 clips: 5 shrieks, 4 sobs, 4 whispers, cut from 11 CC0 1.0 Freesound recordings. Human recordings, no AI; licence checked 2026-11-19; no attribution needed (CRED).
- Format: 4.3 s, mono, 16-bit 44.1 kHz WAV, −18 dBFS RMS (CRED).
- **Gap:** cut from Freesound's lossy public previews; the released game needs the original downloads (same IDs) re-cut (CRED).
- **Gap:** only cries exist; any other sound is not stated.
- Placeholders are no longer in use (CRED).

## 7. Limits of the evidence
- One listener, Sonlm, who practiced over five sessions and knows the design; not five newcomers (OUT).
- Two real-cry sessions, 48 scored trials (CSV).
- One kind per level was never run as its own session; the 8/9 is a small sample from mixed sessions (OUT).
- "Direction passes" is OUT's reading; no direction-only pass mark is defined.
- The placeholder 87% was "partly learned sounds"; room effects read "as flavor, not as a cue a newcomer can rely on" (OUT).
- Not tested, by design: HRTF, ambience or music under the cry, several cries at once, moving sources, a walking player, distance by ear (SPEC "Never", TP). The documents don't list these as caveats.

## 8. Reusable pieces (branch `ear-test-prototype`)
Named by OUT:
- Cry pipeline: cuts and normalizes source recordings into clips (`game/tools/cut_cries.py`, `decode_audio.gd`).
- Loudness tool: measures every clip through every level's buses, then writes and verifies the gain table (`game/tools/measure_loudness.gd`).
- Rear-shadow code and Shadow bus: the per-frame front/back cue (`game/scripts/ear_test.gd`, TP).
- The 13 clips, their credits and sources (`source_audio/cries/`).
- Local CI: import, tests and smoke run before commits (`tools/ci.sh`, `.githooks/pre-commit`).

Also present in the repo:
- Level buses set from one constants table and checked at startup (TP).
- Clip library that finds clips per level and blocks start on missing ones (`game/scripts/cry_library.gd`).
- First-person look rig (`game/scripts/listener.gd`).
- CSV session log and scoring with level mix-ups, usable for the newcomer re-check (`game/scripts/results_log.gd`, TP).
- Headless test runner (`game/tests/run_tests.gd`) and Windows/Linux export presets.
