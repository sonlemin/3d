## SpanGeometry (AD-42, AD-62, architecture "The span's numbers", decision D2). Every expected
## number is written literally: the GDD's where it gives one, D2's gray-box sizes otherwise.
extends WatchTest

const LEFT: NightTypes.Side = NightTypes.Side.LEFT
const RIGHT: NightTypes.Side = NightTypes.Side.RIGHT


func _geometry(sections: int = 6) -> SpanGeometry:
	return _sim_with(_def_with(StartState.new(), sections), 1).geometry


func _aabb_is(box: AABB, from: Vector3, to: Vector3) -> bool:
	return box.position.is_equal_approx(from) and box.end.is_equal_approx(to)


func _test_sections_along() -> void:
	var g: SpanGeometry = _geometry()
	var ok: bool = true
	for n: int in range(1, 7):
		ok = ok and is_equal_approx(g.section_start(n), (n - 1) * 5.0) and is_equal_approx(g.section_end(n), n * 5.0)
	_check("geometry: section n covers along (n - 1) x 5 to n x 5", ok)
	_check("geometry: length 30", is_equal_approx(g.length(), 30.0))


func _test_world_z() -> void:
	var g: SpanGeometry = _geometry()
	_check("geometry: the town pier's edge (along 30) is z 0", is_equal_approx(g.world_z(30.0), 0.0))
	_check("geometry: the far pier's edge (along 0) is z -30", is_equal_approx(g.world_z(0.0), -30.0))


func _test_left_is_minus_x() -> void:
	var g: SpanGeometry = _geometry()
	var left: AABB = g.rail_box(1, LEFT)
	var right: AABB = g.rail_box(1, RIGHT)
	_check("geometry: LEFT is -X", left.get_center().x < 0.0 and right.get_center().x > 0.0,
			"%s %s" % [left.get_center(), right.get_center()])


func _test_deck_and_planks() -> void:
	var g: SpanGeometry = _geometry()
	_check("geometry: deck of section 2 is 5 x 0.08 at y 0, along 5 to 10",
			_aabb_is(g.deck_box(2), Vector3(-2.5, -0.08, -25.0), Vector3(2.5, 0.0, -20.0)), str(g.deck_box(2)))
	_check("geometry: a plank is 5.0 x 0.08 x 0.5", g.plank_size().is_equal_approx(Vector3(5.0, 0.08, 0.5)))


func _test_rails_beams_posts() -> void:
	var g: SpanGeometry = _geometry()
	# D2: rope 0.05 thick at 1.0 m along the side edge, end to end of the section.
	_check("geometry: section 1 left rail", _aabb_is(g.rail_box(1, LEFT),
			Vector3(-2.525, 0.975, -30.0), Vector3(-2.475, 1.025, -25.0)), str(g.rail_box(1, LEFT)))
	# D2: beam 0.25 wide x 0.3 deep under the plank ends.
	_check("geometry: section 1 right beam", _aabb_is(g.side_beam_box(1, RIGHT),
			Vector3(2.25, -0.38, -30.0), Vector3(2.5, -0.08, -25.0)), str(g.side_beam_box(1, RIGHT)))
	var posts: Array[AABB] = g.rail_posts(1, LEFT)
	_check("geometry: two posts per rail, 0.1 x 1.1 at each section end", posts.size() == 2
			and _aabb_is(posts[0], Vector3(-2.55, 0.0, -30.0), Vector3(-2.45, 1.1, -29.9))
			and _aabb_is(posts[1], Vector3(-2.55, 0.0, -25.1), Vector3(-2.45, 1.1, -25.0)), str(posts))


func _test_piers_landing_start() -> void:
	var g: SpanGeometry = _geometry()
	# D2: far pier 7 x 4, along -4 to 0, 20 m below to 3 m above the deck.
	_check("geometry: far pier", _aabb_is(g.far_pier_box(), Vector3(-3.5, -2.0, -34.0), Vector3(3.5, 3.0, -30.0)),
			str(g.far_pier_box()))
	# D2: town pier 7 x 4, along 30 to 34, 20 m below up to the deck.
	_check("geometry: town pier", _aabb_is(g.town_pier_box(), Vector3(-3.5, -2.0, 0.0), Vector3(3.5, 0.0, 4.0)),
			str(g.town_pier_box()))
	# D2: the landing, 5 x 4 at deck level, the town pier's walkable top.
	_check("geometry: landing", _aabb_is(g.landing_box(), Vector3(-2.5, 0.0, 0.0), Vector3(2.5, 0.0, 4.0)),
			str(g.landing_box()))
	_check("geometry: the warden starts at the landing's centre (along 32)",
			g.warden_start().is_equal_approx(Vector3(0.0, 0.0, 2.0)), str(g.warden_start()))


