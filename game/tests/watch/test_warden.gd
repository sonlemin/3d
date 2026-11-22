## The warden's walking (AD-52, AD-67; story 1.3 AC 1, 2, 5, 7, decisions D1 and D3). Every
## spec value is written literally with its source: GD-19 for the speed and the sizes, D1 for
## the 0.3 m clearance, D2 of story 1.2 for the landing (5 x 4 m) and the eye height.
## Positions are floats: compared within 0.001 m.
extends WatchTest

## The tolerance for a position, in metres (story 1.3 Testing standards).
const TOL: float = 0.001
## GD-19: 3.5 m/s at 60 ticks a second (AD-33).
const STEP: float = 3.5 / 60.0


## A def of `sections` sections with `start`, the warden placed at `along` (-1: the landing).
func _placed(along: float, sections: int = 6, planks: Dictionary[int, int] = {}) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	return _sim_with(_def_with(start, sections), 1)


## `ticks` ticks with the same move wish.
func _push(sim: NightSim, wish: Vector2, ticks: int) -> void:
	for i: int in ticks:
		sim.set_move(wish)
		sim.advance()


## The warden's along, for a span of `length` metres (world_z = along - length).
func _along(sim: NightSim, length: float) -> float:
	return sim.warden.position.z + length


func _near(a: float, b: float) -> bool:
	return absf(a - b) < TOL


func _test_eye_height() -> void:
	# D2 of story 1.2, moved here from SpanGeometry (DW-29).
	_check("warden: eye height 1.6", is_equal_approx(WardenConstants.EYE_HEIGHT, 1.6))


