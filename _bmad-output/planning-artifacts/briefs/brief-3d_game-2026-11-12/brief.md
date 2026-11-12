---
title: "Game Brief: The Mourning Watch (working title)"
status: final
created: 2026-11-12
updated: 2026-11-12
author: Sonlm
sources:
  - _bmad-output/brainstorming-session-2026-11-12.md
---

# Game Brief: The Mourning Watch (working title)

Companion files: `addendum.md` holds the research, the full text of the sections condensed here, and the ideas this brief parked. `.decision-log.md` records every decision and why it was made.

## Executive Summary

*The Mourning Watch* (working title) is a free, single-player tower defense game for PC. You play an unarmed engineer holding a bridge over an abyss of the dead with nothing but your wits, your ears and the bridge itself. By day you plan from above. By night you're down on the bridge in the fog, listening for where the dead are coming from (below, above, or inside the walls) and tearing apart the bridge you're defending to barely survive until dawn. Each dawn should feel like pride: *I barely made it, and I was clever enough.* By the end it becomes peace, because the dead have names, and remembering them is how you win.

It's made for players who love build-and-defend strategy games like *Thronefall* and *Dome Keeper* and want that loop with real tension: 20–30-minute day-and-night cycles, a readable plan by day, and fair but frightening information by night. Story players and atmosphere lovers come second. The lead hook is that every defense is built by taking your own base apart. Three more differentiators back it up: you never hold a weapon, you scout by ear, and every victory has a name. No game we found combines all of these.

Sonlm is building it solo in Godot, on about 5–10 hours a week and a $0 budget. The art, sound and text come from free libraries and from AI drafts that Sonlm edits. So the plan starts small and tests the riskiest idea first: a private ear test, then a free one-night game on itch.io, then the first full release, "The Fog Season" (about 2–3 hours). Later seasons follow as free updates if players want more.

## Vision

**Core fantasy:** hold a bridge against the dead with nothing but your wits, your ears and the bridge itself.

**Elevator pitch:** You're an unarmed engineer guarding a bridge over an abyss where nothing stays dead, except on the bridge. Each night you listen for where the dead are coming from, then rig, collapse and strip the bridge itself to barely survive until dawn. Hold on long enough and you learn the truth: the bridge is a grave, the dead were forgotten on purpose, and the only way to end it is to remember them.

**Public pitch (spoiler-free):** Tear apart the bridge you're defending, just to survive the night. A tower defense game you play up close and by ear: no weapons, no turrets, only a lantern, your ears and the bridge itself.

**What players walk away with: pride, then peace.** Every dawn: *I barely made it, and I was clever enough.* At the end: *I remember them.* The cries follow the same arc: eerie at first, heavy once you know who they were, and a release when you lay them to rest.

**Vision statement:** make players feel clever for barely surviving the dead, then make them care who the dead were.

## Target Players & Market

**Primary: day/night strategy players**, aged 16 and older, who have played some strategy games (tower defense experience not required) and love *Thronefall*, *Dome Keeper* or *Kingdom Two Crowns*.

- **What they want:** "When I have an evening to myself, I want a strategy game that keeps me on edge, so I can feel clever for barely surviving."
- **Session:** one day-and-night cycle takes 20–30 minutes. An evening fits two or three, and dawn is the save point.
- **What we owe them:** the loop they love, played from inside the fog, with a readable board by day (the overhead view) and fair information at night. Every threat that can hurt you can be heard, or seen through a visual cue, in time to react.

**Secondary audiences:**

1. **Story players:** they come for the mystery of the bridge and stay for the tension.
2. **Atmosphere and horror players:** they play with headphones in the dark, and the sound is the draw.

**How word spreads:** through streamers, who want tense moments and choices that chat will argue about, and through free-game hunters, who decide in the first minute.

**Market context**

