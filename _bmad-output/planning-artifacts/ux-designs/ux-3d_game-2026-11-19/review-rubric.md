# Spine Pair Review — 3d_game (The Mourning Watch, one-night game)

Reviewed 2026-11-19: `DESIGN.md`, `EXPERIENCE.md` against `.decision-log.md` (UX-1 to UX-37), `.working/gdd-extract.md`, `gdd.md` draft 0.5 (spot checks by line), and `mockups/directions-1.html` (direction C). Nothing in the spines was edited.

## Overall verdict

The pair is a usable contract and close to ready. Mechanically it is clean: all 12 colours carry a hex, all 25 distinct `{path.to.token}` references in DESIGN.md and both in EXPERIENCE.md resolve, the six stated contrast ratios are correct, the 17 component names match one for one across both spines, both `sources` paths exist, and both spines keep the canonical section order. No critical findings.

What stands between it and a clean hand-off is at the edges of the retry loop and the hand-off to the GDD. Two high findings: the "GDD impacts" table leaves out several UX decisions that add to or change the GDD (new sounds, planning input rules, the lesson-skip rule, where the 3 s replay target is measured), and the lost-night screen is built around "the new hint being written" with no rule for a loss whose hint is already in the journal. The medium findings are mostly decisions that live only in a Key Flow or only in the mock (ledger lines, the speakers note, the closing choices at dawn), five logged decisions that were weakened in distillation, and component frontmatter that is thinner than the component prose.

Counts: 0 critical, 2 high, 14 medium, 23 low.

## 1. Flow coverage — adequate

Checked: the GDD names no player journeys (extract, "Player journeys and personas"), so the four Key Flows drafted under UX-35 are the whole set. Each has a named protagonist, numbered steps, a marked climax and a marked failure path. Rules cited in the flows were checked against the GDD: trapdoor cost of 2 ropes (gdd 530), the wrong ring's 10 s (gdd 355), the 0.3 s drop and 2 s falling cry, six tolls and 10 s of silence before wave 6, the hatchling half-window in Tomas step 7 (dust at a pier means a nest, so "a flicker, then dark" is right under UX-37).

### Findings

- **medium** Tomas's flow contradicts the logged journey. UX-35 says he "fails the left/right check, takes the swap"; the flow says "He declines the swap" (EXPERIENCE.md, Key Flows, "Tomas on speakers, cues everywhere", step 2). *Fix:* pick one and make the log and the flow agree. Declining fits a listener with one weak ear better, so amending UX-35 is probably the right direction, but it is the developer's call.
- **medium** The GDD's "first cry sounds within 60 s of pressing Start" (gdd 778) is not protected by the first-launch path. Between "Begin the watch" and the first cry the spines put two question screens, a left/right check that can be answered wrong twice, and key-prompts for look and walk that "stay until the action has been done once" (Key Flows, "Linh's first watch", steps 1 to 4; Component Patterns, key-prompt). UX-22 argues only that the hands-on part comes after the cries. *Fix:* state where the 60 s is measured from (entering the dusk lesson is the natural point) and that the first cry starts on a timer whether or not the look and walk prompts have been cleared.
- **low** Three behaviours are committed only inside a flow narrative, where an extracting consumer will not look: the speakers "best with headphones" line (Tomas step 1), the ledger's name line appearing only when a name was learned (Linh calls the name, step 7), and "one key" continuing from the lost-night page (Linh's first watch, step 9). *Fix:* move each into Component Patterns or State Patterns and leave the flow as the illustration.
- **low** No flow walks the returning player (Skip the lesson?) or Leave the bridge. Not required at four flows; noted because those two paths carry the open questions in sections 3 and 4.

## 2. Token completeness — adequate

Checked: every frontmatter token against `design-md-spec.md` type rules; every `{…}` reference in both files resolved programmatically (DESIGN.md: 11 colour, 6 typography, 2 rounded, 6 spacing references; EXPERIENCE.md: `{colors.dim}`, `{typography.label}`; `{path.to.token}` in the EXPERIENCE.md intro is the syntax note, not a reference). All 12 colours have a hex. One dark theme only, so no light/dark pairs apply. Contrast on `world` recomputed: ink 9.8, ink-bright 13.9, caption 15.6, warm 10.9, muted 5.8, dim 3.1, all as stated. UX-32's eight hex values are carried exactly.

