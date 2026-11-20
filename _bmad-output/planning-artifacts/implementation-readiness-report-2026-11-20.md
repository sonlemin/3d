---
stepsCompleted:
  - step-01-document-discovery
  - step-02-gdd-analysis
  - step-03-epic-coverage-validation
  - step-04-ux-alignment
  - step-05-epic-quality-review
  - step-06-final-assessment
status: complete
readiness: NEEDS WORK
filesIncluded:
  gdd: _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md
  epics: _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md
  ux:
    - _bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/DESIGN.md
    - _bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md
  architecture: _bmad-output/game-architecture.md
  supporting:
    - _bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/decision-log.md
    - _bmad-output/implementation-artifacts/deferred-work.md
    - _bmad-output/project-context.md
---

# Implementation Readiness Assessment Report

**Date:** 2026-11-20
**Project:** 3d_game (The Mourning Watch, the one-night game)
**Assessor:** Claude, through gds-check-implementation-readiness, for Sonlm
**Result:** NEEDS WORK. See Summary and Recommendations at the end.

## Document Inventory

| Type | File | Size | Modified | Format |
|---|---|---|---|---|
| GDD | `planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md` | 86,518 B | 2026-11-20 13:06 | Whole |
| Epics & Stories | `planning-artifacts/gdds/gdd-3d_game-2026-11-19/epics.md` | 27,148 B | 2026-11-20 13:06 | Whole |
| UX (look) | `planning-artifacts/ux-designs/ux-3d_game-2026-11-19/DESIGN.md` | 17,446 B | 2026-11-20 00:27 | Whole |
| UX (behaviour) | `planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md` | 35,974 B | 2026-11-20 13:06 | Whole |
| Architecture | `_bmad-output/game-architecture.md` | 103,138 B | 2026-11-20 13:06 | Whole |

**Supporting references:** GDD `decision-log.md` (61,649 B), `implementation-artifacts/deferred-work.md` (10,220 B), `project-context.md` (21,345 B).

**Duplicates:** None. No document exists in both whole and sharded form.

**Missing documents:** None.

**Notes:**

- The architecture document sits in `_bmad-output/`, outside `planning-artifacts/`, so the default search pattern does not find it. It was located by name.
- `DESIGN.md` was last modified 2026-11-20 00:27, before the GDD draft 0.7 write-back at 13:06 the same day. Its alignment with draft 0.7 is checked in the UX step.

## GDD Analysis

Source: `gdd.md`, draft 0.7 (2026-11-20), read in full. The GDD does not number its requirements as FR/NFR; it states rules by section and cites decision IDs (GD-n, UX-n). The numbering below was assigned in this assessment so coverage can be traced. Each entry names the GDD section it comes from. Scope is the one-night game only; the Fog Season is an outline and is not assessed.

### Functional Requirements

**A. The sitting and its phases**

- FR1 (Core Gameplay Loop): On a first launch, one question comes before the lesson: headphones or speakers. The answer changes no cue, is kept in settings and is written to the playtest log.
- FR2 (Core Gameplay Loop): Left/right check. On a dark screen one stroke of the town bell sounds: left or right? The player can ring it again or answer "I can't hear it", which offers Cues everywhere. Two wrong answers offer the swap-left-and-right setting, warn the sound may be single-channel, and make the same offer.
- FR3 (Core Gameplay Loop): Listening lesson. Three harmless dead, one per level; the first cry starts within 15 s. Each cry repeats until the warden faces within 45° of it; the ally confirms a right turn. After each playing not faced the ally says "listen again"; after three, the place shows its visual cue, held back until then. Walking is prompted once the first cry has been faced.
- FR4 (Core Gameplay Loop): Hands lesson, about a minute, each step with a one-line key prompt: strike a practice pin on the landing, strip a plank, hang and shutter the lantern, raise the forearm. It ends when all four are done; the span and lanterns are put back before planning.
- FR5 (Core Gameplay Loop): Once the lesson has been finished on this machine, Begin the watch offers to skip it and the left/right check.
- FR6 (Core Gameplay Loop): The sitting runs dusk lesson (first person) → planning (from above, untimed) → the night (12 min, first person, six waves) → dawn (from above, the ledger).
- FR7 (Planning): Planning is an overhead view of the whole span with no dead and no time limit. Stripping and placing cost no time.
- FR8 (Planning): In planning the warden strips planks and rail ropes, places trapdoors and swing-beams on sections 1 to 5, and hangs the two placed lanterns. A click on a deck strips its next plank in the fixed order; a click on a rail strips that rail; a swing-beam is placed by clicking the rail it hangs from.
- FR9 (Planning): Undo. Right click takes back the last choice on a section; Start over (1 s hold) restores the whole span. An undo that needs a part no longer in hand is refused and says why.
- FR10 (Planning): The view shows each section's planks, rails and strength as a number; each rig shows the section it covers and each lantern its reach. A tray shows planks and ropes in hand, the three tools with costs, and lanterns left to place. A tool that cannot be afforded is dimmed; pointing at it, or at a section where the chosen tool cannot go, says why. The view never shows what lies under the planks and does not use the woodcut look.
- FR11 (Planning): Ringing the bell (1 s hold of Space) ends planning and starts the night. It cannot be rung until both placed lanterns are hung, and it says why. The night starts with the warden on the town pier landing; the warden's bell rings and the town bell answers with the single toll of wave 1.
- FR12 (Planning; Win/Loss): After a lost night planning opens on the plan that night was started with, and can be undone the same way. After a dawn, Another night opens a fresh span.

**B. Listening and sound rules**

- FR13 (Mechanics 1): Each level has one kind of cry, one kind of place, one visual cue and one ally call: below = whispers at a rail, ropes shake, "Below!"; above = shrieks over the open deck, fog swirls, "Above!"; inside = sobbing in a pier, dust falls, "In the walls!". A kind of cry never appears at another level.
- FR14 (Mechanics 1): The one who keeps coming back sings a low wordless tune where a Grappler would whisper: a fourth voice on the level below, at the same kind of place.
- FR15 (Mechanics 1): Side comes from stereo placement that follows the warden's head.
- FR16 (Mechanics 1): Rear shadow. A cry straight behind has its treble above 2 kHz cut by up to 10 dB and is up to 2 dB quieter; at the side, half of each; it brightens as the warden turns to face it.
- FR17 (Mechanics 1): Distance. A cry loses 0.6 dB per metre along the span (3 dB per section, up to 15 dB at 25 m), changing smoothly with no jump at a section edge. Only distance along the span counts; height and sideways offset do not.
- FR18 (Mechanics 1; Audio): Three room sounds as atmosphere, not cue: above thin and open (mostly above 1000 Hz), inside muffled (mostly below 650 Hz), below with a long cave echo (mostly below 2500 Hz).
- FR19 (Mechanics 1): Warnings. Every threat warns before it can affect the bridge, built from whole 4.3 s clips: Grappler 6 s (one whisper, then 1.7 s straining rope); Diver 8 s (two shrieks, second starting at 3.7 s); nest 40 s (seven sobs, gaps closing from about 3.3 s to none, quickening not louder); the one who keeps coming back 6 s (one phrase of the tune, then 1.7 s straining rope). A warning sounds from where the threat will arrive.
- FR20 (Mechanics 1): On the deck each of the dead repeats its own cry every 8 s and adds footsteps on the planks.
- FR21 (Mechanics 1): Never more than 4 cries at once. The tune counts as a cry; the hum, the tune's resolving phrase, falling cries, the ally and ambience do not.
- FR22 (Mechanics 1): Warnings come first. A warning sounds for its whole length. If all four places are taken when one is due, the cry of the dead farthest from the warden on the deck fades out in 0.1 s. The tune is never the cry that is cut.
- FR23 (Mechanics 1): Two warnings never start within 1.5 s of each other. A warning that cannot start (that gap, or four warnings already sounding) waits, and its threat waits with it, so nothing arrives on less than its full warning.
- FR24 (Mechanics 1): A deck cry that finds no free place is skipped and tries again at its next 8 s mark. The tune takes a free place before any other deck cry; after it, the nearest to the warden come first. While four warnings sound not even the tune sounds. Footsteps always remain.
- FR25 (Mechanics 1; Audio): Anything that falls lets out a cry that fades over 2 s, outside the 4-cry limit. At most three falling cries at once; a fall while three are fading is silent.
- FR26 (Mechanics 1; Horror): Ambience (creaks, wind, the town bell) sits at least 6 dB under the quietest a cry can be. There is no music. In the last 10 s before the sixth toll the wind and the bridge fall silent.
- FR27 (Mechanics 1): A hook on the deck warns from under the chosen edge of that section, and that edge's planks rattle, in the same cue modes as the shaking ropes.

**C. Visual cues and cue modes**

- FR28 (Mechanics 1): Every sound has a visual cue, shown wherever light falls (the three lanterns and the town gate), lasting the whole of its warning: level cues (shaking ropes, swirling fog, falling dust, rattling planks); a lit lantern's flame leans toward the nearest cry sounding inside its own light; the tune's rail ropes sway in time; a section's creak shows as bowing planks; a flame near empty shrinks and the glass shows the level.
- FR29 (Mechanics 1; Mechanics 7): The carried lantern's flame leans toward the name's section within 3 m, only while the hum can be heard (no cry sounding).
- FR30 (Mechanics 1): The town bell's toll is shown by the ally chalking one tally per wave on the board at the town pier.
- FR31 (Mechanics 1): One setting, Visual cues, with three modes. In the light (default): pointer cues where light falls. Everywhere: pointer cues also in the dark as a faint glow that reveals nothing else, a flame leans toward the nearest cry even beyond its own light, footsteps and bowing planks glow faintly in the dark, a shuttered lantern's seam glow still leans, every lit flame dips once per bell stroke, and the ally calls every warning 2 s in all night. Ears only: pointer cues off; footsteps and bowing planks where light falls. Captions, the wound's darkened side, chalk tallies and anything seen in the light are on in every mode.
- FR32 (Mechanics 1): The Cues everywhere glow can be made out from 15 m at default brightness (starting value, tuned on the muted night).

