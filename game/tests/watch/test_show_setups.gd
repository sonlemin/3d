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
	_check("show: the debug tools list span_counts", tools.show_names() == PackedStringArray(["span_counts"]),
			str(tools.show_names()))
	_check("show: the debug tools give its def", tools.show_def(&"span_counts") is NightDef)
	_check("show: and null for an unknown name", tools.show_def(&"nope") == null)
	_check("show: list line format", ShowSetups.list_line(&"span_counts").begins_with("show: span_counts  "),
			ShowSetups.list_line(&"span_counts"))