### Findings

- **medium** Caption sizes small (36 px) and large (56 px) exist only as prose in a table cell (DESIGN.md, Typography, Caption row), while "Caption size" is a shipped setting (EXPERIENCE.md, Accessibility Floor, Settings list). A Theme built from the frontmatter has only the medium size. *Fix:* add `typography.caption-small` and `typography.caption-large`.
- **medium** The `components` frontmatter is thinner than the Components prose, so a consumer that mirrors the frontmatter loses states. Missing from frontmatter: menu-item hover (`ink-bright`); tool-tray group label (`muted`) and counts (`typography.number`); span-section stripped rail (`dim`), section number (`muted`) and fallen outline; rig-mark tag (`world`); key-card group labels (`muted`); two-choice gap (`spacing.5`) and question typography; ledger-page vow and epitaph styles; centre-dot opacity. setting-row disagrees with itself: prose says the row turns warm, frontmatter has only `value-color-chosen` (DESIGN.md, frontmatter `components` against body Components). *Fix:* make the frontmatter the full set and let the prose explain it.
- **medium** The effects that carry legibility are described but not quantified or tokenised: the glow ("about 0.7 of the text's height", no opacity; the mock uses `rgba(240,180,90,.3)`), the halo ("tight"), the pause dim ("about 15%"), hairlines ("1 to 2 px"), the centre dot's 60% (DESIGN.md, Elevation & Depth; Shapes; Components). The halo matters most: `caption` on `warm` is 1.4:1, so over lantern light the halo is the only thing making the one always-on line readable. *Fix:* add an `effects` block (glow radius and alpha, halo width in px at 1080p, pause dim, hairline width) and state the halo as the contrast guarantee for text over the 3D view.
- **medium** Hover is specified two ways. DESIGN.md gives menu-item a separate "pointer hover without choosing" state in `ink-bright`; EXPERIENCE.md says "Pointer hover and keyboard choice are the same state" (Component Patterns, menu-item), and setting-row turns warm under the pointer. `ink-bright` against `ink` is also only 1.4:1 apart. *Fix:* keep EXPERIENCE.md's rule (hover chooses, warm with glow) and delete the separate hover state, or define when hover does not choose.
- **low** Contrast is stated for `world` only. In the dawn view the gradient runs to `dawn-sky`, where `dim` is 1.7:1, `plank` 1.5:1 and `muted` 3.2:1 (DESIGN.md, Colors; Components, town-window, span-section). The counts are repeated in the ledger, so nothing is lost, but an out window may not be visible. *Fix:* say the span and windows sit in the `world` end of the gradient, or state the ratios.
- **low** tray-tool's cost is "in a smaller run (still at the floor)", but the tray is set in `label`, which is the floor (DESIGN.md, Components, tray-tool against Typography, Floor). *Fix:* same size, set in `muted`.
- **low** Lining tabular figures are required (Typography, Figures; UX-34) but depend on OpenType features in the bundled font file. *Fix:* note that the Godot font import must enable `lnum` and `tnum`, and check the bundled Cormorant Garamond build has them.
- **low** `rail` and `muted` share `#8d8982`; `spacing.4` is referenced nowhere; `dawn-sky` is referenced by no component because the dawn and planning grounds are not components. Harmless; listed for the Theme builder.

## 3. Component coverage — adequate

Checked: the 17 names in DESIGN.md frontmatter, DESIGN.md Components and EXPERIENCE.md Component Patterns are identical (menu-item, tool-tray, tray-tool, why-line, hold-control, span-section, rig-mark, lantern-reach, caption-line, ledger-page, journal-page, key-card, key-prompt, setting-row, two-choice, centre-dot, town-window). Every row has real rules on both sides. The misses are elements that appear on a surface without belonging to any component.

### Findings

