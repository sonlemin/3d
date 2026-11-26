## The planning screen in its first form, the overhead read-out (story 1.7): the span from
## straight above, each section's number above it and its strength below it, in the game's
## typeface. It reads and never writes.
##
## Every case opens the screen in a SubViewport of the canvas size the case is about: headless,
## `root`'s own canvas is not 1280 x 720. Canvas positions are written out from the story's
## literal cases (L2, L3, L4, L6), never worked out from the screen's own numbers.
extends WatchTest

const PlanningScreen := preload("res://watch/planning/planning.gd")
const PlanningScene := preload("res://watch/planning/planning.tscn")
const LEFT: NightTypes.Side = NightTypes.Side.LEFT
## How far a canvas position may be off: positions come through the camera's float matrices.
const NEAR: float = 0.01

var _port: SubViewport


## The read-out's state (L6): sections at 8, 5, 0 (open), fallen, 1 and 4 planks; section 2's left
## rail stripped. On a shorter def, only the sections it has.
func _readout_def(sections: int = 6) -> NightDef:
	var all: Dictionary[int, int] = {2: 5, 3: 0, 5: 1, 6: 4}
	var start: StartState = StartState.new()
	for n: int in all:
		if n <= sections:
			start.planks[n] = all[n]
	start.stripped_rails = [Vector2i(2, LEFT)]
	start.fallen = [4]
	return _def_with(start, sections)


## The screen for `def`, set up as Main does and added to a SubViewport of `size`.
func _open(def: NightDef, size: Vector2i = Vector2i(1280, 720)) -> PlanningScreen:
	_port = SubViewport.new()
	_port.size = size
	root.add_child(_port)
	var screen: PlanningScreen = PlanningScene.instantiate() as PlanningScreen
	screen.setup(WatchSession.new(LaunchOptions.parse(PackedStringArray()), PackedStringArray()), def)
	_port.add_child(screen)
	return screen


func _close() -> void:
	root.remove_child(_port)
	_port.free()
	_port = null


func _camera(screen: PlanningScreen) -> Camera3D:
	return screen.get_node_or_null("Plan/Camera") as Camera3D


func _label(screen: PlanningScreen, node_name: String) -> Label:
	return screen.get_node_or_null(node_name) as Label


func _near(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) < NEAR


## Where a point of the span lands on the canvas.
func _on_canvas(screen: PlanningScreen, point: Vector3) -> Vector2:
	return _camera(screen).unproject_position(point)


## The middle of a label's rectangle (also its middle when turned: it turns about it).
func _middle(label: Label) -> Vector2:
	return label.position + label.size / 2.0


## The canvas point a label is drawn from: its position, or for a turned label where its own
## corner lands (Godot: position + pivot - the pivot turned).
func _drawn_from(label: Label) -> Vector2:
	return label.position + label.pivot_offset - label.pivot_offset.rotated(label.rotation)


func _is_even(place: Vector2) -> bool:
	return absf(fposmod(place.x + 0.001, 2.0)) < 0.002 and absf(fposmod(place.y + 0.001, 2.0)) < 0.002


## The names of the labels under `screen` that are not drawn from an even canvas pixel.
func _off_even(screen: PlanningScreen) -> PackedStringArray:
	var off: PackedStringArray = []
	for node: Node in screen.find_children("*", "Label", true, false):
		if not _is_even(_drawn_from(node as Label)):
			off.append("%s %s" % [node.name, _drawn_from(node as Label)])
	return off


## Every node under `node`, as "path|class|visible|text" lines: the whole picture.
func _picture(node: Node, from: Node) -> PackedStringArray:
	var out: PackedStringArray = []
	for child: Node in node.get_children():
		var line: String = "%s|%s" % [from.get_path_to(child), child.get_class()]
		if child is CanvasItem:
			line += "|%s|%s" % [(child as CanvasItem).visible, (child as CanvasItem).position if child is Control else Vector2.ZERO]
		if child is Node3D:
			line += "|%s|%s" % [(child as Node3D).visible, (child as Node3D).transform]
		if child is Label:
			line += "|" + (child as Label).text
		out.append(line)
		out.append_array(_picture(child, from))
	return out


