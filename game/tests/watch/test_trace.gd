## The trace (AD-29): every NightEvent as one line, time, kind, who, where. Only line() is
## tested; on_tick() prints it.
extends WatchTest


func _test_night_started_line() -> void:
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	var events: Array[NightEvent] = sim.advance()
	_check("trace: one event on the first tick", events.size() == 1, str(events.size()))
	if events.size() == 1:
		var line: String = NightTrace.line(events[0])
		_check("trace: NIGHT_STARTED prints '  0.000 NIGHT_STARTED     one_night'",
				line == "  0.000 NIGHT_STARTED     one_night", "'%s'" % line)


func _test_time_and_where() -> void:
	var event: NightEvent = NightEvent.make(NightEvent.Kind.NIGHT_STARTED)
	event.t = 12.5
	event.section = 3
	event.id = &"x"
	_check("trace: time is 7 wide with 3 decimals, where is the section",
			NightTrace.line(event) == " 12.500 NIGHT_STARTED     x s3", "'%s'" % NightTrace.line(event))
