## What follows a fall (AD-48, AD-64; story 1.5 AC 5, 6, 8, decisions D2 and D3):
## ConsequenceRules.settle() as a fixed list of named steps: the weights on a fallen section fall,
## its parts are lost through the ledger, a warden on it catches the edge and climbs back toward
## the town, a warden beside it steps back from the gap. Spec values written out with their source:
## GD-19 / GDD Game Mechanics 2: 3 planks under 4 weights groans from tick 0 and falls on tick 120
## (2 s); the climb back takes 5 s = 300 ticks; 48 planks and 12 ropes in all. Decision D3: the feet
## hang 1.4 m below the deck top being climbed onto, and end 0.3 m in from its edge. D2: a warden
## beside the gap steps back to 0.3 m from it. One night is 30 m (world z = along - 30).
## Ticks are compared exactly; positions within 0.001 m.
extends WatchTest

## GDD Game Mechanics 2: the fall, 2 s after an overload seen on tick 0.
const FALL_TICK: int = 120
## GDD Game Mechanics 2: 5 s.
const CLIMB_TICKS: int = 300
## GD-19: 3.5 m/s at 60 ticks a second.
const STEP: float = 3.5 / 60.0
const TOL: float = 0.001
const PLANK: NightTypes.Part = NightTypes.Part.PLANK
const ROPE: NightTypes.Part = NightTypes.Part.ROPE
const LEFT: NightTypes.Side = NightTypes.Side.LEFT
const RIGHT: NightTypes.Side = NightTypes.Side.RIGHT


## A night of `sections` with `planks`, `weights`, `rails` and the warden at `along`; nothing ticked.
func _night(planks: Dictionary[int, int], weights: Dictionary[int, int], along: float = -1.0, sections: int = 6,
		rails: Array[Vector2i] = []) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = planks
	start.weights = weights
	start.warden_along = along
	start.stripped_rails = rails
	return _sim_with(_def_with(start, sections), 1)


