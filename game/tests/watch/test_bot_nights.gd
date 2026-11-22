## Bot nights (AD-63): every bot path over many seeds, on the one night and on a 4-section
## night, checking on every tick that parts are conserved, nothing faults and the warden stands
## where it can (story 1.3 AC 7: by WardenRules and by this file's own arithmetic); one seed run twice
## gives the same events and checksum; and every NightEvent kind and every NightTypes.Reason is
## produced by some path (the coverage check).
## Story 1.5: a fallen section is no floor; while the warden climbs back after a fall (from
## WARDEN_CAUGHT to WARDEN_CLIMBED, which must be 300 ticks apart: GDD Game Mechanics 2, 5 s) the feet
## hang 1.4 m below the deck (decision D3) instead of standing, at the edge of the next section toward
## the town that has planks and stands (_hang_edge()).
## Story 1.6 AC 7, never trapped: walking, the feet are on a section with planks or the landing, 0.3 m
## from every section with none; or a timed move runs and the feet are at its place, by this file's
## own record of it, kept from its _STARTED event (_moves_ok()): an edging (GDD Game Mechanics 2: 4 s,
## 240 ticks; GD-68: roundi(240 x left / 5), at least 1, when it began with the feet on the section)
## at deck height, onto x +-2.2 (decision D2, sidestepping in its first 0.5 s since Sonlm's play),
## toward the section's far edge; a crossing (8 s, 480 ticks) 2.4 m below the deck under the gap's
## rope (x 0, Sonlm's play), within the gap. An edging may end in
## WARDEN_CAUGHT instead (AC 10). Any path can start a move (the wanders can), so this runs on all.
extends WatchTest

## GDD Game Mechanics 2: the edging and the crossing, in ticks.
const EDGE_TICKS: int = 240
const CROSS_TICKS: int = 480
## Story 1.6 D2: the beam lines (5 m deck less 0.3 m clearance); story 1.5 D3: the hang of a climb;
## Sonlm's play of story 1.6's M1: a crossing hangs 2.4 m down under the gap's rope, on the centre line.
const BEAM_X: float = 2.2
const HANG: float = 1.4
const CROSS_HANG: float = 2.4
## GD-19: one tick's walk, 3.5 m/s at 60 ticks a second.
const STEP: float = 3.5 / 60.0
const TOL: float = 0.001

## Kinds seen over every path and seed.
var _seen: Dictionary[NightEvent.Kind, bool] = {}
## Refusal reasons seen over every path and seed.
var _seen_reasons: Dictionary[NightTypes.Reason, bool] = {}
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
## Story 1.6: the running edging ("edge") or crossing ("cross") as recorded here from its _STARTED
## event, "" for none; its section, first tick, length in ticks, way (+1 toward the town), the feet on
## its first tick, the x it drifts onto, and the feet on the tick before. Reset per run.
var _move: String = ""
var _move_section: int = 0
var _move_began: int = 0
var _move_length: int = 0
var _move_toward: int = 0
var _move_from: Vector3 = Vector3.ZERO
var _move_x_to: float = 0.0
var _move_last: Vector3 = Vector3.ZERO


func _reset_run() -> void:
	_caught_at = -1
	_fell_from = 0
	_move = ""
	_move_section = 0