func _test_four_sections() -> void:
	# AD-42: no literal 6 or 30; a 4-section def is 20 m and its landing starts at along 20.
	var g: SpanGeometry = _geometry(4)
	_check("geometry: 4 sections are 20 m", is_equal_approx(g.length(), 20.0))
	_check("geometry: the 4-section landing starts at along 20 (z 0)",
			_aabb_is(g.landing_box(), Vector3(-2.5, 0.0, 0.0), Vector3(2.5, 0.0, 4.0)))
	_check("geometry: section 1 of 4 starts at z -20", is_equal_approx(g.world_z(g.section_start(1)), -20.0))
	_check("geometry: no fault on 4 sections", _faults.total() == 0, str(_faults.codes()))


func _test_other_plank_count_falls_back() -> void:
	# Only 8 planks per section is used; anything else reports once and keeps the first places.
	var def: NightDef = _def_with(StartState.new())
	def.planks_per_section = 6
	_expect_begin()
	var sim: NightSim = _sim_with(def, 1)
	_expect_end("geometry: 6 planks per section is span.plank_order, once", [["ERROR", "span.plank_order", 1]])
	_check("geometry: the fallback keeps the first places", sim.geometry.places_kept(4) == [1, 2, 3, 4],
			str(sim.geometry.places_kept(4)))
	_check("geometry: reported once only", _faults.count(&"span.plank_order") == 1)


func _test_the_moves_of_story_1_6() -> void:
	# Story 1.6 D2: the beam line is the standable band's edge, the 5 m deck less the 0.3 m clearance
	# (story 1.3 D1): x -2.2 on the left, 2.2 on the right. A move over section n toward the town (+1)
	# runs from its far-pier end (along (n - 1) x 5) to its town end (n x 5); toward the far pier (-1)
	# the other way. A crossing hangs 2.4 m below the deck under the gap's rope, on the centre line
	# (x 0; Sonlm's play of M1). A move ends on the next floor, 0.3 m in.
	var g: SpanGeometry = _geometry()
	_check("moves: the beam lines are x -2.2 (left) and 2.2 (right)", is_equal_approx(g.beam_line_x(LEFT), -2.2)
			and is_equal_approx(g.beam_line_x(RIGHT), 2.2), "%f %f" % [g.beam_line_x(LEFT), g.beam_line_x(RIGHT)])
	_check("moves: section 3's near and far edges toward the far pier are along 15 and 10",
			is_equal_approx(g.near_edge(3, -1), 15.0) and is_equal_approx(g.far_edge(3, -1), 10.0))
	_check("moves: and toward the town 10 and 15", is_equal_approx(g.near_edge(3, 1), 10.0)
			and is_equal_approx(g.far_edge(3, 1), 15.0))
	# L2: the edging of section 3 toward the far pier ends at (2.2, 0, -20.0), and steps off at
	# (2.2, 0, -20.3); toward the town (2.2, 0, -15.0), off at (2.2, 0, -14.7).
	_check("moves: an edging point on the right beam at along 10: (2.2, 0, -20)",
			g.edging_point(RIGHT, 10.0).is_equal_approx(Vector3(2.2, 0.0, -20.0)), str(g.edging_point(RIGHT, 10.0)))
	_check("moves: on the left beam at along 15: (-2.2, 0, -15)",
			g.edging_point(LEFT, 15.0).is_equal_approx(Vector3(-2.2, 0.0, -15.0)), str(g.edging_point(LEFT, 15.0)))
	# Sonlm's play of M1 (2026-11-22): a crossing hangs under the gap's one rope, on the centre line,
	# the feet 2.4 m below deck level.
	_check("moves: a crossing point at along 15: (0, -2.4, -15)",
			g.crossing_point(15.0).is_equal_approx(Vector3(0.0, -2.4, -15.0)), str(g.crossing_point(15.0)))
	_check("moves: at along 12.5: (0, -2.4, -17.5)", g.crossing_point(12.5).is_equal_approx(Vector3(0.0, -2.4, -17.5)),
			str(g.crossing_point(12.5)))
	var ends: Dictionary[String, Array] = {
		"section 3 toward the far pier, x 2.2": [g.move_end(3, -1, 2.2), Vector3(2.2, 0.0, -20.3)],
		"section 3 toward the town, x 2.2": [g.move_end(3, 1, 2.2), Vector3(2.2, 0.0, -14.7)],
		"section 3 toward the far pier, x 0": [g.move_end(3, -1, 0.0), Vector3(0.0, 0.0, -20.3)],
		"section 6 toward the town (the landing), x 2.2": [g.move_end(6, 1, 2.2), Vector3(2.2, 0.0, 0.3)],
		"section 2 toward the far pier, x -2.4 (kept in)": [g.move_end(2, -1, -2.4), Vector3(-2.2, 0.0, -25.3)],
	}
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	for what: String in ends:
		var got: Vector3 = ends[what][0]
		_check("moves: a move over %s ends at %s" % [what, ends[what][1]], got.is_equal_approx(ends[what][1]), str(got))
		_check("moves: which can be stood on (%s)" % what, WardenRules.can_stand(got, sim))


