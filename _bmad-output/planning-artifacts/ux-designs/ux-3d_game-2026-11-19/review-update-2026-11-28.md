# Review of the UX update of 2026-11-28

- **Reviewed:** `DESIGN.md` and `EXPERIENCE.md` at commit d5f3af2, against `.decision-log.md` ("Update run 2026-11-27 to 2026-11-28"), the diff 7571814..d5f3af2, `mockups/type-scale/`, the GDD (draft 0.7), its decision log, `epics.md` (draft 0.8), `game-architecture.md`, `deferred-work.md` (DW-58 to DW-60), `project-context.md` and the code under `game/watch/`.
- **Lenses:** the rubric of `gds-ux/references/validate.md` (Pass 1 and Pass 2), and consistency.
- **Run at:** 2026-11-28. Nothing was edited except this file.

## How the numbers were checked

- **Contrast:** WCAG relative luminance for every pair DESIGN.md states. Every ratio is right except one rounding (L1).
- **Canvas sizes:** every `typography` and `spacing` token is divisible by 3, and the two-thirds column (72, 48, 40, 40, 32, 32, 28, 28, 28; spacing 6, 12, 20, 32, 54, 32, 40) is right. The room inside the safe margin is 1,280 − 2×32 = 1,216 by 720 − 2×32 = 656. Correct.
- **Measured fits:** a scratch Godot 4.7.2 script, kept outside the repo, loaded `game/fonts/cormorant_garamond.ttf` with the theme's settings: weight 600, `lnum`, `tnum` for values, and `spacing_glyph` set to two thirds of letterSpacing × size. It reproduces DESIGN.md's figures exactly: the tools line is **1,080** and the ledger's widest line, "PLANKS AND ROPES LEFT 4, 1", is **471**. The same harness gives the overflows in H1 and H2. Three other figures were checked only against the pictures' pixel extents, divided by 1.5:
  - Settings: about 1,023 wide, against the stated 1,022.
  - Ledger: about 567 tall in glyphs, against 575 in boxes.
  - Key card: about 627 tall in glyphs, against 641.

  All three are consistent with the stated values; none was re-measured with the font.
