## The only source of positions and shapes on the span (AD-42, AD-62). Pure: built from a
## NightDef and holding nothing but its numbers. Views and the warden's and look rules ask here;
## no coordinate of the span is typed anywhere else. Since story 1.7 it also gives the shapes of
## the plan look (the span from straight above, for the planning screen): `plan_*`.
##
## Coordinates: `along` is metres from the far pier. The span runs along Z with the town at
## +Z: world_z = along - length, so the town pier's edge is z 0. X is across, LEFT = -X. Y is
## up; the deck's top is y 0.
class_name SpanGeometry
extends RefCounted

## GD-54 / decision D1: the place whose plank leaves next, first entry first. A plank never
## moves; the rest stay as evenly spread as 8 places allow.
const PLANK_LEAVE_ORDER: Array[int] = [3, 7, 5, 1, 8, 2, 6, 4]
## The number of plank places PLANK_LEAVE_ORDER is written for.
const ORDER_PLACES: int = 8

## Gray-box size, D2; not a rule. A plank's thickness, under the deck's top.
const PLANK_THICKNESS: float = 0.08
## Gray-box size, D2; not a rule. A plank's length along the span, centred in its place.
const PLANK_ALONG: float = 0.5
## Gray-box size, D2; not a rule. A side beam under the plank ends.
const BEAM_WIDTH: float = 0.25
## Gray-box size, D2; not a rule.
const BEAM_DEPTH: float = 0.3
## Gray-box size, D2; not a rule. The rail rope's height above the deck.
const RAIL_HEIGHT: float = 1.0
## Gray-box size, D2; not a rule.
const RAIL_THICKNESS: float = 0.05
## Story 1.4 decision D1: how far across and how tall the box is that counts as "looking at the
## rail" (LookRules), centred on the drawn rope. Wider than the 5 cm rope so a person can hold
## the view on it for a 3 s strip. Gray-box size, not a rule; tuned in M1 of story 1.4.
const RAIL_GRAB_SIZE: float = 0.3
## Gray-box size, D2; not a rule. A post at each section end, under each rail.
const POST_SIZE: float = 0.1
## Gray-box size, D2; not a rule.
const POST_HEIGHT: float = 1.1
## Gray-box size, D2; not a rule. Both piers, across.
const PIER_WIDTH: float = 7.0
## Gray-box size, D2; not a rule. Both piers, along.
const PIER_LENGTH: float = 4.0
## Gray-box size, D2 (20 m until M1 of story 1.2 showed a deep pier fills the gaps with gray;
## a 2 m pier lets them read black); not a rule. How far below the deck both piers reach.
const PIER_DEPTH: float = 2.0
## Gray-box size, D2; not a rule. The far pier rises above the deck; the warden never stands on it.
const FAR_PIER_RISE: float = 3.0
## Gray-box size, D2; not a rule. The landing: the town pier's walkable top.
const LANDING_WIDTH: float = 5.0
## Gray-box size, D2; not a rule.
const LANDING_LENGTH: float = 4.0
## Gray-box size, story 1.5; not a rule. A test weight's cube.
const WEIGHT_SIZE: float = 0.5
## Story 1.5: the weights' grid, a layer of 3 across by 3 along, filled from the middle out (so a
## single weight sits mid-section); then the next layer up. Across, in metres from the centre line.
const WEIGHT_ACROSS: Array[float] = [0.0, -1.5, 1.5]
## Along, in metres from the section's far-pier end: the middle 2.5 m, so no weight stands within
## 1.25 m of either end, where the deck is aimed at from the next section.
const WEIGHT_ALONG: Array[float] = [2.5, 1.75, 3.25]
## Sonlm's play of M1 of story 1.6 (2026-11-22): one rope stays strung across a fallen section, along
## its centre line (this x), for the warden to cross hand over hand under it. A gray-box size, but
## crossing_point() puts a crossing warden's feet on this x, so it is in the sim's state.
const GAP_ROPE_X: float = 0.0
## Gray box: how far under the deck top the rope is tied at each end of the gap, in metres.
const GAP_ROPE_DROP: float = 0.1
## Gray box: how far the rope sags at mid-gap below its ends, in metres (a parabola).
const GAP_ROPE_SAG: float = 0.4
## Gray box: the rope is drawn as this many straight pieces.
const GAP_ROPE_PIECES: int = 10

