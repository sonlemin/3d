# Extract: game brief, addendum and brief decision log

> Extract made on 2026-11-19 by a reader subagent for the GDD session. It is a summary of the sources below, not a source itself; check the original before quoting.
>
> Sources: `_bmad-output/planning-artifacts/briefs/brief-3d_game-2026-11-12/` (brief.md, addendum.md, .decision-log.md)

Sources: `brief.md` (status: final), `addendum.md`, `.decision-log.md`, all dated 2026-11-12. The addendum says the log settles any disagreement. This runs over the word target because cutting further would have dropped numbers.

## 1. Identity
- **Title:** "The Mourning Watch (working title)". Steam check clear, "lowest risk"; itch.io not yet checked by hand.
- **Summary line:** "a free, single-player tower defense game for PC. You play an unarmed engineer holding a bridge over an abyss of the dead with nothing but your wits, your ears and the bridge itself."
- **Core fantasy** (log label "the clever survivor"): "hold a bridge against the dead with nothing but your wits, your ears and the bridge itself."
- **Elevator pitch (reveals the truth; for the GDD):** "You're an unarmed engineer guarding a bridge over an abyss where nothing stays dead, except on the bridge. Each night you listen for where the dead are coming from, then rig, collapse and strip the bridge itself to barely survive until dawn. Hold on long enough and you learn the truth: the bridge is a grave, the dead were forgotten on purpose, and the only way to end it is to remember them."
- **Public pitch (spoiler-free; store text):** "Tear apart the bridge you're defending, just to survive the night. A tower defense game you play up close and by ear: no weapons, no turrets, only a lantern, your ears and the bridge itself."
- **Vision statement:** "make players feel clever for barely surviving the dead, then make them care who the dead were."
- **Lead hook:** "Tear down your own base" ("Every defense is built by taking the bridge apart"). It is the store-page headline and the trailer's first shot.
- **Genre:** "tower defense with a build-and-defend day/night cycle, played up close"; "Survival-horror atmosphere. Single-player, PC."
- **Camera:** overhead view by day, first person at night; third person "later, or never".
- **Tone:** "pride, then peace." Every dawn: "I barely made it, and I was clever enough." At the end: "I remember them." Cries: "eerie at first, heavy once you know who they were, and a release when you lay them to rest."

## 2. Audience and platforms
- **Primary:** "day/night strategy players", aged 16 and older, some strategy experience (tower defense not required), who love *Thronefall*, *Dome Keeper* or *Kingdom Two Crowns*. Want: "When I have an evening to myself, I want a strategy game that keeps me on edge, so I can feel clever for barely surviving."
- **Secondary:** story players, then atmosphere/horror players ("headphones in the dark"). Streamers and free-game hunters (who "decide in the first minute") are how word spreads, not audiences.
- **Session:** one day-and-night cycle is 20–30 minutes; an evening fits two or three; dawn is the save point.
- **Platforms:** Windows first, Linux alongside; itch.io as "$0 or donate". No Steam or Mac build for now.
- **Input devices:** not stated. Output: headphones and speakers both tested.
- **Engine:** Godot 4 (hard constraint), pinned to one version, Forward+ renderer (volumetric fog needs it). Stable is 4.7.2 (18 Aug 2026); 4.8 in beta; 4.7 broke some GDExtensions.
- **Technical limits (addendum):**
  - No built-in HRTF or elevation cue; `AudioStreamPlayer3D` `max_polyphony` defaults to 1 per node.
  - Hundreds of full-node enemies won't scale: use plain data plus `MultiMeshInstance3D`, a full `CharacterBody`/`NavigationAgent` only for "the nearest few dozen", and a 1D path graph or flow field.
  - Bridge as a graph of spans with load values that break at thresholds; rigid-body debris only on failure; Jolt physics.
  - Fog: temporal reprojection leaves ghost trails behind a swinging lantern; keep a low fog preset and a fog-sprite fallback.

