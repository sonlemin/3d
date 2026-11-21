## What the warden looks at (AD-15, AD-47): maths on SpanGeometry's boxes, no physics and no ray
## (AD-52). The view line runs from the eye along the view for HandConstants.REACH; the nearest
## shape it meets wins. Decks (planked or not) and standing rails' grab boxes (story 1.4 D1) are
## targets; the landing and the far pier only block. A fallen section (story 1.5) has no deck and no
## rails: it is neither a target nor a blocker. Pure: it emits nothing.
class_name LookRules
extends RefCounted


## Pure: the target of the view from `eye` (world, metres) at `yaw` and `pitch` (radians, AD-67:
## yaw 0 faces -Z and positive turns left; pitch positive up), on `span`'s state.
static func target(eye: Vector3, yaw: float, pitch: float, geometry: SpanGeometry, span: SpanState) -> LookTarget:
	var to: Vector3 = eye + view_direction(yaw, pitch) * HandConstants.REACH
	var best: LookTarget = LookTarget.none()
	var nearest: float = INF
	# The far pier hides nothing from anywhere the warden can stand today (every target lies on
	# the town side of it); it blocks for a view line that crosses it, as test_look.gd builds one.
	for blocker: AABB in [geometry.landing_box(), geometry.far_pier_box()]:
		nearest = minf(nearest, _hit(blocker, eye, to))
	for n: int in range(1, span.section_count() + 1):
		if span.fallen(n):
			continue
		var at: float = _hit(geometry.deck_box(n), eye, to)
		if at < nearest:
			nearest = at
			best = LookTarget.deck(n, at)
		for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
			if not span.rail_standing(n, side):
				continue
			at = _hit(geometry.rail_grab_box(n, side), eye, to)
			if at < nearest:
				nearest = at
				best = LookTarget.rail(n, side, at)
	return best


## Pure: the unit view direction for `yaw` and `pitch` (AD-67).
static func view_direction(yaw: float, pitch: float) -> Vector3:
	return Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch))


## The distance from `from` to where the segment first meets `box`, or INF when it misses.
## AABB.intersects_segment returns `from` itself when `from` is inside.
static func _hit(box: AABB, from: Vector3, to: Vector3) -> float:
	var point: Variant = box.intersects_segment(from, to)
	if point is Vector3:
		return from.distance_to(point as Vector3)
	return INF
