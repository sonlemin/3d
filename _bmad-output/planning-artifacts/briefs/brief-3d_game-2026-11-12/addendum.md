---
title: "Addendum: Game Brief, The Mourning Watch"
brief: brief.md
created: 2026-11-12
updated: 2026-11-12
---

# Addendum: The Mourning Watch game brief

## How to use this file

This file holds what doesn't fit in `brief.md`. Open the part you need:

| Part | What it holds | Mainly for |
|---|---|---|
| Full versions of condensed sections | The fuller approved text of four brief sections | The GDD |
| Parked by this brief | Brainstorm ideas that this brief set aside or changed | The GDD's cut list |
| Godot technical notes | What Godot 4 handles well, and what it doesn't | Game Architecture |
| Market, references and titles | Comparable games, the originality and title checks, store terms | The GDD and launch planning |

- **How it relates to the brief:** the brief is the summary, and this file adds depth. `.decision-log.md` records every decision. If anything here seems to disagree with the brief, the log settles it.
- **Labels:** in the research parts, **[V]** means verified on a source page, and **[I]** means inference or unverified. The research was done on 2026-11-12. Recheck exact figures before relying on them.
- **Idea codes** such as X5, RB2, CAM3 or #16 refer to ideas in `_bmad-output/brainstorming-session-2026-11-12.md`.
- **HRTF** (head-related transfer function) is the filtering that makes sound on headphones feel 3D, including above and below.

## Full versions of condensed sections

The brief holds the short versions of these four sections; below are the fuller approved texts. Some wording was updated to match later decisions:

- the genre line now says first person only, following the camera decision
- the enemy count is four types, following the Content & Direction decision
- the three kinds of cry are described per "level"

### Core Fundamentals

**Genre:** tower defense with a build-and-defend day/night cycle, played up close, with an overhead view by day and first person at night (third person later, or never). Survival-horror atmosphere. Single-player, PC.

**Core loop** (one cycle, 20–30 minutes):

1. **Day: plan from above.** Strip and rebuild spans; set rigs and lanterns.
2. **Descent (optional, risky):** go below for names, oil and salvage. Time below is time not spent rigging.
3. **Night: survive up close.** Listen, spring rigs by hand, drop spans, and call a name when you hear its owner coming. Moment to moment: hear, rig, hold, salvage.
4. **Dawn: count the cost.** The ledger shows what the night took and which names you learned. Lay the fallen to rest, then save.

**Rhythm:** Chapter 1 has safe days, with dusk and dawn as the clock. The Swell Season (Chapter 2) brings the tide: from then on, the dead come on their own schedule, even while you're below. The finale is one unbroken night.

**Pillars** (same wording as the brief)

1. **Unarmed, not helpless.** Every death comes from the bridge and your rigs, never your hands. Your tools (hammer, rope, bell, lantern) hit like weapons. *Rules out:* weapons of any kind, and turrets that fire on their own.
2. **Hold it by ear.** Sound is how you scout, keep time and read the night. Every threat that can hurt you can be heard in time; anything that muffles your hearing (wind, the Carrion Choir) announces itself first; and every visual cue points to a sound rather than replacing it. *Rules out:* minimaps, enemy markers and wave timers at night.
3. **The bridge is everything.** It's your base, budget, weapon, map and health bar. Every rig is built from a piece of it. A broken span means falling back to the next pier, and the game ends only when the last pier falls. *Rules out:* shops, gold, and any location that isn't part of the bridge.
4. **Every victory has a name.** You win by remembering: names release the dead for good, and the ledger counts names learned and souls released. *Rules out:* kill counters, scores and combo meters.

**Primary mechanics**

- **Listening:** each level has its own kind of cry (whispers below, shrieks above, sobbing inside the walls) on top of 3D audio, so telling where a cry comes from never depends on stereo alone.
- **Reshape, rig, salvage:** collapse spans, build contraptions by day and spring them by hand at night, and strip the bridge for parts (a stripped span is weaker).
- **Five resources, no gold:** material from the bridge, echoes from the border, names and oil from the depths, food from the town.
- **Light:** lanterns let you see but are also a target, and oil is scarce.
- **Names:** found mostly in the depths. Each frees only its own soul, takes one action to call, and fades if unused.
- **Allies at their posts:** four allies, one job each, heard more than seen. A lost ally is gone for good; if the warden falls, an ally takes the lantern.