func _test_the_rope_across_a_gap() -> void:
	# Sonlm's play of M1 (2026-11-22): one rope stays strung across a fallen section, on its centre
	# line, from 0.1 m under the deck top at each end, sagging 0.4 m at mid-gap (a parabola), drawn as
	# 10 straight pieces (11 points). Gray box; no rule but the crossing uses it.
	var g: SpanGeometry = _geometry()
	var points: Array[Vector3] = g.gap_rope_points(3)
	_check("rope: 11 points", points.size() == 11, str(points.size()))
	if points.size() != 11:
		return
	_check("rope: from (0, -0.1, -20) to (0, -0.1, -15)", points[0].is_equal_approx(Vector3(0.0, -0.1, -20.0))
			and points[10].is_equal_approx(Vector3(0.0, -0.1, -15.0)), "%s %s" % [points[0], points[10]])
	_check("rope: lowest at mid-gap, (0, -0.5, -17.5)", points[5].is_equal_approx(Vector3(0.0, -0.5, -17.5)), str(points[5]))
	# u = 0.2: -0.1 - 0.4 x 4 x 0.2 x 0.8 = -0.356.
	_check("rope: a fifth of the way, (0, -0.356, -19)", points[2].is_equal_approx(Vector3(0.0, -0.356, -19.0)), str(points[2]))
	# The crossing's eye (1.6 m above the feet) is always under the rope.
	_check("rope: the crossing eye (-0.8) is 0.3 m under its lowest point", is_equal_approx(g.crossing_point(17.5).y + 1.6,
			points[5].y - 0.3), str(g.crossing_point(17.5)))



# --- Story 1.7: the plan look's shapes (Dev Notes "Plan shapes"; plan-view sizes, not rules) ------
# A standing rail's line is 0.2 m across, its inner edge on the deck's edge (x 2.5 or -2.5) and the
# rest outside it, and stops 0.15 m short of each end of its section (decision D3: a joint shows as
# a break). A dashed line is 0.1 m across, in dashes of 0.25 m every 0.5 m, centred in each step
# (the first starts 0.125 m in). Section 2 of 6 is along 5 to 10: z -25 to -20. The two widths are
# Sonlm's M1 (2026-11-27, option C: 0.12 and 0.05 were too thin to read on the laptop).

func _test_plan_backing() -> void:
	var g: SpanGeometry = _geometry()
	var backing: AABB = g.plan_backing_box(2)
	_check("plan: section 2's backing is the deck's footprint (x -2.5 to 2.5, z -25 to -20)",
			is_equal_approx(backing.position.x, -2.5) and is_equal_approx(backing.end.x, 2.5)
			and is_equal_approx(backing.position.z, -25.0) and is_equal_approx(backing.end.z, -20.0), str(backing))
	# A plank is 0.08 m thick under the deck top (y 0): the backing lies wholly under the planks.
	_check("plan: its top is the planks' underside (y -0.08), and it has some thickness",
			is_equal_approx(backing.end.y, -0.08) and backing.size.y > 0.0, str(backing))


