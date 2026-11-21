## Bot nights (AD-63): every bot path over many seeds, on the one night and on a 4-section
## night, checking on every tick that parts are conserved, nothing faults and the warden stands
## where it can (story 1.3 AC 7: by WardenRules and by this file's own arithmetic); one seed run twice
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
## The span's length for the run: 30 m on 6 sections, 20 m on 4 (GD-19: sections of 5 m).
var _length: float = 0.0


func _each_tick(events: Array[NightEvent], sim: NightSim) -> void:
	for event: NightEvent in events:
		_seen[event.kind] = true
	var planks: int = sim.span.total(NightTypes.Part.PLANK)
	var ropes: int = sim.span.total(NightTypes.Part.ROPE)
	# Story 1.3 AC 7: the warden is never outside what can be walked on.
	var standing: bool = WardenRules.can_stand(sim.warden.position, sim) and _inside(sim)
	if (planks != _want_planks or ropes != _want_ropes or sim.faults.total() != 0 or not standing) \
			and _broken.size() < 5:
		_broken.append("tick %d: %d planks, %d ropes, faults %s, warden at %s%s" % [sim.tick, planks, ropes,
				sim.faults.codes(), sim.warden.position, "" if standing else " (cannot stand there)"])


## Story 1.3 D1, worked out here and not asked of WardenRules (the rule may not be its own
## judge): 0.3 m from the rails (x within 2.2 of the centre line of a 5 m deck), from the far
## pier (along 0.3), from the landing's back (4 m deep: along length + 3.7) and from both ends of
## every 5 m section that has no plank. Within 0.001 m.
func _inside(sim: NightSim) -> bool:
	var x: float = sim.warden.position.x
	var along: float = sim.warden.position.z + _length
	if absf(x) > 2.2 + 0.001 or along < 0.3 - 0.001 or along > _length + 3.7 + 0.001 or sim.warden.position.y != 0.0:
		return false
	for n: int in range(1, sim.def.section_count + 1):
		if sim.span.planks(n) == 0 and along > (n - 1) * 5.0 - 0.3 + 0.001 and along < n * 5.0 + 0.3 - 0.001:
			return false
	return true


## Every path over seeds 1 to 20, noting the kinds seen and any broken tick. Checks nothing.
func _run_paths(sections: int, planks: int, ropes: int) -> void:
	_want_planks = planks
	_want_ropes = ropes
	_length = sections * 5.0
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


func _test_walk_reaches_the_edges() -> void:
	# The walk path really meets what it is written to meet, on both nights and three seeds (the
	# script is the same for every seed; the wander differs): the plankless section 2 (stop at
	# along 10.3), both rails (x -2.2 and 2.2) and the landing's back (along 33.7 on 6 sections,
	# 23.7 on 4), D1.
	for sections: int in [6, 4]:
		var length: float = 30.0 if sections == 6 else 20.0
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			NightBot.walk(def, night_seed, WatchFaults.new(),
					func(_events: Array[NightEvent], sim: NightSim) -> void:
						var along: float = sim.warden.position.z + length
						if absf(along - 10.3) < 0.001:
							reached["plankless edge"] = true
						if absf(sim.warden.position.x + 2.2) < 0.001:
							reached["left rail"] = true
						if absf(sim.warden.position.x - 2.2) < 0.001:
							reached["right rail"] = true
						if absf(along - (length + 3.7)) < 0.001:
							reached["landing's back"] = true)
			_check("bot: walk, %d sections, seed %d, meets the plankless edge, both rails and the landing's back"
					% [sections, night_seed], reached.size() == 4, str(reached.keys()))
