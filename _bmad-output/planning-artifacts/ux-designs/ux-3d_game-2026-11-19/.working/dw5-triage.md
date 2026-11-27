# DW-5 triage: the 50 UX review findings that are not done, checked against what came after

Run on 2026-11-27, read-only. Sources: the GDD (`gdd.md`, draft 0.7, and its decision log up to GD-70); `game-architecture.md` (AD-1 to AD-70); `epics.md` (draft 0.8); `project-context.md`; stories 1.1 to 1.7; `deferred-work.md` (DW-1 to DW-57); the epic 1 retrospective; the code under `game/watch/`.

Paths are short forms:

- `EXP` = `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`
- `DES` = the same folder's `DESIGN.md`
- `UXLOG` = the same folder's `.decision-log.md`
- `VR` = the same folder's `validation-report.md`
- `GDD` = `_bmad-output/planning-artifacts/gdds/gdd-3d_game-2026-11-19/gdd.md`
- `GDLOG` = the same folder's `decision-log.md`
- `EPICS` = the same folder's `epics.md`
- `ARCH` = `_bmad-output/game-architecture.md`
- `PC` = `_bmad-output/project-context.md`
- `DW` = `_bmad-output/implementation-artifacts/deferred-work.md`
- `S1.n` = `_bmad-output/implementation-artifacts/1-n-*.md`
- `READY` = `_bmad-output/planning-artifacts/implementation-readiness-report-2026-11-20.md`

**Scope.** 30 findings are "Not addressed". The second list has 20, not 15: 15 are "Partly addressed", M1 and M2 are "Accepted gap", H2 and M11 are "Decided" with leftovers named in their status line, and R4.2 is "Fixed" as an [ASSUMPTION]. All 50 are below.

**Statuses in VR that are already out of date in the spines themselves.** The editorial pass of 2026-11-20 (UXLOG:102) changed text that VR's statuses still describe as open:

- **R3.6:** EXP:105 already ties rig-mark to "the undo rule of span-section".
- **R3.1:** EXP:117 already says "on the page the label sits above its value".
- **R2.2:** DES:155 already gives setting-row `label-color-chosen`.

**Things found here that no finding names:**

1. **Forced view changes are cuts.** The built game cuts the view at the catch, at the end of the climb, and at the start and end of a gap crossing. At the catch the view is also turned to face the town (S1.5:372 decision 7; S1.6:50 D2; `game/watch/night/warden.gd`:10, :21-23, :55-73). This conflicts with three statements:
   - EXP:273, "Full-view changes are slow fades only", which was rewritten to answer forced camera moves (VR:254-257);
   - GDD:740, the same sentence;
   - ARCH:97, where the limits "bind every effect and every view".

   See M18.
2. **The UX documents' `sources` omit the architecture.** Both spines cite AD-69, but neither lists `game-architecture.md` (EXP:7-10, DES:8-11). See R7.4.
3. **DW-39 contradicts EXP:162.** Changing Holds on the pause screen cancels a frozen hold, while EXP:162 says "Pause freezes a hold and does not cancel it". DW:378-385 asks for this to be confirmed with Sonlm and written into EXP. See R4.7.
4. **Both `.working/` mocks are byte-identical to `mockups/`**, `key-screens.html` as well as `directions-1.html` (checked with `cmp`). See R5.3.
5. **DW-52 and DW-56 are also owned by this update.** DW-52 lists the read-out marks DES does not have (DW:507-514); DW-56 is the label gap against the rail line (DW:549-556).

Bins: **settled-elsewhere**, **housekeeping**, **decision** and **defer**, as defined in the brief. **[type-scale]** marks findings whose answer depends on DES's sizes or colours (DW-54).

---

## Part A: the 30 "Not addressed"

### R2.2: the `components` frontmatter is thinner than the Components prose (medium)

1. **Settled since? Partly, in the spine itself.** DES:152-157 setting-row now has `label-color-chosen: '{colors.warm}'` (DES:155), so "setting-row disagrees with itself" is fixed. Still missing from the frontmatter:
   - tool-tray's "In hand" group label in `muted` and its counts in `number` (prose DES:260; frontmatter DES:97-101);
   - span-section's stripped rail, section number and fallen outline (prose DES:264; frontmatter DES:114-119);
   - rig-mark's tag colour (DES:265 against DES:120-122);
   - key-card's group label colour (DES:270 against DES:143-147);
   - two-choice's `spacing.5` gap and its `body` question (DES:273 against DES:158-161);
   - ledger-page's italic epitaph and closing-line style (DES:268 against DES:130-136);
   - centre-dot's 60 % (DES:274 against DES:162-164).

   Story 1.7 also built marks that have no token: the ends' words FAR PIER and TOWN (S1.7:62 D4), the number kept on a fallen section (S1.7:60 D2), and the rail joints (DW:513 item 3).
2. **Still open:** the frontmatter is not the full set. DW-52's marks have no key.
3. **Bin: housekeeping.** Add the keys named above, plus DW-52's (ends label, fallen-outline colour, section-number style). Write them after DW-54's sizes and colours are chosen, so they are written once.
4. **[type-scale].**

### R3.5: surfaces carry elements that no component covers (medium)

1. **Settled since? No.** Credits: EPICS:588 says "Credits opens a page that lists the asset licences from the credits files kept since epic 2", and epic 8 story 6 adds the AI-use disclosure (EPICS:712). DW-51 adds the typeface's licence to the credits (DW:504). The title wordmark is the `title` token (DES:215), but no component names it. The title today is bare (`game/watch/screens/title_screen.gd`:1-25). Not found: a component for the swap offer, the note line or the credits page.
2. **Still open:** no credits-page or note-line component, and the swap and cues offers have no component.
3. **Bin: housekeeping, with one small decision.**
   - The swap offer and the cues offer are menu-items. This follows from EXP:68 and EXP:132, which call them offers that continue. "I can't hear it" is not one of them: it is the two-choice's third answer (EXP:113).
   - The note line ("Best with headphones.", the line under Visual cues) is why-line's style (`body`, `muted`).
   - Credits is a journal-like page: a single centred column, as for the journal (DES:239).
   - The one real choice: does Credits scroll, or turn in pages? It is long text (licences, the OFL, the AI disclosure).
4. **[type-scale]**, because the note line is `muted` (DW-54 questions whether `muted` is too dim for text).

### R4.3: the crossing input lock adds to the GDD and has no trigger (medium)

1. **Settled since? Yes, by story 1.6.**
   - **Trigger.** S1.6:49 D1: "the crossing begins when the move wish has pushed straight into it at the stop for 0.5 s (30 ticks) in a row ... (within 45° of straight in)". Chosen by Sonlm (S1.6:347). The constant is `game/watch/sim/warden_constants.gd`:34 `PUSH_TO_CROSS_S: float = 0.5`, "a feel size" (S1.6:185).
   - **The lock.** S1.6:23 AC1 and S1.6:27 AC5: "no input but look until the edging ends (the move wish is ignored; every press, Tab too, is ignored with no event)".
   - **Holds.** S1.6:28 AC6: a running hold is cancelled and the forearm lowered.
   - **Chaining.** S1.6:34 AC9: a run of open and fallen sections is crossed "with no input between them".
   - **No abandoning.** S1.6:59: the warden turns back on their own only if the way on falls away.
   - **Second trigger.** GD-68 (GDLOG:463; GDD:294): the last plank going underfoot starts an edging.
   - Summed up in PC:72.
   - Not found in GDD: "no input but look". The GDD gives only the times (GDD:294-295) and GD-70, no jump (GDD:445).
