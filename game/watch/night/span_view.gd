## Draws the span as gray boxes (AD-49, AD-62): the piers, the landing and one SectionView per
## section, every one placed by asking SpanGeometry. A consumer of the night screen: on the
## first tick it builds what never changes, and every tick each section reconciles with state.
## Gray boxes until gate 2 (epic 7); no shader, no texture.
class_name SpanView
extends Node3D

## Gray box until epic 7. Planks: light, so a gap reads against the black.
const PLANK_COLOR: Color = Color(0.72, 0.72, 0.70)
## Gray box until epic 7. Side beams and posts: darker than the planks.
const BEAM_COLOR: Color = Color(0.36, 0.36, 0.35)
## Gray box until epic 7. Rail ropes: lighter than everything else.
const RAIL_COLOR: Color = Color(0.88, 0.88, 0.86)
## Gray box until epic 7. Both piers.
const PIER_COLOR: Color = Color(0.5, 0.5, 0.5)
## Gray box until epic 7. The landing, a shade off the pier it tops.
const LANDING_COLOR: Color = Color(0.6, 0.6, 0.58)
## Gray box until epic 7. The landing is a surface; it is drawn as a slab this thick on the
## pier's top so it can be seen. Drawing only: SpanGeometry's landing has no height.
const LANDING_MARK_THICKNESS: float = 0.01

var _sections: Array[SectionView] = []
var _built: bool = false


func on_tick(_events: Array[NightEvent], sim: NightSim) -> void:
	if not _built:
		_build(sim.geometry, sim.def.section_count)
	for i: int in _sections.size():
		_sections[i].show_state(sim, i + 1)


func _build(geometry: SpanGeometry, section_count: int) -> void:
	_built = true
	var materials: Dictionary[StringName, StandardMaterial3D] = {
		&"plank": _material(PLANK_COLOR), &"beam": _material(BEAM_COLOR), &"rail": _material(RAIL_COLOR),
	}
	var pier: StandardMaterial3D = _material(PIER_COLOR)
	add_child(box("FarPier", geometry.far_pier_box(), pier))
	add_child(box("TownPier", geometry.town_pier_box(), pier))
	var landing: AABB = geometry.landing_box()
	landing.size.y = LANDING_MARK_THICKNESS
	add_child(box("Landing", landing, _material(LANDING_COLOR)))
	for n: int in range(1, section_count + 1):
		var section: SectionView = SectionView.new(geometry, n, materials)
		section.name = "Section%d" % n
		add_child(section)
		_sections.append(section)


## A gray box filling `aabb`, named `node_name`.
static func box(node_name: String, aabb: AABB, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = aabb.size
	mesh.material = material
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = aabb.get_center()
	return node


static func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	return material
