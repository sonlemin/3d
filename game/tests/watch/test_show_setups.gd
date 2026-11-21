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
	_check("show: the debug tools list span_counts, walk and walk_close",
			tools.show_names() == PackedStringArray(["span_counts", "walk", "walk_close"]), str(tools.show_names()))
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