## Walks across to `x`, the last step shortened to land on it (story 1.5 Dev Notes, "The climb").
func _walk_to_x(sim: NightSim, x: float) -> void:
	for i: int in 200:
		var left: float = x - sim.warden.position.x
		if absf(left) < 0.000001:
			break
		sim.set_move(Vector2(clampf(left / STEP, -1.0, 1.0), 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)


## Advances until the tick before `tick` has run (sim.tick == tick), returning every event.
func _until(sim: NightSim, tick: int) -> Array[NightEvent]:
	return _advance(sim, tick - sim.tick)


func _names(events: Array[NightEvent]) -> String:
	return str(events.map(func(e: NightEvent) -> String: return "%s s%d" % [NightEvent.Kind.find_key(e.kind), e.section]))


func _test_settle_steps_in_order() -> void:
	# AD-64: the footing of the dead (here the test weights), rigs, lanterns, parts, hooks, the warden.
	var names: Array = ConsequenceRules.steps().map(func(c: Callable) -> StringName: return c.get_method())
	_check("settle: its steps are weights_fall, parts_lost, warden_footing, in that order",
			names == [&"weights_fall", &"parts_lost", &"warden_footing"], str(names))


func _test_what_falls_with_it() -> void:
	# AC 5: section 4 at 3 planks (5 in hand) with its left rope stripped (1 in hand), 4 weights.
	var sim: NightSim = _night({4: 3}, {4: 4}, -1.0, 6, [Vector2i(4, LEFT)])
	_until(sim, FALL_TICK)
	_check("fall: before tick 120 nothing is lost", sim.span.count_at(PLANK, PartPlace.lost()) == 0
			and sim.span.weights(4) == 4 and sim.span.planks(4) == 3)
	var fell: Array[NightEvent] = sim.advance()
	_check("fall: tick 120 is the fall", _kinds(fell) == [NightEvent.Kind.SECTION_FELL], _names(fell))
	_check("fall: the weights fell with it", sim.span.weights(4) == 0, str(sim.span.weights(4)))
	_check("fall: its 3 planks and its right rope are lost, on the tick it fell",
			sim.span.planks(4) == 0 and not sim.span.rail_standing(4, RIGHT)
			and sim.span.count_at(PLANK, PartPlace.lost()) == 3 and sim.span.count_at(ROPE, PartPlace.lost()) == 1,
			"%d %d" % [sim.span.count_at(PLANK, PartPlace.lost()), sim.span.count_at(ROPE, PartPlace.lost())])
	_check("fall: the hand keeps its 5 planks and 1 rope", sim.span.in_hand(PLANK) == 5 and sim.span.in_hand(ROPE) == 1)
	_check("fall: 48 planks and 12 ropes in all, the lost counted (GD-19)",
			sim.span.total(PLANK) == 48 and sim.span.total(ROPE) == 12)
	_check("fall: no other section changed", sim.span.planks(3) == 8 and sim.span.planks(5) == 8
			and sim.span.rail_standing(3, LEFT) and sim.span.rail_standing(5, RIGHT))
	_check("fall: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_fallen_section_is_never_relaid() -> void:
	# AC 5: a gap for the rest of the night. The warden on section 5 at along 20.4 (0.4 m from it),
	# looking down at where section 4's deck was (pitch -1.2 lands at along 19.778).
	var sim: NightSim = _night({4: 3}, {4: 4}, 20.4)
	sim.set_view(0.0, -1.2)
	var before: Array[NightEvent] = _until(sim, 1)
	_check("gap: before the fall that aim is section 4's deck", sim.look.kind == LookTarget.Kind.DECK
			and sim.look.section == 4, _names(before))
	_until(sim, FALL_TICK + 1)
	_check("gap: no room on a fallen deck", sim.span.fits_at(PLANK, PartPlace.deck(4), 1) == 0)
	_check("gap: a re-lay onto it is NO_ACTION_HERE (5 planks in hand)", sim.span.in_hand(PLANK) == 5
			and HandRules.check(NightTypes.HandAction.RELAY_PLANK, LookTarget.deck(4, 1.0), sim.def, sim.span)
			== NightTypes.Reason.NO_ACTION_HERE)
	sim.command(NightCommand.press(NightTypes.HandInput.USE))
	var pressed: Array[NightEvent] = sim.advance()
	_check("gap: E at the gap is refused NO_ACTION_HERE, as at the sky", pressed.size() == 1
			and pressed[0].kind == NightEvent.Kind.REFUSED and pressed[0].reason == NightTypes.Reason.NO_ACTION_HERE
			and pressed[0].section == 0, _names(pressed))
	_expect_begin()
	SpanRules.move_parts(PLANK, 1, PartPlace.hand(), PartPlace.deck(4), sim)
	_expect_end("gap: the ledger moves nothing onto it (span.no_room)", [["ERROR", "span.no_room", 1]])
	_check("gap: still 0 planks there, 5 in hand", sim.span.planks(4) == 0 and sim.span.in_hand(PLANK) == 5)


func _test_the_warden_on_it_catches_the_edge_and_climbs() -> void:
	# AC 6 and D3: the warden at along 17.5 (mid section 4), walked across to x 0.5 before the fall.
	var sim: NightSim = _night({4: 3}, {4: 4}, 17.5)
	_walk_to_x(sim, 0.5)
	_check("climb: walked to x 0.5 before the fall", absf(sim.warden.position.x - 0.5) < TOL and sim.tick < FALL_TICK,
			str(sim.warden.position))
	_until(sim, FALL_TICK)
	var fell: Array[NightEvent] = sim.advance()
	_check("climb: tick 120: SECTION_FELL then WARDEN_CAUGHT, both section 4",
			_kinds(fell) == [NightEvent.Kind.SECTION_FELL, NightEvent.Kind.WARDEN_CAUGHT] and fell[1].section == 4
			and fell[1].t == 2.0, _names(fell))
	# D3: hanging from section 5's near edge (along 20, z -10), 1.4 m below its deck top.
	_check("climb: hanging at (0.5, -1.4, -10.0)", sim.warden.position.distance_to(Vector3(0.5, -1.4, -10.0)) < TOL,
			str(sim.warden.position))
	_check("climb: the parts in hand are kept (5 planks)", sim.span.in_hand(PLANK) == 5)
	var still: bool = true
	var quiet: bool = true
	for i: int in CLIMB_TICKS - 1:
		sim.set_move(Vector2(0.0, 1.0))
		sim.set_view(float(i) * 0.01, 0.0)
		quiet = quiet and sim.advance().is_empty()
		still = still and sim.warden.position.distance_to(Vector3(0.5, -1.4, -10.0)) < TOL
	_check("climb: ticks 121 to 419: the move wish moves nothing and nothing happens", still and quiet,
			str(sim.warden.position))
	_check("climb: the view still turns (no input but look)", is_equal_approx(sim.yaw, 2.98), str(sim.yaw))
	sim.set_move(Vector2.ZERO)
	var up: Array[NightEvent] = sim.advance()
	_check("climb: tick 420 (120 + 300): WARDEN_CLIMBED onto section 5", _kinds(up) == [NightEvent.Kind.WARDEN_CLIMBED]
			and up[0].section == 5 and up[0].t == 7.0, _names(up))
	_check("climb: up on section 5, 0.3 m in: (0.5, 0.0, -9.7)",
			sim.warden.position.distance_to(Vector3(0.5, 0.0, -9.7)) < TOL, str(sim.warden.position))
	_check("climb: where they end can be stood on", WardenRules.can_stand(sim.warden.position, sim))
	sim.set_move(Vector2(0.0, 1.0))
	sim.advance()
	_check("climb: and they walk on the next tick", absf(sim.warden.position.z - (-9.7 + STEP)) < TOL,
			str(sim.warden.position))
	_check("climb: still 5 planks in hand, no fault", sim.span.in_hand(PLANK) == 5 and _faults.total() == 0,
			str(_faults.codes()))


func _test_a_climb_ends_where_the_warden_walks_that_tick() -> void:
	# The climb ends in step 1 before the walk: on tick 420 a move wish already moves them.
	var sim: NightSim = _night({4: 3}, {4: 4}, 17.5)
	_until(sim, FALL_TICK + CLIMB_TICKS)
	sim.set_move(Vector2(0.0, 1.0))
	var up: Array[NightEvent] = sim.advance()
	_check("climb: on the climb's last tick the warden is free and walks one step",
			_kinds(up) == [NightEvent.Kind.WARDEN_CLIMBED]
			and sim.warden.position.distance_to(Vector3(0.0, 0.0, -9.7 + STEP)) < TOL, str(sim.warden.position))


func _test_section_6_climbs_onto_the_landing() -> void:
	# AC 8: the town section falls under the warden: they climb onto the landing (section 0).
	# One night: mid section 6 is along 27.5; the landing's edge is along 30 (z 0). Four sections:
	# mid section 4 is along 17.5, the landing's edge along 20 (z 0).
	for sections: int in [6, 4]:
		var along: float = 27.5 if sections == 6 else 17.5
		var sim: NightSim = _night({sections: 4}, {sections: 5}, along, sections)
		var events: Array[NightEvent] = _until(sim, FALL_TICK + 1)
		var caught: Array[NightEvent] = events.filter(func(e: NightEvent) -> bool: return e.kind == NightEvent.Kind.WARDEN_CAUGHT)
		_check("town %d: caught on tick 120, section %d" % [sections, sections], caught.size() == 1
				and caught[0].section == sections and caught[0].t == 2.0, _names(events))
		_check("town %d: hanging from the landing's edge at (0, -1.4, 0)" % sections,
				sim.warden.position.distance_to(Vector3(0.0, -1.4, 0.0)) < TOL, str(sim.warden.position))
		events = _until(sim, FALL_TICK + CLIMB_TICKS + 1)
		_check("town %d: WARDEN_CLIMBED onto the landing (section 0) on tick 420" % sections, events.size() == 1
				and events[0].kind == NightEvent.Kind.WARDEN_CLIMBED and events[0].section == 0 and events[0].t == 7.0,
				_names(events))
		_check("town %d: on the landing at (0, 0, 0.3)" % sections,
				sim.warden.position.distance_to(Vector3(0.0, 0.0, 0.3)) < TOL and WardenRules.can_stand(sim.warden.position, sim),
				str(sim.warden.position))
		_check("town %d: no fault" % sections, _faults.total() == 0, str(_faults.codes()))


func _test_the_climb_ends_on_the_next_standing_section() -> void:
	# Section 4 (3 planks, 4 weights) falls on tick 120 under the warden, who stands at along 19.6
	# looking toward the town at section 5's deck (yaw pi, pitch -1.2 lands at along 20.222). Section 5
	# at 4 planks with 4 weights creaks; a strip of it begun on tick 0 completes on tick 120, before
	# the fall in step 7: section 5 groans from 120 and falls on 240, during the climb. The climb ends
	# on the next standing section, 6, at along 25.3 (z -4.7).
	var sim: NightSim = _night({4: 3, 5: 4}, {4: 4, 5: 4}, 19.6)
	sim.set_view(PI, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	var events: Array[NightEvent] = _until(sim, FALL_TICK + 1)
	var tail: Array[NightEvent] = events.filter(func(e: NightEvent) -> bool: return roundi(e.t * 60.0) == FALL_TICK)
	_check("next: tick 120: the strip of 5, 4 falls, 5 stops creaking and groans, the warden is caught",
			_kinds(tail) == [NightEvent.Kind.PLANK_STRIPPED, NightEvent.Kind.SECTION_FELL, NightEvent.Kind.CREAK_STOPPED,
			NightEvent.Kind.GROAN_STARTED, NightEvent.Kind.WARDEN_CAUGHT], _names(tail))
	_check("next: hanging from section 5's edge (along 20, z -10)",
			sim.warden.position.distance_to(Vector3(0.0, -1.4, -10.0)) < TOL, str(sim.warden.position))
	events = _until(sim, FALL_TICK + CLIMB_TICKS + 1)
	_check("next: section 5 fell on tick 240, then the climb ended on 420 onto section 6", _names(events)
			== str(["SECTION_FELL s5", "WARDEN_CLIMBED s6"]) and roundi(events[0].t * 60.0) == 240
			and roundi(events[1].t * 60.0) == 420, _names(events))
	_check("next: up on section 6, 0.3 m in: (0, 0, -4.7)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -4.7)) < TOL, str(sim.warden.position))
	_check("next: no fault", _faults.total() == 0, str(_faults.codes()))


## The D2 night: section 4 (3 planks, 4 weights) falls on tick 120; the warden starts at along 20.1
## (section 5, 0.1 m from section 4) and walks across to x 1.0.
func _beside() -> NightSim:
	var sim: NightSim = _night({4: 3}, {4: 4}, 20.1)
	_walk_to_x(sim, 1.0)
	return sim


func _test_the_warden_beside_it_steps_back() -> void:
	# D2, with a strip of section 5's right rail running (in reach: 1.5 m across, 0.6 m up from the
	# eye; GD-19: 3 s = 180 ticks). Aimed at the rope at along 20.6.
	var sim: NightSim = _beside()
	var eye: Vector3 = sim.warden.position + Vector3(0.0, 1.6, 0.0)
	var to: Vector3 = Vector3(2.5, 1.0, 20.6 - 30.0) - eye
	sim.set_view(atan2(-to.x, -to.z), atan2(to.y, Vector2(to.x, to.z).length()))
	sim.advance()
	_check("d2: aimed at section 5's right rail", sim.look.kind == LookTarget.Kind.RAIL and sim.look.section == 5
			and sim.look.side == RIGHT)
	sim.command(NightCommand.press(NightTypes.HandInput.ROPE))
	var began: int = sim.tick
	_until(sim, FALL_TICK)
	_check("d2: before the fall: at along 20.1, x 1.0, the rail hold running", sim.hands.holding()
			and sim.warden.position.distance_to(Vector3(1.0, 0.0, -9.9)) < TOL, str(sim.warden.position))
	var fell: Array[NightEvent] = sim.advance()
	_check("d2: tick 120: the fall, and no catch", _kinds(fell) == [NightEvent.Kind.SECTION_FELL], _names(fell))
	_check("d2: in the same tick the feet stepped back to along 20.3, x 1.0 (0.2 m)",
			sim.warden.position.distance_to(Vector3(1.0, 0.0, -9.7)) < TOL, str(sim.warden.position))
	_check("d2: and can stand there", WardenRules.can_stand(sim.warden.position, sim))
	var rest: Array[NightEvent] = _until(sim, began + 181)
	_check("d2: the rail hold went on and completed on its tick (begun + 180)", rest.size() == 1
			and rest[0].kind == NightEvent.Kind.RAIL_STRIPPED and roundi(rest[0].t * 60.0) == began + 180
			and rest[0].section == 5 and rest[0].side == RIGHT, _names(rest))
	# Not frozen at the gap: they walk on toward the town, and cannot step into the gap.
	for i: int in 10:
		sim.set_move(Vector2(0.0, 1.0))
		sim.advance()
	_check("d2: they walk away from the gap (20.3 + 10 steps)", absf(sim.warden.position.z + 30.0 - (20.3 + 10 * STEP)) < TOL,
			str(sim.warden.position))
	for i: int in 30:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	_check("d2: walking back toward the gap stops at along 20.3", absf(sim.warden.position.z + 30.0 - 20.3) < TOL,
			str(sim.warden.position))
	_check("d2: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_hold_on_the_fallen_deck_from_beside_it_is_cancelled() -> void:
	# D2's twin: the same stance, a strip of section 4's deck (pitch -1.2 lands at along 19.478):
	# cancelled on tick 121 (F + 1), with no part moved.
	var sim: NightSim = _beside()
	sim.set_view(0.0, -1.2)
	sim.advance()
	_check("d2: aimed at section 4's deck", sim.look.kind == LookTarget.Kind.DECK and sim.look.section == 4)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	_until(sim, FALL_TICK + 1)
	_check("d2: stepped back, the hold still running after the fall's tick", sim.hands.holding()
			and sim.warden.position.distance_to(Vector3(1.0, 0.0, -9.7)) < TOL)
	var next: Array[NightEvent] = sim.advance()
	_check("d2: HOLD_CANCELLED on tick 121, section 4 strip_plank", next.size() == 1
			and next[0].kind == NightEvent.Kind.HOLD_CANCELLED and next[0].section == 4 and next[0].id == &"strip_plank",
			_names(next))
	_check("d2: nothing moved to the hand (5 from the start)", sim.span.in_hand(PLANK) == 5 and not sim.hands.holding())


func _test_the_landing_beside_section_6() -> void:
	# D2 from the landing: at along 30.1 the feet are 0.1 m from section 6 (falls on tick 120): back to 30.3.
	var sim: NightSim = _night({6: 4}, {6: 5}, 30.1)
	_until(sim, FALL_TICK + 1)
	_check("d2: on the landing the feet step back to along 30.3 (z 0.3)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, 0.3)) < TOL and WardenRules.walking(sim),
			str(sim.warden.position))


func _test_settle_twice_changes_nothing() -> void:
	# Each step looks at the whole state: a second settle() in the same tick finds nothing to do.
	# Section 4 falls under the warden at along 17.5 on tick 120 (weights, parts and warden all settled).
	var sim: NightSim = _night({4: 3}, {4: 4}, 17.5)
	_until(sim, FALL_TICK + 1)
	var before: int = sim.checksum()
	ConsequenceRules.settle(sim)
	_check("settle: a second run changes nothing", sim.checksum() == before)
	var next: Array[NightEvent] = sim.advance()
	_check("settle: and emits nothing (no second catch)", next.is_empty(), _names(next))


func _test_steps_alone() -> void:
	# Each named step does only its own part, on the state after a fall it has not yet settled:
	# built by running the fall tick's steps 1 to 7 by hand on a sim (the test's own tick).
	var sim: NightSim = _night({4: 3}, {4: 4}, 17.5)
	_until(sim, FALL_TICK)
	for step: Callable in sim._steps.slice(0, 7):
		step.call()
	_check("steps: section 4 has fallen with its weights, planks and walker still on it", sim.span.fallen(4)
			and sim.span.weights(4) == 4 and sim.span.planks(4) == 3 and WardenRules.walking(sim))
	ConsequenceRules.weights_fall(sim)
	_check("steps: weights_fall takes only the weights", sim.span.weights(4) == 0 and sim.span.planks(4) == 3
			and WardenRules.walking(sim))
	ConsequenceRules.parts_lost(sim)
	_check("steps: parts_lost loses only the parts", sim.span.planks(4) == 0
			and sim.span.count_at(PLANK, PartPlace.lost()) == 3 and sim.span.count_at(ROPE, PartPlace.lost()) == 2
			and WardenRules.walking(sim))
	ConsequenceRules.warden_footing(sim)
	_check("steps: warden_footing catches the warden", not WardenRules.walking(sim)
			and sim.warden.position.distance_to(Vector3(0.0, -1.4, -10.0)) < TOL, str(sim.warden.position))
	_check("steps: no fault", _faults.total() == 0, str(_faults.codes()))
