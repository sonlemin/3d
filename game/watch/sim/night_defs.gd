## The nights there are (AD-9). The only runtime file that writes the span's counts.
class_name NightDefs
extends RefCounted


## The one-night game's night: six sections of eight planks, full (GD-19).
static func one_night() -> NightDef:
	var def: NightDef = NightDef.new()
	def.name = &"one_night"
	def.section_count = 6  # GD-19
	def.planks_per_section = 8  # GD-19
	def.start = StartState.new()
	return def
