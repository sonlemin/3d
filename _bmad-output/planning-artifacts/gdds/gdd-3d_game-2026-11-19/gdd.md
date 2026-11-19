---
title: The Mourning Watch (working title)
game_type: tower-defense
secondary_game_type: horror
platforms: [Windows, Linux]
created: 2026-11-19
updated: 2026-11-19
status: draft 0.4 (finalize fixes applied)
---

# The Mourning Watch - Game Design Document

**Author:** Sonlm
**Game Type:** Tower defense (day/night build-and-defend, played up close), with horror sections
**Target Platform(s):** Windows first, Linux alongside (itch.io, free)

**How to read this document**

- The **one-night game** is specified in full. The **Fog Season** is outlined. Later seasons are out of scope.
- Every number is a starting value to tune at gate 2, unless it is marked as measured.
- What still has to be proven by playtest is listed under Assumptions and Dependencies.
- Decision IDs (GD-n) point to `decision-log.md`. Brainstorm IDs (for example ST4, G11) point to the brainstorming session.
- "The dead" are the enemies. A "section" is one of the six parts of the span. The dead "fall" (gone until dawn) or are "released" (gone for good, by name).

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
| One-night game (public, free) | One span, three enemy types, two rigs, one ally, the bell, one name. One sitting of about 20 minutes. | Full |
| The Fog Season (first full release) | Prologue, 5 nights and a closing night. About five spans, four enemy types, 1 to 2 allies, a handful of names. About 2 to 3 hours. | Outline |
| Later seasons (free updates, "if it lands") | Swell and Wind seasons, the full truth, three endings, Endless mode. | Out of scope |

### Target Audience

- **Primary:** day/night strategy players aged 16 and older with some strategy experience (tower defense not required) who love *Thronefall*, *Dome Keeper* or *Kingdom Two Crowns*. Their want: "When I have an evening to myself, I want a strategy game that keeps me on edge, so I can feel clever for barely surviving."
- **Secondary:** story players, then atmosphere and horror players ("headphones in the dark").
- **How word spreads:** streamers, who "want tense moments and choices that chat will argue about", and free-game hunters, who "decide in the first minute". They are a channel, not an audience. Consequence: the first cry sounds inside the first minute.
- **Session:** the one-night game is one sitting of about 20 minutes. In the full game one day-and-night cycle is 20 to 30 minutes and dawn is the save point.

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
3. **Ears alone aren't enough.** Visual cues are on for everyone, inside lantern light (GD-9).

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
| 2 | Each level has its own cry and its own place. The town bell is the clock. Visual cues exist only where a lantern reaches. |
| 3 | 48 planks and 12 ropes, all of them on the span. Every spring of a rig spends one. Section strength is the health bar. |
| 4 | One name, found by stripping the bridge. The dawn ledger lists the name learned and the soul released, with no count of the fallen. |

### Core Gameplay Loop

**One sitting, about 20 minutes:**

| Phase | Length | View | What happens |
|---|---|---|---|
| Dusk lesson | 2 min | First person | One stroke of the town bell: which side? (This catches swapped or single-channel sound; brainstorm JB4.) Then three harmless dead, one per level. The warden turns to face each cry; the ally says whether that was right. |
| Planning | About 4 min, untimed | From above | No dead. The warden strips sections and places rigs and lanterns, then rings the bell. |
| The night | 12 min | First person | Six waves. The night loop below. |
| Dawn | 2 min | From above | Silence, then the ledger. |

**The night loop, once per wave:**

1. **Hear.** A cry starts. Its kind gives the level, its direction gives the side, its loudness gives how far. (Pillar 2)
2. **Rig.** The warden goes there and readies what stands there: hauls a trapdoor up, re-hangs a beam, moves a lantern. (Pillars 1, 3)
3. **Hold.** The warden springs the rig by hand at the moment it catches the most. (Pillar 1)
4. **Salvage.** Every spring spends a part: a plank for a trapdoor, a rope for a swing-beam (GD-41). In the lull the warden strips more from the bridge to pay for the next wave. (Pillar 3)

The loop closes because parts come only from the bridge and every spring spends one. Each wave leaves the bridge weaker and the next wave is larger, so the pressure rises without a difficulty setting. The one who keeps coming back returns every wave from wave 2 until the warden finds its name and calls it. (Pillar 4)

**Why play it again.** The plan changes the night: which rails stand decides where Grapplers land, where the lanterns hang decides where Divers land, and the section hiding the name changes each run.

### Win/Loss Conditions

- **Dawn** comes on the clock, 12 minutes after the first toll. Any of the dead still on the span sink back below and do not count as crossings. There is no victory screen.
- **The night is lost** when either happens (GD-12):
  - section 6, the last section at the town pier, falls for good; or
  - the last of the town's 12 lit windows goes dark.