func _test_where_a_night_starts() -> void:
	# AC 1: on the landing's centre (along 32 on the one night: z 2), facing the far pier.
	var sim: NightSim = _sim_with(NightDefs.one_night(), 1)
	_check("warden: a fresh night starts at SpanGeometry.warden_start()",
			sim.warden.position.is_equal_approx(sim.geometry.warden_start()), str(sim.warden.position))
	_check("warden: which is (0, 0, 2) on the one night", sim.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(sim.warden.position))
	_check("warden: yaw and pitch 0 before any input", sim.yaw == 0.0 and sim.pitch == 0.0)
	_advance(sim, 60)
	_check("warden: with nothing pressed the warden stays put",
			sim.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)), str(sim.warden.position))
	_check("warden: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_walking_speed() -> void:
	# AC 2, GD-19: 3.5 m/s; 60 ticks of forward from mid section 4 (along 17.5) cover 3.5 m.
	var sim: NightSim = _placed(17.5)
	var y_ok: bool = true
	for i: int in 60:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
		y_ok = y_ok and sim.warden.position.y == 0.0
	_check("warden: 60 ticks forward cover 3.5 m toward the far pier (GD-19)", _near(_along(sim, 30.0), 14.0),
			str(_along(sim, 30.0)))
	_check("warden: x unchanged", _near(sim.warden.position.x, 0.0), str(sim.warden.position.x))
	_check("warden: y stays 0 on every tick (no jump)", y_ok)

	sim = _placed(17.5)
	_push(sim, Vector2(1.0, 0.0), 30)
	_check("warden: strafing is the same speed (30 ticks right: x 1.75)", _near(sim.warden.position.x, 1.75)
			and _near(_along(sim, 30.0), 17.5), str(sim.warden.position))

	sim = _placed(17.5)
	_push(sim, Vector2(0.0, 1.0), 60)
	_check("warden: walking back is the same speed (along 21)", _near(_along(sim, 30.0), 21.0), str(_along(sim, 30.0)))

	# From x -1.75 (30 ticks left), so the diagonal (x share 2.47 m) stays clear of the right rail.
	sim = _placed(17.5)
	_push(sim, Vector2(-1.0, 0.0), 30)
	var diagonal: Vector2 = Vector2(1.0, -1.0).normalized()
	_push(sim, diagonal, 60)
	var moved: float = Vector2(sim.warden.position.x + 1.75, _along(sim, 30.0) - 17.5).length()
	_check("warden: a diagonal covers 3.5 m in 60 ticks", _near(moved, 3.5), str(moved))

	sim = _placed(17.5)
	_push(sim, Vector2(0.0, -0.5), 60)
	_check("warden: half a wish covers 1.75 m", _near(_along(sim, 30.0), 15.75), str(_along(sim, 30.0)))

	sim = _placed(17.5)
	sim.set_move(Vector2(0.0, -1.0))
	sim.advance()
	_check("warden: full speed on the first tick (no ramp)", _near(_along(sim, 30.0), 17.5 - STEP), str(_along(sim, 30.0)))
	sim.set_move(Vector2.ZERO)
	sim.advance()
	_check("warden: still on the first tick with no wish", _near(_along(sim, 30.0), 17.5 - STEP), str(_along(sim, 30.0)))
	_check("warden: walking reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_shared_edges_are_crossed() -> void:
	# From the landing (along 32) to section 1 in 60-tick blocks of 3.5 m: no stop at any shared
	# edge (section 6 to the landing, section to section). The tenth block meets the far pier.
	var sim: NightSim = _placed(-1.0)
	var wanted: Array[float] = [28.5, 25.0, 21.5, 18.0, 14.5, 11.0, 7.5, 4.0, 0.5]
	var got: Array[float] = []
	var ok: bool = true
	for want: float in wanted:
		_push(sim, Vector2(0.0, -1.0), 60)
		got.append(_along(sim, 30.0))
		ok = ok and _near(_along(sim, 30.0), want)
	_check("warden: landing to section 1 without stopping at a shared edge", ok, str(got))
	_push(sim, Vector2(0.0, -1.0), 60)
	_check("warden: then stops 0.3 m from the far pier (D1)", _near(_along(sim, 30.0), 0.3), str(_along(sim, 30.0)))


func _test_edges_stop_the_warden() -> void:
	# AC 5, D1: 0.3 m from every edge not shared: rails at x +-2.5, the far pier at along 0, the
	# landing's back at along length + 4 and its sides at x +-2.5.
	var sim: NightSim = _placed(17.5)
	_push(sim, Vector2(-1.0, 0.0), 120)
	_check("warden: into the left rail: x -2.2", _near(sim.warden.position.x, -2.2), str(sim.warden.position.x))
	sim = _placed(17.5)
	_push(sim, Vector2(1.0, 0.0), 120)
	_check("warden: into the right rail: x 2.2", _near(sim.warden.position.x, 2.2), str(sim.warden.position.x))
	sim = _placed(2.0)
	_push(sim, Vector2(0.0, -1.0), 120)
	_check("warden: into the far pier: along 0.3", _near(_along(sim, 30.0), 0.3), str(_along(sim, 30.0)))
	sim = _placed(-1.0)
	_push(sim, Vector2(0.0, 1.0), 120)
	_check("warden: into the landing's back: along 33.7", _near(_along(sim, 30.0), 33.7), str(_along(sim, 30.0)))
	sim = _placed(-1.0, 4)
	_push(sim, Vector2(0.0, 1.0), 120)
	_check("warden: into the landing's back on 4 sections: along 23.7", _near(_along(sim, 20.0), 23.7),
			str(_along(sim, 20.0)))
	sim = _placed(-1.0)
	_push(sim, Vector2(-1.0, 0.0), 120)
	var left: float = sim.warden.position.x
	sim = _placed(-1.0)
	_push(sim, Vector2(1.0, 0.0), 120)
	_check("warden: into the landing's sides: x -2.2 and 2.2", _near(left, -2.2) and _near(sim.warden.position.x, 2.2),
			"%f %f" % [left, sim.warden.position.x])

	# A diagonal into a rail slides: x stops at the limit, along keeps its own share.
	sim = _placed(17.5)
	var wish: Vector2 = Vector2(1.0, -1.0).normalized()
	_push(sim, wish, 120)
	var want_along: float = 17.5 + 120 * wish.y * 3.5 / 60.0
	_check("warden: a diagonal into the right rail slides along it", _near(sim.warden.position.x, 2.2)
			and _near(_along(sim, 30.0), want_along), "%s, along %f wanted %f" % [sim.warden.position, _along(sim, 30.0), want_along])
	_check("warden: pushing into edges reports no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_section_with_no_planks_blocks() -> void:
	# Story 1.3 D1: a plankless section's edge is not shared, so the feet stop 0.3 m short of it.
	# Story 1.6 D1: only 0.5 s (30 ticks) of pushing straight into it at the stop begins an edging,
	# so a walk that reaches the stop and pushes on for under that stops there.
	var sim: NightSim = _placed(17.5, 6, {3: 0})
	_push(sim, Vector2(0.0, -1.0), 40)
	_check("warden: from section 4 toward the far pier, stops at along 15.3", _near(_along(sim, 30.0), 15.3)
			and WardenRules.walking(sim), str(_along(sim, 30.0)))
	sim = _placed(7.5, 6, {3: 0})
	_push(sim, Vector2(0.0, 1.0), 40)
	_check("warden: from section 2 toward the town, stops at along 9.7", _near(_along(sim, 30.0), 9.7)
			and WardenRules.walking(sim), str(_along(sim, 30.0)))
	# Story 1.6 AC 9: with nothing to stand on beyond it (section 1 open, the far pier past it) the stop
	# holds for good: 600 ticks of pushing.
	sim = _placed(7.5, 6, {1: 0})
	var events: Array[NightEvent] = []
	for i: int in 600:
		sim.set_move(Vector2(0.0, -1.0))
		events.append_array(sim.advance())
	_check("warden: section 1 open, the far pier beyond: stops at along 5.3 for good, nothing begins",
			_near(_along(sim, 30.0), 5.3) and WardenRules.walking(sim) and _kinds(events) == [NightEvent.Kind.NIGHT_STARTED],
			"%f %s" % [_along(sim, 30.0), _kinds(events)])
	sim = _placed(17.5, 6, {3: 1})
	_push(sim, Vector2(0.0, -1.0), 60)
	_check("warden: one plank is enough to walk on (along 14.0)", _near(_along(sim, 30.0), 14.0), str(_along(sim, 30.0)))
	_check("warden: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_placed_start() -> void:
	# D3: StartState.warden_along, metres from the far pier on the centre line.
	var sim: NightSim = _placed(17.5)
	_check("warden: warden_along 17.5 starts at (0, 0, -12.5)", sim.warden.position.is_equal_approx(Vector3(0.0, 0.0, -12.5)),
			str(sim.warden.position))
	_check("warden: a good start reports no fault", _faults.total() == 0, str(_faults.codes()))
	var bad: Array[Array] = [[12.5, {3: 0}, "a plankless section"], [-2.0, {}, "the far pier"],
			[0.1, {}, "inside the far pier's clearance"], [40.0, {}, "past the landing"]]
	for case: Array in bad:
		var planks: Dictionary[int, int] = {}
		planks.assign(case[1])
		_expect_begin()
		sim = _placed(case[0], 6, planks)
		_expect_end("warden: a start on %s is warden.bad_start" % case[2], [["ERROR", "warden.bad_start", 1]])
		_check("warden: reported once, and the warden starts on the landing (%s)" % case[2],
				_faults.count(&"warden.bad_start") == 1 and sim.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
				"%d %s" % [_faults.count(&"warden.bad_start"), sim.warden.position])


func _test_can_stand() -> void:
	var sim: NightSim = _placed(17.5, 6, {3: 0})
	# Every place the tests above reach.
	var good: Array[Vector3] = [Vector3(0, 0, 2), Vector3(-2.2, 0, -12.5), Vector3(2.2, 0, -12.5), Vector3(0, 0, -29.7),
			Vector3(0, 0, 3.7), Vector3(-2.2, 0, 2), Vector3(2.2, 0, 2), Vector3(0, 0, -14.7), Vector3(0, 0, -20.3),
			Vector3(0, 0, -5.0), Vector3(0, 0, 0.0)]
	var wrong: PackedStringArray = []
	for p: Vector3 in good:
		if not WardenRules.can_stand(p, sim):
			wrong.append(str(p))
	_check("warden: can_stand at every place the warden reaches", wrong.is_empty(), str(wrong))
	_check("warden: not at x 2.3", not WardenRules.can_stand(Vector3(2.3, 0, -12.5), sim))
	_check("warden: not at x -2.3", not WardenRules.can_stand(Vector3(-2.3, 0, -12.5), sim))
	_check("warden: not at along 0.2", not WardenRules.can_stand(Vector3(0, 0, -29.8), sim))
	_check("warden: not on a plankless section", not WardenRules.can_stand(Vector3(0, 0, -17.5), sim))
	_check("warden: not within 0.3 m of a plankless section", not WardenRules.can_stand(Vector3(0, 0, -14.8), sim))
	_check("warden: not at along length + 3.8", not WardenRules.can_stand(Vector3(0, 0, 3.8), sim))
	_check("warden: not at a point that is not a number", not WardenRules.can_stand(Vector3(NAN, 0, 2), sim))
	_check("warden: asking reports no fault", _faults.total() == 0, str(_faults.codes()))


## Walks from `from` by `step` a tick on `floors` until a tick moves nothing; where it stopped.
func _walk_until_stopped(from: Vector3, step: Vector3, floors: Array[Rect2]) -> Vector3:
	var at: Vector3 = from
	for i: int in 600:
		var next: Vector3 = WardenRules.reach(at, step, floors)
		if next == at:
			break
		at = next
	return at


func _test_stops_exactly_where_floors_differ_in_width() -> void:
	# The landing's width is a gray-box size (D2 of story 1.2), so the rule may not lean on it
	# being the sections' 5 m. A deck 5 m wide (x -2.5 to 2.5, z -30 to 0) with a landing 7 m wide
	# and then 3 m wide (z 0 to 4): the stop is where a probe 0.3 m (D1) to the side or ahead
	# leaves the floor, to within 0.001 m, whatever the step's phase.
	var deck: Rect2 = Rect2(-2.5, -30.0, 5.0, 30.0)
	var wide: Array[Rect2] = [deck, Rect2(-3.5, 0.0, 7.0, 4.0)]
	# At x 2.3 the right-hand probe (x 2.6) is only on the landing: walking to the span stops at z 0.
	var a: Vector3 = _walk_until_stopped(Vector3(2.3, 0.0, 1.0), Vector3(0.0, 0.0, -STEP), wide)
	_check("warden: wide landing, x 2.3, toward the span: stops at z 0", absf(a.z) < TOL and absf(a.x - 2.3) < TOL, str(a))
	# At z 0.1 the probe toward the span (z -0.2) is on the deck only up to x 2.5.
	var b: Vector3 = _walk_until_stopped(Vector3(2.0, 0.0, 0.1), Vector3(STEP, 0.0, 0.0), wide)
	_check("warden: wide landing, z 0.1, to the right: stops at x 2.5", absf(b.x - 2.5) < TOL, str(b))
	# Further in (z 1.0) nothing but the landing's own side stops it: 3.5 - 0.3.
	var c: Vector3 = _walk_until_stopped(Vector3(2.0, 0.0, 1.0), Vector3(STEP, 0.0, 0.0), wide)
	_check("warden: wide landing, z 1.0, to the right: stops at x 3.2", absf(c.x - 3.2) < TOL, str(c))
	var narrow: Array[Rect2] = [deck, Rect2(-1.5, 0.0, 3.0, 4.0)]
	# At x 1.3 the right-hand probe (x 1.6) is only on the deck: walking to the town stops at z 0.
	var d: Vector3 = _walk_until_stopped(Vector3(1.3, 0.0, -1.0), Vector3(0.0, 0.0, STEP), narrow)
	_check("warden: narrow landing, x 1.3, toward the town: stops at z 0", absf(d.z) < TOL, str(d))
	# On the centre line the narrow landing is walked onto, to its back less the clearance.
	var e: Vector3 = _walk_until_stopped(Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, STEP), narrow)
	_check("warden: narrow landing, centre line: on to z 3.7", absf(e.z - 3.7) < TOL, str(e))
	for stopped: Vector3 in [a, b, c, d, e]:
		var floors: Array[Rect2] = wide if stopped in [a, b, c] else narrow
		_check("warden: where it stopped (%s) can be stood on" % stopped, WardenRules.stands_on(stopped, floors))


# --- Story 1.5: the climb, a fallen section is no floor, the warden adds no load ---------------
# GD-19 / GDD Game Mechanics 2: 3 planks under 4 weights falls on tick 120; the climb back is 5 s
# (300 ticks).

func _loaded(along: float, planks: Dictionary[int, int], weights: Dictionary[int, int]) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	start.weights = weights
	return _sim_with(_def_with(start), 1)


func _test_the_move_wish_does_nothing_while_climbing() -> void:
	var sim: NightSim = _loaded(17.5, {4: 3}, {4: 4})
	_push(sim, Vector2.ZERO, 121)
	var hang: Vector3 = sim.warden.position
	_check("warden: climbing after the fall", not WardenRules.walking(sim) and sim.warden.move == WardenState.Move.CLIMBING)
	var still: bool = true
	for wish: Vector2 in [Vector2(0.0, 1.0), Vector2(0.0, -1.0), Vector2(1.0, 0.0), Vector2(-0.70710678, 0.70710678)]:
		_push(sim, wish, 20)
		still = still and sim.warden.position == hang
	_check("warden: no wish moves a climbing warden", still, str(sim.warden.position))
	_check("warden: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_fallen_section_is_no_floor() -> void:
	# Section 4 falls with the warden on the landing; section 2 is bare and stands.
	var sim: NightSim = _loaded(-1.0, {2: 0, 4: 3}, {4: 4})
	_push(sim, Vector2.ZERO, 121)
	_check("warden: section 4 has fallen", sim.span.fallen(4))
	var floors: Array[Rect2] = WardenRules.walkable(sim)
	_check("warden: walkable is sections 1, 3, 5, 6 and the landing", floors.size() == 5, str(floors))


func _test_the_warden_adds_no_load() -> void:
	# AC 9: 3 planks, 3 weights, the warden standing mid section 4: it creaks, never groans.
	var sim: NightSim = _loaded(17.5, {4: 3}, {4: 3})
	var kinds: Array[NightEvent.Kind] = []
	for i: int in 300:
		sim.set_move(Vector2(0.0, 0.0))
		for event: NightEvent in sim.advance():
			kinds.append(event.kind)
	_check("warden: on a section at its limit it only creaks", kinds == [NightEvent.Kind.NIGHT_STARTED,
			NightEvent.Kind.CREAK_STARTED], str(kinds))
	# 300 ticks is 5 s, more than the 2 s of a groan (GD-19): had the warden counted as a load of any
	# size, 3 planks would have groaned from tick 0 and fallen on tick 120.
	_check("warden: after 5 s on it the section stands, creaking, the warden still on it (along 17.5)",
			not sim.span.fallen(4) and sim.span.creaking(4) and sim.span.groan_left(4) == 0 and WardenRules.walking(sim)
			and sim.warden.position.distance_to(Vector3(0.0, 0.0, -12.5)) < 0.001, str(sim.warden.position))


func _test_warden_state_values() -> void:
	# The checksum's warden facts: each changes values().
	var base: Array = WardenState.new().values()
	var changes: Dictionary[String, Callable] = {
		"move": func(w: WardenState) -> void: w.move = WardenState.Move.EDGING,
		"ticks left": func(w: WardenState) -> void: w.move_ticks_left = 5,
		"fell_from": func(w: WardenState) -> void: w.fell_from = 4,
		"the move's section": func(w: WardenState) -> void: w.move_section = 3,
		"the move's way": func(w: WardenState) -> void: w.move_toward = -1,
		"the move's start": func(w: WardenState) -> void: w.move_from = Vector3(0.0, 0.0, -14.7),
		"the move's end": func(w: WardenState) -> void: w.move_to = Vector3(2.2, 0.0, -20.0),
		"the move's length": func(w: WardenState) -> void: w.move_ticks_total = 240,
		"the push": func(w: WardenState) -> void: w.pushed = 12,
	}
	for what: String in changes:
		var warden: WardenState = WardenState.new()
		changes[what].call(warden)
		_check("warden: %s changes values()" % what, warden.values() != base)
	_check("warden: the moves are WALKING, CLIMBING, EDGING, CROSSING", WardenState.Move.keys()
			== ["WALKING", "CLIMBING", "EDGING", "CROSSING"], str(WardenState.Move.keys()))


# --- Story 1.6: edging round an open section, crossing a gap, the push, runs, turning back ------
# GDD Game Mechanics 2: the warden edges round an open section in 4 s (240 ticks) and crosses a gap
# hand over hand in 8 s (480). Decision D1: a move begins after 0.5 s (30 ticks) of pushing straight
# into it at the stop (within 45 degrees), in step 1 of the 31st tick in a row. D2 and Sonlm's plays
# of M1: edging, the feet stay at deck height and sidestep onto the nearer side beam's line (x +-2.2:
# the 5 m deck less the 0.3 m clearance, right when x >= 0) in the first 0.5 s; crossing, they hang
# 2.4 m below the deck under the gap's rope, on the centre line (x 0). A move ends with the feet on
# the next floor 0.3 m in: an edging's line runs on to that spot, so its every tick is the same size
# (code review 2026-11-22); a crossing cuts up onto it. One night is 30 m: world z = along - 30.

## "tick KIND sN[ L|R]" for every event but NIGHT_STARTED.
func _story_of(events: Array[NightEvent]) -> PackedStringArray:
	var out: PackedStringArray = []
	for event: NightEvent in events:
		if event.kind == NightEvent.Kind.NIGHT_STARTED:
			continue
		var line: String = "%d %s s%d" % [roundi(event.t * 60.0), NightEvent.Kind.find_key(event.kind), event.section]
		if event.kind == NightEvent.Kind.EDGING_STARTED or event.kind == NightEvent.Kind.EDGING_ENDED:
			line += " L" if event.side == NightTypes.Side.LEFT else " R"
		out.append(line)
	return out


## Runs until sim.tick == `tick` with `wish` on every tick; every event.
func _push_until(sim: NightSim, wish: Vector2, tick: int) -> Array[NightEvent]:
	var events: Array[NightEvent] = []
	while sim.tick < tick:
		sim.set_move(wish)
		events.append_array(sim.advance())
	return events


func _at(sim: NightSim, want: Vector3) -> bool:
	return sim.warden.position.distance_to(want) < TOL


## A night of 6 sections with `planks`, `fallen` and `weights`, the warden placed at `along`.
func _broken(along: float, planks: Dictionary[int, int], fallen: Array[int] = [],
		weights: Dictionary[int, int] = {}) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	start.fallen = fallen
	start.weights = weights
	return _sim_with(_def_with(start), 1)


func _test_walking_into_an_open_section_edges_round_it() -> void:
	# AC 1, L2: section 3 open; placed at along 15.3 (section 4, at the stop), pushing toward the far
	# pier from tick 0.
	var sim: NightSim = _broken(15.3, {3: 0})
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 30)
	_check("edge: ticks 0 to 29 pushing: nothing begins", _story_of(events).is_empty() and WardenRules.walking(sim)
			and _at(sim, Vector3(0.0, 0.0, -14.7)), "%s %s" % [_story_of(events), sim.warden.position])
	events = _push_until(sim, Vector2(0.0, -1.0), 31)
	_check("edge: EDGING_STARTED s3 R on tick 30 (D1: the 31st tick of pushing)",
			_story_of(events) == PackedStringArray(["30 EDGING_STARTED s3 R"]), str(_story_of(events)))
	_check("edge: on tick 30 the feet are still where they stood, (0, 0, -14.7); not walking",
			_at(sim, Vector3(0.0, 0.0, -14.7)) and not WardenRules.walking(sim) and sim.warden.move == WardenState.Move.EDGING,
			str(sim.warden.position))
	# Sonlm's play of M1 (2026-11-22): the edging sidesteps onto the beam line in its first 0.5 s
	# (30 ticks), then goes straight along it; the along part moves steadily over the whole 240.
	# Code review 2026-11-22 (Sonlm): the line runs from the stop (along 15.3) to the spot the feet
	# step off at, 0.3 m onto section 2 (along 9.7): 5.6 m in 240 ticks, 0.023333 m on every tick, the
	# last one too (before, the line ended at the section's edge and the last tick added the 0.3 m).
	events = _push_until(sim, Vector2(0.0, -1.0), 46)
	_check("edge: tick 45, a quarter second in: half way across to the beam, (1.1, 0, -15.05)",
			_at(sim, Vector3(1.1, 0.0, -15.05)), str(sim.warden.position))
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 61))
	_check("edge: tick 60, 0.5 s in: on the beam line, (2.2, 0, -15.4)",
			_at(sim, Vector3(2.2, 0.0, -15.4)), str(sim.warden.position))
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 151))
	_check("edge: tick 150, half way: straight along the beam, (2.2, 0, -17.5), nothing else happened",
			_story_of(events).is_empty() and _at(sim, Vector3(2.2, 0.0, -17.5)), str(sim.warden.position))
	events = _push_until(sim, Vector2(0.0, -1.0), 270)
	_check("edge: tick 269, its last tick but one: (2.2, 0, -20.276667), one tick's 0.023333 m short of the end",
			_story_of(events).is_empty() and _at(sim, Vector3(2.2, 0.0, -20.276667)), str(sim.warden.position))
	events.append_array(_push_until(sim, Vector2.ZERO, 271))
	_check("edge: EDGING_ENDED s3 R on tick 270 (30 + 240)", _story_of(events) == PackedStringArray(["270 EDGING_ENDED s3 R"]),
			str(_story_of(events)))
	_check("edge: on section 2, 0.3 m in, on the right beam's line: (2.2, 0, -20.3), walking",
			_at(sim, Vector3(2.2, 0.0, -20.3)) and WardenRules.walking(sim) and WardenRules.can_stand(sim.warden.position, sim),
			str(sim.warden.position))
	_check("edge: no fault", _faults.total() == 0, str(_faults.codes()))

	# The other way: placed at along 9.7 (section 2), pushing toward the town.
	sim = _broken(9.7, {3: 0})
	events = _push_until(sim, Vector2(0.0, 1.0), 270)
	events.append_array(_push_until(sim, Vector2.ZERO, 271))
	_check("edge town: EDGING_STARTED s3 R on 30, EDGING_ENDED s3 R on 270",
			_story_of(events) == PackedStringArray(["30 EDGING_STARTED s3 R", "270 EDGING_ENDED s3 R"]), str(_story_of(events)))
	_check("edge town: ends on section 4 at (2.2, 0, -14.7)", _at(sim, Vector3(2.2, 0.0, -14.7)) and WardenRules.walking(sim),
			str(sim.warden.position))

	# The walk runs on the tick a move ends: a wish still down then moves them one step on.
	sim = _broken(15.3, {3: 0})
	events = _push_until(sim, Vector2(0.0, -1.0), 271)
	_check("edge: with the wish kept, the end tick also walks one step: (2.2, 0, -20.3 - 3.5/60)",
			_story_of(events) == PackedStringArray(["30 EDGING_STARTED s3 R", "270 EDGING_ENDED s3 R"])
			and _at(sim, Vector3(2.2, 0.0, -20.3 - STEP)), str(sim.warden.position))

	# Left of the centre line the left beam: 20 ticks to x -1.167 (a push across, so no count), then in.
	sim = _broken(15.3, {3: 0})
	_push(sim, Vector2(-1.0, 0.0), 20)
	var began: int = sim.tick
	events = _push_until(sim, Vector2(0.0, -1.0), began + 30)
	_check("edge left: a sideways walk is no push: nothing yet", _story_of(events).is_empty(), str(_story_of(events)))
	events = _push_until(sim, Vector2(0.0, -1.0), began + 31)
	events.append_array(_push_until(sim, Vector2.ZERO, began + 31 + 240))
	_check("edge left: EDGING_STARTED s3 L on the 31st pushing tick, EDGING_ENDED s3 L 240 later",
			_story_of(events) == PackedStringArray(["%d EDGING_STARTED s3 L" % (began + 30), "%d EDGING_ENDED s3 L" % (began + 270)]),
			str(_story_of(events)))
	_check("edge left: ends at (-2.2, 0, -20.3)", _at(sim, Vector3(-2.2, 0.0, -20.3)), str(sim.warden.position))
	_check("edge left: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_warden_on_the_beams_adds_no_load() -> void:
	# AC 3: "the warden on the beams adds no load". Section 3 open with 2 test weights, exactly the
	# side beams' 2: it creaks from tick 0. The warden edges along it (L2's ticks) and it never groans.
	var sim: NightSim = _broken(15.3, {3: 0}, [], {3: 2})
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 270)
	events.append_array(_push_until(sim, Vector2.ZERO, 400))
	_check("beams: at a load of 2 it creaks, the warden edges along it, no groan", _story_of(events) == PackedStringArray([
			"0 CREAK_STARTED s3", "30 EDGING_STARTED s3 R", "270 EDGING_ENDED s3 R"]) and not sim.span.fallen(3),
			str(_story_of(events)))
	_check("beams: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_start_on_a_fallen_section() -> void:
	# AC 11: a placed start on a section that starts fallen cannot be stood on: warden.bad_start, and
	# the warden starts on the landing (along 32: z 2).
	var start: StartState = StartState.new()
	start.fallen = [3]
	start.warden_along = 12.5
	_expect_begin()
	var sim: NightSim = _sim_with(_def_with(start), 1)
	_expect_end("warden: a start on a fallen section is warden.bad_start", [["ERROR", "warden.bad_start", 1]])
	_check("warden: and the warden starts on the landing", sim.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(sim.warden.position))


func _test_the_move_wish_is_ignored_while_edging_and_crossing() -> void:
	# AC 1 and AC 5: no input but look. The same night twice, pushing in for 31 ticks, then one gets
	# no wish and the other a different wish every tick: the feet are the same on every tick.
	for case: Array in [[{3: 0}, [] as Array[int], "an edging"], [{}, [3] as Array[int], "a crossing"]]:
		var planks: Dictionary[int, int] = {}
		planks.assign(case[0])
		var fallen: Array[int] = []
		fallen.assign(case[1])
		var still: NightSim = _broken(15.3, planks, fallen)
		var busy: NightSim = _broken(15.3, planks, fallen)
		_push_until(still, Vector2(0.0, -1.0), 31)
		_push_until(busy, Vector2(0.0, -1.0), 31)
		var same: bool = not WardenRules.walking(busy)
		for i: int in 200:
			still.set_move(Vector2.ZERO)
			busy.set_move(Vector2.from_angle(i * 0.7))
			busy.set_view(i * 0.05, 0.3)
			still.advance()
			busy.advance()
			same = same and busy.warden.position == still.warden.position
		_check("moves: during %s the move wish moves nothing" % case[2], same, str(busy.warden.position))
		_check("moves: and the view still turns (%s)" % case[2], is_equal_approx(busy.yaw, 199 * 0.05), str(busy.yaw))


func _test_the_push() -> void:
	# D1, L10: section 3 open, placed at 15.3. 30 ticks of pushing, then a tick without: the count
	# starts again; pushing again from tick 31, the edging begins on tick 61.
	var sim: NightSim = _broken(15.3, {3: 0})
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 30)
	events.append_array(_push_until(sim, Vector2.ZERO, 31))
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 61))
	_check("push: 30 ticks, a tick without, 30 more: nothing begins", _story_of(events).is_empty() and WardenRules.walking(sim),
			str(_story_of(events)))
	events = _push_until(sim, Vector2(0.0, -1.0), 62)
	_check("push: the 31st in a row (tick 61) begins it", _story_of(events) == PackedStringArray(["61 EDGING_STARTED s3 R"]),
			str(_story_of(events)))
	# More across than along (0.8, -0.6): never a push; the feet slide along the edge to the rail.
	sim = _broken(15.3, {3: 0})
	events = _push_until(sim, Vector2(0.8, -0.6), 600)
	_check("push: a slanted push (0.8, -0.6) never begins one in 600 ticks", _story_of(events).is_empty()
			and WardenRules.walking(sim), str(_story_of(events)))
	_check("push: the feet slid along the edge to the right rail: (2.2, 0, -14.7)", _at(sim, Vector3(2.2, 0.0, -14.7)),
			str(sim.warden.position))
	# Exactly 45 degrees is within it (along part as large as the across part).
	sim = _broken(15.3, {3: 0})
	events = _push_until(sim, Vector2(1.0, -1.0).normalized(), 31)
	_check("push: at 45 degrees it begins on tick 30", _story_of(events) == PackedStringArray(["30 EDGING_STARTED s3 R"]),
			str(_story_of(events)))
	# The walk up to the stop is no push: 10 ticks away (0.583 m), then toward it from tick 10. The
	# feet are back at the stop on tick 19, the first tick that counts; the 31st is tick 49. Had the 9
	# ticks of walking up counted, it would begin on tick 40.
	sim = _broken(15.3, {3: 0})
	events = _push_until(sim, Vector2(0.0, 1.0), 10)
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 49))
	_check("push: ticks 10 to 48, walking up then 30 at the stop: nothing begins", _story_of(events).is_empty()
			and _at(sim, Vector3(0.0, 0.0, -14.7)), "%s %s" % [_story_of(events), sim.warden.position])
	events = _push_until(sim, Vector2(0.0, -1.0), 50)
	_check("push: it begins on tick 49, the 31st at the stop", _story_of(events) == PackedStringArray(["49 EDGING_STARTED s3 R"]),
			str(_story_of(events)))
	# Along the deck with nothing ahead (mid section 4, 2.5 m from the open section): no count.
	sim = _broken(17.5, {3: 0})
	_push_until(sim, Vector2(0.0, -1.0), 10)
	_check("push: walking along the deck toward it from 2.5 m away counts nothing", sim.warden.pushed == 0
			and WardenRules.walking(sim), str(sim.warden.pushed))
	_check("push: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_crossing_a_gap() -> void:
	# AC 5, L3: section 3 fallen from the start; placed at 15.3, pushing toward the far pier.
	var sim: NightSim = _broken(15.3, {}, [3])
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 31)
	_check("gap: CROSSING_STARTED s3 on tick 30", _story_of(events) == PackedStringArray(["30 CROSSING_STARTED s3"]),
			str(_story_of(events)))
	# Sonlm's play of M1 (2026-11-22): the warden hangs from the one rope left across the gap, on its
	# centre line (x 0), the feet 2.4 m below deck level (the eye 0.8 m below it, 0.3 m under the
	# rope's lowest point).
	_check("gap: cut down to hang under the rope at the near edge: (0, -2.4, -15.0)", _at(sim, Vector3(0.0, -2.4, -15.0))
			and sim.warden.move == WardenState.Move.CROSSING, str(sim.warden.position))
	# Sonlm's play of M1 (2026-11-22): hand over hand, in reaches of 0.5 m (10 over the 5 m gap, 48
	# ticks each): each a pull eased over its first 60 % (smoothstep), then still until the next.
	# From tick 30: tick 54 (24 in, half a reach): 0.925926 of the first reach, z -15.462963; ticks 59
	# to 78 (29 to 48 in): still at the end of the first reach, z -15.5; tick 79 moving again.
	_push_until(sim, Vector2(0.0, -1.0), 55)
	_check("gap: tick 54, half way through the first reach's time: (0, -2.4, -15.462963)",
			_at(sim, Vector3(0.0, -2.4, -15.462963)), str(sim.warden.position))
	var still: bool = true
	for i: int in 20:
		_push_until(sim, Vector2(0.0, -1.0), 60 + i)
		still = still and _at(sim, Vector3(0.0, -2.4, -15.5))
	_check("gap: ticks 59 to 78: still at the first reach's end, (0, -2.4, -15.5)", still, str(sim.warden.position))
	_push_until(sim, Vector2(0.0, -1.0), 80)
	_check("gap: tick 79: the next reach has begun", sim.warden.position.z < -15.5 - 0.0005, str(sim.warden.position))
	_push_until(sim, Vector2(0.0, -1.0), 271)
	_check("gap: tick 270, half way (5 reaches): (0, -2.4, -17.5)", _at(sim, Vector3(0.0, -2.4, -17.5)), str(sim.warden.position))
	events = _push_until(sim, Vector2(0.0, -1.0), 510)
	events.append_array(_push_until(sim, Vector2.ZERO, 511))
	_check("gap: CROSSING_ENDED s3 on tick 510 (30 + 480)", _story_of(events) == PackedStringArray(["510 CROSSING_ENDED s3"]),
			str(_story_of(events)))
	_check("gap: up on section 2, 0.3 m in: (0, 0, -20.3), walking", _at(sim, Vector3(0.0, 0.0, -20.3))
			and WardenRules.walking(sim), str(sim.warden.position))
	# The other way.
	sim = _broken(9.7, {}, [3])
	events = _push_until(sim, Vector2(0.0, 1.0), 510)
	events.append_array(_push_until(sim, Vector2.ZERO, 511))
	_check("gap town: CROSSING_STARTED s3 on 30, CROSSING_ENDED s3 on 510",
			_story_of(events) == PackedStringArray(["30 CROSSING_STARTED s3", "510 CROSSING_ENDED s3"]), str(_story_of(events)))
	_check("gap town: up on section 4 at (0, 0, -14.7)", _at(sim, Vector3(0.0, 0.0, -14.7)), str(sim.warden.position))
	# Two gaps side by side: 8 s each, the second begun on the tick the first ends.
	sim = _broken(20.3, {}, [3, 4])
	events = _push_until(sim, Vector2(0.0, -1.0), 990)
	events.append_array(_push_until(sim, Vector2.ZERO, 991))
	_check("gaps: s4 30 to 510, s3 510 to 990", _story_of(events) == PackedStringArray(["30 CROSSING_STARTED s4",
			"510 CROSSING_ENDED s4", "510 CROSSING_STARTED s3", "990 CROSSING_ENDED s3"]), str(_story_of(events)))
	_check("gaps: up on section 2 at (0, 0, -20.3)", _at(sim, Vector3(0.0, 0.0, -20.3)), str(sim.warden.position))
	sim = _broken(9.7, {}, [3, 4])
	events = _push_until(sim, Vector2(0.0, 1.0), 990)
	events.append_array(_push_until(sim, Vector2.ZERO, 991))
	_check("gaps town: s3 then s4, onto section 5 at (0, 0, -9.7)", _story_of(events) == PackedStringArray([
			"30 CROSSING_STARTED s3", "510 CROSSING_ENDED s3", "510 CROSSING_STARTED s4", "990 CROSSING_ENDED s4"])
			and _at(sim, Vector3(0.0, 0.0, -9.7)), "%s %s" % [_story_of(events), sim.warden.position])
	_check("gap: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_crossing_goes_onto_the_rope() -> void:
	# Sonlm's play of M1: off the centre line (20 ticks to the right: x 1.1667, a sideways walk, no
	# push), the crossing's start cut puts the feet under the rope at x 0, and they come up at x 0.
	var sim: NightSim = _broken(15.3, {}, [3])
	_push(sim, Vector2(1.0, 0.0), 20)
	var began: int = sim.tick
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), began + 31)
	_check("rope: CROSSING_STARTED s3 on the 31st pushing tick, the feet at (0, -2.4, -15.0)",
			_story_of(events) == PackedStringArray(["%d CROSSING_STARTED s3" % (began + 30)]) and _at(sim, Vector3(0.0, -2.4, -15.0)),
			"%s %s" % [_story_of(events), sim.warden.position])
	_push_until(sim, Vector2.ZERO, began + 30 + 481)
	_check("rope: up on section 2 at (0, 0, -20.3)", _at(sim, Vector3(0.0, 0.0, -20.3)) and WardenRules.walking(sim),
			str(sim.warden.position))


