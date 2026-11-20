## The span's counts and the parts ledger (GD-19, GD-54, AD-35, Novel Pattern 1). Spec values
## are written literally, with the GDD value in a comment; never read from the constants.
extends WatchTest

const LEFT: int = NightTypes.Side.LEFT
const RIGHT: int = NightTypes.Side.RIGHT
const PLANK: NightTypes.Part = NightTypes.Part.PLANK
const ROPE: NightTypes.Part = NightTypes.Part.ROPE

## Decision D1: the kept places per count, 1 to 8 from the far-pier end.
const KEPT: Dictionary[int, Array] = {
	8: [1, 2, 3, 4, 5, 6, 7, 8],
	7: [1, 2, 4, 5, 6, 7, 8],
	6: [1, 2, 4, 5, 6, 8],
	5: [1, 2, 4, 6, 8],
	4: [2, 4, 6, 8],
	3: [2, 4, 6],
	2: [4, 6],
	1: [4],
	0: [],
}


func _test_one_night_counts() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var span: SpanState = sim.span
	# GD-19: 6 sections, each 5 m x 5 m, 30 m; 8 planks and 2 rail ropes per section.
	_check("span: the one night has 6 sections", span.section_count() == 6, str(span.section_count()))
	_check("span: a section is 5 m long", SpanConstants.SECTION_LENGTH == 5.0)
	_check("span: a section is 5 m wide", SpanConstants.SECTION_WIDTH == 5.0)
	_check("span: the span is 30 m", sim.geometry.length() == 30.0, str(sim.geometry.length()))
	var all_full: bool = true
	for n: int in range(1, 7):
		all_full = all_full and span.planks(n) == 8 and span.rail_standing(n, LEFT) and span.rail_standing(n, RIGHT)
	_check("span: every section has 8 planks and 2 rail ropes", all_full)
	_check("span: 48 planks and 12 ropes in all", span.total(PLANK) == 48 and span.total(ROPE) == 12,
			"%d %d" % [span.total(PLANK), span.total(ROPE)])
	_check("span: the warden holds none", span.in_hand(PLANK) == 0 and span.in_hand(ROPE) == 0)
	_check("span: building the one night reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_leave_order() -> void:
	# D1 / GD-54: one fixed leaving order.
	_check("span: PLANK_LEAVE_ORDER is 3 7 5 1 8 2 6 4",
			SpanGeometry.PLANK_LEAVE_ORDER == [3, 7, 5, 1, 8, 2, 6, 4], str(SpanGeometry.PLANK_LEAVE_ORDER))
	var geometry: SpanGeometry = _sim_with(NightDefs.one_night(), 1).geometry
	for count: int in range(8, -1, -1):
		var kept: Array[int] = geometry.places_kept(count)
		_check("span: %d planks keep places %s" % [count, KEPT[count]], kept == KEPT[count], str(kept))


func _test_plank_places_follow_the_table() -> void:
	var geometry: SpanGeometry = _sim_with(NightDefs.one_night(), 1).geometry
	var ok: bool = true
	var detail: String = ""
	for section: int in range(1, 7):
		var start: float = (section - 1) * 5.0  # GD-19: 5 m sections
		for count: int in range(8, -1, -1):
			var places: Array[Vector3] = geometry.plank_places(section, count)
			var want: Array = KEPT[count]
			if places.size() != want.size():
				ok = false
				detail = "s%d count %d: %d places" % [section, count, places.size()]
				continue
			for i: int in want.size():
				# Place p's centre: along = start + (p - 0.5) x 0.625 (5 m / 8).
				var along: float = start + (int(want[i]) - 0.5) * 0.625
				var z: float = along - 30.0
				if not places[i].is_equal_approx(Vector3(0.0, -0.04, z)):
					ok = false
					detail = "s%d count %d place %d at %s" % [section, count, want[i], places[i]]
	_check("span: plank_places gives the table's places in every section (only the offset differs)", ok, detail)


func _test_planks_leave_one_at_a_time_in_order() -> void:
	# AC 4: from 8 down to 0, the plank that leaves is the next entry of the order.
	var geometry: SpanGeometry = _sim_with(NightDefs.one_night(), 1).geometry
	var order: Array[int] = []
	for count: int in range(8, 0, -1):
		var before: Array[int] = geometry.places_kept(count)
		var after: Array[int] = geometry.places_kept(count - 1)
		for place: int in before:
			if not after.has(place):
				order.append(place)
	_check("span: stripping 8 to 0 takes places 3 7 5 1 8 2 6 4", order == [3, 7, 5, 1, 8, 2, 6, 4], str(order))


func _test_start_state_planks_go_to_hand() -> void:
	var start: StartState = StartState.new()
	start.planks = {3: 5}
	var sim: NightSim = _sim_with(_def_with(start), 1)
	_check("span: section 3 starts at 5 planks", sim.span.planks(3) == 5, str(sim.span.planks(3)))
	_check("span: the 3 planks taken are in hand", sim.span.in_hand(PLANK) == 3, str(sim.span.in_hand(PLANK)))
	_check("span: totals stay 48 and 12", sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)
	_check("span: a good StartState reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_start_state_rail_goes_to_hand() -> void:
	var start: StartState = StartState.new()
	start.stripped_rails = [Vector2i(2, LEFT)]
	var sim: NightSim = _sim_with(_def_with(start), 1)
	_check("span: the stripped rail is down", not sim.span.rail_standing(2, LEFT) and sim.span.rail_standing(2, RIGHT))
	_check("span: its rope is in hand", sim.span.in_hand(ROPE) == 1, str(sim.span.in_hand(ROPE)))
	_check("span: totals stay 48 and 12 with a stripped rail",
			sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)


func _test_bad_start_state() -> void:
	var start: StartState = StartState.new()
	start.planks = {9: 2}
	_expect_begin()
	var sim: NightSim = _sim_with(_def_with(start), 1)
	_expect_end("span: a section outside 1 to 6 is span.bad_start", [["ERROR", "span.bad_start", 1]])
	_check("span: the night goes on, full", sim.span.total(PLANK) == 48 and sim.span.in_hand(PLANK) == 0)
	start = StartState.new()
	start.planks = {2: 11}
	_expect_begin()
	sim = _sim_with(_def_with(start), 1)
	_expect_end("span: more planks than a section holds is span.bad_start", [["ERROR", "span.bad_start", 1]])
	_check("span: clamped to 8", sim.span.planks(2) == 8, str(sim.span.planks(2)))


func _test_move_parts_short() -> void:
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	_expect_begin()
	SpanRules.move_parts(PLANK, 11, PartPlace.deck(4), PartPlace.hand(), sim)
	_expect_end("span: moving 11 from an 8-plank deck reports span.parts_short", [["ERROR", "span.parts_short", 1]])
	_check("span: what there was (8) moved", sim.span.planks(4) == 0 and sim.span.in_hand(PLANK) == 8)
	_check("span: totals stay 48 after a short move", sim.span.total(PLANK) == 48)


func _test_move_parts_negative_count() -> void:
	# A negative count would run the move backwards with the totals intact: a fault, nothing moves.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	_expect_begin()
	SpanRules.move_parts(PLANK, -3, PartPlace.deck(1), PartPlace.hand(), sim)
	_expect_end("span: a negative count is span.bad_count", [["ERROR", "span.bad_count", 1]])
	_check("span: nothing moved", sim.span.planks(1) == 8 and sim.span.in_hand(PLANK) == 0,
			"%d %d" % [sim.span.planks(1), sim.span.in_hand(PLANK)])


func _test_move_parts_no_room() -> void:
	# A deck holds at most the planks per section and a rail one rope: what fits moves.
	var start: StartState = StartState.new()
	start.planks = {2: 5, 3: 0}
	start.stripped_rails = [Vector2i(4, LEFT)]
	var sim: NightSim = _sim_with(_def_with(start), 1)
	_check("span: 11 planks and 1 rope in hand to begin", sim.span.in_hand(PLANK) == 11 and sim.span.in_hand(ROPE) == 1)
	_expect_begin()
	SpanRules.move_parts(PLANK, 5, PartPlace.hand(), PartPlace.deck(2), sim)
	SpanRules.move_parts(ROPE, 1, PartPlace.hand(), PartPlace.rail(1, LEFT), sim)
	_expect_end("span: more than a deck or a rail has room for is span.no_room", [["ERROR", "span.no_room", 1]])
	_check("span: both were counted", _faults.count(&"span.no_room") == 2, str(_faults.count(&"span.no_room")))
	_check("span: 3 planks moved, the deck is full and 8 stay in hand",
			sim.span.planks(2) == 8 and sim.span.in_hand(PLANK) == 8, "%d %d" % [sim.span.planks(2), sim.span.in_hand(PLANK)])
	_check("span: the rope stays in hand and the rail holds one rope",
			sim.span.in_hand(ROPE) == 1 and sim.span.count_at(ROPE, PartPlace.rail(1, LEFT)) == 1)
	SpanRules.move_parts(ROPE, 1, PartPlace.hand(), PartPlace.rail(4, LEFT), sim)
	SpanRules.move_parts(PLANK, 8, PartPlace.hand(), PartPlace.deck(3), sim)
	_check("span: moves that fit add no fault", _faults.total() == 2, str(_faults.codes()))
	_check("span: and land: rail 4 up, deck 3 full, hand empty", sim.span.rail_standing(4, LEFT)
			and sim.span.planks(3) == 8 and sim.span.in_hand(PLANK) == 0 and sim.span.in_hand(ROPE) == 0)
	_check("span: totals stay 48 and 12", sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)


func _test_move_parts_bad_place() -> void:
	# A plank on a rail or a rope on a deck is a fault, not a crash, and nothing moves.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	_expect_begin()
	SpanRules.move_parts(PLANK, 1, PartPlace.deck(1), PartPlace.rail(1, LEFT), sim)
	_expect_end("span: a plank onto a rail is span.bad_place", [["ERROR", "span.bad_place", 1]])
	_check("span: nothing moved", sim.span.planks(1) == 8 and sim.span.total(PLANK) == 48)


func _test_part_place_labels() -> void:
	_check("span: place labels for faults and the trace",
			PartPlace.deck(3).label() == "s3 deck" and PartPlace.rail(3, LEFT).label() == "s3 L rail"
			and PartPlace.rail(2, RIGHT).label() == "s2 R rail" and PartPlace.hand().label() == "hand"
			and PartPlace.lost().label() == "lost")


func _test_only_the_ledger_writes_counts() -> void:
	# Novel Pattern 1: add_at( appears only in span_rules.gd and span_state.gd.
	var found: PackedStringArray = []
	for path: String in _gd_files("res://watch"):
		var text: String = FileAccess.get_file_as_string(path)
		if text.contains("add_at("):
			found.append(path.get_file())
	found.sort()
	_check("span: add_at( only in span_rules.gd and span_state.gd",
			found == PackedStringArray(["span_rules.gd", "span_state.gd"]), str(found))


func _gd_files(dir: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(dir):
		if file_name.ends_with(".gd"):
			out.append(dir.path_join(file_name))
	for sub: String in DirAccess.get_directories_at(dir):
		out.append_array(_gd_files(dir.path_join(sub)))
	return out
