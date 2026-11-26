## Draws the span (AD-23: one span view for the night, planning and dawn; AD-49, AD-62), every
## shape placed by asking SpanGeometry, in one of two looks chosen before the first show:
## - the night look (the default): gray boxes under the night's light: the piers, the landing and
##   one SectionView per section. Gray boxes until gate 2 (epic 7); no shader, no texture.
## - the plan look (story 1.7, use_plan_look()): the same sections for a camera looking straight
##   down: flat unshaded colours handed in by the planning screen, no pier and no landing.
##
## Two ways in. The night screen registers on_tick() as a consumer: on the first tick it builds
## what never changes; every tick it hands SECTION_FELL to its section (story 1.5: the pieces
## drop) before each section reconciles with state (AD-49: events first). A screen with no night
## running (planning; in epic 5 the plan's result and the dawn) calls show_span() with a span.
class_name SpanView
extends Node3D

## Gray box until epic 7. Planks: light, so a gap reads against the black.
const PLANK_COLOR: Color = Color(0.72, 0.72, 0.70)
## Gray box until epic 7. Side beams and posts: darker than the planks.
const BEAM_COLOR: Color = Color(0.36, 0.36, 0.35)
## Gray box until epic 7. Rail ropes: lighter than everything else.
const RAIL_COLOR: Color = Color(0.88, 0.88, 0.86)
## Gray box until epic 7. Test weights (story 1.5): dark, so they read on the light planks.
const WEIGHT_COLOR: Color = Color(0.22, 0.22, 0.24)
## Gray box until epic 7. Both piers. Dark (0.5 until M2 of story 1.3, DW-31): seen from
## mid-span, every gap more than about 10 m ahead looks down onto the far pier's face, which must
## read near-black like the abyss for a sparse section to read as open. Chosen by Sonlm (variant B).
const PIER_COLOR: Color = Color(0.12, 0.12, 0.12)
## Gray box until epic 7. The landing, a shade off the pier it tops.
const LANDING_COLOR: Color = Color(0.6, 0.6, 0.58)
## Gray box until epic 7. The landing is a surface; it is drawn as a slab this thick on the
## pier's top so it can be seen. Drawing only: SpanGeometry's landing has no height.
const LANDING_MARK_THICKNESS: float = 0.01

## How the span is drawn. It decides what is built, so it is chosen before the first show.
enum Look {
	NIGHT,  ## Gray boxes under the night's light, seen by the warden.
	PLAN,   ## Flat unshaded shapes seen from straight above (the planning screen).
}

var _look: Look = Look.NIGHT
## The plan look's colours, by the names SectionView asks for (use_plan_look()).
var _plan_colors: Dictionary[StringName, Color] = {}
var _sections: Array[SectionView] = []
var _built: bool = false


## Chooses the plan look, with the colours of its four kinds of shape: planks, standing rails,
## dashed lines (a stripped rail, a fallen section's outline) and the black under a standing
## section's planks. The screen hands them in, so this folder names no screen script. Called before
## the first show; later it is a setup problem and the look stays as it is.
func use_plan_look(plank: Color, rail: Color, dash: Color, abyss: Color) -> void:
	if _built:
		push_warning("span_view.late_look: the plan look was asked for after the span was first shown; the look is kept")
		return
	_look = Look.PLAN
	_plan_colors = {&"plank": plank, &"rail": rail, &"dash": dash, &"abyss": abyss}


## A consumer of the night screen: build once, then the tick's events, then state (AD-49).
func on_tick(events: Array[NightEvent], sim: NightSim) -> void:
	if not _built:
		_build(sim.geometry, sim.span.section_count())
	for event: NightEvent in events:
		if event.kind == NightEvent.Kind.SECTION_FELL and event.section >= 1 and event.section <= _sections.size():
			_sections[event.section - 1].fall(events)
	show_span(sim.geometry, sim.span, sim.ticks.groan)


## Makes every section match `span`, building on the first call. The way in for a screen with no
## night running. `groan_ticks` is how long a groan lasts in ticks (NightTicks.groan), for the
## night look's bow; the plan look does not read it.
func show_span(geometry: SpanGeometry, span: SpanState, groan_ticks: int) -> void:
	if not _built:
		_build(geometry, span.section_count())
	for i: int in _sections.size():
		_sections[i].show_state(span, i + 1, groan_ticks)


func _build(geometry: SpanGeometry, section_count: int) -> void:
	_built = true
	var materials: Dictionary[StringName, StandardMaterial3D] = {}
	if _look == Look.PLAN:
		# Story 1.7 decision D4: no pier and no landing in the plan look; the two ends are words.
		for kind: StringName in _plan_colors:
			materials[kind] = _material(_plan_colors[kind], true)
	else:
		materials = {
			&"plank": _material(PLANK_COLOR), &"beam": _material(BEAM_COLOR), &"rail": _material(RAIL_COLOR),
			&"weight": _material(WEIGHT_COLOR),
		}
		var pier: StandardMaterial3D = _material(PIER_COLOR)
		add_child(box("FarPier", geometry.far_pier_box(), pier))
		add_child(box("TownPier", geometry.town_pier_box(), pier))
		var landing: AABB = geometry.landing_box()
		landing.size.y = LANDING_MARK_THICKNESS
		add_child(box("Landing", landing, _material(LANDING_COLOR)))
	for n: int in range(1, section_count + 1):
		var section: SectionView = SectionView.new(geometry, n, materials, _look)
		section.name = "Section%d" % n
		add_child(section)
		_sections.append(section)


## A box filling `aabb`, named `node_name`.
static func box(node_name: String, aabb: AABB, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = aabb.size
	mesh.material = material
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = aabb.get_center()
	return node


## A plain colour. `flat` (the plan look): unshaded, so it is drawn exactly as given with no light.
static func _material(color: Color, flat: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	if flat:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
