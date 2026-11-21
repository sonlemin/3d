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
		&"walk": ["walk the span and back from the landing (M1 of story 1.3)", ShowSetups.walk],
		&"walk_close": ["the span from mid-span: sections ahead at 5, 4 and 1 planks (M2, DW-31)", ShowSetups.walk_close],
		&"strip": ["strip planks and a rail, re-lay one, read the forearm (M1 of story 1.4)", ShowSetups.strip],
		&"forearm": ["12 planks and 3 ropes in hand; hold Tab on the landing (M2 of story 1.4)", ShowSetups.forearm],
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


## M1 of story 1.3: the whole span can be walked (every section has a plank; crossing a
## plankless one is story 1.6), and it passes the sparse sections up close. From the landing.
static func walk() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = walk_start()
	return def


## M2 of story 1.3 (DW-31): walk's planks, the warden mid section 5 (along 22.5) facing the far
## pier, so the sections ahead at 5 (s4), 4 (s3) and 1 (s2) planks are 2.5 to 17.5 m away.
static func walk_close() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = walk_start()
	def.start.warden_along = 22.5
	return def


## The planks of walk and walk_close: 8, 1, 4, 5, 8 and section 6 full.
static func walk_start() -> StartState:
	var start: StartState = StartState.new()
	start.planks = {1: 8, 2: 1, 3: 4, 4: 5, 5: 8}
	return start


## M1 of story 1.4: a full span, nothing in hand, the warden mid section 5 (along 22.5) facing
## the far pier: strip three planks and a rail, re-lay one, then raise the forearm.
static func strip() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = StartState.new()
	def.start.warden_along = 22.5
	return def


## M2 of story 1.4: 12 planks in hand (section 1 bare, section 2 at 4) and 3 ropes (both rails of
## section 1 and section 2's left), the warden on the landing. 12 reads as two crossed fives and 2.
static func forearm() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = StartState.new()
	def.start.planks = {1: 0, 2: 4}
	def.start.stripped_rails = [Vector2i(1, NightTypes.Side.LEFT), Vector2i(1, NightTypes.Side.RIGHT),
			Vector2i(2, NightTypes.Side.LEFT)]
	return def