func _each_tick(events: Array[NightEvent], sim: NightSim) -> void:
	var tick: int = sim.tick - 1
	var problems: PackedStringArray = []
	# A move that ended this tick with no other begun after it: [its kind, section, way, x at its end].
	var ended: Array = []
	for event: NightEvent in events:
		_seen[event.kind] = true
		if event.kind == NightEvent.Kind.REFUSED:
			_seen_reasons[event.reason] = true
		match event.kind:
			NightEvent.Kind.WARDEN_CAUGHT:
				_caught_at = tick
				_fell_from = event.section
				if _move == "edge" and event.section == _move_section:
					_move = ""  # AC 10: the edging ends in the catch, with no EDGING_ENDED.
				elif _move != "":
					problems.append("caught on s%d during a %s of s%d" % [event.section, _move, _move_section])
			NightEvent.Kind.WARDEN_CLIMBED:
				if tick - _caught_at != 300:
					problems.append("climbed %d ticks after the catch" % (tick - _caught_at))
				_caught_at = -1
			NightEvent.Kind.EDGING_STARTED, NightEvent.Kind.CROSSING_STARTED:
				ended = []
				problems.append_array(_move_began_here(event, sim, tick))
			NightEvent.Kind.EDGING_ENDED, NightEvent.Kind.CROSSING_ENDED:
				var kind: String = "edge" if event.kind == NightEvent.Kind.EDGING_ENDED else "cross"
				if _move != kind or event.section != _move_section:
					problems.append("%s of s%d ended with no start" % [kind, event.section])
				elif tick - _move_began != _move_length:
					problems.append("%s of s%d lasted %d ticks, wanted %d" % [kind, event.section, tick - _move_began,
							_move_length])
				ended = [kind, _move_section, _move_toward, _move_x_to if kind == "edge" else _move_from.x]
				_move = ""
	var planks: int = sim.span.total(NightTypes.Part.PLANK)
	var ropes: int = sim.span.total(NightTypes.Part.ROPE)
	# Story 1.3 AC 7 and story 1.6 AC 7: walking where it can stand, or at the place of its timed move.
	if _caught_at >= 0:
		if not (absf(sim.warden.position.y + HANG) < TOL and tick - _caught_at <= 300
				and absf(sim.warden.position.z + _length - _hang_edge(sim)) < TOL):
			problems.append("not hanging at the edge")
	elif _move != "":
		problems.append_array(_moves_ok(sim))
	else:
		if not WardenRules.walking(sim):
			problems.append("a timed move with no event")
		if not (WardenRules.can_stand(sim.warden.position, sim) and _inside(sim)):
			problems.append("cannot stand there")
		if not ended.is_empty():
			problems.append_array(_stepped_off(ended, sim))
	_move_last = sim.warden.position
	if (planks != _want_planks or ropes != _want_ropes or sim.faults.total() != 0 or not problems.is_empty()) \
			and _broken.size() < 5:
		_broken.append("tick %d: %d planks, %d ropes, faults %s, warden at %s %s" % [tick, planks, ropes,
				sim.faults.codes(), sim.warden.position, problems])


## Records the move `event` begins, worked out here from where the feet are on its first tick: which
## way it goes and how long it must last. Returns what is wrong with where it began.
func _move_began_here(event: NightEvent, sim: NightSim, tick: int) -> PackedStringArray:
	var problems: PackedStringArray = []
	if _move != "":
		problems.append("a move of s%d began during a %s of s%d" % [event.section, _move, _move_section])
	var n: int = event.section
	var start: float = (n - 1) * 5.0
	var end: float = n * 5.0
	var feet: Vector3 = sim.warden.position
	var along: float = feet.z + _length
	_move_section = n
	_move_began = tick
	_move_from = feet
	_move_last = feet
	if event.kind == NightEvent.Kind.CROSSING_STARTED:
		_move = "cross"
		_move_length = CROSS_TICKS
		_move_toward = -1 if absf(along - end) < TOL else 1
		if absf(feet.y + CROSS_HANG) > TOL or absf(feet.x) > TOL or (absf(along - end) > TOL and absf(along - start) > TOL) \
				or not sim.span.fallen(n):
			problems.append("a crossing of s%d begun away from a gap's edge" % n)
		return problems
	_move = "edge"
	_move_x_to = BEAM_X if feet.x >= 0.0 else -BEAM_X
	if along > start + TOL and along < end - TOL:
		# GD-68: on the section when its last plank went, toward the town in the share left.
		_move_toward = 1
		_move_length = maxi(roundi(EDGE_TICKS * (end - along) / 5.0), 1)
	elif along >= end - TOL:
		_move_toward = -1
		_move_length = EDGE_TICKS
		if absf(along - end) > TOL and absf(along - (end + 0.3)) > TOL:
			problems.append("an edging of s%d begun away from its edge or stop" % n)
	else:
		_move_toward = 1
		_move_length = EDGE_TICKS
		if absf(along - start) > TOL and absf(along - (start - 0.3)) > TOL:
			problems.append("an edging of s%d begun away from its edge or stop" % n)
	var side: float = BEAM_X if event.side == NightTypes.Side.RIGHT else -BEAM_X
	if absf(feet.y) > TOL or side != _move_x_to or sim.span.planks(n) != 0 or sim.span.fallen(n):
		problems.append("an edging of s%d begun off the deck, on the wrong side or not open" % n)
	return problems


