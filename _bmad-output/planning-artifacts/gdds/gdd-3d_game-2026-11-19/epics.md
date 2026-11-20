---
title: The Mourning Watch - Development Epics
scope: the one-night game
created: 2026-11-19
updated: 2026-11-20
status: draft 0.7 (architecture decisions written back)
---

# The Mourning Watch - Development Epics

Eight epics for the one-night game (GD-36). Each ends in something playable. `gdd.md` holds the design; this file holds the breakdown. Screens and the night's surfaces are specified in `../../ux-designs/ux-3d_game-2026-11-19/` (UX-n IDs point to its decision log). The Fog Season is planned only after gate 2.

Sizes are rough guesses at 5 to 10 hours a week. The ear test ran from 12 to 19 November 2026 against a guess of about 2 months, but its hours were not recorded, so hours are logged from epic 1.

## Sequence

| # | Epic | Depends on | Rough size |
|---|---|---|---|
| 1 | The span | Nothing | 40 to 65 h |
| 2 | The ear | 1 (its setup and span stories; architecture AD-66) | 55 to 75 h |
| 3 | The dead | 1, 2 | 40 to 60 h |
| 4 | Rigs and hands | 1, 2, 3 | 45 to 70 h |
| 5 | The night | 1 to 4 | 65 to 90 h |
| 6 | Gate 2 | 5 | 20 to 40 h |
| 7 | The look | 6 passed | 40 to 80 h |
| 8 | Going public | 7 | 30 to 45 h |

Total: about 335 to 525 hours. The UX decisions added about 35 to 50 of them (GD-50) and the architecture's setup story about 10 to 15 (GD-63). Gate 2 is reached after about 265 to 400 hours.

How each epic is built is in `../../../game-architecture.md`; its "Built when" table says which parts of the architecture each epic brings in.

Epics 1 and 2 carry the two biggest risks (the bridge as a system; play by ear with several cries and a walking player) and come first: epic 1, then epic 2, because the lesson and the listening round run on the simulation that epic 1 builds (architecture AD-66). Epic 2 ends with the early listen: the first time anyone but Sonlm hears the game. Epics 7 and 8 start only when gate 2 passes.

## What the ear-test prototype already provides

| Piece | Used in |
|---|---|
| The cry rules: one kind per level, the rear shadow, the three room sounds | Epic 2 |
| The loudness tool that measures every clip and writes the matching table | Epics 2 and 8 |
| The tool that cuts and evens out source recordings, and the credits file | Epic 2 |
| The first-person look, the per-trial session log and its scoring | Epics 1, 2 and 6 |
| The local checks that run before every commit | Epic 1 onward |
| Windows and Linux export settings | Epic 8 |

---

## Epic 1: The span

**Goal.** The bridge works as a system: it can be taken apart, it carries weight, and it falls.

**In**

- Setting up: the game starts beside the ear test, which keeps working unchanged; the checks that run before every commit cover both; a way to start the game in a chosen situation, for Sonlm's checks by eye and ear (architecture AD-54, AD-56).
- 6 sections of 8 planks and 2 rail ropes each; the two piers; the town pier landing.
- The warden walks at 3.5 m/s and looks around.
- Strip a plank (2 s), strip a rail rope (3 s), re-lay a plank (3 s). Parts are carried; the forearm shows the tallies while Tab is held, and the warden can still walk and look.
- Strength = planks left, as a count. A section is drawn with that many planks, which leave in a fixed order that keeps the rest evenly spaced; it can be walked over its whole length while it has any. Load from test weights.
- A section creaks at its limit, groans for 2 s above it, then falls for good with what is on it.
- An open section (no planks) cannot be stood on; the warden edges round it in 4 s; its side beams carry a load of 2.
- Section 6 cannot be stripped below 4 planks.
- A fallen section is a gap the warden crosses hand over hand in 8 s. A warden on a falling section catches the edge and climbs back in 5 s.
- The hold rules: a hold is cancelled by moving 0.5 m, by letting go, or when its action becomes impossible; looking is free; one action at a time; parts are counted when the hold completes. (A wound cancels a hold from epic 4; a pause freezes one from epic 5.)
- An overhead read-out of every section's planks, rails and strength.

**Out.** The dead, rigs, lanterns, cries.

**Playable at the end.** Walk the span, strip it, pile test weights on a weakened section and watch it fall.

**Stories**