2. **Still open:**
   - EXP:147 names only "crossing a gap". It leaves out edging round an open section (4 s), which has the same lock, and gives no trigger.
   - No GDD impacts row.
   - Knockdown (epic 4) is not built yet.
3. **Bin: settled-elsewhere.** Rewrite the EXP:147 row as "Knocked down, hanging, edging round an open section, crossing a gap". Add: a move begins after about 0.5 s of pushing straight into the open section or gap at its edge (story 1.6 D1), or at once when the last plank underfoot goes (GD-68). Until it ends only look works: presses and Tab are ignored, a running hold is cancelled, the forearm is lowered. A move cannot be abandoned. Add a GDD-impacts row saying the lock is the UX's and story 1.6's, not yet the GDD's.

### M8: body text at 720p is thin, and there is no way to enlarge it (medium)

1. **Settled since? No.**
   - Not in the settings lists (EXP:280-283; GDD:613; EPICS:591).
   - DW-54 reopens the whole type scale (DW:533: "whether the whole type scale grows by the same step").
   - Story 1.7's planning read-out already uses 72 px numbers and 40 px labels (`game/watch/screens/watch_theme.gd`:25-33).
2. **Still open:** whether text can be made larger at all beyond the base scale. `body` (32 px, 21 px at 720p; DES:220) carries the journal, why-line, key card and settings labels.
3. **Bin: decision.** Purpose: UX-34's "type ... with floors" so text "holds at 720p" (UXLOG:50), and UX-32's condition that the type be made heavier (UXLOG:48). Options:
   - (a) settle it only by raising the base scale in DW-54, with no setting;
   - (b) raise the base scale and add "Text size: normal / large" under Display. A larger size must be rechecked against the two-line tray (DES:237: about 2,700 px of entries on a 1,824 px line at the floor) and the ledger's 36 % column (DES:238);
   - (c) no change.

   The reviewer's ×1.25 is a suggestion. If (b), it is a new setting: a GDD impacts row and an EPICS story-5.8 line.
4. **[type-scale].**

### M10: tallies must be countable, and nothing says how big they are (medium)

1. **Settled since? Partly, by story 1.4 D2.**
   - S1.4:47 D2 and S1.4:345: "two rows on the forearm, planks above behind an inked bar, ropes below behind an inked ring; strokes in fives; one ink".
   - Built in `game/watch/night/hands.gd`:1-12 ("a row wraps after 5 groups"; "Unshaded (seen with no lantern lit)"; "Every size here is a gray-box size, not a rule").
   - The reviewer's "separate rows with a drawn sign at the head of each" is done.
   - Not done: a minimum on-screen size (share of view height, stroke width) and setting every second bundle apart.
2. **Still open:** DES:279 still says only "tally strokes in fives". The rows and signs are not in DES or EXP.
3. **Bin: settled-elsewhere** for the rows and signs: write story 1.4 D2 into DES:279. **Defer** the minimum size to epic 7 story 4, the warden's arms and forearm (EPICS:676; GDD:797), with the gate 2 newcomers as the check (GDD:926 assumption 9).

### M13: aim and click targets have no stated tolerance (medium)

