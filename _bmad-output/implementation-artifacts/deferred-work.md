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
owner: the first story whose rule rolls `sim.rng` (was story 1.3, which closed the input half)
severity: medium
reason: `checksum()` hashes the tick, the generator's state and the part counts, and no rule reads `rng`, `move_wish`, `yaw`, `pitch` or `commands` yet. "Same seed and inputs, same checksum" therefore passes with any inputs, and "a different seed gives a different rng state" only shows that seeding differs. Once the warden walks, add a check that different inputs give a different checksum and that a roll changes the events.
status: open (narrowed)
resolution: story 1.3, 2026-11-21, in part. The warden walks and `checksum()` hashes its position; `test_night_sim.gd` checks that the same seed with different move wishes gives different checksums and the same wishes the same one. The code review of story 1.3 added `yaw` and `pitch` to the hash, with a test, so the input half is whole. Still open: "a roll changes the events" (no rule rolls `sim.rng` yet); owner: the first story whose rule rolls.

### DW-27: A view test changes part counts outside the tick

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor, Blind Hunter)
location: game/tests/watch/test_span_view.gd, the reconcile checks (lines 85 to 94)
owner: story 1.4, which adds the strip command
severity: low
reason: The test calls `SpanRules.move_parts()` directly and then checks that the view follows on the next tick. The testing rule is a `StartState`, then only commands and ticks. No command can change a count until story 1.4; replace the direct call with a strip command then.
status: done 2026-11-21
resolution: story 1.4. `_test_reconcile_follows_state` starts from a `StartState` (section 1 at 5, the warden on it) and drives the counts with strip, rail-strip and re-lay commands and ticks; the view checks are the same. The old last check, "the rail is back", is dropped: no rule puts a rope back on a rail yet (re-hanging is epic 4), and keeping it would need the direct ledger call this item removes.

### DW-28: The trace line has no side, and its "who" is only the event id

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor, Blind Hunter)
location: game/watch/debug/trace.gd, `line()`; game/tests/watch/test_trace.gd
owner: the first story that emits an event with a side or an actor (story 1.4 at the latest)
severity: low
reason: The story's Dev Notes give "where" as `s3 L` and "who" as `grappler#3` or `warden`. The trace prints `s3` and the event's `id`, which is right for `NIGHT_STARTED`, the only kind that exists. An event with a section and no id prints the section in the "who" column, and a kind name over 17 characters breaks the columns. The test pins today's format and has to change with it.
status: done 2026-11-21
resolution: story 1.4. `NightTrace.line()` names `warden` as who for the hands' six kinds, followed by the action (`strip_plank`); where is `s3`, plus ` L` or ` R` for a rail action; a refusal ends with its reason. Every kind name fits the 17-wide column (a test checks the longest). `NIGHT_STARTED`'s line is unchanged.

### DW-29: `EYE_HEIGHT` is in `SpanGeometry`, and AD-67 puts it in `WardenConstants`

origin: gds-code-review of story 1.2, 2026-11-20 (Acceptance Auditor)
location: game/watch/sim/span_geometry.gd, line 45
owner: story 1.3, which adds the warden
severity: low
reason: The code follows the story's decision D2; the architecture (AD-67) says `WardenConstants.EYE_HEIGHT` gives the eye for `LookRules` and the camera. Move the constant when `WardenConstants` is created, and point the night camera at it.
status: done 2026-11-21
resolution: story 1.3. `EYE_HEIGHT` moved to `WardenConstants`; the warden's camera uses it; its check is in `test_warden.gd`.

### DW-30: `Main`'s launch branches have no test

origin: gds-code-review of story 1.2, 2026-11-20 (Blind Hunter)
location: game/watch/main.gd, `_ready()`
owner: the next story that changes `Main` (story 1.3 makes the night a first-person screen)
severity: medium
reason: The "--show wins over --start", unknown-show and no-debug branches each raise a warning, and a smoke run fails on any warning, so CI runs only the clean paths. Inverting "--show wins", or opening the night on an unknown show, would pass every check. Move the choice of screen into a function a test can call, or add smoke runs that expect one named warning.
status: done 2026-11-21
resolution: story 1.3. The choice of screen is `Main.choose()`; `tests/watch/test_main_flow.gd` covers the conflict, unknown-show, no-debug and list branches.

### DW-31: Far sections cannot be read from the landing