- Tower defense is crowded: roughly 360–550 releases on Steam in 2025, and only 3.5% of those released between January 2024 and June 2025 reached 1,000 reviews. Being free doesn't get a game noticed; the hook has to do the work.
- Build-and-defend games keep producing hits: *Thronefall* (2024, 95% positive of 11,000+ reviews), *Dome Keeper* (93% positive) and *Cataclismo* (2025, 88% positive). Up-close action defense is doing less well: *Orcs Must Die! Deathtrap* (2025) sits at 73%.
- We found no direct competitor that combines tower defense, an unarmed hero, scouting by sound and the dead. The nearest is a tiny free audio-only tower defense game on itch.io.
- **Why now:** the build-and-defend format has a proven audience, and none of its hits puts the player down in the dark with sound as the main way to scout.

_Sources: `addendum.md`, "Market, references and titles"._

## Core Fundamentals

**Genre:** tower defense with a build-and-defend day/night cycle, played up close: an overhead view by day, first person at night. Survival-horror atmosphere. Single-player, PC.

**Core loop** (one cycle, 20–30 minutes):

- **Day:** plan from above, stripping and rebuilding spans and setting rigs and lanterns.
- **Descent** (optional, risky): go below for names, oil and salvage.
- **Night:** survive up close. Listen, spring rigs, drop spans, and call a name when you hear its owner coming.
- **Dawn:** the ledger shows what the night cost. Lay the fallen to rest, then save.

**Rhythm:** safe days in the Fog Season. The tide arrives with the Swell Season, bringing the dead on their own schedule, even while you're below.

**Pillars**

1. **Unarmed, not helpless.** Every death comes from the bridge and your rigs, never your hands. Your tools (hammer, rope, bell, lantern) hit like weapons. *Rules out:* weapons of any kind, and turrets that fire on their own.
2. **Hold it by ear.** Sound is how you scout, keep time and read the night. Every threat that can hurt you can be heard in time; anything that muffles your hearing (wind, the Carrion Choir) announces itself first; and every visual cue points to a sound rather than replacing it. *Rules out:* minimaps, enemy markers and wave timers at night.
3. **The bridge is everything.** It's your base, budget, weapon, map and health bar. Every rig is built from a piece of it. A broken span means falling back to the next pier, and the game ends only when the last pier falls. *Rules out:* shops, gold, and any location that isn't part of the bridge.
4. **Every victory has a name.** You win by remembering: names release the dead for good, and the ledger counts names learned and souls released. *Rules out:* kill counters, scores and combo meters.

**Mechanics:** the full list (the cries, rigs, the five resources, light, names and allies) is in `addendum.md`, in the full version of this section.

## Content & Direction

**World:** the Gorge Causeway, a bridge over a bottomless abyss on the border between the living and the dead. Below, nothing stays dead; only on the bridge can the dead die for good. Behind you is the town you never enter: lit windows, a notice board, letters.

**Story:** told in small pieces, with no branching dialogue; every choice is made with your hands. The pieces are names with one-line epitaphs, journal fragments, the cries, found objects and the old warden's few lines. The truth unfolds across all three seasons. The Fog Season has its own arc, from your own funeral to the first name, the first ally and the Silence.

**Look:** stylized woodcut. A full-screen ink-and-hatching shader unifies mismatched free models, lit only by lanterns and fog. There's no HUD: your hands, the names inked on your arms and the ledger carry the information. The overhead map stays clean.

**Sound:** each level has its own kind of cry (whispers below, shrieks above, sobbing inside the walls), and the cries are the score. Every sound has a visual cue, and a stream-safe mode keeps the cries audible under a streamer's voice. Nothing is AI-voiced.

## References & Differentiation

**Inspiration:** the Korean web novel and manhwa *Tyrant of the Tower Defense Game*. We take its feeling, barely surviving through clever use of scarce means, and leave everything else. The originality check found no overlap with our premise. What to steer clear of is listed in `addendum.md`.

**Comparable games**

| Game | Take | Leave |
|---|---|---|
| *Thronefall* (2024) | The day/night build-and-defend cycle; short, readable runs | Top-down nights; an armed hero |
| *Dome Keeper* (2022) | Going below costs you defense time | Shooting from the dome |
| *Orcs Must Die!* (series) | Traps sprung by hand, up close | Weapons; kill-combo scoring |
| *Spiritfarer* (2020) | Helping the dead move on | Cozy management |
| *Return of the Obra Dinn* (2018) | Names as the reward for close attention | The deduction-puzzle format |

