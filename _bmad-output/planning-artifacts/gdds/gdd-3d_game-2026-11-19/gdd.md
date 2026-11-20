---
title: The Mourning Watch (working title)
game_type: tower-defense
secondary_game_type: horror
platforms: [Windows, Linux]
created: 2026-11-19
updated: 2026-11-20
status: draft 0.7 (architecture decisions written back; GD-68 and GD-69 added at the readiness check)
architecture: ../../../game-architecture.md
ux_documents: ../../ux-designs/ux-3d_game-2026-11-19/
---

# The Mourning Watch - Game Design Document

**Author:** Sonlm
**Game Type:** Tower defense (day/night build-and-defend, played up close), with horror sections
**Target Platform(s):** Windows first, Linux alongside (itch.io, free)

**How to read this document**

- The **one-night game** is specified in full. The **Fog Season** is outlined. Later seasons are out of scope.
- Every number is a starting value to tune at gate 2, unless it is marked as measured.
- What still has to be proven by playtest is listed under Assumptions and Dependencies.
- Decision IDs (GD-n) point to `decision-log.md`. IN-n IDs are the inputs listed at the top of that log: what the brief and the ear test fixed before this document was written. Brainstorm IDs (for example ST4, G11) point to the brainstorming session.
- Screens, the night's surfaces (hands, forearm, flames, captions) and the details of input are specified in `../../ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md` and `DESIGN.md`. UX-n IDs point to that folder's `.decision-log.md`. This document keeps the rules of play and cites them.
- "The dead" are the enemies. A "section" is one of the six parts of the span. The dead "fall" (gone until dawn) or are "released" (gone for good, by name).
- A lantern is "lit" when its shutter is open and its tank is not empty. A section is "open" when nothing can stand on it. A "placed" lantern is one hung on a pole. A "toll" is the town bell's tolling at the start of a wave, made of one to six strokes. A "run" is one night: every night start is a new run (GD-52).
- "The tune" is the voice of the one who keeps coming back. "The hum" is that same tune, faint, heard over the carved name.
- Named here but not specified, because they are later content: the Carrion Choir (an enemy whose singing covers other cries), wave-breakers (boss-scale dead), the holdout (an ally who knows the truth).

---

## Executive Summary

### Core Concept

The Mourning Watch is a free, single-player tower defense game for PC, played up close and by ear. The player is the warden, an unarmed engineer holding a bridge over an abyss where nothing stays dead, except on the bridge.

By day the warden plans from above: strips the bridge for parts and sets rigs and lanterns. By night the warden stands on the deck in first person, listens for where the dead are coming from, and springs the rigs by hand until dawn.

- **Core fantasy:** "hold a bridge against the dead with nothing but your wits, your ears and the bridge itself."
- **Vision:** "make players feel clever for barely surviving the dead, then make them care who the dead were."
- **Feeling:** "pride, then peace." Every dawn: "I barely made it, and I was clever enough." At the end: "I remember them."
- **Public pitch (spoiler-free, store text):** "Tear apart the bridge you're defending, just to survive the night. A tower defense game you play up close and by ear: no weapons, no turrets, only a lantern, your ears and the bridge itself."
- **Full pitch (reveals the truth, internal only):** each night the warden listens, then rigs, collapses and strips the bridge to barely survive until dawn. In time the warden learns that the bridge is a grave, the dead were forgotten on purpose, and the only way to end it is to remember them.

| Tier | Contents | Depth here |
|---|---|---|
| One-night game (public, free) | One span, three enemy types, two rigs, one ally, the bell, one name. One sitting of about 21 minutes. | Full |
| The Fog Season (first full release) | Prologue, 5 nights and a closing night. About five spans, four enemy types, 1 to 2 allies, a handful of names. About 2 to 3 hours. | Outline |
| Later seasons (free updates, "if it lands") | Swell and Wind seasons, the full truth, three endings, Endless mode. | Out of scope |

### Target Audience

- **Primary:** day/night strategy players aged 16 and older with some strategy experience (tower defense not required) who love *Thronefall*, *Dome Keeper* or *Kingdom Two Crowns*. Their want: "When I have an evening to myself, I want a strategy game that keeps me on edge, so I can feel clever for barely surviving."
- **Secondary:** story players, then atmosphere and horror players ("headphones in the dark").
- **How word spreads:** streamers, who "want tense moments and choices that chat will argue about", and free-game hunters, who "decide in the first minute". They are a channel, not an audience. Consequence: the first cry sounds inside the first minute.
- **Session:** the one-night game is one sitting of about 21 minutes. In the full game one day-and-night cycle is 20 to 30 minutes and dawn is the save point.

### Unique Selling Points (USPs)

1. **Tear down your own base.** Every defense is built by taking the bridge apart. This is the lead hook: the store headline and the trailer's first shot.
2. **You never hold a weapon.** Hammer, rope, bell and lantern only.
3. **Hold the bridge by ear.** No minimap, no enemy markers, no wave timer at night.
4. **Every victory has a name.** The ledger counts names learned and souls released, never kills.

None of the four is uncopyable alone. "The edge is the combination, plus executing the sound and the feel of the bridge well." The nearest competitor is *A Shot in the Dark* (itch.io, free, audio-only tower defense, armed).

---

## Goals and Context

### Project Goals

1. Pass gate 2 with the one-night game. The pass mark is in Success Metrics.
2. Release the one-night game free on itch.io ("$0 or donate") for Windows and Linux.
3. Find out with newcomers whether play by ear holds under real game conditions.
4. Give architecture a design that grows into the Fog Season without rebuilding the span, the ear or the dead.

