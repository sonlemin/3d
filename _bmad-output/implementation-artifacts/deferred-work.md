# Deferred Work

Work carved out of a spec or flagged in review, kept here so it isn't lost.

### DW-1: Trial the Nexus Resonance HRTF plugin in the ear test

status: open
source: gds-quick-dev scope split, 2026-11-12 (spec-ear-test-prototype)
severity: medium

Swap the ear test's built-in spatializer for the Nexus Resonance plugin (Steam Audio for Godot, v1.0.1, MIT, supports Godot 4.6–4.8) in a headphones-only HRTF mode, then rerun the same trial set and compare scores against the built-in baseline. See the brief addendum's "Directional audio" notes: the plugin is young (one review, store in beta, platform coverage not stated), so check it against the pinned Godot 4.7.2 before adopting it. Speakers keep the built-in panning.

**Depends on:** the built-in ear test (spec-ear-test-prototype) being done and scored first.

### DW-2: Export ear-test builds for outside testers

status: done
resolved: 2026-11-12 (export_presets.cfg; Windows + Linux release builds verified)
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

### DW-4: Read GDD draft 0.6 as it stands after the third round of fixes

origin: gds-gdd update run, finalize, 2026-11-19
location: _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md
owner: gds-game-architecture, as its first step (auto-assigned 2026-11-20)
severity: medium
reason: The GD-52 to GD-55 fixes went in after the validator finished, so nobody has read the result; architecture is the next reader anyway.
status: done 2026-11-20
resolution: Read in full as step 2 of gds-game-architecture. Seven gaps found and listed in game-architecture.md (Project Context, Gaps found); five settled there, two left open for their stories (DW-17).

### DW-5: Walk the UX reviews' medium and low findings

origin: gds-ux reviewer gate, 2026-11-19
location: _bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/review-rubric.md and review-accessibility.md
owner: a gds-ux Update run before epic 2's stories are created (auto-assigned 2026-11-20)
severity: medium
reason: About 33 medium and 32 low findings were never walked one by one; only the high ones and a handful of others were handled.
status: open
seen-again: 2026-11-20 (validation-report.md now gives a status per finding: 30 not addressed, 15 partly addressed)

### DW-6: Settle the flame as a direction-finder (carry height, minimum lean)

origin: gds-ux accessibility review H3, 2026-11-19
location: EXPERIENCE.md, HUD & Diegetic UI; epics.md epic 7 story 4
owner: epic 7 story 4, checked on the muted night in epic 8 (auto-assigned 2026-11-20)
severity: medium
reason: It was left to the art pass without a story naming it; by sight the flame is the only direction-finder in Cues everywhere.
status: open

### DW-7: Add a per-wave economy line to the GDD

origin: third validation of the GDD, minor 18, 2026-11-19
location: gdd.md, Economy and Resources
owner: epic 6 story 5, the tuning pass (auto-assigned 2026-11-20)
severity: low
reason: The whole-night worked example stands in for it; per-wave numbers are better written from playtest data.
status: open

### DW-8: Decide the four accessibility gaps (rebinding, narrated menus, other languages, one-handed play)

origin: gds-ux Accessibility Floor and gdd.md Out of Scope, 2026-11-19
location: n/a
owner: Sonlm, when the Fog Season is planned after gate 2 (auto-assigned 2026-11-20)
severity: low
reason: Accepted as gaps at hobby stakes and marked "not yet planned"; gamepad arrives with the Fog Season, which is the natural time to decide rebinding.
status: open

### DW-9: Find a person to record the ally's lines

origin: gdd.md Dependencies, 2026-11-19
location: n/a
owner: Sonlm, started during epic 1; final recordings needed by epic 6 (auto-assigned 2026-11-20)
severity: high
reason: It has lead time and no date; stand-in recordings carry epics 2 to 5, but gate 2 needs the real ones.
status: open

### DW-10: Recruit newcomers for the early listen and for gate 2

origin: gdd.md Dependencies, 2026-11-19
location: n/a
owner: Sonlm; two or three people by the end of epic 2, five more by epic 6 (auto-assigned 2026-11-20)
severity: high
reason: Both checks need people who have never seen the game, split across headphones and speakers, and nobody is lined up.
status: open

