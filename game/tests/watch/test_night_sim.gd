## NightSim and its tick (AD-33, AD-34, AD-37, AD-30): one tick per advance(), the 13 steps in
## order, typed events, the same seed and inputs giving the same events and checksum.
extends WatchTest

## AD-34, written literally.
const STEPS: Array[StringName] = [
	&"_step_inputs", &"_step_holds", &"_step_rigs", &"_step_consequences_of_actions", &"_step_clock",
	&"_step_dead", &"_step_loads", &"_step_consequences_of_loads", &"_step_crossings_and_windows",
	&"_step_lanterns", &"_step_wounds_and_name", &"_step_voices_and_ally", &"_step_ending",
]
## The fields of NightEvent (AD-30, plus `seed` for AD-3), written literally: a field added to
## the class has to be added here, and so to the architecture's list.
const FIELDS: PackedStringArray = [
	"t", "section", "side", "along", "level", "dead_id", "dead_kind", "slot", "sound", "reason",
	"amount", "id", "seed",
]


func _test_advance_moves_one_tick() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	_check("sim: tick starts at 0", sim.tick == 0, str(sim.tick))
	sim.advance()
	_check("sim: advance() moves exactly one tick", sim.tick == 1, str(sim.tick))
	_advance(sim, 9)
	_check("sim: ten calls, tick 10", sim.tick == 10, str(sim.tick))


func _test_thirteen_steps_in_order() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var names: Array = sim._steps.map(func(c: Callable) -> StringName: return c.get_method())
	_check("sim: the 13 steps of AD-34 in order", names == STEPS, str(names))


func _test_night_started() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var first: Array[NightEvent] = sim.advance()
	_check("sim: the first tick emits exactly NIGHT_STARTED", _kinds(first) == [NightEvent.Kind.NIGHT_STARTED],
			str(_kinds(first)))
	if first.size() == 1:
		_check("sim: NIGHT_STARTED at t 0.0 with the def's name", first[0].t == 0.0 and first[0].id == &"one_night",
				"%f %s" % [first[0].t, first[0].id])
		_check("sim: NIGHT_STARTED carries the night's seed (AD-3)", first[0].seed == 1, str(first[0].seed))
	var other: NightSim = _sim_with(NightDefs.one_night(), 4242)
	var first_other: Array[NightEvent] = other.advance()
	_check("sim: and another seed is carried as itself", first_other.size() == 1 and first_other[0].seed == 4242)
	var later: Array[NightEvent] = _advance(sim, 599)
	_check("sim: NIGHT_STARTED never again", not _has(later, NightEvent.Kind.NIGHT_STARTED))


## The same inputs, fed tick by tick.
func _drive(sim: NightSim, ticks: int) -> Array[NightEvent]:
	var all: Array[NightEvent] = []
	for i: int in ticks:
		sim.set_move(Vector2.from_angle(i * 0.1) * (0.5 + 0.5 * sin(i * 0.07)))
		sim.set_view(i * 0.01, -0.2)
		if i % 50 == 0:
			sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
		if i % 50 == 20:
			sim.command(NightCommand.release(NightTypes.HandInput.HAMMER))
		all.append_array(sim.advance())
	return all


func _test_same_seed_same_night() -> void:
	var a: NightSim = _sim_with(NightDefs.one_night(), 7)
	var events_a: Array[NightEvent] = _drive(a, 600)
	var b: NightSim = _sim_with(NightDefs.one_night(), 7)
	var events_b: Array[NightEvent] = _drive(b, 600)
	_check("sim: same seed and inputs, same events (every field)",
			events_a.map(_event_text) == events_b.map(_event_text) and not events_a.is_empty())
	_check("sim: same seed and inputs, same checksum after 600 ticks", a.checksum() == b.checksum())
	var c: NightSim = _sim_with(NightDefs.one_night(), 8)
	_check("sim: a different seed gives a different rng state", c.rng.state != a.rng.state)


