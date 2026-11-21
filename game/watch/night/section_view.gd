## One section of the span, drawn to its count (AD-49): side beams and posts always, one plank
## per kept place, one rope per standing rail and, since story 1.5, one box per test weight. Each
## tick it reconciles with state: it makes what is missing and frees what is gone. It never counts
## events, so a missed event cannot leave a ghost plank. Every box is placed by SpanGeometry.
##
## Story 1.5 decision D4 (gray box; no sound until epic 2): a creaking deck bows a little, a
## groaning one bows deeper as its groan runs out (read from state each tick, not a timer), and on
## SECTION_FELL every piece of the section drops out of sight over FALL_S and is freed. A fallen
## section draws nothing, so the gap reads black. No shake, no flash, nothing flickers.
class_name SectionView
extends Node3D

## D4, gray box, not a rule: how deep a creaking deck bows at mid-section, in metres.
const CREAK_BOW: float = 0.05
## D4, gray box, not a rule: how deep a groaning deck has bowed when its groan runs out.
const GROAN_BOW: float = 0.25
## D4, view only, not a rule: how long the falling pieces drop before they are freed, in seconds.
const FALL_S: float = 1.5
## View only: the falling pieces' acceleration, metres per second squared (a plain drop).
const FALL_GRAVITY: float = 9.8

var _geometry: SpanGeometry
var _materials: Dictionary[StringName, StandardMaterial3D]
var _section: int = 0
## Place (1 to 8) -> its plank.
var _planks: Dictionary[int, MeshInstance3D] = {}
## NightTypes.Side -> its rope.
var _rails: Dictionary[NightTypes.Side, MeshInstance3D] = {}
## The weight boxes, in SpanGeometry.weight_box() order.
var _weights: Array[MeshInstance3D] = []
## The beams and posts, made once.
var _frame: Array[MeshInstance3D] = []
## True once the section has fallen and nothing of it is drawn any more.
var _gone: bool = false
## The pieces dropping after SECTION_FELL, and for how long they have dropped (view time).
var _falling: Node3D = null
var _fall_time: float = 0.0


func _init(geometry: SpanGeometry, section: int, materials: Dictionary[StringName, StandardMaterial3D]) -> void:
	_geometry = geometry
	_materials = materials
	_section = section
	for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
		var tag: String = _tag(side)
		_frame.append(SpanView.box("Beam" + tag, geometry.side_beam_box(section, side), materials[&"beam"]))
		var posts: Array[AABB] = geometry.rail_posts(section, side)
		for i: int in posts.size():
			_frame.append(SpanView.box("Post%s%d" % [tag, i + 1], posts[i], materials[&"beam"]))
	for node: MeshInstance3D in _frame:
		add_child(node)


## A section in the tree is idle: _process() runs only while its pieces drop (fall() to the end of
## fall_step()). Godot turns processing on for a node with a _process() as it becomes ready, so it
## is turned off here, not in _init().
func _ready() -> void:
	set_process(false)


## Makes the planks, rails and weights match `sim`'s state for section `n`, the planks bowed by its
## creak or groan. A fallen section shows nothing (what fall() took is dropping on its own).
func show_state(sim: NightSim, n: int) -> void:
	if sim.span.fallen(n):
		_clear()
		return
	_show_planks(sim.span.planks(n))
	for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
		_show_rail(side, sim.span.rail_standing(n, side))
	_show_weights(sim.span.weights(n))
	_bow(bow_depth(sim.span.creaking(n), sim.span.groan_left(n), sim.ticks.groan))


## D4: SECTION_FELL, with the events of the tick it fell on. Every piece the section has (planks,
## rails, beams, posts, weights) moves into one group that drops out of sight over FALL_S
## (fall_step()), then is freed. The view handles this before it reconciles (AD-49), so the pieces
## are still the last tick's: what left the section earlier in this tick (a plank or rail stripped
## in step 2, a weight lifted in step 6) is taken out first, and a plank re-laid is put in. Only
## this section's events before its own SECTION_FELL count.
func fall(events: Array[NightEvent]) -> void:
	if _falling != null or _gone:
		return
	var planks: int = _planks.size()
	var weights: int = _weights.size()
	for event: NightEvent in events:
		if event.section != _section:
			continue
		if event.kind == NightEvent.Kind.SECTION_FELL:
			break
		if event.kind == NightEvent.Kind.PLANK_STRIPPED:
			planks -= 1
		elif event.kind == NightEvent.Kind.PLANK_RELAID:
			planks += 1
		elif event.kind == NightEvent.Kind.RAIL_STRIPPED:
			_show_rail(event.side, false)
		elif event.kind == NightEvent.Kind.WEIGHT_LIFTED:
			weights -= 1
	_show_planks(planks)
	_show_weights(weights)
	_falling = Node3D.new()
	_falling.name = "Falling"
	for node: Node in get_children():
		remove_child(node)
		_falling.add_child(node)
	add_child(_falling)
	_fall_time = 0.0
	_forget()
	_gone = true
	set_process(true)


