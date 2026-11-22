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


# --- Story 1.5: weights, the bow and the fall (decision D4) ------------------------------------
# GD-19 / GDD Game Mechanics 2: 3 planks under 4 weights groans from tick 0 and falls on tick 120.
# D4 (gray box): creaking bows 5 cm at mid-section; groaning grows to 25 cm as the groan runs out;
# at the fall every piece drops out of sight over 1.5 s and the section then draws only the one
# rope left across its gap (Sonlm's play of story 1.6's M1).

func _weights_of(section: SectionView) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in section.get_children():
		if String(child.name).begins_with("Weight"):
			out.append(child)
	return out


## The children of `parent` whose names begin with `prefix`.
func _named(parent: Node, prefix: String) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in parent.get_children():
		if String(child.name).begins_with(prefix):
			out.append(child)
	return out


func _event(kind: NightEvent.Kind, section: int) -> NightEvent:
	var event: NightEvent = NightEvent.make(kind)
	event.section = section
	return event


func _loaded_sim(planks: Dictionary[int, int], weights: Dictionary[int, int]) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = planks
	start.weights = weights
	return _sim_with(_def_with(start), 1)


func _test_weights_are_drawn_from_geometry() -> void:
	var sim: NightSim = _loaded_sim({}, {3: 4})
	var view: SpanView = _view_of(sim)
	var section3: SectionView = view.get_node("Section3")
	var weights: Array[Node] = _weights_of(section3)
	_check("view: section 3 shows 4 weights", weights.size() == 4, str(weights.size()))
	var ok: bool = true
	for i: int in 4:
		ok = ok and _is_box(section3.get_node_or_null("Weight%d" % (i + 1)), sim.geometry.weight_box(3, i))
	_check("view: each where SpanGeometry puts it (no bow: 4 on 8 planks)", ok)
	_check("view: no other section shows a weight", _weights_of(view.get_node("Section2")).is_empty())
	view.free()


func _test_weight_boxes() -> void:
	# Story 1.5 Dev Notes, "Geometry": 0.5 m cubes on the deck top, inside the section, never within
	# 1.25 m of either end, none overlapping, a layer up when one is full (here 20: three layers).
	var g: SpanGeometry = _sim_with(_def_with(StartState.new()), 1).geometry
	var boxes: Array[AABB] = []
	var ok: bool = true
	for i: int in 20:
		var box: AABB = g.weight_box(4, i)
		ok = ok and box.size.is_equal_approx(Vector3(0.5, 0.5, 0.5)) and box.position.y >= -0.0001
		ok = ok and box.position.x >= -2.5 and box.end.x <= 2.5
		# Section 4 runs along 15 to 20 (z -15 to -10); 1.25 m in from each end is z -13.75 to -11.25.
		ok = ok and box.position.z >= -13.75 - 0.0001 and box.end.z <= -11.25 + 0.0001
		for other: AABB in boxes:
			ok = ok and not other.intersects(box)
		boxes.append(box)
	_check("view: 20 weight boxes inside section 4's middle, on or above the deck, none overlapping", ok)
	_check("view: the first sits mid-section on the deck (x 0, along 17.5)",
			g.weight_box(4, 0).get_center().is_equal_approx(Vector3(0.0, 0.25, -12.5)), str(g.weight_box(4, 0)))
	_check("view: the tenth starts the second layer", is_equal_approx(g.weight_box(4, 9).position.y, 0.5))


func _test_bow_depth_and_sag() -> void:
	_check("view: no bow when neither creaking nor groaning", SectionView.bow_depth(false, 0, 120) == 0.0)
	_check("view: creaking bows 0.05 m", is_equal_approx(SectionView.bow_depth(true, 0, 120), 0.05))
	_check("view: a groan just begun bows 0.05 m", is_equal_approx(SectionView.bow_depth(false, 120, 120), 0.05))
	_check("view: half run out, 0.15 m", is_equal_approx(SectionView.bow_depth(false, 60, 120), 0.15))
	_check("view: its last tick, nearly 0.25 m", is_equal_approx(SectionView.bow_depth(false, 1, 120), 0.05 + 0.2 * 119.0 / 120.0))
	_check("view: the sag is deepest at mid-section and 0 at the ends",
			is_equal_approx(SectionView.plank_sag(0.2, 0.5), 0.2) and SectionView.plank_sag(0.2, 0.0) == 0.0
			and SectionView.plank_sag(0.2, 1.0) == 0.0 and is_equal_approx(SectionView.plank_sag(0.2, 0.25), 0.15))