**Player-experience goals**

- *Clever:* each night is a puzzle with scarce parts, and surviving feels earned, never lucky.
- *On edge:* you hear the dead before you see them, and the dark never cheats.
- *The weight of cost:* every rig costs part of the bridge, every loss is permanent, and dawn shows the bill.
- *Peace:* each name turns a threat into a person, until the cries resolve into release.

The first three give each dawn its pride; the names bring the peace at the end.

### Scope & MVP

**Constraints**

- **Team:** Sonlm, solo. Programming in Godot only; all art, animation, audio and writing are sourced.
- **Time:** about 5–10 hours a week (roughly 250–500 hours a year).
- **Budget:** $0. Free tools, free asset libraries and AI generation tools, plus basic sound editing (a skill to learn) for the cries. Because players can donate, every asset and AI output must allow commercial use (such as CC0 or CC-BY).
- **Engine:** Godot 4, pinned to one version, with the Forward+ renderer (volumetric fog needs it).
- **Platforms:** Windows first, Linux alongside, published on itch.io as "$0 or donate". No Steam or Mac build for now; tips could later pay Steam's $100 fee.
- **Camera:** first person at night and the overhead view by day. Third person comes later, or never.

**MVP: prove you can hold a bridge by ear.** The core hypothesis is that defending by ear, with the bridge as your only weapon, is fun and easy to follow. Two gates test it, in order:

1. **The ear test** (private). A gray-box build with placeholder cries.
   - **Pass mark:** five outside players correctly name each cry's direction (front, back, left, right) and level (above, below, inside), 8 times out of 10, on headphones and on speakers.
   - **How direction is conveyed:** by the cries themselves. Each level gets a different kind of cry, shaped with Godot's built-in filters and reverb.
   - **Trial:** the Nexus Resonance HRTF plugin gets tested here as an optional upgrade.
   - **If it fails:** if only speakers fail, ship "best with headphones", with visual cues on for speaker players. If headphones fail, the lantern takes over scouting (Plan B).
2. **The one-night game** (public, free on itch.io). One span, three enemies (above, below, inside), two rigs, one ally, the bell and one name. If that night is fun, the game works.

**First full release: "The Fog Season."** The prologue, the Fog Season and a closing night, on one bridge of about five spans: four enemy types (one per level, plus one across the deck), 1–2 allies, a handful of names and an ending for this arc. Campaign only; Endless mode comes later. Free on itch.io.

**Later, if it lands** (free updates): the Swell and Wind seasons, the full truth and the three endings, more enemies and allies, Endless mode, and possibly third person and a Steam release.

**Rough timeline** (guesses until building the ear test shows how long the work really takes):

- the ear test in about 2 months
- the one-night game within about a year
- "The Fog Season" in about 2–3 years

**Cut-list rule:** anything outside the one-night game has to earn its way in. The GDD gives every feature a tier: prototype, first release, update, or never.

### Content & Direction

**World:** the Gorge Causeway is a long bridge over a bottomless abyss, and the border between the living and the dead. Below, nothing stays dead; whatever falls rises again. Only on the bridge can the dead die for good. Behind you is the town. You never enter it, but you see its lit windows, read its notice board and get its letters. Ahead lies the Far Side.

**Narrative approach:** the story comes in small pieces: names with one-line epitaphs, journal fragments, the cries, found objects, and a few lines from the old warden.

- There's no branching dialogue; every choice is made with your hands.
- The rules work without the lore, and the game never states its message outright.
- The truth about the bridge unfolds across all three seasons. The Fog Season tells its own arc: your own funeral as the prologue, then the first name, the first ally, and the Silence.
- Text is drafted with AI tools, then picked and edited by Sonlm, and the itch.io page notes the AI use.

**Content breadth ("The Fog Season"):**

- About 2–3 hours: the prologue, 5 nights and a closing night, with one new thing each night.
- One bridge of about five spans. The depths reuse the bridge's art kit.
- Four enemy types: one from each level (below, inside, above), plus one across the deck. Later seasons deepen each level rather than add new ones.
- 1–2 allies, a handful of names, and an ending for this arc.
- Little replay value until Endless mode arrives.

**Art direction:** stylized, leaning to woodcut.