**D. The span**

- FR33 (Mechanics 2): The span is 6 sections, each 5 m by 5 m, 30 m in all; section 1 touches the far pier, section 6 the town pier. Each section has 8 planks and 2 rail ropes (48 planks, 12 ropes). The warden starts with none in hand.
- FR34 (Mechanics 2): Planks are a count per section, drawn as that many planks, leaving in a fixed order that keeps the rest evenly spaced so strength reads by eye. A section with one or more planks can be walked over its whole length.
- FR35 (Mechanics 2): Strength = planks left (0 to 8). Load: Grappler or Diver standing 1; Grappler hanging from a set hook 1; Diver landing 5 for 0.5 s in place of its 1; hatchling 0.5; the warden 0.
- FR36 (Mechanics 2): A section creaks while load equals strength. When load is above strength it groans for 2 s then falls for good; if load drops back within the 2 s it holds.
- FR37 (Mechanics 2): A Diver's landing counts 5 on top of what already stands there; if the total is above strength the section falls at once.
- FR38 (Mechanics 2): What falls with a section: the dead on it, a rig on it, any lantern hung on it, and its remaining planks and ropes. A warden on it catches the edge and climbs back onto the nearest standing section toward the town in 5 s, with a wound.
- FR39 (Mechanics 2): An open section (trapdoor down, or no planks) cannot be stood on. Crossing along its side beams takes a Grappler or Diver 12 s, a hatchling 6 s, the warden 4 s. Side beams carry a load of 2; more than that for 2 s and the section falls. Whoever stands on a section when its last plank is taken is on the side beams from that moment.
- FR40 (Mechanics 2): A fallen section is a 5 m gap. A Grappler hooks across in 12 s. A stranded Diver takes off and dives again 8 s later (a full warning that takes one of the four places, keeps the 1.5 s gap, and may sound during a lull), picking by the same rule among sections on the town side. Stranded hatchlings fall. The warden crosses hand over hand in 8 s.
- FR41 (Mechanics 2): Section 6 stands inside the town gate's light. It cannot be stripped below 4 planks, nothing can be built on it, Grapplers do not hook its rails and Divers do not pick it. Exceptions: when no other section has planks, deck hooks and Divers come to section 6; a re-diving Diver comes to section 6 when no section between the gap and the town can be picked.
- FR42 (Mechanics 2; Pillar 1): Any of the dead that falls is gone until dawn. Nothing in the one-night game ends one of the dead on the deck.

**E. Stripping, re-laying, hooks**

- FR43 (Mechanics 3): Strip a plank: 2 s, +1 plank in hand, strength −1. Strip a rail rope: 3 s, +1 rope, no Grappler can hook that rail. Re-lay a plank: 3 s, −1 plank, strength +1. Dismantle a rig: 4 s, its planks return, one of its ropes is lost.
- FR44 (Mechanics 3): Parts are carried with no limit and kept through every wound, climb and crossing. The forearm shows tallies of planks and ropes in hand.
- FR45 (Mechanics 3): A rail is locked from the moment a Grappler's warning starts under it until that Grappler is on the deck or has fallen. A rail holding a swing-beam cannot be stripped.
- FR46 (Mechanics 3): No rail, no hook. Grapplers hook only a standing rail on sections 1 to 5; a rail holds at most 2 hooks, counting a warning started under it. With no free rail a Grappler hooks the deck edge of the section with the most planks (nearer the far pier on a tie), tearing one plank off as the hook lands, left or right edge at random.
- FR47 (Mechanics 3): Striking a hook. A 0.5 s hammer blow on a set hook makes the Grappler restart its 6 s haul. The hook stays set and keeps its load. Each Grappler can be shaken loose once.
- FR48 (Mechanics 3): A Grappler's steps: 6 s warning under the rail (load 0, rail locked); hook lands and it hauls for 6 s, or 12 s if shaken loose (load 1); on the deck walking (load 1). The hook is gone once it is on the deck. If its section falls or is swept while it hangs, it falls.

**F. Rigs and the wedge**

- FR49 (Mechanics 4): One rig per section, sections 1 to 5 only. A rig is built, sprung, hauled up, re-hung and dismantled from its section's town-side edge: the warden stands within 2 m of it on the next section toward the town, looking at the section ahead. While that next section is open or fallen the rig cannot be worked. A blow struck from the rig's own section still springs it.
- FR50 (Mechanics 4): Trapdoor. Costs 2 ropes; needs 4 or more planks on its section; 8 s to build at night; sprung by a hammer blow on its pin; the planks drop within 0.3 s and everything on the section falls; each spring loses 1 plank from its section; reset by a 6 s haul; while sprung the section is open; cannot be sprung with fewer than 4 planks; a warden on it catches the edge, climbs back in 5 s and is wounded.
- FR51 (Mechanics 4): Swing-beam. Costs 4 planks + 2 ropes; needs a standing rail, picked at build (at night the side the warden looks toward when the hold starts, in planning the rail clicked); 12 s to build; sprung by a blow that cuts its holding rope; sweeps the section in 1.5 s, knocking off everything standing on it or edging along its side beams and every hook on its rails or deck edge; each spring spends 1 rope; reset by a 10 s re-hang with a rope in hand; cannot be sprung until re-hung; a warden on the section is knocked down and wounded.
- FR52 (Mechanics 4): With no rig, a section stripped to just under the weight about to stand on it collapses under them and is lost for good.
- FR53 (Mechanics 5): The wedge. While a nest is sobbing (40 s), 3 s of unbroken hammering and 1 plank keeps that nest shut for the rest of the wave. It can only be driven while the nest is sobbing.

**G. Lanterns, light and Divers**

- FR54 (Mechanics 6): Three lanterns: one carried, two placed in planning. Each section has one pole on a side beam holding the lantern over the section's centre. At night start both placed lanterns are hung, the third is in hand, all full and lit.
- FR55 (Mechanics 6): One lantern in hand. At a pole the warden hangs, takes or swaps in one press. With none in hand the warden carries no light. The lantern in hand is kept, lit, through every hold, wound, climb and crossing. A lantern over an open section cannot be reached until the section can be stood on again.
- FR56 (Mechanics 6): Light reaches 4 m from the carried lantern and 5 m from a placed one. The town gate's light on section 6 cannot be shuttered or moved. Visual cues show only where light falls unless Cues everywhere is on.
- FR57 (Mechanics 6): Oil. A full tank burns 6 minutes. One spare flask stays at the town pier and is never carried; a refill takes 4 s and fills one lantern's tank, once.
- FR58 (Mechanics 6): Reading oil. Each lantern's glass reservoir shows the level up close. In the last 60 s the flame shrinks and sputters; its reach does not change. A shuttered lantern glows through its seams; an empty one is dark.
- FR59 (Mechanics 6): Shutter. A closed lantern gives no light, burns no oil and cannot be seen by Divers. F acts on a hung lantern looked at within 2 m, otherwise the one in hand.
- FR60 (Mechanics 6): A hung lantern survives a trapdoor drop and a beam's sweep. It is lost if its section falls.
- FR61 (Mechanics 6): A Diver picks its section when its warning starts: (1) the section with a lit hung lantern, nearest the town if several; (2) otherwise the warden's section if the carried lantern is lit; (3) otherwise the section with the fewest planks, nearer the town on a tie. Only sections 1 to 5 with planks and not open can be picked; a lantern on section 6 or the landing is ignored; with no such section it comes down on section 6. Moving or shuttering a lantern after the warning starts does not change the pick.
- FR62 (Mechanics 6): If the picked section is open or fallen when the warning ends, the Diver lands on the nearest of sections 1 to 5 with planks and not open, looking toward the town first, then the far pier; only if none, section 6.
- FR63 (Mechanics 6): During the Diver's 1 s drop: if its section opens or falls, it falls through and is gone until dawn. A trapdoor's section is open from the moment of the blow. A Diver that lands while a beam is sweeping is swept off. A Diver recovers for 2 s after landing.

**H. The bell and the name**

- FR64 (Mechanics 7): One section, random from 2 to 5 each run, has a name carved under its planks; the name is one of six.
- FR65 (Mechanics 7): The hum (the tune, 12 dB under a cry) is heard within 3 m of that section whenever no cry is sounding.
- FR66 (Mechanics 7): The name is uncovered at 4 planks or fewer. It is read only on foot, at night, by lantern light, from within 2 m for about 1 s. Once read it is inked on the forearm, which rises once on its own to show it.
- FR67 (Mechanics 7): The one who keeps coming back arrives once per wave from wave 2, behaves as a Grappler but sings the tune, and returns next wave whether it falls or crosses.
- FR68 (Mechanics 7): Calling the name. One 1 s pull of the bell rope at the town pier, after the name is read, while its owner is on or under the span: the owner stops, passes in peace and never returns; the tune resolves. If the owner is still in its warning, the warning stops, its rail unlocks and no hook lands. The ledger records one name learned and one soul released.
- FR69 (Mechanics 7): The stillness. Every other one of the dead on or under the span stands still for 20 s: everything they were doing stops and resumes afterwards (walking, a haul with its hook keeping load, a Diver's recovery, side-beam and gap crossings, a stranded Diver's wait); they fall silent (no deck cries, no footsteps); warnings already sounding finish and what they announce arrives and then stands still, as does the threat of a warning that starts during it; the bridge and rigs do not stop; the wave timetable and the dawn clock keep running.
- FR70 (Mechanics 7): A wrong ring (name unread or owner absent) makes every one of the dead walking the span walk half again as fast for 10 s; a haul is not hurried. A wrong ring during the stillness does nothing; a right ring ends a hurry.

