## Bot nights (AD-63): every bot path over many seeds, on the one night and on a 4-section
## night, checking on every tick that parts are conserved, nothing faults and the warden stands
## where it can (story 1.3 AC 7: by WardenRules and by this file's own arithmetic); one seed run twice
## gives the same events and checksum; and every NightEvent kind and every NightTypes.Reason is
## produced by some path (the coverage check). Story 1.4 decision D3 is in this file's own
## arithmetic: a section that went bare under the warden holds them until they step off it.
## Story 1.5 too: a fallen section is no floor and never holds anyone; while the warden climbs back
## after a fall (from WARDEN_CAUGHT to WARDEN_CLIMBED, which must be 300 ticks apart: GDD Game
## Mechanics 2, 5 s) the feet hang 1.4 m below the deck (decision D3) instead of standing, at the
## edge of the next section toward the town that has planks and stands (_hang_edge()).
extends WatchTest

## Kinds seen over every path and seed.
var _seen: Dictionary[NightEvent.Kind, bool] = {}
## Refusal reasons seen over every path and seed.
var _seen_reasons: Dictionary[NightTypes.Reason, bool] = {}
## D3: the bare sections that still hold the warden, worked out here from PLANK_STRIPPED events
## and positions: a section is added when its last plank goes while the warden is on it or within
## 0.3 m of it, and dropped on the first tick the warden is outside that band. Reset per run.
var _held: Dictionary[int, bool] = {}
## Problems found on any tick, first few kept.
var _broken: PackedStringArray = []
## The totals a tick must show: 48 planks and 12 ropes on 6 sections (GD-19), 32 and 8 on 4.
var _want_planks: int = 0
var _want_ropes: int = 0
## The span's length for the run: 30 m on 6 sections, 20 m on 4 (GD-19: sections of 5 m).
var _length: float = 0.0
## Story 1.5: the tick of the last WARDEN_CAUGHT while the warden climbs, -1 while walking. Reset
## per run.
var _caught_at: int = -1
## Story 1.5: the section that fell under the warden at the last WARDEN_CAUGHT. Reset per run.
var _fell_from: int = 0


func _each_tick(events: Array[NightEvent], sim: NightSim) -> void:
	var along: float = sim.warden.position.z + _length
	var tick: int = sim.tick - 1
	var climb: String = ""
	for event: NightEvent in events:
		_seen[event.kind] = true
		if event.kind == NightEvent.Kind.REFUSED:
			_seen_reasons[event.reason] = true
		if event.kind == NightEvent.Kind.PLANK_STRIPPED and sim.span.planks(event.section) == 0 \
				and _in_band(along, event.section):
			_held[event.section] = true
		if event.kind == NightEvent.Kind.WARDEN_CAUGHT:
			_caught_at = tick
			_fell_from = event.section
		if event.kind == NightEvent.Kind.WARDEN_CLIMBED:
			if tick - _caught_at != 300:
				climb = " (climbed %d ticks after the catch)" % (tick - _caught_at)
			_caught_at = -1
	# A fallen section holds nobody. No bot path yet bares a section that later falls, so removing
	# `fallen` here changes no run: it is a guard, not a proven check (DW-43, story 1.6).
	for n: int in _held.keys():
		if not _in_band(along, n) or sim.span.planks(n) > 0 or sim.span.fallen(n):
			_held.erase(n)
	var planks: int = sim.span.total(NightTypes.Part.PLANK)
	var ropes: int = sim.span.total(NightTypes.Part.ROPE)
	# Story 1.3 AC 7: the warden is never outside what can be walked on; D3: or is held. Story 1.5:
	# while climbing, the feet hang 1.4 m down at an edge instead, and no climb outlasts 300 ticks.
	var standing: bool
	if _caught_at >= 0:
		standing = absf(sim.warden.position.y + 1.4) < 0.001 and tick - _caught_at <= 300 \
				and absf(along - _hang_edge(sim)) < 0.001
	else:
		standing = (WardenRules.can_stand(sim.warden.position, sim) or not _held.is_empty()) and _inside(sim) \
				and climb.is_empty()
	if (planks != _want_planks or ropes != _want_ropes or sim.faults.total() != 0 or not standing) \
			and _broken.size() < 5:
		_broken.append("tick %d: %d planks, %d ropes, faults %s, warden at %s%s%s" % [sim.tick, planks, ropes,
				sim.faults.codes(), sim.warden.position, "" if standing else " (cannot stand there)", climb])


