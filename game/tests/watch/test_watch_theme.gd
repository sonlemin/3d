## The first theme (AD-69, story 1.7 AC 6): the one place a size at 1080p becomes a canvas size,
## and the two text styles and the colours the overhead read-out uses. Every expected value is
## written out here and never read from the constants under test: DESIGN.md's, except where
## Sonlm's look at the read-out (M1, 2026-11-27: "too small and too dim" with the window filling
## the laptop's screen) chose larger text and brighter colours for it.
extends TestCase

const FONT_PATH: String = "res://fonts/cormorant_garamond.ttf"


func _tag(feature: String) -> int:
	return TextServerManager.get_primary_interface().name_to_tag(feature)


func _font_of(theme: Theme, style: StringName) -> FontVariation:
	return theme.get_font(&"font", style) as FontVariation


func _test_canvas_px_is_two_thirds_rounded() -> void:
	# DESIGN.md, Typography, "Size at 1080p" -> "At 720p": 104 -> 69, 56 -> 37, 48 -> 32, 44 -> 29,
	# 40 -> 27, 32 -> 21, 28 -> 19; the two other caption sizes 36 -> 24 and 56 -> 37. Spacing:
	# spacing.2 16 -> 11, safe-margin 48 -> 32.
	var cases: Dictionary[int, int] = {104: 69, 56: 37, 48: 32, 44: 29, 40: 27, 32: 21, 28: 19, 36: 24, 16: 11}
	for token: int in cases:
		_check("theme: a %d px token is %d canvas px" % [token, cases[token]],
				WatchTheme.canvas_px(float(token)) == cases[token], str(WatchTheme.canvas_px(float(token))))
	# Sonlm's M1 (2026-11-27): the read-out's strengths are 72 px and its labels 40 px at 1080p:
	# 48 and 27 on the canvas. The label's letter spacing, 0.16 em of 40 px, is 6.4 px: 4.
	_check("theme: a 72 px size is 48 canvas px", WatchTheme.canvas_px(72.0) == 48, str(WatchTheme.canvas_px(72.0)))
	_check("theme: 6.4 px (0.16 em of the label) is 4 canvas px", WatchTheme.canvas_px(6.4) == 4,
			str(WatchTheme.canvas_px(6.4)))


func _test_even_px() -> void:
	# even_px() moves a place to the nearest even canvas pixel, which is a whole screen pixel in a
	# 1080p window (1.5 times the canvas): (154.5, 466.5) goes to (154, 466); (345.5, 466.5) to
	# (346, 466). Sonlm, 2026-11-26. Since 2026-11-27 the place that is moved is not a label's
	# corner but the start of its text: sharp_px(), the next test, asks this for it.
	var cases: Dictionary[Vector2, Vector2] = {
		Vector2(154.5, 466.5): Vector2(154.0, 466.0), Vector2(345.5, 466.5): Vector2(346.0, 466.0),
		Vector2(190.0, 502.0): Vector2(190.0, 502.0), Vector2(229.5, 349.5): Vector2(230.0, 350.0),
		Vector2(0.0, 0.9): Vector2(0.0, 0.0), Vector2(31.2, 32.9): Vector2(32.0, 32.0),
	}
	for place: Vector2 in cases:
		_check("theme: %s goes to the even pixel %s" % [place, cases[place]], WatchTheme.even_px(place) == cases[place],
				str(WatchTheme.even_px(place)))
	# An odd pixel is as far from the even one below as from the one above: it goes to one of them.
	var odd: Vector2 = WatchTheme.even_px(Vector2(155.0, 467.0))
	_check("theme: an odd pixel goes to an even pixel 1 px away", absf(odd.x - 155.0) == 1.0 and absf(odd.y - 467.0) == 1.0
			and fposmod(odd.x, 2.0) == 0.0 and fposmod(odd.y, 2.0) == 0.0, str(odd))


func _test_sharp_px() -> void:
	# What must be on an even canvas pixel is where the text itself starts: across, the label's own
	# left edge; down, the text's baseline, which is the font's ascent below the label's top
	# (measured 2026-11-27: with the larger text the ascent is 45 px, odd, and strengths placed on
	# an even y were soft top to bottom at 1080p until the baseline was the thing moved).
	# sharp_px(place, rise) moves `place` so that place + rise is on an even pixel.
	var cases: Array[Array] = [
		# A strength at (158, 465) with its baseline 45 px down: 510 is even, it stays.
		[Vector2(158.0, 465.0), Vector2(0.0, 45.0), Vector2(158.0, 465.0)],
		# A section number at (164.5, 222) with its baseline 25 px down: 247 is odd: (164, 223).
		[Vector2(164.5, 222.0), Vector2(0.0, 25.0), Vector2(164.0, 223.0)],
		# A turned end word drawn from (32, 431.5), its baseline 25 px across: 57 is odd: (33, 432).
		[Vector2(32.0, 431.5), Vector2(25.0, 0.0), Vector2(33.0, 432.0)],
		# No rise: the same as even_px().
		[Vector2(154.5, 466.5), Vector2.ZERO, Vector2(154.0, 466.0)],
	]
	for case: Array in cases:
		var got: Vector2 = WatchTheme.sharp_px(case[0], case[1])
		_check("theme: %s with a rise of %s goes to %s" % [case[0], case[1], case[2]], got == case[2], str(got))