## One plank node for each place a deck of `count` planks keeps (SpanGeometry.places_kept()).
func _show_planks(count: int) -> void:
	var kept: Array[int] = _geometry.places_kept(count)
	for place: int in _planks.keys():
		if not kept.has(place):
			_drop(_planks[place])
			_planks.erase(place)
	var size: Vector3 = _geometry.plank_size()
	for place: int in kept:
		if not _planks.has(place):
			var center: Vector3 = _geometry.plank_place(_section, place)
			var plank: MeshInstance3D = SpanView.box("Plank%d" % place, AABB(center - size / 2.0, size), _materials[&"plank"])
			add_child(plank)
			_planks[place] = plank


func _show_rail(side: NightTypes.Side, standing: bool) -> void:
	if standing and not _rails.has(side):
		var rail: MeshInstance3D = SpanView.box("Rail" + _tag(side), _geometry.rail_box(_section, side), _materials[&"rail"])
		add_child(rail)
		_rails[side] = rail
	elif not standing and _rails.has(side):
		_drop(_rails[side])
		_rails.erase(side)


func _show_weights(count: int) -> void:
	while _weights.size() > maxi(count, 0):
		_drop(_weights.pop_back())
	while _weights.size() < count:
		var weight: MeshInstance3D = SpanView.box("Weight%d" % (_weights.size() + 1),
				_geometry.weight_box(_section, _weights.size()), _materials[&"weight"])
		add_child(weight)
		_weights.append(weight)


## Moves the falling group on by `delta` seconds of view time; frees it once FALL_S has passed.
## _process() calls it; a test drives it headless.
func fall_step(delta: float) -> void:
	if _falling == null:
		return
	_fall_time += delta
	if _fall_time >= FALL_S:
		_drop(_falling)
		_falling = null
		set_process(false)
		return
	_falling.position.y = -0.5 * FALL_GRAVITY * _fall_time * _fall_time


## The group still dropping, or null.
func falling() -> Node3D:
	return _falling


func _process(delta: float) -> void:
	fall_step(delta)


## Pure, D4: the deck's deepest bow, in metres: 0 when neither creaking nor groaning; CREAK_BOW
## creaking; groaning, from CREAK_BOW at the groan's start growing in a straight line to GROAN_BOW
## as `groan_left` runs from `groan_ticks` down to 0.
static func bow_depth(creaking: bool, groan_left: int, groan_ticks: int) -> float:
	if groan_left > 0 and groan_ticks > 0:
		var gone: float = 1.0 - float(groan_left) / groan_ticks
		return lerpf(CREAK_BOW, GROAN_BOW, clampf(gone, 0.0, 1.0))
	return CREAK_BOW if creaking else 0.0


## Pure, D4: how far a point `u` of the way along the section (0 at the far-pier end, 1 at the
## town end) sags at bow `depth`: depth x 4u(1 - u), deepest at mid-section, 0 at the ends.
static func plank_sag(depth: float, u: float) -> float:
	return depth * 4.0 * u * (1.0 - u)


## Sets every kept plank, and every weight on the deck's first layer and up, down by its sag. The
## weights ride the bowed deck (story 1.5 D4: they sit on it).
func _bow(depth: float) -> void:
	for place: int in _planks:
		var base: Vector3 = _geometry.plank_place(_section, place)
		_planks[place].position = Vector3(base.x, base.y - plank_sag(depth, _along(base)), base.z)
	for i: int in _weights.size():
		var base: Vector3 = _geometry.weight_box(_section, i).get_center()
		_weights[i].position = Vector3(base.x, base.y - plank_sag(depth, _along(base)), base.z)


## How far along the section a point is, 0 at its far-pier end to 1 at its town end, asked of the
## geometry, so the bow needs no count of plank places.
func _along(point: Vector3) -> float:
	return (point.z - _geometry.world_z(_geometry.section_start(_section))) / SpanConstants.SECTION_LENGTH


## A fallen section whose fall was not seen (no SECTION_FELL handled): everything goes at once.
func _clear() -> void:
	if _gone:
		return
	for node: Node in get_children():
		if node != _falling:
			_drop(node)
	_forget()
	_gone = true


func _forget() -> void:
	_planks.clear()
	_rails.clear()
	_weights.clear()
	_frame.clear()


## Takes `node` out at once (so its name is free for a part laid back) and frees it at frame end.
func _drop(node: Node) -> void:
	remove_child(node)
	node.queue_free()


static func _tag(side: NightTypes.Side) -> String:
	return "L" if side == NightTypes.Side.LEFT else "R"
