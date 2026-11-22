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

