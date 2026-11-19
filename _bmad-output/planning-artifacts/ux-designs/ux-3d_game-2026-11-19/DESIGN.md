---
name: 'The Mourning Watch: Lantern light'
description: 'Screen UI for the one-night game: words lit, or left in the dark. No panels; warm for what is chosen, colourless grey for the rest.'
title: 'DESIGN.md — The Mourning Watch (one-night game)'
status: final
created: 2026-11-19
updated: 2026-11-19
sources:
  - ../../gdds/gdd-3d_game-2026-11-19/decision-log.md
  - ../../gdds/gdd-3d_game-2026-11-19/gdd.md
  - .decision-log.md
colors:
  world: '#070707'
  abyss: '#000000'
  ink: '#b9b4aa'
  ink-bright: '#ddd6c8'
  caption: '#e9e2d2'
  muted: '#8d8982'
  dim: '#5f5d59'
  warm: '#f0b45a'
  plank: '#55534f'
  rail: '#8d8982'
  hairline: '#3a3835'
  dawn-sky: '#3b3a3d'
typography:
  title:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '104px'
    fontWeight: 500
    lineHeight: 1.0
    letterSpacing: '0.14em'
  heading:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '56px'
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: '0.07em'
  body:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '32px'
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: '0.04em'
  label:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '28px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.16em'
  value:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '40px'
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: '0.04em'
  number:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '48px'
    fontWeight: 600
    lineHeight: 1.0
    letterSpacing: '0'
  caption:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '44px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
  caption-small:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '36px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
  caption-large:
    fontFamily: 'Cormorant Garamond, Garamond, Georgia, serif'
    fontSize: '56px'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: '0.10em'
rounded:
  DEFAULT: '0px'
  full: '9999px'
spacing:
  '1': '8px'
  '2': '16px'
  '3': '24px'
  '4': '40px'
  '5': '64px'
  safe-margin: '48px'
  tray-gap: '56px'
components:
  menu-item:
    typography: '{typography.heading}'
    color: '{colors.ink}'
    color-chosen: '{colors.warm}'
    color-unavailable: '{colors.dim}'
  tool-tray:
    typography: '{typography.label}'
    color: '{colors.ink}'
    gap: '{spacing.tray-gap}'
    margin: '{spacing.safe-margin}'
  tray-tool:
    typography: '{typography.label}'
    color: '{colors.ink}'
    color-chosen: '{colors.warm}'
    color-unavailable: '{colors.dim}'
  why-line:
    typography: '{typography.body}'
    color: '{colors.muted}'
  hold-control:
    typography: '{typography.label}'
    color: '{colors.ink}'
    color-filling: '{colors.warm}'
  span-section:
    plank: '{colors.plank}'
    rail: '{colors.rail}'
    gap: '{colors.abyss}'
    strength-typography: '{typography.number}'
    strength-color: '{colors.ink-bright}'
  rig-mark:
    stroke: '{colors.ink}'
    typography: '{typography.label}'
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
    label-color: '{colors.muted}'
    value-typography: '{typography.value}'
    value-color: '{colors.ink-bright}'
  journal-page:
    background: '{colors.world}'
    edge: '{colors.hairline}'
    typography: '{typography.body}'
    color: '{colors.ink-bright}'
  key-card:
    key-typography: '{typography.label}'
    key-color: '{colors.ink-bright}'
    action-typography: '{typography.body}'
    action-color: '{colors.ink}'
  key-prompt:
    typography: '{typography.body}'
    color: '{colors.caption}'
    halo: '{colors.abyss}'
  setting-row:
    label-typography: '{typography.body}'
    label-color: '{colors.ink}'
    value-color: '{colors.ink-bright}'
    value-color-chosen: '{colors.warm}'
  two-choice:
    typography: '{typography.heading}'
    color: '{colors.ink}'
    color-chosen: '{colors.warm}'
  centre-dot:
    color: '{colors.ink}'
    size: '4px'
  town-window:
    lit: '{colors.warm}'
    out: '{colors.dim}'
---

# DESIGN.md — The Mourning Watch (one-night game)

