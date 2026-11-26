## Show-me setups (AD-56): `--show=<name>` puts Sonlm in exactly the situation a manual check
## needs. One row per setup: a name, what it shows, the builder of its NightDef and, since story
## 1.7, the screen it opens (the night or planning).
##     godot --path game -- --show=span_counts
##     godot --path game -- --show=list
class_name ShowSetups
extends RefCounted


## The screens a setup can open. Main has the same two names (OPEN_NIGHT, OPEN_PLANNING).
const NIGHT: StringName = &"night"
const PLANNING: StringName = &"planning"


## name -> [description, builder () -> NightDef, screen]. A new setup is one more row. `list` is
## taken: `--show=list` lists the setups (a test checks no row uses it).
static func _table() -> Dictionary[StringName, Array]:
	return {
		&"span_counts": ["sections at 8, 5, 4, 1 and 0 planks, seen from the landing", ShowSetups.span_counts, NIGHT],
		&"walk": ["walk the span and back from the landing (M1 of story 1.3)", ShowSetups.walk, NIGHT],
		&"walk_close": ["the span from mid-span: sections ahead at 5, 4 and 1 planks (M2, DW-31)", ShowSetups.walk_close,
				NIGHT],
		&"strip": ["strip planks and a rail, re-lay one, read the forearm (M1 of story 1.4)", ShowSetups.strip, NIGHT],
		&"forearm": ["12 planks and 3 ropes in hand; hold Tab on the landing (M2 of story 1.4)", ShowSetups.forearm, NIGHT],
		&"overload": ["section 4 at 4 planks with 3 weights; strip it from section 5 until it falls (M1 of story 1.5)",
				ShowSetups.overload, NIGHT],
		&"fall_under": ["stand on section 4 (4 planks, 3 weights) and strip it under you (M2 of story 1.5)",
				ShowSetups.fall_under, NIGHT],
		&"gaps": ["section 4 fallen, section 2 open; from section 5, cross the gap and edge round the open section, both ways (M1 of story 1.6)",
				ShowSetups.gaps, NIGHT],
		&"last_plank": ["on section 3 at 1 plank; strip it under you and edge toward the town, then re-lay it (M2 of story 1.6)",
				ShowSetups.last_plank, NIGHT],
		&"readout": ["the overhead read-out: sections at 8, 5, 0, fallen, 1 and 4 planks, section 2's left rail stripped (M1 of story 1.7)",
				ShowSetups.readout, PLANNING],
		&"readout_walk": ["the read-out's span on foot, from the landing (M2 of story 1.7)", ShowSetups.readout_walk, NIGHT],
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


## The screen the setup opens: NIGHT or PLANNING; empty when there is no setup of that name.
static func screen_of(show_name: StringName) -> StringName:
	var table: Dictionary[StringName, Array] = _table()
	return table[show_name][2] if table.has(show_name) else &""


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


## M1 of story 1.3: the whole span can be walked (every section has a plank), and it passes the
## sparse sections up close. From the landing.
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


## M1 of story 1.5: section 4 at 4 planks under 3 test weights (3 < 4: nothing happens until a
## strip), the warden on section 5 at along 20.4, 0.4 m from section 4, facing the far pier. The 4
## planks taken off start in hand.
static func overload() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = StartState.new()
	def.start.planks = {4: 4}
	def.start.weights = {4: 3}
	def.start.warden_along = 20.4
	return def


## M2 of story 1.5: the same section 4, the warden on it at along 19.2, 0.8 m from section 5: inside
## the 1.25 m end strip that weight_box() keeps clear, so they do not stand in a weight; the deck
## 0.6 m ahead (along 18.6) is clear and in reach.
static func fall_under() -> NightDef:
	var def: NightDef = overload()
	def.start.warden_along = 19.2
	return def


## M1 of story 1.6: section 4 fallen (a gap from the start; its parts lost) and section 2 open (its
## 8 planks start in hand), the warden mid section 5 (along 22.5) facing the far pier. Pushing on
## toward the far pier crosses the gap (8 s) onto section 3, then edges round section 2 (4 s) onto
## section 1; and back. Nothing starts a move by itself, so 120 untouched frames see none.
static func gaps() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = StartState.new()
	def.start.planks = {2: 0}
	def.start.fallen = [4]
	def.start.warden_along = 22.5
	return def


## M2 of story 1.6: section 3 at 1 plank (7 in hand), the warden on it at along 11.0, 1 m from
## section 2, facing the far pier: the deck ahead (about along 10.4) is in reach. Stripping it puts
## them on the side beam, edging toward the town (GD-68: 4 m left of 5, 3.2 s) onto section 4; from
## there, a plank re-laid on section 3 makes it walkable again.
static func last_plank() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = StartState.new()
	def.start.planks = {3: 1}
	def.start.warden_along = 11.0
	return def


## M1 of story 1.7, on the planning screen: mixed counts, an open section, a gap and a stripped
## rail, so every mark of the read-out is on screen at once. Strengths read 8, 5, 2, none, 1, 4.
static func readout() -> NightDef:
	var def: NightDef = NightDefs.one_night()
	def.start = readout_start(def.section_count)
	return def


## M2 of story 1.7: readout's span as a night, the warden on the landing, so the read-out can be
## compared with the bridge on foot (left and right included).
static func readout_walk() -> NightDef:
	return readout()


## readout's StartState, without the sections a shorter night does not have: sections 2, 3, 5 and
## 6 at 5, 0, 1 and 4 planks (22 in hand), section 2's left rail stripped (1 rope in hand), section
## 4 fallen (its 8 planks and 2 ropes lost).
static func readout_start(section_count: int) -> StartState:
	var all: Dictionary[int, int] = {2: 5, 3: 0, 5: 1, 6: 4}
	var start: StartState = StartState.new()
	for section: int in all:
		if section <= section_count:
			start.planks[section] = all[section]
	if section_count >= 2:
		start.stripped_rails = [Vector2i(2, NightTypes.Side.LEFT)]
	if section_count >= 4:
		start.fallen = [4]
	return start
