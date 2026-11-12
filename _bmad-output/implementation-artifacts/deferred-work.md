# Deferred Work

Work carved out of a spec or flagged in review, kept here so it isn't lost.

### DW-1: Trial the Nexus Resonance HRTF plugin in the ear test

status: open
source: gds-quick-dev scope split, 2026-11-12 (spec-ear-test-prototype)
severity: medium

Swap the ear test's built-in spatializer for the Nexus Resonance plugin (Steam Audio for Godot, v1.0.1, MIT, supports Godot 4.6–4.8) in a headphones-only HRTF mode, then rerun the same trial set and compare scores against the built-in baseline. See the brief addendum's "Directional audio" notes: the plugin is young (one review, store in beta, platform coverage not stated), so check it against the pinned Godot 4.7.2 before adopting it. Speakers keep the built-in panning.

**Depends on:** the built-in ear test (spec-ear-test-prototype) being done and scored first.

### DW-2: Export ear-test builds for outside testers

status: open
source: gds-quick-dev planning, 2026-11-12 (spec-ear-test-prototype)
severity: medium

Add Windows and Linux export presets to `game/` and produce builds that the five outside testers can run. This needs the Godot 4.7.2 export templates (about 1 GB; not installed yet) and should wait until Sonlm's real CC0/CC-BY cries replace the placeholders. Check that `ResourceLoader.list_directory()` still finds clips in the exported build, and that results land somewhere testers can find and send back.

**Depends on:** spec-ear-test-prototype done; real cry clips in `game/audio/cries/`.

### DW-3: Session metadata and an abort button for the ear test

status: open
source: gds-quick-dev step-4 review, 2026-11-12 (spec-ear-test-prototype)
severity: low

Two operator features raised by the review, beyond the approved spec:
- **Session metadata in the CSV:** the RNG seed (now printed only to stdout), the session start time, which of the tester's two sessions this is (headphones-first or speakers-first counterbalancing), and a final "complete" row, so concatenated CSVs can be checked for order effects and partial sessions.
- **Abort session:** a button on the pause panel that marks the CSV as aborted (or renames it with an `_aborted` suffix) and returns to setup, so a misconfigured session doesn't leave a partial file that looks genuine.

**Depends on:** nothing; useful before the five outside testers run.
