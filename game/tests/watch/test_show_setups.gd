## Show-me setups (AD-56): each puts Sonlm in exactly the situation of a manual check.
extends WatchTest


func _test_span_counts_exists() -> void:
	_check("show: span_counts is a show-me setup", ShowSetups.names().has("span_counts"), str(ShowSetups.names()))
	_check("show: an unknown name gives no def", ShowSetups.def_of(&"no_such_show") == null)


func _test_span_counts_def() -> void:
	var def: NightDef = ShowSetups.def_of(&"span_counts")
	var sim: NightSim = _sim_with(def, 1)
	var counts: Array[int] = []
	for n: int in range(1, sim.span.section_count() + 1):
		counts.append(sim.span.planks(n))
	# M1: sections at 8, 5, 4, 1 and 0 planks; section 6 (nearest the landing) stays full.
	_check("show: span_counts has sections at 8 0 1 4 5 8", counts == [8, 0, 1, 4, 5, 8], str(counts))
	_check("show: building span_counts reports no fault", _faults.total() == 0, str(_faults.codes()))
	_check("show: the parts it takes are in hand (48 - 26 = 22)", sim.span.in_hand(NightTypes.Part.PLANK) == 22,
			str(sim.span.in_hand(NightTypes.Part.PLANK)))


func _test_debug_tools_list() -> void:
	var tools: DebugTools = DebugTools.new()
	_check("show: the debug tools list span_counts, walk, walk_close, strip, forearm, overload and fall_under",
			tools.show_names() == PackedStringArray(["span_counts", "walk", "walk_close", "strip", "forearm", "overload",
			"fall_under"]),
			str(tools.show_names()))
	_check("show: the debug tools give its def", tools.show_def(&"span_counts") is NightDef)
	_check("show: and null for an unknown name", tools.show_def(&"nope") == null)
	_check("show: list line format", ShowSetups.list_line(&"span_counts").begins_with("show: span_counts  "),
			ShowSetups.list_line(&"span_counts"))


func _test_names() -> void:
	# `--show=list` lists the setups, so no setup can be called `list`.
	_check("show: no setup is named list", not ShowSetups.names().has("list"), str(ShowSetups.names()))
	for show_name: String in ShowSetups.names():
		var def: NightDef = ShowSetups.def_of(StringName(show_name))
		_check("show: %s's night carries the setup's name, not a real night's" % show_name,
				def != null and def.name == StringName(show_name), str(def.name) if def != null else "null")
	var sim: NightSim = _sim_with(ShowSetups.def_of(&"span_counts"), 9)
	var first: Array[NightEvent] = sim.advance()
	_check("show: span_counts' NIGHT_STARTED says span_counts", first.size() == 1 and first[0].id == &"span_counts")


func _counts(sim: NightSim) -> Array[int]:
	var counts: Array[int] = []
	for n: int in range(1, sim.span.section_count() + 1):
		counts.append(sim.span.planks(n))
	return counts


func _test_walk_setups() -> void:
	# Story 1.3 Dev Notes, "Show-me setups": the same planks in both, 8 1 4 5 8 8.
	for show_name: StringName in [&"walk", &"walk_close"]:
		_check("show: %s is a show-me setup" % show_name, ShowSetups.names().has(show_name))
		var sim: NightSim = _sim_with(ShowSetups.def_of(show_name), 1)
		_check("show: %s has sections at 8 1 4 5 8 8" % show_name, _counts(sim) == [8, 1, 4, 5, 8, 8], str(_counts(sim)))
		_advance(sim, 60)
		_check("show: building and running %s reports no fault" % show_name, _faults.total() == 0, str(_faults.codes()))
	# M1 starts on the landing (along 32: z 2); M2 mid section 5 (along 22.5: z -7.5).
	var walk: NightSim = _sim_with(ShowSetups.def_of(&"walk"), 1)
	_check("show: walk starts on the landing", walk.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(walk.warden.position))
	var close: NightSim = _sim_with(ShowSetups.def_of(&"walk_close"), 1)
	_check("show: walk_close starts mid section 5 (along 22.5)", close.warden.position.is_equal_approx(Vector3(0.0, 0.0, -7.5)),
			str(close.warden.position))
	_check("show: walk_close faces the far pier (yaw 0, pitch 0)", close.yaw == 0.0 and close.pitch == 0.0)