func _test_the_tree() -> void:
	var screen: PlanningScreen = _open(_readout_def())
	var camera: Camera3D = _camera(screen)
	_check("planning: Plan holds the camera and the span view", screen.get_node_or_null("Plan") is Node3D
			and camera != null and screen.get_node_or_null("Plan/SpanView") is SpanView)
	if camera == null:
		_close()
		return
	# AC 1: straight above, no perspective. KEEP_WIDTH: `size` is the metres across the canvas width.
	_check("planning: the camera looks without perspective, sized by the canvas width, and is the current one",
			camera.projection == Camera3D.PROJECTION_ORTHOGONAL and camera.keep_aspect == Camera3D.KEEP_WIDTH
			and camera.current)
	_check("planning: it looks straight down", camera.global_transform.basis.z.is_equal_approx(Vector3.UP),
			str(camera.global_transform.basis))
	# AC 1: a `world` (#070707) ground; AC 7: no light.
	var environment: Environment = camera.environment
	_check("planning: the ground is the world colour #070707, a plain background", environment != null
			and environment.background_mode == Environment.BG_COLOR
			and environment.background_color.to_html(false) == "070707",
			environment.background_color.to_html(false) if environment != null else "null")
	var lights: int = 0
	for node: Node in screen.find_children("*", "Light3D", true, false):
		lights += 1
	_check("planning: no light", lights == 0, str(lights))
	# AC 3: the night's span view in its plan look.
	_check("planning: the span view is in the plan look (backings and an outline; no pier, no beam)",
			screen.get_node_or_null("Plan/SpanView/Section1/Backing") != null
			and screen.get_node_or_null("Plan/SpanView/Section4/Outline") != null
			and screen.get_node_or_null("Plan/SpanView/FarPier") == null
			and screen.get_node_or_null("Plan/SpanView/Section1/BeamL") == null)
	var plank: MeshInstance3D = screen.get_node_or_null("Plan/SpanView/Section1/Plank1") as MeshInstance3D
	var rail: MeshInstance3D = screen.get_node_or_null("Plan/SpanView/Section1/RailL") as MeshInstance3D
	var dash: MeshInstance3D = screen.get_node_or_null("Plan/SpanView/Section2/RailDashesL/Dash1") as MeshInstance3D
	var backing: MeshInstance3D = screen.get_node_or_null("Plan/SpanView/Section1/Backing") as MeshInstance3D
	# DESIGN.md, span-section: plank #55534f, standing rail #8d8982, stripped rail dim #5f5d59,
	# missing planks show abyss #000000.
	_check("planning: planks #55534f, rail lines #8d8982, dashes #5f5d59, backings #000000",
			plank != null and rail != null and dash != null and backing != null
			and ((plank.mesh as BoxMesh).material as StandardMaterial3D).albedo_color.to_html(false) == "55534f"
			and ((rail.mesh as BoxMesh).material as StandardMaterial3D).albedo_color.to_html(false) == "8d8982"
			and ((dash.mesh as BoxMesh).material as StandardMaterial3D).albedo_color.to_html(false) == "5f5d59"
			and ((backing.mesh as BoxMesh).material as StandardMaterial3D).albedo_color.to_html(false) == "000000")
	_check("planning: a label for each section's number and strength, and the two end words",
			screen.find_children("Number*", "Label", false, false).size() == 6
			and screen.find_children("Strength*", "Label", false, false).size() == 6
			and _label(screen, "FarPierWord") != null and _label(screen, "TownWord") != null)
	_check("planning: no fault and nothing of the night ran", screen._sim.tick == 0 and screen._faults.total() == 0,
			str(screen._faults.codes()))
	_close()


