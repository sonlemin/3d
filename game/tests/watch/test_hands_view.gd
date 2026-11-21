## The forearm (UX-11, story 1.4 decision D2; HandsView): tallies in fives, two rows each with its
## sign, shown only while the sim says the forearm is raised, redrawn when the hand's counts change.
## Driven by commands and ticks on a sim, never by writing sim fields. What it looks like is M2.
extends WatchTest

const FOREARM: NightTypes.HandInput = NightTypes.HandInput.FOREARM


func _view(sim: NightSim) -> HandsView:
	var view: HandsView = HandsView.new()
	root.add_child(view)
	view.on_tick([], sim)
	return view


func _strokes_in(view: HandsView, holder: String) -> int:
	return view.get_node(holder).get_child_count()


func _test_strokes_layout() -> void:
	_check("forearm: strokes(0) is empty", HandsView.strokes(0).is_empty())
	var five: Array[HandsView.Stroke] = HandsView.strokes(5)
	var upright: int = five.filter(func(s: HandsView.Stroke) -> bool: return not s.across).size()
	_check("forearm: strokes(5) is four upright and one across", five.size() == 5 and upright == 4 and five[4].across)
	var xs: Array = five.map(func(s: HandsView.Stroke) -> float: return s.x)
	_check("forearm: the one across lies over the four (between the first and the last)",
			five[4].x > five[0].x and five[4].x < five[3].x, str(xs))
	var twelve: Array[HandsView.Stroke] = HandsView.strokes(12)
	var across: int = twelve.filter(func(s: HandsView.Stroke) -> bool: return s.across).size()
	_check("forearm: strokes(12) is two fives and two", twelve.size() == 12 and across == 2
			and not twelve[10].across and not twelve[11].across and twelve[10].x > twelve[9].x)
	var all: Array[HandsView.Stroke] = HandsView.strokes(48)
	var rows: Dictionary[int, bool] = {}
	for s: HandsView.Stroke in all:
		rows[s.row] = true
	# 5 groups of five to a row: 48 is 25 + 23, two rows.
	_check("forearm: strokes(48) wraps to two rows", rows.keys() == [0, 1] and all[24].row == 0 and all[25].row == 1,
			str(rows.keys()))
	_check("forearm: a new row starts at the row's start", is_equal_approx(all[25].x, all[0].x))
	_check("forearm: rows_for 0, 25, 26, 48 is 1, 1, 2, 2", HandsView.rows_for(0) == 1 and HandsView.rows_for(25) == 1
			and HandsView.rows_for(26) == 2 and HandsView.rows_for(48) == 2)


func _test_shown_only_while_raised() -> void:
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	var view: HandsView = _view(sim)
	view.on_tick(sim.advance(), sim)
	_check("forearm: hidden while down", not view.visible)
	sim.command(NightCommand.press(FOREARM))
	view.on_tick(sim.advance(), sim)
	_check("forearm: shown once raised (a Tab press)", view.visible)
	sim.command(NightCommand.release(FOREARM))
	view.on_tick(sim.advance(), sim)
	_check("forearm: hidden again on its release", not view.visible)
	view.free()


func _test_counts_and_signs() -> void:
	# M2's numbers: 12 planks (section 1 bare, section 2 at 4) and 3 ropes.
	var start: StartState = StartState.new()
	start.planks = {1: 0, 2: 4}
	start.stripped_rails = [Vector2i(1, NightTypes.Side.LEFT), Vector2i(1, NightTypes.Side.RIGHT),
			Vector2i(2, NightTypes.Side.LEFT)]
	var sim: NightSim = _sim_with(_def_with(start), 1)
	var view: HandsView = _view(sim)
	_check("forearm: 12 plank strokes and 3 rope strokes",
			_strokes_in(view, "PlankStrokes") == 12 and _strokes_in(view, "RopeStrokes") == 3,
			"%d %d" % [_strokes_in(view, "PlankStrokes"), _strokes_in(view, "RopeStrokes")])
	var bar: MeshInstance3D = view.get_node_or_null("PlankSign") as MeshInstance3D
	var ring: MeshInstance3D = view.get_node_or_null("RopeSign") as MeshInstance3D
	_check("forearm: D2, the plank row has its filled bar, the rope row its ring",
			bar != null and bar.mesh is BoxMesh and ring != null and ring.mesh is TorusMesh)
	_check("forearm: the plank sign is above the rope sign", bar != null and ring != null and bar.position.y > ring.position.y)
	var first_plank: Node3D = view.get_node("PlankStrokes").get_child(0) as Node3D
	var first_rope: Node3D = view.get_node("RopeStrokes").get_child(0) as Node3D
	_check("forearm: planks on the upper row, ropes below", first_plank.position.y > first_rope.position.y
			and is_equal_approx(first_plank.position.y, bar.position.y) and is_equal_approx(first_rope.position.y, ring.position.y))
	view.free()


func _test_redrawn_when_the_hand_changes() -> void:
	# A strip through the sim (GD-19: 2 s = 120 ticks) adds one plank stroke; nothing else does.
	var start: StartState = StartState.new()
	start.warden_along = 17.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, -1.2)
	var view: HandsView = _view(sim)
	view.on_tick(sim.advance(), sim)
	_check("forearm: nothing in hand, no strokes", _strokes_in(view, "PlankStrokes") == 0 and _strokes_in(view, "RopeStrokes") == 0)
	var first: Node = view.get_node("Skin")
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	for i: int in 121:
		view.on_tick(sim.advance(), sim)
	_check("forearm: after a strip, one plank stroke", _strokes_in(view, "PlankStrokes") == 1 and sim.span.in_hand(NightTypes.Part.PLANK) == 1)
	var stroke: Node = view.get_node("PlankStrokes").get_child(0)
	view.on_tick(sim.advance(), sim)
	_check("forearm: not rebuilt while the counts stand", view.get_node("PlankStrokes").get_child(0) == stroke
			and view.get_node("Skin") == first)
	view.free()


func _test_drawn_over_the_world() -> void:
	# EXPERIENCE.md: readable with no lantern lit (unshaded) and never cut by a rail (no depth test),
	# ink over skin. Whether it reads is M2.
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	var view: HandsView = _view(sim)
	var skin: StandardMaterial3D = ((view.get_node("Skin") as MeshInstance3D).mesh as BoxMesh).material as StandardMaterial3D
	var ink: StandardMaterial3D = ((view.get_node("PlankSign") as MeshInstance3D).mesh as BoxMesh).material as StandardMaterial3D
	_check("forearm: skin and ink unshaded, not depth tested",
			skin.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED and ink.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
			and skin.no_depth_test and ink.no_depth_test)
	_check("forearm: ink drawn after the skin", ink.render_priority > skin.render_priority)
	_check("forearm: in front of the eye, below centre", view.position.z < 0.0 and view.position.y < 0.0)
	view.free()
