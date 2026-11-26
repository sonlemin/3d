## The game's theme in its first form (AD-69, story 1.7): the one place a size at 1080p becomes a
## canvas size, and the only script that names the font file. DESIGN.md's sizes are at 1080p; the
## canvas is 1280 x 720, so every size a screen uses goes through canvas_px(). No other script
## writes a pixel size for a screen.
##
## It holds only what the overhead read-out uses: the `number` and `label` styles and seven
## colours. Epic 5 adds the rest (the other styles and colours, the chosen-item glow, the halo, the
## title). Static only; no state. Not a screen, so no `_screen` suffix.
##
## Where it differs from DESIGN.md, and why (Sonlm's look at the read-out, M1 of story 1.7,
## 2026-11-27): with the window filling the laptop's screen the read-out was "too small and too
## dim" in every part. Sonlm chose, from three rendered versions, larger text and brighter planks,
## rails, dashes and labels (option C). Each such value below says so. Whether DESIGN.md's whole
## type scale and its other colours follow is for the UX update before epic 5's screens (DW-54).
class_name WatchTheme
extends RefCounted

## DESIGN.md, Typography: one family, Cormorant Garamond, bundled (fonts/CREDITS.md). A variable
## font, weight 300 to 700; only the upright file so far (italic is epic 5's).
const TYPEFACE: FontFile = preload("res://fonts/cormorant_garamond.ttf")

## DESIGN.md, Typography: semibold for everything but the title. The file's own default is Light
## 300, which DESIGN.md does not allow below title size.
const WEIGHT: int = 600
## The `number` style at 1080p (section strength; parts in hand in epic 5). Sonlm's M1: 72 px.
## DESIGN.md's typography.number is 48 px, too small on the laptop.
const NUMBER_PX: float = 72.0
## DESIGN.md, typography.number: letter spacing 0.
const NUMBER_SPACING_EM: float = 0.0
## The `label` style at 1080p, capitals (section numbers, the end words). Sonlm's M1: 40 px, the
## size of DESIGN.md's `value`. DESIGN.md's typography.label is 28 px, its floor for all text, and
## was too small on the laptop.
const LABEL_PX: float = 40.0
## DESIGN.md, typography.label: letter spacing 0.16 em.
const LABEL_SPACING_EM: float = 0.16
## DESIGN.md, spacing.2: 16 px at 1080p.
const SPACING_2_PX: float = 16.0
## DESIGN.md, spacing.safe-margin: 48 px at 1080p. Nothing is drawn nearer a canvas edge.
const SAFE_MARGIN_PX: float = 48.0

## DESIGN.md, Colors: the background of every menu and page, and the planning ground.
const WORLD: Color = Color("#070707")
## DESIGN.md, Colors: gaps where planks are missing.
const ABYSS: Color = Color("#000000")
## DESIGN.md, Colors: values the eye should land on (strength numbers).
const INK_BRIGHT: Color = Color("#ddd6c8")
## DESIGN.md, Colors: the common text colour. Sonlm's M1: the read-out's section numbers and end
## words (DESIGN.md has them in `muted`, too dim on the laptop).
const INK: Color = Color("#b9b4aa")
## DESIGN.md, Colors: small labels. Sonlm's M1: the read-out's dashed lines, a stripped rail and a
## fallen section's outline (DESIGN.md has them in `dim`, #5f5d59, too dim on the laptop).
const MUTED: Color = Color("#8d8982")
## Planks in the planning view. Sonlm's M1: #8d8982, `muted`'s value. DESIGN.md's `plank` is
## #55534f, too dim on the laptop.
const PLANK: Color = Color("#8d8982")
## Standing rail ropes in the planning view. Sonlm's M1: #ddd6c8, `ink-bright`'s value, so a rail
## stays brighter than a plank. DESIGN.md's `rail` is #8d8982.
const RAIL: Color = Color("#ddd6c8")

## The `number` style: a type variation of Label. A label asks for it by `theme_type_variation`.
const NUMBER_STYLE: StringName = &"WatchNumber"
## The `label` style: a type variation of Label, shown in capitals (make_label()).
const LABEL_STYLE: StringName = &"WatchLabel"