func _test_the_fit_at_1280_by_720() -> void:
	# L2. room = 32 (safe margin) + 24 (the end word's line) + 11 (gap) = 67; the 30 m fill
	# 1280 - 2 x 67 = 1146 px: 38.2 px per metre; camera.size = 30 x 1280 / 1146.
	var screen: PlanningScreen = _open(_readout_def())
	var camera: Camera3D = _camera(screen)
	_check("fit 1280x720: the camera sees 33.5079 m across", absf(camera.size - 30.0 * 1280.0 / 1146.0) < 0.0001
			and absf(camera.size - 33.5079) < 0.0001, str(camera.size))
	# L4, not mirrored: section 1's LEFT (-X) corner at the far pier is left and low; section 6's
	# RIGHT corner at the town is right and high.
	_check("fit 1280x720: section 1's left corner at the far pier is at (67, 455.5)",
			_near(_on_canvas(screen, Vector3(-2.5, 0.0, -30.0)), Vector2(67.0, 455.5)),
			str(_on_canvas(screen, Vector3(-2.5, 0.0, -30.0))))
	_check("fit 1280x720: section 6's right corner at the town is at (1213, 264.5)",
			_near(_on_canvas(screen, Vector3(2.5, 0.0, 0.0)), Vector2(1213.0, 264.5)),
			str(_on_canvas(screen, Vector3(2.5, 0.0, 0.0))))
	# Section n spans x 67 + 191 (n - 1) to 67 + 191 n: its number and its strength are centred on
	# 67 + 191 (n - 0.5). The number's bottom edge is 11 px above the deck's top edge (y 264.5): 253.5;
	# the strength's top edge 11 px below its bottom edge (y 455.5): 466.5. Then each is moved to the
	# nearest even canvas pixel (Sonlm, 2026-11-26: a whole screen pixel at 1080p), at most 1 px.
	# A strength is 16 x 40, so it would be at x 191 n - 36.5: 154.5, 345.5, 536.5, (727.5), 918.5,
	# 1109.5, y 466.5. On even pixels: x 154, 346, 536, (728), 918, 1110, y 466. Section 4 has fallen:
	# its strength is hidden and has no text, so its place is not looked at. A number is 24 px high:
	# its top would be y 229.5, and is 230.
	var strength_x: Array[float] = [154.0, 346.0, 536.0, 728.0, 918.0, 1110.0]
	var wrong: PackedStringArray = []
	for n: int in range(1, 7):
		var number: Label = _label(screen, "Number%d" % n)
		var strength: Label = _label(screen, "Strength%d" % n)
		var x: float = 67.0 + 191.0 * (n - 0.5)
		if absf(_middle(number).x - x) > 1.0 + NEAR or absf(number.position.y - 230.0) > NEAR or not _is_even(number.position):
			wrong.append("Number%d at %s, %s" % [n, number.position, number.size])
		if strength.visible and not strength.position.is_equal_approx(Vector2(strength_x[n - 1], 466.0)):
			wrong.append("Strength%d at %s, %s" % [n, strength.position, strength.size])
	_check("fit 1280x720: each number is over its section's middle (within 1 px), its top at y 230; the five strengths shown are at x 154 346 536 918 1110, y 466",
			wrong.is_empty(), " | ".join(wrong))
	var number1: Label = _label(screen, "Number1")
	_check("fit 1280x720: Number1 is centred within 1 px of x 162.5", absf(_middle(number1).x - 162.5) <= 1.0 + NEAR,
			str(_middle(number1)))
	_check("fit 1280x720: every label is drawn from an even canvas pixel", _off_even(screen).is_empty(), str(_off_even(screen)))
	# The end words: turned a quarter turn to read upward, on the deck's centre line, their 24 px
	# line box from the safe margin (x 32 to 56, and 1224 to 1248); along their line they may be
	# 1 px off the centre line, to be drawn from an even pixel.
	var far: Label = _label(screen, "FarPierWord")
	var town: Label = _label(screen, "TownWord")
	_check("fit 1280x720: FAR PIER is centred at (44, 360), TOWN at (1236, 360), within 1 px along the line",
			absf(_middle(far).x - 44.0) < NEAR and absf(_middle(far).y - 360.0) <= 1.0 + NEAR
			and absf(_middle(town).x - 1236.0) < NEAR and absf(_middle(town).y - 360.0) <= 1.0 + NEAR,
			"%s %s" % [_middle(far), _middle(town)])
	_check("fit 1280x720: FAR PIER is drawn from x 32, the safe margin; TOWN from x 1224",
			is_equal_approx(_drawn_from(far).x, 32.0) and is_equal_approx(_drawn_from(town).x, 1224.0),
			"%s %s" % [_drawn_from(far), _drawn_from(town)])
	_check("fit 1280x720: both are turned to read upward, about their middle", is_equal_approx(far.rotation, -PI / 2.0)
			and is_equal_approx(town.rotation, -PI / 2.0) and far.pivot_offset.is_equal_approx(far.size / 2.0)
			and town.pivot_offset.is_equal_approx(town.size / 2.0), "%s %s" % [far.rotation, far.pivot_offset])
	_check("fit 1280x720: their line is 24 px high: 32 px from the canvas edge, 11 px from the span's end",
			is_equal_approx(far.size.y, 24.0) and is_equal_approx(town.size.y, 24.0), str(far.size))
	_close()


