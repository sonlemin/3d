---
name: 'The Mourning Watch: Lantern light'
description: 'Screen UI for the one-night game: words lit, or left in the dark. No panels; warm for what is chosen, colourless grey for the rest.'
title: 'DESIGN.md — The Mourning Watch (one-night game)'
status: final
created: 2026-11-19
updated: 2026-11-28
sources:
  - ../../gdds/gdd-3d_game-2026-11-19/decision-log.md
  - ../../gdds/gdd-3d_game-2026-11-19/gdd.md
  - ../../gdds/gdd-3d_game-2026-11-19/epics.md
  - ../../../game-architecture.md
  - .decision-log.md
colors:
  world: '#070707'
  abyss: '#000000'
  ink: '#b9b4aa'
  ink-bright: '#ddd6c8'
  caption: '#e9e2d2'
  muted: '#8d8982'
  warm: '#f0b45a'
  plank: '#8d8982'
  rail: '#ddd6c8'
  hairline: '#3a3835'
  dawn-sky: '#3b3a3d'
typography:
  title:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '108px'
    fontWeight: 500
    lineHeight: 1.0
    letterSpacing: '0.14em'
  heading:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '60px'
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: '0.07em'
  number:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '72px'
    fontWeight: 600
    lineHeight: 1.0
    letterSpacing: '0'
  caption-large:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '60px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
  caption:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '48px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
  value:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '48px'
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: '0.04em'
  caption-small:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '42px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
  body:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '42px'
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: '0.04em'
  label:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '42px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.16em'
rounded:
  DEFAULT: '0px'
  full: '9999px'
spacing:
  '1': '9px'
  '2': '18px'
  '3': '30px'
  '4': '48px'
  '5': '81px'
  safe-margin: '48px'
  tray-gap: '60px'
components:
  menu-item:
    typography: '{typography.heading}'
    color: '{colors.ink}'
    color-chosen: '{colors.warm}'
    color-unavailable: '{colors.muted}'
    rule-chosen: '{colors.warm}'
  tool-tray:
    typography: '{typography.label}'
    color: '{colors.ink}'
    group-label-color: '{colors.ink}'
    count-typography: '{typography.number}'
    count-color: '{colors.ink-bright}'
    gap: '{spacing.tray-gap}'
    line-gap: '{spacing.3}'
    margin: '{spacing.safe-margin}'
  tray-tool:
    typography: '{typography.label}'
    color: '{colors.ink}'
    cost-typography: '{typography.body}'
    cost-color: '{colors.ink}'
    color-chosen: '{colors.warm}'
    color-unavailable: '{colors.muted}'
  why-line:
    typography: '{typography.body}'
    color: '{colors.ink}'
  note-line:
    typography: '{typography.body}'
    color: '{colors.ink}'
  hold-control:
    typography: '{typography.label}'
    color: '{colors.ink}'
    color-filling: '{colors.warm}'
    color-unavailable: '{colors.muted}'
  span-section:
    plank: '{colors.plank}'
    rail: '{colors.rail}'
    missing: '{colors.muted}'
    gap: '{colors.abyss}'
    number-typography: '{typography.label}'
    number-color: '{colors.ink}'
    strength-typography: '{typography.number}'
    strength-color: '{colors.ink-bright}'
    label-gap: '{spacing.2}'
  span-end:
    typography: '{typography.label}'
    color: '{colors.ink}'
  rig-mark:
    stroke: '{colors.ink}'
    typography: '{typography.body}'
    color: '{colors.ink}'
    tag-background: '{colors.world}'
  lantern-reach:
    stroke: '{colors.warm}'
    fill: '{colors.warm}'
  caption-line:
    typography: '{typography.caption}'
    color: '{colors.caption}'
    halo: '{colors.abyss}'
  ledger-page:
    background: '{colors.world}'
    edge: '{colors.hairline}'
    label-typography: '{typography.label}'
    label-color: '{colors.ink}'
    value-typography: '{typography.value}'
    value-color: '{colors.ink-bright}'
    epitaph-typography: '{typography.body}'
    epitaph-color: '{colors.ink}'
    vow-typography: '{typography.heading}'
    vow-color: '{colors.ink-bright}'
  journal-page:
    background: '{colors.world}'
    edge: '{colors.hairline}'
    typography: '{typography.body}'
    color: '{colors.ink-bright}'
    color-older: '{colors.ink}'
  credits-page:
    background: '{colors.world}'
    typography: '{typography.body}'
    color: '{colors.ink}'
    page-count-typography: '{typography.body}'
    page-count-color: '{colors.ink}'
  key-card:
    key-typography: '{typography.label}'
    key-color: '{colors.ink-bright}'
    action-typography: '{typography.body}'
    action-color: '{colors.ink}'
    group-color: '{colors.ink}'
    sign-typography: '{typography.body}'
    sign-color: '{colors.ink-bright}'
  key-prompt:
    typography: '{typography.body}'
    color: '{colors.caption}'
    halo: '{colors.abyss}'
  setting-row:
    label-typography: '{typography.body}'
    label-color: '{colors.ink}'
    label-color-chosen: '{colors.warm}'
    value-typography: '{typography.value}'
    value-color: '{colors.ink-bright}'
    value-color-chosen: '{colors.warm}'
    slider-track: '{colors.ink}'
    slider-marker: '{colors.ink-bright}'
    slider-color-chosen: '{colors.warm}'
  two-choice:
    typography: '{typography.heading}'
    color: '{colors.ink}'
    color-chosen: '{colors.warm}'
    question-typography: '{typography.body}'
    question-color: '{colors.ink}'
    third-typography: '{typography.body}'
    third-color: '{colors.ink}'
    third-color-chosen: '{colors.warm}'
    gap: '{spacing.5}'
  centre-dot:
    color: '{colors.ink}'
    size: '4px'
    opacity: 0.6
  town-window:
    lit: '{colors.warm}'
    out: '{colors.muted}'
