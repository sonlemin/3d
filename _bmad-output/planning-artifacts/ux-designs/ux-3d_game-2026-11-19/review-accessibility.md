# Accessibility review — The Mourning Watch UX spec (2026-11-19)

Reviewed: `DESIGN.md`, `EXPERIENCE.md`, `.decision-log.md` (UX-1 to UX-37), `.working/gdd-extract.md` (B, C, E, F), and `mockups/directions-1.html` for sizes only. Nothing was run; this is a review of the documents. Contrast figures were recomputed (WCAG relative luminance). Godot API names are from memory and should be checked against 4.7 docs.

## Verdict

The screens are in good shape: stated contrast figures are correct, nothing is timed, pause is total, and the caption exception is well reasoned. The night is where the promise slips: "Cues everywhere" as specified does not yet carry a player who cannot hear through a night, the ready pose (the only affordance signal) is not guaranteed to be visible, and two accepted gaps (press-instead-of-hold, keyboard layout) cost less to close than to leave open.

Counts: **critical 0 · high 7 · medium 19 · low 9**.

No finding is rated critical because none blocks a first-time player outright; the worst cases make a promised mode unreliable, not unusable.

Accepted gaps are not re-listed. Where one appears below it is because the fix looks cheap enough that accepting it is the wrong trade (marked "accepted gap, reconsider").

## What holds up

- Contrast on `world` checks out exactly: ink 9.76, ink-bright 13.93, caption 15.61, warm 10.92, muted 5.79, dim 3.07 (DESIGN.md, Colors).
- Full pause in every phase, no timed reading, untimed planning, undo plus Start over.
- The carved name is read by dwell and then held on the forearm, so nobody has to read carving in firelight.
- Lit and out windows differ by shape (solid against outline), not only colour.
- Planning's tray numbers (1, 2, 3) match the night's build keys, which reinforces the mapping.

---

## 1. Deaf and hard-of-hearing play, with Cues everywhere on

Walk of the "player needs to know / carried by" table (EXPERIENCE.md, HUD & Diegetic UI) for a player with no usable hearing:

| Information | Visual channel in Cues everywhere | State |
|---|---|---|
| A cry's level | Glowing ropes, fog, dust; caption | Works if in view. How long the cue lasts is not specified (H1) |
| A cry's side, and whether it is ahead or behind | Flame lean | Unreliable (H3) |
| Where the dead on the deck are | None in the dark. No row in the table | Missing (H1) |
| Distance | The cue's own position | Fine when in view; nothing when behind (H3) |
| The ally's call | Caption | Arrives late or not at all from wave 4 (H4) |
| The hum | Carried flame lean | Cannot be told from a cry lean (M1) |
| The tune, "bell would work now" | Ropes sway instead of shake | Unreliable; wrong guess is punished (M1) |
| Right or wrong ring | The dead stop or quicken, seen only in light | Unreliable (M1) |
| Window going out; hatchling flicker | The window, behind the warden | Nothing in view (M2) |
| Toll, wave number | Flames dip; tally board | Needs a lit flame in view; can be miscounted (M3) |
| Section near breaking | Bowing planks, in light only | Missing in the dark (M4) |
| Hold progress, cancel, can't | Hands | Depends on the hands being visible (H5) |
| Left/right check | None, by nature | No way out offered (H2) |
| Lesson feedback | Captions; "points it out" | Method not specified (H2) |
| The 10 s hush before wave 6; dawn's silence | None; then cues stop and the view rises | Low (L6) |
| Falling cry (the payoff) | The fall, in light | Acceptable: the strike happens within 2 m of the carried light |

### H1 — The dead on the deck, and the lifetime of a cue, have no visual in the dark (high)