func _test_numbers_and_strengths() -> void:
	# L6 / AC 4: strength is SpanRules.strength(): the planks while there are any, 2 for an open
	# section (story 1.6 D4). AC 5 / D2: a fallen section keeps its number and has no strength.
	var screen: PlanningScreen = _open(_readout_def())
	var numbers: PackedStringArray = []
	var strengths: PackedStringArray = []
	var ok: bool = true
	for n: int in range(1, 7):
		var number: Label = _label(screen, "Number%d" % n)
		var strength: Label = _label(screen, "Strength%d" % n)
		numbers.append(number.text if number.visible else "hidden")
		strengths.append(strength.text if strength.visible else "hidden")
		# AC 4: the section number in the label style, the strength in the number style.
		ok = ok and number.theme_type_variation == &"WatchLabel" and strength.theme_type_variation == &"WatchNumber"
	_check("numbers: 1 to 6, all shown", numbers == PackedStringArray(["1", "2", "3", "4", "5", "6"]), str(numbers))
	_check("numbers: strengths 8, 5, 2 (open), none (fallen), 1, 4",
			strengths == PackedStringArray(["8", "5", "2", "hidden", "1", "4"]), str(strengths))
	_check("numbers: the section number is in the label style, the strength in the number style", ok)
	var far: Label = _label(screen, "FarPierWord")
	var town: Label = _label(screen, "TownWord")
	_check("numbers: the end words are 'Far pier' and 'Town', shown in capitals in the label style",
			far.text == "Far pier" and town.text == "Town" and far.uppercase and town.uppercase
			and far.theme_type_variation == &"WatchLabel" and town.theme_type_variation == &"WatchLabel",
			"%s %s" % [far.text, town.text])
	_close()