## Story 1.5 D3 and the code review of 2026-11-22, worked out here: where along the span a climbing
## warden hangs: at the near edge of the first 5 m section after the one that fell under them that
## has a plank and has not fallen, else at the landing's edge (the span's length). Every tick, so
## also when the section first caught falls during the climb.
func _hang_edge(sim: NightSim) -> float:
	for n: int in range(_fell_from + 1, sim.def.section_count + 1):
		if sim.span.planks(n) > 0 and not sim.span.fallen(n):
			return (n - 1) * 5.0
	return _length


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
		if sim.span.planks(n) == 0 and not _held.has(n) and along > (n - 1) * 5.0 - 0.3 + 0.001 \
				and along < n * 5.0 + 0.3 - 0.001:
			return false
	return true


## D3's band: on the 5 m section `n` or within 0.3 m of it (within 0.001 m).
func _in_band(along: float, n: int) -> bool:
	return along > (n - 1) * 5.0 - 0.3 - 0.001 and along < n * 5.0 + 0.3 + 0.001


## Every path over seeds 1 to 20, noting the kinds seen and any broken tick. Checks nothing.
func _run_paths(sections: int, planks: int, ropes: int) -> void:
	_want_planks = planks
	_want_ropes = ropes
	_length = sections * 5.0
	_broken = []
	for path: Callable in NightBot.paths():
		for night_seed: int in range(1, 21):
			_held = {}
			_caught_at = -1
			_fell_from = 0
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
	_seen_reasons = {}
	_run_paths(6, 48, 12)
	var missing: PackedStringArray = []
	for kind_name: String in NightEvent.Kind.keys():
		if not _seen.has(NightEvent.Kind[kind_name]):
			missing.append(kind_name)
	_check("bot: every NightEvent kind is produced by some path", missing.is_empty(), str(missing))
	missing = []
	for reason_name: String in NightTypes.Reason.keys():
		if reason_name != "NONE" and not _seen_reasons.has(NightTypes.Reason[reason_name]):
			missing.append(reason_name)
	_check("bot: every NightTypes.Reason but NONE is produced by some path", missing.is_empty(), str(missing))


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