func _test_a_run_is_crossed_one_section_at_a_time() -> void:
	# AC 9, L9: fallen section 4 then open section 3, walked into from section 5 (along 20.3): a
	# crossing (480), then an edging (240) from where the crossing ended, onto section 2.
	var sim: NightSim = _broken(20.3, {3: 0}, [4])
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 750)
	events.append_array(_push_until(sim, Vector2.ZERO, 751))
	_check("run: s4 crossed 30 to 510, s3 edged 510 to 750", _story_of(events) == PackedStringArray([
			"30 CROSSING_STARTED s4", "510 CROSSING_ENDED s4", "510 EDGING_STARTED s3 R", "750 EDGING_ENDED s3 R"]),
			str(_story_of(events)))
	_check("run: onto section 2 at (2.2, 0, -20.3)", _at(sim, Vector3(2.2, 0.0, -20.3)) and WardenRules.walking(sim),
			str(sim.warden.position))
	# Toward the town a run always ends on a floor: fallen 5 and open 6 end on the landing.
	sim = _broken(19.7, {6: 0}, [5])
	events = _push_until(sim, Vector2(0.0, 1.0), 750)
	events.append_array(_push_until(sim, Vector2.ZERO, 751))
	_check("run town: s5 crossed, s6 edged, onto the landing at (2.2, 0, 0.3)", _story_of(events) == PackedStringArray([
			"30 CROSSING_STARTED s5", "510 CROSSING_ENDED s5", "510 EDGING_STARTED s6 R", "750 EDGING_ENDED s6 R"])
			and _at(sim, Vector3(2.2, 0.0, 0.3)), "%s %s" % [_story_of(events), sim.warden.position])
	# Two open sections in a row (code review 2026-11-22): open 3 and open 2, from along 15.3. The
	# first edging's line ends at section 3's far edge (an open section lies beyond, not a floor); the
	# second begins there on the same tick, on the beam line already (no sidestep), and runs 5.3 m to
	# 0.3 m onto section 1.
	sim = _broken(15.3, {2: 0, 3: 0})
	events = _push_until(sim, Vector2(0.0, -1.0), 271)
	_check("run: two opens: s3 edged 30 to 270, s2 begun on 270 at s3's far edge on the beam line: (2.2, 0, -20.0)",
			_story_of(events) == PackedStringArray(["30 EDGING_STARTED s3 R", "270 EDGING_ENDED s3 R", "270 EDGING_STARTED s2 R"])
			and _at(sim, Vector3(2.2, 0.0, -20.0)), "%s %s" % [_story_of(events), sim.warden.position])
	events = _push_until(sim, Vector2(0.0, -1.0), 391)
	_check("run: two opens: tick 390, half way along section 2's 5.3 m: (2.2, 0, -22.65)", _story_of(events).is_empty()
			and _at(sim, Vector3(2.2, 0.0, -22.65)), str(sim.warden.position))
	events = _push_until(sim, Vector2(0.0, -1.0), 510)
	events.append_array(_push_until(sim, Vector2.ZERO, 511))
	_check("run: two opens: s2 ended on 510, onto section 1 at (2.2, 0, -25.3), walking",
			_story_of(events) == PackedStringArray(["510 EDGING_ENDED s2 R"]) and _at(sim, Vector3(2.2, 0.0, -25.3))
			and WardenRules.walking(sim) and _faults.total() == 0, "%s %s" % [_story_of(events), sim.warden.position])
	# Toward the far pier a run that ends at the far pier blocks like an edge: open 2, fallen 1.
	sim = _broken(10.3, {2: 0}, [1])
	events = _push_until(sim, Vector2(0.0, -1.0), 600)
	_check("run: open 2 and fallen 1 with the far pier beyond: nothing begins, the feet stay at 10.3",
			_story_of(events).is_empty() and _at(sim, Vector3(0.0, 0.0, -19.7)), str(_story_of(events)))
	_check("run: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_turning_back() -> void:
	# L8: section 2 open; section 1 at 1 plank with 2 weights (load 2 over strength 1: it groans from
	# tick 0 and falls on 120, GD-19). Placed at 10.3 pushing toward the far pier: the edging of 2
	# begins on 30 (the run then ends on section 1, standing). Section 1 falls on 120. When the edging
	# ends on 270 the way on ends at the far pier: the warden edges back over section 2 toward the town.
	# Code review 2026-11-22: the edging's line was set on tick 30 to end 0.3 m onto section 1 (a floor
	# then), and stays there when section 1 falls: on tick 269 the feet are at (2.2, 0, -25.276667),
	# at deck height past the beam's end over the new gap, not caught (an edging warden's footing is
	# the section edged). The edging back begins there: 5.6 m to 0.3 m onto section 3.
	var sim: NightSim = _broken(10.3, {1: 1, 2: 0}, [], {1: 2})
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 270)
	_check("back: tick 269: (2.2, 0, -25.276667), past the beam's end over the gap of section 1, still edging",
			_at(sim, Vector3(2.2, 0.0, -25.276667)) and sim.warden.move == WardenState.Move.EDGING, str(sim.warden.position))
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 271))
	_check("back: tick 270: the edging back begins where the feet are, (2.2, 0, -25.3)", _at(sim, Vector3(2.2, 0.0, -25.3))
			and sim.warden.move == WardenState.Move.EDGING and sim.warden.move_toward == 1, str(sim.warden.position))
	events.append_array(_push_until(sim, Vector2(0.0, -1.0), 510))
	events.append_array(_push_until(sim, Vector2.ZERO, 511))
	_check("back: edged out, section 1 fell, edged back", _story_of(events) == PackedStringArray([
			"0 GROAN_STARTED s1", "30 EDGING_STARTED s2 R", "120 SECTION_FELL s1", "270 EDGING_ENDED s2 R",
			"270 EDGING_STARTED s2 R", "510 EDGING_ENDED s2 R"]), str(_story_of(events)))
	_check("back: onto section 3 at (2.2, 0, -19.7), walking", _at(sim, Vector3(2.2, 0.0, -19.7)) and WardenRules.walking(sim),
			str(sim.warden.position))
	_check("back: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_turning_back_out_of_a_crossing() -> void:
	# Code review 2026-11-22: the same turn after a crossing. Section 3 fallen; section 2 at 1 plank
	# with 2 weights (it groans from tick 0 and falls on 120, GD-19); section 1 open. Placed at 15.3
	# pushing toward the far pier: the crossing of 3 begins on 30 (the run then ends on section 2,
	# standing). When it ends on 510 the way on is a gap, an open section and the far pier: the warden
	# crosses back over section 3 from the same edge, 480 more ticks, onto section 4.
	var sim: NightSim = _broken(15.3, {1: 0, 2: 1}, [3], {2: 2})
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 511)
	_check("back gap: crossed out, section 2 fell, the crossing back begins on 510", _story_of(events) == PackedStringArray([
			"0 GROAN_STARTED s2", "30 CROSSING_STARTED s3", "120 SECTION_FELL s2", "510 CROSSING_ENDED s3",
			"510 CROSSING_STARTED s3"]), str(_story_of(events)))
	_check("back gap: tick 510: hanging again at the edge just reached, (0, -2.4, -20.0), heading for the town",
			_at(sim, Vector3(0.0, -2.4, -20.0)) and sim.warden.move == WardenState.Move.CROSSING and sim.warden.move_toward == 1,
			str(sim.warden.position))
	events = _push_until(sim, Vector2(0.0, -1.0), 990)
	events.append_array(_push_until(sim, Vector2.ZERO, 991))
	_check("back gap: CROSSING_ENDED s3 on 990 (510 + 480), onto section 4 at (0, 0, -14.7), walking",
			_story_of(events) == PackedStringArray(["990 CROSSING_ENDED s3"]) and _at(sim, Vector3(0.0, 0.0, -14.7))
			and WardenRules.walking(sim), "%s %s" % [_story_of(events), sim.warden.position])
	_check("back gap: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_crossing_from_the_landing() -> void:
	# Code review 2026-11-22: the town section starts fallen (AC 11 allows any section). From the
	# landing's centre (along 32) toward the far pier: 1.7 m at 3.5 m/s is 29.14 ticks, so the feet are
	# at the stop (along 30.3, 0.3 m from the span's end) on tick 29, the first pushing tick; the 31st
	# is tick 59. The crossing runs from the span's end (z 0) to section 6's far edge, 480 ticks, onto
	# section 5.
	var sim: NightSim = _broken(-1.0, {}, [6])
	var events: Array[NightEvent] = _push_until(sim, Vector2(0.0, -1.0), 59)
	_check("landing: ticks 0 to 58: nothing begins, the feet at the stop on the landing: (0, 0, 0.3)",
			_story_of(events).is_empty() and _at(sim, Vector3(0.0, 0.0, 0.3)), "%s %s" % [_story_of(events), sim.warden.position])
	events = _push_until(sim, Vector2(0.0, -1.0), 60)
	_check("landing: CROSSING_STARTED s6 on 59, hanging at the span's end: (0, -2.4, 0)",
			_story_of(events) == PackedStringArray(["59 CROSSING_STARTED s6"]) and _at(sim, Vector3(0.0, -2.4, 0.0)),
			"%s %s" % [_story_of(events), sim.warden.position])
	events = _push_until(sim, Vector2(0.0, -1.0), 539)
	events.append_array(_push_until(sim, Vector2.ZERO, 540))
	_check("landing: CROSSING_ENDED s6 on 539 (59 + 480), onto section 5 at (0, 0, -5.3), walking",
			_story_of(events) == PackedStringArray(["539 CROSSING_ENDED s6"]) and _at(sim, Vector3(0.0, 0.0, -5.3))
			and WardenRules.walking(sim) and _faults.total() == 0, "%s %s" % [_story_of(events), sim.warden.position])


func _test_way_on() -> void:
	# Pure (AC 9): from section n in a direction, past every section that cannot be stood on, is there
	# a floor? Section 2 open, section 4 fallen, the rest planked.
	var sim: NightSim = _broken(-1.0, {2: 0}, [4])
	_check("way on: from open 2 toward the far pier, section 1 is a floor", WardenRules.way_on(2, -1, sim))
	_check("way on: from fallen 4 toward the far pier, 3 is a floor", WardenRules.way_on(4, -1, sim))
	_check("way on: toward the town always (the landing)", WardenRules.way_on(4, 1, sim) and WardenRules.way_on(2, 1, sim))
	sim = _broken(-1.0, {1: 0, 2: 0})
	_check("way on: open 2 then open 1 toward the far pier: none", not WardenRules.way_on(2, -1, sim))
	sim = _broken(-1.0, {}, [5, 6])
	_check("way on: fallen 6 and 5 toward the far pier: section 4", WardenRules.way_on(6, -1, sim))