## 3. References
- **Inspiration:** Korean web novel/manhwa *Tyrant of the Tower Defense Game*. Take "barely surviving through clever use of scarce means", leave everything else. Avoid "Tyrant" and "Defense Game" in titles, tank/damage-dealer party roles, a "pulled into a game world" frame, and diorama pixel art over 3D backgrounds.
- *Thronefall* (2024): take the day/night build-and-defend cycle and short, readable runs; leave top-down nights and an armed hero.
- *Dome Keeper* (2022): take "Going below costs you defense time"; leave shooting from the dome.
- *Orcs Must Die!* (series): take traps sprung by hand, up close; leave weapons and kill-combo scoring.
- *Spiritfarer* (2020): take helping the dead move on; leave cozy management.
- *Return of the Obra Dinn* (2018): take names as the reward for close attention; leave the deduction-puzzle format.
- **Nearest competitor:** *A Shot in the Dark* (itch.io, free, audio-only tower defense, armed). Indirect: *Thronefall*, *Kingdom Two Crowns*, *Cataclismo*.
- **Market:** roughly 360–550 tower defense releases on Steam in 2025 (addendum: 359–548); only 3.5% of those released Jan 2024–Jun 2025 reached 1,000 reviews. *Thronefall* 95% of 11,181; *Dome Keeper* 93%; *Cataclismo* 88%; *Orcs Must Die! Deathtrap* 73%.
- **"Honest edge":** none of the differentiators is uncopyable; "The edge is the combination, plus executing the sound and the feel of the bridge well."

## 4. Pillars (exact wording)
1. **Unarmed, not helpless.** "Every death comes from the bridge and your rigs, never your hands. Your tools (hammer, rope, bell, lantern) hit like weapons." *Rules out:* "weapons of any kind, and turrets that fire on their own."
2. **Hold it by ear.** "Sound is how you scout, keep time and read the night. Every threat that can hurt you can be heard in time; anything that muffles your hearing (wind, the Carrion Choir) announces itself first; and every visual cue points to a sound rather than replacing it." *Rules out:* "minimaps, enemy markers and wave timers at night."
3. **The bridge is everything.** "It's your base, budget, weapon, map and health bar. Every rig is built from a piece of it. A broken span means falling back to the next pier, and the game ends only when the last pier falls." *Rules out:* "shops, gold, and any location that isn't part of the bridge."
4. **Every victory has a name.** "You win by remembering: names release the dead for good, and the ledger counts names learned and souls released." *Rules out:* "kill counters, scores and combo meters."

Differentiators, in order: tear down your own base; you never hold a weapon; hold the bridge by ear; every victory has a name.

## 5. Core loop and structure
- **Day:** "plan from above." Strip and rebuild spans; set rigs and lanterns.
- **Descent (optional, risky):** go below for names, oil and salvage. "Time below is time not spent rigging."
- **Night:** "survive up close." Listen, spring rigs by hand, drop spans, call a name when you hear its owner coming. Moment to moment: "hear, rig, hold, salvage."
- **Dawn:** "count the cost." The ledger shows what the night took and which names you learned. Lay the fallen to rest, then save.
- **Rhythm:** Chapter 1 (Fog Season) has safe days, with dusk and dawn as the clock. The Swell Season (Chapter 2) brings the tide: the dead come "on their own schedule, even while you're below." The finale is "one unbroken night."
- **Loss:** the last pier falls. **Win:** by remembering (names release the dead for good). Per-night win/loss thresholds: not stated.

## 6. Mechanics and systems
- **Cries (level cue):** whispers = below, shrieks = above, sobbing = inside the walls. Layered on 3D audio "so telling where a cry comes from never depends on stereo alone." Horizontal direction is front/back/left/right.
- **Other non-HRTF cues suggested:** pitch (ST2 Singing Planks), filtering, visual ripples (G11).
- **Reshape, rig, salvage:** collapse spans; build contraptions by day and spring them by hand at night; strip the bridge for parts ("a stripped span is weaker").
- **Five resources, no gold:** material from the bridge, echoes from the border, names and oil from the depths, food from the town.
- **Light:** "lanterns let you see but are also a target, and oil is scarce."
- **Names:** found mostly in the depths; each frees only its own soul; takes one action to call; fades if unused.
- **Allies:** four in total, one job each, "heard more than seen." A lost ally is gone for good; "if the warden falls, an ally takes the lantern."
- **Tools:** hammer, rope, bell, lantern.
- **Enemies:** Fog Season has four types: one from each level (below, inside, above) plus one across the deck. Later seasons deepen each level instead of adding new ones. The specific types are not stated.
- **Hearing-muffling threats:** wind, the Carrion Choir and the Silence must announce themselves first.
- **Map:** the Gorge Causeway; one bridge of about five spans with piers as fallback points. The depths reuse the bridge's art kit. The town behind is never entered (lit windows, notice board, letters). "Ahead lies the Far Side."
- **Ledger:** counts names learned and souls released.
- **Accessibility:** a visual cue for every sound; stream-safe mode keeps cries audible under a streamer's voice.