func _test_strip_reaches_its_cases() -> void:
	# Story 1.4 T7: the strip path's script really produces each case it is written for, on both
	# nights and three seeds. Each case is told from events, commands and state here, not taken on
	# trust. The script alone is run (strip_script): the wander's random taps would reach some of
	# these by luck. What cancelled a hold is read from the commands of that tick, never guessed
	# from the mode.
	var wanted: PackedStringArray = [
		"NO_ACTION_HERE", "NO_PLANK_IN_HAND", "DECK_FULL", "LAST_SECTION_MINIMUM", "NO_PLANKS_LEFT",
		"strip", "rail strip", "town rail at 4", "re-lay", "re-lay onto a bare deck",
		"cancel by letting go", "cancel by walking", "cancel by a second press", "last plank underfoot",
		"walked off it toward the town", "forearm raised", "walked with the forearm up",
		"hammer ignored with the forearm up", "forearm lowered",
	]
	for sections: int in [6, 4]:
		var length: float = sections * 5.0
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			var hold_from: Array[Vector3] = [Vector3.ZERO]
			var bared_under: Array[int] = [0]
			var last_at: Array[Vector3] = [Vector3.ZERO]
			var was_raised: Array[bool] = [false]
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			var script_faults: WatchFaults = WatchFaults.new()
			NightBot.strip_script(def, night_seed, script_faults,
					func(events: Array[NightEvent], sim: NightSim) -> void:
						var along: float = sim.warden.position.z + length
						var pressed: bool = false
						var let_go: bool = false
						for cmd: NightCommand in sim.commands:
							if cmd.input == NightTypes.HandInput.HAMMER:
								pressed = pressed or cmd.kind == NightCommand.Kind.PRESS
								let_go = let_go or cmd.kind == NightCommand.Kind.RELEASE
						for event: NightEvent in events:
							match event.kind:
								NightEvent.Kind.REFUSED:
									reached[NightTypes.Reason.find_key(event.reason)] = true
								NightEvent.Kind.HOLD_STARTED:
									hold_from[0] = sim.warden.position
								NightEvent.Kind.HOLD_CANCELLED:
									var moved: float = Vector2(sim.warden.position.x - hold_from[0].x,
											sim.warden.position.z - hold_from[0].z).length()
									if sim.holds == NightTypes.Holds.PRESS_ONCE and pressed and not let_go and moved <= 0.5:
										reached["cancel by a second press"] = true
									elif sim.holds == NightTypes.Holds.HOLD and moved > 0.5 and not pressed and not let_go:
										reached["cancel by walking"] = true
									elif sim.holds == NightTypes.Holds.HOLD and let_go and not pressed and moved <= 0.5:
										reached["cancel by letting go"] = true
								NightEvent.Kind.PLANK_STRIPPED:
									reached["strip"] = true
									if sim.span.planks(event.section) == 0 and along > (event.section - 1) * 5.0 \
											and along < event.section * 5.0:
										reached["last plank underfoot"] = true
										bared_under[0] = event.section
								NightEvent.Kind.RAIL_STRIPPED:
									reached["rail strip"] = true
									if event.section == sections and sim.span.planks(sections) == 4:
										reached["town rail at 4"] = true
								NightEvent.Kind.PLANK_RELAID:
									reached["re-lay"] = true
									if sim.span.planks(event.section) == 1:
										reached["re-lay onto a bare deck"] = true
						if bared_under[0] > 0 and along > bared_under[0] * 5.0 + 0.3:
							reached["walked off it toward the town"] = true
							bared_under[0] = 0
						if sim.hands.forearm_raised:
							reached["forearm raised"] = true
							if not sim.warden.position.is_equal_approx(last_at[0]):
								reached["walked with the forearm up"] = true
							for cmd: NightCommand in sim.commands:
								if cmd.kind == NightCommand.Kind.PRESS and cmd.input == NightTypes.HandInput.HAMMER \
										and events.is_empty():
									reached["hammer ignored with the forearm up"] = true
						elif was_raised[0]:
							reached["forearm lowered"] = true
						was_raised[0] = sim.hands.forearm_raised
						last_at[0] = sim.warden.position)
			var missing: PackedStringArray = []
			for case: String in wanted:
				if not reached.has(case):
					missing.append(case)
			_check("bot: strip's script, %d sections, seed %d, reaches every case" % [sections, night_seed],
					missing.is_empty(), str(missing))
			_check("bot: strip's script, %d sections, seed %d: no fault" % [sections, night_seed],
					script_faults.total() == 0, str(script_faults.codes()))


func _test_a_walk_that_cannot_arrive_is_a_fault() -> void:
	# The bot's own walk: section 2 has no planks, so a walk from the landing to along 2.5 (section
	# 1) stops at along 10.3 (story 1.3 D1) and never arrives: bot.walk_lost, once the guard runs out.
	var start: StartState = StartState.new()
	start.planks = {2: 0}
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var no_check: Callable = func(_events: Array[NightEvent], _sim: NightSim) -> void: pass
	_expect_begin()
	NightBot._go_to(sim, 0.0, 2.5, no_check)
	_expect_end("bot: a walk that cannot arrive is bot.walk_lost", [["ERROR", "bot.walk_lost", 1]])
	_check("bot: counted once, the warden left at the bare section's edge (along 10.3)",
			_faults.count(&"bot.walk_lost") == 1 and absf(sim.warden.position.z + 30.0 - 10.3) < 0.001,
			str(sim.warden.position))
	NightBot._go_to(sim, 0.0, 12.5, no_check)
	_check("bot: a walk that arrives reports nothing more", _faults.count(&"bot.walk_lost") == 1
			and absf(sim.warden.position.z + 30.0 - 12.5) < 0.001, str(sim.warden.position))


