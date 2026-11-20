# Decision log: The Mourning Watch GDD

Every decision, change and version step for `gdd.md` and `epics.md`, newest section last.
IDs: **IN** = inherited from an earlier document, **GD** = decided in this GDD session, **OP** = open.

## Versions

| Version | Date | State |
|---|---|---|
| 0.1 | 2026-11-19 | Workspace created. Skeleton `gdd.md`. Discovery in progress. |
| 0.2 | 2026-11-19 | Discovery complete (GD-1 to GD-36). Full draft of `gdd.md` and `epics.md`, with 23 tagged proposals. |
| 0.3 | 2026-11-19 | Review applied (GD-37 to GD-39): proposals accepted, tags removed, hammer-and-hook and ally-fade rules added. |
| 0.4 | 2026-11-19 | Finalize checks run (three input reconciliations, one validator: 2 critical, 14 major, 2 minor). GD-40 to GD-44 applied; `gdd.md` and `epics.md` rewritten. Committed as 74deb48. |
| 0.5 | 2026-11-19 | Second validator read draft 0.4: 1 critical, 8 major, minor items; 31 of the 38 first-round fixes confirmed as logged. GD-46 and GD-47 applied. Draft 0.5 has not been read by a validator. Finalized. |
| 0.6 | 2026-11-19 | Update run: UX decisions UX-1 to UX-41 applied (GD-48 to GD-51). Third validator read it: 0 critical, 12 major, 18 minor; a fourth reader checked the UX decisions: 35 of 41 landed, 2 weakened, none contradicted. GD-52 to GD-55 applied. Nobody has read the result. Finalized. |

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
| GD-46 | 2026-11-19 | Ear re-check: a listening round carries the pass marks. Before their first night each of the five gate 2 newcomers spends 5 minutes on the span: 12 warnings from unpredictable places, 4 from each level, in the dark, with no ally. Direction (within 45 degrees in 4 s) 80%; place (within 5 m in 15 s) 70%. The night log stays as supporting data with no pass mark, because a good plan makes arrivals predictable. The same round is used in the early listen (GD-43). Refines GD-30. | |
| GD-47 | 2026-11-19 | Second-validation fixes applied, listed under "Second validation" below. Two change approved starting values: the distance step is 3 dB per section up to 15 dB, not 2 and 10, so that it does not equal the rear shadow's 2 dB (GD-40); gate 2's "barely" check reads "at least 2 sections or 5 windows", scaled from 2 of 5 to the 12 windows (GD-29). Sonlm was told. | |

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

## Second validation (2026-11-19, of draft 0.4)

Result: 1 critical, 8 major, some minor. Checked and found sound: wave totals and the 44 crossings; the timetable against the wave table; at most 4 warnings at once; time-to-town figures; lantern-minutes; epic hour totals; the ally's 10 lines; the wrong-ring and one-shake rules.

Fixes applied in draft 0.5 (GD-47):