## Story 1.7, the plan look (the span seen from straight above by the planning screen). Each is a
## plan-view size, in metres so that it scales with the span; not a rule. Sonlm's look at the
## read-out (M1 of story 1.7, 2026-11-27) made the two widths heavier; each size is in this one
## place.
## Plan-view size; not a rule. A standing rail's line, across (0.12 until Sonlm's M1: too thin).
const PLAN_RAIL_WIDTH: float = 0.2
## Plan-view size; not a rule. A dashed line (a stripped rail, a fallen section's outline), across
## (0.05, the night rope's own thickness, until Sonlm's M1: too thin).
const PLAN_DASH_WIDTH: float = 0.1
## Plan-view size; not a rule. One dash, along its line.
const PLAN_DASH_LENGTH: float = 0.25
## Plan-view size; not a rule. From one dash's start to the next; each dash is centred in its step.
const PLAN_DASH_STEP: float = 0.5
## Plan-view size; not a rule. Story 1.7 decision D3: how far short of each end of its section a
## standing rail's line stops, so every joint between two sections shows as a break in both lines.
const PLAN_JOINT_INSET: float = 0.15

var _sections: int
var _places: int


## Reports `span.plank_order` once when the def's planks per section is not 8: the order
## cannot apply, and places_kept() falls back to the first `count` places. Only 8 is used.
func _init(def: NightDef, faults: WatchFaults) -> void:
	_sections = def.section_count
	_places = def.planks_per_section
	if _places != ORDER_PLACES:
		faults.report(&"span.plank_order", "%d planks per section; the leaving order is for %d"
				% [_places, ORDER_PLACES])


func length() -> float:
	return _sections * SpanConstants.SECTION_LENGTH


func world_z(along: float) -> float:
	return along - length()


func section_start(n: int) -> float:
	return (n - 1) * SpanConstants.SECTION_LENGTH


func section_end(n: int) -> float:
	return n * SpanConstants.SECTION_LENGTH


## The places (1 to 8, from the far-pier end) that hold a plank when the deck has `count`,
## ascending. The same for every section, wherever the warden stands (GD-54). A count outside
## 0 to the places is clamped.
func places_kept(count: int) -> Array[int]:
	var kept: Array[int] = []
	var n: int = clampi(count, 0, _places)
	if _places != ORDER_PLACES:
		for p: int in range(1, n + 1):
			kept.append(p)
		return kept
	var gone: Array[int] = PLANK_LEAVE_ORDER.slice(0, ORDER_PLACES - n)
	for p: int in range(1, ORDER_PLACES + 1):
		if not gone.has(p):
			kept.append(p)
	return kept


## The centre of each kept plank of `section` at `count`, in world coordinates, in the order of
## places_kept().
func plank_places(section: int, count: int) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for p: int in places_kept(count):
		out.append(plank_place(section, p))
	return out


## The centre of place `p` (1 to 8) of `section`.
func plank_place(section: int, p: int) -> Vector3:
	var along: float = section_start(section) + (p - 0.5) * SpanConstants.SECTION_LENGTH / _places
	return Vector3(0.0, -PLANK_THICKNESS / 2.0, world_z(along))


func plank_size() -> Vector3:
	return Vector3(SpanConstants.SECTION_WIDTH, PLANK_THICKNESS, PLANK_ALONG)


## The deck's whole surface, planked or not (for WardenRules and LookRules).
func deck_box(section: int) -> AABB:
	var half: float = SpanConstants.SECTION_WIDTH / 2.0
	return AABB(Vector3(-half, -PLANK_THICKNESS, world_z(section_start(section))),
			Vector3(SpanConstants.SECTION_WIDTH, PLANK_THICKNESS, SpanConstants.SECTION_LENGTH))


## The rail rope along one side edge, end to end of the section.
func rail_box(section: int, side: NightTypes.Side) -> AABB:
	var half: float = RAIL_THICKNESS / 2.0
	return AABB(Vector3(_edge_x(side) - half, RAIL_HEIGHT - half, world_z(section_start(section))),
			Vector3(RAIL_THICKNESS, RAIL_THICKNESS, SpanConstants.SECTION_LENGTH))