func _test_strip_needs_four_sections() -> void:
	# The strip path's sections (the town, two before it, three before it) fold into one another on
	# a shorter span: a fault, and nothing is run.
	var ticks: Array[int] = [0]
	var faults: WatchFaults = WatchFaults.new()
	_expect_begin()
	var sim: NightSim = NightBot.strip(_def_with(StartState.new(), 3), 1, faults,
			func(_events: Array[NightEvent], _sim: NightSim) -> void:
				ticks[0] += 1)
	_expect_end("bot: strip on 3 sections is bot.bad_def", [["ERROR", "bot.bad_def", 1]])
	_check("bot: and it runs nothing", faults.count(&"bot.bad_def") == 1 and ticks[0] == 0 and sim.tick == 0,
			"%d ticks" % ticks[0])



func _test_overload_needs_four_sections() -> void:
	var ticks: Array[int] = [0]
	var faults: WatchFaults = WatchFaults.new()
	_expect_begin()
	var sim: NightSim = NightBot.overload(_def_with(StartState.new(), 3), 1, faults,
			func(_events: Array[NightEvent], _sim: NightSim) -> void:
				ticks[0] += 1)
	_expect_end("bot: overload on 3 sections is bot.bad_def", [["ERROR", "bot.bad_def", 1]])
	_check("bot: and it runs nothing", faults.count(&"bot.bad_def") == 1 and ticks[0] == 0 and sim.tick == 0,
			"%d ticks" % ticks[0])