- **Windows.** Each of the dead that crosses to the town puts one window out. Two hatchlings count as one. The windows are behind the warden and visible from the deck.
- **A lost night** replays from the planning phase, with one new hint in the journal. The dusk lesson can be skipped.
- **Journal hints.** There are six, one per cause. The hint added is for whichever cost the most that night: Grapplers crossing; Divers crossing; hatchlings crossing; section 6 overloaded; section 6 broken by a Diver; the one who keeps coming back crossing three or more times.
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

**One named exception.** The one who keeps coming back hums a tune where a Grappler would whisper. It is a fourth voice on the level below, at the same kind of place. The ear re-check covers it.

**Direction and distance.**

- **Side** comes from stereo placement that follows the warden's head as it turns. (Measured.)
- **Behind is duller.** A cry straight behind the warden has its treble above 2 kHz cut by up to 10 dB and is up to 2 dB quieter; at the side it is half of each. It brightens as the warden turns to face it. (Measured.)
- **Equal at equal distance.** Any two cries at the same distance play within 1 LU of each other, measured straight ahead before the rear shadow. Loudness therefore never gives away level. This is re-measured whenever a clip or a sound setting changes. (Measured.)
- **Farther is quieter** (GD-40). Each section of distance along the span, 5 m, takes off 2 dB, up to 10 dB. This is how the warden hears which section. (Not measured: the ear test had no distance.)
- **Room sound is atmosphere, not a cue.** Above is thin and open, inside is muffled and boxed in, below has a long cave echo.

**Warnings.** Every threat warns before it can affect the bridge. Each warning is built from whole 4.3 s clips.

| Threat | Warning | Made of |
|---|---|---|
| Grappler | 6 s | One whisper, then 1.7 s of straining rope |
| Diver | 8 s | Two shrieks |
| Nest | 40 s | Seven sobs, the gaps between them closing from about 4 s to none. The sobs quicken; they do not get louder. |
| The one who keeps coming back | 6 s | One hummed phrase, then 1.7 s of straining rope |

**During the night.**