func _test_other_canvases() -> void:
	# L3. Taller (1280 x 960): the same x, the deck in the vertical middle (480 +- 95.5).
	var screen: PlanningScreen = _open(_readout_def(), Vector2i(1280, 960))
	_check("fit 1280x960: the corners are at (67, 575.5) and (1213, 384.5)",
			_near(_on_canvas(screen, Vector3(-2.5, 0.0, -30.0)), Vector2(67.0, 575.5))
			and _near(_on_canvas(screen, Vector3(2.5, 0.0, 0.0)), Vector2(1213.0, 384.5)),
			"%s %s" % [_on_canvas(screen, Vector3(-2.5, 0.0, -30.0)), _on_canvas(screen, Vector3(2.5, 0.0, 0.0))])
	var number: Label = _label(screen, "Number1")
	var strength: Label = _label(screen, "Strength1")
	# Number1's bottom would be at y 373.5 (its top 349.5: 350); Strength1 at (154.5, 586.5): (154, 586).
	_check("fit 1280x960: Number1's top is at y 350 and Strength1 at (154, 586), Number1 within 1 px of x 162.5",
			absf(number.position.y - 350.0) < NEAR and strength.position.is_equal_approx(Vector2(154.0, 586.0))
			and absf(_middle(number).x - 162.5) <= 1.0 + NEAR, "%s %s" % [number.position, strength.position])
	_check("fit 1280x960: the end words are on the centre line, y 480, within 1 px along it",
			absf(_middle(_label(screen, "FarPierWord")).x - 44.0) < NEAR and absf(_middle(_label(screen, "FarPierWord")).y - 480.0) <= 1.0 + NEAR
			and absf(_middle(_label(screen, "TownWord")).x - 1236.0) < NEAR and absf(_middle(_label(screen, "TownWord")).y - 480.0) <= 1.0 + NEAR)
	_check("fit 1280x960: every label is drawn from an even canvas pixel", _off_even(screen).is_empty(), str(_off_even(screen)))
	_close()
	# Wider (1706 x 720): 1706 - 134 = 1572 px for 30 m: 52.4 px per metre. Section 1 from x 67 to
	# 329, section 6's town end at x 1639, the deck's edges at y 360 -+ 131: 229 and 491.
	screen = _open(_readout_def(), Vector2i(1706, 720))
	_check("fit 1706x720: the corners are at (67, 491) and (1639, 229)",
			_near(_on_canvas(screen, Vector3(-2.5, 0.0, -30.0)), Vector2(67.0, 491.0))
			and _near(_on_canvas(screen, Vector3(2.5, 0.0, 0.0)), Vector2(1639.0, 229.0)),
			"%s %s" % [_on_canvas(screen, Vector3(-2.5, 0.0, -30.0)), _on_canvas(screen, Vector3(2.5, 0.0, 0.0))])
	_check("fit 1706x720: section 1 ends at x 329", absf(_on_canvas(screen, Vector3(0.0, 0.0, -25.0)).x - 329.0) < NEAR)
	number = _label(screen, "Number1")
	strength = _label(screen, "Strength1")
	# Number1 would be centred on x 198 with its bottom at y 218 (its top 194, even already);
	# Strength1 at (190, 502), even already.
	_check("fit 1706x720: Number1 is within 1 px of x 198, its top at y 194; Strength1 at (190, 502)",
			absf(_middle(number).x - 198.0) <= 1.0 + NEAR and absf(number.position.y - 194.0) < NEAR
			and strength.position.is_equal_approx(Vector2(190.0, 502.0)), "%s %s" % [number.position, strength.position])
	_check("fit 1706x720: TOWN is centred at (1662, 360), within 1 px along its line",
			absf(_middle(_label(screen, "TownWord")).x - 1662.0) < NEAR and absf(_middle(_label(screen, "TownWord")).y - 360.0) <= 1.0 + NEAR,
			str(_middle(_label(screen, "TownWord"))))
	_check("fit 1706x720: every label is drawn from an even canvas pixel", _off_even(screen).is_empty(), str(_off_even(screen)))
	_close()


