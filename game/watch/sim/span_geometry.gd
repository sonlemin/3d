## The only source of positions and shapes on the span (AD-42, AD-62). Pure: built from a
## NightDef and holding nothing but its numbers. Views, and later the warden's and look rules,
## ask here; no coordinate of the span is typed anywhere else.
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
## Gray-box size, D2; not a rule. The warden's eye above the feet.
const EYE_HEIGHT: float = 1.6

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


## The deck's whole surface, planked or not (for LookRules in stories 1.3 and 1.4).
func deck_box(section: int) -> AABB:
	var half: float = SpanConstants.SECTION_WIDTH / 2.0
	return AABB(Vector3(-half, -PLANK_THICKNESS, world_z(section_start(section))),
			Vector3(SpanConstants.SECTION_WIDTH, PLANK_THICKNESS, SpanConstants.SECTION_LENGTH))


## The rail rope along one side edge, end to end of the section.
func rail_box(section: int, side: NightTypes.Side) -> AABB:
	var half: float = RAIL_THICKNESS / 2.0
	return AABB(Vector3(_edge_x(side) - half, RAIL_HEIGHT - half, world_z(section_start(section))),
			Vector3(RAIL_THICKNESS, RAIL_THICKNESS, SpanConstants.SECTION_LENGTH))


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


## The x of a section's side edge.
func _edge_x(side: NightTypes.Side) -> float:
	var half: float = SpanConstants.SECTION_WIDTH / 2.0
	return -half if side == NightTypes.Side.LEFT else half