- **medium** The ledger's content is not committed in either spine. UX-14 says "its seven lines"; the spines never say seven, never list them, and never point at the GDD's list (gdd 176-182). Label and value formats exist only in the mock ("Planks and ropes left · 9, 2", "Souls released · One"). The variants are open: with no name learned, is the line absent (Linh calls the name, step 7, implies so) or shown empty (GDD: "or nothing")? DESIGN.md says label above value; EXPERIENCE.md's Voice example is inline, "Sections standing · 3 of 6" (DESIGN.md, Components, ledger-page; EXPERIENCE.md, Voice and Tone; Component Patterns, ledger-page). *Fix:* add a seven-row table to ledger-page: label, value format, what shows at zero or none, order (cite the GDD for which lines exist).
- **medium** The two closing choices at dawn have no component. DESIGN.md Layout puts them "at the foot of the page"; hold-control lists Leave the bridge as a 1 s hold without saying where; Linh presses Enter on "Another night"; two-choice binds A and D and has a question line (DESIGN.md, Layout & Spacing, Dawn; EXPERIENCE.md, Component Patterns, hold-control, two-choice, ledger-page). *Fix:* name them (two menu-items, the second a hold-control) and say whether Leave the bridge is held at dawn as it is in Pause.
- **medium** hold-control does not say what is held. Space is given for Ring the bell; for Start over and Leave the bridge nothing is (mouse button on the entry, or Enter on the chosen entry, or both), nor whether Ring the bell can also be click-held from the tray (EXPERIENCE.md, Component Patterns, hold-control; Input Schemes). *Fix:* one line per control with its inputs.
- **medium** Start over's effect is never stated in the spines. UX-17 says it "restores the whole span to dusk"; the spines give only its position, wording and hold time (EXPERIENCE.md, Component Patterns, hold-control; Interaction Primitives). *Fix:* add the effect, and that parts in hand return to zero and every rig and lantern is taken back.
- **medium** Surfaces carry elements that no component covers: Credits (asset licences and the AI disclosure are long text; no layout, type role or scrolling rule); the swap offer and single-channel warning on Left or right?; one-line notes (the line under the Cues choice, the "best with headphones" note); the title wordmark (EXPERIENCE.md, Information Architecture table; State Patterns, Settings). *Fix:* add a `credits-page` and a `note-line` component (or widen why-line), and say the swap offer is two menu-items.
- **low** rig-mark says "Right click on its section removes it and returns its cost"; span-section and UX-17 say right click undoes the last choice on that section, which may be a plank strip made after the rig (EXPERIENCE.md, Component Patterns). *Fix:* rig-mark defers to span-section's rule.
- **low** why-line's trigger covers an unavailable tool and a section where the chosen tool cannot go, but span-section also promises a why-line for refused strips with no tool chosen (section 6 at 4 planks). A rail that holds a swing-beam cannot be stripped (gdd 285) and has no stated response (EXPERIENCE.md, Component Patterns, why-line, span-section). *Fix:* widen the trigger to "any refused click in planning" and add the beam-rail case.
- **low** setting-row covers values only. "Check left and right" is an action, sliders have no step, and Resolution has no stated list (Accessibility Floor, Settings list). *Fix:* one line each.
- **low** two-choice has no Esc rule, and the wording of the Skip the lesson? choices is not given (the diagram uses Yes and No) (Component Patterns, two-choice; Information Architecture).

## 4. State coverage — adequate

Checked: every row of the IA table against the states it should have. Not applicable here: offline, permission-denied, account or save errors. Covered well: planning (fresh, after a loss, unavailable, nothing to undo), the night (eleven rows), pause, journal before the first hint.

### Findings