func _test_the_deck_bows_from_state() -> void:
	# Section 4 creaking (3 on 3): place 4 (u = 3.5 / 8) sits 0.05 x 4u(1 - u) lower than flat.
	var sim: NightSim = _loaded_sim({4: 3}, {4: 3})
	var view: SpanView = _view_of(sim)
	view.on_tick(sim.advance(), sim)
	var plank: Node3D = view.get_node("Section4/Plank4") as Node3D
	var flat: float = sim.geometry.plank_place(4, 4).y
	var u: float = 3.5 / 8.0
	_check("view: a creaking deck bows (place 4 down 0.05 x 4u(1 - u))",
			plank != null and is_equal_approx(plank.position.y, flat - 0.05 * 4.0 * u * (1.0 - u)), str(plank.position.y))
	_check("view: a section with nothing on it is flat", is_equal_approx((view.get_node("Section3/Plank4") as Node3D).position.y, flat))
	# Groaning (3 under 4): after tick 60, 60 of 120 ticks left: bow 0.15.
	sim = _loaded_sim({4: 3}, {4: 4})
	view.free()
	view = _view_of(sim)
	for i: int in 61:
		view.on_tick(sim.advance(), sim)
	plank = view.get_node("Section4/Plank4") as Node3D
	_check("view: a groan half run out bows 0.15 m (from state: groan_left %d)" % sim.span.groan_left(4),
			sim.span.groan_left(4) == 60 and is_equal_approx(plank.position.y, flat - 0.15 * 4.0 * u * (1.0 - u)),
			str(plank.position.y))
	var weight: Node3D = view.get_node("Section4/Weight1") as Node3D
	_check("view: the weights ride the bowed deck (the first, mid-section, down 0.15)",
			is_equal_approx(weight.position.y, sim.geometry.weight_box(4, 0).get_center().y - 0.15), str(weight.position.y))
	view.free()


func _test_the_section_drops_and_is_gone() -> void:
	var sim: NightSim = _loaded_sim({4: 3}, {4: 4})
	var view: SpanView = _view_of(sim)
	for i: int in 120:
		view.on_tick(sim.advance(), sim)
	var section4: SectionView = view.get_node("Section4")
	var pieces: int = section4.get_child_count()
	_check("view: before the fall: 3 planks, 2 rails, 2 beams, 4 posts, 4 weights", pieces == 15, str(pieces))
	var fell: Array[NightEvent] = sim.advance()
	view.on_tick(fell, sim)
	var falling: Node3D = section4.falling()
	_check("view: on SECTION_FELL every piece moves into one dropping group; the gap's rope is the only other node",
			falling != null and falling.get_child_count() == 15 and section4.get_child_count() == 2
			and section4.get_node_or_null("GapRope") != null and falling.get_node_or_null("GapRope") == null,
			str(section4.get_children()))
	section4.fall_step(0.5)
	_check("view: half a second on, it has dropped (y = -1/2 g t^2)", is_equal_approx(falling.position.y, -0.5 * 9.8 * 0.25),
			str(falling.position.y))
	for i: int in 30:
		view.on_tick(sim.advance(), sim)
	# Sonlm's play of story 1.6's M1: a gap shows only the one rope strung across it.
	_check("view: reconciling meanwhile draws only the gap's rope for it", section4.get_child_count() == 2
			and section4.get_node_or_null("GapRope") != null)
	section4.fall_step(1.0)
	_check("view: after 1.5 s the group is freed: the section draws only its rope", section4.falling() == null
			and section4.get_child_count() == 1 and section4.get_node("GapRope").get_child_count() == 10)
	_check("view: its neighbours keep their beams and posts", view.get_node_or_null("Section3/BeamL") != null
			and view.get_node_or_null("Section5/PostR1") != null)
	view.free()