## 7. Art and audio direction
- **Art:** "stylized, leaning to woodcut." A full-screen ink-and-hatching shader, written in code, "makes mismatched free models read as one engraving." World near-black, lit only by lanterns and soft fog. "The living are warm, the dead are colorless, and the abyss is true black."
- **No HUD:** "your hands, the names inked on your arms, and the ledger carry the information." The overhead day map stays clean, without the woodcut shader.
- **Audio:** "the cries are the game." Cries built from free vocal libraries, layered and filtered by Sonlm, shaped in code with Godot's filters and reverb. The score is the cries, with no composed music; "the bridge creaks, groans and sings."
- **Voices:** few spoken lines; wordless vocal sounds carry the voices, words stay as text. "Nothing is AI-voiced."
- **Writing:** a few dozen short texts (names with one-line epitaphs, journal fragments, the old warden's lines), AI-drafted and edited by Sonlm. No branching dialogue; "every choice is made with your hands."

## 8. Scope
- **Team:** Sonlm solo; programs in Godot only. All art, animation, audio and writing are sourced.
- **Time:** about 5–10 hours a week (roughly 250–500 hours a year).
- **Budget:** $0. Every asset and AI output must allow commercial use (CC0, CC-BY). The itch.io page discloses AI use.
- **One-night game (public, free):** one span, three enemies (above, below, inside), two rigs, one ally, the bell, one name. Also carries the stream kit: stream-safe sound (SP1) and clip moments (SP2). First cry within a minute.
- **"The Fog Season" (first full release):** prologue, 5 nights and a closing night, about 2–3 hours, one new thing each night; about five spans; four enemy types; 1–2 allies; a handful of names; an ending for this arc. Campaign only. "Little replay value until Endless mode arrives."
- **Later, "if it lands" (free updates):** Swell and Wind seasons, the full truth and three endings, more enemies and allies, Endless mode, possibly third person and Steam.
- **Timeline (guesses):** ear test in about 2 months; one-night game within about a year; Fog Season in about 2–3 years.
- **Cut-list rule:** "anything outside the one-night game has to earn its way in." Every feature gets a tier: prototype, first release, update, or never.
- **Parked:**
  - tide from the start (D1)
  - one new attack direction per season
  - three seasons plus Endless at launch
  - Steam, Next Fest, achievements
  - third person
  - Mac build
  - AI voices and AI-made cries (not allowed)
  - composed music
- **Untiered, for the GDD to decide:**
  - modes: D2 Classic Watch, D4 No Rest, F3 Tenures, F4 Ironman, the Daily Tide, the Quiet Shift, the Blind Watch
  - the opt-in visit for grieving players (JB3); "if it ships, it isn't marketed"

## 9. Gates and plans
- **Gate 1, the ear test (private, gray boxes, placeholder cries).**
  - Pass: five outside players correctly name each cry's direction (front, back, left, right) and level (above, below, inside), 8 times out of 10, on headphones and on speakers.
  - Nexus Resonance HRTF plugin (v1.0.1, Godot 4.6–4.8) is trialled here as an optional upgrade.
  - If headphones pass and speakers fail: ship "best with headphones", visual cues on by default for speaker players.
  - If headphones fail too: Plan B, "the lantern takes over scouting" (no further design given).
  - Also checks that free libraries hold enough vocal material, and times the work.
- **Gate 2, the one-night game.** "If that night is fun, the game works." No measurable criterion.
- **Look test (BC6), on one span:** confirms the woodcut style, readability in the dark and performance on low-end PCs. Pass criteria and timing not stated.
- **Before anything goes public:** check the title on itch.io by hand; watch *LAST STAGE*'s demo (G-Star, from 19 November 2026) for new overlaps.

## 10. Success metrics and playtest criteria
- The ear-test pass mark above is the only numeric criterion.
- Experience goals:
  - *Clever:* "surviving feels earned, never lucky"
  - *On edge:* "the dark never cheats"
  - *The weight of cost:* "dawn shows the bill"
  - *Peace:* "each name turns a threat into a person"
- Fairness: "Every threat that can hurt you can be heard, or seen through a visual cue, in time to react."
- Downloads, ratings, donations, retention, and what "if it lands" means: not stated.

## 11. Risks, assumptions, open questions
- **Risks:**
  - playing by ear doesn't work ("the riskiest pillar")
  - scope outgrows 5–10 hours a week
  - sourced assets clash or can't be licensed
  - players reject AI-made content
  - nobody finds it
  - the dark is unreadable
  - the story preaches or wears players down (mitigation: never state the message; "warmth between the waves: breakfast at dawn, the dog, the allies' jokes")
- **Assumptions to validate:** cry kind plus stereo conveys direction and level; the shader stays readable and runs on low-end PCs; free libraries hold enough vocal material; a year is enough for the one-night game.
- **Open questions for the GDD:**
  - which four enemy types, and whether a wave-breaker appears in the closing night
  - "Who the holdout really is: the last warden, one of the dead, or the bridge's builder"
  - which tier each brainstorm idea gets, including batch-2 ideas never explicitly accepted (ST10–ST20)
  - how the Fog Season's arc ends without revealing the full truth
- **Campaign length:** undecided (reference: 12–15 nights would be about 4–7 hours).
- **Research note:** short localization training with feedback helps; exposure alone doesn't.

## 12. Conflicts and supersessions
- **Enemy count:** the log's first-release entry says "3–4 enemy types"; the later Content & Direction decision fixes four. Four wins.
- **Spoken lines:** "AI-voiced if it sounds right" was superseded by "never AI-voiced".
- **Public pitch:** rewritten to lead with the hook; the version in section 1 wins.
- **Rhythm:** safe days first replaces the brainstorm default D1.
- **Ear-test pass mark:** the brief omits front/back/left/right; the addendum and log include it, replacing RB2's direction-only mark.
- **Pass mark versus fallback:** the pass mark says both setups, but the later "headphones first" decision lets the project proceed if only speakers fail. The later decision wins.
- **Release counts:** brief rounds to 360–550; addendum has 359–548.
- **Clean overhead map:** logged as "up for approval" with no explicit approval entry; it is in the final brief, so treat it as accepted.
- **Outside these files:** the repository's latest commit is titled "Ear test: close gate 1 on Sonlm's own results" (2026-11-19). None of the three documents records this, and it differs from the "five outside players" pass mark. I did not read that commit; confirm how the GDD should state gate 1.

## 13. Qualitative ideas at risk of being dropped
- Remembering is the reward and "must not replace the defense"; "The rules work without the lore."
- Names can stop one of the dead mid-wave, which is why names-only-at-dawn was rejected.
- The prologue is your own funeral. The Fog Season arc runs: the first name, the first ally, the Silence.
- The game "never states its message outright."
- Allies are "heard more than seen"; the town is seen but never entered.
- Information lives on the body: names inked on your arms.
- "The dark never cheats."
- Lanterns are both sight and a target.

## Things the GDD still needs that these documents do not answer
- Input devices and control scheme, including the overhead-day controls.
- The enemy roster: behaviours, counts per night, and what "across the deck" sounds like (no cry is assigned to it).
- Rig types, costs and numbers; span and pier health; resource quantities; what echoes and food do.
- The night-by-night plan: the "one new thing" for each of the 5 nights.
- Ally identities and jobs; the night's length within the 20–30 minutes; fail and retry rules.
- Plan B's actual design, and the look test's pass criteria.
- A measurable definition of "fun" for the one-night game.
- Undefined terms: the holdout, the Silence, the Carrion Choir, wave-breaker, the Far Side, the old warden, the dog.
- The player is called both "engineer" and "warden"; pick one.
- Pillar 3 rules out "any location that isn't part of the bridge", yet the descent goes to the depths; the GDD should state how these fit.