func _test_four_sections() -> void:
	# AC 13 / L3: 4 sections (20 m) at 1280 x 720: 57.3 px per metre, camera.size 22.3386, section 1
	# from x 67 to 353.5, the deck's edges at y 360 -+ 143.25: 216.75 and 503.25.
	var screen: PlanningScreen = _open(_readout_def(4))
	var camera: Camera3D = _camera(screen)
	_check("4 sections: the camera sees 22.3386 m across", absf(camera.size - 22.3386) < 0.0001, str(camera.size))
	_check("4 sections: section 1's left corner at the far pier is at (67, 503.25), its town end at x 353.5",
			_near(_on_canvas(screen, Vector3(-2.5, 0.0, -20.0)), Vector2(67.0, 503.25))
			and absf(_on_canvas(screen, Vector3(0.0, 0.0, -15.0)).x - 353.5) < NEAR,
			str(_on_canvas(screen, Vector3(-2.5, 0.0, -20.0))))
	_check("4 sections: section 4's right corner at the town is at (1213, 216.75)",
			_near(_on_canvas(screen, Vector3(2.5, 0.0, 0.0)), Vector2(1213.0, 216.75)))
	var strengths: PackedStringArray = []
	for n: int in range(1, 5):
		var strength: Label = _label(screen, "Strength%d" % n)
		strengths.append(strength.text if strength.visible else "hidden")
	_check("4 sections: 4 numbers and 4 strengths: 8, 5, 2, none", screen.find_children("Number*", "Label", false, false).size() == 4
			and strengths == PackedStringArray(["8", "5", "2", "hidden"]), str(strengths))
	_check("4 sections: 4 sections drawn", screen.get_node("Plan/SpanView").get_child_count() == 4)
	# Section 1 of 4 is x 67 to 353.5 (middle 210.25), the deck's edges y 216.75 and 503.25: Strength1
	# would be at (202.25, 514.25): (202, 514); Number1's top at 216.75 - 11 - 24 = 181.75: 182.
	_check("4 sections: Strength1 is at (202, 514) and Number1's top at y 182, within 1 px of x 210.25",
			_label(screen, "Strength1").position.is_equal_approx(Vector2(202.0, 514.0))
			and absf(_label(screen, "Number1").position.y - 182.0) < NEAR
			and absf(_middle(_label(screen, "Number1")).x - 210.25) <= 1.0 + NEAR,
			"%s %s" % [_label(screen, "Strength1").position, _label(screen, "Number1").position])
	_check("4 sections: every label is drawn from an even canvas pixel", _off_even(screen).is_empty(), str(_off_even(screen)))
	_check("4 sections: no fault", screen._faults.total() == 0, str(screen._faults.codes()))
	_close()


func _test_the_canvas_changes_size() -> void:
	# AC 10: the labels are placed again when the canvas changes size (a window dragged wider under
	# the `expand` aspect). From 1280 x 720 to 1706 x 720: the wide case of L3.
	var screen: PlanningScreen = _open(_readout_def())
	var number: Label = _label(screen, "Number1")
	_check("resize: at 1280x720 Number1 is centred within 1 px of x 162.5", absf(_middle(number).x - 162.5) <= 1.0 + NEAR)
	_port.size = Vector2i(1706, 720)
	var camera: Camera3D = _camera(screen)
	_check("resize: at 1706x720 the camera sees 30 x 1706 / 1572 m across", absf(camera.size - 30.0 * 1706.0 / 1572.0) < 0.0001,
			str(camera.size))
	_check("resize: Number1 is within 1 px of x 198, its top at y 194", absf(_middle(number).x - 198.0) <= 1.0 + NEAR
			and absf(number.position.y - 194.0) < NEAR, str(number.position))
	# Strength6 is centred on x 1508, 16 px wide: x 1500, even already.
	_check("resize: Strength6 is at (1500, 502)", _label(screen, "Strength6").position.is_equal_approx(Vector2(1500.0, 502.0)),
			str(_label(screen, "Strength6").position))
	_check("resize: TOWN is centred at (1662, 360), within 1 px along its line",
			absf(_middle(_label(screen, "TownWord")).x - 1662.0) < NEAR and absf(_middle(_label(screen, "TownWord")).y - 360.0) <= 1.0 + NEAR,
			str(_middle(_label(screen, "TownWord"))))
	_check("resize: every label is drawn from an even canvas pixel again", _off_even(screen).is_empty(), str(_off_even(screen)))
	# A canvas no wider than the room at its two ends (2 x 67 px): the camera is left as it is; no
	# division by nothing, no negative size, no error.
	var before: float = camera.size
	_port.size = Vector2i(134, 720)
	_check("resize: a canvas 134 px wide leaves the camera as it was", camera.size == before, str(camera.size))
	_port.size = Vector2i(100, 720)
	_check("resize: and so does one 100 px wide", camera.size == before and camera.size > 0.0, str(camera.size))
	_port.size = Vector2i(1280, 720)
	_check("resize: back at 1280x720 it fits again", absf(camera.size - 30.0 * 1280.0 / 1146.0) < 0.0001
			and absf(_middle(number).x - 162.5) <= 1.0 + NEAR
			and _label(screen, "Strength1").position.is_equal_approx(Vector2(154.0, 466.0)), str(camera.size))
	_close()
	# Opened on a canvas that narrow: nothing is divided by nothing.
	screen = _open(_readout_def(), Vector2i(120, 720))
	_check("resize: opened 120 px wide, the screen is built and the camera's size is above 0",
			_camera(screen) != null and _camera(screen).size > 0.0 and _label(screen, "Number1") != null)
	_close()