### DW-11: Get the original Freesound downloads of the 11 recordings

origin: gdd.md Dependencies, 2026-11-19
location: game/audio/cries
owner: Sonlm, before epic 2 story 1 (auto-assigned 2026-11-20)
severity: high
reason: The clips in hand were cut from lossy previews; epic 2 starts by re-cutting them at full quality.
status: open

### DW-12: Secure a GTX 1050-class machine and an Intel Iris Xe machine

origin: gdd.md Dependencies, 2026-11-19
location: n/a
owner: Sonlm, before epic 7 (auto-assigned 2026-11-20)
severity: medium
reason: The frame-rate targets can only be measured on them, and nothing says where they come from.
status: open

### DW-13: Decide caption backing and a Reduce camera motion setting

origin: gds-ux accessibility review cheap wins 12 and 14, 2026-11-19
location: EXPERIENCE.md, Accessibility Floor
owner: epic 8, with the accessibility extras, decided after the muted night (auto-assigned 2026-11-20)
severity: low
reason: Two reviewer suggestions that were not taken up; each adds a setting, so they belong with the other extras after gate 2.
status: open

### DW-14: Optional closing steps of the UX and GDD runs

origin: gds-ux and gds-gdd finalize, 2026-11-19; asked for by Sonlm on 2026-11-20 and cut short by a usage limit
location: _bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/
owner: Claude, next session (auto-assigned 2026-11-20)
severity: low
reason: Still to do: an editorial pass on DESIGN.md and EXPERIENCE.md, the HTML validation report, a visual re-check of the key-screens mock including phone width, and a bmad-help run.
status: done 2026-11-20
resolution: All four run on 2026-11-20; details in the UX folder's .decision-log.md. The report lists 30 findings still not addressed, which stay under DW-5.

### DW-15: Push the planning commits

origin: session of 2026-11-19 (commits eab90cd and e709a12 on ear-test-prototype)
location: n/a
owner: Sonlm
severity: low
reason: Commits are local only; pushing was never asked for.
status: open

### DW-16: Write the architecture's rule changes back into the GDD

