# Validation Report — 3d_game (The Mourning Watch, one-night game)

- **DESIGN.md:** `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/DESIGN.md`
- **EXPERIENCE.md:** `_bmad-output/planning-artifacts/ux-designs/ux-3d_game-2026-11-19/EXPERIENCE.md`
- **Run at:** 2026-11-28 (review of commit d5f3af2; statuses as of the fixes the same day)
- **HTML version:** `validation-report.html`
- **Earlier report:** the report of 2026-11-20 (74 findings) is in git history at d5f3af2; every finding it left open has a disposition in `.decision-log.md`, "Update run 2026-11-27 to 2026-11-28".

## Overall verdict

The update leaves the pair a usable contract. Every token reference resolves and every colour has a hex. The stated contrast ratios and canvas sizes are right, bar one rounding. The measured fits were reproduced with the bundled font in Godot. What the review found was mostly text that no longer fits at the new, larger scale and had not been measured at its widest: the dawn ledger with two-digit counts, a rig's name on its section, and the key card's rows. Behind those were a handful of states the new rules left open. All 26 findings are now fixed, decided (UX-62 to UX-66) or routed to a deferred-work owner. Nothing has been checked in the game: scale B and option C were chosen from pictures (DW-58).

## Category verdicts

- Flow coverage — adequate
- Token completeness — adequate
- Component coverage — adequate
- State coverage — adequate
- Visual reference coverage — strong
- Bloat & overspecification — adequate
- Inheritance discipline — adequate
- Shape fit — strong

## Findings by severity

### Critical (0)

None.

### High (2)

**[Layout]** — H1: The dawn ledger overflows on any two-digit count (§ DESIGN.md, Layout, Dawn)
"PLANKS AND ROPES LEFT 48, 12" is 505 canvas px against 473.
Status: **Decided (UX-62).** The page is 45%, and the name sits under its label. Measured with the widest values: 603 of 656 tall, widest 505 of 512.

**[Component coverage]** — H2: A rig's name is wider than its section (§ DESIGN.md, rig-mark)
"SWING-BEAM" is 211 canvas px on a section of about 172 to 182.
Status: **Decided (UX-63).** Body lower case, 145 of 172, chosen from rendered pictures.

### Medium (9)

**[Inheritance]** — M1: UX-47 named epic 8; Cues everywhere is built in epic 5. Status: **Fixed.** Story 2.9 builds the lesson to allow it; story 5.8 switches it on.
**[Inheritance]** — M2: `epics.md` cites none of UX-42 to UX-66. Status: **Routed** (DW-59, epics part, with DW-20 and DW-22).
**[State coverage]** — M3: "Best with headphones." could never be seen. Status: **Decided (UX-64).**
**[State coverage]** — M4: two-choice hover, third answer's look, S. Status: **Decided (UX-65)**; `third-color` tokens added.
**[Layout]** — M5: the key card fits only with no gap between rows (704 with `spacing.1`). Status: **Fixed as a constraint**; [OPEN] for story 5.8 (short wording or Signs on its own page).
**[State coverage]** — M6: Ring the bell has no unavailable look. Status: **Fixed** (`muted`, does not fill, the press shows why).
**[Token completeness]** — M7: the slider's colours were undefined. Status: **Fixed** (`ink` track, `ink-bright` marker, `warm` chosen).
**[Component coverage]** — M8: UX-45's gap was ambiguous when a rail changes. Status: **Fixed** (measured from where a standing rail's line is; labels never move).
**[Token completeness]** — M9: thin marks off whole canvas pixels. Status: **Decided (UX-66)**: warm rule and halo outline 3 px; the centre dot is left to story 5.8.

### Low (15)

L1 contrast rounding (3.2:1) · L2 laptop size wording · L3 note-line placement · L4 "the one case" of a pause cancel · L5 UX-53 and UX-55 in GDD impacts · L6 focus loss in planning and dawn routed to the architecture (DW-59) · L7 `span-end` row · L8 credits page count in `body` · L9 the wound named as the one view effect · L10 the tune's ropes glow in Cues everywhere · L11 the old mock's span colours listed · L12 the theme's stale comments (DW-58) · L13 ledger text `spacing.4` inside its rule · L14 two-choice words in the menu column · L15 a hover's why-line. Status: **all fixed or routed**; details in `review-update-2026-11-28.md` and the decision log.

## Not addressed

- Nothing was run in the game. Scale B, option C, the rig names and the ledger were chosen from 1920×1080 pictures; Sonlm judges them in the game when story 5.1 builds planning (DW-58).
- The camera cuts the spines now describe were not checked against `warden.gd` by the reviewer.
- Cues everywhere has not been played muted (epic 8).

## Reviewer files

- `review-update-2026-11-28.md` (this run)
- `review-rubric.md`, `review-accessibility.md` (2026-11-19)