**Competition**

- **Direct:** no game we found combines tower defense, an unarmed hero, scouting by sound and the dead. The nearest is *A Shot in the Dark*, a tiny, free, audio-only tower defense game on itch.io in which you're armed. itch.io wasn't searched exhaustively.
- **Indirect:** build-and-defend games that compete for the same players' evenings (*Thronefall*, *Kingdom Two Crowns*, *Cataclismo*), and short story games that compete for story players' attention.

**Differentiators**, in order:

1. **Tear down your own base.** Every defense is built by taking the bridge apart. This is the lead: the store-page headline and the trailer's first shot.
2. **You never hold a weapon.** Every death comes from the bridge and your rigs.
3. **Hold the bridge by ear.** Each level has its own kind of cry, and you scout by listening.
4. **Every victory has a name.** The ledger counts names, not kills.

**Honest edge:** none of these is an advantage others couldn't copy. The edge is the combination, plus executing the sound and the feel of the bridge well.

## Scope & MVP

**Constraints**

- **Team and time:** Sonlm works solo, programs in Godot only, and has about 5–10 hours a week.
- **Budget:** $0. Art, sound and text come from free libraries and from AI drafts that Sonlm edits, and the itch.io page discloses the AI use. Sonlm will also learn basic sound editing for the cries.
- **Licenses:** because players can donate, every asset and AI output must allow commercial use (such as CC0 or CC-BY).
- **Engine:** Godot 4, pinned to one version, with the Forward+ renderer for the fog.
- **Platforms:** Windows and Linux, on itch.io as "$0 or donate". No Steam or Mac build for now.
- **Camera:** first person at night, overhead view by day.

**MVP: prove you can hold a bridge by ear,** with the bridge as your only weapon. Two gates, in order:

1. **The ear test** (private, gray boxes): five outside players correctly name each cry's direction and level (above, below, inside) 8 times out of 10, on headphones and on speakers. The Risks table covers what happens if it fails.
2. **The one-night game** (public, free on itch.io): one span, three enemies (above, below, inside), two rigs, one ally, the bell and one name. If that night is fun, the game works.

**First full release: "The Fog Season"**

- **Contents:** the prologue, 5 nights and a closing night (about 2–3 hours), on one bridge of about five spans, with one new thing each night.
- **Cast:** four enemy types (one from each level, plus one across the deck), 1–2 allies, a handful of names, and an ending for this arc.
- **Modes:** campaign only.

**Timeline** (guesses until building the ear test shows how long the work really takes):

- the ear test in about 2 months
- the one-night game in about a year
- "The Fog Season" in about 2–3 years
- later, if it lands: the Swell and Wind seasons, the full truth and three endings, Endless mode, and possibly third person and Steam

**Cut-list rule:** anything outside the one-night game has to earn its way in. The GDD gives every feature a tier: prototype, first release, update, or never.

## Risks & Open Questions

| Risk | Answer |
|---|---|
| **Playing by ear doesn't work** (Godot can't convey height on its own) | The ear test comes first; the cries carry direction. If only speakers fail: "best with headphones", with visual cues on for speaker players. If headphones fail: Plan B, where the lantern scouts. |
| **Scope outgrows 5–10 hours a week** | One season first, the cut-list rule, and milestones you can show. Timing the ear test checks whether a year is enough for the one-night game. |
| **Sourced assets clash or can't be used** | The woodcut shader unifies them; commercial-use licenses only. Building the ear test checks that free libraries hold enough vocal material. |
| **Players reject AI-made content** | AI drafts that Sonlm edits; never the voices of the dead; disclosed. |
| **Nobody finds it** (crowded genre, itch.io only) | A stream kit from the start, the one-night game as the demo, and tips saved toward Steam. |
| **The dark is unreadable** | A clean overhead map, a visual cue for every sound, and the look test, which also checks that the woodcut runs well on low-end PCs. |
| **The story preaches or wears players down** | Never state the message; warmth between the waves. |

The open questions for the GDD are in `addendum.md`.