origin: gds-game-architecture, validation, 2026-11-20
location: _bmad-output/game-architecture.md, Architecture Validation, Handed on
owner: a gds-gdd Update run before epic 2's stories are created
severity: medium
reason: AD-6 (smooth distance loudness), AD-7 (cut and skip, three falling cries, warning spacing), AD-17 (the wounded ear is per source), AD-26 (what a replay resets; hints on leaving), AD-34 (dawn wins a tie) and AD-50/AD-67 (a hold that becomes impossible cancels on the next tick) change or add to the GDD's wording. The GDD still says "3 dB per section".
status: done 2026-11-20
resolution: GDD draft 0.7, GD-56 to GD-59 and GD-62. The hold wording was left as it is on purpose (see the GDD's decision log).

### DW-17: Two GDD gaps left open by the architecture

origin: gds-game-architecture, 2026-11-20
location: game-architecture.md, Gaps found (6 and 7)
owner: put to Sonlm as options when epic 3 story 3 and epic 5 story 5 are created
severity: low
reason: A Diver whose picked section opens or falls during its 1 s drop; whether a Grappler still hanging stands still for the 20 s after the name is called.
status: done 2026-11-20
resolution: Sonlm chose from options. GD-60: the Diver falls through. GD-61: the dead on and under the span stand still.

### DW-18: Epic 1 needs a setup story, and epic 2's "In" list needs the pieces the architecture moved into it

origin: gds-game-architecture, Built when (AD-54, AD-66), 2026-11-20
location: _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md
owner: gds-create-epics-and-stories, when epic 1's stories are written
severity: medium
reason: epics.md has only its dependency line changed. The setup story (main scene switch, test runner split, CI checks) is not in epic 1's story list or its hours, and epic 2 now also builds warning phases, a timetable with tolls and the carried lantern's light.
status: open (epic level done 2026-11-20)
resolution-so-far: epics.md draft 0.7 has the setup story, epic 2's additions and new hours (GD-63). Draft 0.8 (2026-11-20) has epic 1's seven stories in full with acceptance criteria. Still owed: the same for epics 2 to 8, each before its epic starts, and a re-guess of epics 2 to 5 for the test paths and show-me setups every story now carries, once epic 1's hours are logged.

### DW-19: Architecture's second round of validation fixes was not re-read

origin: gds-game-architecture, validation, 2026-11-20
location: _bmad-output/game-architecture.md
owner: gds-check-implementation-readiness
severity: low
reason: Two cold reads found 39 and then 37 problems; the fixes for the second set had mechanical checks only.
status: done 2026-11-20
resolution: Read in full during gds-check-implementation-readiness. No contradiction found that would make two agents write code that does not fit. Three small things noted in planning-artifacts/implementation-readiness-report-2026-11-20.md (UX Alignment Assessment, DW-19): night_ticks.gd and StartState missing from the directory tree; an event's t is undefined before the first toll and in a lesson or round; pause is described for the night and lesson only.

### DW-20: Write epic 2's stories in full, with three things the readiness check found

origin: gds-check-implementation-readiness, 2026-11-20 (findings G3, G7, B3, B4, Q4)
location: _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md, epic 2
owner: gds-create-epics-and-stories, when epic 1 is nearly done and after the UX update of DW-5
severity: medium
reason: Epic 2's stories are still one line each. When they are written they must also: say where the tune comes from, or that a stand-in is allowed until epic 5 story 9 (its 3 variations, resolving phrase and hum have no sourcing story); name the mono-and-swap measurement test, the saved settings, `build_info` and the two playtest presets the architecture builds in epic 2; and name the no-threat-before-its-warning invariant, which the architecture builds in epic 3 and no story mentions.
status: open

### DW-21: Choose how the screen effects are drawn

origin: gds-check-implementation-readiness, 2026-11-20 (finding A2)
location: _bmad-output/game-architecture.md; DESIGN.md, Elevation & Depth
owner: put to Sonlm as options before epic 5's stories are created
severity: medium
reason: The Lantern light look needs a soft glow on the chosen item, a soft halo on text over 3D, lines that write in left to right, a hold rule that fills and drains, and the paused view dimmed to 15%. The architecture names no technique for any of them, and agents cannot see the result.
status: open

### DW-22: Split and reorder epic 5; add two cue stories and a frame-time check

origin: gds-check-implementation-readiness, 2026-11-20 (findings G4, Q2, Q3, Q8)
location: epics.md, epic 5
owner: gds-create-epics-and-stories, before epic 5 starts
severity: medium
reason: Epic 5 holds the night's rules and every screen, setting, sound and text in 65 to 90 h; stories 8 and 9 are each epic-sized; the text (story 10) and the look (story 12) come after the stories that need them. No story draws bowing planks in the light or the tune's swaying ropes. Frame rate is first measured in epic 7; one wave 6 night with frame times logged in gray boxes would catch a structural cost earlier.
status: open

### DW-23: Bound epic 6's open-ended stories and give its tooling a story

origin: gds-check-implementation-readiness, 2026-11-20 (findings B6, Q6)
location: epics.md, epic 6
owner: gds-create-epics-and-stories, before epic 6 starts
severity: medium
reason: Story 5 (tuning) has no limit and story 6 (fix and re-run the gate; fallbacks) is a contingency, not a story. The architecture builds night recording, replay, the debug overlay, frame times and refusal counts in epic 6, and none has a story or hours there.
status: open

## Deferred from: code review of 1-1-the-game-starts-beside-the-ear-test.md (2026-11-20)

### DW-24: The Windows ear test build is exported but never started

origin: gds-code-review of story 1.1, 2026-11-20 (Edge Case Hunter)
location: tools/ci.sh, the `--export` start check
owner: Sonlm, the next time a Windows ear test build is handed out
severity: low
reason: `tools/ci.sh --export` starts only the Linux build to prove it opens the ear test and writes to the `Ear Test` user folder. The Windows preset is checked as text only. If its `eartest` feature or the `.eartest` overrides stopped applying, that build would open the game and write to `mourning_watch`, and nothing would say so. Needs a Windows machine or Wine.
status: open

### DW-25: Key names on other keyboard layouts are unchecked

origin: gds-code-review of story 1.1, 2026-11-20 (Edge Case Hunter, inferred)
location: game/watch/core/input_actions.gd, `key_name()`
owner: the story that first draws key names on screen
severity: low
reason: `key_name()` prints `OS.get_keycode_string()` of the layout's label for a physical key. Where that label is a symbol or `KEY_NONE` (the number row on AZERTY, some display servers), the name may be empty or a word such as "Ampersand". On Xvfb with a US layout all 27 actions gave good names. Fall back to the physical key's name when the label is `KEY_NONE` or empty, and try at least one non-US layout.
status: open

## Deferred from: code review of 1-2-the-span-exists-and-is-drawn-to-the-count.md (2026-11-20)

### DW-26: The determinism tests cannot fail on inputs or the generator

origin: gds-code-review of story 1.2, 2026-11-20 (Blind Hunter)
location: game/tests/watch/test_night_sim.gd and test_bot_nights.gd; `NightSim.checksum()`
owner: story 1.3, the first story whose rules read the move wish and the view
severity: medium
reason: `checksum()` hashes the tick, the generator's state and the part counts, and no rule reads `rng`, `move_wish`, `yaw`, `pitch` or `commands` yet. "Same seed and inputs, same checksum" therefore passes with any inputs, and "a different seed gives a different rng state" only shows that seeding differs. Once the warden walks, add a check that different inputs give a different checksum and that a roll changes the events.
status: open

### DW-27: A view test changes part counts outside the tick

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor, Blind Hunter)
location: game/tests/watch/test_span_view.gd, the reconcile checks (lines 85 to 94)
owner: story 1.4, which adds the strip command
severity: low
reason: The test calls `SpanRules.move_parts()` directly and then checks that the view follows on the next tick. The testing rule is a `StartState`, then only commands and ticks. No command can change a count until story 1.4; replace the direct call with a strip command then.
status: open

