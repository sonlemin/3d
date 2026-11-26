## The planning screen in its first form, the overhead read-out (story 1.7; GDD Game Mechanics 10,
## UX-8): the whole span seen from straight above, the far pier at the left and the town at the
## right, each section's number above it and its strength below it. It reads and never writes:
## clicks, strips, the tray and the bell are epic 5's, and until then no key, click or pointer does
## anything here (Esc included; the window is closed to leave, as on the title).
##
## The scene is thin (AD-62): the root and this script. The span is the night's own SpanView in its
## plan look (AD-23), under a camera with no perspective looking straight down; every shape is
## placed by SpanGeometry, and the numbers and words are ordinary labels laid over the picture at
## the places the camera gives. Flat colours on the world ground: no light, no texture, no shader.
##
## Where the state comes from: there is no PlanEditor until epic 5, so the screen builds one
## NightSim from the NightDef (which applies the StartState through the parts ledger), never
## advances it, and hands its geometry and span to the view once.
##
## No pixel size is written here (AD-69): every one comes from WatchTheme, and the fit measures the
## labels themselves.
extends Control

## View only, in metres: how high above the deck the camera hangs. With no perspective the height
## changes nothing that is seen; it only has to be above the rail lines.
const CAMERA_HEIGHT: float = 20.0

var _session: WatchSession
var _faults: WatchFaults
var _sim: NightSim
var _camera: Camera3D
## Section n's two labels are at index n - 1.
var _numbers: Array[Label] = []
var _strengths: Array[Label] = []
var _far_pier_word: Label
var _town_word: Label


## Called by Main before the screen is added to the tree. The seed is 0: nothing here is random,
## and the sim is never advanced.
func setup(session: WatchSession, def: NightDef) -> void:
	_session = session
	_faults = WatchFaults.new()
	_sim = NightSim.new(def, 0, _faults)


## Builds and fits in this call, so the screen is whole the moment it is in the tree. Opened
## without setup() (the scene run on its own from the editor): a setup problem and nothing drawn.
func _ready() -> void:
	if _sim == null:
		push_warning("planning.no_setup: the planning screen was opened without setup(); start it with --start=planning")
		return
	theme = WatchTheme.build()
	_build_plan()
	_build_labels()
	_fit()
	get_viewport().size_changed.connect(_fit)


## The picture: the camera and the span view in its plan look, shown once.
func _build_plan() -> void:
	var geometry: SpanGeometry = _sim.geometry
	var plan: Node3D = Node3D.new()
	plan.name = "Plan"
	add_child(plan)
	var ground: Environment = Environment.new()
	ground.background_mode = Environment.BG_COLOR
	ground.background_color = WatchTheme.WORLD
	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.environment = ground
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	# KEEP_WIDTH: `size` is the metres across the canvas width, whatever its height (_fit()).
	_camera.keep_aspect = Camera3D.KEEP_WIDTH
	# Over the span's middle, looking straight down, and not mirrored: the camera's right is world
	# +Z (the town), its up is world +X (the RIGHT rail), so "left rail" is the same rail here as at
	# night. Any other basis that puts the town at the right swaps the rails.
	_camera.transform = Transform3D(Basis(Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0)),
			Vector3(0.0, CAMERA_HEIGHT, geometry.world_z(geometry.length() / 2.0)))
	plan.add_child(_camera)
	_camera.current = true
	var span_view: SpanView = SpanView.new()
	span_view.name = "SpanView"
	span_view.use_plan_look(WatchTheme.PLANK, WatchTheme.RAIL, WatchTheme.DIM, WatchTheme.ABYSS)
	plan.add_child(span_view)
	# Nothing ticks in planning, so no groan is running: the plan look does not read its length.
	span_view.show_span(geometry, _sim.span, 0)