1. **Settled since? Partly.**
   - At night, rails have a grab box: `game/watch/sim/span_geometry.gd`:30-33 `RAIL_GRAB_SIZE: float = 0.3`, "Wider than the 5 cm rope so a person can hold the view on it for a 3 s strip" (S1.4:46 D1).
   - Decks are hit by their whole box (`game/watch/sim/look_rules.gd`:20-26).
   - The look is a view line against boxes from `SpanGeometry` (ARCH:714).
   - A temporary aim aid exists until the hands arrive (DW-41, DW:398-405).
   - The hold-control mouse half was done earlier (EXP:103).
   - Not found: tolerances for pins, holding ropes, hooks, poles, the flask, the bell rope and the carved name. These are epic 4 and 5 targets that do not exist yet. Also not found: dwell build-up across wobble (the name is epic 5 story 3; EPICS:604) and planning click zones (story 1.7's read-out has no clicks; planning input is story 5.1, EPICS:602).
2. **Still open:** EXP states no tolerance anywhere, not even the rail grab box that exists.
3. **Bin: defer.**
   - Write the pattern now as settled-elsewhere: every night target is hit by a grab box larger than what is drawn, sized in play (story 1.4 D1).
   - Each target's size goes to the story that adds it: epic 4 stories 1 and 7 for pins, ropes, hooks and poles (EPICS:558, :564); story 5.3 for the name's dwell, where "does a wobble reset the 1 s?" is a small decision; story 5.1 for planning's rail click zone.

### M15: E and F change meaning with nothing to say which meaning is live (medium)

1. **Settled since? F yes; E no.**
   - **F:** GDD:450 "Open or close a shutter: that of a hung lantern the warden is looking at within 2 m, otherwise that of the lantern in hand". Also GD-55 item 6 (GDLOG:358) and EPICS:548.
   - **E's ready pose: not settled.** The one hint is GDD:797's asset list: the hands' moves include "a ready pose for each action". Against that:
     - EXP:176 gives the ready pose to "What a click will do".
     - EXP:177 says what E, F, 1, 2 and R do is "otherwise learned from the key card; the ready pose at a build spot".
     - GDD:737 says "The hands show the action a click will perform".

     EXP:160 says look decides "for both mouse hands and for E". EPICS:538 and :558 (epic 4 story 1) build the ready poses. Hang, take and swap are one press (GDD:355).
   - Not found: an enumerated pose list.
2. **Still open:**
   - F's rule is not in EXP; Input Schemes has no F row.
   - Whether E shows which meaning is live, in the case where a wrong press removes a light ("take the lantern down" in the same view as "re-lay"). Which target wins is decided by the box the view line hits first (`look_rules.gd`:1-5), but the pole and lantern boxes are epic 4's.
3. **Bin: settled-elsewhere** for F: add an F row citing GDD:450 and GD-55 item 6. **Decision** for E, or defer it to epic 4 story 1 with the question named. Purpose: the no-HUD rule, under which "the hands are the interface, so the action picker must explain itself through poses alone" (ARCH:111), and GDD assumption 9, "The hands alone tell a newcomer what an action will do" (GDD:926). Options:
   - (a) E gets ready poses like the mouse hands (hang, take, swap, re-lay, refill);
   - (b) only E actions that remove something (take a lantern) get one;
   - (c) none, as EXP:177 reads now, with the key card carrying it.

### M19: the wound's darkening has no extent, and it can cover the caption (medium)

1. **Settled since? Partly.** GD-66 (GDLOG:419; GDD:416): "The side is the warden's own and turns with the head", for sound. GDD:255 and GDD:415 say only "the view darkens on that side". EPICS:550 and :567 (epic 4 story 10) build it. ARCH puts "the wound's dark side" in the ALWAYS cue class (ARCH:698). DW-21 owns the drawing technique for screen effects (DW:200-207). Not found: extent, depth, fade time, or drawing order against the caption.
2. **Still open:** how wide and how dark, and whether the caption is drawn above it.
3. **Bin: decision**, with one housekeeping part.
   - **Housekeeping:** the caption is drawn above the wound's darkening. This follows from "Captions always on" (EXP:263) and UX-1.
   - **Decision.** Purpose: the wound is the cost of being caught (GD-27, GDLOG:142: "the ear on that side rings and goes dull"). The darkened side is its visual cue for the deaf ear (GDD:255; finalize fix 15, GDLOG:221). Options:
     - (a) an edge gradient on the wounded side only, capped in width and darkness (the reviewer's outer third and 60 % are suggestions);
     - (b) a whole-half darkening;
     - (c) leave the numbers to epic 4 story 10 with a cap stated now.

     Whether it follows the head like the sound (GD-66) is part of the same choice.

### R1.4: no flow walks the returning player or Leave the bridge (low)

1. **Settled since? Yes, as rules.** The paths are defined:
   - GD-52 (GDLOG:346): every night is a new run; Another night is a fresh span.
   - GD-58 (GDLOG:394; GDD:177): hints survive a return to the title.
   - The skip rule (EXP:53, :69; GDD:154).
   - Leave from Pause asks first (EXP:46).
2. **Still open:** nothing required. The reviewer proposed no fix.
3. **Bin: settled-elsewhere.** No change needed. If anything, a one-line note under Key Flows saying the returning-player and leave paths are fixed by the IA table and GD-52/GD-58.

### R2.5: contrast is stated for `world` only (low)

1. **Settled since? No.** DES:203 states ratios on `world` only. The dawn view is not built (epic 5 story 6, EPICS:607). Computed here, on `dawn-sky` #3b3a3d:

   | Colour | Ratio |
   |---|---|
   | `dim` #5f5d59 | 1.72:1 |
   | `muted` #8d8982 (also option C's plank colour) | 3.25:1 |
   | `plank` #55534f | 1.47:1 |
   | `ink-bright` #ddd6c8 (option C's rail colour) | 7.82:1 |

2. **Still open:** where the span and windows sit in the dawn gradient, or the ratios there.
3. **Bin: decision**, taken together with L1 and DW-54. Purpose: the dawn view shows what the night cost beside the ledger (UX-14, UXLOG:29). The windows "behind the warden are the visible score" (GD-12, GDLOG:126). The ledger repeats the counts in words (EXP:119-120), so nothing is lost if a window fades. Options:
   - (a) keep everything that carries a count in the `world` end of the gradient (DES:238, DES:201);
   - (b) pick colours that clear 3:1 on `dawn-sky`;
   - (c) accept it, since the ledger carries the counts.
4. **[type-scale].**

### R2.7: lining tabular figures depend on OpenType features in the bundled font (low)

1. **Settled since? Yes, in code.**
   - `game/watch/screens/watch_theme.gd`:127-143 sets `lnum` on both styles and `tnum` on `number` through a `FontVariation` ("Cormorant's own are old-style (its 1 reads as a small capital I)").
   - `game/tests/watch/test_watch_theme.gd`:139-141 and :153-164 prove it: "all ten digits are the same width in the number style ... which the file's own figures are not (the features are applied)".
   - Story 1.7 settled lining figures for `label` too (S1.7:67). This overlaps DW-52 item 4 (DW:513).
2. **Still open:** DES:229 does not say how, and does not say the label style is lining too.
3. **Bin: settled-elsewhere.** Add to DES Typography, Figures: the bundled font's figures are old-style by default. The theme turns on `lnum` for every style and `tnum` for `number` (story 1.7, `watch_theme.gd`), and a test checks that the features take effect.

### R2.8: token housekeeping for the Theme builder (low)

1. **Settled since? Changed by option C, not settled.** `rail` and `muted` still share #8d8982 in DES:22 and DES:18. In the build, option C made the planning plank #8d8982 (`muted`'s value) and the rail #ddd6c8 (`ink-bright`'s value) (`watch_theme.gd`:53-58). DW-54 says: "Planks and dashed lines now share a colour, and `plank` and `muted` share a value; the UX update should name them" (DW:533). `spacing.4` is still unreferenced, and `dawn-sky` is used by no component.
2. **Still open:** the role tokens no longer match the build.
3. **Bin: housekeeping**, done as part of DW-54. Decide whether `plank` and `rail` stay roles that alias other values, or are removed. Write the aliases explicitly.
4. **[type-scale].**

### R3.6: rig-mark and span-section give different undo rules (low)

1. **Settled since? Yes, in the spine.** EXP:105: "Right click on its section, when placing the rig was that section's last choice, removes it and returns its cost (the undo rule of span-section)". VR's status is stale. Related, and not in EXP: the GDD and architecture add that "an undo that needs a part no longer in hand ... is refused and says why" (GDD:428; GD-55 item 7, GDLOG:359; ARCH:746; EPICS:579).
2. **Still open:** nothing in the finding. The refused undo has no State Patterns row; EXP:140 has only "Nothing left to undo".
3. **Bin: housekeeping.** Add a Planning row: "Undo needs a spent part: refused; the why-line says which part (GDD Mechanics 10, GD-55)."

### R3.7: why-line's trigger is narrower than the refusals that promise one (low)

1. **Settled since? No.** EXP:102's trigger is unchanged. The GDD adds two more refusals that say why:
   - a refused undo (GDD:428);
   - "Ring the bell ... cannot be rung until both placed lanterns are hung, and it says why" (GDD:432).

   The beam-rail case comes from GDD finalize fix 7, "a rail ... holding a swing-beam cannot be stripped" (GDLOG:213), and EPICS:541. Section 6's two refusals are already promised (EXP:104).
2. **Still open:** the trigger, and the beam-rail and undo cases.
3. **Bin: housekeeping.** Widen the trigger to "any refused click or press in planning". List the cases: unavailable tool, a section the tool cannot go on, section 6 at 4 planks, section 6 and rigs, a rail holding a beam, an undo needing a spent part, the bell with a lantern unplaced. The wording itself is text for story 5.10 (EPICS:611).

### R3.8: setting-row covers values only (low)

1. **Settled since? No.**
   - Check left and right is an action (EXP:52; ARCH has no step or range for any slider).
   - Not found: slider steps or ranges for Volume, Mouse sensitivity, Brightness and Field of view, or the Resolution list.
   - Related: AD-69, "The Resolution setting changes the window, never the canvas" (ARCH:1099). DW-53 (DW:516-523) shows text is sharp only in 720p, 1080p, 1440p and 4K windows.
2. **Still open:** all three.
3. **Bin: decision**, with a housekeeping part.
   - **Housekeeping:** Check left and right is a menu-item inside Settings, opening the check and returning to Settings (follows from EXP:52).
   - **Decision**, owned by story 5.8 (EPICS:609) if not settled now. Purpose: these are the "cheap basics" of hobby stakes (UXLOG:15), and Field of view and Brightness were added as comfort and visibility settings (UX-39, UXLOG:88; EXP:266, :268). The choices:
     - slider ranges and steps;
     - the Resolution list: the monitor's own sizes, or only the even multiples of 1280×720 that DW-53 found sharp;
     - the Field of view range. It is a comfort setting (EXP:266).

### R3.9: two-choice has no Esc rule, and Skip the lesson? has no wording (low)

1. **Settled since? No.**
   - The mermaid still labels SK's edges "No" and "Yes" (EXP:33-34). The table calls them "Two menu-items: skip the lesson, or take it" (EXP:53).
   - The menu keys exist: `watch_menu_back` is Esc (`game/watch/core/input_actions.gd`:44; AD-70, ARCH:1100).
   - The skip question's wording: not found in `game/watch/content/ui_text.gd`, which has no title entries yet (`ui_text.gd`:1-3).
2. **Still open:** Esc on two-choice screens, the skip entries' words, and the diagram labels.
3. **Bin: housekeeping**, with a small wording decision.
   - Esc on a two-choice screen goes back one step, by Input Schemes' "in a menu, back one step" (EXP:228): Headphones? goes back to Title; Left or right? goes back to Headphones? or to Settings.
   - Relabel the diagram's edges with the entry words.
   - The words themselves (for example "Skip the lesson" and "Take the lesson") are a small choice of text under UX-31's voice rule (EXP:80).

### R4.6: no rule for the window losing focus (low)

1. **Settled since? Yes, by the architecture.**
   - ARCH:880: "**Losing focus pauses the lesson and the night**, as the ear test does. The pause is logged with its cause".
   - ARCH:407 (AD-67): "Losing window focus pauses too (AD-51)".
   - PC:156.
   - Built in epic 5 (ARCH:996, "the pause overlay and focus loss"). Not built yet: no focus handling under `game/watch/` (grep found none).
   - Two loose ends are filed: DW-33, the click that refocuses reaches the hands (DW:318-326), and DW-36, a release lost on focus loss (DW:351-358). Both are owned by "epic 5, the focus-loss pause".
   - READY:530 A4: the epic 2 early listen puts the lesson in front of newcomers with no pause at all.
2. **Still open:**
   - EXP has no row.
   - Planning and dawn on focus loss are unstated. They have no sim and are untimed, except that planning's 1 s holds and the ledger write-in are frozen by the overlay pause (ARCH:877).
   - The epic 2 gap is A4.
3. **Bin: settled-elsewhere.** Add a Pause row: "Window loses focus: the lesson and the night pause, as with Esc (AD-51, AD-67). On return the pause screen is showing; a click to refocus does not reach the hands (DW-33)." State planning and dawn either way; pausing them too is the simplest reading of EXP:46. A4 stays a schedule question for DW-20.

### R4.8: "Nothing is deeper than two steps from play" is not true (low)

1. **Settled since? No.** EXP:72 and DES:249 still say it. Counter-examples: Pause → Settings → Check left and right is three; Pause → Leave the bridge → the leave question (EXP:46) is two, the question being the second.
2. **Still open:** the sentence.
3. **Bin: housekeeping.** Change both to "Nothing is deeper than three steps from play (Pause → Settings → Check left and right)", or drop the claim.

### R5.2: known differences from the mock are only partly listed (low)

1. **Settled since? No.** DES:231 lists only the light weight. Since then the mocks are further from the build: option C's sizes and colours (`watch_theme.gd`:25-58), and story 1.7's marks (DW-52).
2. **Still open:** no "where the mock differs" list.
3. **Bin: housekeeping.** After DW-54, either regenerate `mockups/key-screens.html` to the new tokens (UXLOG:101 did this once) or add the list.
4. **[type-scale]**, because the mock is drawn to the tokens that are changing.

### R5.3: `.working/directions-1.html` is a byte-identical copy (low)

1. **Settled since? No.** `cmp` today: `.working/directions-1.html` and `mockups/directions-1.html` are identical, and so are `.working/key-screens.html` and `mockups/key-screens.html`. UX-32 still names `.working/directions-1.html` (UXLOG:48). UXLOG:79 records the promotion.
2. **Still open:** two stale copies and one stale path.
3. **Bin: housekeeping.** Remove both `.working/` HTML copies, or add a line to the log that `mockups/` is canonical. Leave UX-32's text as history.

### R6.1: the same rule is stated in three or four places (low)

1. **Settled since? No.** The repeats remain, for example hold-to-commit in EXP:103, :166 and :224, and the lost night in EXP:57, :151 and :250.
2. **Still open:** one home per rule.
3. **Bin: housekeeping**, an optional editorial pass. Worth doing for the rules this update edits (caption, holds, lost night, undo), so new wording lands in one place.

### R6.2: Game Feel & Juice restates several GDD outcomes (low)

1. **Settled since? No.** Unchanged (EXP:242, :246, :247). The reviewer called the trim optional.
2. **Still open:** nothing required.
3. **Bin: housekeeping**, optional. Leaving it is fine.

### R7.4: `epics.md` is cited but not in `sources` (low)

1. **Settled since? No.** EXP:7-10 and DES:8-11 list neither `epics.md` nor `game-architecture.md`. Both spines cite AD-69 (EXP:20; DES:174), and EXP cites "GDD epic 5" and "epic 7" (EXP:86, :394; DES:277).
2. **Still open:** both paths.
3. **Bin: housekeeping.** Add `../../gdds/gdd-3d_game-2026-11-19/epics.md` and `../../../game-architecture.md` to both `sources`.

### R8.1: there is no Inspiration section (low)

1. **Settled since? No.** The material exists:
   - UX-32's three declined directions: "A chalk on slate; B ledger paper; D engraved plate" (UXLOG:48);
   - GDD Inspiration and References (GDD:88-97): *Tyrant of the Tower Defense Game*, *Thronefall*, *Dome Keeper*, *Orcs Must Die!*, *Spiritfarer*, *Return of the Obra Dinn*.
2. **Still open:** the section.
3. **Bin: housekeeping.** Add four or five lines to EXP: the three declined directions with UX-32's reason, plus one line pointing at GDD:88-97.

### L6: the two silences have no visual and no stated length (low)

1. **Settled since? Partly.**
   - Before wave 6: GDD:553, "In the last 10 s before the sixth toll the wind and the bridge fall silent", and GDD:626. The reviewer asked to leave this one as it is.
   - Dawn's order: GD-53 (GDLOG:347; GDD:180; EXP:153).
   - Dawn silence's length: **not found** in GDD, ARCH or EPICS (EPICS:586 says "the silence, the ally's one line, then the ledger").
   - The glows: at dawn the dead "sink back below" (GDD:169), and "A pointer cue lasts for the whole of its warning" (EXP:209). So whether cues end with the cries follows, but is not written.
2. **Still open:** the dawn silence's length, and the cue glows at dawn.
3. **Bin: decision** (a starting value), with a housekeeping part.
   - **Decision:** the dawn silence's length. Purpose: "an earned silence" (GDD:180; finalize fix 17 "Dawn opens with an earned silence", GDLOG:223), the brief's dawn feeling (GDD:190). The reviewer's 3 to 4 s is a suggestion. If not set now, it is a tuning value for story 5.6 (EPICS:607).
   - **Housekeeping:** "every cue glow fades with the cries".

### L1: graphic states below 3:1 (low)

1. **Settled since? Partly, for planning.** Story 1.7 option C (DW:533; `watch_theme.gd`:50-58): dashed lines, a stripped rail and a fallen outline are now #8d8982 (`muted`'s value, 5.79:1 on `world`), planks #8d8982, standing rails #ddd6c8. Rail line 0.2 m, dashed line 0.1 m (DW:533). Not changed: out windows are still `dim` in DES:167 and DES:275, and the dawn view (`dawn-sky` gradient) is not built.
2. **Still open:** DES still says `dim` for stripped rails (DES:264) and out windows, and `plank` #55534f (2.62:1 on `world`).
3. **Bin: decision**, inside DW-54. Write option C into DES. Choose the out window's colour and whether dawn keeps anything that carries a count on `world`. Purpose: the windows are the visible score and a loss condition (GD-12, GDLOG:126). A stripped rail decides where Grapplers land (GD-20, GDLOG:134), so in planning it is the plan itself. The reviewer's "muted at 2 px" is a suggestion, and option C already went brighter for planks and rails.
4. **[type-scale].**

### L8: the name "in a written hand" (low)

1. **Settled since? No.** DES:279 says "the name in a written hand". GDD:797 lists "the six names, carved in timber and in a written hand for the forearm" under Models. The art pass owns it (DES:277; EPICS:676, epic 7 story 4).
2. **Still open:** upright or looped.
3. **Bin: defer** to epic 7 story 4. Optionally write the constraint "a clear upright hand, not a looped script" into DES:279 now, as a brief for that story. Writing it is a small decision.

### L3: the lost-night hint can be skipped by a stray key (low)

1. **Settled since? No.** EXP:151: "one action continues (UX-12). Planning is ready within 3 s of that action (GDD)". UX-12 measures the 3 s from the action (EXP:364; GDLOG:298, the P18 row), so a guard costs the target nothing. The ledger has the same pattern: "Any key or click completes the page at once" (EXP:108). Not found: an input guard.
2. **Still open:** whether input is ignored while the hint writes in.
3. **Bin: decision.** Purpose: the lost-night page is where the loss is explained. GD-12, "A lost night replays from dusk with a hint added to the journal" (GDLOG:126), and UX-12, "No 'game over' title" (UXLOG:27). Options:
   - (a) ignore input until the line has written in, then Enter, Space or a click continues;
   - (b) ignore input for a short fixed time, then any key;
   - (c) as now.

   The hint stays in the Journal either way, so the cost of a skip is small.

### L4: the left/right check should not open with an answer already chosen (low)

1. **Settled since? No.**
   - EXP:99 applies "The first entry is chosen when a menu opens" to menu-items. two-choice (EXP:113) says nothing about how it opens.
   - UX-20 answers by "A or D, arrow keys, or a click" (UXLOG:35; EXP:229); Enter is not listed. AD-70 gives two-choice the left and right menu actions (ARCH:1100).
   - Purpose of the check: "a left/right check ... to catch swapped or mono output" (GDLOG:228). A pre-chosen word plus Enter would let a guess through.
   - The catch: the left/right check has a third answer, "I can't hear it" (EXP:113). If Enter and Space never answer, that answer has no keyboard path. AD-70 also gives two-choice the confirm action (`watch_menu_confirm`: Enter or Space; ARCH:1100; `input_actions.gd`:43).
2. **Still open:** the opening state, and how the third answer is reached by keys.
3. **Bin: decision.** Take it with R4.4 and H2: the same screen, needed before story 2.9. Options:
   - (a) open with nothing chosen. A/D or the arrows answer Left or Right at once. Down chooses "I can't hear it" and Enter confirms it; Enter does nothing while nothing is chosen;
   - (b) open with nothing chosen. A/D, the arrows and Down only move the choice, and Enter confirms;
   - (c) as menu-item: first entry chosen.

   (c) lets a guess pass on Enter. Headphones/Speakers can share the rule.

### L2: the centre dot is too small and faint to do its job (low)

1. **Settled since? No.** DES:162-164 and DES:274: 4 px at 60 % (about 3 px at 720p). The centre dot is a Settings item for epic 5 (EPICS:591). The debug aim aid draws its own dot until epic 4 story 1 and is not the setting (DW:404).
2. **Still open:** size and opacity.
3. **Bin: decision.** Purpose: motion comfort and precision (UX-5, UXLOG:20). A fixation point is needed most over lantern light. Options: (a) keep 4 px at 60 %; (b) larger, at full opacity, with an `abyss` ring (the reviewer's 6 px and 1 px ring are suggestions); (c) choose from rendered frames over lit wood, as with option C.
4. **[type-scale]** (size and colour token).

---

## Part B: the 20 "Partly addressed", "Accepted gap", or Decided/Fixed with leftovers

### R7.1: "GDD impacts" is incomplete (high; Partly addressed)

1. **Settled since? Mostly, in the GDD.** VR named four missing rows:
   - **The shaken hook:** in the GDD. GDD:475: "a second strike on a hook already shaken once is one such". Finalize fix 9: "each Grappler can be shaken loose once" (GDLOG:215).
   - **The hum's flame condition:** in the GDD. GDD:247: "only while the hum can be heard: that is, while no cry is sounding". GD-55 item 13 (GDLOG:365).
   - **How the left/right check is answered (UX-20):** in the architecture, not the GDD. GDD:149 describes the check but not its keys. The keys are AD-70 (ARCH:1100; `input_actions.gd`:41-45). READY:514 U4 noted the GDD does not list them.
   - **The crossing input lock:** not found in GDD. It is in S1.6:23 and :27 and PC:72. See R4.3.
2. **Still open:** EXP's GDD-impacts table (EXP:351-385) lacks these four rows. The lock and the check's keys are not in the GDD.
3. **Bin: settled-elsewhere.** Add rows citing GDD:475, GDD:247 / GD-55 item 13, and AD-70. For the lock, add a row and hand it to the next gds-gdd run. DW-47 (DW:458-465) is already owned by "the next gds-gdd update run", so the lock can ride with it.

### H2: the way into deaf play is hidden (high; Decided, UX-38, with leftovers)

1. **Settled since? No, for the two leftovers.**
   - **The check screen's plain line:** EXP:52 and GDD:149 give "one bell stroke, two choices ... 'I can't hear it' ... R rings the bell again". The two-choice question line is `body` (DES:273). Not found: any line telling the player that a sound was played.
   - **The lesson for a Cues-everywhere player:** EXP:134 and GDD:149 say "after three, the place shows its cue ... which the lesson holds back until then". No exception for a player who has just chosen Cues everywhere from "I can't hear it".
   - **Schedule:** the lesson is built in epic 2 story 9 (EPICS:484). Cues everywhere and the check's offer are wired in epic 5 (EPICS:463, :591).
2. **Still open:** both.
3. **Bin: decision.**
   - **(i) A line on the check screen** (for example "A bell rings on one side."). This is text, and small.
   - **(ii) In Cues everywhere, does the lesson show each cry's cue from the first playing?** Purpose: GD-8, "The warden turns to face each cry and the ally says whether that was right" (GDLOG:122); GD-4(b), "it takes practice, so a new player needs a listening lesson" (GDLOG:116). For a player who cannot hear, holding the cue back for three playings teaches nothing. Options: show the cue at once when Cues everywhere is on; keep the GDD's rule for everyone; or show it after one playing. Choose before DW-20 writes story 2.9, and it is also a GDD change.

### H3: the flame is the only direction-finder (high; Partly addressed)

1. **Settled since? No, but owned.**
   - DW-6, "Settle the flame as a direction-finder (carry height, minimum lean)", owner "epic 7 story 4, checked on the muted night in epic 8" (DW:58-65). Also in ARCH:1013 and EPICS:676.
   - The muted night is epic 8 story 14 (EPICS:720). GDD:927 assumption 10: "By sight the flame is the only direction-finder, and it shows the nearest cry only".
   - An empty lantern still gives nothing (GDD:359: "an empty one is dark").
2. **Still open:** carry height, minimum lean, the empty-lantern case, and the muted night.
3. **Bin: defer** to DW-6 (epic 7 story 4) and the muted night (epic 8 story 14). The empty lantern's ember (the reviewer's idea) is a decision that belongs with DW-6.

### R2.3: the effects that carry legibility are not quantified or tokenised (medium; Partly addressed)

1. **Settled since? No.**
   - DW-21, "Choose how the screen effects are drawn", owner "put to Sonlm as options before epic 5's stories are created" (DW:200-207). It names the glow, the halo, the write-in lines, the hold rule and the 15 % pause dim.
   - The halo has numbers (DES:248). Glow (DES:247: "about 0.7 of the text's height"), pause dim (DES:249: "about 15%") and hairlines (DES:253: "1 to 2 px") are still approximate.
   - Option C's line widths are in metres on the span, not hairlines (DW:533).
2. **Still open:** an `effects` block.
3. **Bin: defer** to DW-21. Add the `effects` block when the technique is chosen. Halo and glow sizes scale with text sizes.
4. **[type-scale].**

### R3.1: the ledger's content is not committed (medium; Partly addressed)

1. **Settled since? Yes, in the spine.** EXP:117: "The '·' separates label from value here; on the page the label sits above its value (DESIGN.md, ledger-page)". This matches DES:268. The seven lines and order are GD-53 (GDLOG:347; GDD:180-188; EXP:119-125). VR's status is stale.
2. **Still open:** nothing. The Voice and Tone example (EXP:85) and Linh's flow (EXP:312) quote lines inline, as speech.
3. **Bin: housekeeping**, nothing required. Optionally add "(on the page, label above value)" to the Voice row.

### R4.2: journal lifetime is undefined (medium; Fixed as an [ASSUMPTION])

1. **Settled since? Yes.**
   - GD-58 (GDLOG:394): "Hints survive a return to the title and end when the game is closed".
   - GDD:177: "including a return to the title, and are gone when the game is closed".
   - AD-26 (ARCH:229) and AD-21 (ARCH:224): one `ConfigFile` holds settings and the lesson-done flag.
   - The name is rolled every night (GD-52, GDLOG:346).
2. **Still open:** EXP:391 is still tagged [ASSUMPTION] and says "gone at the next launch". That is the same rule in other words. UXLOG:93 also keeps it as an assumption.
3. **Bin: settled-elsewhere.** Drop the tag. Reword: "Hints last while the game runs, through a return to the title, and are gone when it is closed (GD-58, AD-26). Only settings and the lesson-finished flag are kept on disk (AD-21)." The reviewer's four-row table is optional.

### M1: the hum, the tune and the bell are close to unreachable without hearing (medium; Accepted gap)

1. **Settled since? Partly.**
   - The hum lean's condition is in the GDD: GDD:247, "only while the hum can be heard: that is, while no cry is sounding". GD-55 item 13 (GDLOG:365).
   - The tune's cue: "Its rail's ropes sway in time with it" (GDD:248).
   - DW-22 notes "No story draws ... the tune's swaying ropes" (DW:215), owner gds-create-epics-and-stories before epic 5.
   - Not found: sway against shake numbers, a visible right-ring result, or a hum lean distinct from a cry lean.
   - The contradiction is still there. EXP:213 says "whether the bell would work 'now' is heard in the tune and not shown", while EXP:188 gives the tune a visual cue (the swaying ropes). UXLOG:59 has the same line.
2. **Still open:** the gap, as accepted (EXP:288), and the contradictory sentence.
3. **Bin: decision**, with a housekeeping part.
   - **Housekeeping:** reword EXP:213. The tune, and so "the bell would work now", is shown by its swaying ropes, in light. What is not shown is anything beyond that.
   - **Decision:** whether to close any part of the gap. Purpose: pillar 4, "Every victory has a name" (IN-3), GD-14 and GD-25 (GDLOG:128, :140), against the brief's "a visual cue for every sound" (IN-17, GDLOG:47). Options:
     - (a) keep it accepted, and judge on the muted night (epic 8 story 14);
     - (b) make sway and shake clearly different motions;
     - (c) give a right ring a visible result (the tune's ropes fall still);
     - (d) give the hum lean a different motion from a cry lean.

     (b) to (d) belong to epic 5 stories 3 to 5 (EPICS:604-606) and to DW-22.

### M2: a window going out has a sound but no cue in view (medium; Accepted gap)

1. **Settled since? No.** GDD:252: "A window going out | The window itself; a lone hatchling's crossing makes one flicker low". The windows are built in epic 3 story 6 (EPICS:523). The known gap is stated at EXP:288.
2. **Still open:** a cue in view.
3. **Bin: decision.** Purpose: the windows are one of the two losses (GD-12, GDLOG:126; GDD:170-174). UX-30's sound exists "because the windows are behind the warden". Options:
   - (a) keep the gap;
   - (b) a cue for everyone, such as the town's warm spill near section 6 dimming per window;
   - (c) a Cues-everywhere-only cue, such as one slow lean of the carried flame toward the town, which would be epic 8 (GD-50).

### M3: the toll cue is easy to miss or miscount; the flame means five things (medium; Partly addressed)

1. **Settled since? Partly.**
   - Strokes are 1.5 s apart, one dip per stroke, one tally per wave (GD-55 item 11, GDLOG:363).
   - A dip takes about 0.8 s, and the sputter stays on the flame (EXP:273; GDD:740).
   - The tally board is always lit: "the town gate's light ... section 6's cues and the tally board are always readable" (EXP:172; UX-29, UXLOG:44).
   - The cue classes are in ARCH:693-699.
2. **Still open:** no one table of what each flame motion means. The tally-board glow in Cues everywhere is moot, since the board is always in the gate's light. The real cost is that the board can be read only by walking to it.
3. **Bin: housekeeping.** Add one small table:

   | Motion | Meaning |
   |---|---|
   | Lean | The nearest cry's side, or the hum's section |
   | Dip, about 0.8 s, once per stroke | The toll (Cues everywhere only) |
   | Shrink and sputter, on the flame only | Oil running low |

   Cite GD-55 item 11. Note that the tally board needs no glow (UX-29).

### M9: captions and dusk prompts sit over the brightest part of the frame (medium; Partly addressed)

1. **Settled since? Partly.**
   - The halo has numbers (DES:248).
   - Caption backing is DW-13, owner "epic 8, with the accessibility extras, decided after the muted night" (DW:121-128; ARCH:1014).
   - The forearm against the caption band: not stated anywhere.
     - The forearm is a 3D plate at `game/watch/night/hands.gd`:16-24: `PLACE` (0, −0.13, −0.35), `SKIN_SIZE` 0.27 × 0.12, tilted −0.35 rad.
     - No camera `fov` is set under `game/watch/night/`, so Godot's default 75° applies.
     - A rough calculation from those numbers (not measured on a frame) puts the plate's lower edge near 85 % of view height. That is about where a 44 px caption's top would sit: the caption baseline is 112 px above the bottom at 1080p (DES:240).
2. **Still open:** caption backing, and the forearm against the caption.
3. **Bin: defer** caption backing to DW-13. **Housekeeping:** state that the forearm stays clear of the caption band, and add a frame check to epic 2 story 6, the caption (EPICS:481), when the caption first exists.
4. **[type-scale]**, because caption sizes and the halo scale with the type.

### M11: no brightness control; the cue glow has no minimum (medium; Decided, UX-39, with leftover)

1. **Settled since? Yes, as a starting value set by the facilitator.** GDD:270: "Starting value for the glow: it can be made out from 15 m, half the span, at default brightness. It is tuned on the muted night". GDLOG:374 records that "the glow readable from 15 m" was one of the starting values the facilitator set, to be tuned at gate 2. Brightness is in the settings (GDD:613; EPICS:591).
2. **Still open:** EXP does not carry the glow's starting value.
3. **Bin: settled-elsewhere.** Add the GDD:270 sentence under the cue-mode table (EXP:209) and cite it. The reviewer's 3:1 is a suggestion; the GDD's "made out from 15 m" stands.

### M12: a hold is fragile in ways the spec leaves open (medium; Partly addressed)

1. **Settled since? Three of four, as VR says. The grace is not.**
   - GDD:473: "Held actions are cancelled by moving more than 0.5 m".
   - `game/watch/sim/hand_constants.gd`:9-11 `HOLD_MOVE_LIMIT: float = 0.5`. `game/watch/sim/hold_rules.gd`:57-59 has no time grace.
   - The one grace that exists is Press once's 0.25 s after a completed hold (`hand_constants.gd`:12-16), which is a different case.
   - DW-40 is about hold lengths, not the cancel (DW:389-396). The retrospective's "tune at gate 2" covers DW-40 and DW-50 only (`epic-1-retro-2026-11-27.md`:76).
   - Not found: any owner for a movement grace.
2. **Still open:** a brush of W (0.14 s at 3.5 m/s) ends a 12 s build. Building holds arrive in epic 4 story 4 (EPICS:561).
3. **Bin: decision.** Purpose: "a hold cancels on moving" makes the warden commit to a place while time passes. DW-40's reason: "the time is the cost that makes stripping a choice while the dead arrive". Options:
   - (a) keep 0.5 m with no grace;
   - (b) add a short time a movement key must be held before it counts;
   - (c) raise the distance;
   - (d) defer to gate 2 tuning (story 6.5) with DW-40.

   (b) and (c) are GDD changes (GDD:473).

### M18: forced camera movement is unspecified (medium; Partly addressed)

1. **Settled since? Partly, and the build now conflicts with a sentence.**
   - The build uses **cuts**, not eased moves:
     - S1.5:372 decision 7: "The view at the catch: it cuts to face the edge caught (toward the town, level), once";
     - S1.6:50 D2: "cut down at the start and cut up onto the far deck";
     - `game/watch/night/warden.gd`:10 ("the one time the game turns it is the catch at a fall") and :21-23, :61-73 (`CUT_KINDS`: `WARDEN_CAUGHT`, `WARDEN_CLIMBED`, `CROSSING_STARTED`, `CROSSING_ENDED`);
     - PC:72.
   - Edging and walking blend.
   - **The cuts conflict with three statements:**
     - EXP:273, "Full-view changes are slow fades only: the wound's darkened side, the lost night's dark, the dawn". It was rewritten to answer this very finding, about forced camera moves (VR:254-257), and it names the dawn rise.
     - GDD:740, "full-view changes are slow fades only".
     - ARCH:97: the comfort limits "bind every effect and every view".

     Instant position cuts, and a forced instant turn at the catch, are full-view changes that are not fades.
   - "Reduce camera motion" is DW-13 (DW:121-128).
   - No bob or roll (EXP:266) holds in the build: nothing found that rolls the camera.
2. **Still open:**
   - The conflict above.
   - EXP does not say forced moves are cuts, or that the catch turns the view.
   - Reduce camera motion is deferred.
3. **Bin: housekeeping**, plus **defer** for DW-13. Sonlm chose the cuts in play in stories 1.5 and 1.6, so the documents follow the build.
   - Record exactly those cuts in State Patterns, Night: the catch, the end of the climb back, and the start and end of a gap crossing are cuts. The one forced turn is at the catch, to face the town, level.
   - Amend EXP:273 to allow them, for example: "full-view changes are slow fades or, for the warden's forced moves, single cuts; never a forced pan".
   - The same change is needed in GDD:740 and ARCH:97: hand GDD:740 to the next gds-gdd run (with DW-47), and make ARCH:97 a one-line architecture note.

   If Sonlm wants the cuts judged for comfort, that check goes with DW-13 in epic 8.

### R4.4: Left or right? is missing rows (low; Partly addressed)

1. **Settled since? Partly.** R rings again (EXP:52; GDD:149). "Either answer continues" after the swap (EXP:132). From Settings it returns to Settings (EXP:52). Not found: what happens after one wrong answer. Built in epic 2 story 9 (EPICS:484).
2. **Still open:** the one-wrong-answer state.
3. **Bin: decision**, needed before DW-20 writes story 2.9. Purpose: catch swapped or mono output (GDLOG:228). It is a test, so a guess must not pass by chance (memory note "tests must isolate the real cue"). Options:
   - (a) silently ring again on a side chosen at random and ask again, with no word that the answer was wrong;
   - (b) ring again on the same side;
   - (c) say plainly that it was wrong and ring again.

   Whatever the rule, a pure guess passes 3 times in 4, because one right answer in two tries is enough. What the check catches is swapped output, which a hearing player answers wrong both times, and that works under (a), (b) and (c) alike. The real differences are whether a second stroke from the same side lets a player who heard nothing flip their answer and pass (it does under (b)), and whether being told "wrong" helps or confuses.

### R4.5: Planning after "Another night" has no row (low; Partly addressed)

1. **Settled since? Yes, in the GDD.**
   - GD-52 (GDLOG:346): "'Another night' after dawn opens a fresh span"; the name and section are rolled again; the journal carries over.
   - GDD:433: "After a dawn, Another night opens a fresh span (GD-52)".
   - GD-58: oil and flask full (GDLOG:394).
   - Ringing on an untouched span: the only gate is the lanterns. GDD:432: "It cannot be rung until both placed lanterns are hung". So ringing with nothing stripped is allowed.
2. **Still open:** EXP has no row.
3. **Bin: housekeeping.** Add a Planning row, "After Another night": as Fresh span (EXP:136), with the Journal entry kept if it exists, the name and its section rolled again, and the forearm blank (GD-52). The bell can be rung on an untouched span once both lanterns are hung (GDD Mechanics 10).

### R4.7: Pause pressed during a night hold or with Tab held (low; Partly addressed)

1. **Settled since? Yes, by AD-67, with one open conflict (DW-39).**
   - ARCH:407: "On resume the night screen sends a `release` command for every input that was held at the pause and is no longer held, so a button let go during the pause cancels its hold on the first tick".
   - In Hold mode a Tab release lowers the forearm (`game/watch/sim/hold_rules.gd`:135-140). In Press once, releases do nothing (`hold_rules.gd`:6-8), so the hold runs on.
   - DW-39 (DW:378-385): "a change of the Holds option cancels the running hold". So pausing during a hold, changing Holds and resuming cancels the hold, against EXP:162 "Pause freezes a hold and does not cancel it". Owner "epic 5, the pause overlay". To do: "confirm with Sonlm that this cancel is wanted, and say so in EXPERIENCE.md or the architecture".
2. **Still open:** EXP does not carry AD-67's rule, and DW-39 is open.
3. **Bin: settled-elsewhere** for AD-67's rule: a button let go during the pause cancels its hold on resume; Tab let go lowers the forearm; in Press once nothing is cancelled. **Decision** for DW-39, which can be taken in this update. Purpose: EXP:162's "pause freezes a hold and does not cancel it" serves "Full pause at any time, in every phase" (EXP:271; UX-24, everything stops). The cancel on a mode change exists so that "a mode always starts from idle hands", since otherwise "a hold or a raised forearm would be left with no button behind it" (`hold_rules.gd`:9-11). Options:
   - (a) keep the cancel and write it beside EXP:162 as the one exception;
   - (b) apply the Holds change only after the running hold ends;
   - (c) when Holds changes on pause, keep the hold if its button is still down, and cancel it otherwise.

### R5.1: the mock link is unspecific and in one place (low; Partly addressed)

1. **Settled since? Partly.** DES:184 and EXP:76 now name the screens. Not at DES Layout & Spacing, nor on EXP's planning and dawn rows. The mocks also predate option C (DW-54).
2. **Still open:** link placement, and the mocks are stale.
3. **Bin: housekeeping.** Add links at DES Layout & Spacing (Planning, Dawn) and on EXP:55 and EXP:58, after the mock is redrawn for DW-54.
4. **[type-scale].**

### R7.3: terms drift a little (low; Partly addressed)

1. **Settled since? Partly.**
   - "Begin the watch" is the title's Start entry (EXP:84; UXLOG:84).
   - "Keys" is the entry and "key card" the page (EXP:59, :62, :110). UX-24's log line says "Key card" as the entry (UXLOG:39).
   - The GDD and EPICS say "why-not line" (GDD:799; EPICS:579), UX-33 says "why not" line (UXLOG:49), and the spines say "why-line".
2. **Still open:** a glossary line.
3. **Bin: housekeeping.** One line in EXP Voice and Tone: "Begin the watch = the title's Start; Keys = the tray and pause entry that opens the key card; why-line = the GDD's why-not line."

### L7: an unavailable tool's cost is `dim`, and the why-line needs a pointer (low; Partly addressed)

1. **Settled since? Partly.** DES:261 sets the cost in `muted` but does not say it stays `muted` when the tool is unavailable. GDD Mechanics 10: "A tool that cannot be afforded is dimmed; pointing at it ... says why" (GDD:429). Not found: what pressing 1, 2 or 3 on an unavailable tool does.
2. **Still open:** both.
3. **Bin: decision** (small), with a housekeeping part.
   - **Housekeeping:** the cost stays `muted` when the tool is unavailable; only the name goes `dim`. It follows from DES:196, "`dim` ... never for any text the player must read to proceed".
   - **Decision:** a key press on an unavailable tool. Options: (a) it shows that tool's why-line until the next input; (b) nothing. Purpose: UX-15, "an unaffordable tool dimmed; pointing at a section says why" (UXLOG:30); the keyboard path has no "pointing".
4. **[type-scale]** (`muted` and `dim` are being reopened).

### L5: smaller mismatches between the log and the spines (low; Partly addressed)

1. **Settled since? Partly.**
   - **UX-4** (UXLOG:19, "key card on the pause screen") is stale: the key card is also in the tray (UX-22, UX-33; EXP:62).
   - **The gray-box forearm is described three ways:**
     - UXLOG:62, "a flat panel with the same text";
     - EXP:390, "a flat forearm with the same marks";
     - DES:279, "never a screen-style panel".

     Story 1.4 built it: S1.4:47 D2, and `game/watch/night/hands.gd`:7-12, "a flat light 'skin' below the centre of the view, tilted toward the eye, with dark ink on it (DESIGN.md: ink on skin, never a panel)". Unshaded, so it reads with no lantern.
   - **"A visual cue for every sound"** is still unqualified (EXP:262) beside the known gaps (EXP:288).
2. **Still open:** all three.
3. **Bin: housekeeping.**
   - Add a log note that UX-4's key card is also in the tray (UX-22).
   - Replace the three forearm descriptions with story 1.4's: a flat light skin plate with dark ink, two rows led by a bar and a ring, unshaded, never a screen panel. Drop the [ASSUMPTION] tag on EXP:390's forearm half; the block hands are still epic 4's.
   - Qualify EXP:262 with "(see Known gaps)".

---

## Bins at a glance

| Bin | Findings |
|---|---|
| settled-elsewhere | R4.3, M10 (rows; size deferred), M15 (F only; E is a decision), R1.4, R2.7, R4.6, R7.1, R4.2, M11, R4.7 (AD-67 part) |
| housekeeping | R2.2, R3.5, R2.8, R3.6, R3.7, R3.9, R4.8, R5.2, R5.3, R6.1, R6.2, R7.4, R8.1, R3.1, M3, M18 (+ defer DW-13; also GDD:740, ARCH:97), R4.5, R5.1, R7.3, L5 |
| decision | M8, M19, R2.5, R3.8, L6, L1, L3, L4, L2, H2, M1, M2, M12, R4.4, L7, M15 (E's ready pose), DW-39 (inside R4.7) |
| defer | M13 (numbers per target), L8, H3 (DW-6), R2.3 (DW-21), M9 (DW-13) |

**[type-scale]:** R2.2, R3.5, M8, R2.5, R2.8, R5.2, L1, L2, R2.3, M9, R5.1, L7.

**Suggested order.**

1. Settle DW-54's sizes and colours first, because twelve findings wait on them.
2. Then the left/right check screen, needed before epic 2's stories (DW-20, story 2.9): H2, R4.4 and L4 together.
3. Then M9's caption-band check, for story 2.6.
4. The other decisions can be put to Sonlm in this update, or carried to the stories named.