- On the deck each of the dead repeats its own cry every 8 s and adds footsteps on the planks.
- Never more than 4 cries at once. Two warnings never start within 1.5 s of each other. When the limit is reached, cries from the dead already on the deck are dropped first and their footsteps remain.
- Anything that falls lets out a cry that fades into the dark over 2 s. "That sound is the payoff for a perfectly sprung trap" (brainstorm #14). It does not count toward the limit.
- Ambience (creaks, wind, the town bell) sits at least 12 dB under the cries. There is no music.

**Every sound has a visual cue.** The brief promises this. Cues show inside lantern light (GD-9). The three level cues extend the brainstorm's G11; the leaning flame is G11 itself.

| Sound | Visual cue |
|---|---|
| A cry's level | The table above: shaking ropes, swirling fog, falling dust |
| A cry's side | Every lit lantern's flame leans toward the nearest sounding cry |
| The hum over the carved name | The carried lantern's flame leans toward that section within 3 m |
| The hummed tune of the one who keeps coming back | Its rail's ropes sway in time with the tune |
| A section's creak and groan | Its planks bow |
| A toll of the town bell | The ally chalks one tally on the board at the town pier |
| The ally's calls | Text on screen |
| A wounded ear | The view darkens on that side |

In the dark there are no visual cues. The safety net there is the ally's call, and the "cues everywhere" setting.

#### 2. The span

(GD-19)

- The span is the Gorge Causeway's last span before the town: 6 sections, each 5 m long and 5 m wide, 30 m in all. Section 1 touches the far pier, section 6 the town pier.
- Each section has 8 planks and 2 rail ropes (left and right). The span holds 48 planks and 12 ropes. The warden starts with none in hand.
- Planks are a count per section, not positions.
- **Strength** = planks left on the section, 0 to 8.
- **Load** on a section:

| Source | Load |
|---|---|
| Grappler or Diver standing on it | 1 |
| A Grappler's hook set on its rail | 1 |
| A Diver landing | 5 more, for 0.5 s |
| Hatchling | 0.5 |
| The warden | 0 |

- **Creak.** A section creaks while its load equals its strength (brainstorm CJ3).
- **Collapse.** When load is above strength the section groans for 2 s, then falls for good. If the load drops back within the 2 s, it holds.
- **A Diver's landing** adds 5 to whatever already stands there. If that total is above strength, the section falls at once.
- **What falls with it:** the dead on it, a rig on it, any lantern hung on it, and the planks and ropes still on it. A warden on it catches the edge and climbs back onto the nearest standing section toward the town in 5 s, with a wound.
- **An open section** has its trapdoor down, or no planks left. Nothing can stand on it. Crossing it along its side beams takes a Grappler or Diver 12 s, a hatchling 6 s and the warden 4 s.
- **A fallen section** is a 5 m gap. A Grappler throws a hook across and crosses in 12 s. A Diver stranded beyond it takes off and dives again 8 s later on the town side. Stranded hatchlings fall. The warden crosses hand over hand in 8 s.
- **Falling** (GD-13). Any of the dead that falls is gone until dawn. Nothing in the one-night game ends one of the dead on the deck.

#### 3. Stripping and re-laying

| Action | Time | Result |
|---|---|---|
| Strip a plank | 2 s | +1 plank in hand; that section's strength −1 |
| Strip a rail rope | 3 s | +1 rope in hand; no Grappler can hook that rail |
| Re-lay a plank | 3 s | −1 plank in hand; that section's strength +1 |
| Dismantle a rig | 4 s | Its planks return; one of its ropes is lost |

- The warden carries stripped parts, with no limit. The forearm shows tallies of planks and ropes in hand.
- In the planning phase stripping and placing cost no time.
- A rail cannot be stripped while a hook is set on it, or while it holds a swing-beam.

**No rail, no hook** (GD-20). Grapplers hook only a rail that still stands, and a rail holds at most 2 hooks. Fewer rails means they bunch on those sections and overload them. If no rail is left anywhere they hook the deck and tear one plank off each time.

**Striking a hook** (GD-38). A hammer blow on a set hook, 0.5 s, makes the Grappler lose its grip and start its 6 s haul again. The hook stays set and keeps its load. Each Grappler can be shaken loose once; after that its hook holds. Nothing is removed by hand.

#### 4. Rigs

One rig per section, on sections 1 to 5. Section 6 cannot hold a rig. Each rig is sprung from its section's town-side edge, so the warden stands on the next section toward the town.

| | Trapdoor | Swing-beam |
|---|---|---|
| Cost to build | 2 ropes | 4 planks + 2 ropes |
| Needs | 4 or more planks on its section | A standing rail on its section |
| Build time at night | 8 s | 12 s |
| Sprung by | A hammer blow on its pin | A hammer blow that cuts its holding rope |
| Effect | The planks drop within 0.3 s. Everything on the section falls. | The beam sweeps the section in 1.5 s. Everything standing on it, and every hook on its rails, is knocked off. |
| Each spring spends (GD-41) | 1 plank, lost from its section | 1 rope, for the new holding rope |
| Reset | Haul it up: hold for 6 s | Re-hang: hold for 10 s, with a rope in hand |
| While sprung | The section is open | The section is clear and can be walked on |
| Cannot be sprung when | Its section has fewer than 4 planks | It has not been re-hung |
| Danger | None to the warden | A warden on the section is knocked down and wounded |

The warden can also use the bridge with no rig: strip a section to just under the weight of what is about to stand on it, and it collapses under them. That section is then lost for good.

#### 5. The wedge

A nest sobs inside a pier for 40 s before it hatches. The warden hammers a wedge into the cracked stone: 3 s of unbroken hammering, 1 plank. The nest stays shut for the rest of that wave. (GD-17, GD-19)

#### 6. Lanterns and light

(GD-9, GD-28; reach corrected at finalize)

- 3 lanterns: one carried, two placed during planning. A placed lantern hangs from a section's corner post. It can be taken down and moved at night.
- Light reaches 4 m from the carried lantern and 5 m from a placed one. A placed lantern lights its own section and about half of each neighbour.
- A full tank burns for 6 minutes. There is 1 spare flask; a refill takes 4 s and fills one tank. That is 24 lantern-minutes for a 12-minute night: enough for two lanterns all night, which light at most 20 m of the 30 m span.
- **Shutter.** A closed lantern gives no light, burns no oil, and cannot be seen by Divers.
- **Visual cues show only inside lantern light.** The dark is sound only.
- A hung lantern survives a trapdoor drop and a beam's sweep. It is lost if its section falls.

**Divers and light.** A Diver picks its section when its warning ends:

1. The section with an open placed lantern. If two are open, the one nearer the town.
2. Otherwise the section the warden stands on, if the carried lantern is open.
3. Otherwise the weakest standing section; if several are equal, the one nearer the town.

If the chosen section is open, the Diver lands on the nearest standing section toward the town. Divers never land on the town pier landing, and ignore lanterns there.

#### 7. The bell and the name

(GD-14, GD-25)

- One section, chosen at random from sections 2 to 5 each run, has a name carved in the timber under its planks.
- A faint hum, 12 dB under a cry, can be heard within 3 m of that section whenever no cry is sounding.
- The name is uncovered when that section is down to 4 planks or fewer. It can only be read on foot, at night, by lantern light: the planning view never shows what lies under the planks. Once read, it is inked on the warden's forearm.
- **The one who keeps coming back** arrives once per wave from wave 2. It behaves as a Grappler but hums. Whether it falls or crosses, it is back in the next wave.
- **Calling the name:** one pull of the bell rope at the town pier (1 s), after the name has been read, while its owner is on or under the span. The owner stops and passes in peace, and never returns. Every other one of the dead on the span stands still for 20 s. The ledger records one name learned and one soul released.
- **A wrong ring** (GD-42). A pull that calls no one, because the name is unread or the owner is absent, is only noise. Every one of the dead on the span walks half again as fast for 10 s.

#### 8. The ally

(GD-7c, GD-26, GD-39) The one ally is the survivor who understands the voices.

- Stands at the town pier and cannot be hurt in the one-night game.
- **Waves 1 to 3:** calls the level about 2 s after each warning starts: "Below!", "Above!", "In the walls!".
- **Waves 4 to 6:** calls only when the warden has not turned to within 45° of a cry 4 s after it starts. The ear leads and the ally catches what it misses.
- One call at a time. A call that would be more than 4 s late is dropped.
- About 10 recorded lines, each with matching text on screen:

| Lines | Purpose |
|---|---|
| 3 | The level calls |
| 3 | The dusk lesson: an opening line, "right", and "listen again" |
| 1 | The first time the one who keeps coming back returns |
| 2 | Warmth in a lull, not information (the brief's "warmth between the waves") |
| 1 | Dawn |

#### 9. Wounds

(GD-27) The dead want the town, not the warden.

- One that reaches the warden shoves past. The warden is knocked down for 1.5 s. For 20 s everything on that side is 12 dB quieter and dulled above 1 kHz, and the view darkens on that side.
- The same wound follows a hit from the warden's own swing-beam, a Diver landing on the warden's section, or a section falling under the warden.
- There is no health bar. The warden cannot die in the one-night game.

#### 10. Planning from above

(GD-11)

- An overhead view of the whole span, with no dead and no time limit.
- The warden strips planks and rail ropes, places trapdoors and swing-beams on sections 1 to 5, and hangs the two placed lanterns. Every choice can be undone until the night starts.
- The view shows each section's planks, rails and strength directly. It does not show what lies under the planks, and it does not use the woodcut look.
- Ringing the bell ends planning and starts the night.

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

---

## Tower Defense Specific Design

### Rig Types and Upgrades

The rigs are the towers. There are two, and their full values are in Game Mechanics 4. Neither fires on its own (pillar 1), and each spring spends a part of the bridge (GD-41).

What answers what:

| Threat | Trapdoor (1 plank per drop) | Swing-beam (1 rope per re-hang) | Without a rig |
|---|---|---|---|
| Grappler, hook set on a rail | No effect | Knocks the hook off | One hammer blow restarts its 6 s haul, once; or strip that rail beforehand |
| Grappler on the deck | Drops it | Sweeps it off | Overload the section |
| Diver | Drops it after it lands | Sweeps it off after it lands | Shutter the lanterns; keep sections at 5 planks or more |
| Hatchlings | Drops the brood as it crosses | Sweeps the brood | Wedge the nest; a fallen section strands a far-pier brood |
| The one who keeps coming back | Delays it one wave | Delays it one wave | The name |

Combinations the design expects players to find:

- **Bait.** An open lantern hung on a trapdoor section brings a Diver down onto it.
- **Funnel.** Stripping every rail except those beside a swing-beam makes Grapplers come up into it.
- **Slow.** An open or fully stripped section ahead of a rig costs walkers 6 to 12 s, which is time to haul or re-hang the rig behind it.

**Upgrades.** None in the one-night game: no tiers, no stat upgrades. In the full game knowledge is the upgrade (brainstorm G2): the journal unlocks the rig that answers an enemy. Contraptions that snap together (G5) are not in the one-night game.

### Enemy Wave Design

**The dead of the one-night game** (GD-15 to GD-17, GD-23, GD-25):

| | Grappler | Diver | Hollow Nester | The one who keeps coming back |
|---|---|---|---|---|
| Level and cry | Below, whispers | Above, shrieks | Inside, sobbing | Below, a hummed tune |
| Warning | 6 s under a rail | 8 s circling overhead | 40 s, quickening | 6 s under a rail |
| Arrival | Hook lands; hauls up in 6 s | Drops in 1 s; recovers for 2 s | 4 hatchlings break out together | As a Grappler |
| Enters at | Any standing rail with fewer than 2 hooks; never the same rail twice running unless only one is left | The section chosen by the rule in Game Mechanics 6 | Far pier onto section 1; town pier onto section 6 | As a Grappler |
| Walks | 1.2 m/s | 1.0 m/s | Hatchlings 3.0 m/s | 1.2 m/s |
| Load | 1, plus 1 while its hook is set | 1; 5 more on landing | 0.5 per hatchling | 1, plus 1 while its hook is set |
| If it crosses | 1 window | 1 window | Half a window per hatchling | 1 window, and it returns next wave |
| A fall | Gone until dawn | Gone until dawn | Gone until dawn | Returns next wave |

Light-hunting Divers combine two brainstorm ideas: A2 (they drop on the bridge's weakest point) and U5 with A4 (light draws them).

Time from first sound to the town, with nothing in the way:

- Grappler at section 6: about 14 s. At section 1: about 35 s.
- Diver on section 6: about 14 s. On section 1: about 39 s.
- Hatchlings from the far pier: 40 s of sobbing, then 10 s. From the town pier: 40 s of sobbing, then 2 s. A town-pier brood can only be answered by the wedge.

**The six waves** (GD-23). Each lasts 2 minutes: warnings start in the first 75 s, and no warning starts in the 45 s lull that follows. The town bell tolls at the start of each wave: once for wave 1, six times for wave 6 (GD-24).

| Wave | Grapplers | Divers | Nests | New this wave |
|---|---|---|---|---|
| 1 | 3 | 0 | 0 | Grapplers, one at a time |
| 2 | 4 | 0 | 0 | Both rails at once. The one who keeps coming back, from here on. |
| 3 | 3 | 1 | 0 | The first Diver |
| 4 | 2 | 2 | 1 | The first nest, in the far pier |
| 5 | 5 | 2 | 1 | A nest in the town pier |
| 6 | 6 | 3 | 2 | Everything. The sky pales. |

Totals: 23 Grapplers, 8 Divers, 4 nests (16 hatchlings), and 5 visits from the one who keeps coming back. That is 44 possible crossings, counting two hatchlings as one.

**Timetable.** Seconds after the toll at which each warning starts. G = Grappler, D = Diver, N = nest, R = the one who keeps coming back.

| Wave | Warnings start at |
|---|---|
| 1 | G 5, 30, 55 |
| 2 | R 5; G 20, 22 (opposite rails); G 50, 52 (opposite rails) |
| 3 | R 5; G 15; D 30; G 45; G 60 |
| 4 | N far pier 0; R 8; D 16; G 30; D 44; G 58 |
| 5 | N town pier 0; R 6; G 12, 14; D 24; G 36; D 48; G 58, 60 |
| 6 | N far pier 0; R 4; G 8, 10; D 18; N town pier 20; G 28, 30; D 40; G 52, 54; D 64 |

- This timetable never has more than 4 warnings sounding at once. If play delays one into a fifth slot, it waits for a slot.
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
- **The last line.** Section 6 holds no rig, so the last rig is on section 5 at the nearest. Anything that gets past it reaches the town.
- **Choke points.** Section 6, which everything must cross. The two piers, where nests hatch.
- **What the player can see.** In planning, each rig shows the section it covers and each lantern shows its reach. At night nothing is marked; light shows only what it falls on.

### Economy and Resources

No gold, no shop, no income per wave or per kill (pillar 3; brainstorm Y9).

| Resource | At the start | Gained by | Spent on |
|---|---|---|---|
| Planks | 48, all on the span | Stripping (1 per 2 s) | Swing-beam 4; wedge 1; re-laying 1; each trapdoor drop 1 |
| Rope | 12, all on the span as rails | Stripping a rail (1 per 3 s) | Trapdoor 2; swing-beam 2; each re-hang 1; dismantling 1 |
| Oil | 3 full tanks and 1 flask: 24 lantern-minutes | Nothing | Burning: 1 lantern-minute per open lantern per minute |
| The name | 0 | Stripping its section to 4 planks and reading it | Calling it, once |

- **Nothing is refunded in full.** Dismantling a rig returns its planks and loses one of its ropes. A fallen section takes its planks, ropes, rig and lantern with it.
- **A worked night.** Two trapdoors and one swing-beam cost 6 ropes and 4 planks, leaving 6 rails. Ten trapdoor drops, six re-hangs and four wedges then spend 14 more planks and all 6 remaining rails. Rope runs out first.
- **Not in the one-night game:** echoes and food (GD-21).

### Abilities and Powers

There are no cooldowns and no ability bar. Each action below costs time, parts or oil.

| Action | Cost | Effect |
|---|---|---|
| Call the name | 1 s at the bell; once per night | Its owner passes in peace; the wave stands still for 20 s |
| Ring the bell wrongly | Nothing spent | The dead on the span walk half again as fast for 10 s |
| Wedge a nest | 1 plank, 3 s | That nest stays shut for the wave |
| Strike a hook | 0.5 s, at that rail; once per Grappler | That Grappler starts its 6 s haul again |
| Shutter a lantern | Nothing | No light, no cues, no burn; Divers cannot see it |
| Move a lantern | Travel time | Moves the lit area and the Divers' target |
| Overload a section | The section, for good | Everything on it falls |

### Difficulty and Replayability

- **One difficulty.** No difficulty levels, star ratings or scores (pillar 4).
- **Target band** (GD-23, GD-29; windows corrected at finalize). Of 44 possible crossings a first-time player stops about 35, and reaches dawn with about 3 of 6 sections and 3 of 12 windows left. 3 of 5 newcomers reach dawn within two tries.
- **The aim of the tuning:** "each night is a puzzle with scarce parts, and surviving feels earned, never lucky." Nothing in the night is random except which rail a Grappler picks and where the name lies.
- **What changes between runs:** the section hiding the name; which name it is, from a pool of 6; which rails the Grapplers choose; and the player's own plan.
- **Settings that change the challenge:**
  - **Ears only:** all visual cues off (GD-35). A first step toward the brainstorm's Blind Watch, which is a later update.
  - **Cues everywhere:** visual cues show in the dark too (accessibility, GD-9).
- **Assists** for wave speed, numbers and structural forgiveness arrive with the Fog Season (brainstorm G12).

---

## Horror Specific Design

The horror guide's Enemy and Threat Design is covered under Enemy Wave Design. Its Puzzle Integration section does not apply: there are no locks, codes or riddles. The night itself is the puzzle.

### Atmosphere and Tension Building

- **Light.** The world is near-black, lit only by lanterns and soft fog. "The living are warm, the dead are colorless, and the abyss is true black." The town's warm windows are always behind the warden.
- **Sound.** The cries are the score; there is no music. "The bridge creaks, groans and sings." A section creaks at its limit and groans for 2 s before it falls.
- **Tension and release.** 75 s of arrivals, then a 45 s lull, six times. Ten seconds of silence precede the last wave. Dawn opens in silence too, this time earned.
- **The arc of the cries** (brainstorm E4): eerie at first, heavy once the warden knows who they were, and a release when one is laid to rest. In the one-night game the release is the moment the name is called and the hum resolves.
- **No scripted jump scares.** "The dark never cheats": every threat gives its full warning before it can affect the bridge.
- **Told in small pieces and by the place:** the name and its epitaph, the journal's hints, the windows going out, the bell. The game never states its message.

### Fear Mechanics

- **Darkness.** Visual cues exist only inside lantern light, and there is oil for two of three lanterns. The player is always choosing what to leave dark.
- **Light is also a target.** Divers come down where the light is, including the lantern in the warden's hand.
- **Vulnerability.** The warden has no weapon and cannot harm the dead directly. Being caught costs hearing (wounds, GD-27).
- **Noise has a price.** A bell rung for no one hurries the dead (GD-42).
- **Not used:** a sanity or fear meter; a stalker that hunts the warden. The dead want the town.

### Resource Scarcity

- **Oil:** 24 lantern-minutes for a 12-minute night with three lanterns. Nothing restocks.
- **Planks** are the building material, the trapdoor's fuel and the health bar.
- **Rope** is rig parts, the swing-beam's fuel and the rails. Each rope spent is a rail gone.
- **Saving.** The one-night game is one sitting with no save. In the full game dawn is the save point.

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

1. In the dusk lesson the player learns the three cries with feedback.
2. In waves 1 to 3 the ally's call confirms each cry 2 s after it starts.
3. From wave 4 the ally calls only the cries the player has not turned toward within 4 s.

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

Rates and costs are in Tower Defense Specific Design, Economy and Resources. The scarcity curve: planks, rope and oil all start at their maximum and only fall. By dawn a first-time player is expected to have lost about 3 sections, along with whatever was still on them, and to have no rails left.

---

## Level Design Framework

### Level Types

**One-night game: one level.**

- The span: the last 6 sections of the Gorge Causeway before the town.
- The far pier, with a nest inside it.
- The town pier, with a nest inside it, and its landing: the gate, the bell, the tally board, the ally.
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
- **No HUD at night.** Information is carried by the warden's hands, the forearm (the name, and the tallies of parts in hand), the tally board, and the bridge itself. The hands show the action a click will perform.
- **The overhead view** is clean and readable, without the woodcut treatment.
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
- **Spoken lines:** about 10, all the ally's, recorded by a person, each with on-screen text (GD-26).
- **Stream-safe sound:** a setting that lifts the cries 6 dB above everything else and always shows the ally's calls as text.
- **Clip moments** (brainstorm SP2): three moments are meant to read in a 10 to 30 second clip: a loaded trapdoor dropping, a section collapsing under a Diver, and the name being called.

---

## Technical Specifications

### Performance Requirements

- **Frame rate** (GD-31), measured across the whole 12-minute night, including wave 6:
  - On a GTX 1050-class card at 1080p with the low fog setting: an average of 60 FPS or more, with 1% lows of 45 or more.
  - On integrated graphics (Intel Iris Xe) at 720p with the fog-sprite fallback: an average of 30 FPS or more, with 1% lows of 24 or more.
- **Peak scene:** wave 6, with up to 18 of the dead on the span, three lanterns and fog.
- Cold start to the menu in 10 s or less on the GTX 1050 machine.
- Replaying a lost night starts in 3 s or less.
- A sprung rig reacts within 0.3 s of the hammer blow.
- Download size 300 MB or less.
- No crash in 20 nights played back to back.

### Platform-Specific Details

- **Platforms:** Windows 10 and 11 (64-bit) and Linux (x86-64), distributed on itch.io.
- **Engine:** Godot 4.7.2, pinned, with the Forward+ renderer (the fog needs it).
- **Input:** keyboard and mouse.
- **Sound output:** stereo, on headphones or speakers. The game asks which at first launch. No HRTF plugin (3D audio for headphones) in the base game.
- **Fog:** a low setting and a fog-sprite fallback are both required.
- **Network:** none. The public build collects nothing. The playtest build writes its log to a local file.

### Asset Requirements

Everything must allow commercial use (such as CC0 or CC-BY). Gray boxes stand in for every model until the look test.

| Kind | Needed for the one-night game |
|---|---|
| Cries | The 13 clips in hand, re-cut from the original downloads (they were cut from lossy previews). One hummed tune in 3 variations. Falling cries that fade. |
| Other sounds | Footsteps on planks; hook landing; straining rope; plank creak and section groan; section collapse; trapdoor; swing-beam; hammer on wood, iron and stone; the warden's bell; the town bell; lantern shutter, refill and flame; wind and fog bed. |
| Spoken lines | About 10, recorded by a person. |
| Models | Span kit (plank, beam, rail post, rope, pier stone, gate); Grappler, Diver, hatchling; warden's arms and hands with hammer and lantern; lantern; bell; tally board; the town with 12 windows; the ally's silhouette. |
| Effects | Fog; dust from stone; shaking rope; swirling fog overhead; leaning flame; bowing planks. |
| Text | 6 names with one-line epitaphs (the brief's "names with one-line epitaphs"); 6 journal hints; the ally's lines; menu and settings. |

---

## Development Epics

### Epic Structure

Eight epics for the one-night game (GD-36). Each ends in something playable. Detail is in `epics.md`. Sizes are rough guesses: the ear test's hours were not recorded, so hours are logged from epic 1.

| # | Epic | Ends with | Rough size |
|---|---|---|---|
| 1 | The span | Walk the span, strip it, overload a section and watch it fall | 30 to 50 h |
| 2 | The ear | The dusk lesson, playable, and tried by two or three newcomers | 50 to 70 h |
| 3 | The dead | Grapplers, Divers and nests cross an undefended span and put the windows out | 40 to 60 h |
| 4 | Rigs and hands | One wave held with a trapdoor, a swing-beam, a wedge and lanterns | 40 to 60 h |
| 5 | The night | The full sitting: lesson, planning, six waves, the name, the ledger, replay | 50 to 70 h |
| 6 | Gate 2 | Five newcomers have played; the three checks and the ear re-check are scored | 20 to 40 h |
| 7 | The look | The same night in the woodcut look, at the performance target | 40 to 80 h |
| 8 | Going public | The itch.io release for Windows and Linux | 20 to 30 h |

**Sequence.** 1 and 2 first, in either order: they carry the two biggest risks. Epic 2 ends with the early listen (GD-43). Then 3, 4, 5. Epic 6 is the gate: 7 and 8 start only when it passes. The Fog Season is planned after gate 2.

Total: about 290 to 460 hours, against the brief's 250 to 500 hours in a year.

---

## Success Metrics

### Technical Metrics

- The frame-rate targets in Performance Requirements, measured on both reference machines.
- Any two cries at the same distance within 1 LU, re-measured after any change to a clip or a sound setting.
- No crash in 20 nights played back to back.
- **Fairness:** in the playtest logs, no threat affects the bridge before its full warning has sounded (6 s, 8 s or 40 s).
- The first cry sounds within 60 s of pressing Start.

### Gameplay Metrics

**The early listen** (GD-43). At the end of epic 2, two or three newcomers, at least one on headphones and one on speakers, try the dusk lesson and the listening yard. It is a check, not a gate. If they face the right way on fewer than 80% of cries, the design is rethought before epic 3.

**Gate 2** (GD-29). Five people who have never seen the game play the one-night game in gray boxes. All three checks must pass:

1. **Want more:** 4 of 5 choose to play again or ask what comes next.
2. **Barely:** 3 of 5 reach dawn within two tries, having lost at least 2 sections or 2 windows.
3. **Clever:** 3 of 5 can name something they did that felt clever.

If a check fails, the cause is fixed and the gate is run again with people who have not played. The look does not start until all three pass.

**The ear re-check** (GD-30), run in the same sessions. The playtest build logs every warning in waves 4 to 6, where the ally speaks only after a miss:

| Score | A warning counts as right when | Pass |
|---|---|---|
| Direction | The warden turns to within 45° of it within 4 s of its start | 80% |
| Place (level and section together) | The warden is within 6 m of the arrival point when the warning ends | 70% |

- Each warning is also logged as in the dark or in lantern light, with its section and whether the ally called it.
- The pass is over five newcomers, at least two on headphones and two on speakers.
- A cry the player chose to leave counts as a miss, so 70% is a floor.
- The log also records how long the warden spends on each section, to show whether players camp at the town end.
- **Fallbacks**, judged on the warnings in the dark:
  - Speakers below the mark, headphones above: the store page says "best with headphones", and "cues everywhere" is on by default for speaker players.
  - Headphones below the mark too: trial the HRTF plugin on headphones, after checking it against Godot 4.7.2; if that fails, design Plan B, where the lantern scouts.

**Shape of the sitting.** Median length 18 to 25 minutes. A first-time player reaches dawn with about 3 of 6 sections and 3 of 12 windows left.

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
| 2 | A player can tell 4 cries apart when they sound at once. | The listening yard in epic 2, then the ear re-check |
| 3 | A 2 dB step per section is enough to hear which section a cry is at, on speakers as well as headphones. | The early listen, then the "place" score |
| 4 | The hummed tune reads as "below" and as a different voice from the whispers. | The ear re-check |
| 5 | The woodcut look stays readable in the dark and holds the performance targets. | The look test, epic 7 |
| 6 | Free libraries hold enough material: models and animation for three kinds of dead, the hummed tune, and the other sounds. | Epics 5 and 7 |
| 7 | The one-night game fits in about 290 to 460 hours. | Hours logged epic by epic |
| 8 | Every number in this document is a workable starting value. | Tuning in epic 6 |

### Notes for the designer

- **Is listening still needed?** Level has four cues (the cry, the place, the bridge, the ally) and direction has visual help in lantern light. The ally's calls fade to a safety net from wave 4 (GD-39) so that the ear has to lead. The ear re-check keeps warnings in the dark apart from those in the light: if players pass in the light and fail in the dark, the game works but pillar 2 is doing less than it claims.
- **Camping at the town end.** With no rig on section 6 the last line is section 5, but a player can still hold sections 4 and 5 and never walk the span. The playtest log shows time per section. If camping wins, forward sections need a reason to be held.
- **Planks may follow the fight.** Stripping and re-laying lose nothing but time. If playtests show planks being moved to wherever the next threat is, add a loss on stripping at night (brainstorm Y5).
- **The Fog Season outline holds more than one new thing on nights 1 and 5.** When it is detailed after gate 2, either thin those nights or restate "one new thing each night".
- **Every option chosen in this session was the facilitator's recommendation.** The numbers are starting values from one proposal, not the result of comparison. Gate 2 is where they are tested.
- **The finalize fixes have not been independently re-checked.** A validator found 2 critical and 14 major problems in draft 0.3. This draft applies its fixes, but no second validator has read it.
- **The three clip moments are candidates.** They are confirmed in epic 8 by recording them.

### Dependencies

- A person to record the ally's 10 or so lines.
- The original downloads of the 11 Freesound recordings, to re-cut the cries at full quality.
- Two or three newcomers for the early listen, and five more for gate 2. In each group at least one or two use headphones and one or two use speakers.
- Models and animation that allow commercial use, for the look test.
- A GTX 1050-class machine and an Intel Iris Xe machine to measure on.
- Godot 4.7.2 staying usable for the length of the project.
- Before anything goes public: the title checked on itch.io by hand, and the *LAST STAGE* demo watched for new overlaps.

### Deferred

- Who the holdout is, and how the Fog Season's arc ends without the full truth: for narrative design.
- Which wave-breaker is heard first, and when one is first met.
- The night-by-night detail of the Fog Season: after gate 2.
- Plan B's design: only if the ear re-check fails on headphones.