1. Setup: the game runs beside the unchanged ear test, with its checks and a way to start in a chosen situation.
2. The span exists as 6 sections with countable planks and rails, drawn to the count.
3. The warden walks and looks in first person.
4. The warden strips and re-lays, carries what is stripped, and reads the tallies on the forearm.
5. Sections have strength, take load, creak, groan and collapse.
6. Open sections and gaps: what the warden can cross, and how long it takes.
7. The overhead read-out shows planks, rails and strength per section.

**Delivers.** GDD Game Mechanics 2 and 3. Decisions GD-19, GD-21 (planks, rope), GD-63; UX-8, UX-11.

---

## Epic 2: The ear

**Goal.** A player can place a threat by ear while walking, with several cries sounding, helped by the ally and by what the lantern shows.

**In**

- The cries re-cut from the original downloads at full quality, with loudness re-measured.
- The ear test's rules carried into the game: one kind of cry per level, the rear shadow, equal loudness at equal distance, the three room sounds.
- Farther is quieter: 3 dB per section, smoothly, along the span only, up to 15 dB (GD-56).
- Cries that come from places: the rails, the piers, overhead.
- The four warnings, built from whole clips: Grappler, Diver, nest (sobs that quicken), and the tune of the one who keeps coming back.
- Several cries at once: never more than 4, warnings at least 1.5 s apart, ambience at least 6 dB under the quietest a cry can be. A warning that cannot start waits, and its threat with it (GD-57). Cutting and skipping the cries of the dead on the deck is epic 3, where those cries arrive.
- Enough of the dead to warn: each kind's warning sounds from its place and ends; what they do after arriving is epic 3. A test timetable with the bell's toll; the full six waves are epic 5.
- The ally's calls, each with a caption at the bottom centre of the view: every warning 2 s in, or only the warnings the player has not turned toward within 4 s.
- The bridge shows where, inside the carried lantern's light: shaking rope, falling dust, swirling fog, and the flame leaning toward the nearest cry inside its light. A cue lasts for the whole of its warning.
- The town bell, and a tally chalked at each toll.
- The dusk lesson, listening part: on a dark screen, one bell stroke to check left and right, answered Left, Right or "I can't hear it", with a key to ring again and a setting to swap the sides (the answer "I can't hear it" is recorded here; its offer of Cues everywhere is wired in epic 5, where that setting is built); then three harmless dead, one per level, the first cry within 15 s and serving as the look lesson, with walking prompted once it is faced; each cry repeats until faced, with "listen again" after each playing not faced and the place's cue shown after three; the ally confirms a right turn. The hands-on part of the lesson is built in epic 5, once the hammer and lantern exist.
- The listening round: 12 warnings from unpredictable places, 4 from each level, in the dark with no ally; scored for direction (within 45° in 4 s) and place (within 5 m in 15 s). It comes after the lesson, with no lantern and the pointer cues off; each trial ends 15 s after its warning starts. Its instruction is read aloud from the session script.
- A per-warning log: did the player turn to within 45° within 4 s; in the dark or in the light; did the ally call it.
- **The early listen** (GD-43): two or three newcomers, at least one on headphones and one on speakers, try the listening lesson and the listening round.

**Out.** What the dead do after they arrive; rigs; oil and hung lanterns.

**Needs.** Epic 1's setup and span stories. The ally's recorded lines (stand-in recordings are fine until epic 6). The original downloads of the 11 recordings. Two or three newcomers.

**Playable at the end.** The listening lesson and the listening round.

**Stories**

1. The cries are re-cut at full quality and re-measured.
2. The ear test's cry rules work for a walking, turning listener.
3. Cries come from rails, piers and overhead, and get quieter with distance.
4. The four warnings play as specified, and the nest's sobs quicken.
5. The 4-cry limit, the 1.5 s spacing and the ambience level hold.
6. The ally calls the level with a caption: every warning, or only the missed ones.
7. The bridge shows where, inside the carried lantern's light, and the flame leans.
8. The town bell tolls from the town side, and the tally is chalked.
9. The listening lesson runs from the left/right check to the last cry, with feedback and the look and walk prompts.
10. The listening round runs and scores direction and place.
11. Every warning is logged: turn, dark or lit, called or not.
12. The early listen is run and written up.