func _test_overload_reaches_its_cases() -> void:
	# Story 1.5 T8: the overload path's script really produces each case it is written for, on both
	# nights and three seeds, each told from events, commands and state here, not taken on trust:
	# a load is the test weights (1 each) and a strength the planks, read from the state, never
	# asked of SpanRules (the rule may not be its own judge).
	# GDD Game Mechanics 2: a fall comes 120 ticks after GROAN_STARTED; the climb back lasts 300.
	# Decision D2: a warden beside the gap ends 0.3 m from it; D3: the climb ends 0.3 m in.
	var wanted: PackedStringArray = [
		"creak started", "creak stopped", "groan started", "groan stopped", "weight lifted",
		"fell with nobody on it", "weights gone and parts lost on it", "step back",
		"a hold on it cancelled on F + 1", "one that would have completed then", "fell under the warden",
		"the forearm lowered by the fall", "presses ignored while climbing", "move ignored while climbing",
		"climbed onto a section", "climbed onto the landing", "the town section fell", "NO_ACTION_HERE at a gap",
	]
	for sections: int in [6, 4]:
		var length: float = sections * 5.0
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			# Section -> the tick its groan started, the tick it fell.
			var groaned: Dictionary[int, int] = {}
			var fell_on: Dictionary[int, int] = {}
			# The running hold: [section, the tick it began, its length]; the last feet and forearm.
			var hold: Array[int] = [0, 0, 0]
			var last_at: Array[Vector3] = [Vector3.ZERO]
			var was_raised: Array[bool] = [false]
			# Section -> its test weights at the end of the tick before.
			var weights_were: Dictionary[int, int] = {}
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			var script_faults: WatchFaults = WatchFaults.new()
			NightBot.overload_script(def, night_seed, script_faults,
					func(events: Array[NightEvent], sim: NightSim) -> void:
						var tick: int = sim.tick - 1
						var along: float = sim.warden.position.z + length
						var before: float = last_at[0].z + length
						var caught: bool = false
						for event: NightEvent in events:
							var n: int = event.section
							match event.kind:
								NightEvent.Kind.CREAK_STARTED:
									if sim.span.weights(n) > 0 and sim.span.weights(n) == sim.span.planks(n):
										reached["creak started"] = true
								NightEvent.Kind.CREAK_STOPPED:
									if sim.span.weights(n) != sim.span.planks(n):
										reached["creak stopped"] = true
								NightEvent.Kind.GROAN_STARTED:
									if sim.span.weights(n) > sim.span.planks(n):
										reached["groan started"] = true
										groaned[n] = tick
								NightEvent.Kind.GROAN_STOPPED:
									if sim.span.weights(n) <= sim.span.planks(n) and tick - groaned.get(n, -1000) < 120:
										reached["groan stopped"] = true
								NightEvent.Kind.WEIGHT_LIFTED:
									if sim.span.weights(n) == weights_were.get(n, -1) - 1:
										reached["weight lifted"] = true
								NightEvent.Kind.SECTION_FELL:
									fell_on[n] = tick
									if groaned.get(n, -1000) == tick - 120 and sim.span.weights(n) == 0 \
											and sim.span.planks(n) == 0 and not sim.span.rail_standing(n, NightTypes.Side.LEFT) \
											and not sim.span.rail_standing(n, NightTypes.Side.RIGHT):
										reached["weights gone and parts lost on it"] = true
									if n == sections:
										reached["the town section fell"] = true
								NightEvent.Kind.HOLD_STARTED:
									hold[0] = n
									hold[1] = tick
									hold[2] = sim.hands.ticks_total
								NightEvent.Kind.HOLD_CANCELLED:
									if fell_on.get(n, -1) == tick - 1 and hold[0] == n:
										reached["a hold on it cancelled on F + 1"] = true
										if hold[1] + hold[2] == tick:
											reached["one that would have completed then"] = true
								NightEvent.Kind.WARDEN_CAUGHT:
									caught = true
									if fell_on.get(n, -1) == tick and before > (n - 1) * 5.0 and before < n * 5.0:
										reached["fell under the warden"] = true
								NightEvent.Kind.WARDEN_CLIMBED:
									if n > 0 and absf(along - ((n - 1) * 5.0 + 0.3)) < 0.001:
										reached["climbed onto a section"] = true
									if n == 0 and absf(along - (length + 0.3)) < 0.001:
										reached["climbed onto the landing"] = true
								NightEvent.Kind.REFUSED:
									if event.reason == NightTypes.Reason.NO_ACTION_HERE and _view_meets_a_gap(sim, length):
										reached["NO_ACTION_HERE at a gap"] = true
						# A section fell this tick and nobody was caught: nobody was on it. D2: a warden
						# who stood within 0.3 m of its town edge ends this tick 0.3 m from it.
						for n: int in fell_on:
							if fell_on[n] == tick and not caught:
								reached["fell with nobody on it"] = true
								if absf(along - (n * 5.0 + 0.3)) < 0.001 and before < n * 5.0 + 0.3 - 0.001:
									reached["step back"] = true
						var climbing: bool = not WardenRules.walking(sim) and not caught
						var tab_let_go: bool = sim.commands.any(func(cmd: NightCommand) -> bool:
								return cmd.kind == NightCommand.Kind.RELEASE and cmd.input == NightTypes.HandInput.FOREARM)
						if climbing and was_raised[0] and not sim.hands.forearm_raised and not tab_let_go:
							reached["the forearm lowered by the fall"] = true
						if climbing:
							var pressed: bool = sim.commands.any(func(cmd: NightCommand) -> bool:
									return cmd.kind == NightCommand.Kind.PRESS)
							if pressed and events.is_empty() and not sim.hands.holding() and not sim.hands.forearm_raised:
								reached["presses ignored while climbing"] = true
							if sim.move_wish != Vector2.ZERO and sim.warden.position == last_at[0]:
								reached["move ignored while climbing"] = true
						was_raised[0] = sim.hands.forearm_raised
						last_at[0] = sim.warden.position
						for n: int in range(1, sections + 1):
							weights_were[n] = sim.span.weights(n))
			var missing: PackedStringArray = []
			for case: String in wanted:
				if not reached.get(case, false):
					missing.append(case)
			_check("bot: overload's script, %d sections, seed %d, reaches every case" % [sections, night_seed],
					missing.is_empty(), str(missing))
			_check("bot: overload's script, %d sections, seed %d: no fault" % [sections, night_seed],
					script_faults.total() == 0, str(script_faults.codes()))


## Worked out here, not asked of LookRules: the view line from the eye (1.6 m above the feet)
## meets the deck plane (y 0) within the 2 m reach over a section that has fallen.
func _view_meets_a_gap(sim: NightSim, length: float) -> bool:
	var eye: Vector3 = sim.warden.position + Vector3(0.0, 1.6, 0.0)
	var dir: Vector3 = Vector3(-sin(sim.yaw) * cos(sim.pitch), sin(sim.pitch), -cos(sim.yaw) * cos(sim.pitch))
	if dir.y >= 0.0:
		return false
	var t: float = -eye.y / dir.y
	if t > 2.0:
		return false
	var along: float = eye.z + dir.z * t + length
	var n: int = floori(along / 5.0) + 1
	return n >= 1 and n <= sim.def.section_count and sim.span.fallen(n)
