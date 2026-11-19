# Extract: brainstorming session 2026-11-12

> Extract made on 2026-11-19 by a reader subagent for the GDD session. It is a summary of the sources below, not a source itself; check the original before quoting.
>
> Sources: `_bmad-output/brainstorming-session-2026-11-12.md`

Source read in full (1646 lines): /home/sonlm/project/3d_game/_bmad-output/brainstorming-session-2026-11-12.md. 342 ideas (#1-#342). The extract runs over the 1000-1500 word target because the ID coverage would not fit. Items marked "(my reading)" are my own observations, not statements in the file.

## 1. Concept as finally settled

- **Working title:** The Mourning Watch (Z1; night watch + mourning; "morning watch" = last shift before dawn). A bare "Vigil" is already taken; the Steam/itch.io clash check is still pending.
- **Other title candidates, reused as in-game names:**
  - Z2 The Unmourned = what the living call the dead.
  - Z3 Where Grief Ends = the true ending.
  - Z4 Grief Comes in Waves = Endless mode.
  - Z5 The Toll = the toll gate.
  - Z6 Tollkeeper = old name of the warden's post (the holdout still uses it).
  - Z7 What the Bridge Remembers = the journal.
  - Z8 Keeper of Names = the warden in the true ending.
  - Z9 Call Them by Name = Chapter 1.
  - Z10 The Last Span = finale night.
  - Z11 Lanternfall = Tenures mode.
  - Z12 Hold Fast, Let Go = Chapter 3, the last before the ending choice.
- **Frame (Round 0):** PC, single-player, full release, free, no monetization.
- **Premise (Promising Combination 1):** "A warm-hearted engineer guards a bridge over an abyss where nothing stays dead, except on the bridge. Up close, listening to the cries, they rig, collapse, and salvage the bridge itself to barely survive each tide, and by day they plan from above. Then they learn the bridge is a grave, the dead were forgotten on purpose, and the only way to win is to remember them."
- **Player:** the Engineer-Warden (#2), warm-blooded, "explicitly not cold-blooded", wins "by ingenuity, not sacrifice".
  - Unarmed (H8): carries only rope, hammer, lantern, bell. Every death comes from the bridge and rigs.
  - The only one who never revives (#31).
  - Mourned at their own funeral before serving (K2, O1).
- **Core feeling:** "Smart use to barely survive".
- **Thesis:** "a warm warden wins by mourning, not killing". Core metaphor: Q1 A Vigil.
- **Kinds of fun (MDA):** Challenge + Narrative + Sensation.
- **Positioning (JB7, updated after the camera change):** "For players who love tense strategy and stories that stay with them, The Mourning Watch is a free tower defense game you play up close, where you hold a bridge by ear and win by remembering the dead. Unlike other tower defense games, you never hold a weapon, and every victory has a name."
- **Reference:** the manhwa Tyrant of the Tower Defense Game. Rule: "Keep the feelings, leave the story"; none of its premise, cast, world or names.

## 2. Accepted decisions by GDD area

**Core loop**
- L1: Hear → Rig → Hold → Salvage. Scouting is by ear, not minimap.
- Default campaign D1 "The Tide Waits for No One":
  - R2 The Tide: swells forecast by sound; prep time trades against expedition depth.
  - R4 They Don't Wait: waves come while you are below; rigs must hold without you; you hear which span is failing.
  - S1 Expedition → Siege: track the siege to its source (a nest, roost or gate) below, inside or beyond; what you break or learn decides what reaches the bridge.
  - S2 Push the Line: the causeway is the level map; holding is advancing.
- Day cycle: night → rites at dawn (L7, O8 "Dawn Is a Valley") → explore, salvage, repair and plan by day.
- Verbs: #3 Reshape (dig, dam, flood, divert); #4 Rig & Trigger (build in prep, spring by hand mid-wave); #5 Salvage & Repurpose (nothing restocked).
- Toys: #10 Load-Bearing; #11 Rope & Wind (sails, counterweights); #12 Feed the Abyss.
- Loop layers:
  - L2 Integrity Is the Budget.
  - L3 The Bargain: recruits become mortal.
  - L4 Toll Gate: living refugees vs mimics; open the gate or drop the span.
  - L5 Witnesses: dead who flee remember your traps.
  - L6 Sabotage the Source: the target is missing next wave, then grows back.
  - L7 Rites: quiet the cries so radar is clearer; some echoes come only from a rite.
  - L8 Lantern Line: refuel, relight, protect.
  - L9 Escort the Crossing.
  - #20 Fishing the abyss for echoes between waves.
- Remembering loop (P8, H5, H2, H6, Y3, H7, 5a): find names in the depths and piers → call them or carry them home before they fade → light town windows → grief reaches deeper until the depths can be cleared.

**Player actions and controls**
- H10: rites are hand actions (light a candle, carve a name, ring the bell once for each of the dead).
- J10: no dialogue menus; every decision is an action (open the gate, lower your hands, ring the bell, hand over the lantern).
- RB9: calling a name is one action; the journal page is already marked and you pull the bell rope.
- H2: calling a learned name makes that dead stop and pass without a fight.
- CJ6: hammer, rope and bell get weapon-grade feel.
- P1: chalk plans drawn with the mouse; the game never writes on the boards.
- N4/J4: Don't Look Back when leading someone up.
- ST13: lean over the edge for the best view of climbers, at a risk.
- G5: contraptions snap together (counterweight + trapdoor + net).
- ST20: nets under spans.
- Key bindings and input scheme: not stated.

**Threats (18 designed)**
- Above:
  - A1 Kite-Wraiths: ride gusts; a timed sail blows them off.
  - A2 Divers: drop onto load-bearing points.
  - A3 Carrion Choir: its singing blinds the radar while overhead.
  - A4 Lantern-Snuffers: moths that put out lanterns.
- Below:
  - B1 Rope-Eaters: chew ropes and supports, unseen from the deck.
  - B2 Grapplers: hooks drag sections down.
  - B3 The Swell: the dead pile into a living ramp.
  - B4 Line-Biters: climb your fishing lines.
- Inside:
  - I1 Hollow Nesters: uncleared nests hatch mid-wave.
  - I2 Mimics of the Living.
  - I3 Rot in the Planks: each cut adds strain elsewhere.
  - I4 Echo Ghosts: salvaged echoes wake in your stores.
- Deck:
  - C1 The Procession: coffins; break one and something worse climbs out.
  - C2 Bone Shieldwall: immune to frontal traps; drop the floor or blow them off.
  - C3 The Drowned: walk through floods and open dams.
- Wave-breakers:
  - W1 Gorge-Climber: shakes the whole causeway.
  - W2 The Mourner: its wail hits ally morale; mercenaries waver.
  - W3 The Returner: slips below to revive; cut off its way home.
- Behaviour rules:
  - U1: every body adds load.
  - U4: noise draws them (bell, hammering, a falling span).
  - U5: Snuffers hunt light, the other dead avoid it.
  - U7: Falling Isn't Dying; anything knocked off returns and remembers your traps; only a release on the bridge is final.
  - U8: paths wear in.
  - U10: allies and the dead hear the same sounds.
  - Y2: the dead are finite; the oldest and angriest come last; Endless is the exception.
  - #29: the depths can't be cleared (sneak, lure, outsmart).
  - #32: the revived are weakest right after getting back up.
  - #37: soul-pinning nails hold a creature dead "until the nail rusts".
  - ST10: each wave follows one named leader; call the name and the rest lose their way.
  - ST4: The Regular.
  - ST14: dropped spans return next season as their ladders.
  - RB11: one tell per exception (peaceful dead carry candles; mimics' footsteps sound wrong).
  - H3: blank masks crack to show faces as you learn about them.
- Special nights: N5 Wild Hunt (wind season; put out lanterns and keep still); AG2 Night of Standing Aside; AG1 The Night You Lose; M1 The Silence.
- Final boss, AG7: the last wave-breaker is the first person buried in the bridge; only its name, found in the first pier, ends the fight.

**Audio and information cues**
- #16: whispers below, shrieks above, sobbing inside the walls.
- R1: dusk cries are the clock; no on-screen timer.
- ST2 Singing Planks: each span rings at its own pitch.
- N1: planks sound different under living feet (mimic check).
- G3 The Ear Trains: more distinct cries, precise direction, late-game intent ("dive or climb, fake or charge").
- #33: the survivor turns whispers into wave forecasts.
- N6/J7 The Keening: names who dies tonight; saving them means pulling a rig or person from elsewhere.
- U3/O10: wind makes cries drift.
- P7 Deafening Chorus: every release without a rite makes the chorus louder.
- H4: echoes taken without a rite cry louder and cloud the radar.
- U9: an echo lingers where someone was released until salvaged with a rite (a lure or a leak).
- Y8: touching a pier makes the chorus louder.
- O7: every new threat is heard at least one night before it appears.
- ST1 Bridge Dog: ears and growl point at danger; you can pet it.
- CJ3: the bridge's creaks are its moods.
- ST25: moss muffles footsteps on spans left alone.
- F6: wounds hit the senses (a ringing ear, a burned hand).
- Q8: fatigue slows hands and blurs hearing.
- AG4: the cries turn out to be about you.
- G11 See the Sound: ripples in the fog, lantern flames leaning toward the source.
- T3 No HUD: blueprints on boards, chalk wave tallies, the alarm bell.
- ST22 Your Hands Are the HUD: trembling, bandaged, older each chapter.
- ST28: names inked on the forearms; space is limited.
- CAM1: from above, the dead show only where your light reaches or where you can hear them.
- JB4: an in-story ear test ("Which side did the bell ring?").

**Resources and economy**
- Y9 No Gold, Ever. Five resources: material, echoes, names, oil, food; sources named as "the bridge, the border, the depths, the town".
- L2: rigs are built from planks, rope and iron pulled from elsewhere on the bridge.
- Y1: stripped spans fall early (blocks the strip-then-drop exploit).
- Y5: every move loses a little (a pulled plank splinters, a cut rope comes back shorter).
- Y4: stone is heavy, so the piers under it need work too.
- Y8: decks and rails can be stripped, piers never.
- Y6: oil only seeps from the walls of the Descent.
- Y7: allies must eat; the town feeds the camp only while its lights burn.
- Y3: names fade "after a few nights" unless called or carried home.
- J1: call a name now (safety) or carry it home to light a window (reach).
- #17/#35: echoes are income; the forge works only with things that have died once.
- G4: each salvaged enemy teaches the blacksmith a part (Kite-Wraith silk → sail rope, Grappler hooks → your hooks).

**Progression**
- O1 Prologue, Your Own Funeral: learn the bridge, listening, the lantern, one rig, the bell; the old warden hands you the lantern at dawn (M12).
- O2 Chapter 1, Fog Season: stripping and building, first trip below, first name; threats from below and across the deck; ends with the first ally coming up (M5), then the Silence (M1).
- O3 Chapter 2, Swell Season: water and rot, fire, contraptions, toll gate and footsteps, leading someone up; threats from inside (nesters, mimics); ends on Tell the Town (J5); peak M6.
- O4 Chapter 3, Wind Season: wind bends sound and spreads fire, the Wild Hunt, the keening; threats from above (divers, lantern-snuffers); age may force a succession; the truth lands (M14).
- O5 Finale, The Last Span: nothing new, everything at once, plus the oldest dead and the wave-breaker only heard in Chapter 1; then the ending choice.
- Pacing rules: O6 at most one new enemy, rig or rule per night; O7; O8; O9 revelation after mastery; O11 no grind gates (if stuck, the bridge replays the night and the journal adds a hint).
- Growth:
  - G2: knowledge is the upgrade (the journal unlocks the rig that beats an enemy; no stat tiers).
  - G6: held spans harden from timber to stone and iron.
  - G7: each ally adds a station (forge, infirmary, bell tower, kitchen); losing them closes it.
  - G8: trust decides what allies will do (hold a post alone, go below, tell the truth).
  - ST26: trust grows at the dawn breakfast; who you sit beside decides who holds a post alone.
  - G9: truth in pieces, by depth reached.
  - G10: the warden ages each chapter ("slower hands, sharper ears").
  - Q7: allies take shifts; an empty post is where the dead break through.
  - ST30: a successor who worked beside you inherits your skills.

**Level and map**
- #9 Gorge Causeway; X4: one causeway of "about five spans".
- #22 Hollow Causeway: tunnels, engine rooms, sealed vaults.
- #23 The Descent: deeper means richer salvage and louder cries.
- ST21: the Long Stair is the loading screen.
- ST7: the Quiet Floor at the foot of the first pier.
- #24 The Far Side: scout the coming wave, then race back.
- Living side: the camp, the toll gate, the notice board, the town's lit windows, the old graveyard.
- G1/CAM4: lookout and watchtower.
- BC9 span graph: each span holds load, wetness, fire, light, noise.
- X5: collapse is a number plus a hand-made animation.
- X6: the depths reuse the bridge's art kit.
- U2 fire runs along rope; U6 the Swell soaks the lower spans (wet timber won't burn, rots faster).
- T5: scars persist.
- S4: seasons shift the threat direction.

**Win and loss**
- F12 Cost Ledger: nights are not pass/fail; you see the cost in spans, lanterns, people.
- H11: the ledger counts names learned and souls released, never kills.
- F5: a broken span drops and you retreat to the next pier; the game ends only when the last pier goes.
- F6 Wounds, Not Deaths; F7 a fall lands you in the Descent; F8 a downed warden can be dragged out by an ally.
- F10: allies die permanently.
- F11: each breach puts town windows out for good; the ending depends on the lights left.
- Endings, earned via J9:
  - 5a Remembering (true): needs names carried home and rites held.
  - 5b Merciful Fire / F13 Burn the Bridge: always available.
  - 5c Stand Down: needs K5.
  - ST8: secret ending, refuse the lantern in the prologue; the game "ends in two minutes".
- AG8: the credits roll your carried names first.

**Art direction**
- X10: stylized (V4 Low-Poly Gloom or V5 Living Woodcut) under V1 Lantern Noir and V3 Painterly Fog. "Fog Is a Budget".
- T1: the living are warm-toned, the dead colorless; a recruit's color returns.
- T2: the gorge is true black with drifting motes.
- X9 Voices, Not Faces: allies are silhouettes. CJ5: an ally at a post is their lantern, tools and voice.
- BC6: the look is tested on one span and checked on low-end PCs.

**Audio direction**
- E4: the cries follow an arc: eerie → heavy → release, with triumph kept for peaks.
- T4: the score is made of cries.
- ST29: in the true ending the chorus resolves into one song, as full as the names you remembered.
- RB7: sell weight with layered groans.
- ST16: voiced letters from the old warden between chapters.
- P6: a sound-only Close Calls replay.

**Narrative and world**
- Rule #27: immortal below, mortal beyond.
- Truth K2 The Unmourned: grief reaches exactly as far as the bridge; the town's lights are the mourners' windows.
  - Layered on: K5 The Pleas (the dead climb because they want to die); K6 The Keeper's Oar (no warden leaves until someone takes the lantern).
- Canon chain: 1a forgotten on purpose → 2a because of what the living did → 3a the bridge was built on them → 4a the bridge is their only memorial → 5a remembering is the cure.
- False beliefs: K1 Death in Chains (blacksmith); K3 Food of the Depths (survivor); K4 The Treaty (mercenaries). Only the holdout knows the truth.
- Journal rumors: 1b Grief-Eater, 1c Sealed Way, 2b Forgetting Was the Cure, 2c Stolen Names, 3b Abandoned Half, 3c The Tithe, 4b Ward in the First Pier, 4c Gorge Swallows Sound.
- Choices: J2 Whose Plan (per chapter); J3 Forbidden Meal; J5 Tell the Town (lights go out, but the remaining mourners reach further); J6 Builder's Secret (expose, forgive, or let them choose); J8 Who Takes the Lantern.
- Ally role options (12):
  - Survivor: #32 The Way Down, #33 The Voices, #34 What They Were.
  - Blacksmith: #35 From Echoes, #36 The Bridge Itself, #37 Soul-Pinning Nails.
  - Mercenaries: #38 A Way Out, #39 Echoes (may desert), #40 A Good Death.
  - Holdout: #41 Last Warden, #42 One of the Dead, #43 Bridge's Builder.
- The town: ST5 Dead to the Town (messages by bell or note); ST6 The Council (cuts your food); ST15 Who Rang the Bell; ST17 The One Who Still Writes; ST18 Notice Board.
- Release ritual: ST9 last words; ST19 epitaph; ST12 keepsakes; ST27 death days; ST3 unfinished errands; AG6 One Last Watch.
- Story rules: X11 no branching dialogue; RB3 show, never sermon; RB8 keep three good lies alive; CJ2 every mechanic works without the lore; AG3 the tutorial teaches the wrong lesson; AG5 the bridge wants to fall; RB4 warmth between the waves; RB5 first cry in the first minute; SP6 the order of discovery varies per run.

**Meta features**
- Accessibility: G12 assists (wave speed, enemy numbers, structural forgiveness, set separately); G11; ST24 Gentle Mode.
- Streaming: SP1 stream-safe sound; SP2 clip moments of "10–30 second"; SP3 name a warden after chat; SP7 Dawn Card.
- Records: JB5 Dawn Tally; ST11 the ledger is the save file; P2 the line of warden names is carved in the first pier.
- Extras: P3 Daily Tide; P4 Bridge Codes; P5 Quiet Shift; O12 Blind Watch; JB3 "A Visit, Not a Game" (opt-in, not marketed); ST23 names load from plain text files; ST31 achievements for kindness only; JB2 The Letter After.

## 3. Mutually exclusive choices

- **Campaign:** D1 is the default. R3 Long Night is the finale night; S4 gives each chapter its season.
  - D2 Classic Watch (R1 Dusk & Dawn + S2) = Story mode.
  - D3 Builder's Gamble (R5 Ring the Bell + S3 Unfinished Bridge) = Endless mode.
  - D4 No Rest (R3 + R4 + S1) = Hard mode.
  - S5 Many Crossings stays an alternate.
- **Warden death:** F2 Succession is the default (the bridge keeps its scars); it falls back to F1 Last Dawn when no allies remain (H9: "the bridge replays the night"). F3 Tenures and F4 Ironman are modes.
- **Camera:** CAM1 Plan From Above, Survive Up Close is the default (overhead by day and at dawn; first or third person at night).
  - CAM3 (third person as the main view) and CAM2 (switch any time) are settings.
  - CAM4: at night the overhead view is only from the watchtower, where you can't rig, unless CAM2 is on.
  - This replaced the Round 4 default of first person with G1 Lenses You Earn.
- **Cries register:** E4 An Arc is the default; E1–E3 are its stages.
- **Look:** stylized over realism (V2 Timber & Iron lost). V4 vs V5 is open.
- **Truth:** K2 is real, with K5 and K6 layered on; K1, K3 and K4 are ally beliefs.
- **Five Whys:** the "a" answers are canon; the "b" and "c" answers at levels 1–4 are rumors; 5a is the true ending, 5b and 5c are the other endings.
- **Metaphor:** Q1 is the core; Q2–Q6 are motifs; Q7–Q8 are mechanics.
- **Launch modes (X13):** campaign D1 + Endless D3; the rest come later.
- **Positioning:** JB1 leads; JB2 and JB4 support; JB5 and JB6 are how it spreads.

## 4. Rejected, parked or later

- Unchosen Round 1 sparks: Cold Calculator, Last Bastion, Puppet-Tyrant, Accidental Commander, Hometown Guardian, Dam Pass, Hollow Wall (the last two are remixed in S5).
- Realism (V2) rejected.
- Monetization parked; multiplayer excluded.
- Never: gold, a kill counter, dialogue menus, stat tiers, grind.
- Later, via free updates: about 12 of the 18 enemies; the allies' second and third roles; all modes other than D1 and D3.
- Not explicitly accepted: Batch 2 kernels ST10–ST20 (#287–#297), "captured as generated".
- Contingent: CJ1 Plan B, The Lantern Sees.
- Third person: launch or later is to be decided in the cut list.
- JB3 is not marketed.
- RB1: every feature needs a tier (prototype, launch, update, never).

## 5. Numbers and tunables

- Bridge: "about five spans" (X4).
- Enemies: 18 total = 4 above + 4 below + 4 inside + 3 deck + 3 wave-breakers.
- Launch roster: "about 6 of the 18", at least one per direction plus one wave-breaker (X7).
- One-night prototype (X2/BC7): one span; three enemies (one above, one below, one inside); two rigs; one ally; the bell; one name.
- Allies: four, one job each (X8), out of 12 role options.
- Campaign: prologue + three chapters (fog, swell, wind) + finale night.
- Endings: three, plus the secret one ("ends in two minutes").
- Modes at launch: two.
- Ear test (RB2/BC8): five outside players name a cry's direction "8 times out of 10".
- Clip moments: 10–30 seconds.
- Names fade "after a few nights".
- Pacing: at most one new thing per night; threats heard at least one night before they appear.
- AG2: "once a season".
- M6: a span reinforced over "three chapters".
- Resources: five. Span-graph values: five. Warden tools: four. Assist sliders: three.
- Collapse: "a few collapse animations per span type". Allies: "a few lines each".
- Fees: Steam Direct $100; itch.io $0 minimum.
- Reference adaptation targets 2027.
- Session output: 342 ideas, 18 concepts, 16 themes.
- Not stated: night length, nights per chapter, wave sizes, distances, rates, health values, forearm name slots.

## 6. Open questions and tensions

Listed in the file:
1. Team size is assumed solo, not confirmed.
2. Batch 2 (ST10–ST20): keep or drop.
3. Title clash check.
4. Originality check (RB10).
5. Who the holdout is (#41, #42 or #43; J6 implies complicity).
6. Which wave-breaker ships.
7. V4 or V5.
8. Engine: deferred to architecture in the file.
9. Third person's cost: launch or later.
10. Donations and the Steam fee.

Not resolved (my reading):
- U7 Falling Isn't Dying contradicts #12 ("nothing ever comes back up"), #14 (the cry of enemies sent into the abyss as the payoff) and #17 (abyss income).
- T4 (a fuller choir for more sent down) vs P7 (the chorus drowns the radar).
- Five resources, but only four source places are listed.
- Which six enemies, which two rigs and which job per ally ship: not stated.
- Whether the G1 lookout still matters after CAM1: not stated.
- F2 and M10 switch the view to an ally, while X9 and CJ5 keep allies unanimated.

## 7. Tone and feel (quoted)

- "the cries of souls"
- "The payoff is heard, not seen."
- "the border is a volume, not a line"
- "the border is the only place death works"
- "Survival horror without a body count."
- "In a game played by ear, silence is the scariest sound."
- "The abyss is felt through absence."
- "The score is warmth you can see over your shoulder."
- "Death as a change of eyes, not a game-over screen."
- "\"Barely survive\" is the expected result, not a near-miss."
- "defending and mourning are the same act"
- "says \"warm, not cold\" in every frame"
- "The most peaceful place in the game is the bottom of the abyss."
- "seeing everything means standing still"
- "A goodbye instead of a kill."
- Job to be done: "a game I can play with headphones in the dark"; one night = one sitting.

## 8. Scope signals

- Team: solo developer, assumed ("just me"), not confirmed.
- Time, budget, schedule, the designer's skills: not stated.
- Purpose: a full free release on Steam and itch.io.
- "342 ideas are a menu, not a plan." "A short, finished, polished game beats a long unfinished one."
- The bridge is irreplaceable: "cut scope around it, never into it". The sound radar is the riskiest pillar (CJ1).
- Costs noted: third person needs a fully animated warden (the biggest new cost); the overhead view is cheap because it reuses the debug map (CJ4).
- First playable:
  - X1 gray boxes with placeholder cries.
  - BC9 span graph with a top-down debug view and faked collapses.
  - BC8 ear test as the gate.
  - X2/BC7 one-night prototype, released free on itch.io (X3).
- Roadmap (BC1–BC12): brief → (optional early ear test) → GDD and architecture → span graph → ear test → one-night prototype → look test → Chapter 1 public demo → full campaign → content lock → launch.
- BC3 content lock: three seasons, the Last Span, Endless and three endings; polish only afterwards.
- RB6: every milestone ends in something playable.

## Ideas most likely to be lost in a compressed brief

1. **U7 Falling Isn't Dying (with ST20 nets):** knocking enemies off is only a delay; the kill has to happen on the deck.
2. **P7, H4, U9:** skipped rites degrade the radar, which makes mourning mechanically compulsory.
3. **Y3, J1, ST28:** names fade, the call-or-carry trade-off, and limited forearm slots.
4. **Y1, Y5, Y8, Y4:** the guards that keep "the bridge is the budget" from being exploited.
5. **U4, U5, U8:** noise, light and worn paths are how the player steers a wave.
6. **R4 with F7:** the defense must hold while you are below, and a fall becomes a forced expedition.
7. **O6 and O7:** one new thing per night; hear it a night before you see it.
8. **RB9 and RB11:** a one-action name call, and one consistent tell per exception.
9. **Q7, Q8, ST26, G8:** fatigue, shifts and breakfast make trust a staffing mechanic.
10. **CAM1 and CAM4:** the overhead view shows only what is lit or heard, and at night it costs you the ability to rig.
