# Decision log: The Mourning Watch GDD

Every decision, change and version step for `gdd.md` and `epics.md`, newest section last.
IDs: **IN** = inherited from an earlier document, **GD** = decided in this GDD session, **OP** = open.

## Versions

| Version | Date | State |
|---|---|---|
| 0.1 | 2026-11-19 | Workspace created. Skeleton `gdd.md`. Discovery in progress. |
| 0.2 | 2026-11-19 | Discovery complete (GD-1 to GD-36). Full draft of `gdd.md` and `epics.md`, with 23 tagged proposals. |
| 0.3 | 2026-11-19 | Review applied (GD-37 to GD-39): proposals accepted, tags removed, hammer-and-hook and ally-fade rules added. |
| 0.4 | 2026-11-19 | Finalize checks run (three input reconciliations, one validator: 2 critical, 14 major, 2 minor). GD-40 to GD-44 applied; `gdd.md` and `epics.md` rewritten. Not independently re-validated. |

## Inputs read (2026-11-19)

Each was read by a reader subagent; the extracts are in `source-extracts/`.

| Input | Path | Extract |
|---|---|---|
| Game brief (final), addendum, brief decision log | `_bmad-output/planning-artifacts/briefs/brief-3d_game-2026-11-12/` | `source-extracts/brief.md` |
| Brainstorming session, 342 ideas | `_bmad-output/brainstorming-session-2026-11-12.md` | `source-extracts/brainstorm.md` |
| Ear-test outcome, spec, deferred work, tuned values | `_bmad-output/implementation-artifacts/`, `game/EAR_TEST.md` | `source-extracts/ear-test.md` |

## Inherited decisions (carried into the GDD unless Sonlm changes them)

| ID | Decision | Source |
|---|---|---|
| IN-1 | Working title: The Mourning Watch. | Brief |
| IN-2 | Core fantasy: "hold a bridge against the dead with nothing but your wits, your ears and the bridge itself." | Brief |
| IN-3 | Four pillars, exact wording in the brief: Unarmed, not helpless; Hold it by ear; The bridge is everything; Every victory has a name. Each has a "rules out" line. | Brief |
| IN-4 | Loop: day (plan from above), optional descent, night (survive up close: "hear, rig, hold, salvage"), dawn (ledger, rites, save). | Brief |
| IN-5 | Camera: overhead by day, first person at night. Third person "later, or never". | Brief |
| IN-6 | Level cue: whispers below, shrieks above, sobbing inside the walls. | Brief, brainstorm #16 |
| IN-7 | Five resources, no gold: material, echoes, names, oil, food. | Brief, brainstorm Y9 |
| IN-8 | Loss: the last pier falls. Nights are not pass/fail; the ledger shows the cost. | Brief, brainstorm F5, F12 |
| IN-9 | No HUD at night: hands, names inked on the arms, the ledger. No minimap, enemy markers or wave timers at night. | Brief |
| IN-10 | Art: stylized, leaning to woodcut, full-screen ink-and-hatching shader; living warm, dead colorless, abyss true black. | Brief |
| IN-11 | Audio: the cries are the score; no composed music; nothing AI-voiced; cries from free human recordings. | Brief |
| IN-12 | Scope tiers: one-night game (public, free), then The Fog Season (first full release), then later seasons as free updates "if it lands". Cut-list rule: "anything outside the one-night game has to earn its way in." | Brief |
| IN-13 | One-night game contents: one span, three enemies (above, below, inside), two rigs, one ally, the bell, one name; stream-safe sound and clip moments; first cry within a minute. | Brief, brainstorm X2/BC7 |
| IN-14 | Fog Season contents: prologue, 5 nights and a closing night, about 2 to 3 hours, one new thing each night, about five spans, four enemy types, 1 to 2 allies, a handful of names. | Brief |
| IN-15 | Constraints: Sonlm solo, Godot 4 only (4.7.2, Forward+), 5 to 10 hours a week, $0 budget, all assets CC0 or CC-BY, AI use disclosed. | Brief, addendum |
| IN-16 | Platforms: Windows first, Linux alongside, itch.io "$0 or donate". No Steam or Mac for now. | Brief |
| IN-17 | Accessibility: a visual cue for every sound; stream-safe mode. | Brief |
| IN-18 | Gate 1 (ear test) closed 2026-11-19 on Sonlm's own sessions; the five outside players were skipped. Both-right 62.5% on each device against an 80% mark; direction 95.8% headphones, 87.5% speakers; level 8 of 9 when the kind of cry matched its level. | Ear-test outcome |
| IN-19 | Audio rules the ear test settled: one kind of cry per level, never crossed; the rear shadow (a cry behind is duller and slightly quieter); every cry equally loud; each level's room sound is atmosphere, not a cue. | Ear-test outcome |
| IN-20 | The one-night game's first playtests re-check with newcomers that threats can be placed by ear, on headphones and on speakers. Fallbacks: "best with headphones" plus visual cues; Plan B, the lantern scouts. | Ear-test outcome, brief |