- **Where:** EXPERIENCE.md, HUD & Diegetic UI (table and cue-mode table); UX-27; GDD B2 ("Footsteps, a hook landing, a fall: the event itself, seen in the light"); extract E, "Where the dead on the deck are now".
- **Experience:** A hearing player tracks walkers in the dark by a cry every 8 s plus footsteps. The EXPERIENCE.md table, which claims to be "the whole of what the player can know at night", has no row for this. UX-27's glow list is ropes, fog, dust and swaying ropes only. Once a Grappler is on the planks and walking through an unlit section, a deaf player has nothing until it enters lantern or gate light. The spec also never says whether a level cue lasts for the warning (6 to 40 s) or for as long as the threat is there; Tomas's flow (step 8) assumes ropes "still shaking" after the climb, which is not written as a rule anywhere.
- **Fix:** Add the row. In Cues everywhere, give footfalls the same pale glow as the other cue objects (a brief pale puff or print per footstep event; the audio event already exists to hang it on). State the lifetime rule: a level cue runs for the whole warning and stops when the threat lands. Both stay inside "the cue itself glows; nothing else is revealed".

### H2 — The way into deaf play is hidden, and the first-launch flow cannot be answered without hearing (high)

- **Where:** EXPERIENCE.md, Information Architecture (first-launch chain), State Patterns "Left or right? / Wrong twice", Key Flows "Tomas" step 3; UX-20, UX-21.
- **Experience:** First launch goes Title → Headphones or speakers? → a dark screen with one bell stroke → the listening lesson. Nothing on the dark screen says a sound was played, the stroke cannot be replayed, and a guess passes half the time with no offer made. After two wrong answers the offer is "Swap left and right", which is the wrong remedy for someone who heard nothing. Cues everywhere is never offered; Tomas only finds it by pressing Esc in planning, after the lesson he needed it for. The lesson itself does not say whether the three cries show their visual cue, and "the ally points it out" has no stated form. The pairing of sign to level (ropes = below, fog = above, dust = in the walls) is taught nowhere.
- **Fix:** On the check screen add one plain line ("A bell rings on one side.") and a third answer, "I can't hear it", plus a key to ring again. That answer, and the wrong-twice state, both offer "Show cues everywhere" beside the swap. State that the dusk lesson always shows each cry's visual cue (dusk counts as lit) and that "points it out" is the glowing cue plus a caption. Screens only; no night rule is touched.

### H3 — The flame is the only direction-finder, and it is weak at exactly that job (high)

- **Where:** EXPERIENCE.md, HUD table "A cry's side", cue-mode table; UX-27; GDD B2 (flame leans to the *nearest* cry); GD-28 (a closed lantern gives no cues); GD-16 (Divers aim for the brightest lantern).
- **Experience:** A cue glowing behind the warden, or 25 m off in fog, is invisible until faced. The only thing that says "turn round" is the carried flame leaning. Three problems: (1) it points at the nearest cry only, while up to four sound at once in waves 5 and 6; (2) the span is a line, so the question that matters is ahead or behind, and a lean toward or away from the camera is the one direction a first-person view foreshortens to nothing; (3) the flame is gone whenever the carried lantern is shuttered, empty, or hung, and the Diver rule rewards shuttering. For a hearing player oil is light; for a deaf player oil is also hearing.
- **Fix:** Specify the carry pose so the lantern is held low and seen from above (a lean along the span then reads as up or down the screen), with a stated minimum lean angle. In Cues everywhere, let a shuttered lantern's seam glow, or an empty one's wick ember, keep leaning and dipping. Then test it: one muted night in Cues everywhere, judged by the ear re-check's own criterion (face each warning within 4 s). That test costs nothing and should gate the claim in the Accessibility Floor.

### H4 — From wave 4 the caption reaches a deaf player late by design (high; partly an accepted gap, reconsider)

