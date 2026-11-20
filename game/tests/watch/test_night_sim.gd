## NightSim and its tick (AD-33, AD-34, AD-37, AD-30): one tick per advance(), the 13 steps in
## order, typed events, the same seed and inputs giving the same events and checksum.
extends WatchTest

## AD-34, written literally.
const STEPS: Array[StringName] = [
	&"_step_inputs", &"_step_holds", &"_step_rigs", &"_step_consequences_of_actions", &"_step_clock",
	&"_step_dead", &"_step_loads", &"_step_consequences_of_loads", &"_step_crossings_and_windows",
	&"_step_lanterns", &"_step_wounds_and_name", &"_step_voices_and_ally", &"_step_ending",
]
## The fields of NightEvent (AD-30) and their defaults.
const FIELD_DEFAULTS: Dictionary[String, Variant] = {
	"t": 0.0, "section": 0, "side": NightTypes.Side.LEFT, "along": 0.0, "level": -1, "dead_id": 0,
	"dead_kind": -1, "slot": 0, "sound": &"", "reason": -1, "amount": 0.0, "id": &"",
}


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


static func _event_text(event: NightEvent) -> String:
	var parts: PackedStringArray = [str(event.kind)]
	for field: String in FIELD_DEFAULTS:
		parts.append(str(event.get(field)))
	return ",".join(parts)


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
	_check("sim: NIGHT_STARTED names t and id", named.get("NIGHT_STARTED", PackedStringArray()) == PackedStringArray(["t", "id"]),
			str(named.get("NIGHT_STARTED")))
	for kind_name: String in named:
		for field: String in named[kind_name]:
			_check("sim: %s names a real field '%s'" % [kind_name, field], FIELD_DEFAULTS.has(field))
	# Every event the sim emits sets only the fields its kind names.
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var bad: PackedStringArray = []
	for event: NightEvent in _advance(sim, 60):
		var kind_name: String = NightEvent.Kind.find_key(event.kind)
		for field: String in FIELD_DEFAULTS:
			if field == "t" or named.get(kind_name, PackedStringArray()).has(field):
				continue
			if event.get(field) != FIELD_DEFAULTS[field]:
				bad.append("%s sets %s" % [kind_name, field])
	_check("sim: no event sets a field its kind does not name", bad.is_empty(), str(bad))


## Kind name -> the fields of its "Fields: a, b." comment, read from the source.
func _fields_per_kind() -> Dictionary[String, PackedStringArray]:
	var source: String = FileAccess.get_file_as_string("res://watch/sim/night_event.gd")
	var out: Dictionary[String, PackedStringArray] = {}
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
		var kind_name: String = code.get_slice(",", 0).strip_edges()
		var list: String = code.get_slice("Fields:", 1).get_slice(".", 0)
		var fields: PackedStringArray = []
		for field: String in list.split(","):
			fields.append(field.strip_edges())
		out[kind_name] = fields
	return out