func _test_tokens_are_design_md_s_but_for_option_c_s_two_sizes() -> void:
	# DESIGN.md front matter: typography.number 48px / 600 / 0; typography.label 28px / 600 /
	# 0.16em; spacing.2 16px; spacing.safe-margin 48px. Sonlm's M1 (2026-11-27, option C): both
	# sizes were too small on the laptop; the number style is 72 px and the label style 40 px (the
	# size of DESIGN.md's `value`). Weight, spacing in em, the gap and the margin are DESIGN.md's.
	_check("theme: the number style is 72 px at 1080p", WatchTheme.NUMBER_PX == 72.0, str(WatchTheme.NUMBER_PX))
	_check("theme: the label style is 40 px at 1080p", WatchTheme.LABEL_PX == 40.0, str(WatchTheme.LABEL_PX))
	_check("theme: the label's letter spacing is 0.16 em", WatchTheme.LABEL_SPACING_EM == 0.16,
			str(WatchTheme.LABEL_SPACING_EM))
	_check("theme: spacing.2 is 16 px", WatchTheme.SPACING_2_PX == 16.0, str(WatchTheme.SPACING_2_PX))
	_check("theme: the safe margin is 48 px", WatchTheme.SAFE_MARGIN_PX == 48.0, str(WatchTheme.SAFE_MARGIN_PX))
	_check("theme: the weight is 600 (semibold)", WatchTheme.WEIGHT == 600, str(WatchTheme.WEIGHT))


func _test_colours() -> void:
	# DESIGN.md, Colors: world, abyss, ink, ink-bright and muted are its values. Sonlm's M1
	# (2026-11-27, option C): DESIGN.md's plank (#55534f) and rail (#8d8982) were too dim; planks
	# are #8d8982 (muted's value) and standing rails #ddd6c8 (ink-bright's), so a rail is still
	# brighter than a plank. `dim` (#5f5d59) is no longer used on this screen.
	var colours: Dictionary[String, Array] = {
		"world": [WatchTheme.WORLD, "070707"], "abyss": [WatchTheme.ABYSS, "000000"],
		"ink": [WatchTheme.INK, "b9b4aa"], "ink-bright": [WatchTheme.INK_BRIGHT, "ddd6c8"],
		"muted": [WatchTheme.MUTED, "8d8982"], "plank": [WatchTheme.PLANK, "8d8982"],
		"rail": [WatchTheme.RAIL, "ddd6c8"],
	}
	for token: String in colours:
		var colour: Color = colours[token][0]
		_check("theme: %s is #%s" % [token, colours[token][1]], colour.to_html(false) == colours[token][1]
				and colour.a == 1.0, colour.to_html())


func _test_the_two_styles() -> void:
	var theme: Theme = WatchTheme.build()
	_check("theme: WatchNumber and WatchLabel are variations of Label",
			theme.get_type_variation_base(&"WatchNumber") == &"Label"
			and theme.get_type_variation_base(&"WatchLabel") == &"Label")
	# AC 6: two thirds, rounded: of 72 and of 40 since Sonlm's M1 (of 48 and 28 before: 32 and 19).
	_check("theme: the number style is 48 px", theme.get_font_size(&"font_size", &"WatchNumber") == 48,
			str(theme.get_font_size(&"font_size", &"WatchNumber")))
	_check("theme: the label style is 27 px", theme.get_font_size(&"font_size", &"WatchLabel") == 27,
			str(theme.get_font_size(&"font_size", &"WatchLabel")))
	# AC 4: strength in ink-bright. The section number: ink since Sonlm's M1 (muted was too dim).
	_check("theme: the number style is ink-bright (#ddd6c8)",
			theme.get_color(&"font_color", &"WatchNumber").to_html(false) == "ddd6c8")
	_check("theme: the label style is ink (#b9b4aa)",
			theme.get_color(&"font_color", &"WatchLabel").to_html(false) == "b9b4aa")
	_check("theme: the style names are the constants", WatchTheme.NUMBER_STYLE == &"WatchNumber"
			and WatchTheme.LABEL_STYLE == &"WatchLabel")