- **Shader:** a full-screen ink-and-hatching shader, written in code, makes mismatched free models read as one engraving.
- **Light and color:** the world is near-black and lit only by lanterns and soft fog. The living are warm, the dead are colorless, and the abyss is true black.
- **No HUD:** your hands, the names inked on your arms, and the ledger carry the information.
- **Check:** the look test on one span confirms the style and checks performance on low-end PCs.

**Audio direction:** the cries are the game.

- **Cries:** each level has its own kind (whispers below, shrieks above, sobbing inside the walls). They're built from free vocal libraries, layered and filtered by Sonlm, and shaped further in code with Godot's filters and reverb.
- **Score and ambience:** the score is made of the cries rather than composed music, and the bridge creaks, groans and sings.
- **Mood:** it follows the cries' arc: eerie, then heavy, then release.
- **Accessibility:** every sound has a visual cue, and a stream-safe mode keeps the cries audible under a streamer's voice.
- **Spoken lines:** few. Wordless vocal sounds from free libraries carry the voices, and the words stay as text. Nothing is AI-voiced.

### Risks & Open Questions

**Key risks**

| Risk | Mitigation |
|---|---|
| **Playing by ear doesn't work.** It's the riskiest pillar: Godot's built-in audio can't convey height, and the only HRTF plugin is new. | The ear test comes first, and the cries carry direction themselves. If headphones pass but speakers fail, ship "best with headphones", with the visual cues on by default for speaker players. If headphones fail too, the lantern takes over scouting (Plan B). |
| **Scope outgrows a solo developer on 5–10 hours a week**, ending in burnout. | One season first, the cut-list rule, and milestones you can show: the ear test, the one-night game, the Fog Season. Timing the ear test turns the guesses into real numbers. |
| **Sourced assets clash, or their licenses don't allow use.** | The woodcut shader unifies mismatched free models. Every asset and AI output must allow commercial use. The look test checks the style on one span. |
| **Players reject AI-made content**, all the more in a game about remembering people. | AI only drafts text and helps with art and sound effects, and Sonlm edits everything. The voices of the dead and any spoken lines never come from AI. The itch.io page discloses the AI use. |
| **Nobody finds it:** a crowded genre, on itch.io only. | A stream kit from the start (stream-safe sound, clip moments). The one-night game as the free demo (first cry within a minute, devlogs, itch.io followers). Tips saved toward Steam's $100 fee. |
| **The dark is unreadable** for strategy players. | The overhead day map stays clean, without the woodcut shader. Every sound has a visual cue. The look test checks readability in the dark. |
| **The story preaches or wears players down.** | The game never states its message, and there's warmth between the waves: breakfast at dawn, the dog, the allies' jokes. |

**Assumptions to validate**

- Players can name a cry's direction and level from the kind of cry plus stereo (the ear test).
- The woodcut shader stays readable in near-darkness and runs on low-end PCs (the look test).
- Free libraries hold enough usable vocal material for the cries (checked while building the ear test).
- About a year is enough to finish the one-night game at 5–10 hours a week (timed from the ear test).

**Open questions for the GDD**

- Which four enemy types make up the Fog Season, and whether a wave-breaker appears in its closing night.
- Who the holdout really is: the last warden, one of the dead, or the bridge's builder.
- Which cut-list tier each brainstorm idea gets, including the batch-2 ideas that were never explicitly accepted (ST10–ST20).
- How the Fog Season's arc ends without revealing the full truth.
- Before anything goes public:
  - check the title on itch.io by hand
  - watch *LAST STAGE*'s demo (G-Star, from 19 November 2026) for new overlaps

## Parked by this brief

Brainstorm ideas that this brief set aside or changed. They aren't rejected forever; the GDD's cut list gives each one a tier.

