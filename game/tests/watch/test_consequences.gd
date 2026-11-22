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
	_check("settle: its steps are weights_fall, parts_lost, warden_footing, warden_on_beams, in that order",
			names == [&"weights_fall", &"parts_lost", &"warden_footing", &"warden_on_beams"], str(names))


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


func _test_a_fallen_section_takes_no_rope() -> void:
	# AC 5: "a gap for the rest of the night". Section 4's left rope starts in the hand; after the
	# fall its rail has no room for it, as its deck has none for a plank.
	var sim: NightSim = _night({4: 3}, {4: 4}, -1.0, 6, [Vector2i(4, LEFT)])
	_check("gap rope: before the fall the rail has room for its rope", sim.span.fits_at(ROPE, PartPlace.rail(4, LEFT), 1) == 1)
	_until(sim, FALL_TICK + 1)
	_check("gap rope: no room on a fallen section's rail", sim.span.fits_at(ROPE, PartPlace.rail(4, LEFT), 1) == 0
			and sim.span.fits_at(ROPE, PartPlace.rail(4, RIGHT), 1) == 0)
	_expect_begin()
	SpanRules.move_parts(ROPE, 1, PartPlace.hand(), PartPlace.rail(4, LEFT), sim)
	_expect_end("gap rope: the ledger moves nothing onto it (span.no_room)", [["ERROR", "span.no_room", 1]])
	_check("gap rope: 1 rope in hand still, 1 lost (the right rope), 12 in all", sim.span.in_hand(ROPE) == 1
			and sim.span.count_at(ROPE, PartPlace.lost()) == 1 and sim.span.total(ROPE) == 12)


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
	# on the next section with planks, 6, at along 25.3 (z -4.7).
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
	events = _until(sim, 240)
	_check("next: ticks 121 to 239: nothing happens, still hanging from section 5's edge", events.is_empty()
			and sim.warden.position.distance_to(Vector3(0.0, -1.4, -10.0)) < TOL, _names(events))
	# Code review of 2026-11-22 (Sonlm): the edge hung from falls. In that same tick (step 8) the feet
	# cut to the next edge toward the town, section 6's (along 25, z -5). No event of its own, and
	# the 5 s keep running: the climb still ends on tick 420.
	var gone: Array[NightEvent] = sim.advance()
	_check("next: tick 240: section 5 falls, the tick's only event", _names(gone) == str(["SECTION_FELL s5"])
			and roundi(gone[0].t * 60.0) == 240, _names(gone))
	_check("next: on tick 240 the feet hang from section 6's edge: (0, -1.4, -5.0)",
			sim.warden.position.distance_to(Vector3(0.0, -1.4, -5.0)) < TOL and not WardenRules.walking(sim),
			str(sim.warden.position))
	var still: bool = true
	var quiet: bool = true
	for i: int in 179:
		quiet = quiet and sim.advance().is_empty()
		still = still and sim.warden.position.distance_to(Vector3(0.0, -1.4, -5.0)) < TOL
	_check("next: ticks 241 to 419: hanging there, nothing happens", still and quiet and sim.tick == 420,
			str(sim.warden.position))
	var up: Array[NightEvent] = sim.advance()
	_check("next: the climb ends on tick 420 (120 + 300, not restarted), onto section 6",
			_names(up) == str(["WARDEN_CLIMBED s6"]) and roundi(up[0].t * 60.0) == 420, _names(up))
	_check("next: up on section 6, 0.3 m in: (0, 0, -4.7)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -4.7)) < TOL, str(sim.warden.position))
	_check("next: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_climb_passes_a_bare_section() -> void:
	# "The first section toward the town that has planks and has not fallen": section 5 starts with no
	# planks (it stands, bare); section 4 falls under the warden at along 17.5 on tick 120. They hang
	# from section 6's edge (along 25, z -5), not from bare section 5's, and climb onto 6.
	var sim: NightSim = _night({4: 3, 5: 0}, {4: 4}, 17.5)
	var events: Array[NightEvent] = _until(sim, FALL_TICK + 1)
	_check("bare: caught on tick 120, section 5 standing with no planks", _has(events, NightEvent.Kind.WARDEN_CAUGHT)
			and not sim.span.fallen(5) and sim.span.planks(5) == 0, _names(events))
	_check("bare: hanging from section 6's edge: (0, -1.4, -5.0)",
			sim.warden.position.distance_to(Vector3(0.0, -1.4, -5.0)) < TOL, str(sim.warden.position))
	events = _until(sim, FALL_TICK + CLIMB_TICKS + 1)
	_check("bare: WARDEN_CLIMBED onto section 6 on tick 420", _names(events) == str(["WARDEN_CLIMBED s6"])
			and roundi(events[0].t * 60.0) == 420, _names(events))
	_check("bare: up on section 6 at (0, 0, -4.7), where they can stand",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -4.7)) < TOL and WardenRules.can_stand(sim.warden.position, sim),
			str(sim.warden.position))
	_check("bare: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_an_edging_warden_whose_section_falls() -> void:
	# Story 1.6 AC 10, L6: section 3 open with 3 test weights (over the side beams' 2: it groans from
	# tick 0 and falls on 120, GDD Game Mechanics 2). Placed at along 15.3 pushing toward the far pier:
	# the edging begins on tick 30 (D1), from (0, 0, -14.7) toward (2.2, 0, -20.0), on the beam line
	# from 0.5 s in (Sonlm's play of M1). On tick 120 it is 90 of its 240 ticks in: the feet at
	# 0.375 of the way along, on the beam line: (2.2, 0, -16.6875). Section 3 falls in
	# step 7 and the warden is caught in step 8, as story 1.5's climb: hanging from section 4's edge
	# (along 15, z -15), x kept; climbed 300 ticks later onto section 4, 0.3 m in.
	var start: StartState = StartState.new()
	start.planks = {3: 0}
	start.weights = {3: 3}
	start.warden_along = 15.3
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var events: Array[NightEvent] = []
	while sim.tick < FALL_TICK:
		sim.set_move(Vector2(0.0, -1.0))
		events.append_array(sim.advance())
	_check("edging falls: GROAN_STARTED s3 on 0, EDGING_STARTED s3 on 30", _names(events)
			== str(["NIGHT_STARTED s0", "GROAN_STARTED s3", "EDGING_STARTED s3"]), _names(events))
	_check("edging falls: on tick 119, 89 ticks in: (2.2, 0, -16.665417)",
			sim.warden.position.distance_to(Vector3(2.2, 0.0, -14.7 - 5.3 * 89.0 / 240.0)) < TOL,
			str(sim.warden.position))
	sim.set_move(Vector2(0.0, -1.0))
	var fell: Array[NightEvent] = sim.advance()
	_check("edging falls: tick 120: SECTION_FELL s3 then WARDEN_CAUGHT s3", _names(fell)
			== str(["SECTION_FELL s3", "WARDEN_CAUGHT s3"]), _names(fell))
	_check("edging falls: hanging from section 4's edge, x kept: (2.2, -1.4, -15.0)",
			sim.warden.position.distance_to(Vector3(2.2, -1.4, -15.0)) < TOL and sim.warden.move == WardenState.Move.CLIMBING,
			str(sim.warden.position))
	_check("edging falls: the edging's facts are cleared", sim.warden.move_section == 0 and sim.warden.move_toward == 0
			and sim.warden.move_ticks_total == 0, str(sim.warden.values()))
	events = _until(sim, FALL_TICK + CLIMB_TICKS + 1)
	_check("edging falls: WARDEN_CLIMBED onto section 4 on tick 420, no EDGING_ENDED", _names(events)
			== str(["WARDEN_CLIMBED s4"]) and roundi(events[0].t * 60.0) == 420, _names(events))
	_check("edging falls: up on section 4 at (2.2, 0, -14.7)", sim.warden.position.distance_to(Vector3(2.2, 0.0, -14.7)) < TOL
			and WardenRules.can_stand(sim.warden.position, sim), str(sim.warden.position))
	_check("edging falls: 8 planks in hand (section 3's, from the start), no fault", sim.span.in_hand(PLANK) == 8
			and _faults.total() == 0, str(_faults.codes()))
	# Whichever way they were edging: placed at 9.7 pushing toward the town, the edging runs from
	# (0, 0, -20.3) toward (2.2, 0, -15.0); caught on 120 at 0.375 of the way along (on the beam line),
	# they still climb onto
	# section 4, the first toward the town with planks.
	start = StartState.new()
	start.planks = {3: 0}
	start.weights = {3: 3}
	start.warden_along = 9.7
	sim = _sim_with(_def_with(start), 1)
	events = []
	while sim.tick < FALL_TICK + 1:
		sim.set_move(Vector2(0.0, 1.0))
		events.append_array(sim.advance())
	_check("edging falls town: caught on 120 from (2.2, 0, -18.3125), hanging at (2.2, -1.4, -15.0)",
			_has(events, NightEvent.Kind.WARDEN_CAUGHT) and sim.warden.position.distance_to(Vector3(2.2, -1.4, -15.0)) < TOL,
			"%s %s" % [_names(events), sim.warden.position])
	events = _until(sim, FALL_TICK + CLIMB_TICKS + 1)
	_check("edging falls town: climbed onto section 4 on 420", _names(events) == str(["WARDEN_CLIMBED s4"]), _names(events))


# --- Story 1.6 GD-68: the last plank underfoot --------------------------------------------------
# GD-68: a warden whose last plank goes is on the side beam at once and finishes toward the town in
# the share of 4 s (240 ticks) that the distance left is of 5 m: roundi(240 x left / 5), at least 1.

## Section 3 at 1 plank (and `fallen`), the warden at `along` on it facing `yaw`, the hammer pressed
## before tick 0 at the deck 0.622 m ahead (pitch -1.2, test_hands.gd), held: the strip of the last
## plank completes on tick 120 (GD-19: 2 s).
func _strip_underfoot(along: float, yaw: float = 0.0, fallen: Array[int] = []) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = {3: 1}
	start.fallen = fallen
	start.warden_along = along
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(yaw, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	return sim


func _test_the_last_plank_underfoot() -> void:
	# AC 2, L1: from along 12.5 (2.5 m left: 120 ticks), 11.0 (4 m: 192) and 14.9 (0.1 m: 4.8, so 5).
	# "Whichever way the warden faces": from 12.5 and 11.0 facing either way (from 14.9 the deck 0.622
	# m ahead toward the town is section 4's, so that one faces the far pier only).
	for case: Array in [[12.5, 120], [11.0, 192], [14.9, 5]]:
		var along: float = case[0]
		var ticks: int = case[1]
		var yaws: Array[float] = [0.0]
		if along != 14.9:
			yaws.append(PI)
		for yaw: float in yaws:
			var facing: String = "facing the far pier" if yaw == 0.0 else "facing the town"
			var sim: NightSim = _strip_underfoot(along, yaw)
			_until(sim, FALL_TICK)
			var strip: Array[NightEvent] = sim.advance()
			_check("gd68 %.1f %s: tick 120: PLANK_STRIPPED s3 then EDGING_STARTED s3 (step 4)" % [along, facing],
					_names(strip) == str(["PLANK_STRIPPED s3", "EDGING_STARTED s3"]) and strip[1].side == RIGHT, _names(strip))
			_check("gd68 %.1f %s: the feet stay where they stood, not walking" % [along, facing],
					sim.warden.position.distance_to(Vector3(0.0, 0.0, along - 30.0)) < TOL and not WardenRules.walking(sim),
					str(sim.warden.position))
			var events: Array[NightEvent] = _until(sim, FALL_TICK + ticks)
			_check("gd68 %.1f %s: nothing until tick %d" % [along, facing, FALL_TICK + ticks], events.is_empty()
					and not WardenRules.walking(sim), _names(events))
			var ended: Array[NightEvent] = sim.advance()
			_check("gd68 %.1f %s: EDGING_ENDED s3 R on tick %d (120 + %d)" % [along, facing, FALL_TICK + ticks, ticks],
					_names(ended) == str(["EDGING_ENDED s3"]) and ended[0].side == RIGHT, _names(ended))
			_check("gd68 %.1f %s: on section 4 at (2.2, 0, -14.7), walking" % [along, facing],
					sim.warden.position.distance_to(Vector3(2.2, 0.0, -14.7)) < TOL and WardenRules.walking(sim),
					str(sim.warden.position))
			_check("gd68 %.1f %s: no fault" % [along, facing], _faults.total() == 0, str(_faults.codes()))


func _test_the_last_plank_underfoot_half_way() -> void:
	# From 12.5 (to (2.2, 0, -15.0) in 120 ticks), sidestepping onto the beam line in the first 30
	# (Sonlm's play of M1): on tick 135 half way across, (1.1, 0, -17.1875); on tick 180, half way
	# along and on the line, (2.2, 0, -16.25).
	var sim: NightSim = _strip_underfoot(12.5)
	_until(sim, 136)
	_check("gd68: tick 135: (1.1, 0, -17.1875)", sim.warden.position.distance_to(Vector3(1.1, 0.0, -17.1875)) < TOL,
			str(sim.warden.position))
	_until(sim, 181)
	_check("gd68: tick 180, half way: (2.2, 0, -16.25)", sim.warden.position.distance_to(Vector3(2.2, 0.0, -16.25)) < TOL,
			str(sim.warden.position))


func _test_the_last_plank_underfoot_into_a_gap() -> void:
	# L9: section 4 fallen from the start. The GD-68 edging of section 3 from 12.5 ends on 240 and the
	# gap of section 4 is crossed from there: cut down to (2.2, -1.4, -15.0), 480 ticks, onto section 5.
	var sim: NightSim = _strip_underfoot(12.5, 0.0, [4])
	_until(sim, 240)
	var ended: Array[NightEvent] = sim.advance()
	_check("gd68 gap: tick 240: EDGING_ENDED s3 then CROSSING_STARTED s4", _names(ended)
			== str(["EDGING_ENDED s3", "CROSSING_STARTED s4"]), _names(ended))
	_check("gd68 gap: cut down to (2.2, -1.4, -15.0)", sim.warden.position.distance_to(Vector3(2.2, -1.4, -15.0)) < TOL,
			str(sim.warden.position))
	var events: Array[NightEvent] = _until(sim, 721)
	_check("gd68 gap: CROSSING_ENDED s4 on tick 720 (240 + 480)", _names(events) == str(["CROSSING_ENDED s4"])
			and roundi(events[0].t * 60.0) == 720, _names(events))
	_check("gd68 gap: up on section 5 at (2.2, 0, -9.7)", sim.warden.position.distance_to(Vector3(2.2, 0.0, -9.7)) < TOL
			and WardenRules.walking(sim), str(sim.warden.position))
	_check("gd68 gap: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_a_section_that_goes_open_beside_the_warden() -> void:
	# AC 8, L7 (D3): section 3 at 1 plank. On section 4 at along 15.1 (0.1 m from it), facing the far
	# pier, the warden strips its last plank (the aim lands at 14.478): on tick 120 the feet step back
	# to along 15.3, x kept, with no event but the strip.
	var start: StartState = StartState.new()
	start.planks = {3: 1}
	start.warden_along = 15.1
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	_until(sim, FALL_TICK)
	var strip: Array[NightEvent] = sim.advance()
	_check("open beside: tick 120: the strip and nothing else", _names(strip) == str(["PLANK_STRIPPED s3"]), _names(strip))
	_check("open beside: stepped back to along 15.3: (0, 0, -14.7), walking",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -14.7)) < TOL and WardenRules.walking(sim)
			and WardenRules.can_stand(sim.warden.position, sim), str(sim.warden.position))
	var before: int = sim.checksum()
	ConsequenceRules.settle(sim)
	_check("open beside: a second settle changes nothing", sim.checksum() == before)
	# On section 2 at along 9.9, facing the town (the aim lands at 10.522): back to along 9.7.
	start = StartState.new()
	start.planks = {3: 1}
	start.warden_along = 9.9
	sim = _sim_with(_def_with(start), 1)
	sim.set_view(PI, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	_until(sim, FALL_TICK)
	strip = sim.advance()
	_check("open beside far: tick 120: the strip and nothing else", _names(strip) == str(["PLANK_STRIPPED s3"]), _names(strip))
	_check("open beside far: stepped back to along 9.7: (0, 0, -20.3)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -20.3)) < TOL and WardenRules.walking(sim), str(sim.warden.position))
	# The negative: at along 14.9 the feet are on section 3 itself, so GD-68's edging begins (5 ticks)
	# from where they stand, and there is no step back to section 4.
	sim = _strip_underfoot(14.9)
	_until(sim, FALL_TICK + 1)
	_check("open under: at 14.9 no step back: the edging begins from (0, 0, -15.1)", sim.warden.move == WardenState.Move.EDGING
			and sim.warden.position.distance_to(Vector3(0.0, 0.0, -15.1)) < TOL, str(sim.warden.position))
	before = sim.checksum()
	ConsequenceRules.settle(sim)
	_check("open under: a second settle changes nothing", sim.checksum() == before)
	_check("open: no fault", _faults.total() == 0, str(_faults.codes()))


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


func _test_the_step_back_on_the_far_pier_side() -> void:
	# D2's other direction: the warden on section 3 at along 14.9, 0.1 m from section 4 (along 15 to
	# 20), which falls on tick 120. The feet step back toward the far pier, to along 14.7 (z -15.3).
	var sim: NightSim = _night({4: 3}, {4: 4}, 14.9)
	_until(sim, FALL_TICK)
	_check("d2 far: before the fall at along 14.9 (z -15.1)", sim.warden.position.distance_to(Vector3(0.0, 0.0, -15.1)) < TOL,
			str(sim.warden.position))
	var fell: Array[NightEvent] = sim.advance()
	_check("d2 far: tick 120: the fall, and no catch", _kinds(fell) == [NightEvent.Kind.SECTION_FELL], _names(fell))
	_check("d2 far: in the same tick the feet stepped back to along 14.7 (z -15.3)",
			sim.warden.position.distance_to(Vector3(0.0, 0.0, -15.3)) < TOL, str(sim.warden.position))
	_check("d2 far: and can stand there, walking", WardenRules.can_stand(sim.warden.position, sim) and WardenRules.walking(sim))
	for i: int in 10:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	_check("d2 far: they walk away from the gap (14.7 - 10 steps)", absf(sim.warden.position.z + 30.0 - (14.7 - 10 * STEP)) < TOL,
			str(sim.warden.position))
	for i: int in 30:
		sim.set_move(Vector2(0.0, 1.0))
		sim.advance()
	_check("d2 far: walking back toward the gap stops at along 14.7", absf(sim.warden.position.z + 30.0 - 14.7) < TOL,
			str(sim.warden.position))
	_check("d2 far: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_step_back_does_not_count_against_a_hold() -> void:
	# D2: "a hold on another target goes on". GD-19: a hold is cancelled by walking more than 0.5 m
	# from where it began. The rail hold of the D2 test begins at along 20.1, x 1.0; the warden then
	# walks 0.48 m across to x 1.48 (under 0.5 m). The step back adds 0.2 m along: 0.52 m in a straight
	# line from where the hold began, of which the warden walked 0.48. The hold goes on.
	var sim: NightSim = _beside()
	var eye: Vector3 = sim.warden.position + Vector3(0.0, 1.6, 0.0)
	var to: Vector3 = Vector3(2.5, 1.0, 20.6 - 30.0) - eye
	sim.set_view(atan2(-to.x, -to.z), atan2(to.y, Vector2(to.x, to.z).length()))
	sim.advance()
	sim.command(NightCommand.press(NightTypes.HandInput.ROPE))
	var began: int = sim.tick
	sim.advance()
	_check("d2 hold: the rail hold began at along 20.1, x 1.0", sim.hands.holding()
			and sim.hands.began_at.distance_to(Vector3(1.0, 0.0, -9.9)) < TOL, str(sim.hands.began_at))
	_walk_to_x(sim, 1.48)
	_until(sim, FALL_TICK)
	_check("d2 hold: before the fall: at along 20.1, x 1.48, the rail hold running", sim.hands.holding()
			and sim.warden.position.distance_to(Vector3(1.48, 0.0, -9.9)) < TOL, str(sim.warden.position))
	var fell: Array[NightEvent] = sim.advance()
	_check("d2 hold: tick 120: the fall; the feet step back to along 20.3, x 1.48",
			_kinds(fell) == [NightEvent.Kind.SECTION_FELL] and sim.warden.position.distance_to(Vector3(1.48, 0.0, -9.7)) < TOL,
			"%s %s" % [_names(fell), sim.warden.position])
	var rest: Array[NightEvent] = _until(sim, began + 181)
	_check("d2 hold: not cancelled on tick 121: it completes on its tick (begun + 180)", rest.size() == 1
			and rest[0].kind == NightEvent.Kind.RAIL_STRIPPED and roundi(rest[0].t * 60.0) == began + 180, _names(rest))
	_check("d2 hold: no fault", _faults.total() == 0, str(_faults.codes()))


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
	# built by running the fall tick's steps by hand, up to the one that settles the loads (found by
	# its name, so a renumbered tick cannot change what this sets up). AD-64 asks for each step tested
	# alone, and no command or tick leaves a sim between steps 7 and 8.
	var sim: NightSim = _night({4: 3}, {4: 4}, 17.5)
	_until(sim, FALL_TICK)
	for step: Callable in sim._steps:
		if step.get_method() == &"_step_consequences_of_loads":
			break
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