origin: M1 of story 1.2, re-judged 2026-11-21 (Sonlm chose to move it)
location: game/watch/sim/span_geometry.gd (D2's gray-box sizes); game/watch/night/span_view.gd
owner: story 1.3, its walk check (where D2's sizes are tuned by eye)
severity: medium
reason: From the landing (eye 1.6 m, looking along a 30 m span), sections 20 to 25 m away are seen nearly edge-on: at 4, 1 and 0 planks they are a stack of thin lines that cannot be told apart at a glance. The piers are now 2 m deep, so every gap reads black, but that does not fix the angle. In story 1.3, check whether walking up to a section is enough to read it. If not, levers are plank and gap sizes, more contrast between planks and the void, or a cue other than the gaps. Also check that a 2 m pier still looks like a pier in the fog.
status: done 2026-11-21 (decided by Sonlm)
resolution: Sonlm looked at `--show=walk_close` on the laptop's real GPU: missing planks read on the sections near the warden and not on the far ones. Sonlm accepted that as it is: planks are read within roughly 10 m, the warden walks closer to check, and nothing is changed to make far sections readable (fog in epic 7 hides them anyway; DW-32 carries the fog check). Any later story that needs the span's state from further away must give its own cue, not lean on the planks. History: reopened the same day by the code review of story 1.3, with this note: The code review could not confirm the reading below from the one llvmpipe frame: sections 5, 4 and 3 are clear, but past about 10 m section 2 (1 plank) and section 1 (8 planks) could not be told apart with confidence. Sonlm judges `--show=walk_close` in M1; if it does not read, the levers are the ones in "reason". The fog check moved to DW-32. What story 1.3 did: (M2, `--show=walk_close`, Xvfb on llvmpipe, not a real GPU). From mid-span, sections 4 and 3 read, but section 2 (1 plank, 12.5 to 17.5 m ahead) did not: any gap more than about 10 m ahead looks down onto the far pier's face, which was gray. Sonlm chose variant B from rendered options: both piers dark (`SpanView.PIER_COLOR` 0.12); D2's sizes unchanged. Re-rendered: 5, 4 and 1 read apart. Not checked: how a 2 m pier looks in fog (no fog until epic 7).

### DW-32: How the dark 2 m piers look in fog is not checked

origin: gds-code-review of story 1.3, 2026-11-21 (Acceptance Auditor); carried over from DW-31
location: game/watch/night/span_view.gd (`PIER_COLOR` 0.12, piers 2 m deep)
owner: epic 7, the story that adds the fog
severity: low
reason: DW-31 asked "check that a 2 m pier still looks like a pier in the fog" and was closed without it, as there is no fog yet. Story 1.3 then darkened both piers from 0.5 to 0.12 gray so far gaps read black. When fog exists, check from the landing and from mid-span that the piers still read as piers and that far gaps still read as gaps.
status: open

### DW-33: A click that refocuses the window reaches the hands

origin: gds-code-review of story 1.3, 2026-11-21 (Edge Case Hunter)
location: game/watch/night/warden.gd, `_unhandled_input`
owner: epic 5, the focus-loss pause
severity: low
reason: After alt-tab the mouse mode is still captured, so the click that gives the window its focus back is not the "take the mouse back" click and passes through unhandled. Harmless in story 1.3 (nothing reads `watch_hammer`); from story 1.4 it is a hammer press the player did not mean. The focus-loss pause of epic 5 is where it is settled.
status: open
note (story 1.4, 2026-11-21): from this story such a click is a real `HAMMER` press: at a deck within 2 m it starts a strip (cancelled when the button comes up, 2 s before it could complete), and anywhere else it is a `REFUSED` (`NO_ACTION_HERE`). No part moves unless the button stays down for 2 s.

### DW-34: A hold made impossible by the span changing under it has no test through the tick

origin: dev-story of story 1.4, 2026-11-21 (Known gap, story 1.4 T1.2 AC 5)
location: game/watch/sim/hold_rules.gd, `tick()` (the `HandRules.check()` cancel branch); game/tests/watch/test_hands.gd
owner: story 1.5, the first rule that can change the span under a running hold (a section falling)
severity: medium
reason: `HoldRules.tick()` cancels a hold whose action `HandRules.check()` no longer allows on its own target (AD-67). Nothing in story 1.4 can change the span under a hold (one action at a time; nothing else moves parts), so that branch is reached only by its pure `check()` test, and deleting it fails no test. Story 1.5 adds a strip hold on a section that falls and checks the `HOLD_CANCELLED` on the tick after it falls (corrected at closing: the fall is step 7 of tick F and `HoldRules` is step 2, so the cancel is on F + 1, as the architecture says). (The unreached side branch of `NightSim.refuse()`, first noted here, is DW-37: it has another owner.)
status: done 2026-11-22
resolution: Story 1.5. A strip, a rail-strip and a re-lay hold on a section that falls on tick F are cancelled on F + 1 with no part moved, also a strip that would have completed on F + 1 (test_hands.gd, `_test_dw34_*`; the overload bot path reaches it too). With the `check()` cancel removed from `HoldRules.tick()`, those tests fail.

### DW-35: D3 can hand the warden on to a neighbouring section that was already bare

origin: dev-story of story 1.4, 2026-11-21
location: game/watch/sim/warden_rules.gd, `walk()` and `held_by_bare()`
owner: story 1.6, which replaces D3 with edging toward the town (GD-68)
severity: low
reason: D3 (Sonlm, 2026-11-21) lets every bare section under the feet or a clearance probe count as floor while the warden cannot stand. If the section next to the one that just went bare was already bare, a warden held near their shared edge may step onto that older bare section too. The rule does what D3 says; whether it should is left to story 1.6, which replaces D3. The bot paths never reach the case (no two neighbouring sections are bare in them), and test_bot_nights.gd's own arithmetic would flag it.
note (story 1.5, 2026-11-22): `held_by_bare()` now skips fallen sections (a fallen section has 0 planks too but is no floor), so D3 can never hand the warden on to a gap; a test in test_warden.gd checks it. The case above, an older bare section that has not fallen, is unchanged.
status: done 2026-11-22
resolution: story 1.6 removed D3 (`held_by_bare()` and its use in `walk()`), so the case can no longer happen. A warden whose last plank goes is on its side beam at once and edges toward the town (GD-68, `ConsequenceRules.warden_on_beams`); a warden beside a section that goes open steps back to 0.3 m from it (story 1.6 D3, `WardenRules.step_back()`); a run of open and fallen sections is crossed one section at a time.

## Deferred from: code review of 1-4-the-warden-strips-re-lays-carries-and-reads-the-forearm.md (2026-11-21)

### DW-36: A release that never arrives leaves a hold or the forearm with no button behind it

origin: gds-code-review of story 1.4, 2026-11-21 (Edge Case Hunter, Blind Hunter)
location: game/watch/night/night.gd, `_unhandled_input`; game/watch/night/warden.gd, `_unhandled_input` (`_swallow_release`)
owner: epic 5, the focus-loss pause (with DW-33)
severity: low
reason: The hands get press and release only as events. If a release is never delivered (the window loses focus while a button is held), a Hold-mode hold runs on and completes with nothing held, and a raised forearm stays up and blocks both hands until Tab is pressed and released. The same lost release leaves the warden's `_swallow_release` set after a "take the mouse back" click, so the next hammer release is swallowed and that strip completes after the player let go. Also: with the mouse freed by Esc (story 1.3 D2) only the left click is kept from the hands; right mouse, E and Tab still act. Whether the engine sends a release on focus loss was not checked. Movement is polled each tick, so it corrects itself; the hands do not. Epic 5's pause on focus loss should release every night button (or cancel the hold and lower the forearm) and clear `_swallow_release`.
status: open

### DW-37: The side branch of `NightSim.refuse()` is reached by nothing

origin: dev-story of story 1.4 (noted on DW-34); split off by gds-code-review of story 1.4, 2026-11-21 (Acceptance Auditor, Blind Hunter)
location: game/watch/sim/night_sim.gd, `refuse()` (a refused rail action names its side)
owner: epic 3, the first refusal of a rail action (a locked rail)
severity: low
reason: A rail is only a look target while it stands, so no rail action is refused at the press yet, and the branch that puts the side on a `REFUSED` event has no test: deleting it fails nothing. `refuse()` also fills section, id and side from the action, while its comment and `NightEvent` describe them by reason (`NO_ACTION_HERE` leaves them empty); the two agree for every refusal that can happen today. The story that adds a refusable rail action checks the side on its `REFUSED` event and settles which of the two decides the fields.
status: open

### DW-38: The view test no longer checks a rail coming back

origin: gds-code-review of story 1.4, 2026-11-21 (all three reviewers); the check was dropped when DW-27 closed
location: game/tests/watch/test_span_view.gd, `_test_reconcile_follows_state`; game/watch/night/section_view.gd (the branch that re-adds a rail)
owner: epic 4, the story that lets a rope be hung again
severity: low
reason: DW-27 made the view test move parts only through commands and ticks. No rule puts a rope back yet, so the check "the rail is back" was dropped, and `SectionView`'s re-add of a rail after it was taken off is run by no test. When a rule can re-hang a rope, add the check back, driven by that rule's command.
status: open

### DW-39: Changing Holds on the pause screen cancels a hold the pause had frozen

origin: gds-code-review of story 1.4, 2026-11-21 (found when the mode-change rule was checked against the planning documents)
location: game/watch/sim/hold_rules.gd, `_set_option()`; game-architecture.md, "Pause (AD-67)"; EXPERIENCE.md, Input Schemes ("Pause freezes a hold and does not cancel it")
owner: epic 5, the pause overlay (the Holds row itself is epic 8)
severity: low
reason: Since the code review of story 1.4 (Sonlm, 2026-11-21), a change of the Holds option cancels the running hold and lowers the forearm, so a mode always starts from idle hands. The architecture applies a Holds change made on the pause screen as `set_option()` on the first tick after resume, and EXPERIENCE.md says a pause freezes a hold and does not cancel it. The two meet in one case only: a player pauses during a hold, changes Holds, and resumes; that hold is then cancelled (no part moves, nothing is lost). No planning document states the old reading ("a mode change leaves the running hold as it is"); it was the story's own. When the pause overlay is built, confirm with Sonlm that this cancel is wanted, and say so in EXPERIENCE.md or the architecture.
status: open

## Deferred from: Sonlm's play of story 1.4 (2026-11-21)

### DW-40: The strip and re-lay holds felt too slow in play

origin: Sonlm's M1 and M2 of story 1.4, 2026-11-21 ("shouldnt it be faster or even instant")
location: game/watch/sim/span_constants.gd (`STRIP_PLANK_S` 2 s, `STRIP_RAIL_S` 3 s, `RELAY_PLANK_S` 3 s); gdd.md, the costs table of Game Mechanics (GD-19)
owner: epic 5, the first played night with waves (and epic 4 story 1 for how a hold feels once the hands show it)
severity: medium
reason: Played with nothing attacking and nothing showing a hold, the three holds felt like waiting. Sonlm chose to keep the numbers for now (2026-11-21): they are GD-19's starting values, and the time is the cost that makes stripping a choice while the dead arrive. Judge them again once a hold has its own animation and sound and the night has threats. If they still feel slow, shorten them in the GDD and in `SpanConstants` together; the bot and the tests read the lengths from `sim.ticks`, so nothing else changes. Instant actions were offered and not chosen.
status: open

### DW-41: The temporary aim aid must go when the hands arrive

origin: Sonlm's M1 and M2 of story 1.4, 2026-11-21 ("i have to aim because i can't know if i am targetting it or not"); Sonlm chose a temporary aid the same day
location: game/watch/debug/aim_aid.gd; game/watch/debug/debug_tools.gd, `make_aim_aid()`; game/watch/main.gd, `_show_night()`; game/tests/watch/test_aim_aid.gd; game/WATCH.md
owner: epic 4 story 1 (the hands: ready pose, hold feedback, cancel, can't), and in any case before the first gate 2 build
severity: medium
reason: Until the hands show what a click will do (UX-5), a debug aid draws a centre dot over the night view: dim with nothing in reach, the word `deck` or `rail` for what is in reach, bright when a button would start a hold, and a ring for a hold's progress. It is on in every run that has the debug tools (the editor and playtest builds), so a playtest build would show it. EXPERIENCE.md allows nothing over the night view but the caption and the optional plain centre dot, and no bars or rings: the aid breaks that on purpose and must not reach a player. Remove the files and the call in `_show_night()` when epic 4 story 1 lands. The settings' plain centre dot (UX-5, epic 8) is a separate thing and is not built by this.
status: open

## Deferred from: dev-story of 1-5-sections-carry-weight-creak-groan-and-fall.md (2026-11-22)

### DW-42: Test weights are a count in SpanState; the architecture sketches them as the dead

origin: dev-story of story 1.5, 2026-11-22 (Dev Notes, decisions settled without a question)
location: game/watch/sim/span_state.gd (`_weights`, `_lifts`), start_state.gd (`weights`, `lifts`), span_rules.gd (`load_on()`, `take_lifts()`), consequence_rules.gd (`weights_fall()`); game-architecture.md, the test example (`start.weights[3] = 4`) and "a weight is a kind of `DeadState`"
owner: epic 3, when `DeadState` is whole (epic 2 brings the warnings' part, epic 3 the rest)
severity: low
reason: Story 1.5 stores test weights as a count per section, as the architecture's test example writes them, because `DeadState` does not exist yet. The architecture's other sketch makes a weight a kind of `DeadState`. When the dead arrive, decide whether test weights become dead of a "weight" kind (then `load_on()` sums one list, and `weights_fall()` folds into the dead's footing step) or stay a separate count for tests and show-me setups. Story 1.5's decision D1 lifts (`StartState.lifts`, `WEIGHT_LIFTED`) stand in for one of the dead walking off a section: fold them into the dead walking off then, and check that the bot path's `GROAN_STOPPED` coverage still has a path.
status: open

### DW-43: A plankless section with a weight on it falls by the general rule until story 1.6

origin: dev-story of story 1.5, 2026-11-22
location: game/watch/sim/span_rules.gd, `strength()` and `tick_loads()`; game/watch/sim/warden_rules.gd, `step_back()`
owner: story 1.6 (open sections and gaps)
severity: low
reason: In story 1.5 a section's strength is its planks only, so a section with no planks and a load of 1 groans and falls after 2 s (a test checks it). GDD Game Mechanics 2 gives an open section's side beams a load of 2: story 1.6 replaces this by adding the beams to `strength()` for an open section, and that test changes with it. Story 1.5's decision D2 (a warden beside a fallen section within 0.3 m steps straight back to 0.3 m from the gap, in the same tick) is the precedent for a warden beside a section that goes open, if 1.6 needs one; 1.6's edging replaces story 1.4's D3, which `step_back()` deliberately leaves alone (it moves the feet only when a probe is over a fallen section).
note (code review of story 1.5, 2026-11-22): in `game/tests/watch/test_bot_nights.gd`, `_each_tick` drops a held bare section once it has fallen. No bot path yet bares a section that later falls, so removing that clause changes no run: it is a guard, not a proven check. When story 1.6's paths bare sections that can then fall, undo it once to see a run fail.
status: done 2026-11-22
resolution: story 1.6. `SpanRules.strength()` is `SpanConstants.SIDE_BEAM_LOAD` (2) for an open section (decision D4); test_span.gd's L4 (1 weight: nothing; 2: a creak; 3: a groan and a fall on tick 120) replaces the old "bare section with a weight falls" test, and L5 pins that taking the last plank can stop a groan. The step back now covers open sections too (D3). The note's `_held` clause is gone with `_held` itself: test_bot_nights.gd no longer keeps D3's held sections, and its own arithmetic instead records each edging and crossing from its `_STARTED` event (the beams path bares a section that then falls under an edging warden, AC 10).

### DW-44: The creak's bow has not been judged on its own

origin: Sonlm's M1 and M2 of story 1.5, 2026-11-22
location: game/watch/night/section_view.gd (`CREAK_BOW` 0.05 m, `GROAN_BOW` 0.25 m)
owner: epic 2 (the creak gets its sound)
severity: low
reason: Story 1.5's decision D4 bows a creaking deck 5 cm at mid-section (`CREAK_BOW` in `game/watch/night/section_view.gd`) until the creak has a sound. On a virtual display the creak moved the planks 5 to 7 pixels. In play on 2026-11-22 Sonlm reported "i can see it sag a bit" and "You can feel the fall is coming", without saying after which strip, so whether the creak alone can be seen is not known. When epic 2 gives the creak its sound, judge whether the bow is still needed and at what depth.
status: open

## Deferred from: Sonlm's play of story 1.6 (2026-11-22)

### DW-45: A newcomer may not understand sliding backward when the last plank goes

origin: Sonlm's M2 of story 1.6, 2026-11-22
location: game/watch/sim/consequence_rules.gd (`warden_on_beams`), game/watch/night/warden.gd (no view turn)
owner: epic 2 (sound), epic 4 story 1 (the hands), the dusk lesson (epic 5); judged at gate 2 with newcomers
severity: low
reason: GD-68 puts a warden whose last plank goes on its side beam at once, edging toward the town. Facing the far pier (the usual stance for stripping), that edging goes backward to the view. Sonlm: "It work. I slide backward. First time player might not understand." Sonlm chose (2026-11-22) to keep it as built, with no view turn (the view is the player's; the fall's catch stays the only turn), and to let the sound, the hands and the lesson explain it. Check at gate 2 whether newcomers read it.
status: open

### DW-46: A section with few planks looks like walking on air

origin: Sonlm's M2 of story 1.6, 2026-11-22
location: game/watch/night/section_view.gd (only the planks left are drawn); GDD Game Mechanics 2 (only a section with no planks cannot be stood on)
owner: epic 7 (the look); checked at gate 2
severity: low
reason: By the GDD a section can be stood on over its whole length while it has any plank, but the gray box draws only the planks left (one plank sits mid-section), so walking over a 1-plank section looks like walking on air. Sonlm: "i am at 1 plank and can still walk through still look rather strange like i am walking on air." Sonlm chose (2026-11-22) to keep the rule and leave it to the look (epic 7) to show what holds the warden up on a sparse section; no gray-box change now. If gate 2 newcomers are confused by it, put a gray-box frame (joists between the side beams) back to Sonlm as an option.
status: open

### DW-47: Write the rope left across a gap into the GDD

origin: Sonlm's replay of M1 of story 1.6, 2026-11-22
location: GDD Game Mechanics 2 ("A fallen section is a 5 m gap ... The warden crosses hand over hand in 8 s"); game/watch/sim/span_geometry.gd (`gap_rope_points()`, `GAP_ROPE_*`), game/watch/sim/warden_constants.gd (`CROSS_HANG_DROP`)
owner: the next gds-gdd update run
severity: low
reason: The GDD says the warden crosses a gap hand over hand but not what along: everything on a fallen section falls. In play the crossing felt like "walking midair". Sonlm chose (2026-11-22) that one rope stays strung across a fallen section, on its centre line, and the warden hangs under it (feet 2.4 m down) and pulls along it. It is gray box and view only (no rule but the warden's crossing line reads it; the dead do not use it), but the GDD should say it, and say whether it is a rail rope or the bridge's own line, before epic 3 (Grapplers' hooks) and epic 7 (the look).
status: open

### DW-48: Idea: the warden strings a rope across a gap

origin: Sonlm, after the second replay of M1 of story 1.6, 2026-11-22
location: GDD Game Mechanics 2 (a fallen section) and Economy and Resources (rope); GD-19, GD-20
owner: a gds-gdd run after gate 2
severity: low
reason: Sonlm asked whether the warden should be able to attach a rope across a gap. It would be a new action spending rope, the scarcest resource ("Rope runs out first", GDD worked night), and a strung rope could become something Grapplers hook (GD-20). Since one rope already stays across every gap for free (DW-47), an attached rope must give something to be worth its cost (a faster crossing than 8 s, for example); the other way, removing the free rope so stringing one is the only way across, brings back the stranding the GDD ruled out. Sonlm chose (2026-11-22) to log it and decide after gate 2 shows whether rope and crossing time matter in play. Nothing is built for it.
status: open

## Deferred from: code review of 1-6-open-sections-and-gaps.md (2026-11-22)

### DW-49: An open section is stronger than one with a single plank, both ways

origin: story 1.6 decision D4 (Sonlm, 2026-11-22) and its code review, 2026-11-22
location: game/watch/sim/span_rules.gd (`strength()`), game/watch/sim/span_constants.gd (`SIDE_BEAM_LOAD`); GDD Game Mechanics 2, GD-19
owner: gate 2, with the dead on the beams (epic 3); a GDD change if it is judged wrong
severity: low
reason: By the GDD as written a section's strength is its planks, and an open section's side beams carry 2. So a section at 1 plank is weaker than one with none. D4 kept that and said it would be judged at gate 2; no item tracked it. Sonlm was shown one side when choosing: taking the last plank of a section groaning under 2 stops the groan (test L5). The code review measured the other side: re-laying one plank on an open section that carries 2 makes it groan and fall 2 s later with the plank, and a second re-lay (3 s) cannot save it (`test_hands.gd`, `_test_a_relay_onto_a_loaded_open_section_brings_it_down`). In epic 3 that load is the dead: repairing a section they are edging round drops it. The option declined at D4 was strength never below 2 (`max(planks, 2)`, a GD-19 change). Judge both sides at gate 2.
status: open
