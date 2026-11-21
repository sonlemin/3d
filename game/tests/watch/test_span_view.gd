## The span view (AD-49, AD-62): every box placed by asking SpanGeometry, the planks drawn to
## the count, reconciled with state every tick. Runs synchronously under `root`; positions are
## compared with `position` (the view sits at the origin), never `global_position`.
extends WatchTest

const LEFT: NightTypes.Side = NightTypes.Side.LEFT
const RIGHT: NightTypes.Side = NightTypes.Side.RIGHT


func _view_of(sim: NightSim) -> SpanView:
	var view: SpanView = SpanView.new()
	root.add_child(view)
	view.on_tick([], sim)
	return view


## True when `node` is a MeshInstance3D box at `box`'s centre with `box`'s size.
func _is_box(node: Node, box: AABB) -> bool:
	var mesh_node: MeshInstance3D = node as MeshInstance3D
	if mesh_node == null or not (mesh_node.mesh is BoxMesh):
		return false
	return mesh_node.position.is_equal_approx(box.get_center()) \
			and (mesh_node.mesh as BoxMesh).size.is_equal_approx(box.size)


func _planks_of(section: SectionView) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in section.get_children():
		if String(child.name).begins_with("Plank"):
			out.append(child)
	return out


func _test_stripped_start_is_drawn_from_geometry() -> void:
	var start: StartState = StartState.new()
	start.planks = {3: 5}
	start.stripped_rails = [Vector2i(2, LEFT)]
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var g: SpanGeometry = sim.geometry
	var view: SpanView = _view_of(sim)

	_check("view: far pier, town pier and landing from SpanGeometry",
			_is_box(view.get_node("FarPier"), g.far_pier_box()) and _is_box(view.get_node("TownPier"), g.town_pier_box())
			and view.get_node("Landing") is MeshInstance3D
			and (view.get_node("Landing") as Node3D).position.x == g.landing_box().get_center().x
			and is_equal_approx((view.get_node("Landing") as Node3D).position.z, g.landing_box().get_center().z))
	# The landing is a surface in SpanGeometry; the view draws it as a thin slab on the pier's top.
	var landing: MeshInstance3D = view.get_node("Landing") as MeshInstance3D
	var slab: Vector3 = (landing.mesh as BoxMesh).size if landing != null and landing.mesh is BoxMesh else Vector3.ZERO
	_check("view: the landing is as wide and long as SpanGeometry's, and a thin slab high",
			is_equal_approx(slab.x, g.landing_box().size.x) and is_equal_approx(slab.z, g.landing_box().size.z)
			and is_equal_approx(slab.y, SpanView.LANDING_MARK_THICKNESS), str(slab))
	_check("view: the landing's slab starts at SpanGeometry's height, the deck level",
			landing != null and is_equal_approx(landing.position.y - slab.y / 2.0, g.landing_box().position.y),
			str(landing.position.y) if landing != null else "null")
	_check("view: 6 sections drawn", view.get_children().filter(func(n: Node) -> bool: return n is SectionView).size() == 6)

	var section3: SectionView = view.get_node("Section3")
	var planks: Array[Node] = _planks_of(section3)
	_check("view: section 3 shows exactly 5 planks", planks.size() == 5, str(planks.size()))
	var ok: bool = true
	var places: Array[Vector3] = g.plank_places(3, 5)
	var kept: Array[int] = g.places_kept(5)
	for i: int in kept.size():
		var plank: MeshInstance3D = section3.get_node_or_null("Plank%d" % kept[i])
		ok = ok and plank != null and plank.position.is_equal_approx(places[i]) \
				and (plank.mesh as BoxMesh).size.is_equal_approx(g.plank_size())
	_check("view: each of section 3's planks is where SpanGeometry puts it for a count of 5", ok)

	ok = true
	for n: int in range(1, 7):
		var section: SectionView = view.get_node("Section%d" % n)
		ok = ok and _planks_of(section).size() == (5 if n == 3 else 8)
		for side: NightTypes.Side in [LEFT, RIGHT]:
			var tag: String = "L" if side == LEFT else "R"
			ok = ok and _is_box(section.get_node("Beam" + tag), g.side_beam_box(n, side))
			var posts: Array[AABB] = g.rail_posts(n, side)
			ok = ok and _is_box(section.get_node("Post%s1" % tag), posts[0]) \
					and _is_box(section.get_node("Post%s2" % tag), posts[1])
			var rail: Node = section.get_node_or_null("Rail" + tag)
			if n == 2 and side == LEFT:
				ok = ok and rail == null
			else:
				ok = ok and rail != null and _is_box(rail, g.rail_box(n, side))
	_check("view: beams and posts always, rails where standing (none on s2 left), from SpanGeometry", ok)
	view.free()