func _test_read_only() -> void:
	# AC 7: clicked or a key pressed, nothing changes (read-only until epic 5; Esc included: pause is
	# epic 5).
	var screen: PlanningScreen = _open(_readout_def())
	var span_before: Array = screen._sim.span.values()
	var picture_before: PackedStringArray = _picture(screen, screen)
	var checksum_before: int = screen._sim.checksum()
	var events: Array[InputEvent] = []
	for button: MouseButton in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		for pressed: bool in [true, false]:
			var click: InputEventMouseButton = InputEventMouseButton.new()
			click.button_index = button
			click.pressed = pressed
			click.position = Vector2(162.0, 360.0)  # on section 1's deck
			click.global_position = click.position
			events.append(click)
	for key: Key in [KEY_E, KEY_TAB, KEY_ESCAPE, KEY_ENTER, KEY_SPACE, KEY_1, KEY_Z]:
		for pressed: bool in [true, false]:
			var press: InputEventKey = InputEventKey.new()
			press.keycode = key
			press.physical_keycode = key
			press.pressed = pressed
			events.append(press)
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = Vector2(700.0, 360.0)
	motion.global_position = motion.position
	motion.relative = Vector2(40.0, 0.0)
	events.append(motion)
	for event: InputEvent in events:
		_port.push_input(event)
	_check("read-only: clicks, keys and a pointer move leave the span as it was", screen._sim.span.values() == span_before
			and screen._sim.checksum() == checksum_before and screen._sim.tick == 0)
	var picture_after: PackedStringArray = _picture(screen, screen)
	_check("read-only: and every node, place, label and text of the screen", picture_after == picture_before
			and picture_before.size() > 20, str(picture_before.size()))
	# The labels take no pointer input, and the screen has no input handler at all.
	var stops: PackedStringArray = []
	for label: Node in screen.find_children("*", "Label", true, false):
		if (label as Label).mouse_filter != Control.MOUSE_FILTER_IGNORE:
			stops.append(label.name)
	_check("read-only: every label ignores the pointer", stops.is_empty(), str(stops))
	var code: String = _code_of("res://watch/planning/planning.gd")
	var handlers: PackedStringArray = []
	for word: String in ["_input", "_unhandled_input", "_unhandled_key_input", "_shortcut_input", "_gui_input",
			"gui_input", "Input.", "is_action", ".advance(", ".command(", "set_move(", "set_view("]:
		if code.contains(word):
			handlers.append(word)
	_check("read-only: planning.gd has no input handler, reads no input and never drives the sim", handlers.is_empty(),
			str(handlers))
	_close()