func _test_other_inputs_other_checksum() -> void:
	# DW-26: the warden walks, so the inputs reach the checksum. Toward the far pier at full and
	# at half speed for 600 ticks ends at two different places (along 0.3 and 14.5).
	var a: NightSim = _sim_with(NightDefs.one_night(), 7)
	var b: NightSim = _sim_with(NightDefs.one_night(), 7)
	for i: int in 600:
		a.set_move(Vector2(0.0, -1.0))
		b.set_move(Vector2(0.0, -0.5))
		a.advance()
		b.advance()
	_check("sim: same seed, different move wishes, different checksums", a.checksum() != b.checksum())
	var c: NightSim = _sim_with(NightDefs.one_night(), 7)
	for i: int in 600:
		c.set_move(Vector2(0.0, -1.0))
		c.advance()
	_check("sim: and the same wishes again give the same checksum", a.checksum() == c.checksum())


func _test_inputs_are_taken_in_step_1() -> void:
	# AD-34 step 1: the wish, the view and the commands set before a tick are that tick's.
	var sim: NightSim = _sim_with(NightDefs.one_night(), 3)
	sim.set_move(Vector2(0.6, -0.3))
	sim.set_view(0.75, -0.25)
	var first: NightCommand = NightCommand.press(NightTypes.HandInput.USE)
	var second: NightCommand = NightCommand.release(NightTypes.HandInput.USE)
	var third: NightCommand = NightCommand.press(NightTypes.HandInput.HAMMER)
	sim.command(first)
	sim.command(second)
	sim.command(third)
	_check("sim: nothing is taken before the tick",
			sim.move_wish == Vector2.ZERO and sim.yaw == 0.0 and sim.pitch == 0.0 and sim.commands.is_empty())
	sim.advance()
	_check("sim: the tick takes the move wish", sim.move_wish.is_equal_approx(Vector2(0.6, -0.3)), str(sim.move_wish))
	_check("sim: the tick takes yaw and pitch, each as itself",
			is_equal_approx(sim.yaw, 0.75) and is_equal_approx(sim.pitch, -0.25), "%f %f" % [sim.yaw, sim.pitch])
	_check("sim: the tick takes the commands in arrival order",
			sim.commands.size() == 3 and sim.commands[0] == first and sim.commands[1] == second
			and sim.commands[2] == third, str(sim.commands.size()))
	sim.advance()
	_check("sim: the next tick has no command left, and the wish and view stand",
			sim.commands.is_empty() and sim.move_wish.is_equal_approx(Vector2(0.6, -0.3)) and is_equal_approx(sim.yaw, 0.75))
	_check("sim: taking inputs reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_bad_inputs_are_faults() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 3)
	sim.set_move(Vector2(0.5, 0.0))
	sim.set_view(0.4, 0.1)
	sim.advance()
	_expect_begin()
	sim.set_move(Vector2(NAN, 0.0))
	sim.set_move(Vector2(INF, 0.0))
	sim.set_view(NAN, 0.0)
	sim.set_view(0.0, INF)
	sim.command(null)
	_expect_end("sim: a wish or view that is not finite, and a null command, are sim.bad_input",
			[["ERROR", "sim.bad_input", 1]])
	_check("sim: all five were counted", _faults.count(&"sim.bad_input") == 5, str(_faults.count(&"sim.bad_input")))
	sim.advance()
	_check("sim: a wish that is not finite counts as standing still", sim.move_wish == Vector2.ZERO, str(sim.move_wish))
	_check("sim: a view that is not finite leaves the last view",
			is_equal_approx(sim.yaw, 0.4) and is_equal_approx(sim.pitch, 0.1), "%f %f" % [sim.yaw, sim.pitch])
	_check("sim: a null command is not queued", sim.commands.is_empty(), str(sim.commands.size()))


func _test_bad_def() -> void:
	var def: NightDef = _def_with(StartState.new(), 0)
	_expect_begin()
	var sim: NightSim = _sim_with(def, 1)
	_expect_end("sim: a night with no section is sim.bad_def", [["ERROR", "sim.bad_def", 1]])
	_check("sim: and gets one section", sim.span.section_count() == 1 and sim.geometry.length() > 0.0,
			"%d %f" % [sim.span.section_count(), sim.geometry.length()])
	def = _def_with(StartState.new(), -2)
	_expect_begin()
	sim = _sim_with(def, 1)
	_expect_end("sim: a negative section count is sim.bad_def too", [["ERROR", "sim.bad_def", 1]])
	_check("sim: and also gets one section", sim.span.section_count() == 1, str(sim.span.section_count()))


func _test_quiet_night_has_no_fault() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 3)
	_advance(sim, 600)
	_check("sim: 600 ticks of nothing, no fault", _faults.total() == 0, str(_faults.codes()))


