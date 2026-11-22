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


# --- Story 1.5: strength, load, creak, groan, fall ---------------------------------------------
# GD-19 and GDD Game Mechanics 2, written out: a section's strength is its planks (0 to 8); a test
# weight is a load of 1 (the epic's AC); load equal to strength (above 0) creaks; above it groans
# for 2 s = 120 ticks, then the section falls for good. GD-19: a strip is 2 s = 120 ticks.

## GD-19, GDD Game Mechanics 2: 2 s at 60 ticks a second.
const GROAN_TICKS: int = 120
## Looking down at the deck ahead (test_hands.gd): lands 0.622 m ahead of the feet.
const DOWN: float = -1.2


## A night of `sections` with `planks` taken off, `weights` and `lifts` placed, the warden at
## `along` (-1: the landing). Nothing is ticked.
func _loaded(planks: Dictionary[int, int], weights: Dictionary[int, int], lifts: Array[Vector2i] = [],
		sections: int = 6, along: float = -1.0) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = planks
	start.weights = weights
	start.lifts = lifts
	start.warden_along = along
	return _sim_with(_def_with(start, sections), 1)


## The events of the next `ticks` ticks but NIGHT_STARTED, each as "tick KIND sN".
func _story(sim: NightSim, ticks: int) -> PackedStringArray:
	var out: PackedStringArray = []
	for i: int in ticks:
		for event: NightEvent in sim.advance():
			if event.kind != NightEvent.Kind.NIGHT_STARTED:
				out.append("%d %s s%d" % [roundi(event.t * 60.0), NightEvent.Kind.find_key(event.kind), event.section])
	return out


