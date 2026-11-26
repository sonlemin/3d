## The span view's second look, the plan look (story 1.7, AD-23: one span view draws the night,
## planning and dawn). Seen from straight above by the planning screen: flat unshaded shapes in
## the colours it is handed, every one placed by asking SpanGeometry. The night look's own tests
## are test_span_view.gd, which this story does not edit. Runs synchronously under `root`.
extends WatchTest

const LEFT: NightTypes.Side = NightTypes.Side.LEFT
const RIGHT: NightTypes.Side = NightTypes.Side.RIGHT
# The four colours the planning screen hands in (Sonlm's M1, 2026-11-27, option C): planks #8d8982,
# standing rails #ddd6c8, dashed lines #8d8982, and DESIGN.md's abyss #000000 under the planks.
# Planks and dashes share a colour, so the test hands the dashes a colour of its own (#7a7670) to
# tell which one a shape was given.
const PLANK: Color = Color("#8d8982")
const RAIL: Color = Color("#ddd6c8")
const DASH: Color = Color("#7a7670")
const ABYSS: Color = Color("#000000")


## A plan-look view of `sim`'s span, shown once, with no tick and no event.
func _plan_view_of(sim: NightSim) -> SpanView:
	var view: SpanView = SpanView.new()
	view.use_plan_look(PLANK, RAIL, DASH, ABYSS)
	root.add_child(view)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	return view


## Story 1.7 L6, the read-out's state: sections at 8, 5, 0 (open), fallen, 1 and 4 planks, section
## 2's left rail stripped.
func _readout_start() -> StartState:
	var start: StartState = StartState.new()
	start.planks = {2: 5, 3: 0, 5: 1, 6: 4}
	start.stripped_rails = [Vector2i(2, LEFT)]
	start.fallen = [4]
	return start


func _is_box(node: Node, box: AABB) -> bool:
	var mesh_node: MeshInstance3D = node as MeshInstance3D
	if mesh_node == null or not (mesh_node.mesh is BoxMesh):
		return false
	return mesh_node.position.is_equal_approx(box.get_center()) \
			and (mesh_node.mesh as BoxMesh).size.is_equal_approx(box.size)


## The children of `parent` whose names begin with `prefix`.
func _named(parent: Node, prefix: String) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in parent.get_children():
		if String(child.name).begins_with(prefix):
			out.append(child)
	return out