func _test_reconcile_follows_state() -> void:
	# The view reconciles with state every tick: after a strip or a re-lay completes, the next
	# on_tick shows the new count with no event telling it (DW-27: driven by commands and ticks
	# from a StartState, never by moving parts directly). Section 1 at 5 (3 in hand), the warden
	# on it at along 2.5 looking down at its deck (GD-19: strip 2 s = 120 ticks, re-lay 3 s = 180).
	var start: StartState = StartState.new()
	start.planks = {1: 5}
	start.warden_along = 2.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var view: SpanView = _view_of(sim)
	sim.set_view(0.0, -1.2)
	view.on_tick(sim.advance(), sim)
	var section1: SectionView = view.get_node("Section1")
	for i: int in 2:
		sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
		for t: int in 121:
			view.on_tick(sim.advance(), sim)
	var names: Array = _planks_of(section1).map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("view: two strips, 3 planks left on section 1, at places 2 4 6", sim.span.planks(1) == 3
			and names == ["Plank2", "Plank4", "Plank6"], str(names))
	# The rope hand at section 1's right rail: walk into it (x 2.2), face +X, aim at the rope.
	for t: int in 60:
		sim.set_move(Vector2(1.0, 0.0))
		view.on_tick(sim.advance(), sim)
	sim.set_move(Vector2.ZERO)
	sim.set_view(-PI / 2.0, -1.107)
	view.on_tick(sim.advance(), sim)
	sim.command(NightCommand.press(NightTypes.HandInput.ROPE))
	for t: int in 181:
		view.on_tick(sim.advance(), sim)
	_check("view: section 1's right rail is gone", not sim.span.rail_standing(1, RIGHT)
			and section1.get_node_or_null("RailR") == null)
	# Back to the deck: re-lay two.
	sim.set_view(PI / 2.0, -1.2)
	view.on_tick(sim.advance(), sim)
	for i: int in 2:
		sim.command(NightCommand.press(NightTypes.HandInput.USE))
		for t: int in 181:
			view.on_tick(sim.advance(), sim)
	names = _planks_of(section1).map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("view: re-laid to 5, at places 1 2 4 6 8", sim.span.planks(1) == 5
			and names == ["Plank1", "Plank2", "Plank4", "Plank6", "Plank8"], str(names))
	_check("view: driven by commands, no fault", _faults.total() == 0, str(_faults.codes()))
	view.free()


func _test_four_sections_drawn() -> void:
	var sim: NightSim = _sim_with(_def_with(StartState.new(), 4), 1)
	var view: SpanView = _view_of(sim)
	var sections: int = view.get_children().filter(func(n: Node) -> bool: return n is SectionView).size()
	_check("view: a 4-section def draws 4 sections", sections == 4, str(sections))
	# The landing starts at along 20, which is z 0.
	_check("view: the 4-section landing is where SpanGeometry puts it",
			is_equal_approx((view.get_node("Landing") as Node3D).position.z, 2.0)
			and _is_box(view.get_node("TownPier"), sim.geometry.town_pier_box()))
	_check("view: no fault drawing 4 sections", _faults.total() == 0, str(_faults.codes()))
	view.free()
