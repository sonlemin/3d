## Show-me setups (AD-56): `--show=<name>` puts Sonlm in exactly the situation a manual check
## needs. One row per setup: a name, what it shows, and the builder of its NightDef.
##     godot --path game -- --show=span_counts
##     godot --path game -- --show=list
class_name ShowSetups
extends RefCounted


## name -> [description, builder () -> NightDef]. A new setup is one more row. `list` is taken:
## `--show=list` lists the setups (a test checks no row uses it).
static func _table() -> Dictionary[StringName, Array]:
	return {
		&"span_counts": ["sections at 8, 5, 4, 1 and 0 planks, seen from the landing", ShowSetups.span_counts],
	}


static func names() -> PackedStringArray:
	return PackedStringArray(_table().keys())


## The setup's night, or null when there is no setup of that name. The night carries the
## setup's name, so NIGHT_STARTED, the trace and the playtest log never show it as a real night.
static func def_of(show_name: StringName) -> NightDef:
	var table: Dictionary[StringName, Array] = _table()
	if not table.has(show_name):
		return null
	var builder: Callable = table[show_name][1]
	var def: NightDef = builder.call()
	def.name = show_name
	return def


## `show: <name>  <description>`, as `--show=list` prints it and tools/ci.sh reads it.
static func list_line(show_name: StringName) -> String:
	return "show: %s  %s" % [show_name, _table()[show_name][0]]


## M1 of story 1.2: from the landing the nearest sections are 8 (s6), 5, 4, 1, 0, 8.
static func span_counts() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = span_counts_start(def.section_count)
	return def


## span_counts' StartState, without the sections a shorter night does not have.
static func span_counts_start(section_count: int) -> StartState:
	var all: Dictionary[int, int] = {1: 8, 2: 0, 3: 1, 4: 4, 5: 5}
	var start: StartState = StartState.new()
	for section: int in all:
		if section <= section_count:
			start.planks[section] = all[section]
	return start