## While a move runs: the feet at its place, moving one way. An edging at deck height, x drifting
## from where it began onto its beam line, along from where it began toward the far edge; a crossing
## 2.4 m down, under the rope (x 0), within the gap.
func _moves_ok(sim: NightSim) -> PackedStringArray:
	var problems: PackedStringArray = []
	var feet: Vector3 = sim.warden.position
	var along: float = feet.z + _length
	var last_along: float = _move_last.z + _length
	var far: float = (_move_section - 1) * 5.0 if _move_toward < 0 else _move_section * 5.0
	var from_along: float = _move_from.z + _length
	if WardenRules.walking(sim):
		problems.append("walking during a %s with no end" % _move)
	if _move == "cross":
		if absf(feet.y + CROSS_HANG) > TOL or absf(feet.x - _move_from.x) > TOL or along < (_move_section - 1) * 5.0 - TOL \
				or along > _move_section * 5.0 + TOL:
			problems.append("crossing off its line")
	else:
		var x_ok: bool = absf(feet.x) <= BEAM_X + TOL and absf(feet.x - _move_x_to) <= absf(_move_last.x - _move_x_to) + TOL
		var along_ok: bool = (along - far) * _move_toward <= TOL and (along - from_along) * _move_toward >= -TOL
		if absf(feet.y) > TOL or not x_ok or not along_ok:
			problems.append("edging off its line")
	if (along - last_along) * _move_toward < -TOL:
		problems.append("the %s went back" % _move)
	return problems


