## The warden's forearm (UX-11, story 1.4 decision D2): raised with Tab, it shows the planks and
## the ropes in hand as ink tally strokes in fives. A consumer of the night (`on_tick(events,
## sim)`) that reconciles with state every tick (AD-49): shown while `sim.hands.forearm_raised`,
## hidden otherwise; its strokes rebuilt only when the counts in hand change. It decides nothing.
##
## A child of the warden's Camera3D, so it turns with the view at once and needs no TickBlend.
## Gray box (epic 7 draws the real arm): a flat light "skin" below the centre of the view, tilted
## toward the eye, with dark ink on it (DESIGN.md: ink on skin, never a panel). Two rows, each led
## by its sign: planks above behind a filled bar, ropes below behind a ring. A group of five is four
## upright strokes and one across them; a row wraps after 5 groups. Unshaded (seen with no lantern
## lit, EXPERIENCE.md) and drawn over the world, never cut by a rail or a post. The epic 4 hands
## join this file. Every size here is a gray-box size, not a rule.
class_name HandsView
extends Node3D

## Where the forearm sits in the camera's space: below centre, 0.35 m in front of the eye.
const PLACE: Vector3 = Vector3(0.0, -0.13, -0.35)
## Tilted toward the eye, in radians (the top leans away, as a raised forearm does).
const TILT: float = -0.35
const SKIN_SIZE: Vector2 = Vector2(0.27, 0.12)
const SKIN_THICKNESS: float = 0.004
const SKIN_COLOR: Color = Color(0.86, 0.80, 0.70)
const INK_COLOR: Color = Color(0.08, 0.07, 0.06)
## One stroke: thin and short enough that 25 fit a row.
const STROKE_WIDTH: float = 0.003
const STROKE_LENGTH: float = 0.022
## Between the upright strokes of a group.
const STROKE_GAP: float = 0.008
## Between two groups of five.
const GROUP_GAP: float = 0.014
## How far the stroke across a group leans from upright, in radians.
const ACROSS_ANGLE: float = 1.05
const ROW_HEIGHT: float = 0.034
const GROUPS_PER_ROW: int = 5
## Room for the sign at the start of a row, and the sign's size.
const SIGN_ROOM: float = 0.03
const SIGN_SIZE: float = 0.014
## Ink sits this far in front of the skin.
const INK_LIFT: float = 0.003
## Drawn after the world (transparent pass) and the ink after the skin.
const SKIN_PRIORITY: int = 10
const INK_PRIORITY: int = 11


## One stroke of a tally: its row (0 first), its x from the row's start in metres, and whether it
## is the stroke across a group.
class Stroke:
	extends RefCounted
	var row: int = 0
	var x: float = 0.0
	var across: bool = false


var _planks_shown: int = -1
var _ropes_shown: int = -1
var _plank_strokes: Node3D
var _rope_strokes: Node3D
var _skin_material: StandardMaterial3D
var _ink_material: StandardMaterial3D


func _init() -> void:
	position = PLACE
	rotation = Vector3(TILT, 0.0, 0.0)
	visible = false
	_skin_material = _material(SKIN_COLOR, SKIN_PRIORITY)
	_ink_material = _material(INK_COLOR, INK_PRIORITY)
	var skin: MeshInstance3D = _box("Skin", Vector3(SKIN_SIZE.x, SKIN_SIZE.y, SKIN_THICKNESS), _skin_material)
	add_child(skin)
	_plank_strokes = Node3D.new()
	_plank_strokes.name = "PlankStrokes"
	add_child(_plank_strokes)
	_rope_strokes = Node3D.new()
	_rope_strokes.name = "RopeStrokes"
	add_child(_rope_strokes)
	var plank_sign: MeshInstance3D = _box("PlankSign", Vector3(SIGN_SIZE, SIGN_SIZE * 0.5, STROKE_WIDTH), _ink_material)
	add_child(plank_sign)
	var ring: TorusMesh = TorusMesh.new()
	ring.outer_radius = SIGN_SIZE * 0.5
	ring.inner_radius = SIGN_SIZE * 0.5 - STROKE_WIDTH
	ring.material = _ink_material
	var rope_sign: MeshInstance3D = MeshInstance3D.new()
	rope_sign.name = "RopeSign"
	rope_sign.mesh = ring
	rope_sign.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	rope_sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rope_sign)