## Story 1.4 decision D1: what LookRules hits for a rail. Centred on rail_box() (the drawn rope
## stays where it is), the rope's full length, RAIL_GRAB_SIZE across and tall.
func rail_grab_box(section: int, side: NightTypes.Side) -> AABB:
	var rope: AABB = rail_box(section, side)
	var grow: float = (RAIL_GRAB_SIZE - RAIL_THICKNESS) / 2.0
	return AABB(rope.position - Vector3(grow, grow, 0.0),
			Vector3(RAIL_GRAB_SIZE, RAIL_GRAB_SIZE, rope.size.z))


## The two posts of a rail, one inside each end of the section.
func rail_posts(section: int, side: NightTypes.Side) -> Array[AABB]:
	var size: Vector3 = Vector3(POST_SIZE, POST_HEIGHT, POST_SIZE)
	var x: float = _edge_x(side) - POST_SIZE / 2.0
	return [
		AABB(Vector3(x, 0.0, world_z(section_start(section))), size),
		AABB(Vector3(x, 0.0, world_z(section_end(section)) - POST_SIZE), size),
	]


## The beam under the plank ends on one side; it stays whether or not planks remain.
func side_beam_box(section: int, side: NightTypes.Side) -> AABB:
	var x: float = _edge_x(side) if side == NightTypes.Side.LEFT else _edge_x(side) - BEAM_WIDTH
	return AABB(Vector3(x, -PLANK_THICKNESS - BEAM_DEPTH, world_z(section_start(section))),
			Vector3(BEAM_WIDTH, BEAM_DEPTH, SpanConstants.SECTION_LENGTH))


func far_pier_box() -> AABB:
	return AABB(Vector3(-PIER_WIDTH / 2.0, -PIER_DEPTH, world_z(-PIER_LENGTH)),
			Vector3(PIER_WIDTH, PIER_DEPTH + FAR_PIER_RISE, PIER_LENGTH))


func town_pier_box() -> AABB:
	return AABB(Vector3(-PIER_WIDTH / 2.0, -PIER_DEPTH, world_z(length())),
			Vector3(PIER_WIDTH, PIER_DEPTH, PIER_LENGTH))


## The landing: the town pier's walkable top, a surface at deck level (no height).
func landing_box() -> AABB:
	return AABB(Vector3(-LANDING_WIDTH / 2.0, 0.0, world_z(length())),
			Vector3(LANDING_WIDTH, 0.0, LANDING_LENGTH))


## Where the warden's feet start: the landing's centre, facing the far pier.
func warden_start() -> Vector3:
	return Vector3(0.0, 0.0, world_z(length() + LANDING_LENGTH / 2.0))


## Story 1.5: test weight `i` (from 0) on `section`: a cube standing on the deck top, in a fixed
## grid (WEIGHT_ACROSS by WEIGHT_ALONG), stacking up a layer when one is full, so any count is
## drawn. Not a shape for LookRules or WardenRules: the warden walks through weights.
func weight_box(section: int, i: int) -> AABB:
	var per_layer: int = WEIGHT_ACROSS.size() * WEIGHT_ALONG.size()
	var in_layer: int = i % per_layer
	var x: float = WEIGHT_ACROSS[in_layer % WEIGHT_ACROSS.size()]
	var along: float = section_start(section) + WEIGHT_ALONG[in_layer / WEIGHT_ACROSS.size()]
	var half: float = WEIGHT_SIZE / 2.0
	return AABB(Vector3(x - half, (i / per_layer) * WEIGHT_SIZE, world_z(along) - half),
			Vector3(WEIGHT_SIZE, WEIGHT_SIZE, WEIGHT_SIZE))


## Story 1.5 decision D3: the along of the edge a falling warden catches and climbs onto: the
## far-pier end of section `onto`, or the landing's edge for `onto` 0.
func climb_edge(onto: int) -> float:
	return length() if onto == 0 else section_start(onto)