func _test_plan_rail_line() -> void:
	var g: SpanGeometry = _geometry()
	# At the rope's height (1.0 m, 0.05 thick), so it lies over the planks seen from above.
	_check("plan: section 2's right rail line is x 2.5 to 2.7, z -24.85 to -20.15, at the rope's height",
			_aabb_is(g.plan_rail_box(2, RIGHT), Vector3(2.5, 0.975, -24.85), Vector3(2.7, 1.025, -20.15)),
			str(g.plan_rail_box(2, RIGHT)))
	_check("plan: its left rail line is x -2.7 to -2.5",
			_aabb_is(g.plan_rail_box(2, LEFT), Vector3(-2.7, 0.975, -24.85), Vector3(-2.5, 1.025, -20.15)),
			str(g.plan_rail_box(2, LEFT)))
	# D3: two neighbours' lines are 0.3 m apart at their joint.
	_check("plan: section 3's line starts 0.3 m after section 2's ends",
			is_equal_approx(g.plan_rail_box(3, RIGHT).position.z - g.plan_rail_box(2, RIGHT).end.z, 0.3))
	var short: SpanGeometry = _geometry(4)
	_check("plan: section 1 of 4's right rail line is z -19.85 to -15.15",
			_aabb_is(short.plan_rail_box(1, RIGHT), Vector3(2.5, 0.975, -19.85), Vector3(2.7, 1.025, -15.15)),
			str(short.plan_rail_box(1, RIGHT)))


func _test_plan_rail_dashes() -> void:
	var g: SpanGeometry = _geometry()
	var dashes: Array[AABB] = g.plan_rail_dashes(2, LEFT)
	_check("plan: a stripped rail is 10 dashes on a 5 m section", dashes.size() == 10, str(dashes.size()))
	if dashes.size() != 10:
		return
	_check("plan: section 2's left dashes: the first is x -2.6 to -2.5, z -24.875 to -24.625, at the rope's height",
			_aabb_is(dashes[0], Vector3(-2.6, 0.975, -24.875), Vector3(-2.5, 1.025, -24.625)), str(dashes[0]))
	_check("plan: the last is z -20.375 to -20.125", _aabb_is(dashes[9], Vector3(-2.6, 0.975, -20.375),
			Vector3(-2.5, 1.025, -20.125)), str(dashes[9]))
	var ok: bool = true
	for i: int in dashes.size():
		ok = ok and is_equal_approx(dashes[i].size.z, 0.25) and is_equal_approx(dashes[i].size.x, 0.1) \
				and is_equal_approx(dashes[i].position.z, -24.875 + 0.5 * i)
	_check("plan: every dash is 0.25 m long and 0.1 m across, one every 0.5 m", ok, str(dashes))
	var right: Array[AABB] = g.plan_rail_dashes(2, RIGHT)
	_check("plan: the right rail's dashes are x 2.5 to 2.6, outside the deck's edge", right.size() == 10
			and _aabb_is(right[0], Vector3(2.5, 0.975, -24.875), Vector3(2.6, 1.025, -24.625)), str(right))


func _test_plan_outline() -> void:
	# A fallen section's outline: the four edges of the deck's footprint, each dashed as above, the
	# line centred on the edge, its top at the deck's top (y 0). Section 4 is along 15 to 20: z -15
	# to -10. Order: the right (+X) edge, the left edge, the far-pier end, the town end.
	var g: SpanGeometry = _geometry()
	var dashes: Array[AABB] = g.plan_outline_dashes(4)
	_check("plan: a fallen section's outline is 40 dashes (10 an edge)", dashes.size() == 40, str(dashes.size()))
	if dashes.size() != 40:
		return
	var ok: bool = true
	for i: int in 10:
		ok = ok and _aabb_is(dashes[i], Vector3(2.45, -0.1, -14.875 + 0.5 * i), Vector3(2.55, 0.0, -14.625 + 0.5 * i))
	_check("plan: the +X edge's dashes are x 2.45 to 2.55, from z -14.875, top at y 0", ok, str(dashes.slice(0, 10)))
	ok = true
	for i: int in 10:
		ok = ok and _aabb_is(dashes[10 + i], Vector3(-2.55, -0.1, -14.875 + 0.5 * i), Vector3(-2.45, 0.0, -14.625 + 0.5 * i))
	_check("plan: the -X edge's are x -2.55 to -2.45", ok, str(dashes.slice(10, 20)))
	ok = true
	for i: int in 10:
		ok = ok and _aabb_is(dashes[20 + i], Vector3(-2.375 + 0.5 * i, -0.1, -15.05), Vector3(-2.125 + 0.5 * i, 0.0, -14.95))
	_check("plan: the far-pier end's are z -15.05 to -14.95, from x -2.375", ok, str(dashes.slice(20, 30)))
	ok = true
	for i: int in 10:
		ok = ok and _aabb_is(dashes[30 + i], Vector3(-2.375 + 0.5 * i, -0.1, -10.05), Vector3(-2.125 + 0.5 * i, 0.0, -9.95))
	_check("plan: the town end's are z -10.05 to -9.95", ok, str(dashes.slice(30, 40)))
	_check("plan: the plan shapes report no fault", _faults.total() == 0, str(_faults.codes()))