func _test_a_piece_taken_on_the_fall_tick_does_not_fall() -> void:
	# Code review of 2026-11-22: the view handles SECTION_FELL before it reconciles (AD-49), so what
	# left the section earlier in that same tick must leave the picture first. Section 4 (3 planks,
	# 4 weights) groans from tick 0; the warden on section 5 (along 20.4, looking down) strips it
	# from tick 0, and the strip completes in step 2 of tick 120, the tick it falls (step 7): the
	# stripped plank is in the hand and does not drop with the section.
	var start: StartState = StartState.new()
	start.planks = {4: 3}
	start.weights = {4: 4}
	start.warden_along = 20.4
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	var view: SpanView = _view_of(sim)
	for i: int in 120:
		view.on_tick(sim.advance(), sim)
	var section4: SectionView = view.get_node("Section4")
	_check("view: before the fall's tick: 3 planks, 2 rails, 2 beams, 4 posts, 4 weights", section4.get_child_count() == 15,
			str(section4.get_child_count()))
	var fell: Array[NightEvent] = sim.advance()
	view.on_tick(fell, sim)
	_check("view: tick 120 is the strip, then the fall", _kinds(fell) == [NightEvent.Kind.PLANK_STRIPPED,
			NightEvent.Kind.SECTION_FELL] and sim.span.in_hand(NightTypes.Part.PLANK) == 6, str(_kinds(fell)))
	var falling: Node3D = section4.falling()
	_check("view: 14 pieces drop: the plank stripped that tick is not one of them", falling != null
			and falling.get_child_count() == 14 and _named(falling, "Plank").size() == 2, str(falling.get_children()))
	view.free()
	# A weight lifted (step 6) on the tick the section falls: 3 planks under 5 weights, one lifted on
	# tick 120 leaves 4 on 3, so it still falls. Four weights drop, not five.
	start = StartState.new()
	start.planks = {4: 3}
	start.weights = {4: 5}
	start.lifts = [Vector2i(4, 120)]
	sim = _sim_with(_def_with(start), 1)
	view = _view_of(sim)
	for i: int in 120:
		view.on_tick(sim.advance(), sim)
	fell = sim.advance()
	view.on_tick(fell, sim)
	section4 = view.get_node("Section4")
	_check("view: tick 120 is the lift, then the fall", _kinds(fell) == [NightEvent.Kind.WEIGHT_LIFTED,
			NightEvent.Kind.SECTION_FELL], str(_kinds(fell)))
	_check("view: 4 weights drop, the lifted one is not one of them", section4.falling() != null
			and _named(section4.falling(), "Weight").size() == 4 and section4.falling().get_child_count() == 15,
			str(section4.falling().get_children()))
	view.free()


func _test_fall_counts_only_what_came_before_it() -> void:
	# SectionView.fall(events) on its own, with event lists no tick of this story can produce (a rail
	# strip or a re-lay cannot complete on a fall's tick yet; the dead of epic 3 make it possible):
	# only this section's events before its own SECTION_FELL change what drops.
	var sim: NightSim = _loaded_sim({4: 3}, {4: 4})
	var view: SpanView = _view_of(sim)
	var section4: SectionView = view.get_node("Section4")
	var rail: NightEvent = _event(NightEvent.Kind.RAIL_STRIPPED, 4)
	rail.side = LEFT
	section4.fall([_event(NightEvent.Kind.PLANK_STRIPPED, 5), rail, _event(NightEvent.Kind.PLANK_RELAID, 4),
			_event(NightEvent.Kind.SECTION_FELL, 4), _event(NightEvent.Kind.PLANK_STRIPPED, 4)])
	var falling: Node3D = section4.falling()
	_check("view: a rail stripped and a plank re-laid before the fall: 4 planks and the right rail drop",
			_named(falling, "Plank").size() == 4 and _named(falling, "Rail").size() == 1
			and falling.get_node_or_null("RailR") != null, str(falling.get_children()))
	_check("view: section 5's strip, and section 4's after its fall, change nothing: 4 weights, 15 pieces",
			_named(falling, "Weight").size() == 4 and falling.get_child_count() == 15, str(falling.get_child_count()))
	view.free()