How the screens look. How they behave is in [EXPERIENCE.md](EXPERIENCE.md). Both documents win over any mock on conflict.

Sizes are given for a 1920×1080 canvas and scale with the viewport height (Godot `canvas_items` stretch), so 720p shows two thirds of each value.

## Brand & Style

**Lantern light.** Words are lit, or left in the dark. There are no panels, cards, bars or boxes: text sits straight on near-black. Whatever is chosen glows warm, as if a lantern were held to it. Everything else is the colourless grey the game gives to the dead.

This is the GDD's palette rule applied to the interface: "near-black world; warm living things; colourless dead; a true black abyss." The screens are quiet so that the night can be loud. The interface never competes with the woodcut look of the night; it does not use hatching, texture or ornament.

The night itself has no screen UI except the ally's caption (and, by setting, a centre dot). Everything described here applies to the title, the first-launch screens, planning, pause and settings, the journal, the dawn ledger, and that one caption line.

Visual references: [mockups/key-screens.html](mockups/key-screens.html) shows planning, the dawn ledger, pause, settings, the lost-night page and the journal drawn to these tokens. [mockups/directions-1.html](mockups/directions-1.html) is the comparison this look was chosen from (direction C; its type is lighter than the tokens here allow).

## Colors

| Role | Token | Hex | Use | Not for |
|---|---|---|---|---|
| World | `world` | `#070707` | Background of every menu, page and the planning ground | The abyss |
| Abyss | `abyss` | `#000000` | Gaps where planks are missing; the caption's halo | Backgrounds |
| Ink | `ink` | `#b9b4aa` | Default text and line work | Chosen state |
| Bright ink | `ink-bright` | `#ddd6c8` | Values the eye should land on: strength numbers, ledger values, journal text | Labels |
| Caption | `caption` | `#e9e2d2` | The ally's caption and dusk key prompts, which sit over a live 3D view | Menus |
| Muted | `muted` | `#8d8982` | Small labels, the why-line, help text | Anything smaller than `{typography.label}` |
| Dim | `dim` | `#5f5d59` | Unavailable tools and entries; stripped rails; windows that have gone out | Any text the player must read to proceed |
| Warm | `warm` | `#f0b45a` | The one chosen thing on a screen; lantern reach; lit windows; a hold filling | Decoration, headings, more than one item per group |
| Plank | `plank` | `#55534f` | Planks in the planning and dawn views | Text |
| Rail | `rail` | `#8d8982` | Standing rail ropes in the planning view | — |
| Hairline | `hairline` | `#3a3835` | The single rule at the edge of the ledger and journal pages | Boxes |
| Dawn sky | `dawn-sky` | `#3b3a3d` | The top of the dawn view's gradient, from `world` | Text backgrounds |

Contrast on `world`: `ink` 9.8:1, `ink-bright` 13.9:1, `caption` 15.6:1, `warm` 10.9:1, `muted` 5.8:1, `dim` 3.1:1. `dim` is below 4.5:1 on purpose and is never the only way to learn something: an unavailable tool also has the why-line.

Warm and ink are close in brightness (1.12:1 against each other), so colour is never the only sign of the chosen state: chosen text also carries the glow and a 2 px `{colors.warm}` rule beneath it (see Elevation & Depth and Shapes).

There is no red, no green and no error colour. "Cannot" is said by `dim` plus words.

## Typography

One family, Cormorant Garamond (SIL Open Font License, bundled with the game), at semibold for everything except the title.

| Role | Token | Size at 1080p | At 720p | Use |
|---|---|---|---|---|
| Title | `title` | 104 px | 69 px | The game's name; capitals |
| Heading | `heading` | 56 px | 37 px | Menu entries, the two-choice screens, the ledger's vow line |
| Value | `value` | 40 px | 27 px | Ledger values, settings values |
| Number | `number` | 48 px | 32 px | Section strength, parts in hand |
| Caption | `caption` | 44 px | 29 px | The ally's line at the medium setting; `caption-small` is 36 px (24 px), `caption-large` is 56 px (37 px) |
| Body | `body` | 32 px | 21 px | Journal hints, the why-line, key card actions, settings labels |
| Label | `label` | 28 px | 19 px | Tray entries, ledger labels, key names; capitals |