---

# DESIGN.md — The Mourning Watch (one-night game)

How the screens look. How they behave is in [EXPERIENCE.md](EXPERIENCE.md). Both documents win over any mock on conflict.

Sizes are given as they appear at 1080p and scale with the viewport height (Godot `canvas_items` stretch). The project's canvas is 1280×720, so the Theme holds two thirds of each value, and every type and spacing size here is divisible by 3 so that each canvas size is a whole pixel (architecture AD-69). Thin marks are given in whole canvas pixels too: the warm rule and the halo's outline are 3 px (2 canvas px), a 1 px rule is 1.5 px (1 canvas px); the centre dot is set in story 5.8. The reference screen is Sonlm's 13 to 14 inch laptop at 1920×1080: the sizes and colours were chosen from 1920×1080 captures shown full screen on it (UX-42, UX-43).

## Brand & Style

**Lantern light.** Words are lit, or left in the dark. There are no panels, cards, bars or boxes: text sits straight on near-black. Whatever is chosen glows warm, as if a lantern were held to it. Everything else is the colourless grey the game gives to the dead.

This is the GDD's palette rule applied to the interface: "near-black world; warm living things; colourless dead; a true black abyss." The screens are quiet so that the night can be loud. The interface never competes with the woodcut look of the night; it does not use hatching, texture or ornament.

The night itself has no screen UI except the ally's caption (and, by setting, a centre dot). Everything described here applies to the title, the first-launch screens, planning, pause and settings, the journal, the dawn ledger, credits, and that one caption line.

Visual references:

- [mockups/type-scale/index.html](mockups/type-scale/index.html): planning, title, settings, the dawn ledger and the key card, drawn in Godot and captured at 1920×1080. **B** is this document's scale; A is the scale before 2026-11-28 and C the one declined. Its "Dawn ledger with the widest values" section shows the ledger as finally chosen (option 1).
- [mockups/key-screens.html](mockups/key-screens.html): planning, the dawn ledger, pause, settings, the lost-night page and the journal, drawn to the tokens of 2026-11-20. It predates the current scale and colours; see "Where the mocks differ" below.
- [mockups/directions-1.html](mockups/directions-1.html): the comparison this look was chosen from (direction C).

## Colors

