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
	_check("geometry: eye height 1.6", is_equal_approx(SpanGeometry.EYE_HEIGHT, 1.6))


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
