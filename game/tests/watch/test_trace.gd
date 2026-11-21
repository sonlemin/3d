## The trace (AD-29): every NightEvent as one line, time, kind, who, where. Only line() is
## tested; on_tick() prints it.
extends WatchTest


func _test_night_started_line() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var events: Array[NightEvent] = sim.advance()
	_check("trace: one event on the first tick", events.size() == 1, str(events.size()))
	if events.size() == 1:
		var line: String = NightTrace.line(events[0])
		_check("trace: NIGHT_STARTED prints '  0.000 NIGHT_STARTED     one_night seed=1'",
				line == "  0.000 NIGHT_STARTED     one_night seed=1", "'%s'" % line)


func _test_time_and_where() -> void:
	var event: NightEvent = NightEvent.make(NightEvent.Kind.NIGHT_STARTED)
	event.t = 12.5
	event.section = 3
	event.id = &"x"
	event.seed = 7
	_check("trace: time is 7 wide with 3 decimals, where is the section",
			NightTrace.line(event) == " 12.500 NIGHT_STARTED     x seed=7 s3", "'%s'" % NightTrace.line(event))


func _event(kind: NightEvent.Kind, t: float, section: int, id: StringName = &"",
		side: NightTypes.Side = NightTypes.Side.LEFT) -> NightEvent:
	var event: NightEvent = NightEvent.make(kind)
	event.t = t
	event.section = section
	event.id = id
	event.side = side
	return event


func _test_hand_lines() -> void:
	# DW-28: who is `warden` for the hands' kinds, then the action; where carries the side for a
	# rail. Story 1.4 Dev Notes, "Trace".
	var right: NightTypes.Side = NightTypes.Side.RIGHT
	var cases: Array[Array] = [
		[_event(NightEvent.Kind.PLANK_STRIPPED, 4.0, 3), "  4.000 PLANK_STRIPPED    warden s3"],
		[_event(NightEvent.Kind.RAIL_STRIPPED, 7.0, 5), "  7.000 RAIL_STRIPPED     warden s5 L"],
		[_event(NightEvent.Kind.RAIL_STRIPPED, 7.0, 5, &"", right), "  7.000 RAIL_STRIPPED     warden s5 R"],
		[_event(NightEvent.Kind.PLANK_RELAID, 9.5, 1), "  9.500 PLANK_RELAID      warden s1"],
		[_event(NightEvent.Kind.HOLD_STARTED, 1.0, 4, &"strip_plank"), "  1.000 HOLD_STARTED      warden strip_plank s4"],
		[_event(NightEvent.Kind.HOLD_STARTED, 1.0, 4, &"strip_rail", right),
				"  1.000 HOLD_STARTED      warden strip_rail s4 R"],
		[_event(NightEvent.Kind.HOLD_CANCELLED, 2.0, 2, &"relay_plank"),
				"  2.000 HOLD_CANCELLED    warden relay_plank s2"],
	]
	for case: Array in cases:
		var got: String = NightTrace.line(case[0])
		_check("trace: '%s'" % case[1], got == case[1], "'%s'" % got)
	var refused: NightEvent = _event(NightEvent.Kind.REFUSED, 9.0, 6, &"strip_plank")
	refused.reason = NightTypes.Reason.LAST_SECTION_MINIMUM
	_check("trace: a refusal names the action, the section and the reason",
			NightTrace.line(refused) == "  9.000 REFUSED           warden strip_plank s6 LAST_SECTION_MINIMUM",
			"'%s'" % NightTrace.line(refused))
	var nothing: NightEvent = _event(NightEvent.Kind.REFUSED, 0.5, 0)
	nothing.reason = NightTypes.Reason.NO_ACTION_HERE
	_check("trace: a refusal with no action has no section",
			NightTrace.line(nothing) == "  0.500 REFUSED           warden NO_ACTION_HERE", "'%s'" % NightTrace.line(nothing))
	# Every kind name fits the 17-wide column (the longest today is 14).
	var widest: int = 0
	for kind_name: String in NightEvent.Kind.keys():
		widest = maxi(widest, kind_name.length())
	_check("trace: every kind fits the 17 column", widest <= 17, str(widest))


func _test_traced_strip() -> void:
	# A real strip through the sim, traced: section 4 from along 17.5 (GD-19: 2 s = 120 ticks).
	var start: StartState = StartState.new()
	start.warden_along = 17.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, -1.2)
	sim.advance()
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	var lines: PackedStringArray = []
	for event: NightEvent in _advance(sim, 121):
		lines.append(NightTrace.line(event))
	_check("trace: a strip traced as begun on tick 1 and done on tick 121", lines == PackedStringArray([
			"  0.017 HOLD_STARTED      warden strip_plank s4", "  2.017 PLANK_STRIPPED    warden s4"]), str(lines))
