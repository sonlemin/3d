## Bot nights (AD-63): every bot path over many seeds, on the one night and on a 4-section
## night, checking on every tick that parts are conserved and nothing faults; one seed run twice
## gives the same events and checksum; and every NightEvent kind is produced by some path (the
## event-coverage check; NightTypes.Reason joins it in story 1.4).
extends WatchTest

## Kinds seen over every path and seed.
var _seen: Dictionary[NightEvent.Kind, bool] = {}
## Problems found on any tick, first few kept.
var _broken: PackedStringArray = []
## The totals a tick must show: 48 planks and 12 ropes on 6 sections (GD-19), 32 and 8 on 4.
var _want_planks: int = 0
var _want_ropes: int = 0


func _each_tick(events: Array[NightEvent], sim: NightSim) -> void:
	for event: NightEvent in events:
		_seen[event.kind] = true
	var planks: int = sim.span.total(NightTypes.Part.PLANK)
	var ropes: int = sim.span.total(NightTypes.Part.ROPE)
	if (planks != _want_planks or ropes != _want_ropes or sim.faults.total() != 0) and _broken.size() < 5:
		_broken.append("tick %d: %d planks, %d ropes, faults %s" % [sim.tick, planks, ropes, sim.faults.codes()])


## Every path over seeds 1 to 20, noting the kinds seen and any broken tick. Checks nothing.
func _run_paths(sections: int, planks: int, ropes: int) -> void:
	_want_planks = planks
	_want_ropes = ropes
	_broken = []
	for path: Callable in NightBot.paths():
		for night_seed: int in range(1, 21):
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), sections)
			path.call(def, night_seed, WatchFaults.new(), _each_tick)


func _run_all(sections: int, planks: int, ropes: int) -> void:
	_run_paths(sections, planks, ropes)
	_check("bot: every path, seeds 1 to 20, %d sections: %d planks and %d ropes on every tick, no fault"
			% [sections, planks, ropes], _broken.is_empty(), " | ".join(_broken))


func _test_one_night() -> void:
	_run_all(6, 48, 12)


func _test_four_sections() -> void:
	_run_all(4, 32, 8)


func _test_same_seed_twice() -> void:
	for path: Callable in NightBot.paths():
		var lines_a: PackedStringArray = []
		var lines_b: PackedStringArray = []
		var a: NightSim = path.call(NightDefs.one_night(), 5, WatchFaults.new(),
				func(events: Array[NightEvent], _sim: NightSim) -> void:
					for event: NightEvent in events:
						lines_a.append(_event_text(event)))
		var b: NightSim = path.call(NightDefs.one_night(), 5, WatchFaults.new(),
				func(events: Array[NightEvent], _sim: NightSim) -> void:
					for event: NightEvent in events:
						lines_b.append(_event_text(event)))
		_check("bot: %s twice on seed 5 gives the same events (every field) and checksum" % path.get_method(),
				lines_a == lines_b and not lines_a.is_empty() and a.checksum() == b.checksum())


func _test_every_kind_produced() -> void:
	_seen = {}
	_run_paths(6, 48, 12)
	var missing: PackedStringArray = []
	for kind_name: String in NightEvent.Kind.keys():
		if not _seen.has(NightEvent.Kind[kind_name]):
			missing.append(kind_name)
	_check("bot: every NightEvent kind is produced by some path", missing.is_empty(), str(missing))