## Each section's number and strength, and the two end words. Texts are set once: the screen is
## read-only and its span never changes.
func _build_labels() -> void:
	var span: SpanState = _sim.span
	for n: int in range(1, span.section_count() + 1):
		_numbers.append(_add_label("Number%d" % n, WatchTheme.LABEL_STYLE, str(n)))
		# Strength is asked, never worked out here (AD-35): an open section's side beams carry 2. A
		# fallen section keeps its number and has no strength (story 1.7 decision D2).
		var strength: Label = _add_label("Strength%d" % n, WatchTheme.NUMBER_STYLE,
				"" if span.fallen(n) else str(SpanRules.strength(n, span)))
		strength.visible = not span.fallen(n)
		_strengths.append(strength)
	_far_pier_word = _add_label("FarPierWord", WatchTheme.LABEL_STYLE, UiText.FAR_PIER)
	_town_word = _add_label("TownWord", WatchTheme.LABEL_STYLE, UiText.TOWN)
	# Decision D4: the end words are turned a quarter turn to read upward, about their middle.
	for word: Label in [_far_pier_word, _town_word]:
		word.pivot_offset = word.size / 2.0
		word.rotation = -PI / 2.0


## A label of `style` showing `text`, in the tree and at its own smallest size. It is measured
## under the themed root, after its text is set. It takes no pointer input: a Label ignores the
## pointer unless told otherwise, and nothing here tells it (a test holds that).
func _add_label(node_name: String, style: StringName, text: String) -> Label:
	var label: Label = WatchTheme.make_label(style)
	label.name = node_name
	add_child(label)
	label.text = text
	label.reset_size()
	return label


## Fits the span to the canvas and places every label; again whenever the canvas changes size.
## The sections fill the canvas width less `room` at each side: the safe margin, an end word's
## line, and a gap. The camera is over the span's middle, so the deck's centre line is at half the
## canvas height. A canvas no wider than the two rooms leaves the camera as it is. Each label is
## then moved to the nearest even canvas pixel (at most 1 px), so its text is sharp in a 1080p
## window too (WatchTheme.even_px()).
func _fit() -> void:
	var geometry: SpanGeometry = _sim.geometry
	var canvas: Vector2 = get_viewport().get_visible_rect().size
	var margin: float = WatchTheme.canvas_px(WatchTheme.SAFE_MARGIN_PX)
	var gap: float = WatchTheme.canvas_px(WatchTheme.SPACING_2_PX)
	var word_line: float = _far_pier_word.size.y
	var room: float = margin + word_line + gap
	if canvas.x > 2.0 * room:
		_camera.size = geometry.length() * canvas.x / (canvas.x - 2.0 * room)
	for i: int in _numbers.size():
		var deck: AABB = geometry.deck_box(i + 1)
		var middle_z: float = deck.get_center().z
		# The RIGHT rail's edge (+X) is the deck's top edge on the canvas, the LEFT its bottom edge.
		var top: Vector2 = _camera.unproject_position(Vector3(deck.end.x, 0.0, middle_z))
		var bottom: Vector2 = _camera.unproject_position(Vector3(deck.position.x, 0.0, middle_z))
		var number: Label = _numbers[i]
		number.position = WatchTheme.even_px(Vector2(top.x - number.size.x / 2.0, top.y - gap - number.size.y))
		var strength: Label = _strengths[i]
		strength.position = WatchTheme.even_px(Vector2(bottom.x - strength.size.x / 2.0, bottom.y + gap))
	# Each word's line box (as wide as the line is high, once turned) runs from the safe margin to
	# `gap` short of the span's end; the word is centred on the deck's centre line.
	var line_middle: float = margin + word_line / 2.0
	_place_word(_far_pier_word, Vector2(line_middle, canvas.y / 2.0))
	_place_word(_town_word, Vector2(canvas.x - line_middle, canvas.y / 2.0))


## Puts a turned end word's middle at `middle`, less the little it takes to draw it from an even
## pixel. Turned a quarter turn about its middle, the word is drawn from the corner that is its
## lower left on the canvas; that corner is what must be on an even pixel (WatchTheme.even_px()).
func _place_word(word: Label, middle: Vector2) -> void:
	var corner: Vector2 = Vector2(middle.x - word.size.y / 2.0, middle.y + word.size.x / 2.0)
	word.position = middle - word.size / 2.0 + WatchTheme.even_px(corner) - corner