**I. The ally**

- FR71 (Mechanics 8): The ally stands at the town pier, cannot be hurt, and is a silhouette (a lantern, tools, a voice).
- FR72 (Mechanics 8): Waves 1 to 3: calls the level about 2 s after each warning starts. Waves 4 to 6: calls only when the warden has not turned to within 45° of a warning 4 s after it starts. One call at a time; a call that cannot start within 4 s of when it was due is dropped.
- FR73 (Mechanics 8): About 10 recorded lines: 3 level calls; 3 for the dusk lesson (an opening line, a confirming word that is not "right", "listen again"); 1 for the first return of the one who keeps coming back; 2 of warmth in a lull; 1 at dawn.
- FR74 (Mechanics 8): Every line has a matching caption: one line at bottom centre, shown for as long as the line is spoken and at least 2 s, in every cue mode.

**J. Wounds**

- FR75 (Mechanics 9): One of the dead that reaches the warden shoves past: the warden is knocked down for 1.5 s. The same wound follows the warden's own swing-beam, a Diver landing on the warden's section, or a section falling under the warden. There is no health bar and the warden cannot die.
- FR76 (Mechanics 9): For 20 s sounds on the wounded side are up to 12 dB quieter and the view darkens on that side. The side is the warden's own and turns with the head; the cut grows from nothing straight ahead or behind to the full 12 dB directly at the side. It applies to every placed sound (cries, tune, hum, footsteps, hooks, creaks, both bells, windows, wind); the ally's voice and the warden's own hands are never cut. Cries, the tune and the wind are also dulled by up to 10 dB above 1 kHz; footsteps, hooks and creaks keep their tone.
- FR77 (Mechanics 9): The wound is on the side the blow came from; a fall or a landing picks a side at random. Both sides can be wounded at once; a second wound on a wounded side restarts its 20 s without growing the cut.

**K. Controls and the hands**

- FR78 (Controls): Night input, keyboard and mouse only: W A S D walk at 3.5 m/s, no sprint, no jump; mouse look; left mouse = hammer hand (strike 0.5 s, strip a plank 2 s hold, wedge 3 s hold); right mouse = rope and lantern hand (strip a rail 3 s, haul 6 s, re-hang 10 s, bell rope 1 s); E (hang/take/swap, re-lay 3 s, refill 4 s); F shutter; 1 (hold 8 s) build trapdoor; 2 (hold 12 s) build swing-beam; R (hold 4 s) dismantle; Tab (hold) raise the forearm; Esc pause.
- FR79 (Controls): Context hands. The game picks the action from what the warden looks at within 2 m, and the hands show that action before the click: a ready pose means an action, no pose means none. At a rig's working edge the hands take out the tool, the sign that 1, 2 and R will act.
- FR80 (Controls): Planning input: left click strips or places; right click undoes; 1, 2, 3 choose trapdoor, swing-beam, lantern, and the same key or Esc puts the tool away; Space (1 s hold) rings the bell; Start over (1 s hold on the tray); J opens the journal once it holds a hint; Esc pauses when no tool is chosen.
- FR81 (Controls): Holds. A held action is cancelled by moving more than 0.5 m, by a wound, by letting go, or the moment it becomes impossible; looking is free. One action at a time. Parts are gained or spent when a hold completes. A pause freezes a hold without cancelling it. A strike's blow lands at the end of its 0.5 s.
- FR82 (Controls): Holds setting. On Press once, a press starts a hold and a second press stops it, with the same times, and Tab becomes a toggle. Planning's two 1 s holds stay holds in both settings.
- FR83 (Controls): Action feedback at night with no prompts, bars or rings. A hold is its own progress (counted blows, rope hand over hand, a plank levering up, a heavier final beat). A cancelled hold drops from the hand with a slack-rope or dropped-tool sound. An impossible action makes the hand reach, stop short and open empty with a dull knock, including a second strike on a hook already shaken once.
- FR84 (Controls): The forearm (Tab) shows the name if read and the tallies of parts in hand. The warden can still walk and look; neither hand can act until it is lowered; it is ignored during a hold.
- FR85 (Controls): A key card listing every key can be read in planning and on the pause screen.
- FR86 (Controls; Platform): Keys are bound by physical position and named as the player's keyboard prints them. No key rebinding.
- FR87 (Controls): Pause (Esc): everything stops and falls silent.

**L. The dead and the waves**

- FR88 (Enemy Wave Design): Grappler: below, whispers, 6 s warning under a rail, hook lands and it hauls up in 6 s, walks 1.2 m/s, load 1 from the moment its hook lands, 1 window if it crosses. It enters at any standing rail on sections 1 to 5 with fewer than 2 hooks, never the same rail twice running unless only one is free.
- FR89 (Enemy Wave Design): Diver: above, shrieks, 8 s warning circling overhead, drops in 1 s, recovers 2 s, walks 1.0 m/s, load 5 on landing then 1, 1 window if it crosses.
- FR90 (Enemy Wave Design): Hollow Nester: inside, sobbing, 40 s quickening warning, 4 hatchlings break out together; far pier onto section 1, town pier onto section 6; hatchlings walk 3.0 m/s, load 0.5 each, half a window each.
- FR91 (Enemy Wave Design): Six waves of 2 minutes each: warnings start in the first 75 s, none in the 45 s lull. Counts per wave (Grapplers/Divers/nests): 3/0/0, 4/0/0, 3/1/0, 2/2/1, 5/2/1, 6/3/2.
- FR92 (Enemy Wave Design): The timetable, seconds after the toll's first stroke, exactly as tabled in the GDD for waves 1 to 6, including opposite-rail pairs in wave 2 and which pier each nest is in.
- FR93 (Enemy Wave Design): The town bell tolls at the start of each wave: one stroke for wave 1 up to six for wave 6, 1.5 s apart. A wave's clock starts at its first stroke.
- FR94 (Enemy Wave Design; Difficulty): Nothing in the night is random except: which rail a Grappler picks; which edge a deck hook takes; the side of a sideless wound; which of the six names; where the name lies.

**M. Winning, losing, the journal and the ledger**

- FR95 (Win/Loss): Dawn comes 12 minutes after the first toll, whatever is on the span. The dead still on the span sink back and do not count as crossings. If the night would be lost in the same instant as dawn, it is dawn and that instant's event does not count. There is no victory screen.
- FR96 (Win/Loss): The night is lost when section 6 falls for good, or the last of the town's 12 lit windows goes dark. Sections 1 to 5 falling, a wound, and running out of oil are not losses.
- FR97 (Win/Loss): Crossing: one of the dead crosses when it steps off section 6 onto the town pier landing. Each crossing puts one window out; hatchlings put one out per two, counted across the night.
- FR98 (Win/Loss): Windows are behind the warden and visible from the deck. Each going out makes one small sound from the town side. After a single hatchling's crossing the next window flickers low until a second puts it out; a full crossing during a flicker puts that window out and the next takes up the flicker.
- FR99 (Win/Loss): At the moment of loss the cries cut to wind, the view goes dark, and the journal opens on the hint. A lost night replays from planning.
- FR100 (Win/Loss): Every night start is a new run: the name and its section are rolled again and the forearm is blank, while the journal carries over. On a replay whatever fell or was spent is back as the plan had it, and all three lanterns and the flask are full. The lesson is not replayed.
- FR101 (Win/Loss): Journal hints. Six, one per cause: Grapplers crossing; Divers crossing; hatchlings crossing; section 6 overloaded; section 6 torn up by hooks; the one who keeps coming back crossing three or more times. The cause is found in the order the GDD gives. Each hint is one or two plain sentences about the cause, never a score.
- FR102 (Win/Loss): If that cause's hint is already in the journal it is shown again and nothing new is written. Hints last while the game is running, including a return to the title, and are gone when it is closed.
- FR103 (Win/Loss): Dawn opens with every cry stopped; the ally speaks the dawn line; then the ledger lists in order: sections standing of 6; windows lit of 12; planks and ropes left; wounds taken; names learned (name and epitaph, or "None"); souls released ("One" or "None"); "The fallen will return." as the last line, with no number.
- FR104 (Win/Loss): The ledger is a page beside the span, written one line at a time while the bridge stays in view. It ends with two choices: another night, or leave. It never shows a kill count or a score.

**N. Screens, settings, saving**

- FR105 (Art Style): Screens: title, planning tray, pause, settings, journal, ledger, captions, in the Lantern light look defined in `DESIGN.md`.
- FR106 (Art Style): No HUD at night. One thing is drawn over the night view: the ally's caption. A centre dot can be switched on. The hands and forearm keep a minimum brightness, enough to tell the ready pose with every lantern shuttered.
- FR107 (Difficulty): Settings that do not change the rules: volume; headphones or speakers; swap left and right; check left and right; stream-safe sound (cries +6 dB over everything else); mono sound (choosing it suggests Cues everywhere); centre dot; mouse sensitivity; invert look; Holds; fullscreen or window; resolution; brightness; field of view; fog quality; caption size.
- FR108 (Resource Scarcity): No save. Between launches the game keeps only its settings and a note that the lesson has been finished.

