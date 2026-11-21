## The warden's walking (AD-52, story 1.3): the feet move inside what can be walked on, and stop
## at its edges. No physics body, collider or ray decides anything: what can be walked on is the
## floor rectangle of every section that has at least one plank and has not fallen, and the
## landing, all asked of SpanGeometry (plus, until story 1.6, a bare section that still holds the
## warden: D3 in walk()). Every rectangle is axis-aligned, so an edge is found from the rectangles'
## sides, never by searching in small steps.
##
## The timed moves (AD-52) are this file's too, counted in whole ticks: story 1.5's climb back after
## a fall (decision D3). While one runs the warden is not walking: the move wish is ignored, and
## HoldRules ignores every press and lowers the hands.
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
		if sim.span.planks(n) > 0 and not sim.span.fallen(n):
			floors.append(_floor_of(sim.geometry.deck_box(n)))
	floors.append(_floor_of(sim.geometry.landing_box()))
	return floors


## Step 1 of the tick (AD-34): moves the feet by this tick's wish. The X part first, then the Z
## part from the new X; each takes its whole share if the end can be stood on, otherwise stops at
## the farthest point on that axis that can (the clearance limit). The other axis keeps its share,
## so a diagonal into a rail slides along it. A zero wish moves nothing. Pushing into an edge is not
## a mistake: nothing is emitted and nothing faults.
##
## Story 1.4 decision D3, until story 1.6's edging: a section that went bare under the warden, or
## within CLEARANCE of the feet, still holds them. When the feet cannot be stood on, this tick's
## floors also take every section with no plank that holds the feet or one of the four clearance
## probes (held_by_bare()), so the warden walks out through the 0.3 m band. Once can_stand() is
## true again nothing is added and the bare section blocks as before (story 1.3 D1). Normal
## walking never reaches a spot that cannot be stood on, so "cannot stand here" already means
## "was here when it went bare": nothing is stored.
##
## A warden who is not walking (a timed move, story 1.5) does not walk: the wish is ignored.
static func walk(sim: NightSim) -> void:
	var step: Vector2 = sim.move_wish * sim.walk_step
	if step == Vector2.ZERO or not walking(sim):
		return
	var floors: Array[Rect2] = walkable(sim)
	var at: Vector3 = sim.warden.position
	if not stands_on(at, floors):
		floors.append_array(held_by_bare(at, sim))
	if step.x != 0.0:
		at = reach(at, Vector3(step.x, 0.0, 0.0), floors)
	if step.y != 0.0:
		at = reach(at, Vector3(0.0, 0.0, step.y), floors)
	at.y = 0.0
	sim.warden.position = at


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


## Pure: story 1.4 D3. The floor of every section with no plank that holds the feet at
## `position` or one of its four clearance probes. A fallen section has no plank too, and is never
## one: it is no floor at all (story 1.5).
static func held_by_bare(position: Vector3, sim: NightSim) -> Array[Rect2]:
	var c: float = WardenConstants.CLEARANCE
	var feet: Vector2 = Vector2(position.x, position.z)
	var out: Array[Rect2] = []
	for n: int in range(1, sim.def.section_count + 1):
		if sim.span.planks(n) > 0 or sim.span.fallen(n):
			continue
		var rect: Rect2 = _floor_of(sim.geometry.deck_box(n))
		for offset: Vector2 in [Vector2.ZERO, Vector2(c, 0.0), Vector2(-c, 0.0), Vector2(0.0, c), Vector2(0.0, -c)]:
			if _on_floor(feet + offset, [rect]):
				out.append(rect)
				break
	return out


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
## toward the town that has planks and has not fallen, else the landing (0). Worked out when the
## climb begins and again when it ends, so a section that falls or goes bare meanwhile is passed.
static func climb_target(from_section: int, sim: NightSim) -> int:
	for n: int in range(from_section + 1, sim.def.section_count + 1):
		if sim.span.planks(n) > 0 and not sim.span.fallen(n):
			return n
	return 0


## Step 8 (ConsequenceRules.warden_footing): the warden's section `section` fell. They catch the
## edge (decision D3): the feet go at once to the hang point of the section (or landing) they will
## climb onto, and the climb back runs sim.ticks.climb_back ticks (WARDEN_CAUGHT).
static func start_climb(section: int, sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	warden.move = WardenState.Move.CLIMBING
	warden.move_ticks_left = sim.ticks.climb_back
	warden.fell_from = section
	warden.position = sim.geometry.hang_point(climb_target(section, sim), warden.position.x)
	var event: NightEvent = NightEvent.make(NightEvent.Kind.WARDEN_CAUGHT)
	event.section = section
	sim.emit(event)


## Step 1, before the walk: the running timed move counts down. Begun on tick F (WARDEN_CAUGHT),
## the climb ends on F + sim.ticks.climb_back (AD-33): the feet go onto the deck of the section it
## ends on, worked out now, CLEARANCE in from its edge (WARDEN_CLIMBED, section 0 for the landing),
## and the warden walks again from this same tick on.
static func tick_moves(sim: NightSim) -> void:
	var warden: WardenState = sim.warden
	if warden.move == WardenState.Move.WALKING:
		return
	warden.move_ticks_left -= 1
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


## Step 8 (ConsequenceRules.warden_footing), story 1.5 decision D2: feet beside a gap, with a
## clearance probe along the span over a fallen section and on no standing floor, move straight
## away from the gap until they are CLEARANCE from its edge: at most CLEARANCE, in the same tick.
## The x is kept. Anything else (a probe over a bare section, story 1.4's D3) is left alone.
static func step_back(sim: NightSim) -> void:
	var c: float = WardenConstants.CLEARANCE
	var at: Vector3 = sim.warden.position
	var standing: Array[Rect2] = _standing_floors(sim)
	for n: int in range(1, sim.def.section_count + 1):
		if not sim.span.fallen(n):
			continue
		var gap: Rect2 = _floor_of(sim.geometry.deck_box(n))
		for toward: float in [-c, c]:
			var probe: Vector2 = Vector2(at.x, at.z + toward)
			if not _on_floor(probe, [gap]) or _on_floor(probe, standing):
				continue
			# The gap's edge on the feet's side, and the spot CLEARANCE beyond it.
			var edge: float = gap.end.y if toward < 0.0 else gap.position.y
			at.z = edge - signf(toward) * c
	sim.warden.position = at


## The floors that stand this tick: every section that has not fallen (planked or bare), and the
## landing. What "on no standing floor" is measured against.
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