func _test_the_typeface() -> void:
	var theme: Theme = WatchTheme.build()
	for style: StringName in [&"WatchNumber", &"WatchLabel"]:
		var font: FontVariation = _font_of(theme, style)
		_check("theme: %s has a font variation" % style, font != null)
		if font == null:
			continue
		var base: FontFile = font.base_font as FontFile
		_check("theme: %s is the bundled file" % style, base != null and base.resource_path == FONT_PATH,
				base.resource_path if base != null else "null")
		_check("theme: %s is Cormorant Garamond" % style, base != null
				and base.get_font_name().begins_with("Cormorant Garamond"), base.get_font_name() if base != null else "null")
		# DESIGN.md: semibold for everything but the title; the file's own default is Light 300.
		_check("theme: %s is weight 600" % style, font.variation_opentype.get(_tag("weight"), 0) == 600,
				str(font.variation_opentype))
		# Lining figures in both styles (old-style 1 reads as a small capital I).
		_check("theme: %s has lining figures" % style, font.opentype_features.get(_tag("lnum"), 0) == 1,
				str(font.opentype_features))
	_check("theme: the font file's licence is beside it", FileAccess.file_exists("res://fonts/OFL.txt")
			and FileAccess.file_exists("res://fonts/CREDITS.md"))


func _test_figures_and_spacing() -> void:
	var theme: Theme = WatchTheme.build()
	var number: FontVariation = _font_of(theme, &"WatchNumber")
	var label: FontVariation = _font_of(theme, &"WatchLabel")
	if number == null or label == null:
		_check("theme: both styles have a font", false)
		return
	# DESIGN.md: figures are tabular wherever numbers stack or change (the strength numbers).
	_check("theme: the number style has tabular figures", number.opentype_features.get(_tag("tnum"), 0) == 1,
			str(number.opentype_features))
	var widths: Array[float] = []
	var plain: Array[float] = []
	for digit: int in 10:
		widths.append(number.get_string_size(str(digit), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 48).x)
		plain.append(number.base_font.get_string_size(str(digit), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 48).x)
	_check("theme: all ten digits are the same width in the number style", widths.min() == widths.max()
			and widths.min() > 0.0, str(widths))
	_check("theme: which the file's own figures are not (the features are applied)", plain.min() != plain.max(),
			str(plain))
	# 0.16 em of 40 px, two thirds, rounded: 4 px between glyphs. The number style: 0.
	_check("theme: the label style's letter spacing is 4 px", label.spacing_glyph == 4, str(label.spacing_glyph))
	_check("theme: the number style has none", number.spacing_glyph == 0, str(number.spacing_glyph))
	_check("theme: the label style has no tabular figures (only lining)", not label.opentype_features.has(_tag("tnum")),
			str(label.opentype_features))


func _test_a_styled_label() -> void:
	# The style is set by the theme alone: a label under a control that carries the theme gets its
	# font, size and colour from its variation, with no override. Capitals are the label style's.
	var holder: Control = Control.new()
	holder.theme = WatchTheme.build()
	root.add_child(holder)
	var number: Label = WatchTheme.make_label(WatchTheme.NUMBER_STYLE)
	var label: Label = WatchTheme.make_label(WatchTheme.LABEL_STYLE)
	holder.add_child(number)
	holder.add_child(label)
	number.text = "8"
	number.reset_size()
	label.text = "Far pier"
	label.reset_size()
	_check("theme: a number label carries the WatchNumber variation, not capitals",
			number.theme_type_variation == &"WatchNumber" and not number.uppercase)
	_check("theme: a label label carries the WatchLabel variation, in capitals",
			label.theme_type_variation == &"WatchLabel" and label.uppercase)
	_check("theme: neither has a font, size or colour override", not number.has_theme_font_override(&"font")
			and not number.has_theme_font_size_override(&"font_size") and not number.has_theme_color_override(&"font_color")
			and not label.has_theme_font_override(&"font") and not label.has_theme_font_size_override(&"font_size")
			and not label.has_theme_color_override(&"font_color"))
	_check("theme: under the theme the number label draws at 48 px", number.get_theme_font_size(&"font_size") == 48
			and number.get_theme_color(&"font_color").to_html(false) == "ddd6c8", str(number.get_theme_font_size(&"font_size")))
	_check("theme: and the label label at 27 px", label.get_theme_font_size(&"font_size") == 27
			and label.get_theme_color(&"font_color").to_html(false) == "b9b4aa", str(label.get_theme_font_size(&"font_size")))
	# Measured on the build machine (2026-11-27): one line is 59 px high at 48 px and 33 px at 27 px,
	# and a tabular digit is 24 px wide at 48 px. The read-out's fit is worked out from these
	# (test_planning.gd).
	_check("theme: a one-line number label is 59 px high and one digit 24 px wide",
			number.size.is_equal_approx(Vector2(24.0, 59.0)), str(number.size))
	_check("theme: a one-line label label is 33 px high", is_equal_approx(label.size.y, 33.0), str(label.size))
	# The baseline of each: the font's ascent at its size, 45 px at 48 px and 25 px at 27 px.
	_check("theme: a number label's text rises 45 px above its baseline, a label label's 25 px",
			WatchTheme.text_rise(number) == 45.0 and WatchTheme.text_rise(label) == 25.0,
			"%s %s" % [WatchTheme.text_rise(number), WatchTheme.text_rise(label)])
	root.remove_child(holder)
	holder.free()