**O. Playtest instrumentation and gates**

- FR109 (Success Metrics): The playtest build writes a local log recording: both settings (Visual cues, Holds) for every night; the headphones-or-speakers answer; every pause; time from Begin the watch to first cry; time spent on each section; and, for every warning in waves 4 to 6, whether the warden turned within 45° in 4 s, whether the warden was heading toward the arrival point at 4 s, dark or lit, the section, and whether the ally called it.
- FR110 (Success Metrics): The listening round. 12 warnings from unpredictable places, 4 per level, in the dark, no ally, nothing to defend, no lantern, pointer cues off; each trial ends 15 s after its warning starts. It scores direction (within 45° in 4 s) and place (stops within 5 m of the arrival point in 15 s).
- FR111 (Success Metrics): The fairness check must be answerable from the logs: no threat affects the bridge before its full warning has sounded.
- FR112 (Success Metrics): The early listen at the end of epic 2: two or three newcomers try the lesson and the listening round.
- FR113 (Success Metrics): Gate 2: five newcomers play in gray boxes at default settings; three checks (want more, barely, clever) plus the ear re-check; name found and name called are recorded.
- FR114 (Success Metrics): The muted night in epic 8: one night with sound off and Cues everywhere.
- FR115 (Success Metrics): The look test after gate 2: screenshot readability by three people, performance with the woodcut treatment, no model out of place.

**Total FRs: 115**

### Non-Functional Requirements

**Performance**

- NFR1: GTX 1050-class card, 1080p, low fog: average 60 FPS or more with 1% lows of 45 or more, measured across the whole 12-minute night including wave 6.
- NFR2: Intel Iris Xe, 720p, fog-sprite fallback: average 30 FPS or more with 1% lows of 24 or more.
- NFR3: Peak scene to hold these: wave 6, up to 18 of the dead on the span, three lanterns and fog.
- NFR4: Cold start to the menu in 10 s or less on the GTX 1050 machine.
- NFR5: Replaying a lost night starts in 3 s or less from the player's action on the lost-night page.
- NFR6: A sprung rig reacts within 0.3 s of the hammer blow.
- NFR7: Download size 300 MB or less.

**Reliability**

- NFR8: No crash in 20 nights played back to back.
- NFR9: Fairness: no threat affects the bridge before its full warning has sounded.

**Audio quality**

- NFR10: Any two cries at the same distance play within 1 LU of each other, measured straight ahead before the rear shadow, re-measured whenever a clip or a sound setting changes.
- NFR11: The first cry starts within 15 s of the lesson opening; median time from Begin the watch to first cry 60 s or less.

**Platform**

- NFR12: Windows 10 and 11 (64-bit) and Linux (x86-64), distributed on itch.io, free.
- NFR13: Godot 4.7.2, pinned, Forward+ renderer.
- NFR14: Stereo output on headphones or speakers; a mono fold-down setting; no HRTF plugin in the base game.
- NFR15: A low fog setting and a fog-sprite fallback are both required.
- NFR16: No network. The public build collects nothing; the playtest build logs to a local file.

**Accessibility and comfort**

- NFR17: No full-screen flash and no screen shake; full-view changes are slow fades only. Nothing flickers faster than 3 times a second. The camera has no bob and no roll.
- NFR18: The ally's calls are captioned in every cue mode; caption size is a setting.
- NFR19: Cues everywhere must let a player who cannot hear face each warning within 4 s (checked by the muted night).
- NFR20: Holds can be played as Press once.

**Content and licensing**

- NFR21: Every asset and AI output must allow commercial use (such as CC0 or CC-BY). AI use is disclosed on the itch.io page. Nothing is AI-voiced; no AI-made cries.
- NFR22: One typeface for every screen, Cormorant Garamond (SIL OFL), bundled.
- NFR23: English only.

**Process**

- NFR24: Gray boxes until gate 2 is passed; the look starts only when all three gate 2 checks pass.
- NFR25: Hours are logged from epic 1.

**Total NFRs: 25**

### Additional Requirements

**Constraints**

- Solo developer, Godot only, 5 to 10 hours a week, $0 budget; all art, animation, audio and writing sourced.
- Pillar exclusions that bind every story: no weapons or self-firing turrets; no minimap, enemy markers or wave timer at night; no shop or gold; no kill counter, score or combo meter; no composed music.
- Every number is a starting value to tune at gate 2 unless marked measured, so values must be data, not code.
- Project goal 4: the design must grow into the Fog Season without rebuilding the span, the ear or the dead.

**Asset requirements (GDD Asset Requirements table)**

- Cries: the 13 clips re-cut from original downloads; the tune in 3 variations, its resolving phrase and its hum; falling cries.
- About 35 other sounds, about 10 spoken lines recorded by a person, the span kit and character models, the effects list, and the text list (6 names with epitaphs, 6 journal hints, ally lines, menus, lesson prompts, why-not lines, key card, listening round instruction).

**External dependencies**

- A person to record the ally's lines.
- The original downloads of the 11 Freesound recordings.
- Two or three newcomers for the early listen and five more for gate 2, split across headphones and speakers.
- A GTX 1050-class machine and an Intel Iris Xe machine.
- Before going public: the title checked on itch.io, and the *LAST STAGE* demo watched for overlaps.

**Open assumptions the GDD names (11)**

- Assumptions 1 to 4 (play by ear under game conditions) are tested at the early listen and the ear re-check. Assumption 9 (hands alone carry action feedback) is tested only at gate 2. Assumption 11 (Godot 4.7.2 physical keys and mono fold-down) is assigned to architecture.

### GDD Completeness Assessment

**Strengths**

- The one-night game is specified to the level of timings, loads and tie-break rules. Rule interactions (lanterns with open sections, Divers with gaps, the stillness with warnings) are stated, not left to the implementer.
- Every rule cites a decision ID, so each can be traced to `decision-log.md`.
- Scope is explicit: a tiered cut list, and an Out of Scope section with four categories.
- Success is measurable: gate 2 has three pass marks, the ear re-check has two scored thresholds with named fallbacks, and performance has two reference machines.
- The document states its own weaknesses under Notes for the designer.

**Concerns carried forward to later steps**

1. **Requirements are not numbered.** Traceability to epics depends on GD-n citations or section names, not on FR IDs. Step 3 checks whether `epics.md` cites them consistently.
2. **Draft 0.7's last changes are unread.** The GDD says a validator found 10 major problems in the 0.7 write-back, that GD-64 to GD-67 answer them, and "Nobody has read the result." The stillness (FR69), the tune under the 4-cry limit (FR22, FR24) and what a wound cuts (FR76) are the rules affected.
3. **The estimate exceeds the brief.** 335 to 525 hours against 250 to 500. The GDD also says the architecture's per-story test path and show-me setup are costed only in epic 1, so epics 2 to 5 are likely under-sized.
4. **Gate 1 closed without meeting its pass mark**, on one practiced listener. Assumptions 1 to 3 are unproven for newcomers until the end of epic 2, after about 95 to 140 hours of work.
5. **Distance loudness (FR17) is unmeasured**, and the listening round's place score depends on it.
6. **Asset dependencies with no owner in the GDD:** the voice recording, the tune and its variations, and the original Freesound downloads.
7. **A per-wave economy line was not done** (noted from the third validation); the worked night stands in for it.

## Epic Coverage Validation

Source: `epics.md`, draft 0.7 (2026-11-20), read in full. It holds 8 epics and 72 one-line stories. It has no FR numbers (the GDD has none); it traces by GDD section and by GD-n / UX-n decision ID in each epic's "Delivers" line, plus a Coverage table of 24 mechanics. The matrix below maps this report's FR numbers to epic and story (E4 S2 = epic 4, story 2).