- **D1 as the default rhythm** (the tide from the start). Replaced by safe days in Chapter 1, with the tide arriving in the Swell Season.
- **One new attack direction per season** (S4, #245–#256). Replaced by all three levels in the Fog Season; later seasons deepen each level.
- **The launch scope in X12–X13** (three seasons and a finale, with the campaign and Endless at launch). The first release is "The Fog Season", campaign only. The Swell and Wind seasons, the full truth, the three endings and Endless come later.
- **The Steam launch (BC1–BC2), Steam Next Fest and Steam achievements (ST31).** Out while the budget is $0; tips may fund Steam later.
- **Third person** (CAM3, and CAM1's third-person option). Later, or never.
- **A Mac build.** Out, since notarization isn't possible on $0.
- **AI-voiced lines and AI-made cries.** Not allowed. The cries come from free vocal libraries; spoken words stay as text.
- **Composed music.** The score is made of the cries (T4).
- **The other modes** (D2 Classic Watch, D4 No Rest, F3 Tenures, F4 Ironman, the Daily Tide, the Quiet Shift, the Blind Watch). Untiered; the GDD decides.
- **The opt-in visit for grieving players** (JB3). Untiered; if it ships, it isn't marketed.

**Exception, moved earlier rather than parked:** stream-safe sound (SP1) and clip moments (SP2) now belong in the one-night game, as part of the stream kit.

## Godot technical notes

For Game Architecture. The labels and research date are explained in "How to use this file".

| Area | Verdict |
|---|---|
| Directional audio | Risky for a solo developer (the riskiest pillar) |
| Lantern light in fog | Fine out of the box |
| The bridge as a structure | Fine out of the box |
| Enemy crowds | Needs a workaround |
| Animated third-person warden | Fine out of the box, but parked |
| Shipping | Fine, with minor friction |

### Engine version

- The current stable release is Godot 4.7.2 (18 Aug 2026); 4.8 is in beta. [V] <https://godotengine.org/download/archive/>
- Pin one engine version and check every plugin against it. Version 4.7 broke some GDExtensions, such as GodotSteam 4.20. [V]

### Directional audio: risky for a solo developer (the riskiest pillar)

**Verdict:** prototype the real audio pipeline first. Carry front/back and height with cues that don't depend on HRTF, such as:

- the kind of cry (#16: whispers below, shrieks above, sobbing inside the walls)
- pitch (ST2 Singing Planks)
- filtering
- visual ripples (G11)

**Evidence**

- Built-in `AudioStreamPlayer3D` provides stereo panning (left/right), attenuation models, a distance low-pass filter, opt-in Doppler, and reverb buses through `Area3D`. `max_polyphony` defaults to 1 per node. [V] <https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html>
- There's no built-in HRTF/binaural rendering and no elevation cue, so the built-in stereo can't reliably convey front versus behind or above versus below. [V for the docs, I for the conclusion]
- Binaural options:
  - **Nexus Resonance** (Steam Audio for Godot): v1.0.1 (2 Sep 2026), supports Godot 4.6–4.8, MIT license. It provides HRTF, occlusion and reflections. It's young: one review, a store still in beta, and platform coverage not stated. It's the only live way to use Steam Audio. [V] <https://store.godotengine.org/asset/movec/nexus-resonance/>
  - stechyo/godot-steam-audio was archived on 7 Oct 2026. Avoid it. [V]
  - FMOD via fmod-gdextension: FMOD's own spatializer isn't HRTF, so binaural would need a third-party plugin inside FMOD. FMOD's license figures are contested; confirm them with FMOD directly. [V/I] <https://github.com/utopia-rise/fmod-gdextension>
  - The community Wwise integration is heavy tooling and isn't confirmed for 4.7. [V/I]
  - Writing your own HRTF convolution in a GDExtension is a lot of work. [I]
- Research findings [V, from abstracts and snippets; the two sources weren't matched to individual findings] <https://www.ieda.ust.hk/dfaculty/so/pdf/Ngan-et-al-2010-Ergonomics.pdf>, <https://mdpi-res.com/d_attachment/applsci/applsci-11-06646/article_deploy/applsci-11-06646.pdf>:
  - Generic HRTFs cause more front/back confusion than individual ones, and judging elevation depends on individual spectral cues.
  - Short training *with feedback* improves localization with generic HRTFs; exposure alone doesn't.
- HRTF is designed for headphones, so speakers need a separate mode. Godot's SPCAP panning (its surround method) handles 5.1/7.1. [V/I]

### Lantern light in fog: fine out of the box

- Volumetric fog and `FogVolume` need the Forward+ renderer; Mobile and Compatibility don't support them. [V] <https://docs.godotengine.org/en/stable/tutorials/3d/volumetric_fog.html>
- Temporal reprojection is cheap but leaves ghost trails behind moving lights. A swinging lantern is a moving light, so test this early. [V/I]
- Keep a low fog preset and a fog-sprite fallback, and profile on low-end PCs and the Steam Deck. [V/I]

### The bridge as a structure: fine out of the box

- Jolt physics has been built in since 4.4 and is the default for new projects. [V] <https://docs.godotengine.org/en/stable/tutorials/physics/using_jolt_physics.html>
- The standard way to fake structure is a graph of spans with load values that break at thresholds, and rigid-body debris spawned only when something fails. This matches X5 and BC9. [I]

### Enemy crowds: needs a workaround

- Hundreds of enemies, each a full node with avoidance, won't scale. Instead [I, informed by the docs] <https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html>:
  - run enemy logic as plain data and render it through `MultiMeshInstance3D`
  - give a full `CharacterBody`/`NavigationAgent` only to the nearest few dozen
  - route enemies along the linear bridge with a 1D path graph or a flow field
- GDScript and C# perform within the same order of magnitude. C++ through GDExtension is the fastest but the slowest to write. [V] <https://docs.godotengine.org/en/stable/about/faq.html>

### Animated third-person warden: fine out of the box, but parked

Parked: the first release is first person only. If third person returns, the cost is time, not tech.

- Retargeting is built in (`BoneMap`, `SkeletonProfileHumanoid`, Rest Fixer). [V] <https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html>
- Known pitfalls are rest-pose mismatches, foot sliding, and models in an A-pose that need fixing. [V]
- Mixamo animations are commonly brought in through FBX import; check the Mixamo license for this use. [I]

### Shipping: fine, with minor friction

- Godot's MIT license means no royalties. [V]
- itch.io: upload with butler, a free command-line tool. [V]
- Steam (parked while the budget is $0): GodotSteam 4.24 (MIT, now hosted on Codeberg). Match its version to the engine version. [V] <https://codeberg.org/godotsteam/godotsteam>
- macOS (parked, no Mac build): notarization needs an Apple Developer ID, which requires a paid Apple developer account [I]. Without notarization, Gatekeeper may block downloads. Test on real Mac hardware. [V] <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html>
- Steam Deck (only if Steam comes later): Windows builds run under Proton. Export both Linux and Windows builds and compare them on the device. [V/I]

## Market, references and titles

For the GDD and launch planning. Steam review figures are all-time English reviews on 2026-11-12. The labels are explained in "How to use this file".

### Comparable games

| Game (year) | Steam reviews | Similar | Different |
|---|---|---|---|
| [Sanctum 2](https://store.steampowered.com/app/210770) (2013) | Very Positive, 92% of 4,350 | First-person tower defense | You shoot; no sound radar, no grief |
| [Orcs Must Die! 3](https://store.steampowered.com/app/1522820) (2021) | Very Positive, 85% of 4,995 | Trap defense played up close | Combat-centered |
| [Orcs Must Die! Deathtrap](https://store.steampowered.com/app/2273980) (2025) | Mostly Positive, 73% of 2,422 | Third-person trap defense | Armed hero; recent up-close tower defense that sold only moderately |
| [Dungeon Defenders](https://store.steampowered.com/app/65800) (2011) | Very Positive, 92% of 8,830 | Tower defense and action hybrid | Class-based fighter |
| [Thronefall](https://store.steampowered.com/app/2239150) (2024) | Overwhelmingly Positive, 95% of 11,181 | Build by day, defend by night | Top-down king, minimalist, no sound mechanic |
| [Kingdom Two Crowns](https://store.steampowered.com/app/701160) (2018) | Very Positive, 89% of 10,608 | Nightly waves, scarce means | 2D side view |
| [Cataclismo](https://store.steampowered.com/app/1422440) (2025) | Very Positive, 88% of 2,340 | Building against nightly waves | Real-time strategy (RTS) |
| [Dome Keeper](https://store.steampowered.com/app/1637320) (2022) | Very Positive, 93% of 11,921 | Defend above, mine below: the closest loop | You shoot from the dome |
| [Perception](https://store.steampowered.com/app/426310) (2017) | Mostly Positive, 72% of 550 | Finding your way by sound; noise draws the threat | Stealth horror, no defense |
| [Spiritfarer](https://store.steampowered.com/app/972660) (2020) | Very Positive, 94% of 19,002 | Helping the dead move on: the closest tone | Cozy management |
| [Return of the Obra Dinn](https://store.steampowered.com/app/653530) (2018) | Overwhelmingly Positive, 96% of 18,949 | Finding the names of the dead | Deduction puzzle |
| [Poly Bridge](https://store.steampowered.com/app/367450) (2016) | Very Positive, 89% of 6,170 | The bridge as a structure | Puzzle, no enemies |
| [A Shot in the Dark](https://magesinstitute.itch.io/a-shot-in-the-dark) (itch.io, free) | no ratings | Audio-only tower defense; footsteps and growls give direction | Tiny, armed |

- We found no direct competitor that combines tower defense, an unarmed hero, a sound radar and the dead. [I: limited search; itch.io was not searched exhaustively]

### Originality check (RB10)

- *Tyrant of the Defense Game: LAST STAGE* (Webzen, made by its studio Crevix):
  - Title finalized in Sep 2026; release targeted for 2027. A demo of about 15 minutes is at G-Star from 19 Nov 2026.
  - A tactical command RPG: tank and damage-dealer party roles, unit placement, direct control, exploration and domain management.
  - Unreal Engine 5 3D backgrounds with hand-drawn "diorama pixel art" characters.
  - Based on the webtoon and web novel *I Became the Tyrant of a Defense Game*. Platforms not announced.
  - [V] <https://www.invenglobal.com/articles/27701/webzen-unveils-first-teaser-for-tyrant-of-the-defense-game-last-stage>, <https://www.invenglobal.com/articles/26349/webzen-to-host-tyrant-of-the-defense-game-last-stage-demo-zone-at-g-star>
- Avoid "Tyrant" and "Defense Game" in titles, tank/damage-dealer party roles, a "pulled into a game world" frame, and diorama pixel art over 3D backgrounds. [I]
- No premise overlap was found. The novel's own terms weren't checked. [I]

### Title check

| Title | Steam | Verdict |
|---|---|---|
| The Mourning Watch | Clear; no exact match on the web either | Lowest risk. Many titles start with "Mourning" (Mourning Tide, Silent Mourning, Mourning House) |
| Keeper of Names | Clear | Low risk |
| The Last Span | Clear | Low risk |
| Tollkeeper | Clear; near neighbors: "Keeper's Toll" (Steam) and "The Bridge Keeper" (itch.io, soldiers defending a bridge) | Low risk |
| What the Bridge Remembers | Clear | Low risk |
| Lanternfall | **Taken**: Bylon Studio's roguelite autobattler (Early Access planned for 22 Dec 2026), plus an itch.io lantern-horror game | Keep the name off the store page, or rename the mode (it was planned as the Tenures mode's name) |
| The Unmourned | **Too close**: *Unmourned* (Codebros, Nov 2025, first-person horror) and *Unmourned VR* | Fine as an in-world term; don't use it as a title |

- These verdicts cover Steam only [V for the Steam store search]. itch.io's search wouldn't load; the manual itch.io check is listed in the open questions (Full versions → Risks & Open Questions).

### Store terms for a free PC release

- **itch.io:** a $0 minimum price is allowed, and there's a "$0 or Donate" option. The default revenue share is 10% (adjustable from 0 to 100%), plus a processing fee of $0.30 plus 2.9% on paid transactions. [V] <https://itch.io/docs/creators/pricing>, <https://itch.io/docs/creators/payments>
- **Steam Direct** (parked while the budget is $0): $100 per new app. It isn't refunded, but Valve returns it in a later payout once the app earns $1,000 in Adjusted Gross Revenue, so a free game with no purchases effectively never gets it back. [V for the fee; I for how it applies to a free game] <https://partner.steamgames.com/doc/gettingstarted/appfee>
- **Steam Next Fest** (parked while the budget is $0): runs in February, June and October; the next ones are Feb 2027 and Jun 2027. [V] <https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest>
  - The store page must be public, and each game can join only one Next Fest.
  - The demo build is reviewed 5 weeks before the Fest (3 weeks if the demo is released before the Fest starts), and the demo must be public before the Fest starts.
  - This would fit the Chapter 1 demo (BC5). How a free game enters wasn't checked.

### Genre context

- The genre is crowded: roughly 359–548 tower defense releases in 2025 (the two sources disagree). Only 3.5% of tower defense games released between Jan 2024 and Jun 2025 reached 1,000 reviews. [V] <https://www.steampageanalyzer.com/niches/tower-defense>
- Recent results [V, mostly from the same source]:
  - Emberward (Sep 2026): 97% of 2,668 reviews, $19.99.
  - Sir, We Have an Orc Problem (Jul 2026): 86% of 2,677 reviews, $9.99.
  - The Perfect Tower II (free, Nov 2025): 85% of 3,305 reviews, which shows a free tower defense game can draw volume.
