## The game's theme in its first form (AD-69, story 1.7): the one place a DESIGN.md token becomes
## a canvas size, and the only script that names the font file. DESIGN.md's sizes are at 1080p; the
## canvas is 1280 x 720, so every size a screen uses goes through canvas_px(). No other script
## writes a pixel size for a screen.
##
## It holds only what the overhead read-out uses: the `number` and `label` styles and seven
## colours. Epic 5 adds the rest (the other styles and colours, the chosen-item glow, the halo, the
## title). Static only; no state. Not a screen, so no `_screen` suffix.
class_name WatchTheme
extends RefCounted

## DESIGN.md, Typography: one family, Cormorant Garamond, bundled (fonts/CREDITS.md). A variable
## font, weight 300 to 700; only the upright file so far (italic is epic 5's).
const TYPEFACE: FontFile = preload("res://fonts/cormorant_garamond.ttf")

## DESIGN.md, Typography: semibold for everything but the title. The file's own default is Light
## 300, which DESIGN.md does not allow below title size.
const WEIGHT: int = 600
## DESIGN.md, typography.number: 48 px at 1080p (section strength, parts in hand).
const NUMBER_PX: float = 48.0
## DESIGN.md, typography.number: letter spacing 0.
const NUMBER_SPACING_EM: float = 0.0
## DESIGN.md, typography.label: 28 px at 1080p, capitals (the floor: no text is smaller).
const LABEL_PX: float = 28.0
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
## DESIGN.md, Colors: small labels.
const MUTED: Color = Color("#8d8982")
## DESIGN.md, Colors: stripped rails; a fallen section's outline.
const DIM: Color = Color("#5f5d59")
## DESIGN.md, Colors: planks in the planning and dawn views.
const PLANK: Color = Color("#55534f")
## DESIGN.md, Colors: standing rail ropes in the planning view.
const RAIL: Color = Color("#8d8982")

## The `number` style: a type variation of Label. A label asks for it by `theme_type_variation`.
const NUMBER_STYLE: StringName = &"WatchNumber"
## The `label` style: a type variation of Label, shown in capitals (make_label()).
const LABEL_STYLE: StringName = &"WatchLabel"


## A DESIGN.md size (at 1080p) on the 1280 x 720 canvas: two thirds, rounded. It gives DESIGN.md's
## whole "At 720p" column (48 -> 32, 28 -> 19, 40 -> 27, ...).
static func canvas_px(token_px: float) -> int:
	return roundi(token_px * 2.0 / 3.0)


## A place on the canvas moved to the nearest even canvas pixel, for a label a script places by
## hand (Sonlm, 2026-11-26, story 1.7). Godot draws a control from a whole canvas pixel, and in a
## 1080p window the canvas is drawn 1.5 times as large, so an odd canvas pixel is half a screen
## pixel and the text drawn from it is blurred by that half pixel (measured on the read-out's
## digits). An even one is a whole screen pixel at 1080p, 1440p and 4K. The label moves by at most
## 1 px. Window sizes in between (1366 x 768) are not helped (DW-53).
static func even_px(place: Vector2) -> Vector2:
	return (place / 2.0).round() * 2.0


## The theme a screen sets on its root. Each style carries its font, size and colour, so no label
## gets an override. The colours are the only ones each style has on the read-out (ink-bright for a
## strength, muted for a section number or an end word); epic 5 adds the others.
static func build() -> Theme:
	var theme: Theme = Theme.new()
	_add_style(theme, NUMBER_STYLE, _font(true, NUMBER_PX * NUMBER_SPACING_EM), NUMBER_PX, INK_BRIGHT)
	_add_style(theme, LABEL_STYLE, _font(false, LABEL_PX * LABEL_SPACING_EM), LABEL_PX, MUTED)
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