## Open items

Session set-up:

| ID | Question | State |
|---|---|---|
| OP-1 | How much of the game this GDD specifies in full. | Closed by GD-1 |
| OP-2 | Game type for the genre section. | Closed by GD-2 |
| OP-3 | Working mode. | Closed by GD-3 |
| OP-4 | Anything changed since the brief and the ear test. | Closed by GD-4 |

Core gameplay:

| ID | Question |
|---|---|
| OP-5 | The player is called both "engineer" and "warden". Pick one name for the GDD. Closed by GD-6. |
| OP-6 | Pillar 3 rules out "any location that isn't part of the bridge", yet the descent goes below. State how they fit. Closed by GD-10. |
| OP-7 | Does the one-night game include a prep phase from above, or only the night? Closed by GD-11. |
| OP-8 | Night length inside the 20 to 30 minute cycle; fail and retry rules for the one night. Fail and retry closed by GD-12; night length still open. Night length closed by GD-23. |
| OP-9 | Falling: a kill or a delay? Brainstorm U7 (falling isn't dying) conflicts with #12, #14, #17 (feed the abyss). Closed by GD-13. |

Mechanics and the one-night roster:

| ID | Question |
|---|---|
| OP-10 | Which three enemies (one above, one below, one inside), with speeds, counts and tells. Types closed by GD-15 to GD-17; speeds and counts still open. Speeds and counts closed by GD-23. |
| OP-11 | Which two rigs, with build cost, trigger, effect and reset. Types closed by GD-18; costs still open. Costs closed by GD-19. |
| OP-12 | Which ally and what one job. Closed by GD-7c. |
| OP-13 | Where the one name comes from if the one-night game has no descent; what calling it does. Closed by GD-14. |
| OP-14 | Span and pier values: load, what stripping costs, when a span breaks. Closed by GD-19, GD-20. |
| OP-15 | Which of the five resources exist in the one-night game. Closed by GD-21. |
| OP-16 | Controls and input devices: first-person night controls and overhead controls. Closed by GD-22; the full key map is proposed in the draft. |
| OP-17 | Sound under game conditions the ear test did not cover: how many cries at once, moving sources, ambience under cries, a walking player. Closed by GD-37 (P1 to P3); whether it works is GDD assumptions 1 and 2, tested in epics 2 and 6. |

Fog Season outline and tiers:

| ID | Question |
|---|---|
| OP-18 | The four Fog Season enemy types, and what the deck enemy sounds like (no cry is assigned to it). Closed by GD-33. |
| OP-19 | The "one new thing" for each of the 5 nights; how the arc ends without the full truth. Night order closed by GD-34; how the arc ends in detail goes to narrative design. |
| OP-20 | A tier (one night, first release, update, never) for the untiered ideas: modes D2, D4, F3, F4, Daily Tide, Quiet Shift, Blind Watch; JB3; batch-2 ideas ST10 to ST20. Closed by GD-35. |
| OP-21 | Who the holdout is (last warden, one of the dead, or the builder). Likely a narrative-design question. Deferred to narrative design (gds-create-narrative); not needed for the one-night game. |

Gates, metrics, technical:

| ID | Question |
|---|---|
| OP-22 | Gate 2 pass mark: a measurable form of "if that night is fun, the game works", plus the newcomer re-check's size and threshold. Closed by GD-29, GD-30. |
| OP-23 | Look test (BC6) pass criteria and where it sits. Placement closed by GD-32; pass criteria proposed in the draft. |
| OP-24 | Target hardware for "low-end PCs" and the frame-rate target. Closed by GD-31. |
| OP-25 | HRTF plugin trial (DW-1): which tier. Closed by GD-35: only if the ear re-check fails. |
| OP-26 | Plan B (the lantern scouts) has no design. Design it now or only if the newcomer re-check fails. Closed by GD-35: designed only if the ear re-check fails. |

## Flags

- `needs_narrative`: **set** (2026-11-19). The horror guide marks narrative design as recommended, and pillar 4 is narrative. Offered at finalize; Sonlm chose architecture first and narrative design later, before the Fog Season is planned (GD-45).

## Session decisions

| ID | Date | Decision | Closes |
|---|---|---|---|
| GD-1 | 2026-11-19 | GDD depth: the one-night game is specified in full, with exact numbers. The Fog Season gets an outline (roster, night-by-night plan, arc). Later seasons are out of scope. | OP-1 |
| GD-2 | 2026-11-19 | Game type: tower defense, with horror sections. The six tower defense sections lead; four horror sections are added (atmosphere and tension, fear mechanics, scarcity, safe zones). The horror guide's enemy section folds into wave design; its puzzle section is not applicable. | OP-2 |
| GD-3 | 2026-11-19 | Working mode: section by section (facilitative), with options and proposed numbers in choice windows. | OP-3 |
| GD-4 | 2026-11-19 | What the ear test changed for Sonlm, all three: (a) level is the weak cue (direction was easy; below kept sounding like inside); (b) it takes practice, so a new player needs a listening lesson inside the game; (c) ears alone aren't enough, so the night should show more by default. Each becomes a mechanic, see GD-7 onward. | OP-4 |
| GD-5 | 2026-11-19 | Pillar 2, "Hold it by ear", stays as written, with its rule (no minimaps, enemy markers or wave timers at night). GD-4 lands in mechanics, not in the pillar: the pillar already allows visual cues that point to a sound. | |
| GD-6 | 2026-11-19 | The player character is "the warden" throughout. Engineer is the warden's trade, mentioned in the concept only. | OP-5 |
| GD-7a | 2026-11-19 | Level cue 1, each level has its own place on the span: the dead from below climb over the two rails, the dead inside break out of the two piers, the dead above drop onto the open deck. Where a cry comes from also tells which level. | |
| GD-7b | 2026-11-19 | Level cue 2, the bridge shows where: dust falls from a pier's stones (inside), a rail's ropes shake (below), the fog overhead swirls (above). No markers. Brainstorm G11. | |
| GD-7c | 2026-11-19 | Level cue 3, the ally calls the level: the one ally in the one-night game is the survivor who understands the voices (brainstorm #33). About 2 seconds after a cry starts they call "Below!", "Above!" or "In the walls!". | OP-12 |
| GD-8 | 2026-11-19 | Listening lesson: the night opens with about 2 minutes at dusk. Three harmless dead come one at a time, one per level; the warden turns to face each cry and the ally says whether that was right. First cry inside the first minute. Skippable on replay. Brainstorm JB4, RB5. | |
| GD-9 | 2026-11-19 | Visual cues are on for everyone, on headphones and speakers, but only where the warden's lantern or a placed lantern reaches. The dark is sound only. An accessibility setting shows cues everywhere. This replaces the brief's "on by default for speaker players only". | |
| GD-10 | 2026-11-19 | Pillar 3 and the descent: the depths are the bridge. The descent goes down inside the bridge's own piers and foundations (the Long Stair, the hollow causeway), built from the same pieces. Pillar 3's rule becomes: no shops, no gold, and no location that isn't the bridge or what it stands on. | OP-6 |
| GD-11 | 2026-11-19 | Planning phase: after the dusk lesson the one-night game has a plan-from-above phase with no dead. The warden strips sections of the span for material and places rigs and lanterns, then rings the bell to start the night. | OP-7 |
| GD-12 | 2026-11-19 | Losing the one night: every one of the dead is trying to cross the span to the town. The night is lost when the last section of deck at the town pier falls, or when the last of the town's lit windows goes dark. Each of the dead that crosses puts one window out; the windows behind the warden are the visible score. A lost night replays from dusk with a hint added to the journal. Brainstorm F5, F11, O11. | OP-8 (part) |
| GD-13 | 2026-11-19 | Falling: one of the dead knocked off the bridge is gone until dawn. The ledger lists it as "fell, will return", not as released. In the full game the fallen come back on later nights and remember the rig that dropped them. Settles brainstorm U7 against #12, #14, #17. | OP-9 |
| GD-14 | 2026-11-19 | The one name is carved under the planks: stripping one section of the span uncovers it in the timber beneath. Calling it takes one pull of the bell rope when the warden hears its owner coming, and that one passes in peace. | OP-13 |
| GD-15 | 2026-11-19 | From below: Grapplers (brainstorm B2). They throw a hook over a rail, haul themselves up in about 6 seconds, then walk for the town. A set hook drags on that section. | OP-10 (part) |
| GD-16 | 2026-11-19 | From above: Divers (brainstorm A2). They circle shrieking for about 8 seconds, then drop onto a section, aiming for the brightest lantern. The landing hits hard and breaks a stripped section. Then they walk for the town. A lantern can bait them onto a rig. | OP-10 (part) |
| GD-17 | 2026-11-19 | From inside: Hollow Nesters (brainstorm I1). A nest in a pier sobs louder for about 40 seconds, then hatches 4 small, fast dead at once. A wedge hammered into the cracked stone keeps it shut; or it hatches onto a waiting rig. | OP-10 (part) |
| GD-18 | 2026-11-19 | The two rigs: trapdoor (knock out the pin and a section's planks drop with everything on them; hauled back up in about 6 seconds) and swing-beam (cut its rope and a hung timber sweeps one section, knocking off whatever is at the rail or on the deck; re-hung in about 10 seconds). | OP-11 (part) |
| GD-19 | 2026-11-19 | The span, starting values to tune in playtests. 6 sections, each 5 m long and 5 m wide (30 m); no. 1 at the far pier, no. 6 at the town pier. Each section has 8 planks and 2 rail ropes (left, right): 48 planks and 12 ropes on the span, and the stockpile starts empty. Strength = planks left on the section (0 to 8). Load: Grappler 1, set hook 1, Diver 1, Diver landing 5 at impact, hatchling 0.5. Load above strength for 2 s: the section groans, then falls for good with all on it. Warden walks 3.5 m/s (end to end in about 9 s). Strip 1 plank per 2 s, 1 rope per 3 s; re-lay 1 plank per 3 s. Trapdoor: 2 ropes, needs 4 or more planks on its section. Swing-beam: 4 planks + 2 ropes, hangs from a rail. Wedge a nest: 1 plank, 3 s of hammering. | OP-11, OP-14 |
| GD-20 | 2026-11-19 | No rail, no hook: Grapplers can only hook a rail that still stands. Stripping a rail for its rope means nothing comes up there, so the plan chooses where they land. Fewer rails means they bunch up and overload those sections. If no rail is left anywhere, they hook the deck and tear a plank off each time. | OP-14 |
| GD-21 | 2026-11-19 | Resources in the one-night game: planks, rope, oil, and the one name. Material is split into planks and rope, counted on the span itself. Echoes and food wait for the Fog Season. | OP-15 |
| GD-22 | 2026-11-19 | Input for the one-night game: keyboard and mouse only. Context hands: left mouse is the hammer hand, right mouse is the lantern and rope hand; the game picks the action from what the warden is looking at, and the hands show it before the click. Gamepad arrives with the Fog Season. | OP-16 |
| OP-27 (new) | 2026-11-19 | Raised by GD-7c and GD-8: the ally calls the level and gives lesson feedback in words, but the brief allows only a few spoken lines and nothing AI-voiced. How the ally speaks is being asked. | Closed by GD-26. |
| GD-23 | 2026-11-19 | The night, starting values to tune in playtests: 12 minutes, 6 waves, each about 75 s of arrivals then a 45 s lull. Grapplers / Divers / nests per wave: W1 3/0/0 (Grapplers one at a time); W2 4/0/0 (both rails at once); W3 3/1/0 (first Diver); W4 2/2/1 (first nest, far pier); W5 5/2/1 (a nest at the town pier); W6 6/3/2 (everything, and the name's owner). Totals: 23 Grapplers, 8 Divers, 4 nests (16 hatchlings). The town has 5 lit windows. Speeds: Grappler walks 1.2 m/s, Diver 1.0, hatchling 3.0. Aim: a first-time player reaches dawn with about 3 of 6 sections and 2 of 5 windows left. A whole sitting is about 20 minutes (lesson 2, planning about 4, night 12, dawn 2). | OP-8, OP-10 |
| GD-24 | 2026-11-19 | The clock: the town's bell, behind the warden, tolls at the start of each wave, once for the first and up to six before dawn. It always sounds from the town side, so it also tells the warden which way is home. The sky pales during the last wave. | |
| GD-25 | 2026-11-19 | The name's owner keeps coming back (brainstorm ST4, The Regular): one of the dead returns every wave from wave 2 and is the only one a fall does not stop (the named exception to GD-13). The warden learns to recognise its voice. A faint hum marks the section where its name is carved. Calling the name: it passes in peace, never returns, and that wave loses its way for 20 seconds. | |
| GD-26 | 2026-11-19 | The ally's voice: about 10 short lines recorded by a person (Sonlm, someone Sonlm knows, or a free-licence voice recording), with matching text on screen. Never AI-voiced. A dependency: the recordings must exist before the dusk lesson can be playtested. | OP-27 |
| GD-27 | 2026-11-19 | Caught: the dead want the town, not the warden. One that reaches the warden shoves past: the warden is knocked down for 1.5 seconds and the ear on that side rings and goes dull for 20 seconds. No health bar, and the warden cannot die in the one night. Brainstorm F6. | |
| GD-28 | 2026-11-19 | Light and oil, starting values ("two of three lit"). 3 lanterns: one carried, two placed in planning; a placed lantern can be moved at night. Light radius: carried 6 m, placed 8 m. A full tank burns 6 minutes; the night is 12. 1 spare flask; a refill takes 4 s and fills a tank. 24 lantern-minutes in total against the 36 that would keep all three lit. Shutter: a closed lantern gives no light and no cues, burns nothing, and Divers cannot see it. Divers dive at the brightest open lantern in reach. An empty lantern stays dark until refilled. | |
| GD-29 | 2026-11-19 | Gate 2 pass mark: five people who have never seen the game play the one-night game. All three checks must pass: (1) 4 of 5 choose to play again or ask what comes next; (2) 3 of 5 reach dawn within two tries, having lost at least 2 sections or 2 windows; (3) 3 of 5 can name something they did that felt clever. | OP-22 |
| GD-30 | 2026-11-19 | Ear re-check, logged during play: a playtest build records, for every cry, whether the player turned toward it and went to the right kind of place (rail, pier, open deck), split into cries in the dark (sound only) and cries in lantern light. Pass: five newcomers, at least two on each of headphones and speakers, are right on 80% for direction and 70% for level from wave 3 on. | OP-22 |
| GD-31 | 2026-11-19 | Performance target for the one-night game: 60 FPS at 1080p on a GTX 1050-class card with the low fog setting, and at least 30 FPS at 720p on integrated graphics (Intel Iris Xe) with the fog-sprite fallback. Measured across the whole 12-minute night, including wave 6. | OP-24 |
| GD-32 | 2026-11-19 | Look test order: gray boxes first. Gate 2 is played privately in gray boxes with the real sound. The look test follows on the same span, and the public itch.io release is the proven night plus the look. | OP-23 |
| GD-33 | 2026-11-19 | Fog Season's fourth enemy: the Procession (brainstorm C1), heard through the planks (ST2). Coffin-bearers walk the deck from the far side and do not cry; each span rings at its own pitch under their feet, so the warden hears how far they have come. A coffin broken on the deck lets something worse climb out, so they must be dropped, not struck. | OP-18 |
| GD-34 | 2026-11-19 | Fog Season outline, to be detailed after gate 2. Prologue: your own funeral, one span; the old warden teaches listening, the lantern, the trapdoor and the bell, then hands over the lantern. Night 1: Grapplers; stripping and the swing-beam. Night 2: Divers; lanterns as bait; a second span. Night 3: the first trip below, down the Long Stair, for oil and the first name; the one who keeps coming back can now be named. Night 4: Hollow Nesters; a third span; a dropped span means falling back to the next pier. Night 5: the Procession on the deck; two more spans; the first ally comes up from below. Closing night: nothing new, all four at once across five spans, then the Silence. About 2 to 3 hours. | OP-19 |
| GD-35 | 2026-11-19 | Tiers for the undecided ideas. One-night game: Blind Watch as a setting (all visual cues off); ST10 calling a name makes the wave lose its way; ST19 a one-line epitaph with the name at dawn. Fog Season: D2 Classic Watch (safe days are the Fog Season's own rhythm, not a separate mode); G12 assists; ST11 the ledger is the save file; ST13 lean over the edge; ST17, ST18 letters and the notice board; gamepad. Later update: D4 No Rest, F3 Tenures, F4 Ironman, Daily Tide, Quiet Shift, ST12, ST14, ST15, ST16, ST20, JB3 (never marketed). Only if the ear re-check fails: the HRTF plugin trial (DW-1) and Plan B, the lantern scouts. | OP-20, OP-25, OP-26 |
| GD-36 | 2026-11-19 | Eight epics for the one-night game, each ending in something playable: 1 the span; 2 the ear; 3 the dead; 4 rigs and hands; 5 the night; 6 gate 2; 7 the look; 8 going public. The Fog Season is planned only after gate 2. | |
| GD-37 | 2026-11-19 | Sonlm accepted all 23 facilitator proposals (P1 to P23, listed below; first written as A1 to A23 and renamed so they do not collide with the brainstorm's enemy IDs A1 to A4). They are now part of the design and the tags are out of the GDD. | OP-17 |
| GD-38 | 2026-11-19 | Hammer and hook: a hammer blow on a set hook makes the Grappler lose its grip and start its 6 s haul again. The hook stays set. Nothing is removed by hand, so pillar 1 holds. | |
| GD-39 | 2026-11-19 | The ally's calls fade to a safety net: in waves 1 to 3 the ally calls every cry 2 s in; from wave 4 the ally calls only when the warden has not turned to within 45 degrees of a cry 4 s after it starts. | |

## Accepted proposals (GD-37)

| ID | Proposal, accepted 2026-11-19 |
|---|---|
| P1 | Warning lengths (6 s, 8 s, 40 s); on the deck each of the dead repeats its cry every 8 s and adds footsteps. |
| P2 | Never more than 4 cries at once; warnings start at least 1.5 s apart; beyond the limit, the dead on the deck drop to footsteps. Untested: the ear test played one cry at a time. |
| P3 | Ambience sits at least 12 dB under the cries. |
| P4 | The key map in Controls and Input. |
| P5 | A warden on a falling section catches the edge and climbs back in 5 s, with a wound. A hit from the warden's own swing-beam, or a Diver landing on the warden's section, also wounds. |
| P6 | Two hatchlings that cross count as one window. |
| P7 | Rig details beyond GD-18 and GD-19: where each is sprung from, the 0.3 s drop, the 1.5 s sweep, one rig per section, and dismantling losing one rope. |
| P8 | Gap rules: Grapplers cross a fallen section in 8 s, a stranded Diver dives again, stranded hatchlings are gone, the warden cannot cross. An open trapdoor is edged round in 3 to 6 s. |
| P9 | The name's section is random among sections 2 to 5; the hum is heard within 3 m; the name is uncovered at 4 planks or fewer; one of 6 names per run. |
| P10 | The one who keeps coming back behaves as a Grappler, hums, arrives once per wave from wave 2, and can be called whenever it is on or under the span. |
| P11 | A lost night replays from the planning phase with one new journal hint, and the lesson can be skipped. |
| P12 | The lines of the dawn ledger. |
| P13 | No scripted jump scares; 10 s of silence before wave 6. |
| P14 | The town pier landing is safe; no warning starts during a lull. |
| P15 | The look test's three pass criteria. |
| P16 | The ear re-check's fallbacks are judged on cries in the dark, with the thresholds given. |
| P17 | What stream-safe sound does. Clip moments are not yet specified. |
| P18 | Start-up, replay, reaction, download-size and stability targets. |
| P19 | The ally stands at the town pier, cannot be hurt in the one-night game, and drops a call that would be more than 4 s late. |
| P20 | Planning is untimed, fully undoable, and shows strength directly. |
| P21 | The carried lantern counts as a Diver's target. |
| P22 | A Grappler never chooses the same rail twice running. |
| P23 | The epic sizes in hours. |
| GD-40 | 2026-11-19 | How far: farther is quieter. Cries are equally loud at equal distance (so loudness still cannot give away level); each section (5 m) of distance takes off 2 dB, up to 10 dB. The ear re-check gains a "right section" score. Replaces "loudness never tells distance", which was an ear-test setting, not a finding. | |
| GD-41 | 2026-11-19 | Every spring spends a part: a trapdoor drop loses 1 plank from its section; a swing-beam's holding rope is cut to spring it, so each re-hang costs 1 rope. | |
| GD-42 | 2026-11-19 | A wrong ring hurries the dead: if the bell calls no one, every one of the dead on the span walks half again as fast for 10 seconds (brainstorm U4). | |
| GD-43 | 2026-11-19 | Early listen, a check and not a gate: at the end of epic 2, two or three newcomers (at least one on headphones, one on speakers) try the dusk lesson and the listening yard. If direction is under 80%, rethink before building the dead and the rigs. | |
| GD-44 | 2026-11-19 | Finalize fixes applied to `gdd.md` and `epics.md`: all 38 items under "Fixes applied at finalize" below. Three of them correct values Sonlm had approved, where the facilitator's arithmetic was wrong: lantern reach (GD-28) is now 4 m carried and 5 m placed; the town has 12 windows with an aim of about 3 left (GD-23, GD-12); the ear re-check scores waves 4 to 6 (GD-30). Sonlm was told before the change. | |
| GD-45 | 2026-11-19 | Next steps chosen by Sonlm: a second validator reads draft 0.4 now; architecture (`gds-game-architecture`) comes before narrative design, which runs later, before the Fog Season is planned; the GDD workspace is committed on the branch `ear-test-prototype`. | |

## Finalize status (2026-11-19)

Done: step 1 (decision audit, nothing dropped); step 2 (three input reconciliations); step 3 (validator: 2 critical, 14 major, 2 minor); the four ambiguous findings asked and answered (GD-40 to GD-43).

The fixes below were applied in draft 0.4 (GD-44). They have not been read by a second validator.

## Fixes applied at finalize

Decisions written in: GD-40, GD-41, GD-42, GD-43.

Corrections to values Sonlm approved, where the facilitator's arithmetic was wrong (told to Sonlm 2026-11-19):

1. Lantern reach 6 m / 8 m lit the whole span. Change to carried 4 m, placed 5 m (GD-28).
2. 5 windows against 44 possible crossings needed 93% stopped. Change to 12 windows, aim about 3 left (GD-23, GD-12).
3. Ear re-check "from wave 3 on" no longer isolates the ear after GD-39. Score waves 4 to 6 (GD-30).

Critical and major rule fixes (validator):

4. No rig on section 6. Log where the warden stands, to detect camping at the town end.
5. Open section (trapdoor down, or 0 planks): cannot be stood on; crossing along the side beams takes Grappler and Diver 12 s, hatchling 6 s, warden 4 s. Fallen section: Grappler 12 s; stranded Diver dives again on the town side; stranded hatchlings gone until dawn; the warden crosses hand over hand in 8 s (no stranding). Drop the "hold and sweep" combination.
6. Collapse: the groan fills the 2 s, then the fall; a creak sounds when load equals strength (CJ3). A Diver's landing adds 5 to the standing load for 0.5 s and breaks the section at once if the total is above strength. Planks are a count, not positions. A falling section takes its rig and any lantern hung on it.
7. Stripping: parts are carried with no limit, and the forearm shows tallies. A rail with a set hook, or one holding a swing-beam, cannot be stripped. A rail holds at most 2 hooks. With one rail left, "never the same rail twice" lapses.
8. Rigs: a trapdoor under 4 planks cannot be sprung until re-laid. Night building has a time and an input (trapdoor 8 s on key 1, swing-beam 12 s on key 2); dismantling is R held 4 s. F also shutters a placed lantern within 2 m.
9. Hook strike (GD-38): a blow takes 0.5 s; each Grappler can be shaken loose once.
10. Divers: the target locks when the warning ends. A placed open lantern outranks the carried one; of two placed, the one nearer the town. No open lantern on the span: the weakest standing section (cite brainstorm A2, with A4 and U5 for light). A target that is open: the nearest standing section toward the town. Divers never land on the town pier landing. Placed lanterns hang from a corner post and survive a drop and a sweep.
11. Nests: the 40 s countdown is heard as sobs quickening (seven sobs, gaps closing from about 4 s to none), never as loudness. A town-pier brood can only be answered by the wedge.
12. The name: the planning view never shows what is under the planks; the name is read on foot at night by lantern light. The hum is 12 dB under a cry, heard within 3 m, and is a named exception: a fourth kind of voice on the "below" level, to be covered by the ear re-check. Whether it falls or crosses, the owner is back next wave. Fix "all six waves" to "from wave 2".
13. Warning clips: Grappler one whisper then 1.7 s of straining rope; Diver two shrieks; on-deck cries are dropped first at the 4-cry limit. A falling cry that fades over 2 s (Sonlm's idea #14) is the payoff for a sprung rig and sits outside the limit.
14. Wave timetable, warnings in seconds after each toll (R = the one who keeps coming back, N = nest): W1 G 5, 30, 55. W2 R 5; G 20, 22, 50, 52. W3 R 5; G 15; D 30; G 45, 60. W4 N-far 0; R 8; D 16; G 30; D 44; G 58. W5 N-town 0; R 6; G 12, 14; D 24; G 36; D 48; G 58, 60. W6 N-far 0; R 4; G 8, 10; D 18; N-town 20; G 28, 30; D 40; G 52, 54; D 64. Dawn comes on the clock at 12:00; the dead still on the span sink back and do not count. Peak scene is up to 18 dead, not 12.
15. Wounds: that ear is 12 dB quieter and dulled above 1 kHz for 20 s; the view darkens on that side.
16. Every sound gets a visual cue (brief): lantern flames lean toward the nearest cry (G11) and toward the hum; a groaning section's planks bow; each bell toll adds a chalk tally at the town pier; the ally's calls are text. State that in the dark the safety net is the ally's call and the "cues everywhere" setting.
17. Ledger: add "names learned"; drop the count of the fallen (pillar 4). Dawn opens with an earned silence (M8).
18. Pillars: note under pillar 3 that the town's lights are a second way to lose in the one night (GD-12); note under pillar 1 that in the one night nothing dies, rigs only make the dead fall, and only the name releases.
19. Ear re-check definitions: "direction right" = turned to within 45 degrees within 4 s of the cry's start; "place right" = within 6 m of the arrival point when the warning ends (this covers level and section); log the ally's calls, dark or lit, and the section. A cry the player chose to leave counts as a miss.
20. Gate 2 fail path: fix and re-run with people who have not played; the look does not start until all three checks pass.
21. Journal hints: six, keyed to the main cause of the loss.
22. Start flow: a left/right check with the town bell before the lesson (JB4), to catch swapped or mono output.
23. Performance statistic: average 60 FPS with 1% lows of 45 (GTX 1050); average 30 with 1% lows of 24 (Iris Xe).

Wording and source fixes (reconcilers):

24. "Head-tracking audio plugin" is wrong everywhere: write "HRTF plugin (3D audio for headphones)". DW-1 is headphones only and must be checked against Godot 4.7.2 first.
25. Gate 1 paragraph: the 8 of 9 is pooled from mixed sessions and one kind per level was never run as its own session; the 80% mark was missed; the three speaker misses were rail cries from below heard as town; distance was not covered. Assumption 1: "showed direction only", not "proved".
26. Loudness within 1 LU is measured straight ahead, before the rear shadow. Room-sound table: "mostly what is above 1000 Hz", and likewise.
27. Licences: "must allow commercial use (such as CC0 or CC-BY)". Add: "AI only drafts text and helps with art and sound effects, and Sonlm edits everything."
28. Audience: only free-game hunters "decide in the first minute"; streamers "want tense moments and choices that chat will argue about".
29. Add the inspiration and steer-clear line; name the Gorge Causeway; add "pride, then peace" beside the vision and as the ledger's intent; add "each night is a puzzle with scarce parts, and surviving feels earned, never lucky" and reword "the game has no puzzles"; the game never states its message; warmth between the waves (two of the ally's ten lines are warm, not calls).
30. Fog Season outline: add "lay the fallen to rest, then save", names fade if unused, a lost ally is gone for good, an ally takes the lantern if the warden falls. Add a note that nights 1 and 5 hold more than one new thing, against "one new thing each night" (O6).
31. Citations: the dust, rope and fog cues extend G11 and are new; the silence line is the brainstorm's; ST19 is the player writing the epitaph (Fog Season), while the one night uses the brief's pre-written epitaphs; the cues-off setting is "Ears only", and Blind Watch (O12, near-black screen) stays a later update; label ST15 (Who Rang the Bell?) and ST16 (voiced letters).
32. Frontmatter: `game_type: tower-defense`, secondary `horror`.
33. Rename proposal IDs A1 to A23 in this log to P1 to P23 (they collide with brainstorm enemy IDs A1 to A4).

`epics.md`:

34. Epic 2: re-cut the cries from the original downloads here, not in epic 8; add the early listen (GD-43); raise its size to 50 to 70 h (total about 290 to 460 h).
35. Add stories: on-deck cries and the falling cry (epic 3); night building and dismantling inputs (epic 4); all remaining sounds sourced, including the hum (epic 5); the left/right check (epic 5); the gate 2 re-run rule (epic 6).
36. Name the reusable prototype pieces by what they do: cry rules and rear shadow, loudness tool, cry cutting tool and credits, session log, local checks.
37. The ear test ran 12 to 19 November 2026 against a guess of about 2 months; hours were not recorded, so sizes stay guesses and hours are logged from epic 1.
38. Epic 8: add a devlog post and the itch.io follow button; tips are saved toward Steam's $100 fee.

Not adopted, kept as tuning levers: plank loss on stripping at night (Y5) if planks "follow the fight"; hammering a pier swelling its sobbing (Y8).