func _test_strength_and_load() -> void:
	# AC 1: strength is the planks, load the weights (1 each); both worked out when asked.
	var sim: NightSim = _loaded({3: 5}, {3: 2}, [], 6, 12.5)
	_check("load: strength of a section at 5 planks is 5", SpanRules.strength(3, sim.span) == 5,
			str(SpanRules.strength(3, sim.span)))
	_check("load: strength of a full section is 8", SpanRules.strength(1, sim.span) == 8)
	_check("load: 2 test weights are a load of 2", SpanRules.load_on(3, sim.span) == 2.0, str(SpanRules.load_on(3, sim.span)))
	_check("load: no weight is a load of 0", SpanRules.load_on(1, sim.span) == 0.0)
	_check("load: a creak is load == strength above 0; overload is load above strength",
			SpanRules.creaks(3.0, 3) and not SpanRules.creaks(0.0, 0) and not SpanRules.creaks(2.0, 3)
			and not SpanRules.creaks(4.0, 3) and SpanRules.overloaded(4.0, 3) and SpanRules.overloaded(1.0, 0)
			and not SpanRules.overloaded(3.0, 3) and not SpanRules.overloaded(0.0, 0))
	_check("load: building it reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_creak_starts_and_stops() -> void:
	# AC 2: 3 planks, 3 weights: it creaks from tick 0; a lift on tick 30 (D1) ends it.
	var sim: NightSim = _loaded({4: 3}, {4: 3}, [Vector2i(4, 30)])
	var story: PackedStringArray = _story(sim, 200)
	_check("creak: CREAK_STARTED on tick 0, then on tick 30 the lift and CREAK_STOPPED, nothing else",
			story == PackedStringArray(["0 CREAK_STARTED s4", "30 WEIGHT_LIFTED s4", "30 CREAK_STOPPED s4"]), str(story))
	_check("creak: the weight is gone, the section stands", sim.span.weights(4) == 2 and not sim.span.fallen(4)
			and not sim.span.creaking(4))
	_check("creak: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_groan_then_fall() -> void:
	# AC 3: 3 planks and 4 weights from the start: a groan on tick 0, the fall on tick 120 (t 2.0).
	var sim: NightSim = _loaded({4: 3}, {4: 4})
	var first: Array[NightEvent] = sim.advance()
	_check("groan: tick 0 has NIGHT_STARTED then GROAN_STARTED s4 at t 0.0",
			_kinds(first) == [NightEvent.Kind.NIGHT_STARTED, NightEvent.Kind.GROAN_STARTED]
			and first[1].t == 0.0 and first[1].section == 4, str(_kinds(first)))
	var early: Array[NightEvent] = _advance(sim, GROAN_TICKS - 1)
	_check("groan: nothing on ticks 1 to 119, no fall", early.is_empty() and not sim.span.fallen(4), str(_kinds(early)))
	var fell: Array[NightEvent] = sim.advance()
	_check("groan: SECTION_FELL s4 on tick 120 at t 2.0", _kinds(fell) == [NightEvent.Kind.SECTION_FELL]
			and fell[0].t == 2.0 and fell[0].section == 4, str(_kinds(fell)))
	_check("groan: it has fallen, neither creaking nor groaning", sim.span.fallen(4) and not sim.span.creaking(4)
			and sim.span.groan_left(4) == 0)
	var later: Array[NightEvent] = _advance(sim, 600)
	_check("groan: it stays fallen and nothing more happens", sim.span.fallen(4) and later.is_empty(), str(_kinds(later)))
	_check("groan: no other section fell", not sim.span.fallen(3) and not sim.span.fallen(5))
	_check("groan: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_lift_saves_it() -> void:
	# AC 4 and D1: back to equal (3 on 3) on tick 60: the groan stops and the creak starts that tick.
	var sim: NightSim = _loaded({4: 3}, {4: 4}, [Vector2i(4, 60)])
	var story: PackedStringArray = _story(sim, 400)
	_check("hold: at equal: GROAN_STOPPED and CREAK_STARTED on the lift's tick, no fall",
			story == PackedStringArray(["0 GROAN_STARTED s4", "60 WEIGHT_LIFTED s4", "60 GROAN_STOPPED s4",
			"60 CREAK_STARTED s4"]), str(story))
	_check("hold: it stands, creaking", not sim.span.fallen(4) and sim.span.creaking(4) and sim.span.groan_left(4) == 0)
	# Under (2 on 3): two lifts on tick 60, the groan stops and nothing creaks.
	sim = _loaded({4: 3}, {4: 4}, [Vector2i(4, 60), Vector2i(4, 60)])
	story = _story(sim, 400)
	_check("hold: under: GROAN_STOPPED, no creak, no fall", story == PackedStringArray(["0 GROAN_STARTED s4",
			"60 WEIGHT_LIFTED s4", "60 WEIGHT_LIFTED s4", "60 GROAN_STOPPED s4"]), str(story))
	_check("hold: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_lift_on_the_fall_tick_saves_it() -> void:
	# The fall is decided at step 7 of tick 120; a lift is step 6 of that tick.
	var sim: NightSim = _loaded({4: 3}, {4: 4}, [Vector2i(4, 120)])
	var story: PackedStringArray = _story(sim, 300)
	_check("hold: a lift on tick 120 saves it", story == PackedStringArray(["0 GROAN_STARTED s4",
			"120 WEIGHT_LIFTED s4", "120 GROAN_STOPPED s4", "120 CREAK_STARTED s4"]), str(story))
	# A lift on tick 121 is too late: the weights fell with the section, and the lift does nothing.
	sim = _loaded({4: 3}, {4: 4}, [Vector2i(4, 121)])
	story = _story(sim, 300)
	_check("hold: a lift on tick 121 is too late and lifts nothing",
			story == PackedStringArray(["0 GROAN_STARTED s4", "120 SECTION_FELL s4"]), str(story))
	_check("hold: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_deeper_overload_does_not_restart_the_groan() -> void:
	# 3 planks, 4 weights: the groan from tick 0. The warden on section 5 (along 20.4) begins a strip
	# of section 4 on tick 0 (pressed before the first tick); it completes in step 2 of tick 120
	# (2 on 4), before step 7: the fall is still tick 120.
	var sim: NightSim = _loaded({4: 3}, {4: 4}, [], 6, 20.4)
	sim.set_view(0.0, DOWN)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	var story: PackedStringArray = _story(sim, 200)
	_check("groan: deeper on tick 120 (a strip), and it still falls on tick 120",
			story == PackedStringArray(["0 HOLD_STARTED s4", "0 GROAN_STARTED s4", "120 PLANK_STRIPPED s4",
			"120 SECTION_FELL s4"]), str(story))
	_check("groan: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_an_overload_after_holding_starts_a_fresh_groan() -> void:
	# 3 planks, 4 weights; a lift on tick 60 holds it (3 on 3). A strip begun on tick 61 completes
	# on tick 181 (2 planks under 3): a fresh groan, the fall 120 ticks later, on 301.
	var sim: NightSim = _loaded({4: 3}, {4: 4}, [Vector2i(4, 60)], 6, 20.4)
	sim.set_view(0.0, DOWN)
	var story: PackedStringArray = _story(sim, 61)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	story.append_array(_story(sim, 400))
	_check("groan: a fresh 120 ticks after holding", story == PackedStringArray(["0 GROAN_STARTED s4",
			"60 WEIGHT_LIFTED s4", "60 GROAN_STOPPED s4", "60 CREAK_STARTED s4", "61 HOLD_STARTED s4",
			"181 PLANK_STRIPPED s4", "181 CREAK_STOPPED s4", "181 GROAN_STARTED s4", "301 SECTION_FELL s4"]), str(story))
	_check("groan: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_overload_by_stripping() -> void:
	# AC 7: 4 planks, 3 weights, the warden on section 5 at along 20.4 looking down at section 4.
	# Strip 1 pressed on tick 1 completes on 121 (3 on 3: creak); strip 2 pressed on 122 completes
	# on 242 (3 on 2: the creak stops, the groan starts); the fall on 362.
	var sim: NightSim = _loaded({4: 4}, {4: 3}, [], 6, 20.4)
	sim.set_view(0.0, DOWN)
	var story: PackedStringArray = _story(sim, 1)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	story.append_array(_story(sim, 121))
	sim.command(NightCommand.release(NightTypes.HandInput.HAMMER))
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	story.append_array(_story(sim, 300))
	_check("strip: creak after the first, groan after the second, fall 120 ticks later",
			story == PackedStringArray(["1 HOLD_STARTED s4", "121 PLANK_STRIPPED s4", "121 CREAK_STARTED s4",
			"122 HOLD_STARTED s4", "242 PLANK_STRIPPED s4", "242 CREAK_STOPPED s4", "242 GROAN_STARTED s4",
			"362 SECTION_FELL s4"]), str(story))
	_check("strip: strength followed the planks (AD-35)", SpanRules.strength(4, sim.span) == 0 and sim.span.fallen(4))
	_check("strip: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_town_section_falls_too() -> void:
	# AC 8: the def's last section (6 of 6, 4 of 4) overloaded falls like any other.
	for sections: int in [6, 4]:
		var sim: NightSim = _loaded({sections: 4}, {sections: 5}, [], sections)
		var story: PackedStringArray = _story(sim, 200)
		_check("town: section %d of %d at 4 planks with 5 weights groans and falls on tick 120" % [sections, sections],
				story == PackedStringArray(["0 GROAN_STARTED s%d" % sections, "120 SECTION_FELL s%d" % sections]),
				str(story))
		_check("town: %d sections, no fault" % sections, _faults.total() == 0, str(_faults.codes()))


func _test_no_load_no_creak() -> void:
	# A section with nothing on it is not "at its limit" (decision list): bare or full, no event.
	var sim: NightSim = _loaded({2: 0, 3: 4}, {})
	_check("load: a bare section and a full one with no weight never creak", _story(sim, 600).is_empty())


# --- Story 1.6: an open section's side beams (GDD Game Mechanics 2; decision D4) ---------------
# "Strength = planks left, 0 to 8" and "The side beams carry a load of 2; more than that for 2 s and
# the section falls". D4: as the GDD is written, an open section (no planks, not fallen) has
# strength 2, and a section with planks has its planks.

func _test_open_and_the_side_beams() -> void:
	var sim: NightSim = _loaded({2: 0, 3: 1, 4: 3}, {4: 4})
	_check("open: a section with no planks that stands is open", SpanRules.open(2, sim.span))
	_check("open: one with 1 plank, or full, is not", not SpanRules.open(3, sim.span) and not SpanRules.open(1, sim.span))
	_advance(sim, 121)
	_check("open: a fallen section is not open (GDD: a gap)", sim.span.fallen(4) and sim.span.planks(4) == 0
			and not SpanRules.open(4, sim.span))
	_check("open: an open section's strength is 2 (the side beams)", SpanRules.strength(2, sim.span) == 2,
			str(SpanRules.strength(2, sim.span)))
	_check("open: a section's strength is its planks while it has any (1, 8)", SpanRules.strength(3, sim.span) == 1
			and SpanRules.strength(1, sim.span) == 8)
	_check("open: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_side_beams_carry_2() -> void:
	# AC 3, L4: section 2 open from the start with 1, 2 and 3 test weights (a load of 1 each).
	var sim: NightSim = _loaded({2: 0}, {2: 1})
	var story: PackedStringArray = _story(sim, 600)
	_check("beams: 1 weight on an open section: nothing in 600 ticks", story.is_empty(), str(story))
	sim = _loaded({2: 0}, {2: 2})
	story = _story(sim, 600)
	_check("beams: 2 weights: it creaks from tick 0 and never falls", story == PackedStringArray(["0 CREAK_STARTED s2"])
			and not sim.span.fallen(2), str(story))
	sim = _loaded({2: 0}, {2: 3})
	story = _story(sim, 600)
	_check("beams: 3 weights: it groans from tick 0 and falls on tick 120 (2 s)",
			story == PackedStringArray(["0 GROAN_STARTED s2", "120 SECTION_FELL s2"]) and sim.span.fallen(2), str(story))
	_check("beams: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_last_plank_saves_a_groaning_section() -> void:
	# L5 (D4): section 3 at 1 plank under 2 weights groans from tick 0. The warden on section 4 at
	# along 15.4 (0.4 m from it) strips its last plank: begun on tick 0 (the hammer pressed before it,
	# aimed at section 3's deck about along 14.9), done on tick 120 (GD-19: 2 s), in step 2 of the tick
	# the groan would end in step 7. Open, its strength is 2: the groan stops and it creaks.
	var start: StartState = StartState.new()
	start.planks = {3: 1}
	start.weights = {3: 2}
	start.warden_along = 15.4
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, -atan2(1.6, 0.5))
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	var first: Array[NightEvent] = sim.advance()
	_check("saved: tick 0: HOLD_STARTED s3, NIGHT_STARTED, GROAN_STARTED s3", _kinds(first) == [NightEvent.Kind.HOLD_STARTED,
			NightEvent.Kind.NIGHT_STARTED, NightEvent.Kind.GROAN_STARTED] and first[0].section == 3 and first[2].section == 3,
			str(_kinds(first)))
	var story: PackedStringArray = _story(sim, 599)
	_check("saved: tick 120: the plank goes, the groan stops, it creaks; no fall in 600 ticks",
			story == PackedStringArray(["120 PLANK_STRIPPED s3", "120 GROAN_STOPPED s3", "120 CREAK_STARTED s3"])
			and not sim.span.fallen(3), str(story))
	_check("saved: the warden, 0.4 m away, did not step back (along 15.4)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -14.6)) < 0.001 and WardenRules.walking(sim), str(sim.warden.position))
	_check("saved: no fault", _faults.total() == 0, str(_faults.codes()))


# --- Story 1.6 AC 11: a section can start fallen -----------------------------------------------

func _fallen_start(fallen: Array[int], planks: Dictionary[int, int] = {}, rails: Array[Vector2i] = [],
		weights: Dictionary[int, int] = {}, lifts: Array[Vector2i] = []) -> NightSim:
	var start: StartState = StartState.new()
	start.fallen = fallen
	start.planks = planks
	start.stripped_rails = rails
	start.weights = weights
	start.lifts = lifts
	return _sim_with(_def_with(start), 1)


func _test_a_section_can_start_fallen() -> void:
	var sim: NightSim = _fallen_start([4])
	_check("start fallen: section 4 is a gap from the start", sim.span.fallen(4) and sim.span.planks(4) == 0
			and not sim.span.rail_standing(4, LEFT) and not sim.span.rail_standing(4, RIGHT))
	_check("start fallen: its 8 planks and 2 ropes are lost, none in hand", sim.span.count_at(PLANK, PartPlace.lost()) == 8
			and sim.span.count_at(ROPE, PartPlace.lost()) == 2 and sim.span.in_hand(PLANK) == 0 and sim.span.in_hand(ROPE) == 0)
	_check("start fallen: 48 planks and 12 ropes in all (GD-19)", sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)
	var story: PackedStringArray = _story(sim, 200)
	_check("start fallen: no event of its own, no other section changed", story.is_empty() and sim.span.planks(3) == 8
			and sim.span.planks(5) == 8, str(story))
	_check("start fallen: no fault", _faults.total() == 0, str(_faults.codes()))
	# What planks and stripped_rails take off first is in hand; the rest is lost.
	sim = _fallen_start([2, 5], {2: 3}, [Vector2i(2, RIGHT)])
	_check("start fallen: section 2's 5 taken off are in hand, its other 3 lost, with section 5's 8",
			sim.span.in_hand(PLANK) == 5 and sim.span.count_at(PLANK, PartPlace.lost()) == 11, "%d %d" % [sim.span.in_hand(PLANK),
			sim.span.count_at(PLANK, PartPlace.lost())])
	_check("start fallen: section 2's right rope in hand, its left lost, with both of section 5's",
			sim.span.in_hand(ROPE) == 1 and sim.span.count_at(ROPE, PartPlace.lost()) == 3)
	_check("start fallen: totals still 48 and 12", sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)
	_check("start fallen: no fault", _faults.total() == 0, str(_faults.codes()))
	# A repeat is ignored.
	sim = _fallen_start([3, 3])
	_check("start fallen: a repeat is ignored (8 planks lost, not a fault)", sim.span.fallen(3)
			and sim.span.count_at(PLANK, PartPlace.lost()) == 8 and _faults.total() == 0, str(_faults.codes()))


func _test_a_bad_fallen_start() -> void:
	for bad: int in [0, 7, -1]:
		_expect_begin()
		var sim: NightSim = _fallen_start([bad])
		_expect_end("start fallen: section %d is span.bad_start" % bad, [["ERROR", "span.bad_start", 1]])
		_check("start fallen: section %d skipped, nothing lost" % bad, _faults.count(&"span.bad_start") == 1
				and sim.span.count_at(PLANK, PartPlace.lost()) == 0)
	_expect_begin()
	var sim: NightSim = _fallen_start([4], {}, [], {4: 2, 3: 1})
	_expect_end("start fallen: weights on a section that starts fallen are span.bad_start",
			[["ERROR", "span.bad_start: weights on section 4, which starts fallen", 1]])
	_check("start fallen: those skipped, the others placed", sim.span.weights(4) == 0 and sim.span.weights(3) == 1
			and _faults.count(&"span.bad_start") == 1)
	_expect_begin()
	sim = _fallen_start([4], {}, [], {3: 1}, [Vector2i(4, 10)])
	# (Told by its own message: with the weights skipped the lift would also be "more lifts than weights".)
	_expect_end("start fallen: a lift on a section that starts fallen is span.bad_start",
			[["ERROR", "span.bad_start: lift (4, 10) on section 4, which starts fallen", 1]])
	_check("start fallen: and dropped", sim.span.lifts().is_empty() and _faults.count(&"span.bad_start") == 1,
			str(sim.span.lifts()))


func _test_bad_weights_and_lifts() -> void:
	_expect_begin()
	var sim: NightSim = _loaded({}, {9: 2})
	_expect_end("load: weights on a section outside 1 to 6 are span.bad_start", [["ERROR", "span.bad_start", 1]])
	_check("load: and skipped", sim.span.weights(1) == 0 and _faults.count(&"span.bad_start") == 1)
	_expect_begin()
	sim = _loaded({}, {2: -1})
	_expect_end("load: a negative count of weights is span.bad_start", [["ERROR", "span.bad_start", 1]])
	_check("load: clamped to 0", sim.span.weights(2) == 0, str(sim.span.weights(2)))
	_expect_begin()
	sim = _loaded({}, {2: 1}, [Vector2i(9, 5), Vector2i(2, -1)])
	_expect_end("load: a lift on a bad section or before tick 0 is span.bad_start", [["ERROR", "span.bad_start", 1]])
	_check("load: both counted and dropped", _faults.count(&"span.bad_start") == 2 and sim.span.lifts().is_empty(),
			str(sim.span.lifts()))
	_expect_begin()
	sim = _loaded({}, {2: 1}, [Vector2i(2, 10), Vector2i(2, 20)])
	_expect_end("load: more lifts on a section than its weights is span.bad_start", [["ERROR", "span.bad_start", 1]])
	var story: PackedStringArray = _story(sim, 30)
	_check("load: the extra lift is dropped: one lift, on tick 10", _faults.count(&"span.bad_start") == 1
			and story == PackedStringArray(["10 WEIGHT_LIFTED s2"]) and sim.span.weights(2) == 0, str(story))


func _test_span_state_values() -> void:
	# The checksum's span facts: each one changes values() (a SpanState of its own, not a sim's).
	var faults: WatchFaults = WatchFaults.new()
	var base: Array = SpanState.new(6, 8, faults).values()
	var changes: Dictionary[String, Callable] = {
		"fallen": func(s: SpanState) -> void: s.set_fallen(3),
		"creaking": func(s: SpanState) -> void: s.set_creaking(3, true),
		"groan left": func(s: SpanState) -> void: s.set_groan_left(3, 7),
		"weights": func(s: SpanState) -> void: s.add_weights(3, 1),
		"a lift": func(s: SpanState) -> void: s.add_lift(Vector2i(3, 9)),
	}
	for what: String in changes:
		var span: SpanState = SpanState.new(6, 8, faults)
		changes[what].call(span)
		_check("load: %s changes the span's values()" % what, span.values() != base)
	_check("load: no fault", faults.total() == 0, str(faults.codes()))