### DW-28: The trace line has no side, and its "who" is only the event id

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor, Blind Hunter)
location: game/watch/debug/trace.gd, `line()`; game/tests/watch/test_trace.gd
owner: the first story that emits an event with a side or an actor (story 1.4 at the latest)
severity: low
reason: The story's Dev Notes give "where" as `s3 L` and "who" as `grappler#3` or `warden`. The trace prints `s3` and the event's `id`, which is right for `NIGHT_STARTED`, the only kind that exists. An event with a section and no id prints the section in the "who" column, and a kind name over 17 characters breaks the columns. The test pins today's format and has to change with it.
status: open

### DW-29: `EYE_HEIGHT` is in `SpanGeometry`, and AD-67 puts it in `WardenConstants`

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor)
location: game/watch/sim/span_geometry.gd, line 45
owner: story 1.3, which adds the warden
severity: low
reason: The code follows the story's decision D2; the architecture (AD-67) says `WardenConstants.EYE_HEIGHT` gives the eye for `LookRules` and the camera. Move the constant when `WardenConstants` is created, and point the night camera at it.
status: open

### DW-30: `Main`'s launch branches have no test

origin: gds-code-review of story 1.2, 2026-11-20 (Blind Hunter)
location: game/watch/main.gd, `_ready()`
owner: the next story that changes `Main` (story 1.3 makes the night a first-person screen)
severity: medium
reason: The "--show wins over --start", unknown-show and no-debug branches each raise a warning, and a smoke run fails on any warning, so CI runs only the clean paths. Inverting "--show wins", or opening the night on an unknown show, would pass every check. Move the choice of screen into a function a test can call, or add smoke runs that expect one named warning.
status: open

### DW-31: Far sections cannot be read from the landing

origin: M1 of story 1.2, re-judged 2026-11-21 (Sonlm chose to move it)
location: game/watch/sim/span_geometry.gd (D2's gray-box sizes); game/watch/night/span_view.gd
owner: story 1.3, its walk check (where D2's sizes are tuned by eye)
severity: medium
reason: From the landing (eye 1.6 m, looking along a 30 m span), sections 20 to 25 m away are seen nearly edge-on: at 4, 1 and 0 planks they are a stack of thin lines that cannot be told apart at a glance. The piers are now 2 m deep, so every gap reads black, but that does not fix the angle. In story 1.3, check whether walking up to a section is enough to read it. If not, levers are plank and gap sizes, more contrast between planks and the void, or a cue other than the gaps. Also check that a 2 m pier still looks like a pier in the fog.
status: open