- **high** A lost night with no new hint to write is undefined. The lost-night surface is "the journal page opens on the new hint being written" (State Patterns, Lost night; UX-12). There are six hints, one per cause, chosen by "whichever cost the most" (gdd 171), so a second loss to the same cause, the common case for a newcomer and the case Linh's own flow sets up, has no new hint. The GDD does not settle it either. *Fix:* commit one behaviour (for example: the page opens on the existing hint for that cause, drawn as already written, with no writing-in), add it as a State Patterns row, and add it to GDD impacts.
- **medium** Journal lifetime is undefined. "No save" (Information Architecture) sits beside settings and the lesson flag being kept between launches (setting-row; Skip the lesson?). Nothing says whether hints survive Another night, Leave the bridge to Title, or quitting. This decides what the architecture persists. *Fix:* state the scope of each kept thing in one table: settings (machine), lesson-finished flag (machine), journal hints (sitting or machine), the read name (one night).
- **medium** "Knocked down, hanging, crossing a gap: no input but look until it ends" (State Patterns, Night) adds an input lock to two crossings the GDD only times (open section 4 s, fallen gap 8 s; gdd 268-269), and neither document says how a crossing starts or whether it can be abandoned. *Fix:* state the trigger (walking onto the edge is the obvious one) or mark it [OPEN] for architecture, and list it under GDD impacts.
- **low** Left or right?: no row for one wrong answer (is the stroke repeated?), for what follows accepting the swap (re-test or continue), or for hearing the stroke again. It can also be opened from Settings during a paused night (Information Architecture table; State Patterns).
- **low** Planning after "Another night" has no row (span at dusk, nothing in hand, journal kept, a new name section per the GDD), and ringing the bell on an untouched span is not stated as allowed.
- **low** No rule for the window losing focus (alt-tab, a stream overlay). An automatic pause is the usual answer and suits "Mai streams it".
- **low** Pause pressed during a night hold or with Tab held: Resume "continues from the same instant", but whether the hold survives a released button is not stated (State Patterns, Pause).
- **low** "Nothing is deeper than two steps from play (Pause → Settings)" is not true of Pause → Settings → Check left and right (Information Architecture; DESIGN.md, Elevation & Depth).

## 5. Visual reference coverage — adequate

Checked: `mockups/` holds one file, `directions-1.html` (four directions, each drawing planning, dawn, the night caption and the title). `imports/` is empty; there is no `wireframes/`. "Both documents win over any mock on conflict" is stated at the top of each spine. DESIGN.md links the mock once, in Brand & Style, and names direction C. No orphans.

### Findings

- **low** The link is unspecific and in one place. It does not say which four screens the mock shows, and neither Layout & Spacing (planning, dawn) nor EXPERIENCE.md (Information Architecture; Component Patterns, tool-tray, which UX-33 fixes "as mocked") links to it. *Fix:* link at DESIGN.md Layout & Spacing and at EXPERIENCE.md's planning and dawn rows, naming the screen each time.
- **low** Known differences from the mock are only partly listed (the light weight, in Typography). Also different: the mock has no `muted` role, sets C in weights 300 and 500, says "Layout is not decided here" in its own header although UX-33 later fixed the tray, and uses a stand-in name and epitaph. *Fix:* one "where the mock differs" list in DESIGN.md.
- **low** `.working/directions-1.html` is a byte-identical copy, and UX-32 in the log still points at the `.working` path. Housekeeping.

## 6. Bloat & overspecification — adequate

Lean for its size. Tables are used where tables work; EXPERIENCE.md prose is plain; the GDD is cited and not restated; the 720p column in Typography earns its place because 720p is a test resolution. DESIGN.md's "Not screen components" paragraph is a useful fence.

### Findings

- **low** The same rule is stated in three or four places, which is where the drift found above comes from: the caption rule (Foundation, Component Patterns, HUD & Diegetic UI, Accessibility Floor), hold-to-commit (Component Patterns, Interaction Primitives, Input Schemes), the lost night (IA table, State Patterns, Game Feel, Flow 1), undo (span-section, rig-mark, Interaction Primitives). *Fix:* one home per rule; the others cite it.
- **low** Game Feel & Juice restates several GDD outcomes (right ring, wrong ring, rig sprung). They are marked "(GDD)" and short; trimming is optional.

## 7. Inheritance discipline — adequate

Checked: both `sources` lists resolve (`../../gdds/gdd-3d_game-2026-11-19/decision-log.md` and `gdd.md` exist; `.decision-log.md` exists). Component names are identical across every section of both files. EXPERIENCE.md token references resolve by name. GDD terms are used as the GDD uses them (the tune, the hum, the one who keeps coming back, town pier, far pier, tally board, lost night, Ears only, Cues everywhere, Stream-safe sound).

### Decision log fidelity (UX-1 to UX-37)