Rules:

- **Floor.** No text is smaller than `{typography.label}`: 28 px at 1080p, about 19 px at 720p.
- **Capitals** with wide spacing are for `title` and `label` only. Sentences are never set in capitals.
- **Figures** are lining and tabular wherever numbers stack or change: strength numbers, parts in hand, ledger values.
- **Italic** is reserved for the epitaph and for "The fallen will return."
- The light weight seen in the direction mock is not used below `title` size.

## Layout & Spacing

- 8 px base (`{spacing.1}`). A `{spacing.safe-margin}` margin on every edge.
- **Menus** (title, pause, settings, two-choice screens): one centred column, entries stacked with `{spacing.3}` between them. The title sits above with `{spacing.5}` below it.
- **Planning:** the span runs across the full width and sits in the vertical middle, far pier at the left, town at the right. The tray is a strip of two lines along the bottom inside the safe margin. The upper line is for choosing: parts in hand, then tools 1, 2, 3. The lower line is for committing: Journal, Keys, Start over at the left, Ring the bell alone at the right. Entries are separated by `{spacing.tray-gap}`. (One line does not fit at the type floor: the entries need about 2,700 px of a 1,824 px line.) The why-line sits `{spacing.2}` above the tray, centred.
- **Dawn:** the span and the town's windows fill the left 64% of the view; the ledger page takes the right 36%, separated by one `{colors.hairline}` rule. Ledger lines are stacked with `{spacing.3}` between them; the two closing choices sit at the foot of the page.
- **Journal:** a single centred column no wider than 60 characters.
- **Caption:** bottom centre, its baseline `{spacing.5}` above the bottom safe margin, one line, no wider than 60% of the view.
- Nothing is anchored to a corner. Nothing overlaps the centre of the night view.

## Elevation & Depth

There are no shadows and no layers of surfaces. Depth is said with light:

- **Glow.** The chosen item has a soft halo of its own colour (`{colors.warm}`, about 0.7 of the text's height in radius) and a 2 px warm rule under it. This is the only "raised" state.
- **Halo.** Text drawn over a live 3D view (the caption, dusk key prompts) has a `{colors.abyss}` halo so it reads over lantern light: a solid 4 px outline and a soft 12 px spread at 1080p. No box, no bar.
- **Pause** dims the frozen view to about 15% and draws the menu on top. Screens replace one another; nothing stacks deeper than pause → settings.

## Shapes

Square or nothing. Corner radius is `{rounded.DEFAULT}` everywhere; the only round things are the lantern's reach and its lamp dot (`{rounded.full}`), because light is round. Rules are 1 to 2 px hairlines; the only coloured rule is the 2 px warm one under the chosen item. Missing things are drawn dashed (a stripped rail, a fallen section's outline, the edge of a lantern's reach).

## Components

Behaviour for each is in EXPERIENCE.md, Component Patterns, under the same name.

- **menu-item** — A word or short phrase in `{typography.heading}`, `{colors.ink}`. Chosen (by keys or by the pointer resting on it): `{colors.warm}` with glow. Unavailable: `{colors.dim}`. No bullets, no brackets.
- **tool-tray** — The unboxed bottom strip of the planning view. `{typography.label}` capitals in `{colors.ink}`; the "In hand" group label in `{colors.muted}`; counts in `{typography.number}`.
- **tray-tool** — Key number and name in `{typography.label}` capitals, then cost or count in `{typography.body}` lower case and `{colors.muted}`: "1 TRAPDOOR 2 ropes". Chosen: `{colors.warm}` with glow. Cannot be afforded or placed anywhere: `{colors.dim}`.
- **why-line** — One sentence in `{typography.body}`, `{colors.muted}`, italic off. Example: "Trapdoor needs 2 ropes. You hold 1."
- **hold-control** — A tray entry that must be held (Ring the bell, Start over). At rest it looks like its neighbours with "hold" in its wording. While held, the warm rule under it grows from left to right across the entry's width, and the text turns `{colors.warm}`; on release before the end the rule drains back.
- **span-section** — One of six squares seen from above. Up to eight `{colors.plank}` planks across the deck, missing ones showing `{colors.abyss}`; planks go missing from the far-pier side first. A standing rail is a solid `{colors.rail}` line along that edge; a stripped rail is a thin dashed `{colors.dim}` line. Section number above in `{colors.muted}`; strength below in `{typography.number}`, `{colors.ink-bright}`. In the dawn view a fallen section is a dashed outline only.
- **rig-mark** — Drawn over its section in `{colors.ink}` line work, with its name on a `{colors.world}` tag. Trapdoor: a frame with crossed diagonals. Swing-beam: a frame with a solid bar along the rail it hangs from. The frame is the coverage the GDD asks for.
- **lantern-reach** — A `{colors.warm}` dot over the middle of its section and a dashed `{colors.warm}` circle of the lantern's reach (the section and about half of each neighbour), filled with a warm glow that fades to nothing at the edge.
- **caption-line** — One line of `{typography.caption}` in `{colors.caption}` with the `{colors.abyss}` halo. No speaker name, no box, no arrows.
- **ledger-page** — `{colors.world}` ground with one `{colors.hairline}` rule on its inner edge. Each line: a `{colors.muted}` capital label above an `{colors.ink-bright}` value. The epitaph sits under the name in italic. "The fallen will return." is italic `{typography.heading}` with no label. The lines look written: each fades in from left to right.
- **journal-page** — Full-screen `{colors.world}`. Hints in `{typography.body}`, `{colors.ink-bright}`, one paragraph each, newest last. A hint being written in for the first time appears left to right; older hints are `{colors.ink}`.
- **key-card** — Two columns: key names in `{typography.label}` `{colors.ink-bright}`, actions in `{typography.body}` `{colors.ink}`. Grouped under three `{colors.muted}` labels: Night, Planning, Always.
- **key-prompt** — Dusk lesson only. One line in `{typography.body}`, `{colors.caption}` with halo, bottom centre where the caption sits; the key name in capitals. Never shown with a caption at the same moment: the caption wins and the prompt waits.
- **setting-row** — Label left in `{colors.ink}`, value right in `{colors.ink-bright}`; the row under the pointer or keyboard focus turns `{colors.warm}` with glow. A slider is a hairline with a small square marker. A choice shows its current value in words, never as a tick box.
- **two-choice** — Two `{typography.heading}` words side by side with `{spacing.5}` between them (Left / Right; Headphones / Speakers), a one-line question in `{typography.body}` above.
- **centre-dot** — Optional. A 4 px `{colors.ink}` dot at 60% opacity in the exact centre of the night view.
- **town-window** — In the dawn view, a small upright rectangle: lit is solid `{colors.warm}` with glow; out is a `{colors.dim}` outline.

Not screen components: the warden's hands, the forearm, lantern flames and reservoirs, the tally board, the town's windows at night, and the carved name are all objects in the 3D world. Their behaviour is in EXPERIENCE.md, HUD & Diegetic UI; their look belongs to the woodcut art pass (GDD epic 7). Two visual rules cross over. **The forearm is ink on skin** (the name in a written hand, parts as tally strokes in fives), never a screen-style panel, and its ink is kept clear of the hatching treatment. **Hands and forearm keep a minimum brightness** so they can be read with no lantern lit.

## Do's and Don'ts

- Do let one thing per group be warm. If two things glow, one of them is wrong.
- Do say "cannot" with dim text and a sentence.
- Do keep every screen readable in greyscale.
- Do keep the planning view clean: flat shapes, no hatching (GDD: the overhead view does not use the woodcut look).
- Don't draw a box, bar, card, badge, icon or progress ring anywhere.
- Don't put anything over the night view except the caption line and, if switched on, the centre dot.
- Don't use colour to carry meaning the words do not also carry.
- Don't use a second typeface, or any weight lighter than semibold below title size.
- Don't show a score, a kill count, a timer or a percentage, on any screen.