func _test_strip_and_forearm_setups() -> void:
	# Story 1.4 Dev Notes, "Show-me setups".
	var strip: NightSim = _sim_with(ShowSetups.def_of(&"strip"), 1)
	_check("show: strip is a full span", _counts(strip) == [8, 8, 8, 8, 8, 8], str(_counts(strip)))
	_check("show: strip has nothing in hand", strip.span.in_hand(NightTypes.Part.PLANK) == 0
			and strip.span.in_hand(NightTypes.Part.ROPE) == 0)
	_check("show: strip starts mid section 5 (along 22.5: z -7.5)",
			strip.warden.position.is_equal_approx(Vector3(0.0, 0.0, -7.5)), str(strip.warden.position))
	_advance(strip, 60)
	_check("show: building and running strip reports no fault", _faults.total() == 0, str(_faults.codes()))
	var forearm: NightSim = _sim_with(ShowSetups.def_of(&"forearm"), 1)
	# M2: 12 planks (8 from section 1, 4 from section 2) and 3 ropes in hand.
	_check("show: forearm has 12 planks and 3 ropes in hand", forearm.span.in_hand(NightTypes.Part.PLANK) == 12
			and forearm.span.in_hand(NightTypes.Part.ROPE) == 3,
			"%d %d" % [forearm.span.in_hand(NightTypes.Part.PLANK), forearm.span.in_hand(NightTypes.Part.ROPE)])
	_check("show: forearm's sections are 0 4 8 8 8 8", _counts(forearm) == [0, 4, 8, 8, 8, 8], str(_counts(forearm)))
	_check("show: forearm starts on the landing", forearm.warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(forearm.warden.position))
	_advance(forearm, 60)
	_check("show: building and running forearm reports no fault", _faults.total() == 0, str(_faults.codes()))



func _test_overload_and_fall_under_setups() -> void:
	# Story 1.5 Dev Notes, "Show-me setups": section 4 at 4 planks with 3 test weights (not overloaded:
	# 3 < 4, so 120 frames of the CI smoke run see no creak and no fall).
	for show_name: StringName in [&"overload", &"fall_under"]:
		var sim: NightSim = _sim_with(ShowSetups.def_of(show_name), 1)
		_check("show: %s has sections at 8 8 8 4 8 8" % show_name, _counts(sim) == [8, 8, 8, 4, 8, 8], str(_counts(sim)))
		_check("show: %s has 3 weights on section 4 and none elsewhere" % show_name, sim.span.weights(4) == 3
				and sim.span.weights(3) == 0 and sim.span.weights(5) == 0)
		_check("show: %s has the 4 planks taken off in hand" % show_name, sim.span.in_hand(NightTypes.Part.PLANK) == 4)
		var events: Array[NightEvent] = _advance(sim, 120)
		_check("show: %s, 120 ticks untouched: only NIGHT_STARTED" % show_name, _kinds(events) == [NightEvent.Kind.NIGHT_STARTED],
				str(_kinds(events)))
		_check("show: building and running %s reports no fault" % show_name, _faults.total() == 0, str(_faults.codes()))
	# M1 on section 5 at along 20.4 (z -9.6); M2 on section 4 at along 19.2 (z -10.8).
	var overload: NightSim = _sim_with(ShowSetups.def_of(&"overload"), 1)
	_check("show: overload starts at along 20.4", overload.warden.position.is_equal_approx(Vector3(0.0, 0.0, -9.6)),
			str(overload.warden.position))
	var under: NightSim = _sim_with(ShowSetups.def_of(&"fall_under"), 1)
	_check("show: fall_under starts at along 19.2", under.warden.position.is_equal_approx(Vector3(0.0, 0.0, -10.8)),
			str(under.warden.position))
	# fall_under's feet are clear of every weight box (D3 of the show: no standing inside one).
	var feet: Vector3 = under.warden.position
	var clear: bool = true
	for i: int in 3:
		var box: AABB = under.geometry.weight_box(4, i)
		clear = clear and not (feet.x >= box.position.x and feet.x <= box.end.x and feet.z >= box.position.z
				and feet.z <= box.end.z)
	_check("show: fall_under's warden does not stand in a weight", clear)
	# Each M check's first move: two strips of section 4 from where the show starts, looking down
	# just ahead (pitch -1.2 lands 0.622 m ahead), creak then groan, the fall 120 ticks later.
	for show_name: StringName in [&"overload", &"fall_under"]:
		var sim: NightSim = _sim_with(ShowSetups.def_of(show_name), 1)
		sim.set_view(0.0, -1.2)
		sim.advance()
		var kinds: Array[NightEvent.Kind] = []
		for strip: int in 2:
			sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
			kinds.append_array(_kinds(_advance(sim, 121)))
			sim.command(NightCommand.release(NightTypes.HandInput.HAMMER))
		kinds.append_array(_kinds(_advance(sim, 121)))
		var fell: bool = sim.span.fallen(4)
		_check("show: %s: two strips of section 4 creak, groan and fell it" % show_name, fell
				and kinds.has(NightEvent.Kind.CREAK_STARTED) and kinds.has(NightEvent.Kind.GROAN_STARTED)
				and kinds.has(NightEvent.Kind.SECTION_FELL), str(kinds))
		_check("show: %s: %s" % [show_name, "the warden is caught" if show_name == &"fall_under" else "nobody is caught"],
				kinds.has(NightEvent.Kind.WARDEN_CAUGHT) == (show_name == &"fall_under"), str(kinds))