## A consumer of the night: shows or hides the forearm, and redraws the tallies when the counts
## in hand changed.
func on_tick(_events: Array[NightEvent], sim: NightSim) -> void:
	visible = sim.hands.forearm_raised
	var planks: int = sim.span.in_hand(NightTypes.Part.PLANK)
	var ropes: int = sim.span.in_hand(NightTypes.Part.ROPE)
	if planks == _planks_shown and ropes == _ropes_shown:
		return
	_planks_shown = planks
	_ropes_shown = ropes
	var plank_rows: int = rows_for(planks)
	_place_row(_plank_strokes, get_node("PlankSign") as Node3D, 0, strokes(planks))
	_place_row(_rope_strokes, get_node("RopeSign") as Node3D, plank_rows, strokes(ropes))


## Pure: the layout of `count` tally strokes, in order: groups of five (four upright, then one
## across them), GROUPS_PER_ROW groups to a row. Empty for 0 or less.
static func strokes(count: int) -> Array[Stroke]:
	var out: Array[Stroke] = []
	var group_width: float = 3.0 * STROKE_GAP + GROUP_GAP
	for i: int in maxi(count, 0):
		@warning_ignore("integer_division")
		var group: int = i / 5
		var in_group: int = i % 5
		var stroke: Stroke = Stroke.new()
		@warning_ignore("integer_division")
		stroke.row = group / GROUPS_PER_ROW
		stroke.across = in_group == 4
		var start: float = (group % GROUPS_PER_ROW) * group_width
		stroke.x = start + (1.5 * STROKE_GAP if stroke.across else in_group * STROKE_GAP)
		out.append(stroke)
	return out


## Pure: the rows `count` strokes take; at least 1, so the sign always has its row.
static func rows_for(count: int) -> int:
	return maxi(1, ceili(maxi(count, 0) / float(5 * GROUPS_PER_ROW)))


## Frees `holder`'s strokes and places one ink box per stroke, rows counted from `first_row`
## down from the skin's top; the sign at the start of the first row.
func _place_row(holder: Node3D, sign_node: Node3D, first_row: int, layout: Array[Stroke]) -> void:
	for child: Node in holder.get_children():
		holder.remove_child(child)
		child.queue_free()
	var left: float = -SKIN_SIZE.x / 2.0 + SIGN_ROOM
	var top: float = SKIN_SIZE.y / 2.0 - ROW_HEIGHT / 2.0
	sign_node.position = Vector3(-SKIN_SIZE.x / 2.0 + SIGN_ROOM / 2.0, top - first_row * ROW_HEIGHT, INK_LIFT)
	var size: Vector3 = Vector3(STROKE_WIDTH, STROKE_LENGTH, STROKE_WIDTH)
	for i: int in layout.size():
		var stroke: Stroke = layout[i]
		var ink: MeshInstance3D = _box("Stroke%d" % (i + 1), size, _ink_material)
		ink.position = Vector3(left + stroke.x, top - (first_row + stroke.row) * ROW_HEIGHT, INK_LIFT)
		if stroke.across:
			ink.rotation = Vector3(0.0, 0.0, -ACROSS_ANGLE)
			ink.scale = Vector3(1.0, 1.3, 1.0)
		holder.add_child(ink)


static func _box(node_name: String, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## Unshaded, never depth-tested, in the transparent pass so its priority puts it over the world.
static func _material(color: Color, priority: int) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.render_priority = priority
	return material
