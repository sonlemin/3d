# Validation Report — 3d_game (The Mourning Watch, one-night game)

- **DESIGN.md:** `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/DESIGN.md`
- **EXPERIENCE.md:** `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`
- **Reviews run:** 2026-11-19, on the drafts before they were marked final
- **Run at:** 2026-11-20T00:27:45+07:00 (this report; statuses as of this time)
- **HTML version:** `validation-report.html`

## Overall verdict

The pair is a usable contract and close to ready. Mechanically it is clean: all 12 colours carry a hex, all 25 distinct token references in DESIGN.md and both in EXPERIENCE.md resolve, the six stated contrast ratios are correct, the 17 component names match one for one across both spines, both `sources` paths exist, and both spines keep the canonical section order. No critical findings. What stands between it and a clean hand-off is at the edges of the retry loop and the hand-off to the GDD. Two high findings: the "GDD impacts" table leaves out several UX decisions that add to or change the GDD, and the lost-night screen is built around "the new hint being written" with no rule for a loss whose hint is already in the journal. The medium findings are mostly decisions that live only in a Key Flow or only in the mock, five logged decisions that were weakened in distillation, and component frontmatter that is thinner than the component prose.

Accessibility reviewer: the screens are in good shape: stated contrast figures are correct, nothing is timed, pause is total, and the caption exception is well reasoned. The night is where the promise slips: "Cues everywhere" as specified does not yet carry a player who cannot hear through a night, the ready pose (the only affordance signal) is not guaranteed to be visible, and two accepted gaps (press-instead-of-hold, keyboard layout) cost less to close than to leave open. No finding is rated critical because none blocks a first-time player outright; the worst cases make a promised mode unreliable, not unusable.

Both verdicts describe the drafts as they stood on 2026-11-19, before they were marked final. Since then all nine high findings have been acted on (six by decision UX-38 to UX-41, three by direct fixes; two of the nine only in part) and the documents were corrected again after GDD draft 0.6 (GD-52, GD-53, GD-54). Each finding below carries its status today. Every status is a reading of the documents: nothing has been run in Godot, and Cues everywhere has not been played muted.

## Category verdicts

- Flow coverage — adequate (2 medium · 2 low)
- Token completeness — adequate (4 medium · 4 low)
- Component coverage — adequate (5 medium · 4 low)
- State coverage — adequate (1 high · 2 medium · 5 low)
- Visual reference coverage — adequate (3 low)
- Bloat & overspecification — adequate (2 low)
- Inheritance discipline — adequate (1 high · 1 medium · 2 low)
- Shape fit — strong (1 low)
- Accessibility (extra reviewer, no category verdict) — 7 high · 19 medium · 9 low

## Findings by severity and status

| Severity | Fixed | Decided | Partly addressed | Accepted gap | Not addressed | Not verified | Total |
|---|---:|---:|---:|---:|---:|---:|---:|
| Critical | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| High | 2 | 5 | 2 | 0 | 0 | 0 | 9 |
| Medium | 13 | 4 | 6 | 2 | 8 | 0 | 33 |
| Low | 3 | 0 | 7 | 0 | 22 | 0 | 32 |
| **Total** | **18** | **9** | **15** | **2** | **30** | **0** | **74** |

Rubric walker: 0 critical, 2 high, 14 medium, 23 low. Accessibility: 0 critical, 7 high, 19 medium, 9 low.

Status words: **Fixed** (the documents now say what the finding asked for); **Decided** (Sonlm chose, with the decision id); **Partly addressed** (some of the fix is in, the rest is named); **Accepted gap** (stated as a known gap in EXPERIENCE.md, Accessibility Floor); **Not addressed** (the text reads as it did, or the fix was declined); **Not verified** (could not be told from the log or the documents).

## Findings by severity

### Critical (0)

None.

### High (9)

**[State coverage]** — R4.1: A lost night with no new hint to write is undefined (§ EXPERIENCE.md, State Patterns, Lost night; UX-12)
The lost-night surface is "the journal page opens on the new hint being written". There are six hints, one per cause, so a second loss to the same cause, the common case for a newcomer and the case Linh's own flow sets up, has no new hint. The GDD does not settle it either.
Fix: Commit one behaviour (for example: the page opens on the existing hint for that cause, drawn as already written, with no writing-in), add it as a State Patterns row, and add it to GDD impacts.
Status: **Decided (UX-41).** UX-41: a repeated loss shows the same hint again, brightened for a moment; nothing new is written. State Patterns row and GDD impacts row both present.