## Every node under `node`, at any depth.
func _all_under(node: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in node.get_children():
		out.append(child)
		out.append_array(_all_under(child))
	return out


## True when `group` holds exactly one box per entry of `boxes`, in order.
func _are_boxes(group: Node, boxes: Array[AABB]) -> bool:
	if group == null or group.get_child_count() != boxes.size():
		return false
	for i: int in boxes.size():
		if not _is_box(group.get_child(i), boxes[i]):
			return false
	return true


func _test_the_read_out_s_span() -> void:
	var sim: NightSim = _sim_with(_def_with(_readout_start()), 1)
	var g: SpanGeometry = sim.geometry
	var view: SpanView = _plan_view_of(sim)
	_check("plan: 6 sections drawn", view.get_children().filter(func(n: Node) -> bool: return n is SectionView).size() == 6)
	# Decision D4: no pier shapes; the landing is not part of the read-out either.
	_check("plan: no pier and no landing", view.get_node_or_null("FarPier") == null
			and view.get_node_or_null("TownPier") == null and view.get_node_or_null("Landing") == null)
	# L6: planks drawn 8, 5, 0, 0, 1, 4, each at plank_place() of places_kept(count), as the night.
	var counts: Array[int] = [8, 5, 0, 0, 1, 4]
	var ok: bool = true
	var drawn: Array[int] = []
	for n: int in range(1, 7):
		var section: SectionView = view.get_node("Section%d" % n)
		drawn.append(_named(section, "Plank").size())
		for place: int in g.places_kept(counts[n - 1]):
			var plank: MeshInstance3D = section.get_node_or_null("Plank%d" % place)
			ok = ok and plank != null and plank.position.is_equal_approx(g.plank_place(n, place)) \
					and (plank.mesh as BoxMesh).size.is_equal_approx(g.plank_size())
	_check("plan: planks drawn to the count: 8 5 0 0 1 4", drawn == counts, str(drawn))
	_check("plan: each plank where SpanGeometry puts it for the count (GD-54)", ok)
	# What a standing section is made of, by name, and nothing else: its backing, its planks, and
	# per side a rail line or a row of dashes.
	var kids: Array[int] = []
	for n: int in range(1, 7):
		kids.append(view.get_node("Section%d" % n).get_child_count())
	_check("plan: child counts 11 8 3 1 4 7 (backing + planks + two rails; the fallen one its outline)",
			kids == [11, 8, 3, 1, 4, 7], str(kids))
	ok = true
	for n: int in [1, 2, 3, 5, 6]:
		var section: SectionView = view.get_node("Section%d" % n)
		ok = ok and _is_box(section.get_node_or_null("Backing"), g.plan_backing_box(n))
		for side: NightTypes.Side in [LEFT, RIGHT]:
			var tag: String = "L" if side == LEFT else "R"
			if n == 2 and side == LEFT:
				ok = ok and section.get_node_or_null("Rail" + tag) == null \
						and _are_boxes(section.get_node_or_null("RailDashes" + tag), g.plan_rail_dashes(n, side))
			else:
				ok = ok and section.get_node_or_null("RailDashes" + tag) == null \
						and _is_box(section.get_node_or_null("Rail" + tag), g.plan_rail_box(n, side))
	_check("plan: a backing under each standing section; a line for a standing rail, dashes for section 2's left", ok)
	# AC 5 / D2: a fallen section is its dashed outline and nothing else inside it.
	var section4: SectionView = view.get_node("Section4")
	_check("plan: the fallen section 4 is its outline only: 40 dashes from SpanGeometry",
			section4.get_child_count() == 1 and _are_boxes(section4.get_node_or_null("Outline"), g.plan_outline_dashes(4)),
			str(section4.get_children()))
	# The open section 3: an all-black deck with both rails (AC 4: it reads 2).
	var section3: SectionView = view.get_node("Section3")
	_check("plan: the open section 3 is its backing and two rail lines, no plank",
			section3.get_node_or_null("Backing") != null and section3.get_node_or_null("RailL") != null
			and section3.get_node_or_null("RailR") != null and _named(section3, "Plank").is_empty())
	_check("plan: no fault drawing it", _faults.total() == 0, str(_faults.codes()))
	view.free()


func _test_literal_places() -> void:
	# Story 1.7 L5 with the widths of Sonlm's M1 (0.2 and 0.1 m), section 2 of 6 (z -25 to -20),
	# written out: the right rail's line is x 2.5 to 2.7, z -24.85 to -20.15 (centre (2.6, 1.0,
	# -22.5), 0.2 x 0.05 x 4.7); the left rail's first dash is x -2.6 to -2.5, z -24.875 to -24.625
	# (centre (-2.55, 1.0, -24.75)); the backing is 5 m by 5 m with its top at y -0.08.
	var sim: NightSim = _sim_with(_def_with(_readout_start()), 1)
	var view: SpanView = _plan_view_of(sim)
	var rail: MeshInstance3D = view.get_node_or_null("Section2/RailR") as MeshInstance3D
	_check("plan: section 2's right rail line is centred at (2.6, 1.0, -22.5), 0.2 x 0.05 x 4.7", rail != null
			and rail.position.is_equal_approx(Vector3(2.6, 1.0, -22.5))
			and (rail.mesh as BoxMesh).size.is_equal_approx(Vector3(0.2, 0.05, 4.7)),
			"%s" % [rail.position if rail != null else Vector3.ZERO])
	var dash: MeshInstance3D = view.get_node_or_null("Section2/RailDashesL/Dash1") as MeshInstance3D
	_check("plan: its left rail's first dash is centred at (-2.55, 1.0, -24.75), 0.1 x 0.05 x 0.25", dash != null
			and dash.position.is_equal_approx(Vector3(-2.55, 1.0, -24.75))
			and (dash.mesh as BoxMesh).size.is_equal_approx(Vector3(0.1, 0.05, 0.25)),
			"%s" % [dash.position if dash != null else Vector3.ZERO])
	_check("plan: 10 dashes on that rail", view.get_node("Section2/RailDashesL").get_child_count() == 10)
	var backing: MeshInstance3D = view.get_node_or_null("Section2/Backing") as MeshInstance3D
	var size: Vector3 = (backing.mesh as BoxMesh).size if backing != null else Vector3.ZERO
	_check("plan: its backing is 5 m by 5 m around (0, -22.5), its top at y -0.08", backing != null
			and is_equal_approx(size.x, 5.0) and is_equal_approx(size.z, 5.0) and is_equal_approx(backing.position.x, 0.0)
			and is_equal_approx(backing.position.z, -22.5) and is_equal_approx(backing.position.y + size.y / 2.0, -0.08),
			"%s %s" % [backing.position if backing != null else Vector3.ZERO, size])
	# The rail's line lies outside the deck's edge, on the ground: a dashed line over the plank ends
	# cannot be told from them (trial result).
	_check("plan: both of section 2's rail marks lie outside the deck (beyond x 2.5 and -2.5)", rail != null and dash != null
			and rail.position.x - (rail.mesh as BoxMesh).size.x / 2.0 >= 2.5 - 0.0001
			and dash.position.x + (dash.mesh as BoxMesh).size.x / 2.0 <= -2.5 + 0.0001)
	view.free()


func _test_flat_colours_and_nothing_of_the_night() -> void:
	# AC 7: flat unshaded shapes, no light, no texture, no shader. Not drawn in the plan look: side
	# beams and posts, test weights, the rope across a gap, the piers and the landing.
	var start: StartState = _readout_start()
	start.weights = {1: 3, 5: 1}
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var view: SpanView = _plan_view_of(sim)
	var wrong: PackedStringArray = []
	var seen: Dictionary[String, int] = {"Plank": 0, "Rail": 0, "Dash": 0, "Backing": 0}
	for node: Node in _all_under(view):
		var node_name: String = String(node.name)
		for banned: String in ["Beam", "Post", "Weight", "GapRope", "FarPier", "TownPier", "Landing", "Falling"]:
			if node_name.begins_with(banned):
				wrong.append("%s is drawn" % node.get_path())
		if node is Light3D or node is WorldEnvironment:
			wrong.append("%s is a light or an environment" % node.get_path())
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node == null:
			continue
		var material: StandardMaterial3D = (mesh_node.mesh as BoxMesh).material as StandardMaterial3D
		if material == null or material.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED \
				or material.albedo_texture != null or mesh_node.material_override != null:
			wrong.append("%s is not a plain unshaded colour" % node.get_path())
			continue
		var want: Color = PLANK
		var kind: String = "Plank"
		if node_name.begins_with("Dash"):
			want = DASH
			kind = "Dash"
		elif node_name.begins_with("Rail"):
			want = RAIL
			kind = "Rail"
		elif node_name == "Backing":
			want = ABYSS
			kind = "Backing"
		elif not node_name.begins_with("Plank"):
			wrong.append("%s is not a shape of the plan look" % node.get_path())
			continue
		seen[kind] += 1
		if not material.albedo_color.is_equal_approx(want):
			wrong.append("%s is %s" % [node.get_path(), material.albedo_color.to_html(false)])
	_check("plan: every shape is unshaded in the colour handed in for it, and nothing of the night is drawn",
			wrong.is_empty(), " | ".join(wrong))
	# 18 planks; 9 rail lines (10 rails stand, section 4's two fell with it, section 2's left is
	# stripped: 12 - 2 - 1); 10 + 40 dashes; 5 backings.
	_check("plan: 18 planks, 9 rail lines, 50 dashes and 5 backings were looked at", seen == {"Plank": 18, "Rail": 9,
			"Dash": 50, "Backing": 5}, str(seen))
	view.free()


func _test_reconcile_follows_state() -> void:
	# The plan look reconciles with state like the night look: a second show_span() after the span
	# changed shows the new span, with no event. Driven by commands and ticks from a StartState:
	# section 1 at 5, the warden on it at along 2.5 looking down at its deck (GD-19: strip 2 s = 120
	# ticks, rail 3 s = 180, re-lay 3 s = 180); section 4 at 3 planks under 4 weights groans from
	# tick 0 and falls on tick 120.
	var start: StartState = StartState.new()
	start.planks = {1: 5, 4: 3}
	start.weights = {4: 4}
	start.warden_along = 2.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var view: SpanView = _plan_view_of(sim)
	var section1: SectionView = view.get_node("Section1")
	var section4: SectionView = view.get_node("Section4")
	_check("plan: before any tick, section 4 stands with 3 planks, its backing and two rail lines (no weights)",
			section4.get_child_count() == 6 and _named(section4, "Plank").size() == 3, str(section4.get_children()))
	sim.set_view(0.0, -1.2)
	sim.advance()
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	_advance(sim, 121)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	var names: Array = _named(section1, "Plank").map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("plan: a plank stripped: section 1 shows 4, at places 2 4 6 8", sim.span.planks(1) == 4
			and names == ["Plank2", "Plank4", "Plank6", "Plank8"], str(names))
	_check("plan: section 4 fell meanwhile: its outline only", sim.span.fallen(4) and section4.get_child_count() == 1
			and section4.get_node_or_null("Outline") != null and section4.get_node("Outline").get_child_count() == 40,
			str(section4.get_children()))
	# The rope hand at section 1's right rail: walk into it (x 2.2), face +X, aim at the rope.
	for t: int in 60:
		sim.set_move(Vector2(1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(-PI / 2.0, -1.107)
	sim.advance()
	sim.command(NightCommand.press(NightTypes.HandInput.ROPE))
	_advance(sim, 181)
	_check("plan: until shown again, the view still draws the standing rail", section1.get_node_or_null("RailR") != null)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	_check("plan: a rail stripped: section 1's right line is gone and its dashes are drawn",
			not sim.span.rail_standing(1, RIGHT) and section1.get_node_or_null("RailR") == null
			and _are_boxes(section1.get_node_or_null("RailDashesR"), sim.geometry.plan_rail_dashes(1, RIGHT))
			and section1.get_node_or_null("RailL") != null and section1.get_node_or_null("RailDashesL") == null)
	# Back to the deck: re-lay one.
	sim.set_view(PI / 2.0, -1.2)
	sim.advance()
	sim.command(NightCommand.press(NightTypes.HandInput.USE))
	_advance(sim, 181)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	names = _named(section1, "Plank").map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("plan: a plank re-laid: 5 again, at places 1 2 4 6 8", sim.span.planks(1) == 5
			and names == ["Plank1", "Plank2", "Plank4", "Plank6", "Plank8"], str(names))
	_check("plan: one backing still, and showing the same span twice changes nothing",
			_named(section1, "Backing").size() == 1 and section1.get_child_count() == 8, str(section1.get_children()))
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	_check("plan: shown again: the same 8 nodes", section1.get_child_count() == 8 and section4.get_child_count() == 1)
	_check("plan: driven by commands, no fault", _faults.total() == 0, str(_faults.codes()))
	view.free()


func _test_four_sections() -> void:
	# AC 13 / AD-42: a 4-section def is drawn with no change to any script.
	var start: StartState = StartState.new()
	start.planks = {2: 5}
	start.fallen = [4]
	var sim: NightSim = _sim_with(_def_with(start, 4), 1)
	var view: SpanView = _plan_view_of(sim)
	var sections: int = view.get_children().filter(func(n: Node) -> bool: return n is SectionView).size()
	_check("plan: a 4-section def draws 4 sections and nothing else", sections == 4 and view.get_child_count() == 4,
			str(view.get_children()))
	# Section 1 of 4 is along 0 to 5: z -20 to -15.
	var rail: MeshInstance3D = view.get_node_or_null("Section1/RailL") as MeshInstance3D
	_check("plan: section 1 of 4's left rail line is centred at (-2.6, 1.0, -17.5)", rail != null
			and rail.position.is_equal_approx(Vector3(-2.6, 1.0, -17.5)), str(rail.position) if rail != null else "null")
	_check("plan: its fallen section 4 is the outline", view.get_node("Section4").get_child_count() == 1
			and view.get_node_or_null("Section4/Outline") != null)
	_check("plan: no fault drawing 4 sections", _faults.total() == 0, str(_faults.codes()))
	view.free()


func _test_the_night_look_is_the_default() -> void:
	# show_span() is the way in with no sim (planning now; PlanResult and the dawn's NightResult in
	# epic 5). With no look asked for it draws the night: piers, landing, beams, posts, lit grays.
	var sim: NightSim = _sim_with(_def_with(_readout_start()), 1)
	var view: SpanView = SpanView.new()
	root.add_child(view)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	_check("night look by default: piers, landing, beams and posts; no backing, no dashes",
			view.get_node_or_null("FarPier") != null and view.get_node_or_null("TownPier") != null
			and view.get_node_or_null("Landing") != null and view.get_node_or_null("Section1/BeamL") != null
			and view.get_node_or_null("Section1/PostR2") != null and view.get_node_or_null("Section1/Backing") == null
			and view.get_node_or_null("Section2/RailDashesL") == null and view.get_node_or_null("Section4/Outline") == null
			and view.get_node_or_null("Section4/GapRope") != null)
	var plank: MeshInstance3D = view.get_node("Section1/Plank1") as MeshInstance3D
	var material: StandardMaterial3D = (plank.mesh as BoxMesh).material as StandardMaterial3D
	_check("night look by default: its planks are lit, in the night's own gray",
			material.shading_mode == BaseMaterial3D.SHADING_MODE_PER_PIXEL and material.albedo_color == SpanView.PLANK_COLOR)
	# on_tick() is still build, events, reconcile: the same picture through a tick.
	var ticked: SpanView = SpanView.new()
	root.add_child(ticked)
	ticked.on_tick(sim.advance(), sim)
	_check("night look: show_span() and on_tick() draw the same nodes",
			_all_under(view).map(func(n: Node) -> String: return String(view.get_path_to(n)))
			== _all_under(ticked).map(func(n: Node) -> String: return String(ticked.get_path_to(n))))
	view.free()
	ticked.free()


func _test_the_look_is_chosen_before_the_first_show() -> void:
	# The look decides what is built, so it cannot change afterwards: asked for late, it is a setup
	# problem and the view keeps the look it has.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	var view: SpanView = SpanView.new()
	root.add_child(view)
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	_expect_begin()
	view.use_plan_look(PLANK, RAIL, DASH, ABYSS)
	_expect_end("plan: the plan look asked for after the first show is span_view.late_look", [["WARNING", "span_view.late_look", 1]])
	view.show_span(sim.geometry, sim.span, sim.ticks.groan)
	_check("plan: and the view stays in the night look", view.get_node_or_null("FarPier") != null
			and view.get_node_or_null("Section1/Backing") == null)
	view.free()