func _test_no_setup() -> void:
	# The scene run alone from the editor: a setup problem, and nothing is drawn (as night.gd).
	_port = SubViewport.new()
	_port.size = Vector2i(1280, 720)
	root.add_child(_port)
	var screen: PlanningScreen = PlanningScene.instantiate() as PlanningScreen
	_expect_begin()
	_port.add_child(screen)
	_expect_end("planning: opened without setup() is planning.no_setup", [["WARNING", "planning.no_setup", 1]])
	_check("planning: and nothing is built", screen.get_child_count() == 0, str(screen.get_children()))
	_port.size = Vector2i(1706, 720)
	_check("planning: a size change then does nothing", screen.get_child_count() == 0)
	_close()


## A script's text with comments left out (from the first `#` of each line on).
func _code_of(path: String) -> String:
	var lines: PackedStringArray = []
	for line: String in FileAccess.get_file_as_string(path).split("\n"):
		lines.append(line.get_slice("#", 0))
	return "\n".join(lines)


## Every `.gd` under `dir`, at any depth.
func _scripts_under(dir: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(dir):
		if file_name.ends_with(".gd"):
			found.append(dir.path_join(file_name))
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_scripts_under(dir.path_join(sub)))
	return found


func _test_no_pixel_size_but_the_theme_s() -> void:
	# AC 6 / AD-69: only watch_theme.gd turns a token into a canvas size; no other script or scene of
	# the screen sets a pixel size.
	var scene: String = FileAccess.get_file_as_string("res://watch/planning/planning.tscn")
	_check("sizes: planning.tscn sets no theme override and no minimum size", not scene.is_empty()
			and not scene.contains("theme_override") and not scene.contains("custom_minimum_size"))
	var screen: PlanningScreen = PlanningScene.instantiate() as PlanningScreen
	_check("sizes: the scene is thin: the root alone, filling the screen by anchors", screen.get_child_count() == 0
			and screen.anchor_left == 0.0 and screen.anchor_top == 0.0 and screen.anchor_right == 1.0
			and screen.anchor_bottom == 1.0 and screen.offset_left == 0.0 and screen.offset_top == 0.0
			and screen.offset_right == 0.0 and screen.offset_bottom == 0.0)
	screen.free()
	screen = _open(_readout_def())
	_check("sizes: the screen's root carries the theme", screen.theme != null
			and screen.theme.get_font_size(&"font_size", &"WatchNumber") == 32)
	var sized: PackedStringArray = []
	var controls: Array[Node] = screen.find_children("*", "Control", true, false)
	controls.append(screen)
	for node: Node in controls:
		var control: Control = node as Control
		if control.has_theme_font_override(&"font") or control.has_theme_font_size_override(&"font_size") \
				or control.has_theme_color_override(&"font_color"):
			sized.append("%s: a font, size or colour override" % control.name)
		if control.custom_minimum_size != Vector2.ZERO:
			sized.append("%s: custom_minimum_size %s" % [control.name, control.custom_minimum_size])
		if control != screen and control.theme != null:
			sized.append("%s: a theme of its own" % control.name)
	_check("sizes: no control of the built screen has a font, size or colour override, a minimum size or its own theme",
			sized.is_empty() and controls.size() == 15, "%d controls; %s" % [controls.size(), sized])
	_close()
	var users: PackedStringArray = []
	var scripts: PackedStringArray = _scripts_under("res://watch")
	for path: String in scripts:
		if path != "res://watch/screens/watch_theme.gd" and _code_of(path).contains("font_size"):
			users.append(path)
	_check("sizes: no script under watch/ but watch_theme.gd names a font size", users.is_empty()
			and scripts.has("res://watch/screens/watch_theme.gd") and scripts.has("res://watch/planning/planning.gd"),
			str(users))
	var namers: PackedStringArray = []
	for path: String in scripts:
		if path != "res://watch/screens/watch_theme.gd" and FileAccess.get_file_as_string(path).contains("cormorant"):
			namers.append(path)
	_check("sizes: and only watch_theme.gd names the font file", namers.is_empty(), str(namers))