- **Code:** I read these files: `watch_theme.gd`, `planning.gd`, `span_geometry.gd` (the plan look's constants), `title_screen.gd`, `ui_text.gd` and `input_actions.gd`. The night rules that the update newly cites agree with the code:
  - the 0.5 s, 45° push into an edging or crossing (`warden_constants.gd:32-34`, `warden_rules.gd:78`);
  - presses ignored and a running hold cancelled during timed moves (`hold_rules.gd:13-16`);
  - a change of Holds cancels the running hold (`hold_rules.gd:9`, UX-53 "as built");
  - the rail's 0.3 m grab box (`span_geometry.gd:33`);
  - the 0.5 m hold limit (`hand_constants.gd:11`).

  Not checked: the camera cuts named in EXPERIENCE.md line 158.
- **Citations:** GD-68, GDD:270, GDD:450, DW-6, DW-13 and DW-21 exist and say what the spines cite. `.working/dw5-triage.md` holds no earlier disposition for any of M3 to M8.
- **Token references:** all 24 distinct `{…}` references in DESIGN.md resolve. EXPERIENCE.md resolves `{colors.muted}`; its `{path.to.token}` is the explanatory placeholder. Defined but referenced nowhere: `spacing.4`, `colors.dawn-sky`, and `typography.title`, `caption-large` and `caption-small`. The last three are named in prose.
- **Decision log against the spines:** UX-42 to UX-61 are each carried into the spines without being weakened, except the epic named in UX-47 (M1). The declared code gaps (label 40 against 42, `spacing.2` 16 against 18, the gap from the deck's edge, AD-69's 720p column) are in DW-58 and `project-context.md`, so they are not reported here. The GDD rows in EXPERIENCE.md "From the update of 2026-11-28" match DW-59.

## Rubric verdicts

| Category | Verdict | Findings |
|---|---|---|
| 1. Flow coverage | adequate | The sources name no user journeys. The four flows are intact after the change, but Tomas's step 1 relies on a note-line the new two-choice rule never shows (M3) |
| 2. Token completeness | adequate | Every reference resolves and every colour has a hex. Missing component tokens for states the prose needs: M4, M6, M7. One false claim about sizes: M9 |
| 3. Component coverage | adequate | `span-end` has no Component Patterns row (L7) |
| 4. State coverage | adequate | No look for Ring the bell while it is unavailable (M6). Two-choice hover and choice states are unclear (M4) |
| 5. Visual reference coverage | strong | Every file in `mockups/` is linked and the spines-win rule is stated. One omission in "Where the mocks differ" (L11) |
| 6. Bloat & overspecification | adequate | No findings |
| 7. Inheritance discipline | adequate | M1, M2, L2, L5, L6 |
| 8. Shape fit | strong | DESIGN.md adds one section of its own, "Where the mocks differ", between Components and Do's and Don'ts. The canonical order is kept, so this is acceptable |

## Findings

### High

**H1 — The dawn ledger's widest line overflows the page whenever a count has two digits.** *(Token/Layout; consistency, measured fit)*
- **Where:** DESIGN.md, Layout & Spacing, line 289. EXPERIENCE.md, ledger line formats, line 128.
- **What is wrong:** the fit "widest line 471 of 473" was measured with the stand-in value "4, 1". The line "Planks and ropes left · n, n" can hold two-digit counts: 48 planks and 12 ropes exist, and the GDD's worked night (gdd.md:586) spends 14 planks after the rigs. Neither the GDD ("planks and ropes left", gdd.md:186) nor the spines say whether the count is of parts in hand or parts still on the span. If it is the span, two digits are the normal case. The document warns only about names and epitaphs: "The real names and epitaphs (epic 5) must be checked against that width" (line 289).
- **Evidence:** the same harness that reproduces 471 gives "PLANKS AND ROPES LEFT 12, 3" = **488** and "48, 12" or "10, 10" = **505** canvas px, against 473 of room. A builder following line 289 builds a page that overflows on an ordinary night. The other count lines fit at their worst case: "SECTIONS STANDING 6 of 6" is about 432 and "WINDOWS LIT 12 of 12" is 347. The stand-in epitaph is 427.
- **Fix:** decide one of these with Sonlm, then restate the measurement using the worst case ("48, 12"). Also say which parts the line counts:
  - widen the page to about 45% (505 + 64 = 569 of 1,280 is 44.5%);
  - shorten the label ("Parts left");
  - let this line wrap its value under the label.

  Add the counts to the "must be checked" sentence.

**H2 — A rig-mark's name is wider than the section it is drawn over.** *(Component coverage; consistency with UX-42)*
- **Where:** DESIGN.md, Components, rig-mark, line 324, and its tokens at lines 138 to 141.
- **What is wrong:** the rig's name is set in `{typography.label}` on a `{colors.world}` tag over its section. At scale B, `label` is 28 canvas px with 0.16 em spacing.
- **Evidence:**
  - Measured name widths: "SWING-BEAM" = **211** canvas px, "TRAPDOOR" = **182**.
  - A section's deck in `B-planning.png` runs from x 121 to 393 screen px, which is about **182** canvas px. The fit maths give the same: (1,280 − 2 × (32 + about 34 + 12)) / 30 m × 5 m ≈ 187.
  - "SWING-BEAM" therefore runs past both rail joints and over the neighbouring sections, and "TRAPDOOR" fills the deck edge to edge. At scale A both fitted (145 and 126).
  - No B picture draws a rig-mark, and none of the measured fits covers one.
- **Fix:** give the rig name its own rule. Options: `body` lower case ("swing-beam", about 150 px, to be measured); the name outside the deck, in the read-out's label band; or no name, the frame alone. Then measure it against the 6-section span at 1280×720. The rule must also say where the tag goes relative to the section number and the strength.

### Medium

**M1 — UX-47 is placed in the wrong epic, so no story owns it.** *(Inheritance; consistency with epics)*
- **Where:** EXPERIENCE.md, State Patterns, Dusk lesson, line 143: "(UX-47; the mode is built in epic 8)". The same claim is in `.decision-log.md` line 147 ("Cues everywhere is built in epic 8 (GD-50)") and in DW-20's ux-input (deferred-work.md line 200: "UX-47 … waits for the mode in epic 8").
- **What is wrong:** `epics.md` builds the Everywhere mode in **epic 5**: "Settings: Visual cues (In the light, Everywhere, Ears only), with the cues drawn self-lit in the dark for Everywhere … The left/right check's offer of Cues everywhere is wired here" (epics.md:591). Epic 8 story 10 only *strengthens* it (footsteps, dips, every call; epics.md:716). GD-50 moves the extras, not the mode.
- **Consequence:** UX-47 matters exactly for the player who has just chosen "Show cues everywhere" at the check. It has no owning story: epic 8's list does not include it, and epic 5's story 8 or 11 does not know about it.
- **Fix:** say the mode exists from epic 5. Give UX-47 to epic 5 story 8 (where the check's offer is wired) or story 11 (the lesson's hands-on part). Correct line 143, decision-log line 147 and DW-20's ux-input.

**M2 — `epics.md` carries none of UX-42 to UX-61, and no deferred item routes them there.** *(Inheritance)*
- **Where:** `.decision-log.md` lines 133 to 170.
  - Owners the log names itself: epic 4 story 1 (UX-50), epic 4 story 4 (UX-51, through DW-60), epic 4 story 10 (UX-52), story 5.6 (UX-57), story 5.8 (UX-60), and story 5.1 (UX-44 and UX-45, through DW-58).
  - Owners inferred by this review from epics.md's story titles: story 5.1 (UX-55), 5.7 (UX-54), 5.8 (UX-56, UX-61, and UX-49 for the headphones question) and 5.12 (UX-42, UX-43). The log names no story for these.
- **Evidence:**
  - `grep "UX-4[2-9]|UX-5[0-9]|UX-6[01]" epics.md` finds nothing.
  - Epic 4's stories cite only UX-2 to UX-36 (epics.md, Epic 4 "Delivers").
  - Story 5.12 still cites "UX-32, UX-34". UX-34's floors are superseded (decision log line 142).
  - DW-59 routes these decisions to the GDD and architecture only. DW-20 covers epic 2 only.
- **Fix:** add a DW item, or extend DW-59, to update each named story's decision list in `epics.md`. Make story 5.12 cite UX-42 and UX-43 instead of UX-34's floors.

**M3 — Under the new two-choice rule, "Best with headphones." has no moment to appear.** *(Flow and state coverage; consistency inside EXPERIENCE.md)*
- **Where:** EXPERIENCE.md line 69 ("Speakers adds one note-line: 'Best with headphones.'"), line 108 (note-line: "'Best with headphones.' under Speakers"), line 120 (two-choice: "D or Right arrow [answers] with the right one … at once") and line 368 (Tomas, step 1: "Speakers. A line notes the game is best with headphones."). DESIGN.md line 316.
- **What is wrong:** UX-49 makes A, D or a click answer at once, and the screen leaves to "Left or right?" (IA table, line 53). A note-line "shown for as long as that thing is" (line 108) under a word that is answered and gone on the same press is never seen, and Tomas's step 1 cannot happen.
- **Fix:** choose where the line lives:
  - on the next screen, above the left/right note-line;
  - for a fixed beat before the screen changes;
  - only on the Settings row while its value is Speakers.

  Then say so in EXPERIENCE.md lines 69 and 108 and DESIGN.md line 316.

**M4 — The two-choice states after UX-49 are not fully specified: hover, the third answer's look, and S.** *(State coverage; token completeness)*
- **Where:** DESIGN.md, two-choice, line 333, and its tokens at lines 191 to 198. EXPERIENCE.md, two-choice, line 120, and Input Schemes, line 257.
- **What is wrong:**
  1. "Down chooses 'I can't hear it'", so that answer has a chosen state. DESIGN.md gives it a `third-typography` but no colour (there is no `third-color` token) and no chosen look. EXPERIENCE.md calls it "quieter" (line 54), and `muted` is reserved for unavailable things.
  2. menu-item says "moving the pointer onto an entry chooses it" (line 104). Two-choice does not say whether hovering Left, Right or the third answer makes it warm. So "Enter does nothing while nothing is chosen" is undefined when the pointer rests on a word as the screen opens. That would also break "Neither word is warm when the screen opens" (DESIGN.md line 333).
  3. What Up does after Down is not stated.
  4. AD-70 and `input_actions.gd:40` bind `watch_menu_down` to Down **or S**. The spine says only "Down" (lines 120 and 257).
- **Fix:** add `third-color: '{colors.ink}'` and `third-color-chosen: '{colors.warm}'` (with the glow and rule) to DESIGN.md. In EXPERIENCE.md, state these rules:
  - hover chooses only the third answer, or nothing;
  - Up clears the choice;
  - "Down or S" chooses the third answer.

**M5 — The key card fits only because its rows have no gap, and in the picture they touch.** *(Layout; measured fit)*
- **Where:** DESIGN.md, Layout, line 290 ("Measured with stand-in wording: 641 of 656"). Key-card component, line 330.
- **What is wrong:** DESIGN.md gives no gap between rows. In `B-keys.png`, measured on rows of pixels across the Night action column:
  - the wrapped "pull the bell" (RIGHT MOUSE) and "Hang, take or swap" (E) form one unbroken run, rows 461 to 545;
  - "town-side edge, facing out" (1 2) and "Hold: dismantle" (R) are 3 screen px apart.

  So a row boundary is tighter than the line spacing inside a row, and wrapped actions read as belonging to the next key. The Night column has 9 rows: WASD, Mouse, Left mouse, Right mouse, E, F, 1 2, R and Tab. Even the smallest row gap, `{spacing.1}` (6 canvas px), adds 8 × 6 = 48 px, which makes the column about 689 of 656, and it no longer fits.
- **Fix:** state a row gap (at least `{spacing.1}`) and re-measure. If it no longer fits, decide now, while the wording is still a stand-in: split Night over both columns, or shorten the condition texts. Epic 5's writer needs a word budget per action.

**M6 — Ring the bell has an unavailable state in the spine but no look for it.** *(State coverage; token completeness. Not introduced by this update: hold-control's tokens are unchanged since 7571814. It is reported because R2.2 now claims the frontmatter is complete.)*
- **Where:** EXPERIENCE.md, State Patterns, line 148 ("Ring the bell is unavailable and says why"), and why-line, line 107. DESIGN.md, hold-control, lines 121 to 124 and line 317.
- **What is wrong:** `hold-control` has `color` and `color-filling` only. There is no `color-unavailable`, and nothing says whether the warm rule grows while Space is held on an unavailable bell. Every other unavailable thing is `muted` (UX-43). The decision log (housekeeping R2.2, line 190) claims "frontmatter is the full set".
- **Fix:** add `color-unavailable: '{colors.muted}'` to hold-control. State that an unavailable hold does not fill: the press shows the why-line instead (UX-55's pattern).

**M7 — The slider's colours are undefined, and the obvious reading is nearly invisible.** *(Token completeness; contrast. Not introduced by this update: the slider sentence is unchanged since 7571814. It is reported because UX-43 and R2.2 now claim every mark is covered.)*
- **Where:** DESIGN.md, setting-row, line 332 ("A slider is a hairline with a small square marker"), and tokens at lines 184 to 190.
- **What is wrong:** "hairline" is also a colour token, `#3a3835`, which is **1.72:1** on `world` and is reserved for "The single rule at the edge of the ledger and journal pages" (line 241). `B-settings.png` draws the track and marker light, close to `ink-bright`. A slider's position carries a value, which UX-43's "all text ink or brighter" was meant to protect. No token gives the track, the marker or the chosen state.
- **Fix:** add `slider-track`, `slider-marker` and `slider-color-chosen` to setting-row, for example `ink`, `ink-bright` and `warm`. Write "a 1 px rule" rather than "a hairline".

**M8 — UX-45's gap "from the rail line's outer edge" is ambiguous whenever that line changes.** *(Consistency; component spec)*
- **Where:** DESIGN.md, span-section, line 321 ("Each stands `{spacing.2}` clear of the rail line's outer edge (UX-45)"). Decision log line 136 ("whatever its width or the section count").
- **What is wrong:**
  - A standing rail is 0.2 m wide and a stripped rail's dashes are 0.1 m (line 320). Read literally, the section number or strength moves by about 0.1 m (about 4 canvas px) each time a rail is stripped or undone in planning.
  - A fallen section has no rail line, only an outline 0.1 m wide (line 322), so nothing says where its number goes.
  - `test_planning.gd` will pin literal places (DW-58), so story 5.1 would have to guess.
- **Fix:** say "clear of the outer edge of a standing rail's line, wherever the line is drawn or not". The labels then never move with the span's state.

**M9 — "Every size here is divisible by 3" is false outside type and spacing, and the exceptions land on half pixels.** *(Token completeness; consistency with AD-69)*
- **Where:** DESIGN.md line 212. The decision log (line 209) claims only "every type size".
- **What is wrong:** DESIGN.md also states these sizes at 1080p, and none is divisible by 3:
  - the 2 px warm rule under the chosen item (lines 248, 299, 306), which is 1.33 canvas px;
  - the halo's 4 px outline (line 300), 2.67 canvas px;
  - the centre dot's 4 px (line 201), 2.67 canvas px;
  - the 1 to 2 px hairlines (line 306).

  `canvas_px()` rounds, so the warm rule becomes 1 canvas px, which is 1.5 screen px at 1080p. That is the blur `project-context.md` warns about, on the one mark that carries the chosen state.
- **Fix:** restate these as 3 px (2 canvas px) for the warm rule and 3 or 6 px for the outline and the dot. Or narrow line 212 to "every type and spacing token" and give these marks whole canvas sizes explicitly.

### Low

**L1 — `muted` on `dawn-sky` is 3.2:1, not 3.3:1.** DESIGN.md line 246 says "`muted` (and `plank`) 3.3:1". The computed ratio is 3.246, which rounds to 3.2; the decision log, line 186, correctly says 3.25. The 3:1 conclusion still holds. *Fix:* write 3.2:1, or 3.25:1.

**L2 — The laptop's size is given two ways.** EXPERIENCE.md line 21 and DESIGN.md line 212 say "13 to 14 inch". EXPERIENCE.md line 301 says "chosen on a 14-inch 1920×1080 laptop". The decision log (line 127) has 13 to 14. *Fix:* "13 to 14 inch" at line 301.

**L3 — note-line contradicts itself on where it sits.** DESIGN.md line 316 says "under the thing it explains", then gives as an example "'A bell rings on one side.' above the left/right question". EXPERIENCE.md line 108 says "above or below". *Fix:* DESIGN.md line 316 should say "next to the thing it explains (under it, or above a question)".

**L4 — "The one case where a pause leads to a cancel" is contradicted by the row above it.** EXPERIENCE.md line 168 (UX-53) says it is the only case. Line 167 says "A button let go during the pause cancels its hold on the first tick" (AD-67). *Fix:* "the one case where a pause cancels a hold whose button is still down", or drop "the one case".

**L5 — Two GDD differences are not declared in "GDD impacts".** *(Inheritance)*
- UX-53 (EXPERIENCE.md line 168) makes an exception to GDD:473, "a pause freezes a hold without cancelling it".
- UX-55 (line 106) adds a press as a second way to read why, where GDD:429 says "pointing at it … says why".
- Neither is in the table at lines 426 to 436, nor in DW-59.

*Fix:* add UX-53 (Controls and Input) and UX-55 (Mechanics 10) as rows, and to DW-59's list.

**L6 — Focus loss in planning and at dawn extends the architecture without routing.** EXPERIENCE.md line 166 says "Planning and dawn open the pause screen too". The architecture says "Losing focus pauses the lesson and the night" (game-architecture.md:880), and puts the pause overlay "on the night screen (and on the lesson screen)" (:407). The decision log lists this rule under "Derived" (line 203), but no DW item carries it to the architecture. *Fix:* add it to DW-59's architecture part, or to a new DW item for AD-51 and AD-67.

**L7 — `span-end` has no Component Patterns row.** DESIGN.md line 310 says "Behaviour for each is in EXPERIENCE.md, Component Patterns, under the same name". `span-end` (line 323) has no row there; the other 19 components match. *Fix:* add a row: "Not interactive; set once per screen; turned to read upward."

**L8 — The credits page count would be set in capitals.** DESIGN.md says the count is in `{typography.label}` (lines 170 and 329), and capitals are for `title` and `label` (line 273); `make_label()` sets `uppercase` for the label style. The result is "1 OF 3", where EXPERIENCE.md line 116 and the decision log (UX-61, line 170) give 'a plain "1 of 3"'. *Fix:* set the count in `body`, or accept capitals and change the quoted text.

**L9 — The wound's darkened side is drawn over the night view, against two blanket rules.** UX-52 describes it as "an edge gradient … always drawn under the caption" (EXPERIENCE.md line 157), and DESIGN.md line 302 stacks it over the scene. Two lines contradict that:
- DESIGN.md line 358: "Don't put anything over the night view except the caption line and, if switched on, the centre dot."
- EXPERIENCE.md line 210: "Nothing else is ever drawn over the night view."

*Fix:* name the wound gradient as the one view effect in both lines.

**L10 — "In light" for the tune is wrong in Everywhere mode.** EXPERIENCE.md line 239 says "The tune … shows only as its rail's ropes swaying in time, in light; nothing else shows it (UX-58)". The cue-mode table (line 216) has swaying ropes glowing in the dark in Everywhere. *Fix:* "in light (and glowing in the dark with Cues everywhere)".

**L11 — "Where the mocks differ" leaves out the old mock's span colours.** `mockups/key-screens.html` uses `#55534f` for planks and `#8d8982` for rails, the values before option C. DESIGN.md line 346 lists its scale, `muted` labels, `dim`, the two-line tray and the 36% ledger, but not these. *Fix:* add "planks #55534f and rails #8d8982 (now #8d8982 and #ddd6c8)".

**L12 — Code comments and one epic line still state the old DESIGN.md values, and DW-58 does not list them.**
- `game/watch/screens/watch_theme.gd` makes claims about DESIGN.md that are now false: "DESIGN.md's typography.number is 48 px", "DESIGN.md's typography.label is 28 px", "DESIGN.md's `plank` is #55534f", "DESIGN.md has them in `dim`", MUTED described as "small labels", and in `canvas_px()` "(48 -> 32, 28 -> 19, 40 -> 27, ...)". The header says "Whether DESIGN.md's whole type scale … follow[s] is for the UX update (DW-54)".
- epics.md:427 (story 1.7) still reads "32 px and 19 px on the 1280×720 canvas".

An agent reading the theme before story 5.1 is misled. *Fix:* add "the theme's comments" to DW-58's list of changes. The epics line is history of a story that is done, so leave it or footnote it.

**L13 — The ledger's measured room depends on an inner padding the spine never states.** The 473 px room is 42% of 1,280 (537.6) minus the 32 px safe margin minus **32 px** inside the hairline. The other scales follow the same pattern: A's 401 is 36% less 32 less 27, and C's 516 is 46% less 32 less 40. That inside gap is `spacing.4`, which is defined (line 88) and referenced nowhere. DESIGN.md line 289 gives no gap between the hairline and the text. *Fix:* "the text stands `{spacing.4}` inside the hairline rule".

**L14 — Two-choice screens are filed under "one centred column, entries stacked".** DESIGN.md line 281 groups "the two-choice screens" with menus. Line 333 sets the two words side by side, `{spacing.5}` apart. The update edited line 281 (it removed settings) and left this as it was. *Fix:* remove the two-choice screens from line 281, or say "one centred column; the two words of a two-choice sit side by side on one row of it".

**L15 — The why-line's two clearing rules clash.** EXPERIENCE.md line 107 shows the why-line "while the pointer is on an unavailable tool". In the same row, "It stays until the next input or pointer move". Read together, the slightest pointer movement while still over the tool would clear it. *Fix:* "a refusal's why-line stays until the next input or pointer move; a hover's lasts while the pointer stays on the tool".

## Counts

High 2 · Medium 9 · Low 15.
