# GDD extract for UX: The Mourning Watch (one-night game)

Extracted 2026-11-19 from `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/`:
`decision-log.md` (281 lines, read in full), `gdd.md` draft 0.5 (891 lines, read in full), `epics.md` draft 0.5 (361 lines, read in full), and the UI/input/audio/accessibility passages of `source-extracts/brief.md`, `brainstorm.md`, `ear-test.md`.

Rules of this extract: nothing here is a design proposal. Where the documents are silent it says NOT SPECIFIED. Line numbers are `gdd.md` unless another file is named. The decision log overrides `gdd.md` where they differ; draft 0.5 of `gdd.md` already applies the log through GD-47.

## A. Summary

The Mourning Watch (working title) is a free, single-player tower defense game with horror sections for PC (Windows first, Linux alongside, itch.io "$0 or donate"), built in Godot 4.7.2 (Forward+), "played up close and by ear". The player is the warden, an unarmed engineer holding a bridge over an abyss "where nothing stays dead, except on the bridge". Core loop: plan from above (strip the bridge for parts, place rigs and lanterns), then stand on the deck in first person at night and "hear, rig, hold, salvage" through six waves until dawn, when a ledger "counts the cost". The scope specified in full is the **one-night game**: one sitting of about 20 minutes (dusk lesson 2 min, planning about 4 min untimed, night 12 min, dawn 2 min), one span of 6 sections, three kinds of dead (below/above/inside), two rigs, one ally, the bell, one name; no save. The Fog Season (2 to 3 hours) is outlined only; later seasons are out of scope. Audience: day/night strategy players aged 16+ who like *Thronefall*, *Dome Keeper*, *Kingdom Two Crowns*; secondary story players, then atmosphere/horror players ("headphones in the dark"); streamers and free-game hunters are the channel ("decide in the first minute", so the first cry sounds inside the first minute). Stakes: a solo project (Sonlm), 5 to 10 hours a week, $0 budget, all assets sourced under licences that allow commercial use, AI use disclosed, nothing AI-voiced; revenue, Steam and Mac are explicitly not goals; estimated 290 to 460 hours. The documents never use the words jam, hobby, indie or commercial; "free, solo, $0, no revenue goal, public itch.io release gated on a five-person playtest (gate 2)" is what is stated. (gdd.md 30-66, 70-83, 142-149, 766)

## B. Verbatim sections

Each block below is copied unchanged from `gdd.md` by line range.

Note on naming: the request called Game Mechanics 7 "the forearm". In `gdd.md` mechanic 7 is headed "The bell and the name"; it is where the name is "inked on the warden's forearm". The forearm's other mentions are collected after the blocks.

### B1. Controls and Input (GDD heading: "### Controls and Input")

Source: `gdd.md` lines 392-426, verbatim.

~~~markdown
### Controls and Input

Keyboard and mouse only in the one-night game. Gamepad arrives with the Fog Season. (GD-22)

**Context hands.** The left mouse button is the hammer hand and the right is the lantern and rope hand. The game picks the action from what the warden is looking at within 2 m, and the hands show that action before the click.

Night, first person:

| Input | Action |
|---|---|
| W A S D | Walk at 3.5 m/s. No sprint, no jump. |
| Mouse | Look |
| Left mouse (hammer hand) | Strike a pin, a holding rope or a hook (0.5 s); strip a plank (hold 2 s); hammer a wedge (hold 3 s) |
| Right mouse (rope and lantern hand) | Strip a rail rope (hold 3 s); haul a trapdoor (hold 6 s); re-hang a beam (hold 10 s); pull the bell rope (1 s) |
| E | Hang or take down a lantern; re-lay a plank (hold 3 s); refill a lantern (hold 4 s) |
| F | Open or close a shutter: the carried lantern's, or that of a hung lantern within 2 m |
| 1 (hold 8 s) | Build a trapdoor on the section ahead |
| 2 (hold 12 s) | Build a swing-beam on the section ahead |
| R (hold 4 s) | Dismantle the rig ahead |
| Tab (hold) | Raise the forearm: the name, if read, and the tallies of planks and ropes in hand |
| Esc | Pause and settings |

"The section ahead" is the one whose town-side edge the warden stands at.

Planning, from above:

| Input | Action |
|---|---|
| Left click on a plank or rail | Strip it |
| Left click on a section, with a rig or lantern chosen | Place it there |
| Right click | Undo the last choice on that section |
| 1, 2, 3 | Choose trapdoor, swing-beam, lantern |
| Space | Ring the bell: start the night |

Held actions are cancelled by moving more than 0.5 m or by a wound.
~~~

### B2. Game Mechanics 1, Listening, including the visual-cue table (GDD heading: "#### 1. Listening")

Source: `gdd.md` lines 192-244, verbatim.

~~~markdown
#### 1. Listening

**Level.** Each level has one kind of cry, one kind of place, one visual cue and one call from the ally. A kind of cry never appears at another level.

| Level | Cry | Arrives at | The bridge shows | Ally calls |
|---|---|---|---|---|
| Below | Whispers | The left or right rail | That rail's ropes shake | "Below!" |
| Above | Shrieks | The open deck | The fog overhead swirls | "Above!" |
| Inside | Sobbing | A pier | Dust falls from that pier's stones | "In the walls!" |

**One named exception.** The one who keeps coming back sings a low, wordless tune where a Grappler would whisper. The tune is a fourth voice on the level below, at the same kind of place. The ear re-check covers it.

**Direction and distance.**

- **Side** comes from stereo placement that follows the warden's head as it turns. (Measured.)
- **Behind is duller.** A cry straight behind the warden has its treble above 2 kHz cut by up to 10 dB and is up to 2 dB quieter; at the side it is half of each. It brightens as the warden turns to face it. (Measured.)
- **Equal at equal distance.** Any two cries at the same distance play within 1 LU of each other, measured straight ahead before the rear shadow. Loudness therefore never gives away level. This is re-measured whenever a clip or a sound setting changes. (Measured.)
- **Farther is quieter** (GD-40). Each section of distance along the span, 5 m, takes off 3 dB, up to 15 dB. This is how the warden hears how far. The step is wider than the rear shadow's 2 dB, so "far" and "behind" do not sound alike. (Not measured: the ear test had no distance.)
- **Room sound is atmosphere, not a cue.** Above is thin and open, inside is muffled and boxed in, below has a long cave echo.

**Warnings.** Every threat warns before it can affect the bridge. Each warning is built from whole 4.3 s clips.

| Threat | Warning | Made of |
|---|---|---|
| Grappler | 6 s | One whisper, then 1.7 s of straining rope |
| Diver | 8 s | Two shrieks, the second starting 3.7 s after the first |
| Nest | 40 s | Seven sobs, the gaps between them closing from about 4 s to none. The sobs quicken; they do not get louder. |
| The one who keeps coming back | 6 s | One phrase of the tune, then 1.7 s of straining rope |

A warning sounds from where the threat will arrive: under the chosen rail, over the chosen section, inside the pier.

**During the night.**

