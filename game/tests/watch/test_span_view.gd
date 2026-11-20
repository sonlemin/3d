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
	# The view reconciles with state every tick: after the ledger moves parts, the next tick
	# shows the new count with no event telling it.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	var view: SpanView = _view_of(sim)
	SpanRules.move_parts(NightTypes.Part.PLANK, 4, PartPlace.deck(1), PartPlace.hand(), sim)
	SpanRules.move_parts(NightTypes.Part.ROPE, 1, PartPlace.rail(1, RIGHT), PartPlace.hand(), sim)
	view.on_tick(sim.advance(), sim)
	var section1: SectionView = view.get_node("Section1")
	var names: Array = _planks_of(section1).map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("view: 4 planks left on section 1, at places 2 4 6 8", names == ["Plank2", "Plank4", "Plank6", "Plank8"], str(names))
	_check("view: section 1's right rail is gone", section1.get_node_or_null("RailR") == null)
	SpanRules.move_parts(NightTypes.Part.PLANK, 2, PartPlace.hand(), PartPlace.deck(1), sim)
	SpanRules.move_parts(NightTypes.Part.ROPE, 1, PartPlace.hand(), PartPlace.rail(1, RIGHT), sim)
	view.on_tick(sim.advance(), sim)
	names = _planks_of(section1).map(func(n: Node) -> String: return String(n.name))
	names.sort()
	_check("view: re-laid to 6, at places 1 2 4 5 6 8",
			names == ["Plank1", "Plank2", "Plank4", "Plank5", "Plank6", "Plank8"], str(names))
	_check("view: the rail is back", section1.get_node_or_null("RailR") != null)
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
