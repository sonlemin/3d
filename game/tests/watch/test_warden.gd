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
	# D1: a plankless section's edge is not shared; crossing it is story 1.6.
	var sim: NightSim = _placed(17.5, 6, {3: 0})
	_push(sim, Vector2(0.0, -1.0), 120)
	_check("warden: from section 4 toward the far pier, stops at along 15.3", _near(_along(sim, 30.0), 15.3),
			str(_along(sim, 30.0)))
	sim = _placed(7.5, 6, {3: 0})
	_push(sim, Vector2(0.0, 1.0), 120)
	_check("warden: from section 2 toward the town, stops at along 9.7", _near(_along(sim, 30.0), 9.7),
			str(_along(sim, 30.0)))
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