## D3: where the feet hang while climbing onto `onto` (0: the landing), from the warden's `x`:
## at its edge, x kept CLEARANCE inside its sides, WardenConstants.HANG_DROP below its deck top.
func hang_point(onto: int, x: float) -> Vector3:
	return Vector3(_climb_x(onto, x), -WardenConstants.HANG_DROP, world_z(climb_edge(onto)))


## D3: where the feet are once the climb ends: on `onto`'s deck, CLEARANCE in from its edge.
func climb_end(onto: int, x: float) -> Vector3:
	return Vector3(_climb_x(onto, x), 0.0, world_z(climb_edge(onto) + WardenConstants.CLEARANCE))


## `x` kept CLEARANCE inside the sides of section `onto`, or of the landing for 0.
func _climb_x(onto: int, x: float) -> float:
	var half: float = (LANDING_WIDTH if onto == 0 else SpanConstants.SECTION_WIDTH) / 2.0 - WardenConstants.CLEARANCE
	return clampf(x, -half, half)


## Story 1.6 decision D2: the x of the line an edging warden's feet sidestep onto, along the side
## beam of `side`: the edge of the band that can be stood on (the deck's half width less
## WardenConstants.CLEARANCE), so the feet never leave that band.
func beam_line_x(side: NightTypes.Side) -> float:
	var x: float = SpanConstants.SECTION_WIDTH / 2.0 - WardenConstants.CLEARANCE
	return -x if side == NightTypes.Side.LEFT else x


## Story 1.6: the along where a move over `section` heading `toward` (+1 toward the town, -1 toward
## the far pier) begins: the section's end on the side it is entered from.
func near_edge(section: int, toward: int) -> float:
	return section_start(section) if toward > 0 else section_end(section)


## Story 1.6: the along where a move over `section` heading `toward` ends: its other end.
func far_edge(section: int, toward: int) -> float:
	return section_end(section) if toward > 0 else section_start(section)


## Story 1.6 D2: a point of an edging on the line of the `side` beam, at deck height.
func edging_point(side: NightTypes.Side, along: float) -> Vector3:
	return Vector3(beam_line_x(side), 0.0, world_z(along))


## Story 1.6: a point of a crossing at `along`: hanging under the gap's rope (Sonlm's play of M1,
## 2026-11-22), on its line (GAP_ROPE_X), WardenConstants.CROSS_HANG_DROP below the deck top.
func crossing_point(along: float) -> Vector3:
	return Vector3(GAP_ROPE_X, -WardenConstants.CROSS_HANG_DROP, world_z(along))


## Sonlm's play of M1 of story 1.6: the rope left across fallen section `section`, as
## GAP_ROPE_PIECES + 1 points from its far-pier end to its town end: tied GAP_ROPE_DROP under the deck
## top at each end, sagging GAP_ROPE_SAG at mid-gap. Gray box: drawn by SectionView; no rule reads
## these points (a crossing's line is crossing_point(): the rope's x, CROSS_HANG_DROP down).
func gap_rope_points(section: int) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for i: int in GAP_ROPE_PIECES + 1:
		var u: float = float(i) / GAP_ROPE_PIECES
		var along: float = section_start(section) + u * SpanConstants.SECTION_LENGTH
		out.append(Vector3(GAP_ROPE_X, -GAP_ROPE_DROP - GAP_ROPE_SAG * 4.0 * u * (1.0 - u), world_z(along)))
	return out


## Story 1.6: where the feet step onto the next floor when a move over `section` heading `toward`
## ends: WardenConstants.CLEARANCE past its far edge, `x` kept within that floor's band. Toward the
## town it is exactly climb_end() of the next section (or the landing past the town section).
func move_end(section: int, toward: int, x: float) -> Vector3:
	if toward > 0:
		return climb_end(section + 1 if section < _sections else 0, x)
	return Vector3(_climb_x(section - 1, x), 0.0, world_z(section_start(section) - WardenConstants.CLEARANCE))


## Story 1.7, plan look: the black under a standing section's planks, so a missing plank reads as
## the abyss on the planning ground: the deck's footprint, lying wholly under the planks (its top
## at their underside). Heights in the plan look only decide what covers what from above.
func plan_backing_box(section: int) -> AABB:
	var deck: AABB = deck_box(section)
	return AABB(Vector3(deck.position.x, deck.position.y - PLANK_THICKNESS, deck.position.z),
			Vector3(deck.size.x, PLANK_THICKNESS, deck.size.z))