| Role | Token | Hex | Use | Not for |
|---|---|---|---|---|
| World | `world` | `#070707` | Background of every menu, page and the planning ground | The abyss |
| Abyss | `abyss` | `#000000` | Gaps where planks are missing; the caption's halo | Backgrounds |
| Ink | `ink` | `#b9b4aa` | All text that is not a value: labels, group labels, the why-line, note lines, actions, ledger labels; line work | Chosen state |
| Bright ink | `ink-bright` | `#ddd6c8` | Values the eye should land on: strength numbers, counts in hand, ledger values, journal text, key names | Labels |
| Caption | `caption` | `#e9e2d2` | The ally's caption and dusk key prompts, which sit over a live 3D view | Menus |
| Muted | `muted` | `#8d8982` | Unavailable tools and entries (name and cost alike); every dashed mark for a missing thing (a stripped rail, a fallen section's outline); windows that have gone out | Any text that is available |
| Warm | `warm` | `#f0b45a` | The one chosen thing in a group; lantern reach; lit windows; a hold filling | Decoration, headings, more than one item per group |
| Plank | `plank` | `#8d8982` | Planks in the planning and dawn views | Text |
| Rail | `rail` | `#ddd6c8` | Standing rail ropes in the planning and dawn views | Text |
| Hairline | `hairline` | `#3a3835` | The single rule at the edge of the ledger and journal pages | Boxes |
| Dawn sky | `dawn-sky` | `#3b3a3d` | The top of the dawn view's gradient, from `world` | Text backgrounds |

Shared values, on purpose (story 1.7, option C): `plank` is `muted`'s value, so a dashed mark for a missing thing is the colour of the planks; that is why a rail's dashed line lies just outside the deck's edge, where it cannot be taken for a plank's end. `rail` is `ink-bright`'s value, so a standing rail stays brighter than the planks.

Contrast on `world`: `ink` 9.8:1, `ink-bright` 13.9:1, `caption` 15.6:1, `warm` 10.9:1, `muted` (and `plank`) 5.8:1. On `dawn-sky`, the top of the dawn gradient: `ink` 5.5:1, `ink-bright` (and `rail`) 7.8:1, `warm` 6.1:1, `muted` (and `plank`) 3.2:1. So every mark that carries a count clears 3:1 anywhere in the dawn view.

Available and unavailable differ by colour (`ink` against `muted`, 1.7:1 apart) and by words: an unavailable tool also has the why-line. Warm and ink are close in brightness (1.12:1 against each other), so colour is never the only sign of the chosen state: chosen text also carries the glow and a 2 px `{colors.warm}` rule beneath it (see Elevation & Depth and Shapes).

There is no red, no green and no error colour. "Cannot" is said by `muted` plus words. `dim` (#5f5d59) was retired on 2026-11-28: it was too dim on the reference screen (UX-43).

## Typography

One family, Cormorant Garamond (SIL Open Font License, bundled with the game), at semibold for everything except the title.

| Role | Token | Size at 1080p | On the canvas (720p) | Use |
|---|---|---|---|---|
| Title | `title` | 108 px | 72 px | The game's name; capitals |
| Number | `number` | 72 px | 48 px | Section strength, counts in hand |
| Heading | `heading` | 60 px | 40 px | Menu entries, the two-choice words, the ledger's closing line ("The fallen will return.") |
| Caption large | `caption-large` | 60 px | 40 px | The ally's line at the large caption size |
| Caption | `caption` | 48 px | 32 px | The ally's line at the medium caption size (default) |
| Value | `value` | 48 px | 32 px | Ledger values, settings values |
| Caption small | `caption-small` | 42 px | 28 px | The ally's line at the small caption size |
| Body | `body` | 42 px | 28 px | Journal hints, the why-line, note lines, key card actions and signs, settings labels, credits, tool costs |
| Label | `label` | 42 px | 28 px | Tray entries, section numbers, the span's end words, ledger labels, key names, group labels; capitals |

`body` and `label` are the same size: a label is set in wide-spaced capitals, which read larger than lower case at the same size.

Rules:

- **Floor.** No text is smaller than 42 px at 1080p, 28 px on the canvas.
- **Capitals** with wide spacing are for `title` and `label` only. Sentences are never set in capitals.
- **Figures.** The bundled font's own figures are old-style (its 1 reads as a small capital I), so the theme turns on lining figures (`lnum`) in every style, and tabular figures (`tnum`) as well in `number` and `value`, wherever numbers stack or change. A test checks that the features take effect (story 1.7, `watch_theme.gd`).
- **Italic** is reserved for the epitaph and for "The fallen will return." (The italic file is not bundled yet; epic 5.)
- **Weight.** The light weight seen in the direction mock is not used below `title` size.

## Layout & Spacing

- Spacing steps are `{spacing.1}` to `{spacing.5}` (9, 18, 30, 48 and 81 px at 1080p). A `{spacing.safe-margin}` margin on every edge. Measured room inside it: 1,216 × 656 canvas px.
- **Menus** (title, pause, the two-choice screens): one centred column, entries stacked with `{spacing.3}` between them; the two words of a two-choice sit side by side on one row of it. The title sits above with `{spacing.5}` below it.
- **Settings:** two columns, Sound and Cues at the left, Controls and Display at the right, `{spacing.5}` apart, each group under its label. One column does not fit (17 settings). Measured at this scale: 1,022 of 1,216 canvas px wide.
- **Planning:** the span runs across the full width, far pier at the left, town at the right, centred in the room above the why-line. The tray is a strip of three lines along the bottom inside the safe margin, `{spacing.3}` apart, read bottom up:
  1. Committing: Journal, Keys, Start over at the left; Ring the bell alone at the right.
  2. The three tools, each with its cost.
  3. In hand: the counts of planks and ropes.

  Entries are separated by `{spacing.tray-gap}`; a name and its cost or count by `{spacing.2}`. The why-line sits `{spacing.3}` above the tray, centred. Measured: the tools line is 1,080 of 1,216 canvas px. The section numbers and strengths stand `{spacing.2}` clear of the rail lines' outer edges (see span-section).
- **Dawn:** the span and the town's windows fill the left 55% of the view; the ledger page takes the right 45%, separated by one `{colors.hairline}` rule (UX-62); the text stands `{spacing.4}` inside the rule. Each ledger line has its label and value on one line, `{spacing.2}` apart, except Names learned: its name sits on the line under the label, with the epitaph under the name. Lines are `{spacing.3}` apart; the two closing choices sit at the foot of the page. Measured with the widest values a night can produce (two-digit counts on every line, a long name): 603 of 656 canvas px tall, widest line 505 of 512. The real names and epitaphs (epic 5) must fit that width; a longer epitaph wraps.
- **Key card:** two columns: Night alone at the left; Planning, Always and Signs at the right. Each column sizes its key names to its own widest. Measured with stand-in wording: 641 of 656 canvas px with no space between rows, 704 with `{spacing.1}` between rows, which is too tall. So the real wording (story 5.8) must keep most actions to one line, or Signs moves to a page of its own; story 5.8 measures it and chooses.
- **Journal** and **Credits:** a single centred column no wider than 60 characters. Credits turns in pages, with its page count under the column.
- **Caption:** bottom centre, its baseline `{spacing.5}` above the bottom safe margin, one line, no wider than 60% of the view.
- Nothing is anchored to a corner. Nothing overlaps the centre of the night view except the centre dot, when it is switched on.

## Elevation & Depth

There are no shadows and no layers of surfaces. Depth is said with light:

- **Glow.** The chosen item has a soft glow of its own colour (`{colors.warm}`, about 0.7 of the text's height in radius) and a 3 px warm rule under it (2 canvas px, so it is sharp at 1080p; UX-66). This is the only "raised" state. How the glow is drawn is open (DW-21).
- **Halo.** Text drawn over a live 3D view (the caption, dusk key prompts) has a `{colors.abyss}` halo so it reads over lantern light: a solid 3 px outline and a soft 12 px spread at 1080p. No box, no bar.
- **Pause.** The frozen view is dimmed to about 15% and the menu is drawn on top. Screens replace one another; nothing stacks deeper than pause → settings → the left/right check.
- **Over the night view,** bottom to top: the scene, the wound's darkened side, the caption line (and the centre dot).

## Shapes

Square or nothing. Corner radius is `{rounded.DEFAULT}` everywhere; the only round things are the lantern's reach and its lamp dot (`{rounded.full}`), because light is round. Rules are 1.5 px (1 canvas px); the only coloured rule is the 3 px warm one under the chosen item. Missing things are drawn dashed (a stripped rail, a fallen section's outline, the edge of a lantern's reach). On the span, line widths are in metres so that they scale with the span: a standing rail's line is 0.2 m wide and a dashed line 0.1 m (story 1.7, option C).

## Components

Behaviour for each is in EXPERIENCE.md, Component Patterns, under the same name.

- **menu-item** — A word or short phrase in `{typography.heading}`, `{colors.ink}`. Chosen (by keys or by the pointer resting on it): `{colors.warm}` with glow and the warm rule. Unavailable: `{colors.muted}`. No bullets, no brackets. The swap and cues offers of the left/right check are menu-items.
- **tool-tray** — The unboxed three-line strip at the bottom of the planning view. `{typography.label}` capitals in `{colors.ink}`; the "In hand" group label in `{colors.ink}`; the counts in `{typography.number}`, `{colors.ink-bright}`.
- **tray-tool** — Key number and name in `{typography.label}` capitals, then the cost or count in `{typography.body}` lower case, `{colors.ink}`: "1 TRAPDOOR 2 ropes". Chosen: `{colors.warm}` with glow and rule. Unavailable (cannot be afforded or placed anywhere): name and cost both `{colors.muted}`, still readable.
- **why-line** — One sentence in `{typography.body}`, `{colors.ink}`, italic off. Example: "Trapdoor needs 2 ropes. You hold 1."
- **note-line** — One plain sentence in `{typography.body}`, `{colors.ink}`, next to the thing it explains (under it, or above a question): "Best with headphones." above the left/right check's line after Speakers is chosen, and under the Settings row while its value is Speakers (UX-64); the line under Visual cues; "A bell rings on one side." above the left/right question.
- **hold-control** — A tray entry that must be held (Ring the bell, Start over). At rest it looks like its neighbours, with "hold" in its wording in `{typography.body}`. While held, a warm rule grows under it from left to right across the entry's width, and the text turns `{colors.warm}`. On release before the end the rule drains back. Unavailable (Ring the bell with a lantern still to place): `{colors.muted}`, and holding it does not fill; the press shows the why-line instead.
- **span-section** — One of six sections seen from above.
  - Up to eight `{colors.plank}` planks across the deck; missing ones show `{colors.abyss}`. Planks leave in a fixed order that keeps the rest evenly spaced (GDD GD-54).
  - A standing rail is a solid `{colors.rail}` line 0.2 m wide just outside that edge of the deck. It stops 0.15 m short of each end of its section, so each joint shows as a break in both rail lines. A stripped rail is a `{colors.muted}` dashed line 0.1 m wide, also just outside the edge: over the plank ends it could not be told from them.
  - The section number above, in `{typography.label}`, `{colors.ink}`; the strength below, in `{typography.number}`, `{colors.ink-bright}`. Each stands `{spacing.2}` clear of where a standing rail's line's outer edge is, whether that rail is standing, stripped or the section has fallen, so the labels never move with the span's state (UX-45). An open section (no planks) reads 2, its side beams' strength (story 1.6 D4).
  - A fallen section is a `{colors.muted}` dashed outline of its deck, 0.1 m wide. It keeps its section number and has no strength; the same in planning and at dawn.
- **span-end** — The words FAR PIER and TOWN at the two ends of the span in `{typography.label}` capitals, `{colors.ink}`, turned to read upward, each centred on the deck's centre line and starting at the safe margin.
- **rig-mark** — Drawn over its section in `{colors.ink}` line work, with its name in `{typography.body}` lower case ("swing-beam"), `{colors.ink}`, on a `{colors.world}` tag centred in the section; in capitals it would be wider than a section (UX-63, measured: 145 of 172 canvas px). Trapdoor: a frame with crossed diagonals. Swing-beam: a frame with a solid bar along the rail it hangs from. The frame is the coverage the GDD asks for.
- **lantern-reach** — A `{colors.warm}` dot over the middle of its section and a dashed `{colors.warm}` circle of the lantern's reach (the section and about half of each neighbour), filled with a warm glow that fades to nothing at the edge.
- **caption-line** — One line of `{typography.caption}` (or `caption-small` / `caption-large` by setting) in `{colors.caption}` with the `{colors.abyss}` halo. No speaker name, no box, no arrows. Always drawn above the wound's darkened side.
- **ledger-page** — `{colors.world}` ground with one `{colors.hairline}` rule on its inner edge. Each line: a `{colors.ink}` capital label followed on the same line by its `{colors.ink-bright}` value; for Names learned the name sits on the line under its label, and the epitaph under the name in italic `{typography.body}`. "The fallen will return." is italic `{typography.heading}` with no label. The lines look written: each fades in from left to right.
- **journal-page** — Full-screen `{colors.world}`. Hints in `{typography.body}`, one paragraph each, newest last. The newest hint is `{colors.ink-bright}` and older hints are `{colors.ink}`. A hint being written in for the first time appears left to right.
- **credits-page** — Full-screen `{colors.world}`. One centred column of `{typography.body}`, `{colors.ink}`, in pages; under it the page count, "1 of 3", in `{typography.body}` (not capitals).
- **key-card** — Two columns of rows: key names in `{typography.label}` `{colors.ink-bright}`, actions in `{typography.body}` `{colors.ink}`, wrapping within the column. Grouped under four `{colors.ink}` labels: Night, Planning, Always, Signs. In Signs the sign itself ("Shaking ropes") is `{typography.body}` in `{colors.ink-bright}`, not a key name.
- **key-prompt** — Dusk lesson only. One line in `{typography.body}`, `{colors.caption}` with halo, bottom centre where the caption sits; the key name in capitals. Never shown with a caption at the same moment: the caption wins and the prompt waits.
- **setting-row** — Label left in `{typography.body}` `{colors.ink}`, value right in `{typography.value}` `{colors.ink-bright}`. Chosen (by keys or by the pointer resting on it): the row turns `{colors.warm}` with glow and the warm rule under the whole row. A slider is a 1.5 px `{colors.ink}` track with a small `{colors.ink-bright}` square marker; both turn `{colors.warm}` when the row is chosen. A choice shows its current value in words, never as a tick box. Check left and right is a row with no value.
- **two-choice** — Two `{typography.heading}` words side by side with `{spacing.5}` between them (Left / Right; Headphones / Speakers), a one-line question in `{typography.body}` above, and on the left/right check a note-line above the question. The check's third answer, "I can't hear it", sits below in `{typography.body}` `{colors.ink}`; chosen, it is `{colors.warm}` with glow and rule like the words. Neither word is warm when the screen opens.
- **centre-dot** — Optional. A 4 px `{colors.ink}` dot at 60% opacity in the exact centre of the night view. Its size and opacity are chosen again in story 5.8 from frames over lit wood (review finding L2).
- **town-window** — In the dawn view, a small upright rectangle: lit is solid `{colors.warm}` with glow; out is a `{colors.muted}` outline.

Not screen components: the warden's hands, the forearm, lantern flames and reservoirs, the tally board, the town's windows at night, and the carved name are all objects in the 3D world. Their behaviour is in EXPERIENCE.md, HUD & Diegetic UI; their look belongs to the woodcut art pass (GDD epic 7). Two visual rules cross over:

- **The forearm is ink on skin,** never a screen-style panel: a flat light skin plate with dark ink, planks in a row led by an inked bar and ropes in a row led by an inked ring, strokes in fives, and the name in a clear upright hand (story 1.4 D2; the hand itself is epic 7 story 4). Its ink is kept clear of the hatching treatment.
- **Hands and forearm keep a minimum brightness** so they can be read with no lantern lit (the gray box draws them unshaded).

## Where the mocks differ

`DESIGN.md` wins on every point below.

- `mockups/key-screens.html` (2026-11-20) uses the older scale (labels 28, body 32, headings 56, strengths 48), `muted` small labels and `dim` unavailable items, planks `#55534f` and rails `#8d8982` (now `#8d8982` and `#ddd6c8`). It also has a two-line tray and a 36% ledger page with each label above its value.
- `mockups/directions-1.html` sets direction C in weights 300 and 500, has no `muted` role, says layout is not decided, and uses a stand-in name and epitaph.
- `mockups/type-scale/` draws B with stand-in wording and no glow or italics. Its first B ledger picture is the 42% page later replaced (UX-62). Its read-out (planning) uses story 1.7's labels at 40 px and the gap from the deck's edge, which the code still has (DW-58).

## Do's and Don'ts

- Do let one thing per group be warm. If two things glow, one of them is wrong.
- Do say "cannot" with `muted` text and a sentence.
- Do keep every screen readable in greyscale.
- Do keep the planning view clean: flat shapes, no hatching (GDD: the overhead view does not use the woodcut look).
- Do measure a screen at 1080p with its real text before calling it done; the ledger and the key card are near full.
- Don't draw a box, bar, card, badge, icon or progress ring anywhere. The one exception is hold-control's warm rule, which grows under the entry while it is held.
- Don't put anything over the night view except the caption line, the centre dot if switched on, and the one view effect, the wound's darkened side (UX-52).
- Don't use colour to carry meaning the words do not also carry.
- Don't use a second typeface, or any weight lighter than semibold below title size.
- Don't set text darker than `ink`, unless it is unavailable.
- Don't show a score, a kill count, a timer or a percentage on any screen. A page count in Credits is not a score.