1. Stripping everything (critical). Section 6 cannot go below 4 planks. A Grappler with no free rail hooks the deck of the section with the most planks and tears one off. Divers always have a section to land on. An open section's side beams carry a load of 2.
2. A Grappler step by step: warning (the rail locks), hanging from the hook for 6 s with a load of 1, then walking with a load of 1. The hook does not add a second load.
3. A rail locks when a warning starts under it, so it cannot be stripped to cancel an arrival.
4. A Diver picks its section when its warning starts, and the shrieks come from over it. Only sections 1 to 5 with planks can be picked. A lantern counts only when lit (shutter open, tank not empty).
5. Sums: five re-hangs in the worked night, not six, because a beam's own rail must stay. A Diver's landing counts 5 in place of its 1, which restores the approved "breaks at 4 planks or fewer".
6. A flame leans only toward cries inside its own light, so the dark stays sound only.
7. The ear re-check's pass marks move to the listening round (GD-46).
8. Section 6 takes no hooks and no Divers while any other section has planks; its two rails are spare rope.
9. Distance step 3 dB up to 15 dB; ambience at least 6 dB under the quietest a cry can be.
10. Minor: the lesson's pass rule and the left/right check's failure path; where a crossing counts and how hatchlings round; "lit" for lanterns and "open" for sections; "the tune" (the returning one's voice) and "the hum" (the same tune over the carved name); short definitions of the Carrion Choir, wave-breakers and the holdout; the beam hangs from a rail picked at building; lanterns hang on a pole over the middle of a section; a Diver's two shrieks overlap to fit 8 s; visible events as the cue for footsteps, hooks and falls.
11. `epics.md`: a story for writing the names, hints and lines (epic 5); the 20-night run (epic 8); the listening round built in epic 2 and run in epic 6; name found and called recorded at gate 2.

Corrections to the first list: in item 12 the "fourth voice" on the level below is the tune, not the hum; in item 35 the left/right check sits in epic 2 with the lesson, not in epic 5.

## Finalized (2026-11-19)

- `gdd.md` and `epics.md` are at draft 0.5.
- Polish: no document standards are configured for this skill, so none were applied.
- Narrative design: offered; Sonlm chose architecture first (GD-45).
- External handoffs: none configured.
- Still open, none blocking architecture: the seven notes under "Notes for the designer" and the four items under "Deferred" in `gdd.md`.
- Owed: no validator has read draft 0.5. The second validator expects Grappler, Diver and stripping rules to need more cases; architecture is the next place they will surface.
- Next step: `gds-game-architecture`.

## UX reconciliation (2026-11-19, toward draft 0.6)

Update run. Change signal: the UX documents at `../../ux-designs/ux-3d_game-2026-11-19/` (`EXPERIENCE.md`, `DESIGN.md`, and their `.decision-log.md`, UX-1 to UX-41), in particular the "GDD impacts" table in `EXPERIENCE.md`. No pillar and no part of the core loop is rethought, so draft 0.5 is patched. Working mode: express, because the decisions were made in the UX run.

Earlier decisions the UX run changes (surfaced to Sonlm before editing):

| Earlier | Change |
|---|---|
| GD-8, lesson about 2 min | About 3 min with a hands-on part and key prompts (UX-22). The sitting is about 21 minutes. |
| GD-39, the ally's calls fade from wave 4 | Unchanged in the default and Ears only modes. In Cues everywhere the ally calls every warning all night (UX-38). |
| GD-9, cues inside lantern light | Wherever light falls, which adds the town gate's light on section 6 (UX-29). |
| GD-35, Ears only is all visual cues off | Narrowed: captions and physical events stay (UX-3). Ears only and Cues everywhere are two values of one setting (UX-25). |
| P4, the key map | Space is a 1 s hold (UX-18); Esc puts a tool away before it pauses (UX-16); J opens the journal (UX-13); E acts on what is looked at (UX-36). |
| P11, replay from planning | Planning opens on the last plan (UX-40); a repeated cause shows its hint again (UX-41). |
| P18, replay in 3 s | Measured from the player's action on the lost-night page (UX-12). |

Found in this run, not in the UX run:

- The lesson's hands-on part needs the hammer and the lantern (epic 4), so it is built in epic 5. Epic 2 keeps the listening lesson, and the early listen tests only that.
- The ear re-check's first fallback ("cues everywhere on by default for speaker players") now also turns on a call for every warning. Kept as a note for the designer, to be decided only if that fallback is used.

| ID | Date | Decision | Closes |
|---|---|---|---|
| GD-48 | 2026-11-19 | The UX decisions UX-1 to UX-41 are adopted. The GDD keeps the rules of play and cites the UX documents for screens, the night's surfaces and input details. | |
| GD-49 | 2026-11-19 | Lanterns: one in hand. Each of the six sections has one pole. E at a pole hangs the lantern in hand, takes the one hanging there, or swaps the two. The flask stays at the town pier and refills the lantern in hand, once. (Declined: one in hand with no swap; carrying two.) | The case the flask rule exposed |
| GD-50 | 2026-11-19 | The accessibility extras (stronger Cues everywhere, Holds: Press once, Mono sound, the muted night) are built in epic 8, after gate 2. The UX decisions add about 35 to 50 hours: epic 2 to 55-75, epic 4 to 45-70, epic 5 to 65-90, epic 8 to 30-45; total about 325 to 510 hours, 10 over the brief's ceiling at the top. Gate 2 is reached after about 255 to 385 hours. (Declined: the extras in epic 5; the extras as a first update after release, 315 to 495 hours.) | |
| GD-51 | 2026-11-19 | Finalize checks for draft 0.6: a full validation and a check that every UX decision landed. | The validation owed from draft 0.5 |

Changes applied in draft 0.6 (GD-48):

`gdd.md`:

1. Frontmatter and "How to read": draft 0.6; the UX documents named as the home of screens, the night's surfaces and input details.
2. Session shape: lesson 3 min, sitting about 21 minutes; the left/right check on a dark screen with ring-again and "I can't hear it"; the hands-on part; the first-launch question and the skip rule (UX-19 to UX-22, UX-38).
3. Win/Loss: the window's sound and the flicker for a lone hatchling (UX-30, UX-37); the lost-night moment, the last plan, a repeated cause (UX-12, UX-40, UX-41); the ledger's form (UX-14).
4. Mechanics 1: cues wherever light falls; a cue lasts for its warning; captions; the table of the three cue modes (UX-1, UX-3, UX-25 to UX-29, UX-38).
5. Mechanics 2, 4, 6, 7, 8, 10: planks drawn to the count; rigs built from the town-side edge and the beam's rail chosen by look or click; one pole per section, one lantern in hand, the flask at the town pier, reading oil (GD-49, UX-7, UX-36); reading the name (UX-10); the ally in Cues everywhere and the caption (UX-38, UX-26); the planning tray, strip order, Start over, the 1 s bell hold (UX-15 to UX-18).
6. Controls and Input: E by look; 2 by look; Tab; Esc; planning rows for Start over, J and Esc; hold rules and Press once; what the player sees and hears of an action; keys by physical position (UX-2, UX-4 to UX-6, UX-9, UX-11, UX-13, UX-16, UX-24, UX-36, UX-39).
7. Genre sections: the pillar table, the bell's answer, planning's strength numbers, oil, the settings lists, darkness, saving, progression, the landing.
8. Art and Audio: the caption as the one thing over the night view, the centre dot, hands and forearm brightness, the Lantern light look for screens, the small sounds.
9. Technical: the replay target's start point, keys by position, the sound-output answer, Mono sound; assets for the new sounds, models, effects, text and the typeface.
10. Epics summary, metrics, scope, assumptions, notes, dependencies: sizes and total (GD-50); the first-cry target on a first launch; gate 2 at default settings; the playtest log; the muted night; the gaps not yet planned; assumptions 9 and 10; four notes for the designer; the typeface.

`epics.md`:

11. Sizes: epic 2 to 55-75 h, 4 to 45-70 h, 5 to 65-90 h, 8 to 30-45 h; total about 325 to 510 h.
12. Epic 1: planks drawn to the count, the forearm on Tab, the hold rules. Epic 2: the listening lesson only, the dark-screen check, captions. Epic 3: the window's sound and flicker. Epic 4: the hands' feedback, the build spot, poles and swap, the flask, reading oil, E by look. Epic 5: the planning tray, the journal and ledger pages, title, pause, key card, settings, the lesson's hands-on part, the Lantern light look. Epic 6: the log's two additions, default settings. Epic 7: forearm ink and brightness, the lantern's glass. Epic 8: the accessibility extras and the muted night.
13. Coverage table: rows for the hands, the lesson's two parts, the screens, the settings list and the extras.

Not changed: pillars, the core loop, the wave tables and timetable, the dead, costs and timings, the Fog Season outline.

## Third validation and UX check (2026-11-19, of draft 0.6)

Two independent readers (GD-51). Findings stayed in the conversation; no report file.

- **Validator** (the GDD checklist, plus rule completeness for architecture): 0 critical, 12 major, 18 minor. Sound: structure, the six tower-defense and four horror sections, no engine leakage, every recomputed sum (sitting 21 min; 24 lantern-minutes; 55 m in about 16 s; wave totals and 44 crossings; hours 325 to 510 and 255 to 385), the timetable, all timings across sections, the cue-mode table against mechanics 6 and 8 and the 17 settings.
- **UX check** (every UX decision against `gdd.md` and `epics.md`): 35 of 41 landed, 4 are look or wording only and not contradicted, 2 weakened (UX-24, UX-27), none contradicted. GD-49 and GD-50 consistent across the three documents.

Decided by Sonlm from their findings:

| ID | Date | Decision | Closes |
|---|---|---|---|
| GD-52 | 2026-11-19 | Every night is a new run. Each night start, after a loss or after "Another night", rolls the name and its section again and clears the forearm. The journal carries over; after a loss, so does the plan. "Another night" after dawn opens a fresh span. (Declined: a replay as the same night; the same section with the name read again.) | Validator major 7; what "each run" means after UX-40 |
| GD-53 | 2026-11-19 | Dawn: silence, the ally's one line, then the ledger in this order: sections standing, windows lit, planks and ropes left, wounds taken, names learned, souls released, and last "The fallen will return." Changes P12's order. (Declined: no ally line; the ally after the ledger; the old order.) | UX check T1, T3 |
| GD-54 | 2026-11-19 | Missing planks are drawn evenly spread: planks leave in a fixed order that keeps the rest evenly spaced, and a section with any plank can be walked over its whole length. Replaces the facilitator's far-pier-first order. (Declined: far-pier-first as mocked; a bare part that really is bare.) | Validator major 3 |
| GD-55 | 2026-11-19 | The fixes below, applied by the facilitator where the answer followed from an existing rule or from the reviewer's own suggestion. | |

Fixes applied (GD-55), `gdd.md`:

1. Night-start state: the bell cannot be rung until both placed lanterns are hung; the night starts on the town pier landing, third lantern in hand, all three full and lit. (A note for the designer records that planning could set each lantern lit or shuttered.)
2. Holds: also cancelled by letting go, or the moment the action becomes impossible; one action at a time; planning's two 1 s holds are holds in both Holds settings; a strike's blow lands at the end of its 0.5 s.
3. A section with any plank is walkable over its whole length; whoever stands on a section when its last plank is taken is on its side beams from there.
4. Rigs are built, hauled, re-hung and dismantled from within 2 m of the town-side edge, on the next section toward the town; a rig cannot be worked while that section is open or fallen; a blow from the rig's own section still springs it; a warden on a dropping trapdoor catches the edge and is wounded.
5. Divers: "more than one" lit lantern; a section must have planks and not be open when the warning starts; a redirected Diver lands within sections 1 to 5 when it can; section 6's exceptions restated to include the re-dive from beyond a gap.
6. The warden keeps the lantern (lit, counted as carried) and all parts through every hold, wound, climb and crossing. Hang, take and swap are one press. F acts on the hung lantern looked at, otherwise on the lantern in hand. The pole holds the lantern over the centre of the section; a lantern over an open section cannot be reached.
7. Planning: an undo that needs a spent part is refused with a reason; a restored plan can be undone in the same way.
8. A hook on the deck picks an edge at random; its warning sounds under that edge and rattles its planks, in the same cue modes as the ropes. The 2-hook cap counts a pending warning.
9. The lesson: a practice pin on the landing for the strike; the hands-on part ends when all four steps are done; the span and lanterns are put back; "listen again" after each playing not faced, and the place's cue shown after three; the first cry doubles as the look lesson. The ally's confirming word is not "right".
10. The listening round: after the lesson, no lantern, pointer cues off, each trial ends 15 s after its warning starts, about 5 minutes, instruction read from the session script.
11. Tolls and strokes: one tally per wave, one flame dip per stroke, strokes 1.5 s apart, a wave's clock from its first stroke.
12. Wounds: knocked down in place; a side for sideless causes picked at random; wounds stack per side. The wedge only while the nest sobs. The ally's "late" call defined against when it was due. The journal's cause found in a stated order.
13. The flame leans to the hum only while the hum can be heard. In Cues everywhere a flame leans to cries beyond its own light. A full crossing during a window's flicker puts it out and the flicker moves on.
14. Numbers: nest gaps close from about 3.3 s, not 4 s; nearest normal arrivals are at section 5 (about 18 s and 19 s), with section 6 as the exception case; the first-cry target restated as 15 s into the lesson plus a logged median.
15. Assets and limits: the hands' moves and the hold sounds; the tune's resolving phrase; the six names carved and written; the seam glow; the comfort limits (no flash, no shake, flicker under 3 a second, no bob or roll); the window sounds at ambience level.
16. Assumptions 9 and 11, and notes for the designer on rigs locking each other out, the unreachable lantern, lanterns starting lit, and the fallback's effect on the headphones answer.

`epics.md`: ambience corrected to the GDD's rule (missed since draft 0.5); the hold rules split across epics 1, 4 and 5; minimum brightness of hands and forearm moved to epic 4, before gate 2; the pause screen's five entries; "headphones or speakers" in the settings list; "I can't hear it" recorded in epic 2 and wired in epic 5; the playtest log's settings and first-cry time; the remaining targets and a frame-rate re-measure in epic 8; Coverage rows for the hold rules, the screens and the targets.

UX documents, kept in step: the hum's flame condition, "warning" for "cry" in the ally's rule, strokes for tolls, the ledger order, the dawn beat, the confirming word, the practice pin, the bell waiting for both lanterns, even plank spacing, four key-card groups, and one journey step that put a far-pier nest in wave 5.

Not done: a per-wave economy line (validator minor 18). Several starting values were set by the facilitator and are tuned at gate 2: strokes 1.5 s apart, the glow readable from 15 m, the 2 m build spot.

## Finalized (2026-11-19, draft 0.6)

- `gdd.md` and `epics.md` are at draft 0.6.
- Decision log audit: GD-48 to GD-55 are all captured in `gdd.md` or `epics.md`.
- Polish: no document standards are configured for this skill, so none were applied.
- Narrative design: unchanged from GD-45. Architecture first; the night's few texts are written in epic 5.
- External handoffs: none configured.
- Owed: nobody has read the draft after the third round of fixes.
- Next step: `gds-game-architecture`.

## Update 2026-11-20: the architecture's decisions written back (draft 0.7)

Change signal: `gds-game-architecture` finished on 2026-11-20 (`_bmad-output/game-architecture.md`, AD-1 to AD-68). It settled cases draft 0.6 left open, changed the wording of three rules, and left two gaps for the designer. DW-16, DW-17 and the epic-level part of DW-18 are closed by this update.

| ID | Date | Decision | From |
|---|---|---|---|
| GD-56 | 2026-11-20 | Farther is quieter smoothly: 0.6 dB per metre along the span (3 dB per section), up to 15 dB, with no jump at section edges. Only distance along the span counts. Amends GD-40. Chosen by Sonlm from options in the architecture session. (Declined: a step per whole section; true straight-line distance, which would let loudness hint at level.) | AD-6 |
| GD-57 | 2026-11-20 | The 4-cry limit in full. A warning sounds for its whole length and may fade out the farthest deck cry in 0.1 s. A deck cry with no place is skipped until its next 8 s mark, nearest first. The tune counts; the hum, falling cries, the ally and ambience do not. A warning that cannot start waits, and its threat waits with it. At most three falling cries at once. Chosen by Sonlm from options. (Declined: deck cries waiting their turn; never cutting a sounding cry.) | AD-7 |
| GD-58 | 2026-11-20 | A replay starts with the oil and the flask full, as another night does. Hints survive a return to the title and end when the game is closed. The night's random rolls are listed in full: a Grappler's rail, a deck hook's edge, the side of a sideless wound, which name, and where it lies; all follow from one number, so a night can be played back. Accepted by Sonlm as the plainest reading of GD-52 and UX-41. | AD-26, AD-3 |
| GD-59 | 2026-11-20 | If the night would be lost in the same instant dawn comes, it is dawn. Accepted by Sonlm. | AD-34 |
| GD-60 | 2026-11-20 | A Diver whose section opens or falls during its 1 s drop, after its warning has ended, falls through and is gone until dawn. Chosen by Sonlm from options. (Declined: it swerves to the next section; it pulls up and dives again 8 s later.) | Architecture gap 6 |
| GD-61 | 2026-11-20 | When the name is called, the dead on and under the span stand still for 20 s: walkers stop and hanging Grapplers stop hauling, their hooks keeping their load. Warnings already sounding finish and their threats arrive; the timetable and the clock to dawn keep running. Chosen by Sonlm from options. (Declined: walkers only; no new warnings for the 20 s.) | Architecture gap 7 |
| GD-62 | 2026-11-20 | A wound makes every sound on that side 12 dB quieter for 20 s; cries, the tune and ambience are also dulled above 1 kHz, while footsteps, hooks and creaks keep their tone. Amends GD-27. Chosen by Sonlm from options. (Declined: cries and ambience only, as the architecture first had it; everything quieter and dulled, which needs a filter on every sound.) | AD-17, which is amended to match |
| GD-63 | 2026-11-20 | Build order is epic 1, then epic 2 (was: either order), because the lesson and the listening round run on what epic 1 builds. Epic 1 gains a setup story and is re-guessed at 40 to 65 h (was 30 to 50); the 10 to 15 h is the facilitator's guess. Total about 335 to 525 h, 25 h over the brief's ceiling; gate 2 after about 265 to 400 h. The order was chosen by Sonlm; the hours were not put to Sonlm as options. | AD-54, AD-66 |

Applied to `gdd.md`: Win/Loss Conditions (dawn's tie, a replay's oil, hints); Listening (distance; the limit; falling cries); Lanterns and light (the Diver that falls through); The bell and the name; Wounds; the rig table and the abilities table; Difficulty (the list of rolls); Development Epics (order, hours); assumptions 3 and 7; two notes for the designer.

Applied to `epics.md`: order and hours; epic 1's setup story and "In" line; epic 2's distance and limit rules, the warnings it needs from the dead, a test timetable with the toll, and its dependence on epic 1; one line each in epics 3, 4 and 5 for GD-59 to GD-62.

Not written back, on purpose: that a hold which becomes impossible is cancelled a sixtieth of a second later, not "the moment". To a player the GDD's wording is still true; the tick belongs to the architecture.

Not re-guessed: the sizes of epics 2 to 5. The architecture asks every story for a scripted test path and a show-me setup. A note for the designer says so.

UX documents: read for conflicts with GD-56 to GD-62; none found, nothing changed.

### Discipline pass on draft 0.7 (2026-11-20)

A validator read the changes against `gdd.md`, `epics.md`, the architecture and `EXPERIENCE.md`: no critical, 10 major, 20 minor. Hours, totals, the "3 dB" mentions and story numbers were checked and found right. Decided by Sonlm from its findings:

| ID | Date | Decision | Closes |
|---|---|---|---|
| GD-64 | 2026-11-20 | The stillness in full. For the 20 s the dead on and under the span stop everything they were doing and fall silent: no deck cries, no footsteps. Warnings sounding finish and what they announce arrives, then stands still until the 20 s end, as does the threat of a warning that starts during them. The bridge and the rigs still act on the standing dead. (Sonlm chose silence over crying on, and stilled arrivals over arrivals that act.) Applied by the facilitator from those choices: a wrong ring during the stillness does nothing and a right ring ends a hurry; a wrong ring hurries walkers only; an owner called during its own warning has the warning stop, its rail unlock and no hook land. | Validator F9, F12 to F16 |
| GD-65 | 2026-11-20 | The tune comes before every other cry on the deck for a free place and is never the cry a warning cuts; it still cannot sound while four warnings are sounding. Chosen by Sonlm. (Declined: the tune as a fifth voice; no protection.) Applied by the facilitator: the tune's resolving phrase is outside the limit; a fall while three falling cries are fading is silent; a stranded Diver's second dive is a full 8 s warning under the limit and may sound in a lull. | Validator F17 to F20 |
| GD-66 | 2026-11-20 | A wound in detail. The side is the warden's own and turns with the head. The cut grows from nothing ahead or behind to 12 dB at the side. It applies to every sound that has a place (cries, the tune, the hum, footsteps, hooks, creaks, both bells, the windows, the wind); the ally's voice and the warden's own hands are never cut. Cries, the tune and the wind are also dulled by up to 10 dB above 1 kHz. A second wound on the same side restarts its 20 s and does not stack. Chosen by Sonlm; the 10 dB is the facilitator's starting value. (Declined: the ally cut too; a hard cut at the midline.) | Validator F22 to F24 |
| GD-67 | 2026-11-20 | What happens in dawn's instant does not count: the window stays lit, the section stands. Applied by the facilitator from GD-59. | Validator F21 |

Other fixes applied: a replay restores the span as the plan had it (F1); epic 2 proves the limit for warnings and epic 3 the cutting and skipping of deck cries (F2); the list of what changes between runs (F3); the timetable's note on waiting (F4); decisions added to each epic's Delivers line (F5); "setup and span stories" (F6); GD-60's trapdoor case in epic 4, three falling cries in epic 3, hints in epic 5 (F7); "1 s drop" (F8); the two notes for the designer (F10); when a trapdoor's section counts as open, and a Diver landing in a sweep (F11); the sentence about playing a night back moved out, as it is the architecture's (F25).

Kept in step: the architecture (AD-7, AD-17, the stillness in its state pattern, two rows of its Handed on table); `EXPERIENCE.md` (the pause question's wording; two lines on the wound).

Known consequence, not changed: a nest holds one of the four places for its whole 40 s, so in wave 6 from 20 to 40 s at most two places are left for the cries of up to 18 dead on the deck.

## Finalized (2026-11-20, draft 0.7)

- `gdd.md` and `epics.md` are at draft 0.7.
- Decision log audit: GD-56 to GD-67 are all captured in `gdd.md` or `epics.md`.
- Input reconciliation: not re-run. This update came from the architecture, not from the brief or the brainstorm, and it removed nothing of theirs.
- Polish: no document standards are configured for this skill, so none were applied.
- Narrative design: unchanged from GD-45.
- External handoffs: none configured.
- Owed: nobody has read the draft after GD-64 to GD-67. The sizes of epics 2 to 5 were not re-guessed (DW-18).
- Next step: `gds-check-implementation-readiness`.