## A move that ended this tick onto a floor: the feet 0.3 m past its far edge, x at its end, or one
## walking step from there (the walk runs on that tick too).
func _stepped_off(ended: Array, sim: NightSim) -> PackedStringArray:
	var n: int = ended[1]
	var toward: int = ended[2]
	var x: float = clampf(ended[3], -BEAM_X, BEAM_X)
	var along: float = n * 5.0 + 0.3 if toward > 0 else (n - 1) * 5.0 - 0.3
	var want: Vector2 = Vector2(x, along - _length)
	var got: Vector2 = Vector2(sim.warden.position.x, sim.warden.position.z)
	var slack: float = TOL if sim.move_wish == Vector2.ZERO else STEP + TOL
	if got.distance_to(want) > slack:
		return PackedStringArray(["stepped off s%d at %s, wanted %s" % [n, got, want]])
	return PackedStringArray()


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
## every 5 m section that has no plank (open or fallen, story 1.6). Within 0.001 m.
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
			_reset_run()
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
	# script is the same for every seed; the wander differs): open section 1 with the far pier
	# beyond (stop at along 5.3, pushed into with no move begun: story 1.6 AC 9), both rails (x -2.2
	# and 2.2) and the landing's back (along 33.7 on 6 sections, 23.7 on 4), D1.
	for sections: int in [6, 4]:
		var length: float = 30.0 if sections == 6 else 20.0
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			var pushed: Array[int] = [0]
			NightBot.walk(def, night_seed, WatchFaults.new(),
					func(events: Array[NightEvent], sim: NightSim) -> void:
						var along: float = sim.warden.position.z + length
						if absf(along - 5.3) < 0.001 and sim.move_wish == Vector2(0.0, -1.0) and events.is_empty():
							pushed[0] += 1
							if pushed[0] > 30:
								reached["plankless edge"] = true
						if absf(sim.warden.position.x + 2.2) < 0.001:
							reached["left rail"] = true
						if absf(sim.warden.position.x - 2.2) < 0.001:
							reached["right rail"] = true
						if absf(along - (length + 3.7)) < 0.001:
							reached["landing's back"] = true)
			_check("bot: walk, %d sections, seed %d, pushes over 30 ticks at the plankless edge, meets both rails and the landing's back"
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
		"edged off it toward the town (GD-68)", "forearm raised", "walked with the forearm up",
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
								NightEvent.Kind.EDGING_ENDED:
									# GD-68: begun on the strip's tick, ended 0.3 m onto the next section toward
									# the town (or a walking step past it: the bot pushes on to its goal).
									if event.section == bared_under[0] and along >= event.section * 5.0 + 0.3 - 0.001 \
											and along <= event.section * 5.0 + 0.3 + 3.5 / 60.0 + 0.001:
										reached["edged off it toward the town (GD-68)"] = true
									bared_under[0] = 0
								NightEvent.Kind.RAIL_STRIPPED:
									reached["rail strip"] = true
									if event.section == sections and sim.span.planks(sections) == 4:
										reached["town rail at 4"] = true
								NightEvent.Kind.PLANK_RELAID:
									reached["re-lay"] = true
									if sim.span.planks(event.section) == 1:
										reached["re-lay onto a bare deck"] = true
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
	# The bot's own walk: section 1 is open with the far pier beyond, so a walk from the landing to
	# along 2.5 (on section 1) stops at along 5.3 (story 1.3 D1; story 1.6 AC 9: no edging begins) and
	# never arrives: bot.walk_lost, once the guard runs out.
	var start: StartState = StartState.new()
	start.planks = {1: 0}
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var no_check: Callable = func(_events: Array[NightEvent], _sim: NightSim) -> void: pass
	_expect_begin()
	NightBot._go_to(sim, 0.0, 2.5, no_check)
	_expect_end("bot: a walk that cannot arrive is bot.walk_lost", [["ERROR", "bot.walk_lost", 1]])
	_check("bot: counted once, the warden left at the open section's edge (along 5.3)",
			_faults.count(&"bot.walk_lost") == 1 and absf(sim.warden.position.z + 30.0 - 5.3) < 0.001,
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


func _test_gaps_and_beams_need_four_sections() -> void:
	for path: Callable in [NightBot.gaps, NightBot.beams]:
		var ticks: Array[int] = [0]
		var faults: WatchFaults = WatchFaults.new()
		_expect_begin()
		var sim: NightSim = path.call(_def_with(StartState.new(), 3), 1, faults,
				func(_events: Array[NightEvent], _sim: NightSim) -> void:
					ticks[0] += 1)
		_expect_end("bot: %s on 3 sections is bot.bad_def" % path.get_method(), [["ERROR", "bot.bad_def", 1]])
		_check("bot: and %s runs nothing" % path.get_method(), faults.count(&"bot.bad_def") == 1 and ticks[0] == 0
				and sim.tick == 0, "%d ticks" % ticks[0])


## The move cases common to gaps and beams, told here from events and positions: each _STARTED and
## _ENDED is noted as "kind sN tick", so a test can find chained pairs on one tick.
func _note_moves(events: Array[NightEvent], tick: int, log: Array[String]) -> void:
	for event: NightEvent in events:
		match event.kind:
			NightEvent.Kind.EDGING_STARTED, NightEvent.Kind.EDGING_ENDED, NightEvent.Kind.CROSSING_STARTED, \
					NightEvent.Kind.CROSSING_ENDED, NightEvent.Kind.WARDEN_CAUGHT, NightEvent.Kind.WARDEN_CLIMBED:
				log.append("%s s%d %d" % [NightEvent.Kind.find_key(event.kind), event.section, tick])


## True when `log` holds `first` and then `second` on the same tick, `first` ending `length` ticks
## after `start` began (each "KIND sN"): a chained pair, the first lasting `length`.
func _chained(log: Array[String], start: String, first: String, second: String, length: int) -> bool:
	for i: int in range(log.size() - 1):
		var a: PackedStringArray = log[i].split(" ")
		var b: PackedStringArray = log[i + 1].split(" ")
		if "%s %s" % [a[0], a[1]] != first or "%s %s" % [b[0], b[1]] != second or a[2] != b[2]:
			continue
		for j: int in range(i - 1, -1, -1):
			var s: PackedStringArray = log[j].split(" ")
			if "%s %s" % [s[0], s[1]] == start:
				return int(a[2]) - int(s[2]) == length
	return false


func _test_gaps_reaches_its_cases() -> void:
	# Story 1.6 T8: the gaps path's script, on both nights and three seeds. GDD Game Mechanics 2: a gap
	# is crossed in 8 s (480 ticks); D1: 30 ticks of pushing begin nothing, the 31st begins the move.
	var wanted: PackedStringArray = [
		"30 ticks of pushing begin nothing", "a hold cancelled as a crossing begins", "c crossed toward the far pier",
		"a crossed right after c", "onto b", "a crossed back toward the town", "c crossed right after a", "onto the town section",
	]
	for sections: int in [6, 4]:
		var length: float = sections * 5.0
		var town: int = sections
		var c: int = town - 1
		var a: int = town - 2
		var b: int = town - 3
		if sections == 6:
			wanted.append("an open section creaking under 2")
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			var log: Array[String] = []
			var pushes: Array[int] = [0]
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			var script_faults: WatchFaults = WatchFaults.new()
			NightBot.gaps_script(def, night_seed, script_faults,
					func(events: Array[NightEvent], sim: NightSim) -> void:
						var tick: int = sim.tick - 1
						var along: float = sim.warden.position.z + length
						_note_moves(events, tick, log)
						# The stop before c is the town section's far-pier end, 0.3 m in.
						var at_stop: bool = absf(along - ((town - 1) * 5.0 + 0.3)) < 0.001
						if at_stop and sim.move_wish == Vector2(0.0, -1.0) and events.is_empty():
							pushes[0] += 1
						else:
							if pushes[0] == 30 and at_stop and sim.move_wish == Vector2.ZERO and WardenRules.walking(sim):
								reached["30 ticks of pushing begin nothing"] = true
							pushes[0] = 0
						var kinds: Array[NightEvent.Kind] = _kinds(events)
						if kinds.has(NightEvent.Kind.CROSSING_STARTED) and kinds.has(NightEvent.Kind.HOLD_CANCELLED) \
								and kinds.find(NightEvent.Kind.CROSSING_STARTED) < kinds.find(NightEvent.Kind.HOLD_CANCELLED):
							reached["a hold cancelled as a crossing begins"] = true
						for event: NightEvent in events:
							if event.kind == NightEvent.Kind.CREAK_STARTED and event.section == 1 and sim.span.planks(1) == 0 \
									and sim.span.weights(1) == 2 and not sim.span.fallen(1):
								reached["an open section creaking under 2"] = true
							if event.kind == NightEvent.Kind.CROSSING_ENDED and event.section == a \
									and absf(along - (b * 5.0 - 0.3)) < 0.001:
								reached["onto b"] = true
							if event.kind == NightEvent.Kind.CROSSING_ENDED and event.section == c \
									and absf(along - (c * 5.0 + 0.3)) < 0.001:
								reached["onto the town section"] = true)
			if _chained(log, "CROSSING_STARTED s%d" % c, "CROSSING_ENDED s%d" % c, "CROSSING_STARTED s%d" % a, 480):
				reached["c crossed toward the far pier"] = true
				reached["a crossed right after c"] = true
			if _chained(log, "CROSSING_STARTED s%d" % a, "CROSSING_ENDED s%d" % a, "CROSSING_STARTED s%d" % c, 480):
				reached["a crossed back toward the town"] = true
				reached["c crossed right after a"] = true
			var missing: PackedStringArray = []
			for case: String in wanted:
				if not reached.has(case):
					missing.append(case)
			_check("bot: gaps' script, %d sections, seed %d, reaches every case" % [sections, night_seed],
					missing.is_empty(), "%s %s" % [missing, log])
			_check("bot: gaps' script, %d sections, seed %d: no fault" % [sections, night_seed],
					script_faults.total() == 0, str(script_faults.codes()))
		wanted.erase("an open section creaking under 2")


func _test_beams_reaches_its_cases() -> void:
	# Story 1.6 T8: the beams path's script, on both nights and three seeds. GDD Game Mechanics 2: an
	# open section is edged in 4 s (240 ticks), its side beams carry 2 (3 weights groan, and it falls
	# 120 ticks later); GD-68: from mid section (2.5 m left) the edging lasts 120 ticks; D3: a warden
	# 0.1 m beside a section that goes open ends 0.3 m from it; GD-69: a re-lay onto an open section.
	var wanted: PackedStringArray = [
		"an open section groaning under 3", "edged into an open section", "caught as it fell under the beam",
		"climbed back onto c", "last plank underfoot: edged toward the town in 120 ticks", "re-laid onto an open section",
		"walked over the re-laid section", "stepped back from a section that went open", "an edging chained into a crossing",
		"a crossing chained into an edging",
	]
	for sections: int in [6, 4]:
		var length: float = sections * 5.0
		var town: int = sections
		var c: int = town - 1
		var a: int = town - 2
		for night_seed: int in [1, 2, 3]:
			var reached: Dictionary[String, bool] = {}
			var log: Array[String] = []
			var last_at: Array[Vector3] = [Vector3.ZERO]
			var relaid: Array[bool] = [false]
			var def: NightDef = NightDefs.one_night() if sections == 6 else _def_with(StartState.new(), 4)
			var script_faults: WatchFaults = WatchFaults.new()
			NightBot.beams_script(def, night_seed, script_faults,
					func(events: Array[NightEvent], sim: NightSim) -> void:
						var tick: int = sim.tick - 1
						var along: float = sim.warden.position.z + length
						var before: float = last_at[0].z + length
						_note_moves(events, tick, log)
						for event: NightEvent in events:
							var n: int = event.section
							match event.kind:
								NightEvent.Kind.GROAN_STARTED:
									if sim.span.planks(n) == 0 and not sim.span.fallen(n) and sim.span.weights(n) == 3:
										reached["an open section groaning under 3"] = true
								NightEvent.Kind.EDGING_STARTED:
									if n == a and absf(before - (c - 1) * 5.0 - 0.3) < 0.001:
										reached["edged into an open section"] = true
								NightEvent.Kind.WARDEN_CAUGHT:
									if n == a and log.has("EDGING_STARTED s%d %d" % [a, tick - 90]):
										reached["caught as it fell under the beam"] = true
								NightEvent.Kind.WARDEN_CLIMBED:
									if n == c and absf(along - ((c - 1) * 5.0 + 0.3)) < 0.001:
										reached["climbed back onto c"] = true
								NightEvent.Kind.EDGING_ENDED:
									var began: String = "EDGING_STARTED s%d %d" % [n, tick - 120]
									if n == c and log.has(began) and absf(along - (c * 5.0 + 0.3)) < 0.001:
										reached["last plank underfoot: edged toward the town in 120 ticks"] = true
								NightEvent.Kind.PLANK_RELAID:
									if n == c and sim.span.planks(c) == 1 and not sim.span.fallen(c):
										reached["re-laid onto an open section"] = true
										relaid[0] = true
								NightEvent.Kind.PLANK_STRIPPED:
									if n == c and sim.span.planks(c) == 0 and before > c * 5.0 and before < c * 5.0 + 0.3 \
											and absf(along - (c * 5.0 + 0.3)) < 0.001 and WardenRules.walking(sim):
										reached["stepped back from a section that went open"] = true
						if relaid[0] and WardenRules.walking(sim) and along < (c - 1) * 5.0 + 0.5 and along > (c - 1) * 5.0:
							reached["walked over the re-laid section"] = true
							relaid[0] = false
						last_at[0] = sim.warden.position)
			if _chained(log, "EDGING_STARTED s%d" % c, "EDGING_ENDED s%d" % c, "CROSSING_STARTED s%d" % a, 240):
				reached["an edging chained into a crossing"] = true
			if _chained(log, "CROSSING_STARTED s%d" % a, "CROSSING_ENDED s%d" % a, "EDGING_STARTED s%d" % c, 480):
				reached["a crossing chained into an edging"] = true
			var missing: PackedStringArray = []
			for case: String in wanted:
				if not reached.has(case):
					missing.append(case)
			_check("bot: beams' script, %d sections, seed %d, reaches every case" % [sections, night_seed],
					missing.is_empty(), "%s %s" % [missing, log])
			_check("bot: beams' script, %d sections, seed %d: no fault" % [sections, night_seed],
					script_faults.total() == 0, str(script_faults.codes()))