**Delivers.** GDD Game Mechanics 1 and 8; the early listen in Success Metrics. Decisions GD-7, GD-8, GD-9 (carried lantern only), GD-24, GD-26, GD-39 (the rule), GD-40, GD-43, GD-56, GD-57 (warnings); IN-19, IN-20; UX-1, UX-20, UX-22 (the look and walk prompts), UX-26, UX-38 (the left/right check).

---

## Epic 3: The dead

**Goal.** The three kinds of dead arrive, cross and cost the town its lights.

**In**

- Grapplers, step by step: the warning under a rail on sections 1 to 5 (the rail locks); the hook lands (at most 2 per rail) and the Grappler hangs for 6 s with a load of 1; then it walks to the town.
- No rail, no hook; with no free rail, a hook on the deck of the section with the most planks, tearing one off. The deck hook picks an edge at random, and its warning rattles that edge's planks.
- Section 6 takes no hooks and no Divers while any other section has planks.
- Divers: a Diver whose section opens or falls during its 1 s drop falls through (GD-60). A section picked when the warning starts, and the shrieks come from over it; here the section with the fewest planks (the light rule arrives in epic 4); a landing that counts 5; then a walk.
- Hollow Nesters: 40 s of quickening sobs in a pier, then 4 hatchlings at 3.0 m/s.
- On the deck each of the dead repeats its cry every 8 s with footsteps. Warnings come first: one may cut the farthest cry on the deck, and a deck cry with no place is skipped until its next 8 s mark (GD-57). Anything that falls lets out a cry that fades; at most three at once.
- A stranded Diver's second dive is a full 8 s warning (GD-65).
- Loads on sections from every body and every set hook.
- The town's 12 windows; a crossing is stepping off section 6 onto the landing; each puts one window out; hatchlings put one out per two. A window going out makes a small sound from the town side; a lone hatchling's crossing makes the next window flicker low.
- Losing the night: section 6 falls, or the last window goes dark.
- Falling: gone until dawn.
- What each kind does at an open section and at a gap.

**Out.** Rigs; the six-wave timetable (a simple test timetable stands in); the one who keeps coming back.

**Playable at the end.** An undefended span: the dead cross, the windows go out, the night is lost.

**Stories**

1. Grapplers warn, hook, haul and walk.
2. The rail rule decides where Grapplers can come up.
3. Divers warn, choose a section, land hard and walk.
4. Nests warn for 40 s and hatch four.
5. On-deck cries, footsteps and the falling cry.
6. The town's windows go out as the dead cross, with their sound and the flicker.
7. The night can be lost in both ways.
8. The fallen are gone until dawn.
9. Each kind handles open sections and gaps as the GDD states.

**Delivers.** GDD Enemy Wave Design (types), Win/Loss Conditions. Decisions GD-12, GD-13, GD-15, GD-16, GD-17, GD-20, GD-57 (deck cries), GD-60, GD-65 (the second dive); UX-30, UX-37.

---

## Epic 4: Rigs and hands

**Goal.** The warden can hold a wave with tools and the bridge, and every spring spends a part.

**In**

- Context hands: the hammer hand and the rope and lantern hand show the action before the click. A ready pose when something usable is within 2 m; a hold shown by its own animation and sound, with no bar; a cancelled hold dropping from the hand; an impossible action reaching and opening empty. In gray boxes: block hands holding a recognisable hammer, rope or lantern. Hands and forearm keep a minimum brightness, so the ready pose can be told with every lantern shuttered.
- Trapdoor: build (8 s at night), spring, drop, haul up; each drop loses 1 plank; it cannot be sprung under 4 planks.
- Swing-beam: build (12 s at night) on the rail the warden is looking toward, spring, sweep, re-hang; each re-hang costs 1 rope; it knocks hooks off its section's rails and deck edge.
- No rig on section 6. A rail holding a beam, or a hook, cannot be stripped.
- Building, hauling, re-hanging and dismantling only from within 2 m of a section's town-side edge, on the next section toward the town, where the hands take out the tool. A rig cannot be worked while that next section is open or fallen. A warden on a trapdoor when it drops catches the edge and is wounded.
- The wedge: 3 s of hammering, 1 plank, a nest shut for the wave.
- Striking a hook: one blow restarts the haul, once per Grappler.
- Dismantling a rig: planks return, one rope is lost.
- Lanterns: three; one pole on each section; the lantern held over the centre of the section; one lantern in hand, hung, taken or swapped at a pole with one press, and kept lit in hand through holds and wounds; 4 m and 5 m of light; cues wherever light falls, which includes the town gate's light on section 6.
- Oil: 6-minute tanks; one spare flask that stays at the town pier and refills the lantern in hand, once; the shutter (carried and hung); the level read from the lantern's glass, a shrinking, sputtering flame in the last 60 s, and a seam glow when shuttered.
- E acts on what the warden looks at: a pole or the flask (re-laying a plank is already in epic 1). F acts on the hung lantern looked at, otherwise on the lantern in hand.
- Divers pick their section by the light rule, at the start of the warning. An open section cannot be picked, and a redirected Diver lands within sections 1 to 5 when it can. A trapdoor sprung during a Diver's 1 s drop catches it (GD-60); a Diver landing in a beam's sweep is swept off.
- Wounds: knocked down for 1.5 s; sounds on that side of the head quieter, growing to 12 dB at the side, cries also dulled, the ally's voice and the warden's hands never cut, and that side of the view darkened for 20 s (GD-62, GD-66); from the dead, the warden's own beam, a Diver's landing, or a falling section. A wound cancels a hold.

