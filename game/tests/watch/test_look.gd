## What the warden looks at (AD-15, AD-47; story 1.4 Dev Notes "LookRules", decision D1): the
## view line from the eye (1.6 m above the feet, D2 of story 1.2) for 2 m (GDD Controls: "within
## 2 m"), against SpanGeometry's boxes; the nearest wins and a blocker gives nothing. Each aim is
## worked out here from the numbers written out, never from the rule. Yaw +pi/2 faces -X (LEFT).
extends WatchTest

## The tolerance for a distance, in metres.
const TOL: float = 0.001
## The eye above the feet (D2 of story 1.2).
const EYE: float = 1.6


## A 6-section night, the warden at `along`, then `sideways` ticks of walking toward -X (into the
## left rail, which stops the feet at x -2.2), then one tick aimed at `yaw`, `pitch`.
func _aimed(along: float, yaw: float, pitch: float, start: StartState = StartState.new(),
		sideways: int = 0) -> NightSim:
	start.warden_along = along
	var sim: NightSim = _sim_with(_def_with(start), 1)
	for i: int in sideways:
		sim.set_move(Vector2(-1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(yaw, pitch)
	sim.advance()
	return sim


func _is(target: LookTarget, kind: LookTarget.Kind, section: int = 0) -> bool:
	return target.kind == kind and target.section == section


func _describe(target: LookTarget) -> String:
	return "%s s%d %s %.4f" % [LookTarget.Kind.find_key(target.kind), target.section,
			NightTypes.Side.find_key(target.side), target.distance]


func _test_deck_underfoot() -> void:
	# Mid section 4 (along 17.5), facing the far pier, pitch -1.2: the line drops 1.6 m in
	# 1.6 / sin(1.2) = 1.7164 m, landing 1.6 / tan(1.2) = 0.622 m ahead (along 16.878, section 4).
	var sim: NightSim = _aimed(17.5, 0.0, -1.2)
	_check("look: the deck of the section underfoot at pitch -1.2", _is(sim.look, LookTarget.Kind.DECK, 4),
			_describe(sim.look))
	_check("look: 1.716 m along the line from the eye", absf(sim.look.distance - 1.6 / sin(1.2)) < TOL,
			_describe(sim.look))
	_check("look: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_deck_across_an_edge() -> void:
	# Along 15.4 (section 4) facing the far pier: the line lands at along 14.778, section 3.
	var sim: NightSim = _aimed(15.4, 0.0, -1.2)
	_check("look: the next section's deck across a section edge", _is(sim.look, LookTarget.Kind.DECK, 3),
			_describe(sim.look))
	# Along 14.6 (section 3) facing the town (yaw pi): it lands at along 15.222, section 4.
	sim = _aimed(14.6, PI, -1.2)
	_check("look: and facing the town, the next section toward it", _is(sim.look, LookTarget.Kind.DECK, 4),
			_describe(sim.look))


func _test_nothing_at_the_horizon_or_beyond_reach() -> void:
	var sim: NightSim = _aimed(17.5, 0.0, 0.0)
	_check("look: nothing at pitch 0 (the horizon)", _is(sim.look, LookTarget.Kind.NONE), _describe(sim.look))
	# Pitch -0.85: the deck is 1.6 / sin(0.85) = 2.13 m along the line, past the 2 m reach.
	sim = _aimed(17.5, 0.0, -0.85)
	_check("look: nothing beyond 2 m (the deck 2.13 m away at pitch -0.85)", _is(sim.look, LookTarget.Kind.NONE),
			_describe(sim.look))


func _test_a_standing_rail() -> void:
	# From x -2.2 (the left rail stops the feet there, 0.3 m in) facing -X, pitch -1.107 =
	# atan(0.6 / 0.3): the line aims at the rope's centre (x -2.5, y 1.0). D1's grab box is 0.3 m
	# across and tall on it (x -2.65 to -2.35, y 0.85 to 1.15): the line enters through its top at
	# y 1.15, 0.225 m across: sqrt(0.225^2 + 0.45^2) = 0.503 m from the eye.
	var sim: NightSim = _aimed(17.5, PI / 2.0, -1.107, StartState.new(), 60)
	_check("look: walked into the left rail, x -2.2", absf(sim.warden.position.x + 2.2) < TOL, str(sim.warden.position))
	_check("look: the standing left rail of section 4", _is(sim.look, LookTarget.Kind.RAIL, 4)
			and sim.look.side == NightTypes.Side.LEFT, _describe(sim.look))
	_check("look: entered through the grab box's top, 0.503 m away",
			absf(sim.look.distance - sqrt(0.225 * 0.225 + 0.45 * 0.45)) < TOL, _describe(sim.look))
	# At pitch 0 the line stays at y 1.6, over the box's top (1.15).
	sim = _aimed(17.5, PI / 2.0, 0.0, StartState.new(), 60)
	_check("look: at pitch 0 the line passes over the rail", _is(sim.look, LookTarget.Kind.NONE), _describe(sim.look))
	# The right rail, facing +X (yaw -pi/2) from x +2.2.
	var start: StartState = StartState.new()
	start.warden_along = 17.5
	var right: NightSim = _sim_with(_def_with(start), 1)
	for i: int in 60:
		right.set_move(Vector2(1.0, 0.0))
		right.advance()
	right.set_move(Vector2.ZERO)
	right.set_view(-PI / 2.0, -1.107)
	right.advance()
	_check("look: and the right rail facing +X", _is(right.look, LookTarget.Kind.RAIL, 4)
			and right.look.side == NightTypes.Side.RIGHT, _describe(right.look))


func _test_a_stripped_rail_is_not_there() -> void:
	# The same aim with section 4's left rope gone: past where the rope was, 2 m down the line
	# ends at x -3.09, y -0.19; it leaves the deck's width (x -2.5) at y 1.0, so it meets nothing.
	var start: StartState = StartState.new()
	start.stripped_rails = [Vector2i(4, NightTypes.Side.LEFT)]
	var sim: NightSim = _aimed(17.5, PI / 2.0, -1.107, start, 60)
	_check("look: nothing where a stripped rail was", _is(sim.look, LookTarget.Kind.NONE), _describe(sim.look))
	# Steeper (pitch -1.39) the line meets the deck instead: 1.6 / tan(1.39) = 0.292 m across, x -2.492.
	start = StartState.new()
	start.stripped_rails = [Vector2i(4, NightTypes.Side.LEFT)]
	sim = _aimed(17.5, PI / 2.0, -1.39, start, 60)
	_check("look: and a steeper line goes on to the deck", _is(sim.look, LookTarget.Kind.DECK, 4), _describe(sim.look))


func _test_a_blocker_hit_first_gives_nothing() -> void:
	# On section 6 at along 29.5, 0.5 m short of the landing, facing the town (yaw pi). Pitch -1.0
	# lands 1.6 / tan(1.0) = 1.027 m ahead, on the landing (along 30.527), 1.9 m from the eye.
	var sim: NightSim = _aimed(29.5, PI, -1.0)
	_check("look: the landing's top is hit first: nothing", _is(sim.look, LookTarget.Kind.NONE), _describe(sim.look))
	# Pitch -1.35 lands 1.6 / tan(1.35) = 0.359 m ahead, on section 6's deck (along 29.859).
	sim = _aimed(29.5, PI, -1.35)
	_check("look: a little steeper, section 6's deck", _is(sim.look, LookTarget.Kind.DECK, 6), _describe(sim.look))
	# The landing hides what is behind it. On the landing at along 31.05 facing the far pier,
	# pitch -1.0: the line meets the landing's top 1.027 m ahead (along 30.023, 1.90 m along it),
	# then would enter section 6's deck through its end at along 30, 0.036 m down (1.94 m along):
	# the landing is hit first, so nothing.
	sim = _aimed(31.05, 0.0, -1.0)
	_check("look: a deck behind the landing's top is hidden by it", _is(sim.look, LookTarget.Kind.NONE),
			_describe(sim.look))


func _test_a_bare_deck_is_still_a_target() -> void:
	# A deck with no planks can take a re-lay (GD-69), so it is looked at like any other. From
	# along 20.4 on section 5 facing the far pier, pitch -1.2 lands at along 19.778, section 4.
	var start: StartState = StartState.new()
	start.planks = {4: 0}
	var sim: NightSim = _aimed(20.4, 0.0, -1.2, start)
	_check("look: a bare deck is a target", _is(sim.look, LookTarget.Kind.DECK, 4), _describe(sim.look))


func _test_derived_each_tick() -> void:
	# AD-35: the look is worked out every tick, never carried over.
	var sim: NightSim = _aimed(17.5, 0.0, -1.2)
	sim.set_view(0.0, 0.0)
	sim.advance()
	_check("look: turning to the horizon, the next tick has no target", _is(sim.look, LookTarget.Kind.NONE),
			_describe(sim.look))


func _test_view_direction() -> void:
	# AD-67: yaw 0 faces -Z, positive turns left (yaw pi/2 faces -X); pitch positive up.
	_check("look: yaw 0, pitch 0 is -Z", LookRules.view_direction(0.0, 0.0).is_equal_approx(Vector3(0.0, 0.0, -1.0)))
	_check("look: yaw pi/2 is -X", LookRules.view_direction(PI / 2.0, 0.0).is_equal_approx(Vector3(-1.0, 0.0, 0.0)))
	_check("look: pitch pi/2 is up", LookRules.view_direction(0.0, PI / 2.0).is_equal_approx(Vector3(0.0, 1.0, 0.0)))
	_check("look: the eye is 1.6 m above the feet", is_equal_approx(WardenConstants.EYE_HEIGHT, EYE))
	# D1: the grab box is 0.3 m across and tall around the drawn rope, its full length.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	var rope: AABB = sim.geometry.rail_box(2, NightTypes.Side.RIGHT)
	var grab: AABB = sim.geometry.rail_grab_box(2, NightTypes.Side.RIGHT)
	_check("look: D1 grab box 0.3 x 0.3, the rope's length, centred on it",
			grab.size.is_equal_approx(Vector3(0.3, 0.3, 5.0)) and grab.get_center().is_equal_approx(rope.get_center()),
			"%s %s" % [grab, rope])
