## The warden's walking (AD-52, story 1.3): the feet move inside what can be walked on, and stop
## at its edges. No physics body, collider or ray decides anything: what can be walked on is the
## floor rectangle of every section that has at least one plank, and the landing, all asked of
## SpanGeometry. Every rectangle is axis-aligned, so an edge is found from the rectangles' sides,
## never by searching in small steps.
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
	var floors: Array[Rect2] = walkable(sim)
	var c: float = WardenConstants.CLEARANCE
	for offset: Vector2 in [Vector2(c, 0.0), Vector2(-c, 0.0), Vector2(0.0, c), Vector2(0.0, -c)]:
		if not _on_floor(Vector2(position.x, position.z) + offset, floors):
			return false
	return true


## Pure: this tick's walkable floor, as rectangles in world x (Rect2.x) and z (Rect2.y): each
## section with at least one plank, then the landing.
static func walkable(sim: NightSim) -> Array[Rect2]:
	var floors: Array[Rect2] = []
	for n: int in range(1, sim.def.section_count + 1):
		if sim.span.planks(n) > 0:
			floors.append(_floor_of(sim.geometry.deck_box(n)))
	floors.append(_floor_of(sim.geometry.landing_box()))
	return floors


## Step 1 of the tick (AD-34): moves the feet by this tick's wish. The X part first, then the Z
## part from the new X; each takes its whole share if the end can be stood on, otherwise stops at
## the farthest point on that axis that can (the clearance limit). The other axis keeps its share,
## so a diagonal into a rail slides along it. A zero wish moves nothing. Pushing into an edge is not
## a mistake: nothing is emitted and nothing faults.
##
## Story 1.4 will let a warden whose section lost its last plank step off it ("may step from a
## spot that cannot be stood on onto one that can"): that belongs in _reach(), which today keeps
## such a warden where it is.
static func walk(sim: NightSim) -> void:
	var step: Vector2 = sim.move_wish * sim.walk_step
	if step == Vector2.ZERO:
		return
	var at: Vector3 = sim.warden.position
	if step.x != 0.0:
		at = _reach(at, Vector3(step.x, 0.0, 0.0), sim)
	if step.y != 0.0:
		at = _reach(at, Vector3(0.0, 0.0, step.y), sim)
	at.y = 0.0
	sim.warden.position = at


## Where the feet at `from` end after `move` along one axis: `from + move` if it can be stood
## on, otherwise the end of the standable stretch that holds `from`. The stretch can only end
## where some rectangle's side, less the clearance, falls; those are the candidates, tried
## nearest first, each probed just beyond.
static func _reach(from: Vector3, move: Vector3, sim: NightSim) -> Vector3:
	var target: Vector3 = from + move
	if can_stand(target, sim):
		return target
	if not can_stand(from, sim):
		return from
	var axis: int = Vector3.AXIS_X if move.x != 0.0 else Vector3.AXIS_Z
	var sign_of: float = signf(move[axis])
	var length: float = absf(move[axis])
	var c: float = WardenConstants.CLEARANCE
	var stops: Array[float] = []
	for rect: Rect2 in walkable(sim):
		var low: float = rect.position.x if axis == Vector3.AXIS_X else rect.position.y
		var high: float = rect.end.x if axis == Vector3.AXIS_X else rect.end.y
		for edge: float in [low + c, high - c]:
			var ahead: float = (edge - from[axis]) * sign_of
			if ahead >= -EDGE_SLACK and ahead <= length:
				stops.append(maxf(ahead, 0.0))
	stops.sort()
	for ahead: float in stops:
		var beyond: Vector3 = from
		beyond[axis] += (ahead + PROBE) * sign_of
		if not can_stand(beyond, sim):
			var stop: Vector3 = from
			stop[axis] += ahead * sign_of
			return stop
	return from


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