Not goals: revenue (any tips are saved toward Steam's $100 fee), a Steam release, a Mac build.

### Background and Rationale

**Constraints.** Sonlm works solo, in Godot only, 5 to 10 hours a week, on a $0 budget. All art, animation, audio and writing are sourced. Every asset and AI output "must allow commercial use (such as CC0 or CC-BY)". "AI only drafts text and helps with art and sound effects, and Sonlm edits everything." The itch.io page discloses AI use. Nothing is AI-voiced.

**Cut-list rule.** "Anything outside the one-night game has to earn its way in." Every feature has a tier: one-night game, Fog Season, later update, or never.

**Inspiration.** The web novel and manhwa *Tyrant of the Tower Defense Game*: keep the feeling of barely surviving through clever use of scarce means, and leave everything else. Steer clear of "Tyrant" and "Defense Game" in titles, tank and damage-dealer party roles, a "pulled into a game world" frame, and diorama pixel art over 3D backgrounds.

**References.**

| Reference | Take | Leave |
|---|---|---|
| *Thronefall* | The day/night build-and-defend cycle; short, readable runs | Top-down nights; an armed hero |
| *Dome Keeper* | "Going below costs you defense time" | Shooting from the dome |
| *Orcs Must Die!* | Traps sprung by hand, up close | Weapons; kill-combo scoring |
| *Spiritfarer* | Helping the dead move on | Cozy management |
| *Return of the Obra Dinn* | Names as the reward for close attention | The deduction-puzzle format |

**Gate 1, the ear test: closed 2026-11-19 without meeting its pass mark.** The mark was five outside players right on both direction and level 8 times out of 10. Sonlm closed the gate on their own two sessions and skipped the outside players. Measured results, real cries, 24 scored trials per device, one practiced listener who knows the design:

| Measure | Headphones | Speakers |
|---|---|---|
| Direction right | 95.8% | 87.5% |
| Level right | 62.5% | 62.5% |
| Both right (pass mark 80%) | 62.5% | 62.5% |

- Level was right on 8 of 9 trials where the kind of cry matched its own level. That figure is pooled from the two sessions, which mixed kinds across levels; one kind per level was never run as its own session.
- The three direction misses on speakers were all rail cries from below, heard as coming from the town.
- Not covered by the test: several cries at once, moving sources, a walking player, ambience under the cries, and distance (every source sat at a fixed spot with distance loudness switched off).

The test changed three things for Sonlm, and each became a mechanic (GD-4):

1. **Level is the weak cue.** Three extra cues now carry level: place, the bridge, and the ally (GD-7).
2. **It takes practice.** The night opens with a dusk lesson (GD-8).
3. **Ears alone aren't enough.** Visual cues are on for everyone, wherever light falls (GD-9, UX-29).

**Timing.** The ear test ran from 12 to 19 November 2026, against the brief's guess of about 2 months. Hours were not recorded.

---

## Core Gameplay

### Game Pillars

1. **Unarmed, not helpless.** "Every death comes from the bridge and your rigs, never your hands. Your tools (hammer, rope, bell, lantern) hit like weapons." *Rules out:* weapons of any kind, and turrets that fire on their own.
   - In the one-night game nothing dies. Rigs and collapses make the dead fall, and a fall lasts until dawn. Only the name releases.
2. **Hold it by ear.** "Sound is how you scout, keep time and read the night. Every threat that can hurt you can be heard in time; anything that muffles your hearing (wind, the Carrion Choir) announces itself first; and every visual cue points to a sound rather than replacing it." *Rules out:* minimaps, enemy markers and wave timers at night.
3. **The bridge is everything.** "It's your base, budget, weapon, map and health bar. Every rig is built from a piece of it. A broken span means falling back to the next pier, and the game ends only when the last pier falls." *Rules out:* shops, gold, and any location that isn't the bridge or what it stands on.
   - Amended by GD-10: the depths are the bridge's own piers and foundations.
   - Amended by GD-12: in the one-night game the town's lights are a second way to lose.
4. **Every victory has a name.** "You win by remembering: names release the dead for good, and the ledger counts names learned and souls released." *Rules out:* kill counters, scores and combo meters.

How the one-night game answers each pillar:

| Pillar | In the one-night game |
|---|---|
| 1 | Two rigs sprung by a hammer blow. No way to harm the dead directly: a blow on a hook only delays. |
| 2 | Each level has its own cry and its own place. The town bell is the clock. Visual cues exist only where light falls. |
| 3 | 48 planks and 12 ropes, all of them on the span. Every spring of a rig spends one. Section strength is the health bar. |
| 4 | One name, found by stripping the bridge. The dawn ledger lists the name learned and the soul released, with no count of the fallen. |

### Core Gameplay Loop

**One sitting, about 21 minutes:**

| Phase | Length | View | What happens |
|---|---|---|---|
| Dusk lesson | 3 min | First person | On a dark screen, one stroke of the town bell: left or right? The player can ring it again, or answer "I can't hear it", which offers the Cues everywhere setting (UX-20, UX-38). Two wrong answers offer a setting that swaps left and right, warn that the sound may be single-channel (brainstorm JB4), and make the same offer. Then three harmless dead, one per level; the first cry starts within 15 s. Each cry repeats until the warden faces within 45° of it; the ally confirms a right turn. After each playing the warden has not faced, the ally says "listen again"; after three, the place shows its cue (the ropes shake, the fog swirls or the dust falls), which the lesson holds back until then. The first cry is also the lesson in looking, and walking is prompted once it has been faced. Then about a minute of hands, each step with a one-line key prompt: strike a practice pin on the landing, strip a plank, hang and shutter the lantern, raise the forearm (UX-22). That part ends when all four are done, and the span and lanterns are put back before planning. |
| Planning | About 4 min, untimed | From above | No dead. The warden strips sections and places rigs and lanterns, then rings the bell, a 1 s hold. |
| The night | 12 min | First person | Six waves. The night loop below. |
| Dawn | 2 min | From above | Silence, then the ledger. |

On a first launch one question comes before the lesson: headphones or speakers? The answer changes no cue (UX-19). Once the lesson has been finished on this machine, Begin the watch offers to skip it, and the left/right check with it (UX-21).

**The night loop, once per wave:**

1. **Hear.** A cry starts. Its kind gives the level, its direction gives the side, its loudness gives how far. (Pillar 2)
2. **Rig.** The warden goes there and readies what stands there: hauls a trapdoor up, re-hangs a beam, moves a lantern. (Pillars 1, 3)
3. **Hold.** The warden springs the rig by hand at the moment it catches the most. (Pillar 1)
4. **Salvage.** Every spring spends a part: a plank for a trapdoor, a rope for a swing-beam (GD-41). In the lull the warden strips more from the bridge to pay for the next wave. (Pillar 3)

The loop closes because parts come only from the bridge and every spring spends one. Each wave leaves the bridge weaker and the next wave is larger, so the pressure rises without a difficulty setting. The one who keeps coming back returns every wave from wave 2 until the warden finds its name and calls it. (Pillar 4)

**Why play it again.** The plan changes the night: which rails stand decides where Grapplers land, where the lanterns hang decides where Divers land, and the section hiding the name changes each run.

### Win/Loss Conditions

- **Dawn** comes on the clock, 12 minutes after the first toll. Any of the dead still on the span sink back below and do not count as crossings. If the night would be lost in the same instant as dawn, it is dawn, and what happened in that instant does not count: the window stays lit, the section stands (GD-59, GD-67). There is no victory screen.
- **The night is lost** when either happens (GD-12):
  - section 6, the last section at the town pier, falls for good; or
  - the last of the town's 12 lit windows goes dark.
- **Crossing.** One of the dead crosses when it steps off section 6 onto the town pier landing.
- **Windows.** Each crossing puts one window out. Hatchlings put one out for every two that cross, counted across the night; one left over puts out nothing. The windows are behind the warden and visible from the deck. Each window going out makes one small sound from the town side. After a single hatchling's crossing, the next window to go flickers low until a second hatchling puts it out (UX-30, UX-37). A full crossing during a flicker puts that window out, and the next window takes up the flicker.
- **A lost night** replays from the planning phase, with one new hint in the journal. Planning opens on the plan that night was started with (UX-40). Every night start is a new run: the name and its section are rolled again and the forearm is blank, while the journal carries over (GD-52). On a replay whatever fell or was spent during the night is back as that plan had it, and all three lanterns and the spare flask are full (GD-58). The lesson is not replayed. At the moment of loss the cries cut to wind, the view goes dark, and the journal opens on the hint (UX-12).
- **Journal hints.** There are six, one per cause. The hint added is for whichever cost the most that night: Grapplers crossing; Divers crossing; hatchlings crossing; section 6 overloaded; section 6 torn up by hooks; the one who keeps coming back crossing three or more times. The cause is found in this order. If section 6 fell: torn up by hooks if a hook tore any plank from it that night, otherwise overloaded. Otherwise the kind that put out the most windows: Grapplers, Divers or hatchlings, a tie going to the earlier in that list. Crossings by the one who keeps coming back count with the Grapplers', unless it crossed three or more times, in which case its own hint is the one. Each hint is one or two plain sentences about the cause, never about a score (UX-31).
- **A repeated cause.** If that cause's hint is already in the journal, it is shown again and nothing new is written (UX-41). Hints last for as long as the game is running, including a return to the title, and are gone when the game is closed (GD-58).
- **Not a loss:** sections 1 to 5 falling; the warden being caught (a wound, below); running out of oil.

**The dawn ledger.** Dawn opens with every cry stopped: an earned silence. The ally speaks their one dawn line. Then the ledger lists, in this order (GD-53):

- sections standing, of 6
- windows lit, of 12
- planks and ropes left
- wounds taken
- names learned: the name and its one-line epitaph, or "None"
- souls released: "One", or "None"
- "The fallen will return." No number. It is always the last line.

The ledger is a page beside the span, written in one line at a time while the bridge stays in view. It ends with two choices: another night, which opens planning on a fresh span (GD-52), or leave (UX-14). It never shows a kill count or a score. Its purpose is the brief's dawn feeling: "I barely made it, and I was clever enough."

---

## Game Mechanics

### Primary Mechanics

#### 1. Listening

**Level.** Each level has one kind of cry, one kind of place, one visual cue and one call from the ally. A kind of cry never appears at another level.

| Level | Cry | Arrives at | The bridge shows | Ally calls |
|---|---|---|---|---|
| Below | Whispers | The left or right rail | That rail's ropes shake | "Below!" |
| Above | Shrieks | The open deck | The fog overhead swirls | "Above!" |
| Inside | Sobbing | A pier | Dust falls from that pier's stones | "In the walls!" |

**One named exception.** The one who keeps coming back sings a low, wordless tune where a Grappler would whisper. The tune is a fourth voice on the level below, at the same kind of place. The ear re-check covers it.

**A hook on the deck.** A Grappler with no free rail hooks the deck (Game Mechanics 3). It picks the left or right edge of that section at random; its warning sounds from under that edge, and that edge's planks rattle, in the same cue modes as the shaking ropes.

**Direction and distance.**

- **Side** comes from stereo placement that follows the warden's head as it turns. (Measured.)
- **Behind is duller.** A cry straight behind the warden has its treble above 2 kHz cut by up to 10 dB and is up to 2 dB quieter; at the side it is half of each. It brightens as the warden turns to face it. (Measured.)
- **Equal at equal distance.** Any two cries at the same distance play within 1 LU of each other, measured straight ahead before the rear shadow. Loudness therefore never gives away level. This is re-measured whenever a clip or a sound setting changes. (Measured.)
- **Farther is quieter** (GD-40, GD-56). A cry loses 0.6 dB for each metre of distance along the span, which is 3 dB per 5 m section, up to 15 dB at 25 m. It changes smoothly as the warden walks, with no jump at a section's edge. Only distance along the span counts: height and sideways offset do not, so a Diver overhead and a Grappler under the rail of the same section are equally loud. This is how the warden hears how far. One section's 3 dB is wider than the rear shadow's 2 dB, so "far" and "behind" do not sound alike. (Not measured: the ear test had no distance.)
- **Room sound is atmosphere, not a cue.** Above is thin and open, inside is muffled and boxed in, below has a long cave echo.

**Warnings.** Every threat warns before it can affect the bridge. Each warning is built from whole 4.3 s clips.

| Threat | Warning | Made of |
|---|---|---|
| Grappler | 6 s | One whisper, then 1.7 s of straining rope |
| Diver | 8 s | Two shrieks, the second starting 3.7 s after the first |
| Nest | 40 s | Seven sobs, the gaps between them closing from about 3.3 s to none. The sobs quicken; they do not get louder. |
| The one who keeps coming back | 6 s | One phrase of the tune, then 1.7 s of straining rope |

A warning sounds from where the threat will arrive: under the chosen rail, over the chosen section, inside the pier.

**During the night.**

- On the deck each of the dead repeats its own cry every 8 s and adds footsteps on the planks.
- Never more than 4 cries at once. The tune counts as a cry; the hum, the tune's resolving last phrase, falling cries, the ally and ambience do not.
- **Warnings come first** (GD-57). A warning sounds for its whole length. If all four places are taken when one is due, the cry of the dead farthest from the warden on the deck fades out in 0.1 s to make room. The tune is never the cry that is cut (GD-65).
- Two warnings never start within 1.5 s of each other. A warning that cannot start, because of that gap or because four warnings are already sounding, waits; its threat waits with it, so nothing ever arrives on less than its full warning.
- A cry on the deck that finds no free place is skipped, and that one of the dead tries again at its next 8 s mark. The tune takes a free place before any other cry on the deck, because it is how the player hears that the bell will work; after it, the nearest to the warden come first (GD-65). While four warnings are sounding, as happens for a few seconds in wave 6, not even the tune sounds. Footsteps always remain.
- Anything that falls lets out a cry that fades into the dark over 2 s. "That sound is the payoff for a perfectly sprung trap" (brainstorm #14). It does not count toward the limit. At most three falling cries sound at once; a fall while three are still fading is silent (GD-57, GD-65).
- Ambience (creaks, wind, the town bell) sits at least 6 dB under the quietest a cry can be, which is far and behind: 23 dB under a near one. There is no music.

**Every sound has a visual cue.** The brief promises this. Cues show wherever light falls: the three lanterns and the town gate (GD-9, UX-29). A cue lasts for the whole of its warning. The three level cues extend the brainstorm's G11; the leaning flame is G11 itself.

| Sound | Visual cue |
|---|---|
| A cry's level | The table above: shaking ropes, swirling fog, falling dust; rattling planks for a hook on the deck |
| A cry's side | A lit lantern's flame leans toward the nearest cry sounding inside its own light |
| The hum over the carved name | The carried lantern's flame leans toward that section within 3 m, only while the hum can be heard: that is, while no cry is sounding |
| The tune of the one who keeps coming back | Its rail's ropes sway in time with it |
| Footsteps, a hook landing, a fall | The event itself, seen in the light |
| A section's creak and groan | Its planks bow |
| The town bell's toll | The ally chalks one tally on the board at the town pier, one for each wave |
| A window going out | The window itself; a lone hatchling's crossing makes one flicker low |
| A flame sputtering near empty | The flame shrinks, and the lantern's glass shows the level |
| The ally's calls | A caption on screen, always, in every cue mode (UX-1) |
| A wounded ear | The view darkens on that side |

In the dark there are no visual cues. The safety net there is the ally's call, and the Cues everywhere setting.

**One setting, three cue modes** (UX-3, UX-25, UX-27, UX-28, UX-38). Cues everywhere is for players who cannot rely on hearing. Ears only is a challenge.

| | In the light (default) | Everywhere | Ears only |
|---|---|---|---|
| Cues that point at a cry or the hum: shaking ropes, swirling fog, falling dust, swaying ropes, leaning flames, rattling planks at a hook on the deck | Where light falls | Also in the dark: the cue itself glows faintly and nothing else is revealed; a flame leans toward the nearest cry even beyond its own light | Off |
| Footsteps of the dead on the deck; bowing planks | Where light falls | Also glow faintly in the dark | Where light falls |
| A shuttered lantern | No lean | Its seam glow still leans | No lean |
| Every lit flame dips once for each stroke of the bell | No | Yes | No |
| The ally's calls | By wave (Game Mechanics 8) | Every warning, 2 s in, all night | By wave |
| Captions, the wound's darkened side, chalk tallies, anything seen in the light | On | On | On |

Starting value for the glow: it can be made out from 15 m, half the span, at default brightness. It is tuned on the muted night.

#### 2. The span

(GD-19)

- The span is the Gorge Causeway's last span before the town: 6 sections, each 5 m long and 5 m wide, 30 m in all. Section 1 touches the far pier, section 6 the town pier.
- Each section has 8 planks and 2 rail ropes (left and right). The span holds 48 planks and 12 ropes. The warden starts with none in hand.
- Planks are a count per section, not positions. A section is drawn with that many planks. They leave in a fixed order that keeps the rest evenly spaced, so a weakened section looks sparse and its strength can be read by eye wherever light falls (UX-8, GD-54). A section with one or more planks can be walked over its whole length.
- **Strength** = planks left on the section, 0 to 8.
- **Load** on a section:

| Source | Load |
|---|---|
| Grappler or Diver standing on it | 1 |
| A Grappler hanging from a set hook | 1 |
| A Diver landing | 5 for 0.5 s, in place of its 1 |
| Hatchling | 0.5 |
| The warden | 0 |

- **Creak.** A section creaks while its load equals its strength (brainstorm CJ3).
- **Collapse.** When load is above strength the section groans for 2 s, then falls for good. If the load drops back within the 2 s, it holds.
- **A Diver's landing** counts 5 on top of whatever already stands there. If that total is above strength, the section falls at once. An empty section breaks at 4 planks or fewer.
- **What falls with it:** the dead on it, a rig on it, any lantern hung on it, and the planks and ropes still on it. A warden on it catches the edge and climbs back onto the nearest standing section toward the town in 5 s, with a wound.
- **An open section** has its trapdoor down, or no planks left. Nothing can stand on it. Crossing it along its side beams takes a Grappler or Diver 12 s, a hatchling 6 s and the warden 4 s. The side beams carry a load of 2; more than that for 2 s and the section falls. Whoever stands on a section when its last plank is taken is on its side beams from that moment and finishes the crossing from where they stand, toward the town, in the share of the crossing time that the distance left is of the section (GD-68).
- **A fallen section** is a 5 m gap. A Grappler throws a hook across and crosses in 12 s. A Diver stranded beyond it takes off and dives again 8 s later, picking by the same rule among the sections on the town side. Those 8 s are a full warning: it takes one of the four places and keeps 1.5 s from other warnings, and it may sound during a lull (GD-65). Stranded hatchlings fall. The warden crosses hand over hand in 8 s.
- **Section 6** stands inside the light of the town gate. It cannot be stripped below 4 planks and nothing can be built on it. Grapplers do not hook its rails and Divers do not pick it, so its two rails are spare rope. It is reached on foot from section 5, or by the brood of the town pier's nest. The exceptions: when no other section has planks, deck hooks and Divers come to section 6; and a Diver that dives again from beyond a gap comes to section 6 when no section between the gap and the town can be picked (Game Mechanics 6).
- **Falling** (GD-13). Any of the dead that falls is gone until dawn. Nothing in the one-night game ends one of the dead on the deck.

#### 3. Stripping and re-laying

| Action | Time | Result |
|---|---|---|
| Strip a plank | 2 s | +1 plank in hand; that section's strength −1 |
| Strip a rail rope | 3 s | +1 rope in hand; no Grappler can hook that rail |
| Re-lay a plank | 3 s | −1 plank in hand; that section's strength +1. Any section that has not fallen can take one, an open one with no planks included (GD-69) |
| Dismantle a rig | 4 s | Its planks return; one of its ropes is lost |

- The warden carries stripped parts, with no limit. Parts in hand are kept through every wound, climb and crossing. The forearm shows tallies of planks and ropes in hand.
- In the planning phase stripping and placing cost no time.
- A rail is locked, and cannot be stripped, from the moment a Grappler's warning starts under it until that Grappler is on the deck or has fallen.
- A rail that holds a swing-beam cannot be stripped.

**No rail, no hook** (GD-20). Grapplers hook only a rail that still stands, on sections 1 to 5, and a rail holds at most 2 hooks, counting a warning that has started under it. Fewer rails means they bunch on those sections and overload them. A Grappler that finds no free rail hooks the deck instead: the edge of the section with the most planks (the one nearer the far pier if several are equal), tearing one plank off as the hook lands. It picks the left or right edge of that section at random.

**Striking a hook** (GD-38). A hammer blow on a set hook, 0.5 s, makes the Grappler lose its grip and start its 6 s haul again. The hook stays set and keeps its load. Each Grappler can be shaken loose once; after that its hook holds. Nothing is removed by hand.

**A Grappler, step by step.**

| Step | Lasts | Load on the section | Answered by |
|---|---|---|---|
| Warning under the chosen rail | 6 s | 0 | Readying a rig. The rail is now locked. |
| The hook lands; the Grappler hangs and hauls | 6 s, or 12 s if shaken loose | 1 | A swing-beam; one hammer blow |
| On the deck, walking | Until it crosses or falls | 1 | Either rig; overload |

The hook is gone once the Grappler is on the deck. If its section falls or is swept while it hangs, it falls.

#### 4. Rigs

One rig per section, on sections 1 to 5. Section 6 cannot hold a rig. Each rig is sprung from its section's town-side edge, so the warden stands on the next section toward the town. A rig is built, hauled up, re-hung and dismantled from that same edge: the warden stands within 2 m of it on the next section toward the town and looks at the section ahead (UX-9). While that next section is open or fallen there is nowhere to stand, and the rig cannot be worked. A blow struck from the rig's own section still springs it.

| | Trapdoor | Swing-beam |
|---|---|---|
| Cost to build | 2 ropes | 4 planks + 2 ropes |
| Needs | 4 or more planks on its section | A standing rail on its section, picked when it is built: at night the rail on the side the warden is looking toward when the hold starts, in planning the rail that is clicked (UX-9). The beam hangs from it |
| Build time at night | 8 s | 12 s |
| Sprung by | A hammer blow on its pin | A hammer blow that cuts its holding rope |
| Effect | The planks drop within 0.3 s. Everything on the section falls. | The beam sweeps the section in 1.5 s. Everything standing on it or edging along its side beams, and every hook on its rails or deck edge, is knocked off. |
| Each spring spends (GD-41) | 1 plank, lost from its section | 1 rope, for the new holding rope |
| Reset | Haul it up: hold for 6 s | Re-hang: hold for 10 s, with a rope in hand |
| While sprung | The section is open | The section is clear and can be walked on |
| Cannot be sprung when | Its section has fewer than 4 planks | It has not been re-hung |
| Danger | A warden standing on it when it drops catches the edge, climbs back toward the town in 5 s and is wounded | A warden on the section is knocked down and wounded |

The warden can also use the bridge with no rig: strip a section to just under the weight of what is about to stand on it, and it collapses under them. That section is then lost for good.

#### 5. The wedge

A nest sobs inside a pier for 40 s before it hatches. The warden hammers a wedge into the cracked stone: 3 s of unbroken hammering, 1 plank. The nest stays shut for the rest of that wave. A wedge can only be driven while the nest is sobbing. (GD-17, GD-19)

#### 6. Lanterns and light

(GD-9, GD-28; reach corrected at finalize)

- 3 lanterns: one carried, two placed during planning. Each of the six sections has one pole. It stands on a side beam and holds the lantern over the centre of the section, 2.5 m from each edge; a placed lantern hangs there.
- **One lantern in hand** (GD-49). At a pole the warden hangs the lantern in hand, takes the one hanging there, or swaps the two. With no lantern in hand the warden carries no light. Hanging, taking and swapping are each one press. The warden keeps the lantern in hand, lit, through every hold, wound, climb and crossing, and it still counts as carried. A lantern over an open section cannot be reached until that section can be stood on again.
- **At the start of the night** both placed lanterns are hung, the third is in the warden's hand, and all three are full and lit.
- Light reaches 4 m from the carried lantern and 5 m from a placed one. A placed lantern lights its own section and about half of each neighbour.
- A full tank burns for 6 minutes. There is 1 spare flask. It stays at the town pier and is never carried: the warden brings a lantern to it, and a refill takes 4 s and fills that lantern's tank, once (UX-36). From the pole on section 1 the trip home and back is 55 m, about 16 s of walking. That is 24 lantern-minutes for a 12-minute night: enough for two lanterns all night, which light at most 20 m of the 30 m span.
- **Reading oil** (UX-7). Each lantern has a glass reservoir whose level can be seen up close. In the last 60 s of a tank the flame shrinks and sputters; its reach does not change. A shuttered lantern glows through its seams; an empty one is dark.
- **Shutter.** A closed lantern gives no light, burns no oil, and cannot be seen by Divers.
- **Visual cues show only where light falls:** the three lanterns, and the town gate's light on section 6, which cannot be shuttered or moved (UX-29). The dark is sound only, unless Cues everywhere is on.
- A hung lantern survives a trapdoor drop and a beam's sweep. It is lost if its section falls.

**Divers and light.** A Diver picks its section when its warning starts, and its shrieks and the swirling fog come from over that section:

1. The section with a lit hung lantern. If more than one is lit, the one nearest the town.
2. Otherwise the section the warden stands on, if the carried lantern is lit.
3. Otherwise the section with the fewest planks; if several are equal, the one nearer the town.

- Only sections 1 to 5 that have planks and are not open when the warning starts can be picked. A lantern on section 6 or on the landing is ignored.
- If no such section exists, the Diver comes down on section 6.
- Once the warning has started, moving or shuttering a lantern does not change the pick.
- If the picked section is open or fallen when the warning ends, the Diver lands on the nearest of sections 1 to 5 that has planks and is not open, looking toward the town first and then toward the far pier. Only if there is none does it come down on section 6.
- If the section it is coming down on opens or falls after the warning has ended, during the Diver's 1 s drop, the Diver falls through and is gone until dawn (GD-60). A trapdoor sprung in that second catches it before it lands. A trapdoor's section is open from the moment of the blow. A Diver that lands while a beam is sweeping its section is swept off.

#### 7. The bell and the name

(GD-14, GD-25)

- One section, chosen at random from sections 2 to 5 each run, has a name carved in the timber under its planks.
- The hum, 12 dB under a cry, can be heard within 3 m of that section whenever no cry is sounding. It is the tune of the one who keeps coming back, which is how the player connects the two.
- The name is uncovered when that section is down to 4 planks or fewer. It can only be read on foot, at night, by lantern light: the warden looks at it from within 2 m for about 1 s (UX-10). The planning view never shows what lies under the planks. Once read, it is inked on the warden's forearm, which rises once on its own to show it.
- **The one who keeps coming back** arrives once per wave from wave 2. It behaves as a Grappler but sings the tune. Whether it falls or crosses, it is back in the next wave.
- **Calling the name:** one pull of the bell rope at the town pier (1 s), after the name has been read, while its owner is on or under the span. The owner stops and passes in peace, and never returns. If the owner is still in its warning, the warning stops, its rail unlocks and no hook lands. Every other one of the dead on or under the span stands still for 20 s (GD-61, GD-64):
  - Everything the dead were doing stops and resumes afterwards: walking, a Grappler's haul (its hook keeps its load), a Diver's recovery, a crossing along side beams or over a gap, a stranded Diver's wait.
  - They fall silent: no cries on the deck and no footsteps for the 20 s.
  - Warnings already sounding finish, and what they announce arrives: the hook lands, the Diver lands with its load of 5, the hatchlings break out. Whatever arrives during the 20 s stands still until they end. So does the threat of a warning that starts during them.
  - The bridge and the rigs do not stop: loads, creaks, collapses, a sprung rig and a blow on a hook all act on the standing dead as usual.
  - The wave's timetable and the clock to dawn keep running. The ledger records one name learned and one soul released.
- **A wrong ring** (GD-42). A pull that calls no one, because the name is unread or the owner is absent, is only noise. Every one of the dead walking the span walks half again as fast for 10 s; a Grappler's haul is not hurried. A wrong ring during the 20 s of stillness does nothing, and a right ring ends a hurry (GD-64).

#### 8. The ally

(GD-7c, GD-26, GD-39) The one ally is the survivor who understands the voices.

- Stands at the town pier and cannot be hurt in the one-night game.
- **Waves 1 to 3:** calls the level about 2 s after each warning starts: "Below!", "Above!", "In the walls!".
- **Waves 4 to 6:** calls only when the warden has not turned to within 45° of a warning 4 s after it starts. The ear leads and the ally catches what it misses.
- One call at a time. A call is due 2 s after its warning starts in waves 1 to 3, and 4 s after in waves 4 to 6. A call that cannot start within 4 s of when it was due is dropped.
- **In Cues everywhere** the waves 1 to 3 rule runs all night: every warning is called 2 s in (UX-38). The fade from wave 4 belongs to the other two cue modes.
- About 10 recorded lines, each with a matching caption: one line at the bottom centre of the view, shown for as long as the line is spoken and at least 2 s, in every cue mode (UX-1, UX-26):

| Lines | Purpose |
|---|---|
| 3 | The level calls |
| 3 | The dusk lesson: an opening line, a confirming word, and "listen again". The confirming word is not "right", which reads as a direction straight after the left/right check. |
| 1 | The first time the one who keeps coming back returns |
| 2 | Warmth in a lull, not information (the brief's "warmth between the waves") |
| 1 | Dawn, after the silence and before the ledger (GD-53) |

#### 9. Wounds

(GD-27) The dead want the town, not the warden.

- One that reaches the warden shoves past. The warden is knocked down for 1.5 s. For 20 s sounds on that side are up to 12 dB quieter, and the view darkens on that side (GD-62, GD-66).
  - The side is the warden's own and turns with the head. The cut grows from nothing straight ahead or behind to the full 12 dB directly at that side, so nothing jumps as the warden turns.
  - It applies to every sound that has a place: cries, the tune and the hum, footsteps, hooks, creaks, both bells, the windows, the wind. The ally's voice and the warden's own hands are never cut.
  - Cries, the tune and the wind are also dulled, by up to 10 dB above 1 kHz, growing in the same way. Footsteps, hooks and creaks keep their tone.
- The same wound follows a hit from the warden's own swing-beam, a Diver landing on the warden's section, or a section falling under the warden.
- The warden is knocked down where they stand. The wound is on the side the blow came from; a fall or a landing has no side, so its side is picked at random. A new wound starts its own 20 s on its own side, and both sides can be wounded at once. A second wound on a side already wounded restarts that side's 20 s; the cut does not grow.
- There is no health bar. The warden cannot die in the one-night game.

#### 10. Planning from above

(GD-11)

- An overhead view of the whole span, with no dead and no time limit.
- The warden strips planks and rail ropes, places trapdoors and swing-beams on sections 1 to 5, and hangs the two placed lanterns. Every choice can be undone until the night starts: right click takes back the last choice on a section, and Start over, a 1 s hold, restores the whole span (UX-17). An undo that needs a part no longer in hand, because it was spent on a rig elsewhere, is refused and says why.
- The view shows each section's planks and rails, and its strength as a number. A tray shows the planks and ropes in hand, the three tools with their costs, and the lanterns left to place. A tool that cannot be afforded is dimmed; pointing at it, or at a section where the chosen tool cannot go, says why (UX-15).
- A click on a section's deck strips its next plank, in the same fixed order the night draws, which keeps the rest evenly spaced. A click on a rail strips that rail (UX-16, GD-54).
- The view does not show what lies under the planks, and it does not use the woodcut look.
- Ringing the bell, a 1 s hold of Space, ends planning and starts the night. It cannot be rung until both placed lanterns are hung, and it says why. The night starts with the warden on the town pier landing. The warden's bell rings and the town bell answers with the single toll of wave 1 (UX-18).
- After a lost night, planning opens on the plan that night was started with (UX-40). It can be undone in the same way. After a dawn, Another night opens a fresh span (GD-52).

### Controls and Input

Keyboard and mouse only in the one-night game. Gamepad arrives with the Fog Season. (GD-22)

**Context hands.** The left mouse button is the hammer hand and the right is the lantern and rope hand. The game picks the action from what the warden is looking at within 2 m, and the hands show that action before the click: a hand that can act moves to a ready pose, and no pose means no action there (UX-5).

Night, first person:

| Input | Action |
|---|---|
| W A S D | Walk at 3.5 m/s. No sprint, no jump. |
| Mouse | Look |
| Left mouse (hammer hand) | Strike a pin, a holding rope or a hook (0.5 s); strip a plank (hold 2 s); hammer a wedge (hold 3 s) |
| Right mouse (rope and lantern hand) | Strip a rail rope (hold 3 s); haul a trapdoor (hold 6 s); re-hang a beam (hold 10 s); pull the bell rope (hold 1 s) |
| E | Acts on what the warden looks at (UX-36). At a pole: hang, take or swap a lantern (one press). At a standing section with fewer than 8 planks, with a plank in hand: re-lay one (hold 3 s). At the flask on the town pier, with a lantern in hand: refill it (hold 4 s). |
| F | Open or close a shutter: that of a hung lantern the warden is looking at within 2 m, otherwise that of the lantern in hand |
| 1 (hold 8 s) | Build a trapdoor on the section ahead |
| 2 (hold 12 s) | Build a swing-beam on the section ahead, on the rail the warden is looking toward |
| R (hold 4 s) | Dismantle the rig ahead |
| Tab (hold) | Raise the forearm: the name, if read, and the tallies of planks and ropes in hand. The warden can still walk and look; neither hand can act until it is lowered; ignored during a hold (UX-11). |
| Esc | Pause: everything stops and falls silent (UX-24) |

"The section ahead" is the one whose town-side edge the warden stands at: within 2 m of that edge, on the next section toward the town, looking at it. There the hands take out the tool, which is the sign that 1, 2 and R will act (UX-9).

Planning, from above:

| Input | Action |
|---|---|
| Left click on a section's deck, with no tool chosen | Strip its next plank |
| Left click on a rail, with no tool chosen | Strip it |
| Left click on a section, with a rig or lantern chosen | Place it there. A swing-beam is placed by clicking the rail it will hang from. |
| Right click | Undo the last choice on that section |
| 1, 2, 3 | Choose trapdoor, swing-beam, lantern. The same key again, or Esc, puts the tool away. |
| Space (hold 1 s) | Ring the bell: start the night |
| Start over (hold 1 s, on the tray) | Restore the whole span to dusk |
| J | Open the journal, once it holds a hint |
| Esc | Pause, when no tool is chosen |

Held actions are cancelled by moving more than 0.5 m, by a wound, by letting go, or the moment the action becomes impossible (a rail locks, a section falls or opens, a nest hatches); looking around is free. Only one action runs at a time. Parts are gained or spent when a hold completes, and a pause freezes a hold without cancelling it. With the Holds setting on Press once, a press starts a hold and a second press stops it; the times are the same, and Tab becomes a toggle (UX-39). Planning's two 1 s holds stay holds in both settings, because they exist to stop a stray press. The blow of a strike lands at the end of its 0.5 s.

**What the player sees and hears of an action at night** (UX-2, UX-4, UX-6). There are no prompts, bars or rings. A hold is its own progress: counted hammer blows, rope coming in hand over hand, a plank levering up, each closing on a heavier final beat. A cancelled hold drops from the hand with a slack-rope or dropped-tool sound. An impossible action makes the hand reach, stop short and open empty, with a dull knock; a second strike on a hook already shaken once is one such. The dusk lesson practises look, walk, strike, strip, hang, shutter and the forearm. Every other key (haul, re-hang, build, dismantle, the wedge, the bell rope) is learned from the key card, which can be read in planning and on the pause screen.

Keys are bound by physical position, so they sit in the same place on any keyboard layout. There is no key rebinding in the one-night game.

---

## Tower Defense Specific Design

### Rig Types and Upgrades

The rigs are the towers. There are two, and their full values are in Game Mechanics 4. Neither fires on its own (pillar 1), and each spring spends a part of the bridge (GD-41).

What answers what:

| Threat | Trapdoor (1 plank per drop) | Swing-beam (1 rope per re-hang) | Without a rig |
|---|---|---|---|
| Grappler, hook set on a rail | No effect | Knocks the hook off | One hammer blow restarts its 6 s haul, once; or strip that rail before any warning starts under it |
| Grappler on the deck | Drops it | Sweeps it off | Overload the section |
| Diver | Drops it during its 1 s drop, or after it lands | Sweeps it off after it lands | Shutter the lanterns; keep sections at 5 planks or more |
| Hatchlings | Drops the brood as it crosses | Sweeps the brood | Wedge the nest; a fallen section strands a far-pier brood |
| The one who keeps coming back | Delays it one wave | Delays it one wave | The name |

Combinations the design expects players to find:

- **Bait.** A lit lantern hung on a trapdoor section, with the trapdoor up, brings a Diver down onto it.
- **Funnel.** Stripping every rail except those beside a swing-beam makes Grapplers come up into it.
- **Slow.** An open or fully stripped section ahead of a rig costs walkers 6 to 12 s, which is time to haul or re-hang the rig behind it.

**Upgrades.** None in the one-night game: no tiers, no stat upgrades. In the full game knowledge is the upgrade (brainstorm G2): the journal unlocks the rig that answers an enemy. Contraptions that snap together (G5) are not in the one-night game.

### Enemy Wave Design

**The dead of the one-night game** (GD-15 to GD-17, GD-23, GD-25):

| | Grappler | Diver | Hollow Nester | The one who keeps coming back |
|---|---|---|---|---|
| Level and cry | Below, whispers | Above, shrieks | Inside, sobbing | Below, the tune |
| Warning | 6 s under a rail | 8 s circling overhead | 40 s, quickening | 6 s under a rail |
| Arrival | Hook lands; hauls up in 6 s | Drops in 1 s; recovers for 2 s | 4 hatchlings break out together | As a Grappler |
| Enters at | Any standing rail on sections 1 to 5 with fewer than 2 hooks; never the same rail twice running unless only one is free; with none free, the deck | The section chosen by the rule in Game Mechanics 6 | Far pier onto section 1; town pier onto section 6 | As a Grappler |
| Walks | 1.2 m/s | 1.0 m/s | Hatchlings 3.0 m/s | 1.2 m/s |
| Load | 1, from the moment its hook lands | 5 on landing, then 1 | 0.5 per hatchling | 1, from the moment its hook lands |
| If it crosses | 1 window | 1 window | Half a window per hatchling | 1 window, and it returns next wave |
| A fall | Gone until dawn | Gone until dawn | Gone until dawn | Returns next wave |

Light-hunting Divers combine two brainstorm ideas: A2 (they drop on the bridge's weakest point) and U5 with A4 (light draws them).

Time from first sound to the town, with nothing in the way:

- Grappler at section 5, the nearest it normally arrives: about 18 s. At section 1: about 35 s. (At section 6, in the exception case: about 14 s.)
- Diver on section 5: about 19 s. On section 1: about 39 s. (On section 6, in the exception case: about 14 s.)
- Hatchlings from the far pier: 40 s of sobbing, then 10 s. From the town pier: 40 s of sobbing, then 2 s. A town-pier brood can only be answered by the wedge.

**The six waves** (GD-23). Each lasts 2 minutes: warnings start in the first 75 s, and no warning starts in the 45 s lull that follows. The town bell tolls at the start of each wave: one stroke for wave 1, six for wave 6, 1.5 s apart (GD-24). A wave's clock starts at its first stroke. The toll for wave 1 answers the warden's own bell, rung to end planning (UX-18).

| Wave | Grapplers | Divers | Nests | New this wave |
|---|---|---|---|---|
| 1 | 3 | 0 | 0 | Grapplers, one at a time |
| 2 | 4 | 0 | 0 | Both rails at once. The one who keeps coming back, from here on. |
| 3 | 3 | 1 | 0 | The first Diver |
| 4 | 2 | 2 | 1 | The first nest, in the far pier |
| 5 | 5 | 2 | 1 | A nest in the town pier |
| 6 | 6 | 3 | 2 | Everything. The sky pales. |

Totals: 23 Grapplers, 8 Divers, 4 nests (16 hatchlings), and 5 visits from the one who keeps coming back. That is 44 possible crossings, counting two hatchlings as one.

**Timetable.** Seconds after the toll's first stroke at which each warning starts. G = Grappler, D = Diver, N = nest, R = the one who keeps coming back.

| Wave | Warnings start at |
|---|---|
| 1 | G 5, 30, 55 |
| 2 | R 5; G 20, 22 (opposite rails); G 50, 52 (opposite rails) |
| 3 | R 5; G 15; D 30; G 45; G 60 |
| 4 | N far pier 0; R 8; D 16; G 30; D 44; G 58 |
| 5 | N town pier 0; R 6; G 12, 14; D 24; G 36; D 48; G 58, 60 |
| 6 | N far pier 0; R 4; G 8, 10; D 18; N town pier 20; G 28, 30; D 40; G 52, 54; D 64 |

- This timetable never has more than 4 warnings sounding at once. If play delays one into a fifth place (only a stranded Diver's second dive can), it waits (Game Mechanics 1).
- In the last 10 s before the sixth toll the wind and the bridge fall silent. "In a game played by ear, silence is the scariest sound" (brainstorm).
- Dawn comes at 12:00 whatever is on the span.
- Peak: up to 18 of the dead on the span in wave 6.

**Bosses.** None in the one-night game. Wave-breakers are later content.

**Endless scaling.** Not in the one-night game or the Fog Season.

### Path and Placement Strategy

- **One goal, three ways in.** Every one of the dead is going to the town gate at the town pier. They enter at the rails (below), the piers (inside) or the open deck (above).
- **The player shapes the path by taking things away:**
  - a stripped rail removes a place to hook;
  - stripped planks make a section that breaks under weight;
  - an open section costs walkers 6 to 12 s;
  - a fallen section costs Grapplers 12 s and stops a far-pier brood.
- **Placement rules.** One rig per section, on sections 1 to 5 only. A trapdoor needs 4 or more planks; a swing-beam needs a standing rail. Piers cannot be stripped (brainstorm Y8).
- **The last line.** Section 6 holds no rig, so the last rig is on section 5 at the nearest. Anything that gets past it reaches the town. In exchange, nothing arrives on section 6 directly while any other section has planks.
- **Choke points.** Section 6, which everything must cross. The two piers, where nests hatch.
- **What the player can see.** In planning, each section shows its strength as a number, each rig shows the section it covers and each lantern shows its reach. At night nothing is marked; light shows only what it falls on.

### Economy and Resources

No gold, no shop, no income per wave or per kill (pillar 3; brainstorm Y9).

| Resource | At the start | Gained by | Spent on |
|---|---|---|---|
| Planks | 48, all on the span | Stripping (1 per 2 s) | Swing-beam 4; wedge 1; re-laying 1; each trapdoor drop 1 |
| Rope | 12, all on the span as rails | Stripping a rail (1 per 3 s) | Trapdoor 2; swing-beam 2; each re-hang 1; dismantling 1 |
| Oil | 3 full tanks, and 1 flask at the town pier: 24 lantern-minutes | Nothing | Burning: 1 lantern-minute per lit lantern per minute |
| The name | 0 | Stripping its section to 4 planks and reading it | Calling it, once |

- **Nothing is refunded in full.** Dismantling a rig returns its planks and loses one of its ropes. A fallen section takes its planks, ropes, rig and lantern with it.
- **A worked night.** Two trapdoors and one swing-beam cost 6 ropes and 4 planks. That leaves 6 rails: the beam's own, which must stay, and 5 more. Ten trapdoor drops, five re-hangs and four wedges then spend 14 more planks and those 5 rails. Rope runs out first.
- **Not in the one-night game:** echoes and food (GD-21).

### Abilities and Powers

There are no cooldowns and no ability bar. Each action below costs time, parts or oil.

| Action | Cost | Effect |
|---|---|---|
| Call the name | 1 s at the bell; once per night | Its owner passes in peace; the dead on and under the span stand still for 20 s |
| Ring the bell wrongly | Nothing spent | The dead walking the span walk half again as fast for 10 s |
| Wedge a nest | 1 plank, 3 s | That nest stays shut for the wave |
| Strike a hook | 0.5 s, at that rail; once per Grappler | That Grappler starts its 6 s haul again |
| Shutter a lantern | Nothing | No light, no cues, no burn; Divers cannot see it. In Cues everywhere its seam glow still leans. |
| Move a lantern | Travel time | Moves the lit area and the Divers' target |
| Overload a section | The section, for good | Everything on it falls |

### Difficulty and Replayability

- **One difficulty.** No difficulty levels, star ratings or scores (pillar 4).
- **Target band** (GD-23, GD-29; windows corrected at finalize). Of 44 possible crossings a first-time player stops about 35, and reaches dawn with about 3 of 6 sections and 3 of 12 windows left. 3 of 5 newcomers reach dawn within two tries.
- **The aim of the tuning:** "each night is a puzzle with scarce parts, and surviving feels earned, never lucky." Nothing in the night is random except: which rail a Grappler picks; which edge a hook on the deck takes; the side of a wound that has no side; which of the six names it is; and where the name lies (GD-58).
- **What changes between runs:** the rolls just listed (the name and its section, the Grapplers' rails, a deck hook's edge, a sideless wound's side), and the player's own plan.
- **Settings that change the challenge.** One setting, Visual cues, has three values. The table is in Game Mechanics 1.
  - **In the light:** the default.
  - **Ears only:** the cues that point at a cry are off; captions and physical events stay (GD-35, UX-3). A first step toward the brainstorm's Blind Watch, which is a later update.
  - **Cues everywhere:** those cues show in the dark too, and the ally calls every warning (accessibility; GD-9, UX-27, UX-38).
- **Settings that do not change the rules** (UX-25, UX-39): volume; headphones or speakers; swap left and right; check left and right; stream-safe sound; mono sound; centre dot; mouse sensitivity; invert look; Holds (Hold or Press once); fullscreen or window; resolution; brightness; field of view; fog quality; caption size.
- **Assists** for wave speed, numbers and structural forgiveness arrive with the Fog Season (brainstorm G12).

---

## Horror Specific Design

The horror guide's Enemy and Threat Design is covered under Enemy Wave Design. Its Puzzle Integration section does not apply: there are no locks, codes or riddles. The night itself is the puzzle.

### Atmosphere and Tension Building

- **Light.** The world is near-black, lit only by lanterns and soft fog. "The living are warm, the dead are colorless, and the abyss is true black." The town's warm windows are always behind the warden.
- **Sound.** The cries are the score; there is no music. "The bridge creaks, groans and sings." A section creaks at its limit and groans for 2 s before it falls.
- **Tension and release.** 75 s of arrivals, then a 45 s lull, six times. Ten seconds of silence precede the last wave. Dawn opens in silence too, this time earned.
- **The arc of the cries** (brainstorm E4): eerie at first, heavy once the warden knows who they were, and a release when one is laid to rest. In the one-night game the release is the moment the name is called and the tune resolves.
- **No scripted jump scares.** "The dark never cheats": every threat gives its full warning before it can affect the bridge.
- **Told in small pieces and by the place:** the name and its epitaph, the journal's hints, the windows going out, the bell. The game never states its message.

### Fear Mechanics

- **Darkness.** Visual cues exist only where light falls, and there is oil for two of three lanterns. The player is always choosing what to leave dark.
- **Light is also a target.** Divers come down where the light is, including the lantern in the warden's hand.
- **Vulnerability.** The warden has no weapon and cannot harm the dead directly. Being caught costs hearing (wounds, GD-27).
- **Noise has a price.** A bell rung for no one hurries the dead (GD-42).
- **Not used:** a sanity or fear meter; a stalker that hunts the warden. The dead want the town.

### Resource Scarcity

- **Oil:** 24 lantern-minutes for a 12-minute night with three lanterns. Nothing restocks.
- **Planks** are the building material, the trapdoor's fuel and the health bar.
- **Rope** is rig parts, the swing-beam's fuel and the rails. Each rope spent is a rail gone.
- **Saving.** The one-night game is one sitting with no save. In the full game dawn is the save point. Between launches the one-night game keeps only its settings and a note that the lesson has been finished (UX-21).

### Safe Zones and Respite

- **The town pier landing** holds the bell, the tally board, the spare flask and the ally. Nothing attacks the warden there, and Divers never land on it.
- **Lulls.** No new warning starts during the 45 s after each wave.
- **Warmth between the waves.** Two of the ally's lines are spoken in lulls and carry no information. In the Fog Season this grows into the brief's "breakfast at dawn, the dog, the allies' jokes".
- **The one planned exception:** the nests in the town pier in waves 5 and 6 hatch beside the safe place. They are announced by 40 s of sobbing.
- **Dawn** ends all threat.

---

## Progression and Balance

### Player Progression

**One-night game.** The warden gains no power. What progresses is the player:

1. In the dusk lesson the player learns the three cries with feedback, then the hands, the lantern and the forearm.
2. In waves 1 to 3 the ally's call confirms each warning 2 s after it starts.
3. From wave 4 the ally calls only the warnings the player has not turned toward within 4 s.

The player also learns the bridge: that a stripped rail steers Grapplers, that a lantern steers Divers, and that a weak section is a trap.

**Fog Season.** Knowledge is the upgrade (G2). The brief's rule is "one new thing each night"; the brainstorm's is at most one new enemy, rig or rule per night (O6). Every new threat is heard at least one night before it appears (O7). No stat tiers and no grind gates: a stuck player replays the night with a new hint (O11).

### Difficulty Curve

| Wave | What it asks | Expected |
|---|---|---|
| 1 | Go to where you heard it | Coast |
| 2 | Two places at once: rigs must do the work | First struggle |
| 3 | Decide where the light is | Steady |
| 4 | Hear a 40 s countdown under other cries, without the ally's help | Steady |
| 5 | The safe place is threatened | Struggle |
| 6 | Everything, after silence, with the bridge already spent | Barely |

The lulls are for coasting. "Barely surviving" is the intended result of wave 6, not a failure of tuning.

### Economy and Resources

Rates and costs are in Tower Defense Specific Design, Economy and Resources. The scarcity curve: planks, rope and oil all start at their maximum and only fall. By dawn a first-time player is expected to have lost about 3 sections, along with whatever was still on them, and to have one rail left: the one a swing-beam hangs from.

---

## Level Design Framework

### Level Types

**One-night game: one level.**

- The span: the last 6 sections of the Gorge Causeway before the town.
- The far pier, with a nest inside it.
- The town pier, with a nest inside it, and its landing: the gate, the bell, the tally board, the spare flask, the ally.
- The town behind: 12 lit windows, seen and never entered.
- The Far Side ahead: never seen.

**Fog Season.**

- About five spans, with piers as fallback points: "A broken span means falling back to the next pier".
- The depths, reached by the Long Stair: inside the bridge's own piers and foundations, built from the same pieces as the bridge (GD-10).
- The town: lit windows, a notice board, letters. Never entered.

### Level Progression

The Fog Season outline, to be detailed after gate 2 (GD-34):

| Night | New | Spans |
|---|---|---|
| Prologue | Your own funeral. The old warden teaches listening, the lantern, the trapdoor and the bell, then hands over the lantern. | 1 |
| 1 | Grapplers. Stripping, and the swing-beam. | 1 |
| 2 | Divers. Lanterns as bait. | 2 |
| 3 | The first trip below, down the Long Stair, for oil and the first name. The one who keeps coming back can now be named. | 2 |
| 4 | Hollow Nesters. A dropped span means falling back to the next pier. | 3 |
| 5 | The Procession on the deck. The first ally comes up from below. | 5 |
| Closing night | Nothing new: all four types at once. Then the Silence. | 5 |

- **The fourth type, the Procession** (GD-33): coffin-bearers walk the deck from the far side and do not cry. Each span rings at its own pitch under their feet (brainstorm ST2), so the warden hears how far they have come. A coffin broken on the deck lets something worse climb out, so they must be dropped, not struck.
- **Rhythm:** days are safe in the Fog Season; dusk and dawn are the clock.
- **Arc:** the first name, the first ally, the Silence. The season has its own ending and does not reveal the full truth.
- **Rules that arrive with the Fog Season** (from the brief):
  - At dawn the warden lays the fallen to rest, then the game saves.
  - A name fades if it is not used.
  - A lost ally is gone for good. If the warden falls, an ally takes the lantern.

---

## Art and Audio Direction

### Art Style

- **Look:** "stylized, leaning to woodcut." A full-screen ink-and-hatching treatment "makes mismatched free models read as one engraving."
- **Palette:** near-black world; warm living things; colorless dead; a true black abyss.
- **No HUD at night.** Information is carried by the warden's hands, the forearm (the name, and the tallies of parts in hand), the tally board, and the bridge itself. The hands show the action a click will perform. One thing is drawn over the night view: the ally's caption (UX-1). A centre dot can be switched on in settings (UX-5). The hands and forearm keep a minimum brightness, enough to tell the ready pose with every lantern shuttered, and the forearm's ink stays clear of the hatching.
- **The overhead view** is clean and readable, without the woodcut treatment.
- **Screens** (title, planning tray, pause, settings, journal, ledger, captions) use the Lantern light look: no panels, text straight on near-black, the chosen thing glowing warm, everything else colourless grey. Its colours, type and components are in `DESIGN.md` (UX-32, UX-34).
- **Comfort limits** (`EXPERIENCE.md`, Accessibility Floor). No full-screen flash and no screen shake; full-view changes are slow fades only. Nothing flickers faster than 3 times a second: a sputter stays on the flame, and a stroke's dip takes about 0.8 s. The camera has no bob and no roll.
- **The ally** is a silhouette: a lantern, tools and a voice (brainstorm X9, CJ5).
- **Order of work** (GD-32): gray boxes until gate 2 is passed, then the look test on the same span.

### Audio and Music

- "The cries are the game." They are built from free recordings of human voices, layered and filtered. No AI voices and no AI-made cries.
- **In hand:** 13 clips (5 shrieks, 4 sobs, 4 whispers), each 4.3 s, cut from 11 CC0 recordings.
- **No composed music.** The cries, the bridge and the two bells are the whole soundtrack.
- **The three room sounds:**

| Level | Heard as | Kept |
|---|---|---|
| Above | Thin, open air, almost dry | Mostly what is above 1000 Hz |
| Inside | Muffled, boxed in, close | Mostly what is below 650 Hz |
| Below | Distant, with a long cave echo | Mostly what is below 2500 Hz |

- **The falling cry:** a cry that fades into the dark over 2 s whenever one of the dead falls.
- **Spoken lines:** about 10, all the ally's, recorded by a person, each with a caption (GD-26, UX-1).
- **Stream-safe sound:** a setting that lifts the cries 6 dB above everything else. The ally's calls are captioned in every mode, so viewers always see them.
- **Small sounds of the town, the hands and the screens** (UX-6, UX-7, UX-10, UX-12, UX-30, UX-37): a window going out, and a fainter one for a window flickering low, both from the town side, at the level of the ambience (at least 6 dB under the quietest cry) and outside the 4-cry limit; a cancelled hold (slack rope, a dropped tool); an impossible action (a dull knock); the flame's sputter; a pen-scratch when the name is inked and when a hint is written; a dry sound for each strip, placement and undo in planning.
- **Clip moments** (brainstorm SP2): three moments are meant to read in a 10 to 30 second clip: a loaded trapdoor dropping, a section collapsing under a Diver, and the name being called.

---

## Technical Specifications

### Performance Requirements

- **Frame rate** (GD-31), measured across the whole 12-minute night, including wave 6:
  - On a GTX 1050-class card at 1080p with the low fog setting: an average of 60 FPS or more, with 1% lows of 45 or more.
  - On integrated graphics (Intel Iris Xe) at 720p with the fog-sprite fallback: an average of 30 FPS or more, with 1% lows of 24 or more.
- **Peak scene:** wave 6, with up to 18 of the dead on the span, three lanterns and fog.
- Cold start to the menu in 10 s or less on the GTX 1050 machine.
- Replaying a lost night starts in 3 s or less, measured from the player's action on the lost-night page (UX-12).
- A sprung rig reacts within 0.3 s of the hammer blow.
- Download size 300 MB or less.
- No crash in 20 nights played back to back.

### Platform-Specific Details

- **Platforms:** Windows 10 and 11 (64-bit) and Linux (x86-64), distributed on itch.io.
- **Engine:** Godot 4.7.2, pinned, with the Forward+ renderer (the fog needs it).
- **Input:** keyboard and mouse. Keys are bound by physical position and named as the player's keyboard prints them.
- **Sound output:** stereo, on headphones or speakers. The game asks which at first launch; the answer changes no cue, is kept in settings and is written to the playtest log (UX-19). A Mono sound setting folds both channels into one for single-ear listeners. Choosing it suggests Cues everywhere. No HRTF plugin (3D audio for headphones) in the base game.
- **Fog:** a low setting and a fog-sprite fallback are both required.
- **Network:** none. The public build collects nothing. The playtest build writes its log to a local file.

### Asset Requirements

Everything must allow commercial use (such as CC0 or CC-BY). Gray boxes stand in for every model until the look test.

| Kind | Needed for the one-night game |
|---|---|
| Cries | The 13 clips in hand, re-cut from the original downloads (they were cut from lossy previews). The tune in 3 variations, its resolving last phrase for the moment the name is called, and its faint hum. Falling cries that fade. |
| Other sounds | Footsteps on planks; hook landing; straining rope; plank creak and section groan; section collapse; trapdoor; swing-beam; hammer on wood, iron and stone; the warden's bell; the town bell; lantern shutter, refill and flame, and the flame's sputter; wind and fog bed; a window going out and a window flickering; rope hauled hand over hand, a plank levering up and the heavier last beat of each hold; slack rope and a dropped tool; a dull knock; a pen-scratch; rattling planks for a hook on the deck; planning's strip, place and undo. |
| Spoken lines | About 10, recorded by a person. |
| Models | Span kit (plank, beam, rail post, rope, pier stone, gate); Grappler, Diver, hatchling; warden's arms and hands with hammer and lantern, and their moves (a ready pose for each action, each hold, the cancel, the "can't", the forearm raised and being inked); lantern with a glass reservoir; lantern pole; oil flask; bell; tally board; a practice pin on the landing; the six names, carved in timber and in a written hand for the forearm; the town with 12 windows; the ally's silhouette. |
| Effects | Fog; dust from stone; shaking rope; swirling fog overhead; leaning flame; bowing planks; the flame's dip and sputter; a window flickering low; a faint self-lit version of each cue, and of footfalls, for Cues everywhere. A shuttered lantern's seam glow. Rattling planks at a hook on the deck. |
| Text | 6 names with one-line epitaphs (the brief's "names with one-line epitaphs"); 6 journal hints; the ally's lines; menu and settings; the lesson's key prompts; planning's why-not lines; the key card; the listening round's instruction, read aloud from the session script. |
| Type | One typeface for every screen: Cormorant Garamond (SIL Open Font License), bundled with the game. |

---

## Development Epics

### Epic Structure

Eight epics for the one-night game (GD-36). Each ends in something playable. Detail is in `epics.md`. Sizes are rough guesses: the ear test's hours were not recorded, so hours are logged from epic 1.

| # | Epic | Ends with | Rough size |
|---|---|---|---|
| 1 | The span | Walk the span, strip it, overload a section and watch it fall | 40 to 65 h |
| 2 | The ear | The listening lesson, playable, and tried by two or three newcomers | 55 to 75 h |
| 3 | The dead | Grapplers, Divers and nests cross an undefended span and put the windows out | 40 to 60 h |
| 4 | Rigs and hands | One wave held with a trapdoor, a swing-beam, a wedge and lanterns | 45 to 70 h |
| 5 | The night | The full sitting, with every screen: lesson, planning, six waves, the name, the ledger, replay | 65 to 90 h |
| 6 | Gate 2 | Five newcomers have played; the three checks and the ear re-check are scored | 20 to 40 h |
| 7 | The look | The same night in the woodcut look, at the performance target | 40 to 80 h |
| 8 | Going public | The itch.io release for Windows and Linux, with the accessibility extras | 30 to 45 h |

**Sequence.** 1 first, then 2: they carry the two biggest risks, and epic 2 runs on what epic 1 builds (architecture AD-66). Epic 2 ends with the early listen (GD-43). Then 3, 4, 5. Epic 6 is the gate: 7 and 8 start only when it passes. The Fog Season is planned after gate 2.

Total: about 335 to 525 hours, against the brief's 250 to 500 hours in a year. The UX decisions added about 35 to 50 hours (GD-50) and the architecture's setup story about 10 to 15 (GD-63); the top of the range is now 25 hours over the brief's. Gate 2 is reached after about 265 to 400 hours.

---

## Success Metrics

### Technical Metrics

- The frame-rate targets in Performance Requirements, measured on both reference machines.
- Any two cries at the same distance within 1 LU, re-measured after any change to a clip or a sound setting.
- No crash in 20 nights played back to back.
- **Fairness:** in the playtest logs, no threat affects the bridge before its full warning has sounded (6 s, 8 s or 40 s).
- The first cry starts within 15 s of the lesson opening. On a first launch the two sound questions come first and are not timed; the playtest log records the time from Begin the watch to the first cry, and its median should be 60 s or less.

### Gameplay Metrics

**The early listen** (GD-43). At the end of epic 2, two or three newcomers, at least one on headphones and one on speakers, try the listening lesson and the listening round described below. It is a check, not a gate. If they face the right way on fewer than 80% of cries, the design is rethought before epic 3.

**Gate 2** (GD-29). Five people who have never seen the game play the one-night game in gray boxes, at the default settings: Visual cues on In the light, Holds on Hold. The log records both settings for every night. A newcomer who switches Visual cues plays on and is reported separately; the ear re-check's marks are taken over those who kept the default. All three checks must pass:

1. **Want more:** 4 of 5 choose to play again or ask what comes next.
2. **Barely:** 3 of 5 reach dawn within two tries, having lost at least 2 sections or 5 windows. (5 of 12 is the same share as the 2 of 5 first chosen.)
3. **Clever:** 3 of 5 can name something they did that felt clever.

If a check fails, the cause is fixed and the gate is run again with people who have not played. The look does not start until all three pass.

Also recorded, not scored: how many of the five found the name, and how many called it. This is the only sight gate 2 gives of pillar 4.

**The ear re-check** (GD-30, GD-46) has two parts.

*The listening round* carries the pass marks. Before their first night, each of the five gate 2 newcomers spends 5 minutes on the span: 12 warnings from places they cannot predict, 4 from each level, in the dark, with no ally and nothing to defend. They turn and walk to where they hear each one. The round comes after the lesson. The warden carries no lantern and the pointer cues are off, as in Ears only, so the gate's light shows nothing. Each trial ends 15 s after its warning starts, which cuts a nest's sobbing short; twelve trials take about 5 minutes. The person running the session reads the instruction from the session script.

| Score | A warning counts as right when | Pass |
|---|---|---|
| Direction | The player turns to within 45° of it within 4 s of its start | 80% |
| Place (level and section together) | The player stops within 5 m of where it would arrive, within 15 s | 70% |

- The pass is over five newcomers, at least two on headphones and two on speakers.
- **Fallbacks:**
  - Speakers below the mark, headphones above: the store page says "best with headphones", and "cues everywhere" is on by default for speaker players.
  - Headphones below the mark too: trial the HRTF plugin on headphones, after checking it against Godot 4.7.2; if that fails, design Plan B, where the lantern scouts.

*The night log* is supporting data, with no pass mark, because a good plan makes arrivals predictable. For every warning in waves 4 to 6 it records: whether the warden turned to within 45° in 4 s; whether the warden was heading toward the arrival point at 4 s; dark or lit; the section; and whether the ally called it. It also records how long the warden spends on each section, to show whether players camp at the town end. The playtest log also records the headphones-or-speakers answer and every pause (UX-19, UX-24).

**Shape of the sitting.** Median length 18 to 25 minutes. A first-time player reaches dawn with about 3 of 6 sections and 3 of 12 windows left.

**The muted night** (GD-50, UX-38). In epic 8, before the public release, one night is played with the sound off and Visual cues on Everywhere. It is a check, not a gate: the warden should face each warning within 4 s. Until it passes, the store page does not say the game can be played without sound.

**The look test**, after gate 2, on the same span:

1. Three people shown a night screenshot lit by one lantern can each point to the deck edge, a Grappler at 4 m, and a rig.
2. The performance targets hold with the woodcut treatment on.
3. No model stands out as belonging to a different game, in Sonlm's judgment.

---

## Out of Scope

**Never** (ruled out by the pillars): weapons; turrets that fire on their own; minimaps, enemy markers and wave timers at night; shops and gold; kill counters, scores and combo meters; dialogue menus; stat tiers; AI voices and AI-made cries; composed music.

**Not in the one-night game; planned for the Fog Season:**

- More than one span; falling back from pier to pier.
- The descent; echoes and food; names beyond the first; names that fade.
- Rigs that end the dead on the deck, and the rites that follow.
- The Procession; a second ally; losing an ally.
- Saving; the ledger as the save file (ST11).
- Gamepad support.
- Assists for wave speed, numbers and forgiveness (G12).
- Leaning over the edge (ST13); letters and the notice board (ST17, ST18).
- The player writing a name's epitaph (ST19).
- Classic Watch (D2): safe days are the Fog Season's own rhythm, so it is not a separate mode.

**Not in the one-night game, and not yet planned:** key rebinding; narrated menus; languages other than English; a one-handed scheme. These are the accessibility gaps accepted at hobby stakes (`EXPERIENCE.md`, Accessibility Floor).

**Later updates, "if it lands":**

- The Swell and Wind seasons; the full truth and three endings; more enemies and allies.
- Endless mode; No Rest (D4); Tenures (F3); Ironman (F4); Daily Tide; Quiet Shift; Blind Watch (O12, a near-black screen).
- Keepsakes (ST12); dropped spans as ladders (ST14); Who Rang the Bell? (ST15); voiced letters (ST16); nets under spans (ST20).
- The visit for grieving players (JB3), never marketed.
- Third person ("later, or never"); Steam; a Mac build.

**Only if the ear re-check fails:** the HRTF plugin trial (DW-1; headphones only, checked against Godot 4.7.2 first); Plan B, where the lantern scouts.

---

## Assumptions and Dependencies

### Assumptions

These have to be proven by playtest or by the work itself. Each names where it is tested.

| # | Assumption | Tested in |
|---|---|---|
| 1 | Newcomers can place threats by ear under game conditions: several cries, a walking player, ambience. The ear test showed direction only, for one practiced listener who knows the design, one cry at a time, standing still. | The early listen, then the ear re-check |
| 2 | A player can tell 4 cries apart when they sound at once. | The early listen, then the night log |
| 3 | 3 dB per section, changing smoothly, is enough to hear how far along the span a cry is, on speakers as well as headphones. People judge loudness coarsely, so this may give near, middle and far, not six sections. | The early listen, then the listening round's "place" score |
| 4 | The tune reads as "below" and as a different voice from the whispers. | The night log |
| 5 | The woodcut look stays readable in the dark and holds the performance targets. | The look test, epic 7 |
| 6 | Free libraries hold enough material: models and animation for three kinds of dead and for the warden's hands, the tune, and the other sounds. | Epics 5 and 7 |
| 7 | The one-night game fits in about 335 to 525 hours. | Hours logged epic by epic |
| 8 | Every number in this document is a workable starting value. | Tuning in epic 6 |
| 9 | The hands alone tell a newcomer what an action will do and how far along it is, with no prompts at night: the ready pose, the hold as its own progress, the "can't" gesture. In gray boxes they are block hands holding a recognisable tool. The lesson practises seven actions; the key card has to carry the rest. | Gate 2 |
| 10 | Cues everywhere carries a player who cannot hear through a night. By sight the flame is the only direction-finder, and it shows the nearest cry only. | The muted night, epic 8 |
| 11 | Godot 4.7.2 can bind keys by physical position, name them as the player's keyboard prints them, and fold stereo to mono. | Architecture |

### Notes for the designer

- **Is listening still needed?** Level has four cues (the cry, the place, the bridge, the ally) and direction has visual help in lantern light. The ally's calls fade to a safety net from wave 4 (GD-39) so that the ear has to lead. The ear re-check keeps warnings in the dark apart from those in the light: if players pass in the light and fail in the dark, the game works but pillar 2 is doing less than it claims. Cues everywhere stands outside this question on purpose: there the ally calls every warning and the eye leads (UX-38).
- **Camping at the town end.** With no rig on section 6 the last line is section 5, but a player can still hold sections 4 and 5 and never walk the span. The playtest log shows time per section. If camping wins, forward sections need a reason to be held.
- **Planks may follow the fight.** Stripping and re-laying lose nothing but time. If playtests show planks being moved to wherever the next threat is, add a loss on stripping at night (brainstorm Y5).
- **The Fog Season outline holds more than one new thing on nights 1 and 5.** When it is detailed after gate 2, either thin those nights or restate "one new thing each night".
- **Every option chosen in this session was the facilitator's recommendation.** The numbers are starting values from one proposal, not the result of comparison. Gate 2 is where they are tested.
- **Draft 0.7 writes the architecture's decisions back** (GD-56 to GD-63): how distance, the 4-cry limit, a replay, dawn, a diving Diver, the name's stillness and a wound work in the cases draft 0.6 left open. `../../../game-architecture.md` holds how they are built. A validator read only these changes and found no critical and 10 major problems, most of them cases the new rules opened: what the stillness stops and silences, the tune under the 4-cry limit, and which sounds a wound cuts. GD-64 to GD-67 answer them. Nobody has read the result.
- **Three validators have read this document.** The first found 2 critical and 14 major problems in draft 0.3. The second found 1 critical and 8 major in draft 0.4. The third read draft 0.6 after the UX decisions went in and found no critical and 12 major, almost all missing cases where lanterns, holds, rigs, Divers and replays meet; a fourth reader checked the UX decisions against it. Their fixes were applied in draft 0.6. The architecture then found seven more missing cases, all settled in draft 0.7.
- **The three clip moments are candidates.** They are confirmed in epic 8 by recording them.
- **The ear re-check's first fallback now means more.** "Cues everywhere on by default for speaker players" was written when that setting only showed cues in the dark. It now also has the ally call every warning all night. If the fallback is ever used, decide then whether speaker players get the whole setting or only its dark cues. That fallback would also make the headphones-or-speakers answer change a default, which today it does not.
- **Which plank goes.** Planks leave a section in a fixed order that keeps the rest evenly spaced, wherever the warden stands to pry one up (GD-54). The carved name must show only at 4 planks or fewer.
- **Hours.** The top of the estimate is 25 hours over the brief's ceiling. Only epic 1 was re-guessed for the architecture (GD-63). It also asks every story for a scripted test path and a show-me setup for Sonlm's checks, and that cost is not in epics 2 to 5's sizes; the hours logged in epic 1 will show whether those sizes need raising. The accessibility extras sit in epic 8, after gate 2, so they are the first thing to cut or move to an update if the logged hours run over.
- **The UX was reviewed on paper.** Two reviewers read the UX documents and nothing has been played. Their findings that were not taken up are in the UX folder's two review files.
- **Rigs lock each other out.** A rig is worked from the next section toward the town, so a trapdoor dropped there, or that section's fall, puts the rig beyond it out of reach. Two trapdoors side by side must be hauled up town side first. If playtests read this as a bug, let the warden work a rig from the side beams.
- **A lantern over an open section cannot be reached.** A bait lantern on a dropped trapdoor burns until the trapdoor is hauled up.
- **Both placed lanterns start lit.** With oil for two of three, the player's first act may be to shutter one. If that reads as a chore, let planning set each placed lantern lit or shuttered.
- **Not done from the third validation:** a per-wave economy line; the worked night stands in for it.

### Dependencies

- A person to record the ally's 10 or so lines.
- The original downloads of the 11 Freesound recordings, to re-cut the cries at full quality.
- Two or three newcomers for the early listen, and five more for gate 2. In each group at least one or two use headphones and one or two use speakers.
- Models and animation that allow commercial use, for the look test.
- A GTX 1050-class machine and an Intel Iris Xe machine to measure on.
- Godot 4.7.2 staying usable for the length of the project.
- The typeface Cormorant Garamond, under the SIL Open Font License, for every screen.
- Before anything goes public: the title checked on itch.io by hand, and the *LAST STAGE* demo watched for new overlaps.

### Deferred

- Who the holdout is, and how the Fog Season's arc ends without the full truth: for narrative design.
- Which wave-breaker is heard first, and when one is first met.
- The night-by-night detail of the Fog Season: after gate 2.
- Plan B's design: only if the ear re-check fails on headphones.
