## One section of the span, drawn to its count (AD-49): side beams and posts always, one plank
## per kept place and one rope per standing rail. Each tick it reconciles with state: it makes
## what is missing and frees what is gone. It never counts events, so a missed event cannot
## leave a ghost plank. Every box is placed by SpanGeometry.
class_name SectionView
extends Node3D

var _geometry: SpanGeometry
var _materials: Dictionary[StringName, StandardMaterial3D]
## Place (1 to 8) -> its plank.
var _planks: Dictionary[int, MeshInstance3D] = {}
## NightTypes.Side -> its rope.
var _rails: Dictionary[NightTypes.Side, MeshInstance3D] = {}


func _init(geometry: SpanGeometry, section: int, materials: Dictionary[StringName, StandardMaterial3D]) -> void:
	_geometry = geometry
	_materials = materials
	for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
		var tag: String = _tag(side)
		add_child(SpanView.box("Beam" + tag, geometry.side_beam_box(section, side), materials[&"beam"]))
		var posts: Array[AABB] = geometry.rail_posts(section, side)
		for i: int in posts.size():
			add_child(SpanView.box("Post%s%d" % [tag, i + 1], posts[i], materials[&"beam"]))


## Makes the planks and rails match `sim`'s state for section `n`.
func show_state(sim: NightSim, n: int) -> void:
	var kept: Array[int] = _geometry.places_kept(sim.span.planks(n))
	for place: int in _planks.keys():
		if not kept.has(place):
			_drop(_planks[place])
			_planks.erase(place)
	var size: Vector3 = _geometry.plank_size()
	for place: int in kept:
		if not _planks.has(place):
			var center: Vector3 = _geometry.plank_place(n, place)
			var plank: MeshInstance3D = SpanView.box("Plank%d" % place, AABB(center - size / 2.0, size), _materials[&"plank"])
			add_child(plank)
			_planks[place] = plank
	for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
		var standing: bool = sim.span.rail_standing(n, side)
		if standing and not _rails.has(side):
			var rail: MeshInstance3D = SpanView.box("Rail" + _tag(side), _geometry.rail_box(n, side), _materials[&"rail"])
			add_child(rail)
			_rails[side] = rail
		elif not standing and _rails.has(side):
			_drop(_rails[side])
			_rails.erase(side)


## Takes `node` out at once (so its name is free for a part laid back) and frees it at frame end.
func _drop(node: Node) -> void:
	remove_child(node)
	node.queue_free()


static func _tag(side: NightTypes.Side) -> String:
	return "L" if side == NightTypes.Side.LEFT else "R"