- **Where:** EXPERIENCE.md, Accessibility Floor, last known gap; GD-39 and P19 (extract D); extract F5.
- **Experience:** From wave 4 the ally calls only when the warden has not turned within 4 s of a cry starting, one call at a time, and drops calls that would be late. A player who cannot hear never turns in time, so every caption arrives at least 4 s into a warning (a Grappler's is 6 s long) and overlapping ones are dropped. The gap is recorded as "some cries may get no call"; the systematic 4 s delay is not recorded. GD-39's reason ("so that the ear has to lead") does not apply to someone who chose this mode.
- **Fix:** In Cues everywhere, keep the waves 1 to 3 rule all night: every cry called 2 s in. One condition, no new lines to record.

### M1 — The hum, the tune and the bell: the name is close to unreachable without hearing (medium)

- **Where:** EXPERIENCE.md, HUD table rows "The name's section", "The one who keeps coming back is here", and "Left as the GDD has it"; Game Feel "Right ring / Wrong ring"; decision log "Left as written by design".
- **Experience:** The hum's cue is the same flame lean as a cry's, and in Cues everywhere flames also lean to cries beyond their light, so the spec no longer says when the hum wins. The returning one arrives where a Grappler does, and its cue is ropes that "sway in time" where a Grappler's "shake"; in a faint glow at distance that difference carries the whole "ring now" decision, and a wrong ring quickens the dead. The result of a ring is the dead stopping or speeding up, visible only in light. The name is optional, so the night still completes, but the game's signature moment is not available. Separately, "whether the bell would work now is heard in the tune and not shown" contradicts the table row that gives the tune a visual cue.
- **Fix:** Give the two motions numbers that cannot be confused (sway: slow whole-rail swing, period over 1 s; shake: short fast jitter). Make the hum lean distinct from a cry lean (straight down toward the deck, as Linh's flow already describes it) and say that in every mode the hum lean yields only to cries inside the flame's own light. On a right ring, let the tune's ropes fall still and their glow fade out over the 2 s of the resolving note.

### M2 — A window going out has a sound but no cue in view (medium)

- **Where:** UX-30, UX-37; EXPERIENCE.md, HUD table "Windows left", Game Feel "Window out".
- **Experience:** UX-30 added the sound because the windows are behind the warden. Its "visual cue" is the window itself, which is behind the warden. A deaf player learns of each loss only by turning; Tomas's flow says so ("seen when he turns"). Windows are the loss condition.
- **Fix:** Tie the town's warm spill on the deck and rails near section 6, or a brief dim-and-recover of the gate light, to the window count, so a loss is seen from the deck. If that is too subtle, in Cues everywhere add one slow lean of the carried flame toward the town. Either is diegetic.

### M3 — The toll cue is easy to miss or miscount, and the flame now means five things (medium)

- **Where:** UX-28; EXPERIENCE.md, cue-mode table; UX-7.
- **Experience:** Counting up to six dips needs a lit flame in view at that moment, during a fight, and cannot be re-read short of walking to the tally board. In the last 60 s of a tank the same flame is already shrinking and sputtering. A single flame carries side (lean), the hum (lean), tolls (dip), oil (sputter) and, if M2 is taken, windows.
- **Fix:** Make each signal a different kind of movement and write that down in one table: lean = direction, dip = toll, sputter = oil, with the dip slow and deep (about 0.4 s down, 0.4 s up) and the sputter small and irregular. Let the tally board be readable from further off in Cues everywhere (its chalk glows like any other cue).

### M4 — A groaning section in the dark shows nothing (medium)

- **Where:** EXPERIENCE.md, cue-mode table, third row (bowing planks are "on" but only "seen in the light").
- **Experience:** Bowing planks are not in the glow list, so the 2 s groan before a collapse has no visual in the dark. Section 6 is under the gate light; sections 1 to 5 are not, and a collapse there costs rigs and a wound.
- **Fix:** Add bowing planks to UX-27's glow list.

### M5 — Single-ear listeners on headphones lose every cry on one side (medium; accepted gap, reconsider)

- **Where:** EXPERIENCE.md, Accessibility Floor, known gaps ("Mono or single-ear listeners get the warning...").
- **Experience:** With stereo placement and one working ear on headphones, cries on the deaf side are quiet or absent, so even the *kind* of cry is lost. A wound on the good side removes the rest for 20 s.
- **Fix:** A "Mono sound" toggle next to Swap left and right, paired in its help line with Cues everywhere. In Godot this should be one bus effect (AudioEffectStereoEnhance with `pan_pullout` at 0; verify). The player keeps level by ear and takes side from the cues.

### L6 — The two silences have no visual and no stated length (low)

- **Where:** EXPERIENCE.md, State Patterns "Dawn", Game Feel "Dawn"; GDD (10 s of silence before the sixth toll).
- **Fix:** State the dawn pause (about 3 to 4 s) and that all cue glows fade together as the cries stop. Leave the pre-wave-6 hush as it is.

### L9 — Two identical calls in a row look like one (low)

- **Where:** EXPERIENCE.md, Component Patterns, caption-line.
- **Experience:** "Below!" followed by "Below!" for a second Grappler is one unbroken caption.
- **Fix:** A blank gap of about 0.3 s and a fresh fade-in between any two captions.

---

## 2. Low vision and colour

### H5 — The ready pose and the forearm are not guaranteed to be visible (high)

- **Where:** EXPERIENCE.md, Interaction Primitives "Ready pose", HUD table rows 1 to 4, State Patterns "Night"; GDD ("light shows only what it falls on").
- **Experience:** The ready pose is the only sign that an action is available, the hold animation is the only progress read-out, the "can't" gesture is the only refusal, and the forearm is the only count of parts. All four are 3D objects that need light. With the carried lantern shuttered, empty or hung, the hands are black on near-black. For a deaf player the paired sounds are gone too, so nothing at all is left. The woodcut pass adds a second risk: tally strokes under a full-screen hatching shader.
- **Fix:** One rule: the warden's hands and forearm never fall below a fixed minimum brightness (an unlit or emissive floor in their material) and the forearm's ink is exempt from the hatching pass. Applies to the gray-box hands at gate 2 as well.

### M6 — "Chosen" and "hold filling" rest on hue and a glow; the two documents disagree on hover (medium)

- **Where:** DESIGN.md, Colors (last paragraphs), Components menu-item and hold-control, Do's ("readable in greyscale"); EXPERIENCE.md, Component Patterns, menu-item.
- **Experience:** Warm against ink is 1.12:1 in luminance, so in greyscale the chosen item differs only by its halo. On near-black, light text already blooms for many low-vision and astigmatic players, so a soft glow reads as more of the same. A hold filling from ink to warm is the same 1.12:1 step and is invisible in greyscale, which breaks DESIGN.md's own rule. DESIGN.md also gives pointer hover its own `ink-bright` state, which is *brighter* than warm (13.9 against 10.9), while EXPERIENCE.md says hover and keyboard choice are the same state. As written, a hovered item can outshine the item Enter will act on.
- **Fix:** Follow EXPERIENCE.md (hover = chosen) and delete the hover colour. Add a 2 px warm rule under the chosen item; rules are already allowed by Shapes. For hold-control, grow that rule left to right with the fill.

### M7 — The planning tray does not fit on one strip at the type floor (medium)

- **Where:** DESIGN.md, Layout & Spacing "Planning", Typography "Floor", Components tray-tool ("a smaller run (still at the floor)"); UX-33; mock direction C.
- **Experience:** The tray's text in 28 px capitals at 0.16em tracking comes to roughly 2,300 to 2,500 px by estimate, against 1,824 px inside the safe margins. The mock fits it by setting labels at about 25 px and costs at about 20 px and 75% opacity, both under the floor, and by wrapping. "A smaller run (still at the floor)" cannot be true when `label` is the floor. Whoever builds this will shrink the text.
- **Fix:** Allow two rows in the spec (parts and tools above; Journal, Keys, Start over, Ring the bell below), costs at `label` size in `muted`. Measure once in Godot at 720p.

### M8 — Body text at 720p is thin, and there is no way to enlarge it (medium)

- **Where:** DESIGN.md, Typography; UX-34 (sturdier face declined; not reopened here).
- **Experience:** Cormorant Garamond has a low x-height and hairline strokes. `body` at 720p is 21 px, an x-height of about 8 px, used for the why-line (in `muted`, 5.8:1 before thin strokes soften it), journal hints, settings labels and key card actions. Capitals at 19 px hold up better than the lower case at 21 px. Caption size is adjustable; nothing else is.
- **Fix:** Keep the face. Add "Text size: normal / large" under Display that scales the theme by about 1.25 (window `content_scale_factor`), and check the tray and ledger at that size. Treat 720p as the size the floor is judged at.

### M9 — Captions and dusk prompts sit over the brightest part of the frame with only a tight halo (medium)

- **Where:** DESIGN.md, Elevation "Halo", Layout "Caption", Components caption-line and key-prompt.
- **Experience:** Bottom centre is where the hands and the carried lantern are. Caption colour against lantern warm is 1.43:1, so legibility is the halo alone, on a thin serif. The dusk key prompts are worse: 32 px (21 px at 720p) over a dusk scene brighter than night, and they are the only controls teaching. A raised forearm also shares that band with the caption.
- **Fix:** Give the halo numbers: an abyss outline of at least 0.08em plus a soft abyss shadow of about 0.3em, checked against the brightest frame the game can make. Add "Caption backing: off / on" (a plain dark band) under Display; off by default keeps the look. State that the forearm's marks sit above the caption band.

### M10 — Tallies must be countable, and nothing says how big they are (medium)

- **Where:** DESIGN.md, Components (closing paragraph, "tally strokes in fives"); EXPERIENCE.md, HUD table; UX-6 (the reason for a "can't" is read from the tallies).
- **Experience:** Up to 48 planks and 12 ropes as strokes on skin, read while the night keeps running. Past about fifteen, fives are slow to count and easy to lose.
- **Fix:** State a minimum: the raised forearm fills at least 40% of view height; strokes at least 6 px wide at 1080p; planks and ropes on separate rows with a small drawn plank and rope at the head of each; every second bundle of five set apart so tens can be seen.

### M11 — No brightness control in a near-black game whose cues "glow faintly" (medium)

- **Where:** EXPERIENCE.md, Accessibility Floor, Settings list (Display); UX-27.
- **Experience:** `world` against `abyss` is 1.04:1 and the Cues everywhere glow has no minimum. On a laptop panel in daylight the cue disappears; on a crushed-black display the dark sections do. Nobody raised this.
- **Fix:** A Brightness slider under Display with one calibration line ("raise until the mark is just visible"), and a stated floor for the cue glow (about 3:1 against fogged dark at default brightness).

### L1 — Graphic states below 3:1 (low)

- **Where:** DESIGN.md, Colors and Components span-section, town-window.
- **Experience:** `dim` on `dawn-sky` is 1.72:1, so out windows and fallen-section outlines fade into the upper dawn gradient; `muted` section numbers there are 3.25:1. In planning, `plank` on `world` is 2.62:1 and a stripped rail is a thin dashed 3.1:1 line. The ledger and strength numbers repeat most of this in words, which is why it is low.
- **Fix:** Draw out windows, fallen outlines and stripped rails in `muted` at 2 px. Keep the dawn gradient at `world` behind anything that carries a count.

### L7 — An unavailable tool's cost is in `dim`, and the why-line needs a pointer (low)

- **Where:** DESIGN.md, Colors (`dim` "not for text the player must read to proceed"), tray-tool; EXPERIENCE.md, why-line.
- **Experience:** The cost is the thing the player must read to make the tool available. Pressing 1 on an unavailable tool does nothing that is specified.
- **Fix:** Keep the name `dim`, set the cost in `muted`. Pressing an unavailable tool's number shows its why-line until the next input.

### L8 — The name "in a written hand"; counting twelve far windows (low)

- **Where:** DESIGN.md, closing paragraph of Components; EXPERIENCE.md, HUD table "Windows left".
- **Fix:** Pick a clear upright hand, not a looped script. No change for the windows beyond M2.

---

## 3. Motor

### H6 — Press-instead-of-hold is cheap enough that leaving it out is a mistake (high; accepted gap, reconsider)

- **Where:** UX-25; EXPERIENCE.md, Input Schemes and Accessibility Floor, known gaps.
- **Experience:** A night is built from holds of 2 to 12 s, several of them on a mouse button gripped while the same hand looks around. That is painful for far more people than "limited hand strength or one hand": RSI, tremor, arthritis, a trackpad. Rebinding needs a screen of its own and is fairly left out. This does not.
- **Fix:** One setting under Controls, "Holds: hold / press once". In press mode the first press starts the action, and it runs to its end unless the player presses again, moves, or is wounded. Durations, cancel rules and balance are unchanged. If every hold goes through one shared timer, this is a flag on it. Offer the same for Tab.

### H7 — Keyboard layout is not addressed; without rebinding it decides who can play (high)

- **Where:** EXPERIENCE.md, Input Schemes; DESIGN.md, key-card and key-prompt; UX-20 (A / D answers).
- **Experience:** If keys are matched by character, an AZERTY player gets W A on Z Q positions, and the digit row gives & and é without Shift, so walking and building break with no remedy. If keys are matched by position, play works but the prompts, tray and key card print "W", "A", "1" for keys labelled Z, Q, &. The spec does not say which.
- **Fix:** State both halves: bind every action by physical key position, and print key names through the layout (`DisplayServer.keyboard_get_label_from_physical`, or the keycode equivalent). Under an hour, and it removes most of the practical need for rebinding.

### M12 — A hold is fragile in ways the spec leaves open (medium)

- **Where:** EXPERIENCE.md, Interaction Primitives "Hold", State Patterns "Hold cancelled", "Pause".
- **Experience:** At 3.5 m/s, 0.5 m is about 0.14 s of a movement key, so a brush of W ends a 12 s build. Not stated: whether looking away from the target cancels (the player has to look round during a 12 s hold); whether parts are spent at the start or the end; what happens to a hold when the game is paused and the key released (Mai's flow pauses mid-wave).
- **Fix:** Write four lines: look is free during a hold; a movement key must be held about 0.3 s before it breaks a hold; parts are spent on the final beat; a hold survives pause if its key is down again within about 0.5 s of Resume (or always, in press mode).

### M13 — Aim and click targets have no stated tolerance (medium)

- **Where:** EXPERIENCE.md, Interaction Primitives "Look decides", "Dwell to read"; Component Patterns span-section (rail clicks).
- **Experience:** No reticle by default, targets the size of a pin or a rope, a 1 s dwell on letters seen through gaps, and in planning a rail drawn as a thin line that must be clicked to strip it or to hang a beam.
- **Fix:** Night: pick targets with a fat ray (a sphere of about 0.25 m), and let dwell time build up across small wobbles. Planning: a rail's click zone is the outer quarter of its section, at least 48 px deep at 1080p. Say that hold-controls can be held with the mouse as well as the key.

---

## 4. Cognitive and learning

### M14 — The hardest inputs are never taught (medium)

- **Where:** UX-22, UX-4; EXPERIENCE.md, State Patterns "Dusk lesson / Hands-on part", Component Patterns key-card.
- **Experience:** The hands-on part covers strike, strip a plank, hang and shutter, raise the forearm. It does not cover building (1, 2), dismantling (R), the stand-face-look rule, hauling a trapdoor back up, re-hanging a beam, re-laying a plank, refilling, or the bell rope. These are the long, conditional ones, met for the first time under pressure with no prompt. The key card "lists every key", which as written omits the conditions.
- **Fix:** Put the conditions on the key card ("1, hold: build a trapdoor. Stand at the near edge of a section, facing away from town."). Add a short "Signs" group to the same card: ropes shake, below; fog swirls, above; dust falls, in the walls; flame leans, toward the nearest cry; flames dip, the bell tolls. One build in the hands-on part would be better still, but costs lesson time already stretched by UX-22.

### M15 — E and F change meaning with nothing to say which meaning is live (medium)

- **Where:** UX-36; EXPERIENCE.md, Input Schemes (E), Interaction Primitives "Look decides" (covers the mouse hands and E, not F); extract B1 (F) and F11.
- **Experience:** E has three look-dependent meanings and no ready pose; the HUD table offers only "learned at dusk, the key card". A lantern hangs over the middle of a section, so "re-lay the plank under it" and "take the lantern down" sit in the same view; the wrong one removes a light. F is specified by distance, not look: with a lantern in hand and another hung within 2 m, the spec does not say which shutter closes.
- **Fix:** Give the lantern-and-rope hand three small ready poses for E (reach to the hook, plank held forward, lantern tipped to the flask). State F's rule: the hung lantern if it is looked at, otherwise the carried one. Enumerate the full pose list once, including strip-a-plank against strike-a-pin, since a strike spends a part.

### M16 — A lost night wipes the plan (medium)

- **Where:** EXPERIENCE.md, State Patterns "Planning / After a lost night" ("The span is back at dusk").
- **Experience:** The player gets one hint and must then rebuild four minutes of planning from memory, click by click, to change one thing. That is a memory load and a repetition load, and it works against the "replay within 3 s" target.
- **Fix:** Open planning after a lost night with the previous plan still in place; Start over already returns the span to dusk. If the plan lives in one data object, this is not resetting it.

### L3 — The lost-night hint can be skipped by a stray key (low)

- **Where:** EXPERIENCE.md, State Patterns "Lost night" ("one action continues").
- **Experience:** The player is mid-fight, keys down, when the night ends. The hint is still in the Journal, so the cost is small.
- **Fix:** Ignore input until the line has finished writing, then continue on Enter, Space or click.

### L4 — The left/right check should not open with an answer already chosen (low)

- **Where:** EXPERIENCE.md, Component Patterns menu-item ("the first entry is chosen when a menu opens") against two-choice.
- **Fix:** Two-choice screens open with neither word warm.

---

## 5. Vestibular and photosensitivity

### M17 — "No flashing" is claimed but the flame effects have no limits (medium)

- **Where:** EXPERIENCE.md, Accessibility Floor ("No flashing"), State Patterns "Lantern near empty", cue-mode table (toll dips); UX-7, UX-28, UX-37.
- **Experience:** A lantern is most of the light in a near-black frame, so anything it does is a large-area brightness change. A sputter runs for the last 60 s of every tank, which could be three or four minutes of the night. All flames dipping together is a whole-scene change up to six times in a row. None of these has a rate or depth.
- **Fix:** Three numbers. The sputter animates the flame itself while the light it casts stays steady (UX-7 already says reach does not change). Nothing changes brightness more than three times a second. A toll dip takes about 0.8 s end to end. With those written, the claim holds.

### M18 — Forced camera movement is unspecified, and the floor's claim about it is wrong (medium)

- **Where:** EXPERIENCE.md, State Patterns "Knocked down, hanging, crossing a gap", "Dawn"; Accessibility Floor ("The only full-view change is the wound's darkened side"); Settings list.
- **Experience:** Knock-down (1.5 s), a fall and climb back (5 s), hand-over-hand crossings (4 and 8 s) and the rise to the overhead view at dawn are all camera moves the player does not control, which is the usual trigger for motion sickness. There is no field-of-view setting and no statement on head bob. The floor's sentence is contradicted by these, by the lost-night blackout and by pause.
- **Fix:** Rules, not systems: no camera roll, no head bob, forced moves eased and slow. Add a field-of-view slider under Display. Add "Reduce camera motion" that swaps knock-down, the climb and the dawn rise for a short fade. Correct the sentence in the floor.

### M19 — The wound's darkening has no extent, and it can cover the caption (medium)

- **Where:** EXPERIENCE.md, State Patterns "Wounded"; Game Feel (last line); GDD fix 15.
- **Experience:** Half the view dark and one ear dulled for 20 s is disorienting for some players and close to blindness for anyone whose usable vision is on that side. Nothing says how dark, how wide, or whether the caption is drawn above it.
- **Fix:** State it: an edge gradient covering at most the outer third of that side, at most about 60% dark, fading over 1 s or more, always drawn under the caption line.

### L2 — The centre dot is too small and faint to do its job (low)

- **Where:** DESIGN.md, Components centre-dot (4 px, `ink`, 60%).
- **Experience:** At 720p it is under 3 px, and grey at 60% vanishes over lantern-lit wood, where a fixation point is most needed.
- **Fix:** 6 px at full opacity with a 1 px abyss ring.

---

## 6. Internal consistency

Already raised above: hover state (M6); "the only full-view change" and "no flashing" (M17, M18); tray size against the floor and the mock (M7); the tune "not shown" against its own table row (M1); the missing table row for the dead on the deck (H1); `dim` used for text that must be read (L7).

### L5 — Smaller mismatches (low)

- **Leave the bridge.** UX-24 says it "asks first"; EXPERIENCE.md (hold-control, Hold to commit) makes it a 1 s hold with no question. Pick one. With press mode (H6) in play, asking first is the safer of the two from Pause in mid-night.
- **Tomas and the swap.** UX-35 says he "takes the swap"; the Key Flow says he declines it. The flow's version is the sensible one; correct the log line or note it.
- **Key card location.** UX-4 says pause; UX-22 says planning and pause; EXPERIENCE.md follows UX-22. Fine, but UX-4 reads as stale.
- **Gray-box forearm.** The log calls it "a flat panel with the same text"; EXPERIENCE.md says "the same marks"; DESIGN.md says "never a screen-style panel". Gate 2 will judge tallies or text depending on who reads which line.
- **Cue modes and the hum.** UX-3 lists the hum lean among pointer cues; the cue-mode table's first row does not name it, and nothing says what it does in Cues everywhere (see M1).
- **"A visual cue for every sound"** is listed under Provided without qualification, while the same document lists sounds left without one. Reword to what is true after the fixes above.

---

## Cheap wins (each under about two hours of Godot work)

1. **Muted test night** in Cues everywhere before gate 2, judged by "face each warning within 4 s". No code. (H3)
2. **Bind by physical key, label by layout.** (H7)
3. **"Holds: hold / press once"** on the shared hold timer, and for Tab. (H6)
4. **Minimum brightness on hands and forearm**; forearm ink exempt from hatching. (H5)
5. **Cues everywhere keeps the waves 1 to 3 call rule all night.** (H4)
6. **"I can't hear it"** on the left/right check, a ring-again key, and "Show cues everywhere" offered on failure. (H2)
7. **Bowing planks and footfalls join the glow list**; write the cue lifetime rule. (H1, M4)
8. **Hover equals chosen; 2 px warm rule under the chosen item**, growing with a hold. (M6)
9. **Key card gains conditions and a "Signs" group.** (M14)
10. **Keep the last plan after a lost night.** (M16)
11. **Brightness slider with a calibration mark.** (M11)
12. **Caption halo numbers, optional caption backing, 0.3 s gap between captions.** (M9)
13. **Flame limits written down**: sputter on the flame only, nothing faster than 3 per second, 0.8 s dips. (M17)
14. **Field-of-view slider; no roll, no bob; "Reduce camera motion" fades.** (M18)
15. **Tray allowed two rows; costs in `muted` at label size.** (M7, L7)
16. **"Mono sound" toggle.** (M5)
17. **Hold rules in four lines**: free look, 0.3 s to break, parts spent at the end, survives pause. (M12)