## A size at 1080p on the 1280 x 720 canvas: two thirds, rounded. It gives DESIGN.md's whole
## "At 720p" column (48 -> 32, 28 -> 19, 40 -> 27, ...).
static func canvas_px(token_px: float) -> int:
	return roundi(token_px * 2.0 / 3.0)


## A place on the canvas moved to the nearest even canvas pixel (Sonlm, 2026-11-26, story 1.7).
## A label a script places by hand goes through sharp_px(), which asks this for the start of its
## text. Godot draws a control from a whole canvas pixel, and in a
## 1080p window the canvas is drawn 1.5 times as large, so an odd canvas pixel is half a screen
## pixel and the text drawn from it is blurred by that half pixel (measured on the read-out's
## digits). An even one is a whole screen pixel at 1080p, 1440p and 4K. The label moves by at most
## 1 px. Window sizes in between (1366 x 768) are not helped (DW-53).
static func even_px(place: Vector2) -> Vector2:
	return (place / 2.0).round() * 2.0


## How far below `label`'s top edge its text's baseline is: the ascent of its font at its size
## (45 px in the number style, 25 px in the label style). The label must be in the tree under the
## themed root, so that its style is known.
static func text_rise(label: Label) -> float:
	return label.get_theme_font(&"font").get_ascent(label.get_theme_font_size(&"font_size"))


## `place`, a label's top left corner, moved by at most 1 px so that the label's text starts on an
## even canvas pixel: `place + rise` is what even_px() is asked for. `rise` runs from the corner the
## label is drawn from to the start of its baseline: `Vector2(0, text_rise(label))` for an upright
## label, and the same length across for one turned a quarter turn.
## The corner alone is not enough (measured 2026-11-27): the engine sets each glyph down from the
## baseline, so with an ascent of 45 px a label on an even row has its baseline on an odd one, and
## at 1080p its digits were blurred top to bottom.
static func sharp_px(place: Vector2, rise: Vector2) -> Vector2:
	return even_px(place + rise) - rise


## The theme a screen sets on its root. Each style carries its font, size and colour, so no label
## gets an override. The colours are the only ones each style has on the read-out (ink-bright for a
## strength, ink for a section number or an end word); epic 5 adds the others.
static func build() -> Theme:
	var theme: Theme = Theme.new()
	_add_style(theme, NUMBER_STYLE, _font(true, NUMBER_PX * NUMBER_SPACING_EM), NUMBER_PX, INK_BRIGHT)
	_add_style(theme, LABEL_STYLE, _font(false, LABEL_PX * LABEL_SPACING_EM), LABEL_PX, INK)
	return theme


## A label in `style`, to add under a control that carries build()'s theme. Capitals belong to the
## label style but are a property of the Label, not of a Theme, so they are set here once.
static func make_label(style: StringName) -> Label:
	var label: Label = Label.new()
	label.theme_type_variation = style
	label.uppercase = style == LABEL_STYLE
	return label


static func _add_style(theme: Theme, style: StringName, font: Font, token_px: float, color: Color) -> void:
	theme.set_type_variation(style, &"Label")
	theme.set_font(&"font", style, font)
	theme.set_font_size(&"font_size", style, canvas_px(token_px))
	theme.set_color(&"font_color", style, color)


## The typeface at WEIGHT with lining figures: Cormorant's own are old-style (its 1 reads as a
## small capital I), and DESIGN.md asks for lining ones. `tabular` adds figures of one width, for
## numbers that stack or change. `spacing_px` is the style's letter spacing at 1080p.
static func _font(tabular: bool, spacing_px: float) -> FontVariation:
	var text_server: TextServer = TextServerManager.get_primary_interface()
	# Plain dictionaries, not typed ones: the engine keeps the very dictionary it is handed and
	# also looks features up in it by name, which a Dictionary[int, int] refuses with an error.
	var features: Dictionary = {text_server.name_to_tag("lnum"): 1}
	if tabular:
		features[text_server.name_to_tag("tnum")] = 1
	var weight: Dictionary = {text_server.name_to_tag("weight"): WEIGHT}
	var font: FontVariation = FontVariation.new()
	font.base_font = TYPEFACE
	font.variation_opentype = weight
	font.opentype_features = features
	font.spacing_glyph = canvas_px(spacing_px)
	return font