func _test_move_too_long() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 3)
	_expect_begin()
	sim.set_move(Vector2(3.0, 4.0))
	_expect_end("sim: a move wish longer than 1 is sim.move_too_long", [["ERROR", "sim.move_too_long", 1]])
	sim.advance()
	_check("sim: the wish is clamped to length 1", is_equal_approx(sim.move_wish.length(), 1.0), str(sim.move_wish))


func _test_event_fields_match_comments() -> void:
	# Architecture, Event System: each kind's ## comment lists the fields it sets.
	var named: Dictionary[String, PackedStringArray] = _fields_per_kind()
	_check("sim: every NightEvent kind has a Fields: comment", named.size() == NightEvent.Kind.size(), str(named))
	_check("sim: every Fields: comment belongs to a real kind",
			Array(named.keys()).all(func(n: String) -> bool: return NightEvent.Kind.has(n)), str(named.keys()))
	_check("sim: NIGHT_STARTED names t, id and seed",
			named.get("NIGHT_STARTED", PackedStringArray()) == PackedStringArray(["t", "id", "seed"]),
			str(named.get("NIGHT_STARTED")))
	# The class's own fields, so one added to NightEvent cannot be missed below.
	var fields: PackedStringArray = _event_fields()
	_check("sim: NightEvent has exactly the fields of AD-30 and the seed", fields == FIELDS, str(fields))
	for kind_name: String in named:
		for field: String in named[kind_name]:
			_check("sim: %s names a real field '%s'" % [kind_name, field], fields.has(field))
	# Every event the sim emits sets only the fields its kind names.
	# The other direction (a named field left unset) cannot be told from a value: a set field
	# may hold its default (side LEFT, seed 0). Each kind's own test checks the fields it sets.
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var unset: NightEvent = NightEvent.new()
	var bad: PackedStringArray = []
	for event: NightEvent in _drive(sim, 600):
		var kind_name: String = NightEvent.Kind.find_key(event.kind)
		for field: String in fields:
			if field == "t" or named.get(kind_name, PackedStringArray()).has(field):
				continue
			if event.get(field) != unset.get(field):
				bad.append("%s sets %s" % [kind_name, field])
	_check("sim: no event sets a field its kind does not name", bad.is_empty(), str(bad))


## Kind name -> the fields of its "Fields: a, b." comment, read from the source. The name is
## the line's leading identifier, so `NAME = 3,` and a last entry without a comma both read right.
func _fields_per_kind() -> Dictionary[String, PackedStringArray]:
	var source: String = FileAccess.get_file_as_string("res://watch/sim/night_event.gd")
	var out: Dictionary[String, PackedStringArray] = {}
	var leading_name: RegEx = RegEx.create_from_string("^[A-Za-z_][A-Za-z0-9_]*")
	var in_kind: bool = false
	for line: String in source.split("\n"):
		var code: String = line.strip_edges()
		if code.begins_with("enum Kind"):
			in_kind = true
			continue
		if in_kind and code.begins_with("}"):
			break
		if not in_kind or not code.contains("Fields:"):
			continue
		var found: RegExMatch = leading_name.search(code)
		var kind_name: String = found.get_string() if found != null else code
		var list: String = code.get_slice("Fields:", 1).get_slice(".", 0)
		var fields: PackedStringArray = []
		for field: String in list.split(","):
			fields.append(field.strip_edges())
		out[kind_name] = fields
	return out