Carried faithfully: UX-1, 2, 3, 4, 5, 9, 10, 11, 12, 15, 16, 18, 20, 22, 25, 26, 27, 28, 30, 31, 32, 33, 34 (the spines' floor of 28 and 19 px is stricter than the logged 26 and 18, and is listed as derived), 37.

| Decision | Status | What differs | Where |
|---|---|---|---|
| UX-35 | Contradicted | Log: Tomas "takes the swap". Spine: "He declines the swap". | EXPERIENCE.md, Key Flows, Tomas, step 2 |
| UX-24 | Contradicted in part, weakened | Log: Leave the bridge "asks first; nothing is saved". Spine: a 1 s hold with no question and no "nothing is saved" wording. The Finalize list in the log records the hold fill but not that it replaces asking. Also missing: "The playtest build logs each pause." | EXPERIENCE.md, Component Patterns, hold-control; Interaction Primitives; State Patterns, Pause |
| UX-19 | Weakened | Missing: the answer "changes no cue" and is "written to the playtest log". The "best with headphones" note survives only in a flow. | EXPERIENCE.md, IA table, "Headphones or speakers?"; Key Flows, Tomas, step 1 |
| UX-17 | Weakened | Start over's effect ("restores the whole span to dusk") is not stated. | EXPERIENCE.md, Component Patterns, hold-control |
| UX-14 | Weakened | "Seven lines" and "written by hand" are reduced to "lines"; the lines are not listed or cited. | DESIGN.md, Components, ledger-page; EXPERIENCE.md, Component Patterns, ledger-page |
| UX-29 | Weakened | Missing: "Section 6's cues and the tally board are always readable. The gate light cannot be shuttered or moved." | EXPERIENCE.md, HUD & Diegetic UI, opening paragraph |
| UX-7 | Weakened | Missing: "reach does not change" as the flame shrinks. This is a rendering rule the architecture needs. | EXPERIENCE.md, State Patterns, "Lantern near empty"; HUD table, "Oil left" |
| UX-8 | Weakened | The fixed plank order is stated for planning only, not for the night; "positions stay cosmetic" and "the name shows through at 4 or fewer" appear only in a flow. | EXPERIENCE.md, HUD table, "A section's strength"; DESIGN.md, Components, span-section |
| UX-13 | Weakened | "Not carried at night" is not stated, and Pause, which holds Journal, is reachable at night. The log has the same tension between UX-13 and UX-24. | EXPERIENCE.md, IA table, Journal; Pause line |
| UX-21 | Weakened | "A flag kept with settings, not a save game" is reduced to "on this machine". | EXPERIENCE.md, IA table, "Skip the lesson?" |
| UX-36 | Weakened | "Refill that lantern, once" loses "once"; only "full or empty" remains. | EXPERIENCE.md, Input Schemes, E; HUD table, "The spare flask" |
| UX-6 | Weakened | Missing: "The reason is read from the forearm tallies or the object." | EXPERIENCE.md, State Patterns, "Action impossible" |
| UX-23 | Renamed | Log and GDD say "Start"; the spines say "Begin the watch". The rename is not in the log's derived list, and gdd 778 measures from "pressing Start". | EXPERIENCE.md, IA; Voice and Tone |

The seven items the log lists as "derived at distillation" are all present in the spines as described.

### Findings

- **high** "GDD impacts" is incomplete, and EXPERIENCE.md itself says the GDD should be updated from it before architecture reads it. Nothing unlisted flatly reverses a GDD rule, but these change or add to it and have no row (EXPERIENCE.md, GDD impacts):
  - UX-12: the 3 s replay target (gdd 718) is now measured from the continuing action, after the journal page. This moves a performance criterion.
  - UX-16: a planning click strips the next plank in a fixed order, where the key map says "Left click on a plank"; Esc and a repeated 1, 2 or 3 put a tool away.
  - UX-17: the Start over control. UX-20: how the left/right check is answered.
  - UX-21: the lesson can be skipped only after it has been finished once on this machine, skipping also skips the left/right check, and a flag is kept on disk in a game with "no save".
  - New sounds beyond UX-30 and UX-37, none in the GDD's sound list (gdd 739): the "can't" knock and the cancel sounds (UX-6), the sputtering flame (UX-7), the pen scratch when the name is inked (UX-10), the hint being written (UX-12), and the three planning sounds (Game Feel & Juice, Planning).
  - New visuals: the glass reservoir and the flask seen full or empty (UX-7, UX-36); planks drawn singly in a fixed order (UX-8); cue objects that light themselves in Cues everywhere (UX-27), which is a rendering requirement.
  - Rules added to GDD mechanics: Tab allows walking but blocks the hands (UX-11); "facing out" as a condition for 1, 2 and R (UX-9, whose row mentions only the rail); the flame leans to the hum only when no cry sounds in its light; a shaken hook gets no ready pose; the input lock while crossing.
  - UX-24 and UX-19: pause is a full stop in every phase; the headphones answer and each pause go to the playtest log.
  *Fix:* add a row for each, or split the table into "changes a GDD statement" and "adds to the GDD (assets, inputs, rules)".
- **medium** Thirteen logged decisions are contradicted, weakened or renamed in the spines (table above). The two that change what gets built are UX-24 (confirmation replaced by a hold) and UX-35. *Fix:* restore the dropped clauses, or record each change in the log's derived list so the log stays canonical.
- **low** Terms drift a little: "Key card" (log, component) against "Keys" (pause and tray entry); "Start" against "Begin the watch"; "why not line" (log) against "why-line". *Fix:* a short glossary line in EXPERIENCE.md.
- **low** The spines cite "GDD epic 5" and "GDD epic 7", which live in `epics.md`; it is not in `sources`. *Fix:* add it.

## 8. Shape fit — strong

DESIGN.md runs Brand & Style, Colors, Typography, Layout & Spacing, Elevation & Depth, Shapes, Components, Do's and Don'ts: canonical order, all eight present. EXPERIENCE.md has all eight required defaults (Foundation, Information Architecture, Voice and Tone, Component Patterns, State Patterns, Interaction Primitives, Accessibility Floor, Key Flows) plus the three game sections the example carries (HUD & Diegetic UI, Input Schemes, Game Feel & Juice). The two invented sections, "GDD impacts" and "Assumptions and open items", earn their place. No Responsive section is defensible: one device class, and the 1080p to 720p scaling rule is stated in DESIGN.md's opening and in Foundation.

### Findings

- **low** Inspiration is required when the sources or log show reference products or rejects, and both do: the GDD names *Thronefall*, *Dome Keeper* and *Kingdom Two Crowns*, and UX-32 declines three directions (chalk on slate, ledger paper, engraved plate). There is no Inspiration section. *Fix:* four or five lines in EXPERIENCE.md: the three declined directions and why, so a later contributor does not re-propose them.

## Mechanical notes

- **References.** DESIGN.md: 25 distinct token references, all resolve. EXPERIENCE.md: 2, both resolve. No reference to a missing token anywhere.
- **Frontmatter.** DESIGN.md has `name`, `description`, `colors`, `typography`, `rounded`, `spacing`, `components`, with types as the spec asks (hex strings, numeric weights and line heights, dimension strings). The font-family fallbacks (Garamond, Georgia, serif) mean nothing in a Godot Theme with a bundled font; harmless. EXPERIENCE.md has `title`, `status`, `form_factor`, `sources`.
- **Mermaid.** Not rendered in this review. The node id `LR` in a `flowchart LR` diagram reuses the direction keyword; render it once and rename the node (for example `LRC`) if the parser objects. The diagram leaves out Pause, Journal and Keys; the table under it covers them.
- **Cross-file conflicts found:** menu-item hover (section 2); rig-mark against span-section undo (section 3); ledger label above value against inline (section 3); tray-tool "smaller run" against the type floor (section 2).
- **Numbers checked against the GDD and found right:** 48 planks and 12 ropes (gdd 251); trapdoor 2 ropes (gdd 530); section 6 stops at 4 planks and takes no rig (gdd 270); the lantern-reach drawing of a section plus half of each neighbour (5 m reach, 5 m sections); wound 20 s; 2 m context range; holds of 2 to 12 s.
- **Type table order.** Typography lists Value (40 px) above Number (48 px); every other row descends by size.
- **Notes not raised as findings, as instructed:** the Key Flows are not inherited from the GDD; controller, couch and handheld coverage is absent by design; the night has no HUD; names, epitaphs and journal hint texts are open under GDD epic 5.
