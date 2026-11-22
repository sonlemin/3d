## The warden's walking (AD-52, story 1.3): the feet move inside what can be walked on, and stop
## at its edges. No physics body, collider or ray decides anything: what can be walked on is the
## floor rectangle of every section that has at least one plank and has not fallen, and the
## landing, all asked of SpanGeometry. Every rectangle is axis-aligned, so an edge is found from the
## rectangles' sides, never by searching in small steps.
##
## The timed moves (AD-52) are this file's too, counted in whole ticks: story 1.5's climb back after
## a fall (decision D3), and story 1.6's edging round an open section along its side beam (4 s) and
## crossing a gap hand over hand (8 s), one move per section, begun by pushing into it (D1) or, for
## an edging, by the last plank going underfoot (GD-68). While one runs the warden is not walking:
## the move wish is ignored, and HoldRules ignores every press and lowers the hands.
class_name WardenRules
extends RefCounted

## Float slack for "on a rectangle", in metres: a limit worked out as edge - CLEARANCE may land a
## rounding error past the edge. Not a rule number; far below the 0.001 m the tests check.
const EDGE_SLACK: float = 0.0001
## How far past a candidate stop the next spot is probed, in metres: more than EDGE_SLACK, so the
## probe really is past the edge it tests.
const PROBE: float = 0.001


## Pure: true when the feet at `position` keep WardenConstants.CLEARANCE from every edge of the
## walkable area that is not shared (decision D1). The point moved CLEARANCE along +x, -x, +z and
## -z must each still lie on a walkable rectangle; a point on a shared edge is on both.
static func can_stand(position: Vector3, sim: NightSim) -> bool:
	return stands_on(position, walkable(sim))


## Pure: can_stand() on a given list of floor rectangles (world x and z), so the rule can be
## checked on floors of any shape, not only the one night's.
static func stands_on(position: Vector3, floors: Array[Rect2]) -> bool:
	var c: float = WardenConstants.CLEARANCE
	for offset: Vector2 in [Vector2(c, 0.0), Vector2(-c, 0.0), Vector2(0.0, c), Vector2(0.0, -c)]:
		if not _on_floor(Vector2(position.x, position.z) + offset, floors):
			return false
	return true


## Pure: this tick's walkable floor, as rectangles in world x (Rect2.x) and z (Rect2.y): each
## section with at least one plank that has not fallen, then the landing.
static func walkable(sim: NightSim) -> Array[Rect2]:
	var floors: Array[Rect2] = []
	for n: int in range(1, sim.def.section_count + 1):
		if _floor_section(n, sim):
			floors.append(_floor_of(sim.geometry.deck_box(n)))
	floors.append(_floor_of(sim.geometry.landing_box()))
	return floors


## Step 1 of the tick (AD-34): moves the feet by this tick's wish. The X part first, then the Z
## part from the new X; each takes its whole share if the end can be stood on, otherwise stops at
## the farthest point on that axis that can (the clearance limit). The other axis keeps its share,
## so a diagonal into a rail slides along it. A zero wish moves nothing. Pushing into an edge is not
## a mistake: nothing is emitted and nothing faults. Then the push of story 1.6 (push()).
##
## A warden who is not walking (a timed move) does not walk: the wish is ignored. (Story 1.4's D3,
## a bare section holding the warden until they step off it, is gone: a walking warden is never on
## a section that cannot be stood on, since GD-68 puts them on its beam and D3 steps them back.)
static func walk(sim: NightSim) -> void:
	if not walking(sim):
		return
	var step: Vector2 = sim.move_wish * sim.walk_step
	if step != Vector2.ZERO:
		var floors: Array[Rect2] = walkable(sim)
		var at: Vector3 = sim.warden.position
		if step.x != 0.0:
			at = reach(at, Vector3(step.x, 0.0, 0.0), floors)
		if step.y != 0.0:
			at = reach(at, Vector3(0.0, 0.0, step.y), floors)
		at.y = 0.0
		sim.warden.position = at
	push(sim)