Status key: ✓ covered (named in an epic's In list or story); ◐ partial (the mechanic has a home but the named detail appears in no epic text); ❌ missing.

### Coverage Matrix

| FR | Requirement (short) | Epic coverage | Status |
|---|---|---|---|
| FR1 | Headphones-or-speakers question | E5 S8; logged in E6 S1 | ✓ |
| FR2 | Left/right check and its offers | E2 S9; Cues everywhere offer wired in E5 S8 | ◐ (G1) |
| FR3 | Listening lesson | E2 S9 | ✓ |
| FR4 | Hands lesson | E5 S11 | ✓ |
| FR5 | Lesson skip | E5 S8 | ✓ |
| FR6 | Sitting structure | E5 (whole epic) | ✓ |
| FR7 | Planning: overhead, untimed | E5 S1 | ✓ |
| FR8 | Planning: strip, place, hang | E5 S1 | ✓ |
| FR9 | Undo, Start over, refused undo | E5 S1 | ✓ |
| FR10 | Planning read-outs, tray, why-not | E5 S1; E1 S7 | ◐ (G2) |
| FR11 | Ring the bell to start the night | E5 S1, S2 | ✓ |
| FR12 | Planning after a loss / after dawn | E5 S6, S7 | ✓ |
| FR13 | One cry, place, cue, call per level | E2 S2, S6, S7 | ✓ |
| FR14 | The tune as a fourth voice | E2 S4; E5 S4, S9 | ◐ (G3) |
| FR15 | Stereo side follows the head | E2 S2 | ✓ |
| FR16 | Rear shadow | E2 S2 | ✓ |
| FR17 | Distance loudness | E2 S3 | ✓ |
| FR18 | Three room sounds | E2 S2 | ✓ |
| FR19 | The four warnings | E2 S4 | ✓ |
| FR20 | Deck cries every 8 s, footsteps | E3 S5 | ✓ |
| FR21 | 4-cry limit | E2 S5 | ✓ |
| FR22 | Warnings come first; tune never cut | E3 S5; E5 (In list, no story named) | ✓ |
| FR23 | 1.5 s spacing; a warning waits | E2 S5 | ✓ |
| FR24 | Skipped deck cries; tune priority | E3 S5; E5 (In list) | ✓ |
| FR25 | Falling cry, at most three | E3 S5 | ✓ |
| FR26 | Ambience level; silence before wave 6 | E2 S5; E5 S2 | ✓ |
| FR27 | Deck hook warning and rattling planks | E3 S2 | ✓ |
| FR28 | Visual cue for every sound | E2 S7; E3 S6; E4 S7, S8 | ◐ (G4) |
| FR29 | Flame leans to the name's section | E5 S3 | ✓ |
| FR30 | Chalk tally per toll | E2 S8 | ✓ |
| FR31 | Three cue modes | E5 S8; E8 S8 | ✓ |
| FR32 | Glow visible from 15 m | E8 S8, S9 (tuned on the muted night) | ✓ |
| FR33 | Span dimensions and counts | E1 S2 | ✓ |
| FR34 | Planks as a count, fixed order | E1 S2 | ✓ |
| FR35 | Strength and load table | E1 S5; E3 (loads from bodies and hooks) | ✓ |
| FR36 | Creak, groan, collapse | E1 S5 | ✓ |
| FR37 | Diver landing counts 5 | E3 S3 | ✓ |
| FR38 | What falls with a section | E1 S5, S6; wound in E4 S10 | ✓ |
| FR39 | Open sections and side beams | E1 S6; E3 S9 | ✓ |
| FR40 | Fallen sections and gaps | E1 S6; E3 S9 | ✓ |
| FR41 | Section 6 rules and exceptions | E1 (floor of 4); E3; E4 | ✓ |
| FR42 | A fall lasts until dawn | E3 S8 | ✓ |
| FR43 | Strip, re-lay, dismantle | E1 S4; E4 S4 | ✓ |
| FR44 | Carried parts, forearm tallies | E1 S4 | ✓ |
| FR45 | Rail locks | E3 S1; E4 | ✓ |
| FR46 | No rail, no hook; deck hooks | E3 S2 | ✓ |
| FR47 | Striking a hook | E4 S6 | ✓ |
| FR48 | Grappler step by step | E3 S1 | ✓ |
| FR49 | Rig placement and working edge | E4 S4 | ✓ |
| FR50 | Trapdoor | E4 S2 | ✓ |
| FR51 | Swing-beam | E4 S3 | ✓ |
| FR52 | Overload with no rig | E1 S5 (emergent) | ✓ |
| FR53 | The wedge | E4 S5 | ✓ |
| FR54 | Three lanterns, poles, start state | E4 S7 | ✓ |
| FR55 | One lantern in hand | E4 S7 | ✓ |
| FR56 | Light reach; the gate's light | E4 S7 | ✓ |
| FR57 | Oil and the flask | E4 S8 | ✓ |
| FR58 | Reading oil | E4 S8 | ✓ |
| FR59 | Shutter | E4 S8 | ✓ |
| FR60 | Hung lantern survives rigs, lost with its section | E4 S7; E1 S5 | ✓ |
| FR61 | Diver's pick by light | E4 S9 (fewest planks rule in E3 S3) | ✓ |
| FR62 | Diver redirected | E4 S9 | ✓ |
| FR63 | Diver's 1 s drop | E3 S3; E4 S9 | ✓ |
| FR64 | Carved name, random section, one of six | E5 S3, S10 | ✓ |
| FR65 | The hum | E5 S3, S9 | ✓ |
| FR66 | Reading the name | E5 S3 | ✓ |
| FR67 | The one who keeps coming back | E5 S4 | ✓ |
| FR68 | Calling the name | E5 S5 | ◐ (G3) |
| FR69 | The stillness | E5 S5 | ✓ |
| FR70 | The wrong ring | E5 S5 | ✓ |
| FR71 | The ally at the town pier | E2 S6; E7 S2 | ✓ |
| FR72 | Call rules by wave | E2 S6; E5 (fade from wave 4) | ✓ |
| FR73 | The ten lines | E5 S10 (written); recording in no story | ◐ (G5) |
| FR74 | Captions | E2 S6 | ✓ |
| FR75 | Knock-down and wound sources | E4 S10 | ✓ |
| FR76 | The wound's cut | E4 S10 | ✓ |
| FR77 | Wound sides | E4 S10 | ✓ |
| FR78 | Night input | E1 S3, S4; E4 S1 to S8 | ✓ |
| FR79 | Context hands | E4 S1 | ✓ |
| FR80 | Planning input | E5 S1 | ✓ |
| FR81 | Hold rules | E1 S4; E4 S10; E5 S8 | ✓ |
| FR82 | Holds: Press once | E8 S8 | ✓ |
| FR83 | Action feedback, no prompts | E4 S1 | ✓ |
| FR84 | The forearm | E1 S4; E5 S3 | ✓ |
| FR85 | Key card | E5 S8 | ✓ |
| FR86 | Physical key positions, printed names | E5 (In list, no story named) | ◐ (G6) |
| FR87 | Pause | E5 S8 | ✓ |
| FR88 | Grappler | E3 S1, S2 | ✓ |
| FR89 | Diver | E3 S3 | ✓ |
| FR90 | Hollow Nester | E3 S4 | ✓ |
| FR91 | Six waves and counts | E5 S2 | ✓ |
| FR92 | The timetable | E5 S2 | ✓ |
| FR93 | The toll | E2 S8; E5 S2 | ✓ |
| FR94 | The five random rolls | E3 S2; E5 S3; no story names the list | ✓ |
| FR95 | Dawn on the clock; dawn wins a tie | E5 S2, S6 | ✓ |
| FR96 | Two ways to lose | E3 S7 | ✓ |
| FR97 | Crossings and windows | E3 S6 | ✓ |
| FR98 | Window sound and flicker | E3 S6 | ✓ |
| FR99 | The moment of loss | E5 S7 | ✓ |
| FR100 | New run, replay state | E5 S7 | ✓ |
| FR101 | Six hints and the cause order | E5 S7, S10 | ✓ |
| FR102 | Repeated cause; hint lifetime | E5 S7 | ✓ |
| FR103 | Ledger contents and order | E5 S6 | ✓ |
| FR104 | Ledger page and its two choices | E5 S6 | ✓ |
| FR105 | Screens in the Lantern light look | E5 S8, S12 | ✓ |
| FR106 | No HUD; centre dot; minimum brightness | E4 S1; E5 S8 | ✓ |
| FR107 | Settings list | E5 S8; E8 S2, S8 | ✓ |
| FR108 | No save; settings and lesson note kept | E5 S8 | ✓ |
| FR109 | Playtest log | E2 S11; E6 S1 | ✓ |
| FR110 | Listening round | E2 S10; E6 S2, S3 | ✓ |
| FR111 | Fairness answerable from logs | **NOT FOUND** | ❌ (G7) |
| FR112 | The early listen | E2 S12 | ✓ |
| FR113 | Gate 2 | E6 S2 to S6 | ✓ |
| FR114 | The muted night | E8 S9 | ✓ |
| FR115 | The look test | E7 S7 | ✓ |

### Missing Requirements

No critical FR is missing. No mechanic lacks a home epic. One FR has no coverage and seven are partial, across six gaps.

**Missing**

- **G7. FR111 / NFR9, the fairness check.** The GDD's technical metric is "in the playtest logs, no threat affects the bridge before its full warning has sounded". Epic 6's log (story 1) lists per-warning turn, heading, section, light and ally call, but not when each threat first acts on the bridge, so the metric cannot be scored from it. The word "fair" appears nowhere in `epics.md`.
  - Impact: "the dark never cheats" is the promise behind pillar 2, and the 4-cry limit, warning queue and stillness rules all exist to keep it. It is the one technical metric with no story.
  - Recommendation: add "arrival time against warning start, per threat" to epic 6 story 1, or cover it with an automated check in epics 2 and 3.
  - **Checked in step 4: the architecture covers it.** The playtest log is one row per `NightEvent` (AD-2), so every warning start and every arrival is in it, and "no threat before its warning" is a bot-night invariant built in epic 3. The gap is in `epics.md` only: no story names the invariant or the gate 2 scoring of the metric.

**Partial**

- **G1. FR2, the left/right check.** Epic 2 story 9 has the stroke, the three answers, ring again and the swap setting. The trigger "two wrong answers offer the swap" and the single-channel warning are not in any epic text. UX-20 is cited, so the detail is reachable.
- **G2. FR10, planning read-outs.** Epic 5 has strength numbers, the tray and the why-not line. "Each rig shows the section it covers and each lantern shows its reach" is not in the epic. UX-15 is cited.
- **G3. FR14 and FR68, the tune as an asset.** The GDD needs the tune in 3 variations, its resolving last phrase and its hum. Epic 2 story 4 plays the tune's warning, and epic 5 story 9 puts "the hum and the tune" in place, but no story sources or makes the tune, and the resolving phrase and the variations are named nowhere. The tune is first needed in epic 2, three epics before the story that supplies it. GDD assumption 6 says free libraries may not hold it.
- **G4. FR28, two cues with no base story.** (a) "The tune's rail ropes sway in time with it": the word "sway" is not in `epics.md`. (b) "A section's creak shows as bowing planks": bowing planks appear only in epic 8, as the glow-in-the-dark extra; no earlier story draws the base cue. Epic 1 story 5 covers the creak as a sound only.
- **G5. FR73, the ally's recorded lines.** Epic 5 story 10 writes the lines. Recording them is listed under "Needs" in epics 2 and 6 and is a GDD dependency ("a person to record"), but no story owns finding the person, recording, editing and loudness-matching. Two specific uses also have no epic text: the two warmth lines spoken in a lull, and the line for the first return of the one who keeps coming back.
- **G6. FR86, keys by physical position.** It is in epic 5's In list, in no story title, and the "named as the player's keyboard prints them" half is absent. Input is bound from epic 1 story 3 onward, four epics earlier.

**Details that rest on a cited decision ID only**

These are in the GDD, are not restated in `epics.md`, and are reachable only because the epic cites the GDD section or decision. They are not gaps today; they become gaps if story files are written from `epics.md` alone.

- FR39: whoever stands on a section when its last plank is taken is on its side beams from that moment.
- FR49: a blow struck from the rig's own section still springs it.
- FR72: one ally call at a time; a call that cannot start within 4 s of when it was due is dropped.
- FR77: both sides can be wounded at once; a second wound restarts the 20 s without growing the cut.
- FR88: a Grappler never takes the same rail twice running unless only one is free.
- FR89: a Diver recovers for 2 s after landing.
- FR99: at the moment of loss the cries cut to wind.
- FR103: the ledger's first four lines (sections, windows, parts left, wounds).
- FR108: settings and the lesson-finished note persist between launches.

**In epics but not in the GDD**

- Epic 1 story 1 (setup beside the ear test, a way to start in a chosen situation) comes from the architecture (AD-54, AD-56, GD-63), not from a GDD mechanic. Correctly attributed.
- Epic 5: the title's four entries (Begin the watch, Settings, Credits, Quit) and the pause screen's five entries come from UX, not the GDD. Correctly attributed.
- Epic 8: the itch.io follow button and a first devlog post. Not in the GDD; small.
- Decision IDs prefixed IN- (IN-10, IN-19, IN-20) are cited in epics 2, 6 and 7. The GDD's reading guide explains GD-n, UX-n and brainstorm IDs but not IN-n.

**NFR coverage (noted here, assessed in later steps)**

- NFR1 to NFR3 (frame rate) are measured only in epic 7 story 6, after gate 2, and again in epic 8 with the extras on. No earlier story measures the gray-box night at wave 6's peak.
- NFR17 (no flash, no shake, flicker limit, no camera bob) appears in no epic text.
- NFR25 (hours logged from epic 1) is stated in the preamble and owned by no story.

### Coverage Statistics

- Total GDD FRs: 115
- Fully covered: 107
- Partially covered: 7 FRs across 6 gaps (FR2, FR10, FR14, FR28, FR68, FR73, FR86)
- Missing: 1 (FR111)
- Coverage: 107 of 115 fully covered (93.0%); 114 of 115 with a home epic (99.1%)

## UX Alignment Assessment

### UX Document Status

**Found.** `ux-designs/ux-3d_game-2026-11-19/` holds `DESIGN.md` (how screens look, status final) and `EXPERIENCE.md` (how surfaces behave, status final), a decision log (UX-1 to UX-41), two mock files, two review files and a validation report. Both were read in full, together with `game-architecture.md` (AD-1 to AD-68, all 1,118 lines) and `deferred-work.md`.

### UX ↔ GDD alignment

**In step.** The GDD's draft 0.6 took in the UX decisions (GD-48 to GD-55), and the UX log records three wording changes made to stay in step with draft 0.7. Checked point by point and found matching: the three cue modes table; the settings list (16 settings, same four groups); the key map additions (E, F, 1, 2, R, Tab, Space hold, J, Esc); the ledger's seven lines and their order; the lost-night and repeated-cause behaviour; the lesson's steps; the comfort limits; the wound; the stillness and wrong ring as the four key flows show them.

**Differences found**

| # | Where | What differs | Weight |
|---|---|---|---|
| U1 | `EXPERIENCE.md`, Assumptions and open items | Still lists as [OPEN]: "The playtest build's listening round needs its own instruction screen; not designed here." The GDD and epic 6 story 2 settle it: the instruction is read aloud from the session script. The open marker is stale. | Low |
| U2 | Both UX files, frontmatter | `updated: 2026-11-19`, but `EXPERIENCE.md` was edited on 2026-11-20 for GDD draft 0.7. `DESIGN.md` was not touched by the 0.7 write-back; nothing in GD-56 to GD-67 changes how a screen looks, so it is not out of step. | Low |
| U3 | `EXPERIENCE.md`, Component Patterns and State Patterns | UX rules the GDD and `epics.md` do not restate, so a story written from the epics alone will miss them: at least 0.3 s between two captions; any key completes the ledger page; a ledger line every 1.5 s; no input but look while knocked down, hanging or crossing a gap; "Best with headphones." after choosing Speakers; one line under the Visual cues choice saying what it changes; the brightness slider's "barely visible" mark; the key card's fourth group, Signs; pause reachable from the lesson, planning, the night and dawn. | Medium |
| U4 | `EXPERIENCE.md`, menu-item and two-choice | Menu keys (Up/Down, W/S, Enter, Space; A/D and arrows on two-choice screens; R to ring again) are UX-only. The GDD's Controls tables do not list them. See A3. | Low |
| U5 | `DESIGN.md`, Do's and Don'ts against hold-control | "Don't draw a box, bar … or progress ring anywhere" sits beside hold-control's "warm rule grows under it from left to right". The rule is a progress bar in all but name. The intent is clear (no bars at night; this is planning), but an agent reading the Don't literally may refuse to build it. | Low |
| U6 | UX validation report; DW-5 | 30 review findings are "not addressed" and 15 "partly addressed" (0 critical; of 9 high, some partly addressed). DW-5 assigns them to a gds-ux Update run before epic 2's stories are created. Still open. Those that touch epic 4 and 5 stories directly: no ready pose stated for E and no rule for F; no table of flame movements; hold cancel at 0.5 m has no grace; slider steps and ranges unstated; wound darkening's extent and its drawing order against the caption unstated. | Medium |
| U7 | DW-6 | The flame as the only direction-finder by sight (carry height, minimum lean) is deferred to epic 7 story 4. `epics.md` epic 7 story 4 does not mention it. | Low |

### UX ↔ Architecture alignment

**Supported.** Every surface in the UX information architecture has a named home: `watch/screens/` lists title, first-launch, sound check, pause, key card, journal, ledger, lost night, settings and credits; planning has its own folder; the caption, centre dot and caption size sit on the caption layer; brightness and field of view are applied by the night screen. The no-HUD rule is structural: hands are drawn from `HandsState`, cues from sim state through `CueRules` and the sound-and-cue table, and the comfort limits are listed as binding technical requirements. Hold-to-commit in planning uses a tickable `hold_timer`. Physical key positions and printed key names are AD-20. Mono and swap are AD-18. Settings persistence is AD-21. The 3 s replay and 0.3 s rig reaction follow from AD-4, AD-25 and the 60 Hz tick.

**Gaps found**

| # | What | Detail | Weight |
|---|---|---|---|
| A1 | **Canvas size has no decision.** | `EXPERIENCE.md` and `DESIGN.md` specify every size on a 1920×1080 canvas with `canvas_items` stretch. `game/project.godot` today is 1280×720, `canvas_items`, aspect `expand`, and it is shared with the closed ear test, whose behaviour may not change. The architecture never mentions the viewport size or stretch. The first text on screen is epic 1 story 7 (strength numbers) and epic 2 story 6 (the caption). Without a decision an agent will either change the ear test's viewport or build every token at the wrong scale. | **High** |
| A2 | **Screen effects have no pattern.** | The Lantern light look needs a soft glow on the chosen item, a solid-plus-soft halo on text over 3D, lines that write in left to right, a hold rule that fills and drains, and the frozen view dimmed to 15% under pause. The architecture says "Control nodes, Theme, bundled font" and names `watch_theme`, and gives no technique for any of these. Agents work headless and cannot see the result. Epic 5 story 12 carries all of it in one line. | Medium |
| A3 | **Menu input actions.** | The architecture hands "the full table of input actions" to epic 1's setup story and says "it follows the GDD's Controls tables one to one". The menu and two-choice keys are in `EXPERIENCE.md` only (U4), so that table would be built without them. | Low |
| A4 | **Pause before epic 5.** | `EXPERIENCE.md` makes pause reachable from the lesson, and AD-51 says losing focus pauses the lesson. The built-when table puts the pause overlay and focus loss in epic 5. The early listen at the end of epic 2 puts the lesson in front of newcomers three epics earlier, with no pause. | Low |
| A5 | **Pause at dawn and in planning.** | AD-67 describes pause as an overlay on the night screen and the lesson screen. UX also pauses planning and dawn. Planning is implied by `hold_timer` ("so a pause freezes them"); dawn is not mentioned. | Low |
| A6 | **Skip-the-lesson and leave questions.** | Neither has a named screen in `watch/screens/`. They are menu-item screens and can live in `first_launch_screen` and `pause_screen`; nothing says so. | Low |

### Architecture ↔ Epics (found while reading; assessed further in step 5)

The architecture's "Built when" table assigns infrastructure to epics. Several entries have no story in `epics.md` and no hours:

| # | Epic | Architecture builds | In `epics.md` |
|---|---|---|---|
| B1 | 1 | The Press once rule ("their rules exist from epics 1, 2 and 2") | Press once appears only in epic 8 story 8 |
| B2 | 1 | `InputActions`: physical keys and printed names (setup story) | Listed under epic 5's In list |
| B3 | 2 | The mono-and-swap measurement test (AD-18, unproven); `build_info`; two playtest export presets; `WatchSettings` saved to disk; the playtest log and `--log` | Story 9 has "a setting to swap the sides"; story 11 logs warnings; none names the measurement test, the presets or the saved settings. "The playtest log" is epic 6 story 1 |
| B4 | 3 | The no-threat-before-its-warning invariant | Not named (see G7) |
| B5 | 5 | The pause overlay with focus loss; the renderer check (AD-57); `--wave` and `--plan`; the 20-night test | Pause is in story 8; the other three are not named. The 20-night run appears only in epic 8 story 1 |
| B6 | 6 | Night recording, replay and checksums (AD-37); the F3 overlay and `--debug`; frame times and refusal counts in the night summary; the log-folder entry on the title; `--def` | None named. Epic 6 story 1 is "The playtest log", in an epic sized 20 to 40 h that also holds five sessions, scoring and tuning |
| B7 | Every story | A scripted bot path (AD-63), a show-me setup (AD-56) and a manual-check list | The GDD says this cost is in epic 1's hours only (DW-18, open) |

### DW-19: the architecture's second round of fixes

`deferred-work.md` assigns DW-19 to this check: the second validation round's fixes "had mechanical checks only". The document was read in full here with that in mind. Checked and found consistent: the counts it states about itself (20 systems, 68 decisions, 18 consistency rules of which 15 are enforced, 7 scripts in `watch/core/`); two smoke runs in the setup story growing to three in epic 1; AD-7's warning queue against the tick order (the slot is asked for at step 5, deck cries at step 12); the stillness against GD-61 and GD-64; the wound against GD-62 and GD-66; dawn winning a tie against GD-59 and GD-67; pause freezing a hold against the GDD.

No contradiction that would make two agents write code that does not fit was found. Three small things:

- `sim/night_ticks.gd` and `StartState` are used throughout and are missing from the directory tree's list of sim files.
- An event's `t` is "measured from the first toll", which is undefined for a lesson or a listening round, and for the ticks between the night's start and the first stroke.
- The pause sections describe the night and lesson only (A5).

**DW-19 can be closed** with those three noted.

### Warnings

1. **A1 needs a decision before epic 1 story 7.** It is the only alignment finding that changes how the first stories are written.
2. **U6 / DW-5 is owed before epic 2's stories**, by its own owner line. It does not block epic 1.
3. **The UX was reviewed on paper only.** Nothing has been played. The GDD says so; it is restated here because the hands (GDD assumption 9) are the whole night interface and are first tested at gate 2, after about 265 to 400 hours.

## Epic Quality Review

Reviewed: the 8 epics and 72 stories of `epics.md` against the create-epics-and-stories standard (player value, independence, no forward dependencies, story sizing, acceptance criteria, traceability).

### What the breakdown does well

- **Every epic ends in something playable**, stated in its own "Playable at the end" line. None is a pure technical layer.
- **Dependencies run forward only.** The sequence table names what each epic depends on, and no epic needs a later one in order to work. Staged rules are named where they split (a Diver picks by fewest planks in epic 3 and by light from epic 4; a wound cancels a hold from epic 4; a pause freezes one from epic 5).
- **Each epic has In, Out and Needs lists**, so its edge is explicit.
- **Brownfield handled.** Epic 1 story 1 is the integration story the standard asks for: the game beside the unchanged ear test, with the checks that keep the ear test whole.
- **Risk first.** The two riskiest things (the bridge as a system, play by ear) are epics 1 and 2, and epic 2 ends by putting the game in front of people.
- **Rules and structures arrive when needed.** The architecture's built-when table stages every system by epic; nothing is created "all up front" except the simulation's skeleton, which the architecture names as a known front-loading risk.

### Compliance by epic

| Epic | Player value | Independent | Stories sized | No forward dependency | Built when needed | Acceptance criteria | Traceable |
|---|---|---|---|---|---|---|---|
| 1 The span | ✓ | ✓ | ✓ | ✓ | ✓ | ❌ | Epic level |
| 2 The ear | ✓ | ✓ | ✓ | ◐ (Q4) | ✓ | ❌ | Epic level |
| 3 The dead | ✓ | ✓ | ✓ | ✓ | ✓ | ❌ | Epic level |
| 4 Rigs and hands | ✓ | ✓ | ◐ story 1 | ✓ | ✓ | ❌ | Epic level |
| 5 The night | ✓ | ✓ | ❌ (Q2) | ◐ (Q3) | ✓ | ❌ | Epic level |
| 6 Gate 2 | ◐ (Q9) | ✓ | ❌ (Q6) | ✓ | n/a | ❌ | Epic level |
| 7 The look | ✓ | ✓ | ✓ | ✓ | ✓ | ❌ | Epic level |
| 8 Going public | ✓ | ✓ | ◐ (Q14) | ✓ | ✓ | ❌ | Epic level |

### 🔴 Critical

**Q1. No story has acceptance criteria.** All 72 stories are one line each ("Sections have strength, take load, creak, groan and collapse."). There is no Given/When/Then, no error case, no measurable outcome at story level. The detail lives one level up, in each epic's In list, and two levels up, in the GDD.

- Cause: `epics.md` is the GDD workflow's companion file. `gds-create-epics-and-stories`, which writes stories with acceptance criteria, has not been run. DW-18 says so ("Still owed: the story files").
- Why it matters here more than usual: the architecture has agents building headless, and it makes each story carry a failing test with the GDD's numbers written out, a bot path, a show-me setup and a manual-check list. An agent cannot write those from a one-line story without re-deriving scope from the GDD each time, and two agents will draw the line between neighbouring stories differently. The nine "details that rest on a cited decision ID only" (step 3) and the UX-only rules (U3) are exactly what gets lost.
- Remedy: run `gds-create-epics-and-stories` over `epics.md`, at least for epics 1 and 2, before sprint planning. Each story should cite the FR numbers of this report or the GD-n / UX-n it delivers.

### 🟠 Major

**Q2. Epic 5 is overloaded, and two of its stories are epic-sized.** In 65 to 90 hours it holds the planning view, the six-wave timetable, the name, the one who keeps coming back, calling the name, dawn and the ledger, losing and the journal, about ten screens, thirteen settings, about 35 sounds, all the text, the hands-on lesson and the whole screen look. Compare epic 1: 40 to 65 hours for seven stories about one system.

- Story 8 is "Title, sound-output question, pause, key card, settings and lesson skip": six surfaces and the settings list in one story.
- Story 9 is "All remaining sounds in place": sourcing, cutting, crediting and wiring roughly 35 sounds.
- Remedy: split epic 5 in two, the night's rules (stories 1 to 7) and the sitting around it (screens, settings, content, lesson, look), and break stories 8 and 9 up.

**Q3. Story order inside epic 5 runs backward.** Story 3 (the name), story 6 (the ledger's epitaph) and story 7 (the six hints) need the text that story 10 writes. Stories 1, 6, 7 and 8 build screens whose look is story 12. Content and theme come last and are needed first.

**Q4. Two things are needed epics before the story that supplies them.**

- The tune. Epic 2 story 4 plays its warning; epic 5 story 9 puts "the hum and the tune" in place; no story sources it (G3). Stand-ins are allowed for the ally's lines "until epic 6"; nothing says so for the tune.
- The screen theme and typeface. Epic 1 story 7 draws strength numbers and epic 2 story 6 draws the caption that newcomers read at the early listen; the Lantern light look is epic 5 story 12. With A1 undecided, those early screens have no size to be built at.

**Q5. Architecture work with no story and no hours (B1 to B7).** The clearest case is epic 6: night recording, replay and checksums, the debug overlay, frame times and refusal counts are assigned to an epic of 20 to 40 hours whose six stories do not mention them. The GDD states that only epic 1 was re-guessed for the architecture and that the per-story test path and show-me setup are not in the sizes of epics 2 to 5. The estimate is already 25 hours over the brief's ceiling before this is added.

**Q6. Epic 6 stories 5 and 6 cannot be sized or accepted.** Story 5 is "Starting values tuned from what the sessions showed", with no limit and no exit. Story 6 is "A failed check is fixed and the gate re-run; fallbacks chosen if the ear re-check fails": conditional, and unbounded if it happens (the fallbacks include an HRTF plugin trial and "Plan B, where the lantern scouts", which is a redesign). These are contingencies, not stories.

- Remedy: give story 5 a time box and a list of what may be tuned; move story 6 out of the story list into a named contingency with a correct-course trigger.

**Q7. Stories only a person can do are not marked, and what they wait on has no date.** Epic 2 story 12, epic 6 story 3, epic 7 story 7, epic 8 stories 5, 6 and 9 are sessions, checks or publishing that Sonlm runs. The ledger's open, high-severity items behind them:

| Item | Needed by | Status |
|---|---|---|
| DW-11: original Freesound downloads of the 11 recordings | Epic 2 story 1, the first story of epic 2 | Open, no date |
| DW-10: two or three newcomers; then five more | End of epic 2; epic 6 | Open, nobody lined up |
| DW-9: a person to record the ally's lines | Epic 6 (stand-ins until then) | Open, to start during epic 1 |
| DW-12: a GTX 1050-class machine and an Iris Xe machine | Epic 7 | Open |

**Q8. Frame rate is first measured after gate 2.** NFR1 to NFR3 are measured in epic 7 story 6, after 265 to 400 hours, on machines not yet in hand. The architecture softens this (the dead are positions on a line with no physics; frame times go into every night's summary row from epic 6), but nothing measures the gray-box night at wave 6's peak before the gate's testers do.

- Remedy: one check in epic 5, on any machine: a wave 6 night with frame times logged, to catch a structural cost before art is added.

### 🟡 Minor

- **Q9.** Epic 6 is a validation milestone, not a player-value epic. For a playtest gate this is normal practice and is accepted. Epic 1 story 1 and epic 2 story 1 are technical stories; both are the brownfield setup the standard expects.
- **Q10.** Two entries in epic 5 have nothing behind them until later: the Fog quality setting (fog is epic 7) and the title's Credits entry (credits are epic 8 story 4).
- **Q11.** Traceability is per epic ("Delivers"), not per story.
- **Q12.** Decision IDs prefixed IN- are cited in epics 2, 6 and 7 and are explained nowhere in the GDD's reading guide.
- **Q13.** Sizes do not say whose hours they are. The architecture has agents building and names Sonlm's 5 to 10 hours a week of review as the scarcest resource, with agents able to "finish stories faster than their look, sound and feel can be checked". A 40 to 65 hour epic means different things under each reading.
- **Q14.** Epic 8 story 8 bundles three unrelated features (the Cues everywhere extras, Press once, Mono sound); story 1 bundles six checks.
- **Q15.** The dusk lesson is built in two halves, epics 2 and 5. The early listen therefore tries half a lesson. This is deliberate and stated; it means the first whole-lesson test is gate 2.

## Summary and Recommendations

### Overall Readiness Status

**NEEDS WORK.**

The design, UX and architecture are ready. They are detailed, cite each other by decision ID, and agree: the UX and the GDD match point for point, and a full read of the architecture found nothing that would make two agents write code that does not fit. Coverage is sound: 107 of 115 requirements are fully placed in an epic and 114 have a home.

What is not ready is the layer the build starts from. The stories are titles. Between "epics" and "implementation" one workflow step has not been run, and a handful of decisions and schedule mismatches should be settled while it is.

Nothing found requires redesign. Everything below can be fixed in the documents.

### Critical Issues Requiring Immediate Action

1. **Stories have no acceptance criteria (Q1).** 72 one-line stories. `gds-create-epics-and-stories` has not been run (DW-18).
2. **The screen canvas size is undecided (A1).** UX specifies 1920×1080; the shared `project.godot` is 1280×720 and belongs to the closed ear test as well. The first on-screen text is epic 1 story 7.
3. **The architecture's work is not in the stories or the hours (B1 to B7, Q5).** Press once and input actions are scheduled in different epics by the two documents; epic 6's recording and replay tooling has no story.

### Recommended Next Steps

Before epic 1 starts:

1. Decide A1: keep 1280×720 and scale the design tokens by two thirds, or move the game to 1920×1080 with an `.eartest` override that keeps the ear test's viewport. Record it as an architecture decision.
2. Run `gds-create-epics-and-stories` for epics 1 and 2, writing acceptance criteria that cite FR or decision IDs. While there: fold in B1, B2 and B3; name the fairness invariant (G7, B4); add the menu keys to the input table (A3); give the tune a stand-in rule or a sourcing story (G3, Q4); add a minimal theme and typeface where the first screen text appears (Q4).
3. Start the three errands that have lead time: the original Freesound downloads (DW-11, blocks epic 2's first story), newcomers for the early listen (DW-10), and a voice for the ally (DW-9).
4. Close DW-19 in the ledger (done by this report).

Before epic 2's stories are created:

5. Run the gds-ux Update that DW-5 already owes: the 30 unaddressed review findings, the stale open item (U1), the Don't that contradicts hold-control (U5), and a pattern for the screen effects (A2).
6. Re-guess the sizes of epics 2 to 5 with the per-story test path and show-me setup included, once epic 1's logged hours give a rate (DW-18). Say whose hours the sizes count (Q13).

Before epic 5:

7. Split epic 5 and reorder it so text and theme come first (Q2, Q3). Add the gray-box frame-time check (Q8) and the missing cue stories: bowing planks and the tune's swaying ropes (G4).
8. Turn epic 6 stories 5 and 6 into a time-boxed tuning story and a named contingency (Q6). Give its tooling (B6) a story and hours.

Standing risk, not fixable on paper: play by ear is unproven for newcomers until the early listen, about 95 to 140 hours in, and the hands-only interface until gate 2. The plan already puts both as early as their dependencies allow.

### Findings by category

| Category | Count | Critical | Major or high | Medium | Low or minor |
|---|---|---|---|---|---|
| Requirement coverage (G1 to G7) | 7 | 0 | 0 | 3 (G3, G5, G7) | 4 |
| UX ↔ GDD (U1 to U7) | 7 | 0 | 0 | 2 (U3, U6) | 5 |
| UX ↔ Architecture (A1 to A6) | 6 | 0 | 1 (A1) | 1 (A2) | 4 |
| Architecture ↔ Epics (B1 to B7) | 7 | 0 | 2 (B6, B7) | 3 (B1, B3, B5) | 2 |
| Epic quality (Q1 to Q15) | 15 | 1 (Q1) | 7 (Q2 to Q8) | 0 | 7 |
| **Total** | **42** | **1** | **10** | **9** | **22** |

Some findings are the same gap seen from two sides (G6 and B2; G7 and B4; G3 and Q4; B7 and Q5).

### Final Note

This assessment identified 42 findings across 5 categories: 1 critical, 10 major. Address the critical issue and the canvas decision before proceeding to implementation; the rest can be taken up at the points named above. These findings can be used to improve the artifacts, or Sonlm may choose to proceed as-is.

Assessed 2026-11-20 against GDD draft 0.7, `epics.md` draft 0.7, `DESIGN.md` and `EXPERIENCE.md` (final), and `game-architecture.md` version 1.0.

## Actions Taken After the Assessment (2026-11-20)

Sonlm asked for the "needed now" and "optional" items to be done as recommended. The assessment above is left as it was written; this section records what has changed since. The status of the planning set after these actions: **epic 1 can start**. Epics 2 to 8 still need their stories written in full before each starts.

| Finding | Action | Where |
|---|---|---|
| A1 canvas size | Decided: the canvas stays 1280×720 and the theme holds two thirds of each `DESIGN.md` token | Architecture AD-69; both UX spines; `project-context.md` |
| A3, U4 menu keys | In the one input table, as `watch_menu_*` actions | Architecture AD-70; story 1.1 |
| Q1 no acceptance criteria | Epic 1's seven stories written in full, Given/When/Then, with the GDD's numbers in seconds and ticks, a manual check each, and the decisions each delivers | `epics.md` draft 0.8, "Epic 1: story detail" |
| B1 Press once rule | In story 1.4; its setting stays in epic 8 | `epics.md` |
| B2, G6 physical keys | In story 1.1; epic 5 keeps only the printed names on the key card | `epics.md` |
| Q4 typeface before epic 5 | Bundled, with a first theme, in story 1.7 | `epics.md` |
| U1 stale open item | Closed | `EXPERIENCE.md` |
| U2 `updated` dates | Set to 2026-11-20 | Both UX spines |
| U5 "no bars" against hold-control | The Don't names the exception | `DESIGN.md` |
| Q10 Fog quality, Credits | Fog quality moves to epic 7; Credits opens a licence page from epic 5 | `epics.md` |
| Q11 traceability | Every story line of epics 2 to 8 names its GDD section and decisions | `epics.md` |
| Q12 IN-n IDs | Explained | `gdd.md` reading guide; `epics.md` |
| Q14 bundled stories | Epic 8's stories 1 and 8 split; 9 stories became 14 | `epics.md` |
| DW-19 notes | `night_ticks` and `start_state` in the tree; what `t` counts from; planning and dawn in the pause rules | Architecture |

Two of these were choices made while writing, beyond what the findings asked:

- The architecture now says tick 0 of a night is the first stroke of the first toll. It read "measured from the first toll" before, without saying where tick 0 was.
- Menus use their own `watch_menu_*` actions and do not rely on Godot's built-in `ui_*` navigation (AD-70).

Story 1.6 needed two rules the GDD did not give. Sonlm chose them from options the same day: the warden finishes a crossing begun by stripping the plank underfoot toward the town (GD-68), and a section with no planks can be re-laid (GD-69).

Still open, each with an owner in `deferred-work.md`: DW-5 (the UX update), DW-9 to DW-12 (the voice, the newcomers, the Freesound originals, the two machines), DW-18 (stories for epics 2 to 8; re-guessing sizes), DW-20 to DW-23 (epic 2's additions; screen effects; epic 5; epic 6). Not taken up and not in the ledger: A4 to A6, B5, Q13, Q15, U3, U7 and G1, G2, G5; they are to be read when the stories of the epic they touch are written.