func _test_a_section_processes_only_while_it_falls() -> void:
	# The drop is the view's only per-frame work: a section in the tree is idle until SECTION_FELL
	# and again once its pieces are freed.
	var sim: NightSim = _loaded_sim({4: 3}, {4: 4})
	var view: SpanView = _view_of(sim)
	var section4: SectionView = view.get_node("Section4")
	var section3: SectionView = view.get_node("Section3")
	_check("view: in the tree and standing, a section does not process", section4.is_inside_tree()
			and not section4.is_processing() and not section3.is_processing())
	for i: int in 121:
		view.on_tick(sim.advance(), sim)
	_check("view: it processes while it drops; its neighbour does not", section4.falling() != null
			and section4.is_processing() and not section3.is_processing())
	section4.fall_step(1.5)
	_check("view: and stops when the pieces are freed", section4.falling() == null and not section4.is_processing())
	view.free()


func _test_a_fall_not_seen_still_clears() -> void:
	# AD-49: a view that missed SECTION_FELL (made after it) still draws nothing of a fallen section
	# but the rope across its gap.
	var sim: NightSim = _loaded_sim({4: 3}, {4: 4})
	_advance(sim, 130)
	var view: SpanView = _view_of(sim)
	var section4: SectionView = view.get_node("Section4")
	_check("view: a section that fell before the view was made shows only the gap's rope",
			section4.get_child_count() == 1 and section4.get_node_or_null("GapRope") != null and section4.falling() == null,
			str(section4.get_children()))
	_check("view: a section that stands has no gap rope", view.get_node("Section3").get_node_or_null("GapRope") == null)
	# The rope's 10 pieces follow SpanGeometry.gap_rope_points(): each sits between two of its points,
	# is as long as they are apart, and lies along the line between them (code review 2026-11-22:
	# every piece, not the first alone).
	var pts: Array[Vector3] = sim.geometry.gap_rope_points(4)
	var rope: Node = section4.get_node("GapRope")
	var wrong: PackedStringArray = []
	for i: int in mini(rope.get_child_count(), pts.size() - 1):
		var piece: MeshInstance3D = rope.get_child(i) as MeshInstance3D
		var between: Vector3 = pts[i + 1] - pts[i]
		var size: Vector3 = (piece.mesh as BoxMesh).size
		if not piece.position.is_equal_approx((pts[i] + pts[i + 1]) / 2.0) or absf(size.z - between.length()) > 0.0001 \
				or absf(absf(piece.transform.basis.z.dot(between.normalized())) - 1.0) > 0.0001:
			wrong.append("piece %d at %s, %s long" % [i + 1, piece.position, size.z])
	_check("view: each of the rope's 10 pieces sits between two of its points, as long as they are apart, lying along them",
			rope.get_child_count() == 10 and wrong.is_empty(), str(wrong))
	# Literally, for section 4 (along 15 to 20, z -15 to -10): tied 0.1 m under the deck top, sagging
	# 0.4 m at mid-gap as 4u(1 - u). Piece 1 runs from y -0.1 to -0.244: centre (0, -0.172, -14.75).
	# Piece 5 runs from y -0.484 to the lowest point, -0.5: centre (0, -0.492, -12.75).
	var first: Node3D = rope.get_child(0) as Node3D
	var fifth: Node3D = rope.get_child(4) as Node3D
	_check("view: the rope's first piece is centred at (0, -0.172, -14.75), its fifth at (0, -0.492, -12.75)",
			first.position.distance_to(Vector3(0.0, -0.172, -14.75)) < 0.0001
			and fifth.position.distance_to(Vector3(0.0, -0.492, -12.75)) < 0.0001, "%s %s" % [first.position, fifth.position])
	view.free()