## Step 1, after the walk (story 1.6 decision D1): the push that begins an edging or a crossing. A
## tick counts when the wish's along part is not 0 and at least as large as its across part (within
## 45 degrees of straight in), the section just ahead of the feet that way cannot be stood on (open
## or fallen), the feet are at its stop (CLEARANCE from its near edge), and the run from it that way
## ends on a floor (way_on()). Any other walking tick starts the count again. On the tick the count
## passes sim.ticks.push_to_cross (pushing from tick T: in step 1 of T + 30) the move begins.
static func push(sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	var ahead: int = 0
	var toward: int = 0
	var wish: Vector2 = sim.move_wish
	if wish.y != 0.0 and absf(wish.y) >= absf(wish.x):
		toward = 1 if wish.y > 0.0 else -1
		ahead = _blocked_ahead(toward, sim)
	if ahead == 0 or not way_on(ahead, toward, sim):
		warden.pushed = 0
		return
	warden.pushed += 1
	if warden.pushed > sim.ticks.push_to_cross:
		begin_move(ahead, toward, sim.ticks.edge, sim)


## Pure: the section the feet stand at the stop of, heading `toward`: one that cannot be stood on
## (open or fallen) whose near edge is CLEARANCE ahead of the feet; 0 for none.
static func _blocked_ahead(toward: int, sim: NightSim) -> int:
	var along: float = sim.warden.position.z - sim.geometry.world_z(0.0)
	for n: int in range(1, sim.def.section_count + 1):
		if _floor_section(n, sim):
			continue
		var ahead: float = (sim.geometry.near_edge(n, toward) - along) * toward
		if ahead >= -EDGE_SLACK and ahead <= WardenConstants.CLEARANCE + EDGE_SLACK:
			return n
	return 0


## Pure (story 1.6 AC 9): true when the run of sections that cannot be stood on, starting at
## `section` and heading `toward`, ends on a floor: a section with planks that has not fallen, or
## the landing past the town section. Toward the far pier it can end at the pier: false.
static func way_on(section: int, toward: int, sim: NightSim) -> bool:
	var n: int = section
	while n >= 1 and n <= sim.def.section_count:
		if _floor_section(n, sim):
			return true
		n += toward
	return n > sim.def.section_count


## Begins the edging (an open section) or crossing (a fallen one) of `section` heading `toward`,
## from where the feet are now (decision D2). An edging lasts `edge_ticks` (sim.ticks.edge, or GD-68's
## share of it) and keeps the feet where they stand on its first tick, then sidesteps them onto the
## nearer side beam's line (right when x >= 0) at deck height and along it (move_point()). A crossing lasts sim.ticks.cross_gap,
## whatever `edge_ticks` says: the feet cut down to hang at the gap's near edge, x kept. The push
## starts again from 0. Emits EDGING_STARTED or CROSSING_STARTED.
static func begin_move(section: int, toward: int, edge_ticks: int, sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	var g: SpanGeometry = sim.geometry
	var x: float = warden.position.x
	var event: NightEvent
	warden.move_section = section
	warden.move_toward = toward
	warden.pushed = 0
	if sim.span.fallen(section):
		warden.move = WardenState.Move.CROSSING
		warden.move_from = g.crossing_point(g.near_edge(section, toward), x)
		warden.move_to = g.crossing_point(g.far_edge(section, toward), x)
		warden.move_ticks_total = sim.ticks.cross_gap
		event = NightEvent.make(NightEvent.Kind.CROSSING_STARTED)
	else:
		var side: NightTypes.Side = NightTypes.Side.RIGHT if x >= 0.0 else NightTypes.Side.LEFT
		warden.move = WardenState.Move.EDGING
		warden.move_from = Vector3(x, 0.0, warden.position.z)
		warden.move_to = g.edging_point(side, g.far_edge(section, toward))
		warden.move_ticks_total = maxi(edge_ticks, 1)
		event = NightEvent.make(NightEvent.Kind.EDGING_STARTED)
		event.side = side
	warden.move_ticks_left = warden.move_ticks_total
	warden.position = warden.move_from
	event.section = section
	sim.emit(event)


## Step 4 or 8 (ConsequenceRules.warden_on_beams), GD-68: the warden's section `section` went open
## under them. They are on its side beam at once and finish the crossing toward the town from where
## they stand, in the share of sim.ticks.edge that the distance left to its town-side edge is of a
## section's length: rounded to whole ticks, at least 1.
static func begin_beams(section: int, sim: NightSim) -> void:
	var along: float = sim.warden.position.z - sim.geometry.world_z(0.0)
	var left: float = sim.geometry.section_end(section) - along
	var ticks: int = maxi(roundi(sim.ticks.edge * left / SpanConstants.SECTION_LENGTH), 1)
	begin_move(section, 1, ticks, sim)


## Pure: the section the feet (the point itself) stand on that has gone open, on no floor that can
## be walked on; 0 when there is none (GD-68: "on a section when its last plank is taken"). Feet on
## a shared edge with a section that has planks are on that one.
static func on_open(sim: NightSim) -> int:
	var feet: Vector2 = Vector2(sim.warden.position.x, sim.warden.position.z)
	if _on_floor(feet, walkable(sim)):
		return 0
	for n: int in range(1, sim.def.section_count + 1):
		if SpanRules.open(n, sim.span) and _on_floor(feet, [_floor_of(sim.geometry.deck_box(n))]):
			return n
	return 0


## Pure: where the feet at `from` end after `move` along one axis (x or z) on `floors`:
## `from + move` if it can be stood on, otherwise the end of the standable stretch that holds
## `from`. Standing depends on four probe points, so along the axis it can only change where a
## probe crosses a rectangle's side: at the side itself (the two probes across the move) and
## CLEARANCE before or after it (the two along the move). Those are the candidates, tried nearest
## first, each probed just beyond. This holds for rectangles of any widths (the landing's width
## is a gray-box size and need not stay the sections').
static func reach(from: Vector3, move: Vector3, floors: Array[Rect2]) -> Vector3:
	var target: Vector3 = from + move
	if stands_on(target, floors):
		return target
	if not stands_on(from, floors):
		return from
	var axis: int = Vector3.AXIS_X if move.x != 0.0 else Vector3.AXIS_Z
	var sign_of: float = signf(move[axis])
	var length: float = absf(move[axis])
	var c: float = WardenConstants.CLEARANCE
	var stops: Array[float] = []
	for rect: Rect2 in floors:
		var low: float = rect.position.x if axis == Vector3.AXIS_X else rect.position.y
		var high: float = rect.end.x if axis == Vector3.AXIS_X else rect.end.y
		for edge: float in [low - c, low, low + c, high - c, high, high + c]:
			var ahead: float = (edge - from[axis]) * sign_of
			if ahead >= -EDGE_SLACK and ahead <= length:
				stops.append(maxf(ahead, 0.0))
	stops.sort()
	for ahead: float in stops:
		var beyond: Vector3 = from
		beyond[axis] += (ahead + PROBE) * sign_of
		if not stands_on(beyond, floors):
			var stop: Vector3 = from
			stop[axis] += ahead * sign_of
			return stop
	return from


## Pure: true while the warden walks: no timed move is running (AD-52). HoldRules and the aim aid
## ask it.
static func walking(sim: NightSim) -> bool:
	return sim.warden.move == WardenState.Move.WALKING


## Pure (story 1.5, "Who falls with a section"): the section that fell under the feet, or 0. The
## feet (the point itself) lie on a fallen section's floor and on no floor of a section that has
## not fallen, nor on the landing. Feet on a shared edge with a standing section are on that one.
static func fell_from(sim: NightSim) -> int:
	var feet: Vector2 = Vector2(sim.warden.position.x, sim.warden.position.z)
	if _on_floor(feet, _standing_floors(sim)):
		return 0
	for n: int in range(1, sim.def.section_count + 1):
		if sim.span.fallen(n) and _on_floor(feet, [_floor_of(sim.geometry.deck_box(n))]):
			return n
	return 0


## Pure: where a climb from the fallen section `from_section` ends: the first section after it
## toward the town that has planks and has not fallen, else the landing (0). An open section is
## passed: there is no deck to climb onto. Worked out when the climb begins, at
## every settle while it runs (hang_on()) and again when it ends, so a section that falls or goes
## open meanwhile is passed.
static func climb_target(from_section: int, sim: NightSim) -> int:
	for n: int in range(from_section + 1, sim.def.section_count + 1):
		if sim.span.planks(n) > 0 and not sim.span.fallen(n):
			return n
	return 0


## Step 8 (ConsequenceRules.warden_footing): the warden's section `section` fell, under their feet
## or (story 1.6 AC 10) under the side beam they were edging along. They catch the edge (decision
## D3): the feet go at once to the hang point of the section (or landing) they will climb onto, and
## the climb back runs sim.ticks.climb_back ticks (WARDEN_CAUGHT). An edging's facts are cleared.
static func start_climb(section: int, sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	_clear_move(warden)
	warden.move = WardenState.Move.CLIMBING
	warden.move_ticks_left = sim.ticks.climb_back
	warden.fell_from = section
	warden.position = sim.geometry.hang_point(climb_target(section, sim), warden.position.x)
	var event: NightEvent = NightEvent.make(NightEvent.Kind.WARDEN_CAUGHT)
	event.section = section
	sim.emit(event)


## Step 8 (ConsequenceRules.warden_footing), while climbing: the feet hang from the edge of what
## the climb would end on now. When that section fell (or went open) since the catch, they cut to
## the next edge toward the town in the same tick (code review 2026-11-22, Sonlm). It is the same
## catch: no event, and the climb's ticks keep running. With nothing changed it moves nothing.
static func hang_on(sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	warden.position = sim.geometry.hang_point(climb_target(warden.fell_from, sim), warden.position.x)


## Step 1, before the walk: the running timed move counts down. Begun on tick F (WARDEN_CAUGHT),
## the climb ends on F + sim.ticks.climb_back (AD-33): the feet go onto the deck of the section it
## ends on, worked out now, CLEARANCE in from its edge (WARDEN_CLIMBED, section 0 for the landing),
## and the warden walks again from this same tick on. An edging or a crossing (story 1.6) moves the
## feet one tick along its line, worked out from the ticks left; on its last tick it ends
## (end_move()).
static func tick_moves(sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	if warden.move == WardenState.Move.WALKING:
		return
	warden.move_ticks_left -= 1
	if warden.move == WardenState.Move.EDGING or warden.move == WardenState.Move.CROSSING:
		if warden.move_ticks_left > 0:
			warden.position = move_point(warden, warden.move_ticks_total - warden.move_ticks_left, sim.ticks)
		else:
			end_move(sim)
		return
	if warden.move_ticks_left > 0:
		return
	var onto: int = climb_target(warden.fell_from, sim)
	warden.position = sim.geometry.climb_end(onto, warden.position.x)
	warden.move = WardenState.Move.WALKING
	warden.move_ticks_left = 0
	warden.fell_from = 0
	var event: NightEvent = NightEvent.make(NightEvent.Kind.WARDEN_CLIMBED)
	event.section = onto
	sim.emit(event)


## Pure: where the feet of the running edging or crossing are `done` ticks after it began (0 to
## move_ticks_total), worked out from its ends, never summed. Sonlm's play of M1 of story 1.6
## (2026-11-22): an edging's along part moves steadily over the whole move while its x sidesteps
## onto the beam line within sim.ticks.edge_sidestep (or the whole move, if shorter), so it goes
## straight along the beam after that; a crossing goes hand over hand in reaches of
## WardenConstants.CROSS_REACH, each a pull eased over WardenConstants.CROSS_PULL_SHARE of its time
## and then still, x and height kept.
static func move_point(warden: WardenState, done: int, ticks: NightTicks) -> Vector3:
	var total: int = maxi(warden.move_ticks_total, 1)
	var share: float = clampf(float(done) / total, 0.0, 1.0)
	var at: Vector3 = warden.move_from.lerp(warden.move_to, share)
	if warden.move == WardenState.Move.EDGING:
		var sidestep: int = clampi(ticks.edge_sidestep, 1, total)
		at.x = lerpf(warden.move_from.x, warden.move_to.x, clampf(float(done) / sidestep, 0.0, 1.0))
		return at
	var length: float = absf(warden.move_to.z - warden.move_from.z)
	var reaches: int = maxi(roundi(length / WardenConstants.CROSS_REACH), 1)
	var reached: float = share * reaches
	var whole: float = floorf(reached)
	var pulled: float = whole + smoothstep(0.0, WardenConstants.CROSS_PULL_SHARE, reached - whole)
	at.z = lerpf(warden.move_from.z, warden.move_to.z, pulled / reaches)
	return at


## Step 1 (tick_moves()), story 1.6: the edging or crossing of `move_section` is done (EDGING_ENDED
## or CROSSING_ENDED). The next section the same way decides what follows, worked out now: a floor
## (planks, or the landing) and the feet step onto it, CLEARANCE in, x kept, walking from this tick;
## open or fallen and the move over it begins on this same tick. Toward the far pier a run that no
## longer ends on a floor (the section beyond fell meanwhile) turns the warden back: the move over
## the section just crossed begins again, toward the town. Nothing leaves the warden nowhere to go.
static func end_move(sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	var section: int = warden.move_section
	var toward: int = warden.move_toward
	var event: NightEvent
	if warden.move == WardenState.Move.EDGING:
		event = NightEvent.make(NightEvent.Kind.EDGING_ENDED)
		event.side = NightTypes.Side.RIGHT if warden.move_to.x >= 0.0 else NightTypes.Side.LEFT
	else:
		event = NightEvent.make(NightEvent.Kind.CROSSING_ENDED)
	event.section = section
	warden.position = Vector3(warden.move_to.x, 0.0, warden.move_to.z)
	_clear_move(warden)
	warden.move = WardenState.Move.WALKING
	sim.emit(event)
	var next: int = section + toward
	if next > sim.def.section_count or (next >= 1 and _floor_section(next, sim)):
		warden.position = sim.geometry.move_end(section, toward, warden.position.x)
	elif toward < 0 and (next < 1 or not way_on(next, toward, sim)):
		begin_move(section, 1, sim.ticks.edge, sim)
	else:
		begin_move(next, toward, sim.ticks.edge, sim)


## Step 8 (ConsequenceRules.warden_footing), story 1.5 decision D2 and story 1.6 decision D3: feet
## beside a section that cannot be stood on (fallen, or open), with a clearance probe along the span
## over it and on no floor that can be walked on, move straight away from it until they are
## CLEARANCE from its edge: at most CLEARANCE, in the same tick. The x is kept. Asked only while the
## feet themselves are on a floor that can be walked on (a warden on an open section is GD-68's).
static func step_back(sim: NightSim) -> void:
	var c: float = WardenConstants.CLEARANCE
	var at: Vector3 = sim.warden.position
	var floors: Array[Rect2] = walkable(sim)
	for n: int in range(1, sim.def.section_count + 1):
		if _floor_section(n, sim):
			continue
		var gap: Rect2 = _floor_of(sim.geometry.deck_box(n))
		for toward: float in [-c, c]:
			var probe: Vector2 = Vector2(at.x, at.z + toward)
			if not _on_floor(probe, [gap]) or _on_floor(probe, floors):
				continue
			# The gap's edge on the feet's side, and the spot CLEARANCE beyond it.
			var edge: float = gap.end.y if toward < 0.0 else gap.position.y
			at.z = edge - signf(toward) * c
	sim.warden.position = at


## Pure: true when the feet (the point itself, not the probes) are on a floor that can be walked on.
static func feet_on_floor(sim: NightSim) -> bool:
	return _on_floor(Vector2(sim.warden.position.x, sim.warden.position.z), walkable(sim))


## True when section `n` can be walked on: it has a plank and has not fallen.
static func _floor_section(n: int, sim: NightSim) -> bool:
	return sim.span.planks(n) > 0 and not sim.span.fallen(n)


## Clears an edging's or crossing's facts (the move itself is set by the caller).
static func _clear_move(warden: WardenState) -> void:
	warden.move_ticks_left = 0
	warden.move_ticks_total = 0
	warden.move_section = 0
	warden.move_toward = 0
	warden.move_from = Vector3.ZERO
	warden.move_to = Vector3.ZERO
	warden.pushed = 0


## The floors that stand this tick: every section that has not fallen (planked or open), and the
## landing. What "on no standing floor" is measured against (who falls with a section).
static func _standing_floors(sim: NightSim) -> Array[Rect2]:
	var floors: Array[Rect2] = []
	for n: int in range(1, sim.def.section_count + 1):
		if not sim.span.fallen(n):
			floors.append(_floor_of(sim.geometry.deck_box(n)))
	floors.append(_floor_of(sim.geometry.landing_box()))
	return floors


## A deck or landing box seen from above: x across, z along.
static func _floor_of(box: AABB) -> Rect2:
	return Rect2(box.position.x, box.position.z, box.size.x, box.size.z)


## True when `point` lies on one of `floors`, edges included (within EDGE_SLACK).
static func _on_floor(point: Vector2, floors: Array[Rect2]) -> bool:
	for rect: Rect2 in floors:
		if point.x >= rect.position.x - EDGE_SLACK and point.x <= rect.end.x + EDGE_SLACK \
				and point.y >= rect.position.y - EDGE_SLACK and point.y <= rect.end.y + EDGE_SLACK:
			return true
	return false