**Out.** The planning view; the full wave timetable; the name.

**Playable at the end.** One scripted wave of Grapplers, a Diver and a nest, held with a trapdoor, a swing-beam, a wedge and lanterns.

**Stories**

1. The hands show and perform the right action for what the warden looks at: ready pose, hold, cancel, can't.
2. The trapdoor, and the plank each drop costs.
3. The swing-beam, and the rope each re-hang costs.
4. Building and dismantling at night, from the town-side edge.
5. The wedge.
6. Striking a hook.
7. Lanterns hung, taken and swapped at poles; cues wherever light falls.
8. Oil, the flask at the town pier, the shutter, and reading the level.
9. Divers follow the light.
10. Wounds.

**Delivers.** GDD Game Mechanics 4, 5, 6, 9; Controls and Input (night). Decisions GD-18, GD-19 (costs), GD-22, GD-27, GD-28, GD-38, GD-41, GD-49, GD-62, GD-66; UX-2, UX-5, UX-6, UX-7, UX-9, UX-29, UX-36.

---

## Epic 5: The night

**Goal.** The whole sitting, start to dawn, in gray boxes.

**In**

- Planning from above: strip the next plank or a rail, place rigs on sections 1 to 5, hang lanterns, undo, Start over, hold Space to ring the bell. Strength numbers, the tool tray with costs, and the why-not line. An undo that needs a spent part is refused, and the bell waits until both lanterns are hung. The view never shows what is under the planks.
- The six waves on their timetable, the lulls, the bell's tolls, the silence before wave 6, the paling sky, dawn on the clock.
- The ally's calls fade to a safety net from wave 4.
- The name under the planks: a random section from 2 to 5, the hum, the leaning flame, read on foot by lantern light with about 1 s of looking, the forearm rising once to show it.
- The one who keeps coming back.
- Calling the name at the bell: its owner passes, and the dead on and under the span stand still and silent for 20 s, hanging Grapplers and anything that arrives meanwhile included (GD-61, GD-64). A wrong ring hurries the walkers; during the stillness it does nothing.
- The tune comes before every other cry on the deck and is never cut by a warning (GD-65).
- Dawn wins if the night would be lost in the same instant, and that instant's loss does not count (GD-59, GD-67). Dawn: the silence, the ally's one line, then the ledger page written in beside the span, with the name learned, its epitaph and the soul released, ending on "The fallen will return." (GD-53); then another night on a fresh span, or leave.
- A lost night: dark, then the journal page with the hint, or the same hint again if its cause repeats; replay from planning, on the plan that night was started with. Every night start rolls the name and its section again and clears the forearm (GD-52), and the oil and the flask are full again (GD-58).
- Starting up: the title (Begin the watch, Settings, Credits, Quit), the headphones-or-speakers question, and skipping the lesson once it has been finished on this machine.
- The lesson's hands-on part, with its key prompts: strike a practice pin on the landing, strip a plank, hang and shutter the lantern, raise the forearm. The span and lanterns are put back before planning.
- Pause as a full stop, which also freezes a hold, with five entries: Resume, Keys, Journal, Settings, and Leave the bridge, which asks first. The key card. The journal page, opened with J in planning and from pause; its hints survive a return to the title (GD-58).
- Settings: Visual cues (In the light, Everywhere, Ears only), with the cues drawn self-lit in the dark for Everywhere; centre dot; volume; headphones or speakers; swap and check left and right; mouse sensitivity; invert look; fullscreen or window; resolution; brightness; field of view; fog quality; caption size. The left/right check's offer of Cues everywhere is wired here.
- Every screen in the Lantern light look from `DESIGN.md`. Keys bound by physical position.
- The night's few texts are written: 6 names with epitaphs, 6 journal hints, the ally's lines.
- Every sound the night still lacks is in place: the hum and the tune, both bells, footsteps, creaks and groans, the collapse, the rigs, the lanterns; and the small sounds of the hands and screens (cancel, can't, sputter, pen-scratch, planning).

**Out.** The woodcut look; stream-safe sound and the accessibility extras of epic 8; the public page.

**Playable at the end.** The full one-night game in gray boxes, about 21 minutes.

**Stories**

1. The planning view, its tray and its undo.
2. The six-wave timetable with its lulls, tolls, silence, sky and dawn.
3. The carved name: the hum, the flame, reading it, the forearm.
4. The one who keeps coming back.
5. Calling the name, and the wrong ring.
6. Dawn and the ledger page.
7. Losing, the journal page, the six hints and the replay on the last plan.
8. Title, sound-output question, pause, key card, settings and lesson skip.
9. All remaining sounds in place.
10. The 6 names with their epitaphs, the 6 hints and the ally's lines are written.
11. The lesson's hands-on part and its key prompts.
12. Every screen in the Lantern light look.

**Delivers.** GDD Core Gameplay Loop; Game Mechanics 7 and 10; Enemy Wave Design (waves); Difficulty and Replayability. Decisions GD-11, GD-14, GD-23, GD-25, GD-35 (one-night items), GD-39 (from wave 4), GD-42, GD-52, GD-53, GD-58, GD-59, GD-61, GD-64, GD-65 (the tune), GD-67; UX-3, UX-4, UX-10, UX-12 to UX-25, UX-27, UX-31 to UX-34, UX-39 (brightness, field of view), UX-40, UX-41.

---

## Epic 6: Gate 2

**Goal.** Know whether the night is fun and whether newcomers can hold it by ear.

**In**

- The listening round, run with each newcomer before their first night. The ear re-check's pass marks apply to it.
- A playtest build that logs to a local file: each warning in waves 4 to 6 (turn, heading, section, dark or lit, called or not); each night (sections, windows, tries, length, name found, name called); and time spent on each section. It also records the headphones-or-speakers answer, the Visual cues and Holds settings for each night, the time from Begin the watch to the first cry, and every pause. This night log is supporting data.
- A fixed question sheet: play again? what felt clever?
- Five newcomers, at least two on headphones and two on speakers, playing at the default settings.
- Scoring the three checks and the ear re-check; a written outcome.
- A tuning pass on the starting values.
- If a check fails: fix the cause and run the gate again with people who have not played.
- If the ear re-check fails: the fallbacks in the GDD.

**Out.** Art.

**Needs.** Five people who have never seen the game. The ally's final recorded lines.

**Playable at the end.** The tuned night, with a gate 2 outcome document beside it.

**Stories**

1. The playtest log.
2. The question sheet and the session script, with the listening round's instruction to read aloud.
3. Five sessions run.
4. The three checks and the listening round scored and written up, with the night log beside them.
5. Starting values tuned from what the sessions showed.
6. A failed check is fixed and the gate re-run; fallbacks chosen if the ear re-check fails.

**Delivers.** GDD Success Metrics (gate 2, ear re-check). Decisions GD-29, GD-30, GD-40 (the place score), GD-46; IN-20.

---

## Epic 7: The look

**Goal.** The proven night in its real look, at the performance targets.

**In**

- The woodcut treatment.
- Sourced models and animation: the span kit, the town and its 12 windows, the dead, the warden's arms and tools, with the forearm's ink kept clear of the hatching and the minimum brightness of epic 4 kept under the woodcut treatment; the lantern with its glass reservoir; the tally board, the ally's silhouette.
- Fog, its low setting and the fog-sprite fallback; the cue effects.
- Measuring on a GTX 1050-class machine and an Intel Iris Xe machine.
- The look test.

**Out.** Any change to rules or numbers.

**Needs.** Gate 2 passed. Models and animation that allow commercial use. The two reference machines.

**Playable at the end.** The same night, in the woodcut look, averaging 60 FPS on the GTX 1050 machine.

**Stories**

1. The woodcut treatment over the gray boxes.
2. The span kit and the town.
3. The dead.
4. The warden's arms, tools and forearm.
5. Fog, its fallback, and the cue effects.
6. Performance on both reference machines.
7. The look test run and written up.

**Delivers.** GDD Art Style; Performance Requirements. Decisions GD-31, GD-32, IN-10.

---

## Epic 8: Going public

**Goal.** The one-night game is on itch.io for Windows and Linux.

**In**

- Loudness measured one last time on the final build.
- 20 nights played back to back without a crash. The other targets checked on the final build: cold start, replay, rig reaction and download size.
- Stream-safe sound. The three clip moments, each checked in a recorded clip.
- The accessibility extras (GD-50): Cues everywhere strengthened (footsteps and bowing planks glow in the dark, a shuttered lantern's seam glow still leans, flames dip with each toll, the ally calls every warning all night); Holds: Press once, which also makes Tab a toggle; Mono sound, which suggests Cues everywhere when chosen. Frame rate is measured again with the extras on.
- The muted night: one night played with the sound off and Visual cues on Everywhere. A check, not a gate.
- Credits and the AI-use disclosure.
- The title checked on itch.io by hand; the *LAST STAGE* demo checked for overlaps.
- The itch.io page, with the public pitch, at "$0 or donate", and its follow button; a first devlog post.
- Windows and Linux builds tested on a clean machine.

**Out.** Steam (tips are saved toward its $100 fee); a Mac build; gamepad.

**Playable at the end.** The public release.

**Stories**

1. Final loudness measurement, the 20-night run, and the start-up, replay, rig-reaction and download-size targets.
2. Stream-safe sound.
3. Clip moments.
4. Credits and disclosure.
5. Title and overlap checks.
6. The itch.io page and a first devlog post.
7. Windows and Linux builds on a clean machine.
8. The accessibility extras.
9. The muted night, run and written up.

**Delivers.** GDD Project Goal 2; Audio and Music (stream-safe sound, clip moments); Game Mechanics 1 (the cue modes); Success Metrics (the muted night). Decisions GD-50; UX-28, UX-38, UX-39 (Holds, Mono sound).

---

## Coverage

Every mechanic in the GDD lands in an epic:

| GDD mechanic | Epic |
|---|---|
| Listening: cries, side, distance, loudness, room sounds, warnings, limits | 2 |
| Visual cues for every sound | 2 (carried lantern), 3 (windows), 4 (hung lanterns, the gate's light, oil, wound), 5 (the hum; the three cue modes), 8 (the Cues everywhere extras) |
| The span: strength, load, creak, collapse, open sections, gaps | 1 |
| Stripping and re-laying; carried parts | 1 |
| Rigs: trapdoor, swing-beam; what each spring spends; night building | 4 |
| The wedge; striking a hook | 4 |
| Lanterns and light; Divers and light | 2 (carried), 4 (hung, oil, shutter, Divers) |
| The bell and the name; the wrong ring; the one who keeps coming back | 5 |
| The ally | 2 (calls, captions, listening lesson), 5 (the fade by wave), 8 (every warning in Cues everywhere) |
| Wounds | 4 |
| Planning from above | 5 |
| The three kinds of dead; on-deck and falling cries; windows; losing | 3 |
| The six waves and their timetable; dawn; the town bell as clock | 2 (bell), 5 (waves, dawn) |
| The dawn ledger; the six hints; replay | 5 |
| Settings: the three cue modes and the settings list | 5; Holds and Mono sound in 8 |
| The hold rules | 1 (move, let go, impossible), 4 (wounds), 5 (pause) |
| The hands: ready pose, hold feedback, cancel, can't; build target; E and F by look | 4 |
| The dusk lesson | 2 (listening part), 5 (hands-on part, skip) |
| Screens: captions, the left/right check, title, first-launch question, skip question, planning tray, pause, key card, journal and lost-night page, ledger page | 2 (captions, the check), 5 |
| The targets beyond frame rate: start-up, replay, rig reaction, download size, first cry | 6 (first cry logged), 8 |
| The early listen; the listening round | 2 (built, first run), 6 (at gate 2) |
| Gate 2; the ear re-check; the camping log | 6 |
| The look test; performance | 7 |
| Stream-safe sound; clip moments; the accessibility extras; the muted night | 8 |