**[Inheritance discipline]** — R7.1: "GDD impacts" is incomplete (§ EXPERIENCE.md, GDD impacts)
EXPERIENCE.md itself says the GDD should be updated from this table before architecture reads it. Unlisted at review time: UX-12 (where the 3 s replay target is measured); UX-16 (fixed plank order, putting a tool away); UX-17 (Start over); UX-20 (how the left/right check is answered); UX-21 (lesson skip and its flag on disk); new sounds beyond UX-30 and UX-37; new visuals (reservoir and flask, planks drawn singly, self-lit cue objects); rules added to mechanics (Tab, "facing out", the hum's flame condition, a shaken hook gets no ready pose, the input lock while crossing); UX-24 and UX-19 (full pause, playtest log).
Fix: Add a row for each, or split the table into "changes a GDD statement" and "adds to the GDD (assets, inputs, rules)".
Status: **Partly addressed.** The table was split into "Changes a GDD statement" and "Adds to the GDD" and filled in, and GDD draft 0.6 was updated from it (GD-48 to GD-50). The decision log and the earlier report call this fixed. Checked against the current table, three of the listed items still have no row: how the left/right check is answered (UX-20), the shaken hook, and the crossing input lock. The hum's flame condition was corrected in the HUD table after the GDD update, with no row. Marked partly addressed for that reason.

**[Accessibility]** — H1: The dead on the deck, and the lifetime of a cue, have no visual in the dark (§ EXPERIENCE.md, HUD & Diegetic UI (table and cue-mode table); UX-27)
A hearing player tracks walkers in the dark by a cry every 8 s plus footsteps. The table that claims to be "the whole of what the player can know at night" has no row for this. Once a Grappler is on the planks and walking through an unlit section, a deaf player has nothing until it enters lantern or gate light. The spec also never says whether a level cue lasts for the warning or for as long as the threat is there.
Fix: Add the row. In Cues everywhere, give footfalls the same pale glow as the other cue objects. State the lifetime rule: a level cue runs for the whole warning and stops when the threat lands.
Status: **Decided (UX-38).** UX-38: in Cues everywhere, footsteps on the deck and bowing planks also glow faintly in the dark; "A pointer cue lasts for the whole of its warning". Both are in the cue-mode table. Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — H2: The way into deaf play is hidden, and the first-launch flow cannot be answered without hearing (§ EXPERIENCE.md, Information Architecture (first-launch chain); State Patterns, Left or right?; Key Flows, Tomas, step 3; UX-20, UX-21)
Nothing on the dark screen says a sound was played, the stroke cannot be replayed, and a guess passes half the time with no offer made. After two wrong answers the offer is "Swap left and right", which is the wrong remedy for someone who heard nothing. Cues everywhere is never offered; Tomas only finds it by pressing Esc in planning, after the lesson he needed it for. The lesson itself does not say whether the three cries show their visual cue, and the pairing of sign to level is taught nowhere.
Fix: On the check screen add one plain line ("A bell rings on one side.") and a third answer, "I can't hear it", plus a key to ring again. That answer, and the wrong-twice state, both offer "Show cues everywhere" beside the swap. State that the dusk lesson always shows each cry's visual cue and that "points it out" is the glowing cue plus a caption.
Status: **Decided (UX-38).** UX-38: "I can't hear it" offers "Show cues everywhere"; R rings again; the wrong-twice state makes the same offer. The key card's Signs group now teaches sign to level. Not picked up: the plain line on the check screen, and a statement that the lesson shows each cry's cue for a player in Cues everywhere (State Patterns still has the lesson hold the cue back until three playings go unfaced). Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — H3: The flame is the only direction-finder, and it is weak at exactly that job (§ EXPERIENCE.md, HUD table "A cry's side", cue-mode table; UX-27; GDD GD-28, GD-16)
A cue glowing behind the warden, or 25 m off in fog, is invisible until faced. The only thing that says "turn round" is the carried flame leaning. It points at the nearest cry only, while up to four sound at once; the span is a line, and a lean toward or away from the camera is the one direction a first-person view foreshortens to nothing; and the flame is gone whenever the carried lantern is shuttered, empty, or hung. For a hearing player oil is light; for a deaf player oil is also hearing.
Fix: Specify the carry pose so the lantern is held low and seen from above, with a stated minimum lean angle. In Cues everywhere, let a shuttered lantern's seam glow, or an empty one's wick ember, keep leaning and dipping. Then test it: one muted night in Cues everywhere, judged by "face each warning within 4 s".
Status: **Partly addressed (UX-38).** UX-38: a shuttered lantern's seam glow still leans in Cues everywhere. Carrying height and a minimum lean angle are left to the art pass, an empty lantern still gives nothing, and the muted test night has not been played (it is listed as a known gap in the Accessibility Floor).

**[Accessibility]** — H4: From wave 4 the caption reaches a deaf player late by design (§ EXPERIENCE.md, Accessibility Floor, known gaps; GDD GD-39)
Partly an accepted gap; reconsider. From wave 4 the ally calls only when the warden has not turned within 4 s of a cry starting, and drops calls that would be late. A player who cannot hear never turns in time, so every caption arrives at least 4 s into a warning (a Grappler's is 6 s long). GD-39's reason ("so that the ear has to lead") does not apply to someone who chose this mode.
Fix: In Cues everywhere, keep the waves 1 to 3 rule all night: every cry called 2 s in. One condition, no new lines to record.
Status: **Decided (UX-38).** UX-38: in Cues everywhere the ally calls every warning, 2 s in, all night; GD-39's fade applies to the other two modes only. With four warnings at once a call can still be dropped (known gap). Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — H5: The ready pose and the forearm are not guaranteed to be visible (§ EXPERIENCE.md, Interaction Primitives "Ready pose"; HUD table; State Patterns "Night")
The ready pose is the only sign that an action is available, the hold animation is the only progress read-out, the "can't" gesture is the only refusal, and the forearm is the only count of parts. All four are 3D objects that need light. With the carried lantern shuttered, empty or hung, the hands are black on near-black. For a deaf player the paired sounds are gone too, so nothing at all is left.
Fix: One rule: the warden's hands and forearm never fall below a fixed minimum brightness and the forearm's ink is exempt from the hatching pass. Applies to the gray-box hands at gate 2 as well.
Status: **Fixed.** In both spines: EXPERIENCE.md, HUD & Diegetic UI, "Seen without a lantern"; DESIGN.md, closing paragraph of Components (minimum brightness; ink kept clear of hatching). No brightness value is given, and the gray-box hands are not named.

**[Accessibility]** — H6: Press-instead-of-hold is cheap enough that leaving it out is a mistake (§ UX-25; EXPERIENCE.md, Input Schemes; Accessibility Floor, known gaps)
Accepted gap; reconsider. A night is built from holds of 2 to 12 s, several of them on a mouse button gripped while the same hand looks around. That is painful for far more people than "limited hand strength or one hand": RSI, tremor, arthritis, a trackpad. Rebinding needs a screen of its own and is fairly left out. This does not.
Fix: One setting under Controls, "Holds: hold / press once". Durations, cancel rules and balance are unchanged. Offer the same for Tab.
Status: **Decided (UX-39).** UX-39: Holds: Hold / Press once; Tab becomes a toggle. Reverses the hold-toggle half of UX-25's declined option; rebinding stays out. Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — H7: Keyboard layout is not addressed; without rebinding it decides who can play (§ EXPERIENCE.md, Input Schemes; DESIGN.md, key-card, key-prompt; UX-20)
If keys are matched by character, an AZERTY player gets W A on Z Q positions and the digit row gives & and é without Shift, so walking and building break with no remedy. If matched by position, play works but the prompts print the wrong names. The spec does not say which.
Fix: State both halves: bind every action by physical key position, and print key names through the layout.
Status: **Fixed.** Accessibility Floor, "Keys by position", and Input Schemes. The Godot specifics are an [ASSUMPTION] for architecture to confirm against 4.7.


### Medium (33)

**[Flow coverage]** — R1.1: Tomas's flow contradicts the logged journey (§ EXPERIENCE.md, Key Flows, Tomas, step 2)
UX-35 says he "fails the left/right check, takes the swap"; the flow said "He declines the swap".
Fix: Pick one and make the log and the flow agree. Declining fits a listener with one weak ear better, so amending UX-35 is probably the right direction, but it is the developer's call.
Status: **Fixed.** The flow now reads "He takes the swap, so the game's left now reaches his good right ear" (decision log, Finalize: rubric fixes). The log was kept and the flow changed, the opposite of the reviewer's lean.

**[Flow coverage]** — R1.2: The GDD's "first cry within 60 s of Start" is not protected on the first-launch path (§ EXPERIENCE.md, Key Flows, Linh's first watch, steps 1 to 4; Component Patterns, key-prompt)
Between "Begin the watch" and the first cry sit two question screens, a left/right check that can be answered wrong twice, and key-prompts for look and walk that stay until the action has been done once. UX-22 argues only that the hands-on part comes after the cries.
Fix: State where the 60 s is measured from (entering the dusk lesson is the natural point) and that the first cry starts on a timer whether or not the look and walk prompts have been cleared.
Status: **Fixed.** State Patterns, Dusk lesson, Opening: the first cry starts within 15 s of the lesson opening and is itself the look lesson. Recorded in the log as an [ASSUMPTION], so it is a rule for Sonlm to confirm. Not timed in a build.

**[Token completeness]** — R2.1: Caption sizes small and large exist only as prose (§ DESIGN.md, Typography, Caption row; EXPERIENCE.md, Accessibility Floor, Settings list)
"Caption size" is a shipped setting, but a Theme built from the frontmatter has only the medium size.
Fix: Add `typography.caption-small` and `typography.caption-large`.
Status: **Fixed.** Both tokens are in the DESIGN.md frontmatter (36 px and 56 px).

**[Token completeness]** — R2.2: The `components` frontmatter is thinner than the Components prose (§ DESIGN.md, frontmatter `components` against body Components)
A consumer that mirrors the frontmatter loses states: tool-tray group label and counts; span-section stripped rail, section number and fallen outline; rig-mark tag; key-card group labels; two-choice gap and question typography; ledger-page vow and epitaph styles; centre-dot opacity; menu-item hover. setting-row disagrees with itself: prose says the row turns warm, frontmatter has only `value-color-chosen`.
Fix: Make the frontmatter the full set and let the prose explain it.
Status: **Not addressed.** Checked against the current frontmatter: the listed keys are still missing and setting-row still has only `value-color-chosen`. The menu-item hover item no longer applies because the separate hover state was removed.

**[Token completeness]** — R2.3: The effects that carry legibility are described but not quantified or tokenised (§ DESIGN.md, Elevation & Depth; Shapes; Components)
The glow ("about 0.7 of the text's height", no opacity), the halo ("tight"), the pause dim ("about 15%"), hairlines ("1 to 2 px"), the centre dot's 60%. The halo matters most: `caption` on `warm` is 1.4:1, so over lantern light the halo is the only thing making the one always-on line readable.
Fix: Add an `effects` block (glow radius and alpha, halo width in px at 1080p, pause dim, hairline width) and state the halo as the contrast guarantee for text over the 3D view.
Status: **Partly addressed.** The halo now has numbers (a solid 4 px outline and a soft 12 px spread at 1080p) and the chosen item gained a 2 px warm rule. There is still no `effects` block; glow opacity, pause dim and hairline width are still approximate.

**[Token completeness]** — R2.4: Hover is specified two ways (§ DESIGN.md, Components, menu-item; EXPERIENCE.md, Component Patterns, menu-item)
DESIGN.md gave menu-item a separate pointer-hover state in `ink-bright`; EXPERIENCE.md says hover and keyboard choice are the same state. `ink-bright` against `ink` is only 1.4:1 apart.
Fix: Keep EXPERIENCE.md's rule (hover chooses, warm with glow) and delete the separate hover state, or define when hover does not choose.
Status: **Fixed.** DESIGN.md menu-item now reads "Chosen (by keys or by the pointer resting on it)"; the separate hover colour is gone.

**[Component coverage]** — R3.1: The ledger's content is not committed in either spine (§ DESIGN.md, Components, ledger-page; EXPERIENCE.md, Voice and Tone; Component Patterns, ledger-page)
UX-14 says "its seven lines"; the spines never said seven, never listed them and never pointed at the GDD's list. Label and value formats existed only in the mock. The no-name variant was open. DESIGN.md says label above value; EXPERIENCE.md's Voice example is inline, "Sections standing · 3 of 6".
Fix: Add a seven-row table to ledger-page: label, value format, what shows at zero or none, order (cite the GDD for which lines exist).
Status: **Partly addressed.** ledger-page now commits seven lines in the GDD's order, with each format and the "None" variants in a numbered list under the Component Patterns table (decision log; GD-53 for the closing line). One thing in the finding is still open in words: DESIGN.md draws the label above the value while EXPERIENCE.md writes the formats inline with " · ".

**[Component coverage]** — R3.2: The two closing choices at dawn have no component (§ DESIGN.md, Layout & Spacing, Dawn; EXPERIENCE.md, Component Patterns, hold-control, two-choice, ledger-page)
Layout put them "at the foot of the page"; hold-control listed Leave the bridge as a 1 s hold without saying where; Linh presses Enter on "Another night"; two-choice binds A and D and has a question line.
Fix: Name them (two menu-items, the second a hold-control) and say whether Leave the bridge is held at dawn as it is in Pause.
Status: **Fixed.** Named as two menu-items (Information Architecture, Dawn row; menu-item and ledger-page rows). Leave the bridge is no longer a hold anywhere: from Pause it asks first, at dawn it does not ask.

**[Component coverage]** — R3.3: hold-control does not say what is held (§ EXPERIENCE.md, Component Patterns, hold-control; Input Schemes)
Space is given for Ring the bell; for Start over and Leave the bridge nothing is, nor whether Ring the bell can also be click-held from the tray.
Fix: One line per control with its inputs.
Status: **Fixed.** hold-control now states: a full 1 s hold of its key (Space for Ring the bell) or of the left mouse button on the entry (Ring the bell, Start over).

**[Component coverage]** — R3.4: Start over's effect is never stated in the spines (§ EXPERIENCE.md, Component Patterns, hold-control; Interaction Primitives)
UX-17 says it "restores the whole span to dusk"; the spines gave only its position, wording and hold time.
Fix: Add the effect, and that parts in hand return to zero and every rig and lantern is taken back.
Status: **Fixed.** hold-control: "Start over restores the whole span to dusk: every plank and rope back, every rig and placed lantern removed (UX-17)."

**[Component coverage]** — R3.5: Surfaces carry elements that no component covers (§ EXPERIENCE.md, Information Architecture table; State Patterns, Settings)
Credits (asset licences and the AI disclosure are long text; no layout, type role or scrolling rule); the swap offer and single-channel warning on Left or right?; one-line notes (the line under the Cues choice, the "best with headphones" note); the title wordmark.
Fix: Add a `credits-page` and a `note-line` component (or widen why-line), and say the swap offer is two menu-items.
Status: **Not addressed.** Still 17 components. No credits-page or note-line, and the swap offer's component is not named. The log records that Credits and the first-launch questions are "built from spine tables alone".

**[State coverage]** — R4.2: Journal lifetime is undefined (§ EXPERIENCE.md, Information Architecture; setting-row; Skip the lesson?)
"No save" sits beside settings and the lesson flag being kept between launches. Nothing says whether hints survive Another night, Leave the bridge to Title, or quitting. This decides what the architecture persists.
Fix: State the scope of each kept thing in one table: settings (machine), lesson-finished flag (machine), journal hints (sitting or machine), the read name (one night).
Status: **Fixed.** Stated in Assumptions and open items: hints last while the game is running and are gone at the next launch; only settings and the lesson flag are kept on disk. The name is rolled again every night (GD-52). It is an [ASSUMPTION] in the log, not a decision, and a list, not a table.

**[State coverage]** — R4.3: The crossing input lock adds to the GDD and has no trigger (§ EXPERIENCE.md, State Patterns, Night, "Knocked down, hanging, crossing a gap")
"No input but look until it ends" adds an input lock to two crossings the GDD only times (open section 4 s, fallen gap 8 s), and neither document says how a crossing starts or whether it can be abandoned.
Fix: State the trigger (walking onto the edge is the obvious one) or mark it [OPEN] for architecture, and list it under GDD impacts.
Status: **Not addressed.** The row is unchanged; no trigger, no [OPEN] mark and no GDD impacts row in EXPERIENCE.md. Whether GDD draft 0.6 settles it was not checked here.

**[Inheritance discipline]** — R7.2: Thirteen logged decisions are contradicted, weakened or renamed (§ EXPERIENCE.md and DESIGN.md, several sections; decision log UX-6, 7, 8, 13, 14, 17, 19, 21, 23, 24, 29, 35, 36)
Contradicted: UX-35 (Tomas and the swap), UX-24 (Leave the bridge "asks first" became a hold; pause logging missing). Weakened: UX-19, UX-17, UX-14, UX-29, UX-7, UX-8, UX-13, UX-21, UX-36, UX-6 each lost a clause. Renamed: UX-23 ("Start" became "Begin the watch"). The two that change what gets built are UX-24 and UX-35.
Fix: Restore the dropped clauses, or record each change in the log's derived list so the log stays canonical.
Status: **Fixed.** Decision log, Finalize: both contradictions reversed, the ten clauses restored, and a naming note added for UX-23. Spot-checked in the current text. For UX-8, the night's plank order has since changed to evenly spread (GD-54), and "the name shows through at 4 or fewer" still appears only in a flow.

**[Accessibility]** — M1: The hum, the tune and the bell: the name is close to unreachable without hearing (§ EXPERIENCE.md, HUD table ("The name's section", "The one who keeps coming back is here", "Left as the GDD has it"); Game Feel, Right ring, Wrong ring)
The hum's cue is the same flame lean as a cry's. The returning one's cue is ropes that "sway in time" where a Grappler's "shake"; in a faint glow at distance that difference carries the whole "ring now" decision, and a wrong ring quickens the dead. The result of a ring is visible only in light. The night still completes, but the game's signature moment is not available. Separately, "whether the bell would work now is heard in the tune and not shown" contradicts the table row that gives the tune a visual cue.
Fix: Give sway and shake numbers that cannot be confused. Make the hum lean distinct from a cry lean (straight down toward the deck) and say the hum lean yields only to cries inside the flame's own light. On a right ring, let the tune's ropes fall still and their glow fade over the 2 s of the resolving note.
Status: **Accepted gap.** Stated as a known gap in the Accessibility Floor ("Calling the name is hard to do by sight alone"). One part moved: the HUD table now says the flame leans to the hum only while no cry is sounding. No numbers for sway against shake, nothing on the right ring, and the "not shown" sentence still sits beside the table row.

**[Accessibility]** — M2: A window going out has a sound but no cue in view (§ UX-30, UX-37; EXPERIENCE.md, HUD table "Windows left"; Game Feel "Window out")
UX-30 added the sound because the windows are behind the warden. Its "visual cue" is the window itself, which is behind the warden. A deaf player learns of each loss only by turning. Windows are the loss condition.
Fix: Tie the town's warm spill on the deck near section 6, or a brief dim-and-recover of the gate light, to the window count. If that is too subtle, in Cues everywhere add one slow lean of the carried flame toward the town.
Status: **Accepted gap.** Stated as a known gap in the Accessibility Floor: "a window going out behind the warden has no cue in view". No cue was added.

**[Accessibility]** — M3: The toll cue is easy to miss or miscount, and the flame now means five things (§ UX-28; EXPERIENCE.md, cue-mode table; UX-7)
Counting up to six dips needs a lit flame in view at that moment, during a fight, and cannot be re-read short of walking to the tally board. A single flame carries side (lean), the hum (lean), tolls (dip) and oil (sputter).
Fix: Make each signal a different kind of movement and write that down in one table: lean = direction, dip = toll, sputter = oil, with the dip slow and deep and the sputter small and irregular. Let the tally board's chalk glow in Cues everywhere.
Status: **Partly addressed.** The Accessibility Floor now gives a toll dip about 0.8 s and keeps the sputter on the flame itself, which separates the two in practice. There is no table of flame movements and the tally board does not glow in Cues everywhere.

**[Accessibility]** — M4: A groaning section in the dark shows nothing (§ EXPERIENCE.md, cue-mode table)
Bowing planks are not in the glow list, so the 2 s groan before a collapse has no visual in the dark. Sections 1 to 5 are not under the gate light, and a collapse there costs rigs and a wound.
Fix: Add bowing planks to UX-27's glow list.
Status: **Decided (UX-38).** UX-38: bowing planks glow faintly in the dark in Cues everywhere (cue-mode table). Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — M5: Single-ear listeners on headphones lose every cry on one side (§ EXPERIENCE.md, Accessibility Floor, known gaps)
Accepted gap; reconsider. With stereo placement and one working ear on headphones, cries on the deaf side are quiet or absent, so even the kind of cry is lost. A wound on the good side removes the rest for 20 s.
Fix: A "Mono sound" toggle next to Swap left and right, paired in its help line with Cues everywhere.
Status: **Decided (UX-39).** UX-39: Mono sound is a setting; choosing it suggests Cues everywhere. The Godot downmix is an [ASSUMPTION] for architecture to confirm. Decided in the documents only: GDD GD-50 puts this build work in epic 8, after gate 2.

**[Accessibility]** — M6: "Chosen" and "hold filling" rest on hue and a glow; the two documents disagree on hover (§ DESIGN.md, Colors; Components menu-item, hold-control; Do's; EXPERIENCE.md, Component Patterns, menu-item)
Warm against ink is 1.12:1 in luminance, so in greyscale the chosen item differs only by its halo. A hold filling from ink to warm is the same step and is invisible in greyscale, which breaks DESIGN.md's own rule. DESIGN.md also gave pointer hover an `ink-bright` state brighter than warm, so a hovered item could outshine the item Enter will act on.
Fix: Follow EXPERIENCE.md (hover = chosen) and delete the hover colour. Add a 2 px warm rule under the chosen item. For hold-control, grow that rule left to right with the fill.
Status: **Fixed.** All three done in DESIGN.md: hover equals chosen, a 2 px warm rule under the chosen item, and the hold shown by that rule growing.

**[Accessibility]** — M7: The planning tray does not fit on one strip at the type floor (§ DESIGN.md, Layout & Spacing "Planning"; Typography "Floor"; Components tray-tool; UX-33)
The tray's text at the floor comes to well over the 1,824 px inside the safe margins. The mock fits it by going under the floor and by wrapping. Whoever builds this will shrink the text.
Fix: Allow two rows in the spec (parts and tools above; Journal, Keys, Start over, Ring the bell below), costs in `muted`. Measure once in Godot at 720p.
Status: **Fixed.** DESIGN.md Layout now specifies a two-line strip. The log leaves it "for Sonlm to confirm". Not measured in Godot.

**[Accessibility]** — M8: Body text at 720p is thin, and there is no way to enlarge it (§ DESIGN.md, Typography; UX-34)
Cormorant Garamond has a low x-height and hairline strokes. `body` at 720p is 21 px, an x-height of about 8 px, used for the why-line, journal hints, settings labels and key card actions. Caption size is adjustable; nothing else is.
Fix: Keep the face. Add "Text size: normal / large" under Display that scales the theme by about 1.25, and check the tray and ledger at that size.
Status: **Not addressed.** No Text size setting in the Settings list.

**[Accessibility]** — M9: Captions and dusk prompts sit over the brightest part of the frame with only a tight halo (§ DESIGN.md, Elevation "Halo"; Layout "Caption"; Components caption-line, key-prompt)
Bottom centre is where the hands and the carried lantern are. Caption colour against lantern warm is 1.43:1, so legibility is the halo alone, on a thin serif. The dusk key prompts are worse: 32 px over a dusk scene brighter than night, and they are the only controls teaching.
Fix: Give the halo numbers. Add "Caption backing: off / on" under Display. State that the forearm's marks sit above the caption band.
Status: **Partly addressed.** The halo has numbers (4 px outline, 12 px spread at 1080p). Caption backing was explicitly not taken up (decision log), and the forearm against the caption band is not stated. Not checked against a bright frame.

**[Accessibility]** — M10: Tallies must be countable, and nothing says how big they are (§ DESIGN.md, Components (closing paragraph); EXPERIENCE.md, HUD table; UX-6)
Up to 48 planks and 12 ropes as strokes on skin, read while the night keeps running. Past about fifteen, fives are slow to count and easy to lose.
Fix: State a minimum: the raised forearm fills at least 40% of view height; strokes at least 6 px wide at 1080p; planks and ropes on separate rows with a small drawn plank and rope at the head of each; every second bundle of five set apart.
Status: **Not addressed.** DESIGN.md still says only "tally strokes in fives".

**[Accessibility]** — M11: No brightness control in a near-black game whose cues "glow faintly" (§ EXPERIENCE.md, Accessibility Floor, Settings list; UX-27)
`world` against `abyss` is 1.04:1 and the Cues everywhere glow has no minimum. On a laptop panel in daylight the cue disappears; on a crushed-black display the dark sections do. Nobody raised this.
Fix: A Brightness slider under Display with one calibration line, and a stated floor for the cue glow (about 3:1 against fogged dark at default brightness).
Status: **Decided (UX-39).** UX-39: Brightness slider with a "barely visible" calibration mark. The cue glow still has no stated minimum.

**[Accessibility]** — M12: A hold is fragile in ways the spec leaves open (§ EXPERIENCE.md, Interaction Primitives "Hold"; State Patterns "Hold cancelled", "Pause")
At 3.5 m/s, 0.5 m is about 0.14 s of a movement key, so a brush of W ends a 12 s build. Not stated: whether looking away cancels; whether parts are spent at the start or the end; what happens to a hold when the game is paused and the key released.
Fix: Write four lines: look is free during a hold; a movement key must be held about 0.3 s before it breaks a hold; parts are spent on the final beat; a hold survives pause.
Status: **Partly addressed.** Three of the four are written (free look, parts spent when the hold completes, pause freezes and does not cancel). The cancel is still 0.5 m of movement with no grace time, so the brush of W still ends a build.

**[Accessibility]** — M13: Aim and click targets have no stated tolerance (§ EXPERIENCE.md, Interaction Primitives "Look decides", "Dwell to read"; Component Patterns span-section)
No reticle by default, targets the size of a pin or a rope, a 1 s dwell on letters seen through gaps, and in planning a rail drawn as a thin line that must be clicked.
Fix: Night: pick targets with a fat ray (a sphere of about 0.25 m), and let dwell time build up across small wobbles. Planning: a rail's click zone is the outer quarter of its section, at least 48 px deep at 1080p. Say that hold-controls can be held with the mouse as well as the key.
Status: **Not addressed.** No tolerances anywhere. Only the last sentence was picked up: hold-control now names the left mouse button.

**[Accessibility]** — M14: The hardest inputs are never taught (§ UX-22, UX-4; EXPERIENCE.md, State Patterns "Dusk lesson / Hands-on part"; Component Patterns key-card)
The hands-on part does not cover building (1, 2), dismantling (R), the stand-face-look rule, hauling a trapdoor back up, re-hanging a beam, re-laying a plank, refilling, or the bell rope. These are the long, conditional ones, met for the first time under pressure with no prompt.
Fix: Put the conditions on the key card. Add a short "Signs" group to the same card. One build in the hands-on part would be better still, but costs lesson time.
Status: **Fixed.** key-card now lists each key's condition and has a fourth group, Signs. The hands-on part did not gain a build (the reviewer's optional extra).

**[Accessibility]** — M15: E and F change meaning with nothing to say which meaning is live (§ UX-36; EXPERIENCE.md, Input Schemes (E); Interaction Primitives "Look decides")
E has three look-dependent meanings and no ready pose. "Re-lay the plank under it" and "take the lantern down" sit in the same view; the wrong one removes a light. F is specified by distance, not look: with a lantern in hand and another hung within 2 m, the spec does not say which shutter closes.
Fix: Give the lantern-and-rope hand three small ready poses for E. State F's rule: the hung lantern if it is looked at, otherwise the carried one. Enumerate the full pose list once.
Status: **Not addressed.** The E row was rewritten for GD-49 (one lantern in hand; hang, take or swap at a pole), which changes E's meanings but adds no ready pose for E and no rule for F.

**[Accessibility]** — M16: A lost night wipes the plan (§ EXPERIENCE.md, State Patterns "Planning / After a lost night")
The player gets one hint and must then rebuild four minutes of planning from memory, click by click, to change one thing. That works against the "replay within 3 s" target.
Fix: Open planning after a lost night with the previous plan still in place; Start over already returns the span to dusk.
Status: **Decided (UX-40).** UX-40: the plan the lost night was started with is restored exactly; Start over wipes it. Since GD-52 the name and its section are rolled again and the forearm is blank.

**[Accessibility]** — M17: "No flashing" is claimed but the flame effects have no limits (§ EXPERIENCE.md, Accessibility Floor; State Patterns "Lantern near empty"; cue-mode table; UX-7, UX-28, UX-37)
A lantern is most of the light in a near-black frame, so anything it does is a large-area brightness change. A sputter runs for the last 60 s of every tank. All flames dipping together is a whole-scene change up to six times in a row. None of these has a rate or depth.
Fix: Three numbers. The sputter animates the flame itself while the light it casts stays steady. Nothing changes brightness more than three times a second. A toll dip takes about 0.8 s end to end.
Status: **Fixed.** All three are in the Accessibility Floor, and the claim was reworded to "No full-screen flash".

**[Accessibility]** — M18: Forced camera movement is unspecified, and the floor's claim about it is wrong (§ EXPERIENCE.md, State Patterns "Knocked down, hanging, crossing a gap", "Dawn"; Accessibility Floor; Settings list)
Knock-down, a fall and climb back, hand-over-hand crossings and the rise at dawn are all camera moves the player does not control, the usual trigger for motion sickness. There is no field-of-view setting and no statement on head bob. The floor's sentence ("The only full-view change is the wound's darkened side") is contradicted.
Fix: No camera roll, no head bob, forced moves eased and slow. Add a field-of-view slider. Add "Reduce camera motion" that swaps knock-down, the climb and the dawn rise for a short fade. Correct the sentence in the floor.
Status: **Partly addressed (UX-39).** Field of view slider added (UX-39); "The camera has no bob and no roll"; the floor's sentence was corrected. "Reduce camera motion" was explicitly not taken up (decision log), and nothing says forced moves are eased and slow.

**[Accessibility]** — M19: The wound's darkening has no extent, and it can cover the caption (§ EXPERIENCE.md, State Patterns "Wounded"; Game Feel)
Half the view dark and one ear dulled for 20 s is disorienting for some players and close to blindness for anyone whose usable vision is on that side. Nothing says how dark, how wide, or whether the caption is drawn above it.
Fix: State it: an edge gradient covering at most the outer third of that side, at most about 60% dark, fading over 1 s or more, always drawn under the caption line.
Status: **Not addressed.** The Accessibility Floor now calls it a slow fade; extent, depth and drawing order against the caption are not stated.


### Low (32)

**[Flow coverage]** — R1.3: Three behaviours are committed only inside a flow narrative (§ EXPERIENCE.md, Key Flows (Tomas step 1; Linh calls the name step 7; Linh's first watch step 9))
The speakers "best with headphones" line, the ledger's name line appearing only when a name was learned, and "one key" continuing from the lost-night page sit where an extracting consumer will not look.
Fix: Move each into Component Patterns or State Patterns and leave the flow as the illustration.
Status: **Fixed.** All three now have a home outside the flows: the notes under the Information Architecture table (Headphones or speakers?, UX-19), the ledger line formats under Component Patterns ("Names learned", or "None"), and State Patterns, Lost night ("one action continues").

**[Flow coverage]** — R1.4: No flow walks the returning player or Leave the bridge (§ EXPERIENCE.md, Key Flows)
Not required at four flows; noted because those two paths carry the open questions in sections 3 and 4.
Fix: None proposed (noted only).
Status: **Not addressed.** Still four flows. The rules for both paths were tightened elsewhere (Skip the lesson? row; Leave the bridge asks first from Pause).

**[Token completeness]** — R2.5: Contrast is stated for `world` only (§ DESIGN.md, Colors; Components, town-window, span-section)
In the dawn view the gradient runs to `dawn-sky`, where `dim` is 1.7:1, `plank` 1.5:1 and `muted` 3.2:1. The counts are repeated in the ledger, so nothing is lost, but an out window may not be visible.
Fix: Say the span and windows sit in the `world` end of the gradient, or state the ratios.
Status: **Not addressed.** DESIGN.md still states contrast on `world` only and does not say where the span and windows sit in the gradient. Same ground as accessibility L1.

**[Token completeness]** — R2.6: tray-tool's cost is "a smaller run (still at the floor)", but the tray is set at the floor (§ DESIGN.md, Components, tray-tool against Typography, Floor)
`label` is the floor, so a smaller run cannot also be at the floor.
Fix: Same size, set in `muted`.
Status: **Fixed.** tray-tool now sets cost in `typography.body` lower case and `muted`; nothing is below the floor.

**[Token completeness]** — R2.7: Lining tabular figures depend on OpenType features in the bundled font (§ DESIGN.md, Typography, Figures; UX-34)
The requirement is stated; the font-side condition is not.
Fix: Note that the Godot font import must enable `lnum` and `tnum`, and check the bundled Cormorant Garamond build has them.
Status: **Not addressed.** No such note in DESIGN.md. The font file has not been checked.

**[Token completeness]** — R2.8: Token housekeeping for the Theme builder (§ DESIGN.md, frontmatter)
`rail` and `muted` share `#8d8982`; `spacing.4` is referenced nowhere; `dawn-sky` is referenced by no component because the dawn and planning grounds are not components. Harmless.
Fix: None proposed (listed for the Theme builder).
Status: **Not addressed.** Unchanged in the current frontmatter.

**[Component coverage]** — R3.6: rig-mark and span-section give different undo rules (§ EXPERIENCE.md, Component Patterns)
rig-mark says right click on its section removes the rig and returns its cost; span-section and UX-17 say right click undoes the last choice on that section, which may be a plank strip made after the rig.
Fix: rig-mark defers to span-section's rule.
Status: **Not addressed.** Both rows read as they did.

**[Component coverage]** — R3.7: why-line's trigger is narrower than the refusals that promise one (§ EXPERIENCE.md, Component Patterns, why-line, span-section)
The trigger covers an unavailable tool and a section where the chosen tool cannot go, but span-section also promises a why-line for refused strips with no tool chosen (section 6 at 4 planks). A rail that holds a swing-beam cannot be stripped and has no stated response.
Fix: Widen the trigger to "any refused click in planning" and add the beam-rail case.
Status: **Not addressed.** why-line's trigger is unchanged and the beam-rail case is not written.

**[Component coverage]** — R3.8: setting-row covers values only (§ EXPERIENCE.md, Accessibility Floor, Settings list)
"Check left and right" is an action, sliders have no step, and Resolution has no stated list.
Fix: One line each.
Status: **Not addressed.** Not written. Two sliders were added since (Brightness, Field of view; UX-39), also without a step or range.

**[Component coverage]** — R3.9: two-choice has no Esc rule, and Skip the lesson? has no wording (§ EXPERIENCE.md, Component Patterns, two-choice; Information Architecture)
The diagram uses Yes and No.
Fix: State the Esc rule and the wording.
Status: **Not addressed.** Neither is stated. The menu-item row now lists "the skip question" among its uses, which gives it menu-item's Esc rule by implication only; the diagram still says Yes and No.

**[State coverage]** — R4.4: Left or right? is missing rows (§ EXPERIENCE.md, Information Architecture table; State Patterns)
No row for one wrong answer (is the stroke repeated?), for what follows accepting the swap (re-test or continue), or for hearing the stroke again. It can also be opened from Settings during a paused night.
Fix: Add the rows.
Status: **Partly addressed.** R rings the bell again (UX-38) and "Either answer continues" covers the swap. What happens after one wrong answer is still not stated.

**[State coverage]** — R4.5: Planning after "Another night" has no row (§ EXPERIENCE.md, State Patterns, Planning)
Span at dusk, nothing in hand, journal kept, a new name section per the GDD; and ringing the bell on an untouched span is not stated as allowed.
Fix: Add the row.
Status: **Partly addressed.** GD-52 (every night is a new run: name and section rolled again, forearm blank) is written into the "After a lost night" row, and the journal's lifetime is stated. There is still no "Another night" row, and ringing on an untouched span is not addressed beyond "A lantern still to place".

**[State coverage]** — R4.6: No rule for the window losing focus (§ EXPERIENCE.md, State Patterns)
Alt-tab, a stream overlay. An automatic pause is the usual answer and suits "Mai streams it".
Fix: State the rule.
Status: **Not addressed.** Nothing on focus loss in either spine.

**[State coverage]** — R4.7: Pause pressed during a night hold or with Tab held (§ EXPERIENCE.md, State Patterns, Pause)
Resume "continues from the same instant", but whether the hold survives a released button is not stated.
Fix: State it.
Status: **Partly addressed.** Interaction Primitives now says "Pause freezes a hold and does not cancel it". What happens if the button is up at Resume, and the Tab case, are still unstated.

**[State coverage]** — R4.8: "Nothing is deeper than two steps from play" is not true (§ EXPERIENCE.md, Information Architecture; DESIGN.md, Elevation & Depth)
Pause → Settings → Check left and right is three.
Fix: Correct the sentence.
Status: **Not addressed.** The sentence stands in both spines.

**[Visual reference coverage]** — R5.1: The mock link is unspecific and in one place (§ DESIGN.md, Brand & Style; Layout & Spacing; EXPERIENCE.md, Information Architecture)
It does not say which four screens the mock shows, and neither Layout & Spacing nor EXPERIENCE.md links to it.
Fix: Link at DESIGN.md Layout & Spacing and at EXPERIENCE.md's planning and dawn rows, naming the screen each time.
Status: **Partly addressed.** Both spines now link both mocks and name the screens each shows (DESIGN.md, Brand & Style; EXPERIENCE.md, end of Information Architecture). The links are not at Layout & Spacing or on the planning and dawn rows.

**[Visual reference coverage]** — R5.2: Known differences from the mock are only partly listed (§ DESIGN.md, Typography)
Only the light weight is listed. Also different: the mock has no `muted` role, sets C in weights 300 and 500, says "Layout is not decided here" although UX-33 later fixed the tray, and uses a stand-in name and epitaph.
Fix: One "where the mock differs" list in DESIGN.md.
Status: **Not addressed.** No such list. `key-screens.html` was drawn to the tokens, which reduces the need for the planning and dawn screens.

**[Visual reference coverage]** — R5.3: `.working/directions-1.html` is a byte-identical copy (§ Workspace; decision log, UX-32)
UX-32 in the log still points at the `.working` path. Housekeeping.
Fix: Remove the copy or repoint the log.
Status: **Not addressed.** The copy is still byte-identical and UX-32 still names the `.working` path. A later log line records the promotion to `mockups/`.

**[Bloat & overspecification]** — R6.1: The same rule is stated in three or four places (§ EXPERIENCE.md (Foundation, Component Patterns, HUD & Diegetic UI, Accessibility Floor, Interaction Primitives, Input Schemes, State Patterns, Game Feel, Flow 1))
This is where the drift found elsewhere comes from: the caption rule, hold-to-commit, the lost night, undo.
Fix: One home per rule; the others cite it.
Status: **Not addressed.** The repeats remain.

**[Bloat & overspecification]** — R6.2: Game Feel & Juice restates several GDD outcomes (§ EXPERIENCE.md, Game Feel & Juice)
Right ring, wrong ring, rig sprung. They are marked "(GDD)" and short.
Fix: Trimming is optional.
Status: **Not addressed.** Left as written; the reviewer called it optional.

**[Inheritance discipline]** — R7.3: Terms drift a little (§ EXPERIENCE.md; decision log)
"Key card" against "Keys"; "Start" against "Begin the watch"; "why not line" against "why-line".
Fix: A short glossary line in EXPERIENCE.md.
Status: **Partly addressed.** Voice and Tone now marks "Begin the watch" as the title's Start entry and the log carries a naming note. No glossary line; the other two pairs are unreconciled.

**[Inheritance discipline]** — R7.4: `epics.md` is cited but not in `sources` (§ Both spines, frontmatter `sources`)
The spines cite "GDD epic 5" and "GDD epic 7", which live in `epics.md`.
Fix: Add it.
Status: **Not addressed.** `sources` is unchanged in both files.

**[Shape fit]** — R8.1: There is no Inspiration section (§ EXPERIENCE.md)
It is required when the sources or log show reference products or rejects, and both do: the GDD names Thronefall, Dome Keeper and Kingdom Two Crowns, and UX-32 declines three directions (chalk on slate, ledger paper, engraved plate).
Fix: Four or five lines in EXPERIENCE.md: the three declined directions and why, so a later contributor does not re-propose them.
Status: **Not addressed.** No Inspiration section in either spine.

**[Accessibility]** — L6: The two silences have no visual and no stated length (§ EXPERIENCE.md, State Patterns "Dawn"; Game Feel "Dawn")
The 10 s hush before wave 6, and dawn's silence.
Fix: State the dawn pause (about 3 to 4 s) and that all cue glows fade together as the cries stop. Leave the pre-wave-6 hush as it is.
Status: **Not addressed.** GD-53 fixed the order at dawn (silence, the ally's line, then the ledger), but EXPERIENCE.md gives the silence no length and says nothing about the glows fading.

**[Accessibility]** — L9: Two identical calls in a row look like one (§ EXPERIENCE.md, Component Patterns, caption-line)
"Below!" followed by "Below!" for a second Grappler is one unbroken caption.
Fix: A blank gap of about 0.3 s and a fresh fade-in between any two captions.
Status: **Fixed.** caption-line: "with at least 0.3 s between two captions".

**[Accessibility]** — L1: Graphic states below 3:1 (§ DESIGN.md, Colors; Components span-section, town-window)
`dim` on `dawn-sky` is 1.72:1, so out windows and fallen-section outlines fade into the upper dawn gradient. In planning, `plank` on `world` is 2.62:1 and a stripped rail is a thin dashed 3.1:1 line. The ledger and strength numbers repeat most of this in words.
Fix: Draw out windows, fallen outlines and stripped rails in `muted` at 2 px. Keep the dawn gradient at `world` behind anything that carries a count.
Status: **Not addressed.** Out windows and stripped rails are still `dim`.

**[Accessibility]** — L7: An unavailable tool's cost is in `dim`, and the why-line needs a pointer (§ DESIGN.md, Colors; tray-tool; EXPERIENCE.md, why-line)
The cost is the thing the player must read to make the tool available. Pressing 1 on an unavailable tool does nothing that is specified.
Fix: Keep the name `dim`, set the cost in `muted`. Pressing an unavailable tool's number shows its why-line until the next input.
Status: **Partly addressed.** tray-tool now sets the cost in `muted`, but does not say the cost stays `muted` when the tool is unavailable. The key press on an unavailable tool is still unspecified.

**[Accessibility]** — L8: The name "in a written hand" (§ DESIGN.md, closing paragraph of Components; EXPERIENCE.md, HUD table "Windows left")
A looped script on skin is hard to read. (Counting twelve far windows: no change beyond M2.)
Fix: Pick a clear upright hand, not a looped script.
Status: **Not addressed.** Still "a written hand"; the art pass (GDD epic 7) owns it.

**[Accessibility]** — L3: The lost-night hint can be skipped by a stray key (§ EXPERIENCE.md, State Patterns "Lost night")
The player is mid-fight, keys down, when the night ends. The hint is still in the Journal, so the cost is small.
Fix: Ignore input until the line has finished writing, then continue on Enter, Space or click.
Status: **Not addressed.** Still "one action continues".

**[Accessibility]** — L4: The left/right check should not open with an answer already chosen (§ EXPERIENCE.md, Component Patterns, menu-item against two-choice)
"The first entry is chosen when a menu opens."
Fix: Two-choice screens open with neither word warm.
Status: **Not addressed.** two-choice does not say how it opens.

**[Accessibility]** — L2: The centre dot is too small and faint to do its job (§ DESIGN.md, Components centre-dot)
At 720p it is under 3 px, and grey at 60% vanishes over lantern-lit wood, where a fixation point is most needed.
Fix: 6 px at full opacity with a 1 px abyss ring.
Status: **Not addressed.** Still 4 px at 60%.

**[Accessibility]** — L5: Smaller mismatches between the log and the spines (§ Decision log UX-3, UX-4, UX-22, UX-24, UX-35; EXPERIENCE.md, hold-control, Key Flows, cue-mode table, Accessibility Floor; DESIGN.md, Components)
Six of them: Leave the bridge "asks first" in the log but was a hold in the spine; Tomas takes the swap in the log but declined it in the flow; UX-4 puts the key card on pause only and reads as stale; the gray-box forearm is "a flat panel with the same text" in the log, "the same marks" in EXPERIENCE.md and "never a screen-style panel" in DESIGN.md; the cue-mode table does not name the hum lean; "A visual cue for every sound" is listed under Provided without qualification.
Fix: Pick one reading for each.
Status: **Partly addressed.** Two fixed (Leave the bridge asks first; Tomas takes the swap). The hum's condition is now stated in the HUD table. Three stand: UX-4 is unchanged in the log, the gray-box forearm is still described three ways, and "A visual cue for every sound" is still unqualified beside the known gaps.

## Mechanical notes

- References: DESIGN.md has 25 distinct token references and EXPERIENCE.md has 2; all resolved at review time.
- Frontmatter: types are as the spec asks. The font-family fallbacks (Garamond, Georgia, serif) mean nothing in a Godot Theme with a bundled font; harmless.
- Mermaid: the node id `LR` reused the direction keyword. Fixed: the node is now `LRC`. The diagram was not rendered in the review and still leaves out Pause, Journal and Keys; the table under it covers them.
- Cross-file conflicts found at review: menu-item hover (fixed), rig-mark against span-section undo (stands), ledger label above value against inline (stands), tray-tool "smaller run" against the type floor (fixed).
- Numbers checked against the GDD and found right at review time: 48 planks and 12 ropes; trapdoor 2 ropes; section 6 stops at 4 planks and takes no rig; lantern reach; wound 20 s; 2 m context range; holds of 2 to 12 s.
- Type table order: at review time Typography listed Value (40 px) above Number (48 px). Fixed: the rows now descend by size.
- Not raised as findings, as instructed: the Key Flows are not inherited from the GDD; controller, couch and handheld coverage is absent by design; the night has no HUD; names, epitaphs and journal hint texts are open under GDD epic 5.
- The accessibility reviewer's Godot API names were given from memory and are to be checked against the 4.7 docs.

## Not addressed

- Nothing was run in Godot. The reviews, the fixes and every status in this report are readings of the documents.
- Cues everywhere has not been played muted. EXPERIENCE.md, Accessibility Floor, asks for one muted test night (face each warning within 4 s) before any deaf-playable claim.
- Without hearing, the hum, the tune and a window going out behind the warden remain hard to reach. Stated as a known gap (accessibility M1, M2).
- Optional caption backing and a "Reduce camera motion" setting were considered and not taken up (accessibility M9, M18).
- The accessibility extras of UX-28, UX-38 and UX-39 (Holds, Mono sound) and the muted night are built in epic 8, after gate 2 (GDD GD-50). "Decided" below means decided on paper.
- Statuses were set from the decision log, then from the current text of DESIGN.md and EXPERIENCE.md. The GDD itself (draft 0.6) was not re-read, so a finding marked "Not addressed" may have been settled there.

The 30 findings marked "Not addressed" above, by name:

- Medium — R2.2 [Token completeness]: The `components` frontmatter is thinner than the Components prose
- Medium — R3.5 [Component coverage]: Surfaces carry elements that no component covers
- Medium — R4.3 [State coverage]: The crossing input lock adds to the GDD and has no trigger
- Medium — M8 [Accessibility]: Body text at 720p is thin, and there is no way to enlarge it
- Medium — M10 [Accessibility]: Tallies must be countable, and nothing says how big they are
- Medium — M13 [Accessibility]: Aim and click targets have no stated tolerance
- Medium — M15 [Accessibility]: E and F change meaning with nothing to say which meaning is live
- Medium — M19 [Accessibility]: The wound's darkening has no extent, and it can cover the caption
- Low — R1.4 [Flow coverage]: No flow walks the returning player or Leave the bridge
- Low — R2.5 [Token completeness]: Contrast is stated for `world` only
- Low — R2.7 [Token completeness]: Lining tabular figures depend on OpenType features in the bundled font
- Low — R2.8 [Token completeness]: Token housekeeping for the Theme builder
- Low — R3.6 [Component coverage]: rig-mark and span-section give different undo rules
- Low — R3.7 [Component coverage]: why-line's trigger is narrower than the refusals that promise one
- Low — R3.8 [Component coverage]: setting-row covers values only
- Low — R3.9 [Component coverage]: two-choice has no Esc rule, and Skip the lesson? has no wording
- Low — R4.6 [State coverage]: No rule for the window losing focus
- Low — R4.8 [State coverage]: "Nothing is deeper than two steps from play" is not true
- Low — R5.2 [Visual reference coverage]: Known differences from the mock are only partly listed
- Low — R5.3 [Visual reference coverage]: `.working/directions-1.html` is a byte-identical copy
- Low — R6.1 [Bloat & overspecification]: The same rule is stated in three or four places
- Low — R6.2 [Bloat & overspecification]: Game Feel & Juice restates several GDD outcomes
- Low — R7.4 [Inheritance discipline]: `epics.md` is cited but not in `sources`
- Low — R8.1 [Shape fit]: There is no Inspiration section
- Low — L6 [Accessibility]: The two silences have no visual and no stated length
- Low — L1 [Accessibility]: Graphic states below 3:1
- Low — L8 [Accessibility]: The name "in a written hand"
- Low — L3 [Accessibility]: The lost-night hint can be skipped by a stray key
- Low — L4 [Accessibility]: The left/right check should not open with an answer already chosen
- Low — L2 [Accessibility]: The centre dot is too small and faint to do its job

The 15 marked "Partly addressed" each name what is left in their status line.

## Reviewer files

- `review-rubric.md`
- `review-accessibility.md`
- `.decision-log.md` (from "## Finalize" on: UX-38 to UX-41, GD-49, GD-50, GD-52 to GD-54)