- On the deck each of the dead repeats its own cry every 8 s and adds footsteps on the planks.
- Never more than 4 cries at once. Two warnings never start within 1.5 s of each other. When the limit is reached, cries from the dead already on the deck are dropped first and their footsteps remain.
- Anything that falls lets out a cry that fades into the dark over 2 s. "That sound is the payoff for a perfectly sprung trap" (brainstorm #14). It does not count toward the limit.
- Ambience (creaks, wind, the town bell) sits at least 6 dB under the quietest a cry can be, which is far and behind: 23 dB under a near one. There is no music.

**Every sound has a visual cue.** The brief promises this. Cues show inside lantern light (GD-9). The three level cues extend the brainstorm's G11; the leaning flame is G11 itself.

| Sound | Visual cue |
|---|---|
| A cry's level | The table above: shaking ropes, swirling fog, falling dust |
| A cry's side | A lit lantern's flame leans toward the nearest cry sounding inside its own light |
| The hum over the carved name | The carried lantern's flame leans toward that section within 3 m |
| The tune of the one who keeps coming back | Its rail's ropes sway in time with it |
| Footsteps, a hook landing, a fall | The event itself, seen in the light |
| A section's creak and groan | Its planks bow |
| A toll of the town bell | The ally chalks one tally on the board at the town pier |
| The ally's calls | Text on screen |
| A wounded ear | The view darkens on that side |

In the dark there are no visual cues. The safety net there is the ally's call, and the "cues everywhere" setting.
~~~

### B3. Game Mechanics 7, The bell and the name (GDD heading: "#### 7. The bell and the name")

Source: `gdd.md` lines 346-355, verbatim.

~~~markdown
#### 7. The bell and the name

(GD-14, GD-25)

- One section, chosen at random from sections 2 to 5 each run, has a name carved in the timber under its planks.
- The hum, 12 dB under a cry, can be heard within 3 m of that section whenever no cry is sounding. It is the tune of the one who keeps coming back, which is how the player connects the two.
- The name is uncovered when that section is down to 4 planks or fewer. It can only be read on foot, at night, by lantern light: the planning view never shows what lies under the planks. Once read, it is inked on the warden's forearm.
- **The one who keeps coming back** arrives once per wave from wave 2. It behaves as a Grappler but sings the tune. Whether it falls or crosses, it is back in the next wave.
- **Calling the name:** one pull of the bell rope at the town pier (1 s), after the name has been read, while its owner is on or under the span. The owner stops and passes in peace, and never returns. Every other one of the dead on the span stands still for 20 s. The ledger records one name learned and one soul released.
- **A wrong ring** (GD-42). A pull that calls no one, because the name is unread or the owner is absent, is only noise. Every one of the dead on the span walks half again as fast for 10 s.
~~~

### B4. Game Mechanics 10, Planning from above (GDD heading: "#### 10. Planning from above")

Source: `gdd.md` lines 383-390, verbatim.

~~~markdown
#### 10. Planning from above

(GD-11)

- An overhead view of the whole span, with no dead and no time limit.
- The warden strips planks and rail ropes, places trapdoors and swing-beams on sections 1 to 5, and hangs the two placed lanterns. Every choice can be undone until the night starts.
- The view shows each section's planks, rails and strength directly. It does not show what lies under the planks, and it does not use the woodcut look.
- Ringing the bell ends planning and starts the night.
~~~

### B5. Win/Loss Conditions, including the dawn ledger (GDD heading: "### Win/Loss Conditions")

Source: `gdd.md` lines 162-184, verbatim.

~~~markdown
### Win/Loss Conditions

- **Dawn** comes on the clock, 12 minutes after the first toll. Any of the dead still on the span sink back below and do not count as crossings. There is no victory screen.
- **The night is lost** when either happens (GD-12):
  - section 6, the last section at the town pier, falls for good; or
  - the last of the town's 12 lit windows goes dark.
- **Crossing.** One of the dead crosses when it steps off section 6 onto the town pier landing.
- **Windows.** Each crossing puts one window out. Hatchlings put one out for every two that cross, counted across the night; one left over puts out nothing. The windows are behind the warden and visible from the deck.
- **A lost night** replays from the planning phase, with one new hint in the journal. The dusk lesson can be skipped.
- **Journal hints.** There are six, one per cause. The hint added is for whichever cost the most that night: Grapplers crossing; Divers crossing; hatchlings crossing; section 6 overloaded; section 6 torn up by hooks; the one who keeps coming back crossing three or more times.
- **Not a loss:** sections 1 to 5 falling; the warden being caught (a wound, below); running out of oil.

**The dawn ledger.** Dawn opens with every cry stopped: an earned silence. Then the ledger lists:

- sections standing, of 6
- windows lit, of 12
- planks and ropes left
- names learned: the name and its one-line epitaph, or nothing
- souls released: one, or none
- "The fallen will return." No number.
- wounds taken

It never shows a kill count or a score. Its purpose is the brief's dawn feeling: "I barely made it, and I was clever enough."
~~~

### B6. Every other statement about the forearm (verbatim sentences)

- gdd.md 282 (Mechanics 3): "The warden carries stripped parts, with no limit. The forearm shows tallies of planks and ropes in hand."
- gdd.md 352 (Mechanics 7): "Once read, it is inked on the warden's forearm."
- gdd.md 411 (Controls): "Tab (hold) | Raise the forearm: the name, if read, and the tallies of planks and ropes in hand"
- gdd.md 684 (Art Style): "**No HUD at night.** Information is carried by the warden's hands, the forearm (the name, and the tallies of parts in hand), the tally board, and the bridge itself. The hands show the action a click will perform."
- epics.md 53 (Epic 1): "Parts are carried; the forearm shows the tallies."
- epics.md 209 (Epic 5): "The name under the planks: a random section from 2 to 5, the hum, the leaning flame, read on foot by lantern light, the forearm."
- epics.md 296 (Epic 7, story 4): "The warden's arms, tools and forearm."
- decision-log.md 212 (finalize fix 7): "parts are carried with no limit, and the forearm shows tallies."
- brief extract 78: "**No HUD:** \"your hands, the names inked on your arms, and the ledger carry the information.\""
- brainstorm extract 138-139: "ST22 Your Hands Are the HUD: trembling, bandaged, older each chapter." / "ST28: names inked on the forearms; space is limited." (Neither the ageing hands nor limited slots is in the one-night game's GDD; the one-night game has one name.)

The forearm shows nothing else in the documents: not oil, not wounds, not windows, not time.

## C. Everything else that constrains or implies UX

### Platform and form factor
- Windows 10/11 64-bit and Linux x86-64, itch.io, free. No Steam, no Mac. (15, 725, 77)
- PC only; no console, handheld or mobile is mentioned anywhere. Screen sizes named only as test resolutions: 1080p and 720p. (714-715)
- No network; the public build collects nothing; the playtest build logs to a local file. (730)

### Input devices
- Keyboard and mouse only in the one-night game; gamepad arrives with the Fog Season. (394, 727, 831; GD-22)
- Key rebinding, mouse sensitivity, invert-look, hold-versus-toggle: NOT SPECIFIED.
- Many actions are holds of 2 to 12 s (strip, haul 6 s, re-hang 10 s, build 8 s and 12 s, dismantle 4 s, Tab held); held actions cancel on moving more than 0.5 m or on a wound. (402-412, 426)

### Camera and perspective
- Dusk lesson: first person. Planning: from above (whole span). Night: first person. Dawn: from above. (144-149, 387)
- First person has no sprint and no jump; walk 3.5 m/s. (402)
- Third person is "later, or never". (843; IN-5)
- Context range for the hands is 2 m. (396)

### Art style and palette
- "stylized, leaning to woodcut"; a full-screen ink-and-hatching treatment "makes mismatched free models read as one engraving." (682)
- Palette: "near-black world; warm living things; colorless dead; a true black abyss." (683) Also: "The living are warm, the dead are colorless, and the abyss is true black." The town's warm windows are always behind the warden. (571)
- The overhead (planning) view "is clean and readable, without the woodcut treatment." (685, 389)
- The ally is a silhouette: "a lantern, tools and a voice". (686)
- Gate 2 is played in gray boxes; the woodcut look is applied afterwards on the same span (epic 7). (687, 784; GD-32)
- Look test criteria that bear on readability: three people shown a night screenshot lit by one lantern can each point to the deck edge, a Grappler at 4 m, and a rig. (814)
- Colours, fonts, type sizes, menu styling, ledger styling: NOT SPECIFIED anywhere.

### HUD stance
- "No HUD at night." Carriers: hands, forearm, tally board, the bridge itself. (684; IN-9)
- Pillar 2 rules out "minimaps, enemy markers and wave timers at night." Pillar 4 rules out "kill counters, scores and combo meters." (125, 129, 822)
- "every visual cue points to a sound rather than replacing it." (125)
- No health bar (381); no ability bar, no cooldowns (540); no sanity or fear meter (584); no difficulty levels, star ratings or scores (554); no dialogue menus (822).
- "At night nothing is marked; light shows only what it falls on." In planning, "each rig shows the section it covers and each lantern shows its reach." (521)
- Stated on-screen text at night despite no HUD: the ally's roughly 10 lines, "each with matching text on screen". (365, 241, 703)
- Section strength "is the health bar" (137); the town's windows are "the visible score" (decision-log GD-12; gdd 169).

### Audio direction (sound that carries information)
- "The cries are the game." No composed music; "The cries, the bridge and the two bells are the whole soundtrack." (691, 693, 228)
- Level by kind of cry (whispers below, shrieks above, sobbing inside); a kind never appears at another level. (194-200)
- Side by stereo placement that follows head turns; behind is duller and slightly quieter; farther is quieter, 3 dB per section up to 15 dB; equal loudness at equal distance. (206-209)
- Room sound (thin/open, muffled/boxed, cave echo) is atmosphere, not a cue. (210, 694-700)
- Warnings: Grappler 6 s, Diver 8 s, nest 40 s (sobs quicken, never louder), the returning one 6 s (the tune). Every threat warns in full before it affects the bridge: "The dark never cheats". (212-221, 575, 777)
- At most 4 cries at once; warnings at least 1.5 s apart; on-deck cries drop to footsteps first. (226)
- On the deck each of the dead repeats its cry every 8 s with footsteps. (225)
- Falling cry fading over 2 s: "the payoff for a perfectly sprung trap". (227, 702)
- Section creak when load equals strength; 2 s groan before collapse. (264-265, 572)
- Town bell tolls at each wave start, once for wave 1 up to six for wave 6, always from the town side ("which way is home", GD-24). (477)
- 10 s of silence (wind and bridge) before the sixth toll; dawn opens with every cry stopped. (502, 174, 573)
- The hum (12 dB under a cry, within 3 m, only when no cry sounds) marks the name's section; the tune marks its owner; the tune "resolves" when the name is called. (351, 574)
- Ambience at least 6 dB under the quietest possible cry. (228)
- Wound: that side 12 dB quieter and dulled above 1 kHz for 20 s. (379)
- Sound output is stereo, headphones or speakers; "The game asks which at first launch." No HRTF in the base game. (728)
- Stream-safe sound: "a setting that lifts the cries 6 dB above everything else and always shows the ally's calls as text." (704)
- Sound list needing assets (useful as a feedback-event inventory): footsteps on planks; hook landing; straining rope; plank creak and section groan; section collapse; trapdoor; swing-beam; hammer on wood, iron and stone; the warden's bell; the town bell; lantern shutter, refill and flame; wind and fog bed. (739)

### Menus and screens named or implied
- A menu exists: "Cold start to the menu in 10 s or less" (717); "The first cry sounds within 60 s of pressing Start" (778); asset text "menu and settings" (743); epics.md 214, 231: "Starting up: menu, the headphones-or-speakers question, settings (Ears only, cues everywhere), skipping the lesson on replay."
- Headphones-or-speakers question at first launch. (728) What the answer changes in the base game: NOT SPECIFIED (it matters only in the ear re-check fallback, 805).
- Left/right check: one town-bell stroke, "which side?"; two wrong answers "offer a setting that swaps left and right, and warn that the sound may be single-channel". (146) How the player answers: NOT SPECIFIED.
- Pause and settings on Esc. (412) Pause screen contents: NOT SPECIFIED.
- Settings named anywhere: swap left and right (146); Ears only (559); Cues everywhere (560); Stream-safe sound (704); fog low setting and fog-sprite fallback (715, 729); lesson skip on replay (170). Any other setting (volume, resolution, sensitivity, rebinding, text size, language): NOT SPECIFIED.
- The journal: receives one new hint after each lost night, six hints in all. (170-171) Where and how the journal is shown or opened: NOT SPECIFIED. No key is assigned to it.
- Dawn ledger (174-184): content listed; its presentation (diegetic book, overlay, where the camera is beyond "from above") is NOT SPECIFIED. "There is no victory screen." (164)
- Lost-night screen or transition: NOT SPECIFIED. Replay must start in 3 s or less. (718)
- Save/load: none in the one-night game ("one sitting with no save"). (591)
- Credits and the AI-use disclosure: required for release (epics.md 314); where they appear in the game: NOT SPECIFIED.
- Playtest-only: a listening round of 5 minutes before the first night (796) and a playtest log (808); the listening round has no ally and nothing to defend. Its instructions or UI: NOT SPECIFIED.

### Tutorial and onboarding
- The dusk lesson, 2 min, first person: left/right check, then three harmless dead, one per level; each cry repeats until the warden faces within 45 degrees; the ally says whether that was right "and points it out after three tries". Skippable on replay. (146, 170; GD-8)
- The ally's calls scaffold waves 1 to 3 (every cry, 2 s in) and fade to a safety net from wave 4. (362-363, 609-611)
- Wave 1 is "Go to where you heard it ... Coast"; new threats arrive one per wave. (481-486, 621)
- Lost nights add a journal hint keyed to the main cause. (171)
- Teaching of controls, stripping, rigs, lanterns, the planning view, the bell or the forearm: NOT SPECIFIED. The lesson as written teaches listening only. (In the Fog Season outline the prologue's old warden "teaches listening, the lantern, the trapdoor and the bell"; that is not the one-night game. 660)
- First cry within 60 s of pressing Start. (54, 778)

### Accessibility
- "Every sound has a visual cue." (230; IN-17) Cues show only inside lantern light; "In the dark there are no visual cues. The safety net there is the ally's call, and the 'cues everywhere' setting." (244)
- "Cues everywhere: visual cues show in the dark too (accessibility, GD-9)." (560)
- "Ears only: all visual cues off" (559): a challenge setting, the opposite direction.
- Stream-safe sound (704), listed by the brief under accessibility.
- Left/right swap and a single-channel warning. (146)
- The ally's lines always have matching on-screen text. (365)
- Assists (wave speed, numbers, structural forgiveness) are Fog Season, not the one-night game. (561, 832)
- NOT SPECIFIED anywhere: colour-blind considerations, text size or contrast, photosensitivity, motion or camera comfort, hold-to-toggle alternatives for the long holds, key remapping, one-handed play, mono-output play beyond the warning, a fully deaf-playable path, screen-reader or menu narration, difficulty options.

### Localisation
- NOT SPECIFIED. No language list anywhere. Text volume is small: 6 names with one-line epitaphs, 6 journal hints, about 10 ally lines, menu and settings. (743) The ally's lines are recorded speech with matching text. (703)

### Performance targets
- 60 FPS average, 1% lows 45, at 1080p on a GTX 1050-class card with low fog; 30 FPS average, 1% lows 24, at 720p on Intel Iris Xe with the fog-sprite fallback; measured across the whole night including wave 6 (up to 18 dead, three lanterns, fog). (713-716)
- Cold start to menu 10 s or less; replay of a lost night 3 s or less; "A sprung rig reacts within 0.3 s of the hammer blow"; download 300 MB or less; no crash in 20 nights. (717-721)

### Player journeys and personas
- No named personas. Audience wants are quoted in section A. (52-54)
- Intended feeling: "pride, then peace." Every dawn: "I barely made it, and I was clever enough." (40, 184)
- Intended first-time outcome: reaches dawn with about 3 of 6 sections and 3 of 12 windows left; 3 of 5 newcomers reach dawn within two tries; median sitting 18 to 25 minutes. (555, 810)
- Expected arc per wave (coast, first struggle, steady, steady, struggle, barely). (619-628)
- Gate 2 checks: want more, barely, clever. (786-788)
- Replay reasons: the plan changes the night; the name's section and which of 6 names change per run. (160, 557)
- Three clip moments meant to read in a 10 to 30 s clip: a loaded trapdoor dropping, a section collapsing under a Diver, the name being called. (705)

### Game states and phases
1. Launch to menu; first-launch headphones-or-speakers question. (717, 728)
2. Dusk lesson (first person, about 2 min): left/right check, three harmless dead. Skippable on replay. (146)
3. Planning (from above, untimed, about 4 min, no dead, fully undoable). Ends on ringing the bell (Space). (147, 383-390, 424)
4. The night (first person, 12 min): six waves of 2 min, each 75 s of arrivals plus a 45 s lull; toll count at each wave start; 10 s silence before wave 6; the sky pales in wave 6. (148, 477-503)
5. Sub-states of the warden at night: walking; performing a held action; knocked down 1.5 s; wounded 20 s (one ear dulled, view darkened on that side); hanging from an edge and climbing back 5 s; crossing an open section along side beams 4 s; crossing a gap hand over hand 8 s; forearm raised; paused. (267-269, 379-380, 411-412)
6. Dawn (from above, 2 min): silence, then the ledger. No victory screen. (149, 164, 174)
7. Lost night: when section 6 falls or the last of 12 windows goes dark; replays from planning with one new journal hint. (165-170)
8. No save, no between-night state in the one-night game. (591)

### World objects that carry information (diegetic surfaces named in the GDD)
- The warden's hands (show the action a click will perform). (396, 684)
- The forearm (name; tallies of planks and ropes in hand). (411)
- The tally board at the town pier (the ally chalks one tally per toll). (240, 595)
- The town's 12 lit windows, behind the warden, visible from the deck. (169)
- The bridge: shaking rail ropes, dust from pier stones, swirling fog overhead, bowing planks, swaying ropes in time with the tune. (196-200, 232-242)
- Lantern flames (lean toward the nearest cry inside their own light; the carried flame leans toward the name's section within 3 m). (235-236)
- The name carved in timber under the planks (read on foot, at night, by lantern light). (352)
- The sky (pales during the last wave). (486)
- The town pier landing holds the bell, the tally board, the spare flask and the ally. (595)

## D. Decisions from decision-log.md that touch UI, HUD, input, feedback, readability, audio-as-information or accessibility

Format: decision; rationale; what was rejected. All dated 2026-11-19 unless inherited. "None recorded" means the log gives no rejected alternative.

| ID | Decision | Rationale given | Rejected or replaced |
|---|---|---|---|
| IN-5 | Camera: overhead by day, first person at night. | Brief. | Third person "later, or never". |
| IN-6 | Level cue: whispers below, shrieks above, sobbing inside the walls. | Brief, brainstorm #16. | None recorded. |
| IN-8 | Nights are not pass/fail; the ledger shows the cost. | Brief, brainstorm F5, F12. | Pass/fail nights. (Amended by GD-12: the one night can be lost.) |
| IN-9 | No HUD at night: hands, names inked on the arms, the ledger. | Brief. | Minimap, enemy markers, wave timers at night. |
| IN-10 | Woodcut look, full-screen ink-and-hatching shader; living warm, dead colorless, abyss true black. | Brief. | None recorded (brainstorm: realism lost to stylized). |
| IN-11 | The cries are the score; no composed music; nothing AI-voiced. | Brief. | Composed music; AI voices. |
| IN-13 | One-night game carries stream-safe sound and clip moments; first cry within a minute. | Brief. | None recorded. |
| IN-16 | Windows first, Linux alongside, itch.io. | Brief. | Steam, Mac "for now". |
| IN-17 | Accessibility: a visual cue for every sound; stream-safe mode. | Brief. | None recorded. |
| IN-18 | Ear test: direction 95.8% headphones, 87.5% speakers; both-right 62.5% against an 80% mark. | Measured, one practiced listener. | Gate closed without the five outside players. |
| IN-19 | One kind of cry per level, never crossed; rear shadow; every cry equally loud; room sound is atmosphere, not a cue. | Ear-test outcome. | Room sound as a cue. ("Equally loud" later refined by GD-40.) |
| IN-20 | First playtests re-check placement by ear with newcomers on headphones and speakers. Fallbacks: "best with headphones" plus visual cues; Plan B, the lantern scouts. | Ear-test outcome. | None recorded. |
| GD-4 | Ear test changed three things: level is the weak cue; it takes practice (a listening lesson inside the game); "ears alone aren't enough, so the night should show more by default". | Sonlm's own sessions. | None recorded. |
| GD-5 | Pillar 2 stays as written with its rule (no minimaps, markers, wave timers at night). | "the pillar already allows visual cues that point to a sound". | Changing the pillar to fit GD-4. |
| GD-7a | Each level has its own place: below over the two rails, inside out of the two piers, above onto the open deck. | "Where a cry comes from also tells which level." | None recorded. |
| GD-7b | The bridge shows where: dust from a pier's stones (inside), a rail's ropes shake (below), fog overhead swirls (above). | Brainstorm G11. | "No markers." |
| GD-7c | The ally calls the level about 2 s after a cry starts: "Below!", "Above!", "In the walls!". | Third level cue. | None recorded. |
| GD-8 | Listening lesson: about 2 min at dusk, three harmless dead one per level, the warden turns to face each cry, the ally says whether that was right. First cry inside the first minute. Skippable on replay. | Practice is needed (GD-4b); brainstorm JB4, RB5. | None recorded. |
| GD-9 | Visual cues on for everyone, headphones and speakers, but only where the warden's lantern or a placed lantern reaches. The dark is sound only. An accessibility setting shows cues everywhere. | GD-4c. | The brief's "on by default for speaker players only". |
| GD-11 | A plan-from-above phase with no dead after the dusk lesson; ends by ringing the bell. | Closes OP-7. | A night-only one-night game. |
| GD-12 | Loss: last section at the town pier falls, or the last lit window goes dark; "the windows behind the warden are the visible score". A lost night replays with a hint added to the journal. | Brainstorm F5, F11, O11. | "replays from dusk" was later replaced by P11 (from planning). 5 windows replaced by 12 (GD-44). |
| GD-13 | The ledger lists a fallen one as "fell, will return", not as released. | Settles brainstorm U7. | Counting falls as kills. (Later: the count of the fallen dropped, fix 17.) |
| GD-14 | The name is carved under the planks; calling it takes one pull of the bell rope when the warden hears its owner coming. | Closes OP-13. | None recorded. |
| GD-15 to GD-17 | Tells: Grappler about 6 s haul; Diver circles shrieking about 8 s, aims for the brightest lantern; nest "sobs louder for about 40 s". | Roster. | "sobs louder" replaced by quickening sobs, never loudness (fix 11). |
| GD-18 | Trapdoor hauled up in about 6 s; swing-beam re-hung in about 10 s. | Roster. | None recorded. |
| GD-19 | Overload feedback: load above strength for 2 s, "the section groans, then falls for good". Action times for strip, re-lay, wedge. | Starting values. | None recorded. |
| GD-21 | Material is split into planks and rope, "counted on the span itself". | Closes OP-15. | Echoes and food (Fog Season). |
| GD-22 | Keyboard and mouse only. "Context hands: left mouse is the hammer hand, right mouse is the lantern and rope hand; the game picks the action from what the warden is looking at, and the hands show it before the click." | Closes OP-16. | Gamepad (deferred to the Fog Season). |
| GD-23 | 12 minutes, 6 waves of about 75 s arrivals and a 45 s lull; sitting about 20 minutes. | Starting values. | None recorded. |
| GD-24 | The clock is the town's bell behind the warden, tolling once to six times at wave starts; "it also tells the warden which way is home". The sky pales during the last wave. | Pillar 2. | A wave timer. |
| GD-25 | The returning one has a recognisable voice; "A faint hum marks the section where its name is carved"; calling the name makes the wave lose its way for 20 s. | Brainstorm ST4. | None recorded. |
| GD-26 | The ally's voice: about 10 short lines recorded by a person, "with matching text on screen". | Closes OP-27; brief allows few spoken lines. | AI voice ("Never AI-voiced"). |
| GD-27 | Caught: knocked down 1.5 s, the ear on that side rings and goes dull for 20 s. "No health bar, and the warden cannot die in the one night." | "the dead want the town, not the warden"; brainstorm F6. | Health bar; warden death. |
| GD-28 | Lanterns: 3, shutter, oil 6 min a tank, 1 spare flask, refill 4 s. A closed lantern "gives no light and no cues". | "two of three lit". | Reach 6 m/8 m replaced by 4 m/5 m (GD-44). |
| GD-30 / GD-46 | Ear re-check: listening round of 12 warnings in the dark with no ally; direction within 45 degrees in 4 s (80%), place within 5 m in 15 s (70%). | A good plan makes arrivals predictable, so the night log cannot carry the pass mark. | Pass marks on the night log (GD-30 as first written). |
| GD-31 | Performance target incl. a low fog setting and a fog-sprite fallback. | Closes OP-24. | None recorded. |
| GD-32 | Gate 2 is played privately in gray boxes with the real sound; the look follows. | Prove the night first. | Look first. |
| GD-35 | One-night game: a cues-off setting (first logged as "Blind Watch as a setting", renamed "Ears only" in fix 31); calling a name makes the wave lose its way; a one-line epitaph with the name at dawn. Fog Season: G12 assists, the ledger as save file, lean over the edge, letters and notice board, gamepad. Only if the ear re-check fails: HRTF plugin trial and Plan B. | Tiering. | Blind Watch proper (near-black screen) pushed to a later update. |
| GD-38 | A hammer blow on a set hook restarts the haul; the hook stays. | "Nothing is removed by hand, so pillar 1 holds." | Removing hooks by hand. |
| GD-39 | The ally's calls fade: waves 1 to 3 every cry 2 s in; from wave 4 only when the warden has not turned to within 45 degrees 4 s after the cry starts. | So that the ear has to lead (gdd 868). | Calling every cry all night. |
| GD-40 / GD-47 | Farther is quieter: 3 dB per section up to 15 dB (first 2 dB up to 10 dB). | Distance must be hearable; the step must not equal the rear shadow's 2 dB. | "loudness never tells distance" (an ear-test setting, not a finding). |
| GD-41 | Every spring spends a part (trapdoor 1 plank, swing-beam 1 rope). | Closes the loop. | Free resets. |
| GD-42 | A wrong ring hurries the dead for 10 s. | Brainstorm U4. | A free wrong ring. |
| GD-43 | Early listen at the end of epic 2 with two or three newcomers. | Check before building on the ear. | None recorded. |
| P1 | On the deck each of the dead repeats its cry every 8 s and adds footsteps. | Accepted proposal. | None recorded. |
| P2 | Never more than 4 cries at once; warnings at least 1.5 s apart; beyond the limit, on-deck dead drop to footsteps. "Untested". | Accepted proposal. | None recorded. |
| P3 | Ambience at least 12 dB under the cries. | Accepted proposal. | Replaced in second validation item 9: "ambience at least 6 dB under the quietest a cry can be". |
| P4 | The key map in Controls and Input. | Accepted proposal. | None recorded. |
| P5 | A warden on a falling section catches the edge and climbs back in 5 s, with a wound. | Accepted proposal. | None recorded. |
| P7 | Rig details: where each is sprung from, the 0.3 s drop, the 1.5 s sweep, one rig per section. | Accepted proposal. | None recorded. |
| P11 | A lost night replays from the planning phase with one new journal hint; the lesson can be skipped. | Accepted proposal. | Replay from dusk (GD-12 wording). |
| P12 | The lines of the dawn ledger. | Accepted proposal. | See fix 17. |
| P13 | No scripted jump scares; 10 s of silence before wave 6. | Accepted proposal. | Jump scares. |
| P14 | The town pier landing is safe; no warning starts during a lull. | Accepted proposal. | None recorded. |
| P15 | The look test's three pass criteria. | Accepted proposal. | None recorded. |
| P17 | What stream-safe sound does. "Clip moments are not yet specified." | Accepted proposal. | None recorded. |
| P18 | Start-up, replay, reaction, download-size and stability targets. | Accepted proposal. | None recorded. |
| P19 | The ally stands at the town pier, cannot be hurt, and drops a call that would be more than 4 s late. | Accepted proposal. | None recorded. |
| P20 | "Planning is untimed, fully undoable, and shows strength directly." | Accepted proposal. | None recorded. |
| Fix 7 | Parts carried with no limit; "the forearm shows tallies". | Validator. | A carry limit. |
| Fix 8 | Night building has a time and an input (trapdoor 8 s on key 1, swing-beam 12 s on key 2); dismantling is R held 4 s; F also shutters a placed lantern within 2 m. | Validator: missing inputs. | None recorded. |
| Fix 9 | A hook strike takes 0.5 s; each Grappler can be shaken loose once. | Validator. | None recorded. |
| Fix 11 | The nest's 40 s countdown "is heard as sobs quickening (seven sobs, gaps closing from about 4 s to none), never as loudness." | Loudness is reserved for distance and must not give away level. | "sobs louder" (GD-17). |
| Fix 12 | "the planning view never shows what is under the planks; the name is read on foot at night by lantern light." The hum is 12 dB under a cry, within 3 m. | Validator. | Showing the name in planning. |
| Fix 13 | Warning clip make-up; on-deck cries dropped first at the 4-cry limit; the falling cry sits outside the limit as the payoff for a sprung rig. | Validator; Sonlm's idea #14. | None recorded. |
| Fix 15 | Wounds: that ear 12 dB quieter and dulled above 1 kHz for 20 s; "the view darkens on that side." | Gives the wound a visual cue. | None recorded. |
| Fix 16 | Every sound gets a visual cue: flames lean toward the nearest cry and toward the hum; a groaning section's planks bow; each toll adds a chalk tally at the town pier; the ally's calls are text. "State that in the dark the safety net is the ally's call and the 'cues everywhere' setting." | The brief's promise. | None recorded. |
| Fix 17 | Ledger: add "names learned"; drop the count of the fallen. Dawn opens with an earned silence. | Pillar 4. | A count of the fallen. |
| Fix 21 | Journal hints: six, keyed to the main cause of the loss. | Validator. | None recorded. |
| Fix 22 | Start flow: a left/right check with the town bell before the lesson, "to catch swapped or mono output". | Brainstorm JB4. | None recorded. |
| Fix 31 | The cues-off setting is "Ears only"; Blind Watch (near-black screen) stays a later update. ST19 (player writes the epitaph) is Fog Season; the one night uses pre-written epitaphs. | Citation fix. | Calling the setting Blind Watch. |
| 2nd validation 6 | "A flame leans only toward cries inside its own light, so the dark stays sound only." | Keeps GD-9 intact. | Flames leaning toward any cry. |
| 2nd validation 10 | "lit" for lanterns and "open" for sections; "the tune" and "the hum" defined; lanterns hang on a pole over the middle of a section; "visible events as the cue for footsteps, hooks and falls"; the lesson's pass rule and the left/right check's failure path. | Validator. | None recorded. |

### Open questions and items deferred that bear on UX

Nothing in the decision log or the GDD is explicitly deferred "to UX". What is open or deferred and touches UX:

- P17: "Clip moments are not yet specified." The GDD names three candidates, confirmed in epic 8 by recording them. (gdd 705, 874)
- Draft 0.5 has not been read by a validator; "Expect architecture to find more missing cases" in Grappler, Diver and stripping rules. (decision-log 280; gdd 873)
- "Is listening still needed?" If players pass in the light and fail in the dark, "pillar 2 is doing less than it claims." (gdd 868)
- Camping at the town end; planks following the fight (possible rule changes after playtests). (gdd 869-870)
- Ear re-check fallbacks would change defaults: "best with headphones" on the store page and "cues everywhere" on by default for speaker players; or an HRTF plugin trial; or Plan B, "the lantern scouts" (no design exists). (gdd 804-806, 891)
- Gamepad, assists, saving, the ledger as save file, lean over the edge, letters and notice board: Fog Season. (gdd 824-835)
- Narrative design runs later (GD-45); it owns who the holdout is and how the arc ends. The one-night game's texts (6 names and epitaphs, 6 hints, the ally's lines) are written in epic 5. (epics.md 215)
- "Every option chosen in this session was the facilitator's recommendation. The numbers are starting values from one proposal, not the result of comparison." (gdd 872)

## E. Information the player needs, and where the documents say it is delivered

Tags: SOUND, DIEGETIC (a world object or the warden's body), OVERLAY (on-screen text or screen-space effect), PLANNING VIEW, NOT SPECIFIED. "In light only" means the cue exists only inside lantern light unless "cues everywhere" is on.

### Threats
| Information | Delivered by |
|---|---|
| A threat is coming | SOUND: its warning (212-221). |
| Its level (below, above, inside) | SOUND: kind of cry. DIEGETIC, in light only: shaking ropes, swirling fog, falling dust (196-200). SOUND plus OVERLAY: the ally's call with on-screen text, every cry in waves 1 to 3, missed cries only from wave 4 (362-365). |
| Its side or direction | SOUND: stereo placement and rear shadow (206-207). DIEGETIC, in light only: a lit lantern's flame leans toward the nearest cry inside its own light (235). |
| How far along the span | SOUND: 3 dB quieter per section (209). Visual equivalent: NOT SPECIFIED beyond the level cue appearing at the arrival place if that place is lit. |
| Exactly where it will arrive (which rail, section, pier) | SOUND: the warning sounds from the arrival point (221). DIEGETIC, in light only: that rail's ropes, fog over that section, that pier's dust. |
| How long until it arrives | SOUND: fixed warning lengths; clip structure (whisper then straining rope; two shrieks; seven quickening sobs) (214-219). Visual progress of a warning (for example whether dust or fog changes over the 40 s or 8 s): NOT SPECIFIED. |
| Where the dead on the deck are now | SOUND: cry every 8 s plus footsteps; footsteps only when the 4-cry limit is hit (225-226). DIEGETIC: "The event itself, seen in the light" (238). In the dark: sound only. |
| A hook is set on a rail, and whether it has already been shaken once | SOUND: hook landing (739). DIEGETIC: the event seen in the light (238). Whether a Grappler has used its one shake: NOT SPECIFIED. |
| Which section a Diver has picked | SOUND: shrieks from over that section. DIEGETIC, in light only: fog swirls over it (335). |
| That the returning one is present (when the bell can be rung) | SOUND: the tune (202). DIEGETIC, in light only: its rail's ropes sway in time (237). |
| Something fell | SOUND: the falling cry fading over 2 s (227). DIEGETIC: seen in the light (238). |
| A crossing happened | DIEGETIC: a town window goes out, behind the warden (169). A sound for a window going out: NOT SPECIFIED. |
| The dead have been hurried by a wrong ring, or are standing still after the name | DIEGETIC by implication (they move faster or stop). Any dedicated sound or cue: NOT SPECIFIED, except that the tune "resolves" when the name is called (574). |

### Time and score
| Information | Delivered by |
|---|---|
| Which wave it is; how long until dawn | SOUND: number of town-bell tolls at each wave start (477). DIEGETIC: chalk tallies on the board at the town pier (240). DIEGETIC: the sky pales in wave 6 (486). No timer (pillar 2). Time remaining inside a wave: NOT SPECIFIED (by design no wave timer). |
| A lull has started (no new warnings for 45 s) | NOT SPECIFIED. The rule exists (477); no signal for it is named. |
| The last wave is about to start | SOUND: 10 s of silence before the sixth toll (502). |
| Which way the town is | SOUND: the bell always sounds from the town side (GD-24). DIEGETIC: warm windows behind the warden (571). |
| Windows left, of 12 | DIEGETIC: the windows themselves, "behind the warden and visible from the deck" (169). OVERLAY/ledger at dawn (177). |
| The half-window state from hatchlings | NOT SPECIFIED. |
| The night is lost, and why | NOT SPECIFIED as a screen or moment. The cause arrives afterwards as a journal hint (171). |
| Dawn has come | SOUND: every cry stops (174). View changes to from above (149). "There is no victory screen." (164) |

### The bridge and resources
| Information | Delivered by |
|---|---|
| A section's strength (planks left) during planning | PLANNING VIEW: "shows each section's planks, rails and strength directly" (389). |
| A section's strength at night | DIEGETIC by implication: the planks on it. But "Planks are a count per section, not positions" (252); how a count of 0 to 8 is read on foot, in the dark or in light, is NOT SPECIFIED. |
| A section's current load, or how close it is to breaking | SOUND: creak when load equals strength; 2 s groan above it (264-265). DIEGETIC, in light only: its planks bow (239). Numeric load at night: NOT SPECIFIED (and a number would be a HUD element). |
| A section is open or fallen | DIEGETIC by implication (trapdoor down, no planks, a gap). In the dark: NOT SPECIFIED. |
| Planks and ropes in hand | DIEGETIC: forearm tallies, on holding Tab (411). In planning: NOT SPECIFIED (the planning view is said to show per-section planks, rails and strength; a stockpile read-out is not mentioned). |
| Whether a rig can be afforded or placed (cost, needs 4 planks, needs a standing rail, not on section 6) | NOT SPECIFIED, in planning and at night. |
| A rig's state (ready, sprung, cannot be sprung under 4 planks, needs a rope to re-hang) | DIEGETIC by implication (the rig itself). Explicit feedback for "cannot": NOT SPECIFIED. |
| What a rig covers; a lantern's reach | PLANNING VIEW: "each rig shows the section it covers and each lantern shows its reach" (521). At night: "nothing is marked". |
| A rail is locked (a warning has started under it) or cannot be stripped (holds a beam) | NOT SPECIFIED. |
| Oil left in each lantern's tank | NOT SPECIFIED. |
| Whether the spare flask has been used; where it is | Location only: the town pier landing "holds ... the spare flask" (595). Used or not: NOT SPECIFIED. Whether it must be fetched or is carried: NOT SPECIFIED. |
| A lantern is lit, shuttered or empty | DIEGETIC by implication (light or no light). Telling shuttered from empty: NOT SPECIFIED. Sounds exist for shutter, refill and flame (739). |
| Where the light ends (where cues stop) | DIEGETIC: the light itself (4 m carried, 5 m placed) (329). |

### The name
| Information | Delivered by |
|---|---|
| Which section hides the name | SOUND: the hum within 3 m when no cry is sounding (351). DIEGETIC: the carried lantern's flame leans toward that section within 3 m (236). Never the planning view (389). |
| The name has been uncovered (4 planks or fewer) | DIEGETIC: carved in the timber, readable on foot, at night, by lantern light (352). What "reading" requires of the player (look at it, an input, a duration): NOT SPECIFIED. |
| The name itself, once read | DIEGETIC: inked on the forearm, seen on holding Tab (352, 411). |
| That the bell can now call it, and that the owner is on or under the span | SOUND: the tune. Otherwise NOT SPECIFIED (the hands "show the action" in general; no specific statement for the bell rope). |
| The ring worked or was wrong | Right: the owner stops and passes, the wave stands still 20 s, the tune resolves (354, 574). Wrong: "only noise" and the dead speed up (355). Any further feedback: NOT SPECIFIED. |
| The epitaph | Dawn ledger (179). |

### The warden
| Information | Delivered by |
|---|---|
| What a click will do right now | DIEGETIC: the hands show the action before the click, from what the warden looks at within 2 m (396). |
| What E, F, 1, 2, R will do right now, and whether they are available | NOT SPECIFIED. The "hands show it" statement is made about the two mouse hands. |
| Progress of a held action (2 s to 12 s) | NOT SPECIFIED. |
| A held action was cancelled (moved more than 0.5 m, or wounded) | NOT SPECIFIED. |
| An action is impossible (no parts, locked rail, section 6 limits, no rope for a re-hang) | NOT SPECIFIED. |
| "The section ahead" that a build or dismantle will affect | Defined as "the one whose town-side edge the warden stands at" (414). How the player sees which section that is: NOT SPECIFIED. |
| Which rail a swing-beam will hang from ("picked when it is built") | NOT SPECIFIED, at night and in planning. |
| Wounded, and on which side | SOUND: that side 12 dB quieter and dulled. OVERLAY: "the view darkens on that side" (379). Time left on the wound: NOT SPECIFIED. |
| Knocked down; hanging from an edge; crossing a gap | By implication the first-person view. NOT SPECIFIED in detail. |
| Wounds taken in total | Dawn ledger only (182). |

### Lesson, planning, menus
| Information | Delivered by |
|---|---|
| Left/right check: what to do and how to answer | Question stated ("which side?"). Answer method and presentation: NOT SPECIFIED (146). |
| Lesson feedback (right, listen again, where it actually was) | SOUND plus OVERLAY: the ally's lines "right" and "listen again" with text; the ally "points it out after three tries" (146, 370). How it is pointed out: NOT SPECIFIED. |
| How to move, strip, build, use lanterns, raise the forearm, ring the bell | NOT SPECIFIED. No controls teaching or key reference is described for the one-night game. |
| Planning: which tool is chosen (1, 2, 3); what can still be undone; how many lanterns remain to place | NOT SPECIFIED. |
| Planning: how to start the night | Space rings the bell (424). Any on-screen prompt: NOT SPECIFIED. |
| The journal's hints | "one new hint in the journal" (170). Where the journal is seen: NOT SPECIFIED. |
| Dawn ledger lines | Listed (176-182). Surface: NOT SPECIFIED. |
| Settings and their meaning (Ears only, Cues everywhere, Stream-safe sound, swap left/right, fog) | Named. Screen layout and wording: NOT SPECIFIED. |
| The ally's calls | SOUND plus OVERLAY text (241, 365). Placement, duration, style of the text: NOT SPECIFIED. |

## F. Contradictions and ambiguities that bear on UX

1. **"No HUD at night" against on-screen text.** Art Style says information at night is carried by hands, forearm, tally board and the bridge (684). Mechanics 8 and the cue table put the ally's calls as "Text on screen" (241, 365). The documents do not say this text is an exception to the no-HUD rule or describe it.
2. **Stream-safe "always shows the ally's calls as text" (704) against "each with matching text on screen" (365).** If the text is always matched, "always shows" adds nothing; if it adds something, there is an unstated case where call text is not shown (the obvious candidate is Ears only).
3. **Ears only: "all visual cues off" (559).** The visual-cue table (232-242) includes the ally's call text, the wound's darkened view, the chalk tally, bowing planks and "the event itself, seen in the light". Whether Ears only removes all of these, or only the level/side cues, is not stated.
4. **Cues inside lantern light only (GD-9) against cues that sit at fixed places.** The chalk tally is at the town pier; section 6 "stands inside the light of the town gate" (270), a light source not counted among the three lanterns. Whether the town-gate light shows cues, and whether the tally board and windows obey the "in light only" rule, is not stated. The wound's darkened view and the call text are screen effects that cannot be "inside lantern light" at all.
5. **The dark's safety net can be dropped.** "In the dark ... the safety net there is the ally's call" (244), but the ally makes "One call at a time. A call that would be more than 4 s late is dropped" (364), and from wave 4 a call is only triggered 4 s after a cry starts (363). With up to 4 warnings at once in waves 5 and 6, some cries in the dark get neither a visual cue nor a call. The drop rule's reference point ("late" relative to what) is also unclear given the 4 s trigger.
6. **Ambience level: epics.md is stale.** epics.md 89 says "ambience 12 dB under" (P3); gdd.md 228 and second-validation item 9 say "at least 6 dB under the quietest a cry can be ... 23 dB under a near one". The GDD and the later log entry win.
7. **Where a lost night restarts.** GD-12 says "replays from dusk"; P11 and gdd.md 170 say "from the planning phase". The later P11 wins.
8. **Lesson skip.** "Skippable on replay" (GD-8), "The dusk lesson can be skipped" after a lost night (170), "skipping the lesson on replay" (epics.md 214). Not stated: whether a returning player starting a fresh sitting can skip, whether the left/right check is skipped with it, and what a first-time player is offered.
9. **The headphones-or-speakers question has no stated effect.** The game "asks which at first launch" (728), but GD-9 makes cues identical for both. The only use of the answer is in a fallback that applies only if the ear re-check fails (805), which itself would partly restore the brief default that GD-9 replaced.
10. **"Lantern and rope hand" has no lantern actions.** GD-22 and gdd.md 396 call the right mouse button "the lantern and rope hand", but every lantern action in the key map is on E or F (406-407); the right-mouse row lists only rope and bell actions (405). So the statement "the hands show that action before the click" does not obviously cover E, F, 1, 2 and R.
11. **E is overloaded.** E hangs or takes down a lantern, re-lays a plank and refills a lantern (406). Which wins when more than one applies within 2 m, and how the player sees which will happen, is not stated.
12. **Picking the swing-beam's rail.** The beam needs "a standing rail on its section, picked when it is built" (308), but the inputs are "2 (hold 12 s) build a swing-beam on the section ahead" (409) and, in planning, "left click on a section" (421). Neither input says how left or right rail is chosen.
13. **Planning clicks against plank counts.** Planning is "Left click on a plank or rail: strip it" (420), while "Planks are a count per section, not positions" (252). Whether the planning view draws individual planks or a count is not settled. Re-laying a plank in planning has no input other than undo.
14. **Undo scope.** "Every choice can be undone until the night starts" (388) and "fully undoable" (P20), but the only undo input is "Right click: undo the last choice on that section" (422): per section, last-first. No reset-all is described.
15. **Two bells, three uses.** The town bell tolls by itself as the clock (477). The warden pulls "the bell rope at the town pier" to call the name (354), and "rings the bell" with Space to end planning (424). The asset list has "the warden's bell; the town bell" (739). Which bell Space rings, and how the first toll of wave 1 relates to that ring, is not stated. Because the name can only be called at the town pier, the player must be at section 6's end to use it; no cue says the owner is "on or under the span" other than hearing the tune.
16. **The tally board as the visual clock is location-bound.** The visual cue for a bell toll is a chalk tally at the town pier (240). A player who cannot hear the toll and is elsewhere on the span has no visual cue for a wave start unless they walk back; "cues everywhere" is not said to change this.
17. **Distance has no visual cue.** "Every sound has a visual cue" (230), but the property "how far" (209), added later by GD-40, has no row in the cue table. Equally the nest's quickening (time left) has only "dust falls" with no stated progression.
18. **The hum's two conditions.** The hum is heard "whenever no cry is sounding" (351); its visual cue (carried flame leans within 3 m, 236) has no such condition, and the general flame rule is "toward the nearest cry sounding inside its own light" (235). What the flame does when both apply is not stated.
19. **Oil is a named scarce resource with no read-out.** Oil is one of three resources (531) and "the player is always choosing what to leave dark" (580), yet no surface (forearm, lantern, ledger) is said to show tank level or the flask. The dawn ledger lists "planks and ropes left" but not oil (178).
20. **The journal has no surface or input.** Hints go "in the journal" (170); the key map has no journal key; the forearm shows only the name and tallies; the brainstorm's RB9 ("the journal page is already marked") was not carried over.
21. **Dawn view and ledger form.** Dawn is "from above" (149) and the overhead view "does not use the woodcut look" (389), "There is no victory screen" (164), and the ledger is a list of seven lines (176-182). Whether the ledger is an object in the world or an overlay, and whether dawn's overhead view is the same clean planning view, is not stated. IN-9 names the ledger as one of the no-HUD carriers.
22. **Gray-box timing of diegetic UI.** The forearm tallies are in epic 1 and the context hands in epic 4 (epics.md 53, 167), but "the warden's arms, tools and forearm" as art arrive in epic 7 (epics.md 296), after gate 2. Gate 2 is therefore judged on gray-box versions of the hands and forearm that no document describes.
23. **Stream-safe sound arrives after gate 2.** It is a brief accessibility item (IN-17) but is "Out" of epic 5 and built in epic 8 (epics.md 218, 313), so it is never playtested at the gate.
24. **Tab as a held action.** "Held actions are cancelled by moving more than 0.5 m or by a wound" (426). Whether raising the forearm (Tab, hold) is such an action, i.e. whether the warden can walk while reading it, is not stated.
25. **Pause.** Esc is "Pause and settings" (412). Whether the night clock and sounds stop, and whether pause is allowed in the listening round or lesson, is not stated.
26. **Reading the name.** "It can only be read on foot, at night, by lantern light" (352) with "Once read, it is inked on the warden's forearm"; no input, distance or dwell is given for "read", and the uncovering can also happen in planning (stripping to 4 planks) where the view deliberately hides it. A player who strips that section in planning gets no sign until they walk over it at night with a lit lantern.
27. **Clip moments.** P17 says "Clip moments are not yet specified"; gdd.md 705 names three and 874 calls them candidates. Not a conflict, but they are unconfirmed.
28. **Fog Season and brainstorm ideas that must not leak in.** Limited forearm slots (ST28), ageing hands (ST22), chalk plans drawn with the mouse (P1), camera settings CAM2/CAM3, lean over the edge (ST13), the overhead view showing only what is lit or heard (CAM1/CAM4) are in the brainstorm extract but are not in the one-night GDD; the cut-list rule ("anything outside the one-night game has to earn its way in", 83) applies.