## Story 1.7, plan look: a standing rail's line. PLAN_RAIL_WIDTH across, its inner edge on the
## deck's edge and the rest outside it, on the ground (a line over the plank ends cannot be told
## from them); along, PLAN_JOINT_INSET short of each end of the section (D3); at the rope's height,
## so it lies over everything else seen from above.
func plan_rail_box(section: int, side: NightTypes.Side) -> AABB:
	var along: float = section_start(section) + PLAN_JOINT_INSET
	return AABB(Vector3(_outside_x(side, PLAN_RAIL_WIDTH), RAIL_HEIGHT - RAIL_THICKNESS / 2.0, world_z(along)),
			Vector3(PLAN_RAIL_WIDTH, RAIL_THICKNESS, SpanConstants.SECTION_LENGTH - 2.0 * PLAN_JOINT_INSET))


## Story 1.7, plan look: a stripped rail's line, as dashes from the section's far-pier end to its
## town end: PLAN_DASH_WIDTH across, the inner edge on the deck's edge, where the standing line
## was; at the rope's height. "Missing things are drawn dashed" (DESIGN.md, Shapes).
func plan_rail_dashes(section: int, side: NightTypes.Side) -> Array[AABB]:
	var out: Array[AABB] = []
	var x: float = _outside_x(side, PLAN_DASH_WIDTH)
	for along: float in _dash_starts(section_start(section), SpanConstants.SECTION_LENGTH):
		out.append(AABB(Vector3(x, RAIL_HEIGHT - RAIL_THICKNESS / 2.0, world_z(along)),
				Vector3(PLAN_DASH_WIDTH, RAIL_THICKNESS, PLAN_DASH_LENGTH)))
	return out


## Story 1.7, plan look: a fallen section's outline (decision D2: it is all that is drawn of it):
## the four edges of the deck's footprint, each dashed, the line PLAN_DASH_WIDTH across and centred
## on the edge, its top at the deck's top. In order: the right (+X) edge, the left edge, the
## far-pier end, the town end.
func plan_outline_dashes(section: int) -> Array[AABB]:
	var out: Array[AABB] = []
	var half: float = PLAN_DASH_WIDTH / 2.0
	for side: NightTypes.Side in [NightTypes.Side.RIGHT, NightTypes.Side.LEFT]:
		for along: float in _dash_starts(section_start(section), SpanConstants.SECTION_LENGTH):
			out.append(AABB(Vector3(_edge_x(side) - half, -PLAN_DASH_WIDTH, world_z(along)),
					Vector3(PLAN_DASH_WIDTH, PLAN_DASH_WIDTH, PLAN_DASH_LENGTH)))
	for end: float in [section_start(section), section_end(section)]:
		for x: float in _dash_starts(_edge_x(NightTypes.Side.LEFT), SpanConstants.SECTION_WIDTH):
			out.append(AABB(Vector3(x, -PLAN_DASH_WIDTH, world_z(end) - half),
					Vector3(PLAN_DASH_LENGTH, PLAN_DASH_WIDTH, PLAN_DASH_WIDTH)))
	return out


## Where each dash of a dashed line `length` long starts, measured from `from`: one dash per
## PLAN_DASH_STEP, centred in its step, so the line begins and ends with half a gap.
func _dash_starts(from: float, length: float) -> Array[float]:
	var out: Array[float] = []
	var lead: float = (PLAN_DASH_STEP - PLAN_DASH_LENGTH) / 2.0
	for i: int in roundi(length / PLAN_DASH_STEP):
		out.append(from + lead + i * PLAN_DASH_STEP)
	return out


## The low x of a line `width` across that lies just outside the deck on `side`, touching its edge.
func _outside_x(side: NightTypes.Side, width: float) -> float:
	return _edge_x(side) - width if side == NightTypes.Side.LEFT else _edge_x(side)


## The x of a section's side edge.
func _edge_x(side: NightTypes.Side) -> float:
	var half: float = SpanConstants.SECTION_WIDTH / 2.0
	return -half if side == NightTypes.Side.LEFT else half
